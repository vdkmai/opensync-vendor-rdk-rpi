#!/bin/sh

#If not stated otherwise in this file or this component's LICENSE
#file the following copyright and licenses apply:
#
#Copyright [2020] [RDK Management]
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.

#
# Log-pull script for RDK

Usage() {
    echo "Usage: lm_log_pull.sh <upload-url> <upload-token> [status-dir]"
    exit 1
}

log() {
    echo "lm_log_pull: $*"
}

error_out() {
    log "ERROR - $*"
    exit 1
}

collect_cmd() {
    _outfn="$LM_PULL_DIR/$(echo -n "$*" | tr -C "A-Za-z0-9.-" _)"
    "$@" > "${_outfn}" 2>&1
}

[ $# -eq 0 ] && Usage
LM_UPLOAD_URL="$1"; shift

[ $# -eq 0 ] && Usage
LM_UPLOAD_TOKEN="$(basename $1)"; shift

LM_STATUS_DIR="$1"; shift
[ $# -ne 0 ] && Usage

LM_TEMP_DIR="/tmp/lm"
LM_TSTAMP="$(date +'%Y%m%d_%H%M%S')"
LM_PULL_NAME="pull_${LM_TSTAMP}"
LM_PULL_DIR="${LM_TEMP_DIR}/${LM_PULL_NAME}"

log "Pulling into ${LM_PULL_DIR}..."
mkdir -p "${LM_PULL_DIR}" || error_out "failed to create ${LM_PULL_DIR}"
cd "${LM_PULL_DIR}"

# First handle syslog, for example using journalctl
journalctl > messages_${LM_TSTAMP}

### Now handle collection from commands

# OVSDB
collect_cmd ovsdb-client dump
collect_cmd ovsdb-client -f json dump

# Networking
collect_cmd ifconfig -a
collect_cmd ip -d link show
collect_cmd route -n
collect_cmd arp -an
collect_cmd brctl show

# System
collect_cmd ps wl
collect_cmd top -n1
collect_cmd free
collect_cmd df -h
collect_cmd dmesg
collect_cmd cat /etc/resolv.conf
collect_cmd cat /nvram/dnsmasq.leases

# Wireless
collect_cmd iwconfig
collect_cmd iw dev

# Device info
for x in -mo -sn -fw -ms -mu -cmac -cip -cipv6 -emac -eip -eipv6 -lmac -lip -lipv6; do
    collect_cmd deviceinfo.sh $x
done

# status files
if [ -n "${LM_STATUS_DIR}" -a -d "${LM_STATUS_DIR}" ]; then
    mv "${LM_STATUS_DIR}"/* "${LM_PULL_DIR}"/
fi

# RDK Logs
if [ -d /rdklogs/logs ]; then
    cp -dpR /rdklogs/logs "${LM_PULL_DIR}/rdklogs"
fi

# Collect all core dump files
mkdir -p Core
mv /tmp/*.core.gz  Core/

# Create tarball
log "Creating tarball: ${LM_UPLOAD_TOKEN}"
cd $LM_TEMP_DIR || error_out
tar -czf "$LM_UPLOAD_TOKEN" "$LM_PULL_NAME"

# Upload tarball
log "Uploading tarball to ${LM_UPLOAD_URL}"
curl --cert /usr/opensync/etc/certs/client.pem --key /usr/opensync/etc/certs/client_dec.key -v -F filename=@${LM_UPLOAD_TOKEN} $LM_UPLOAD_URL || log "Upload failed!!"

# Cleanup
log "Cleaning up"
cd "$LM_TEMP_DIR" || error_out
rm -rf "${LM_PULL_DIR}"
rm -f "${LM_UPLOAD_TOKEN}"

exit 0
