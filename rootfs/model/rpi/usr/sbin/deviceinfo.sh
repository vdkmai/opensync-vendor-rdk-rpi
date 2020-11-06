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

case "$1" in

    -mo)
        echo "RTROM01-2G"
        ;;
    -sn)
        echo "1234567890"
        ;;
    -fw)
        echo "rdk-yocto-rpi"
        ;;
    -cmac)
	echo $(cat /sys/class/net/erouter0/address)
        ;;
    -cip)
	echo $(ip addr show brlan0 | grep 'inet ' | awk '{print $2}' | cut -f1 -d'/')
        ;;
    -cipv6)
        echo ""
        ;;
    -emac)
	echo $(cat /sys/class/net/erouter0/address)
        ;;
    -eip)
	echo $(ip addr show erouter0 | grep 'inet ' | awk '{print $2}' | cut -f1 -d'/')
        ;;
    -eipv6)
        echo ""
        ;;
    -lmac)
	echo $(cat /sys/class/net/brlan0/address)
        ;;
    -lip)
	echo $(ip addr show brlan0 | grep 'inet ' | awk '{print $2}' | cut -f1 -d'/')
        ;;
    -lipv6)
        echo ""
        ;;
    -ms)
	echo "Full"
        ;;
    -mu)
	echo "ssl:wildfire.plume.tech:443"
        ;;

    *)
        echo "Usage: deviceinfo.sh [-mo|-sn|-fw|-cmac|-cip|-cipv6|-emac|-eip|-eipv6|-lmac|-lip|-lipv6|-ms|-mu]"
        exit 1
        ;;
esac
