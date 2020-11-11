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

device_type=`cat /version.txt | grep imagename | cut -d':' -f2 | cut -d'-' -f3`
case "$1" in

    -mo)
        if [ $device_type == "extender" ]; then
            echo "RTROM01-2G-EX"
        else
            echo "RTROM01-2G"
        fi
        ;;
    -sn)
        if [ $device_type == "extender" ]; then
            echo "9876543210"
        else
            echo "1234567890"
        fi
        ;;
    -fw)
        echo "rdk-yocto-rpi"
        ;;
    -cmac)
        if [ $device_type == "extender" ]; then
            echo $(cat /sys/class/net/eth0/address)
        else
            echo $(cat /sys/class/net/erouter0/address)
        fi
        ;;
    -cip)
        echo $(ip addr show brlan0 | grep 'inet ' | awk '{print $2}' | cut -f1 -d'/')
        ;;
    -cipv6)
        echo ""
        ;;
    -emac)
        if [ $device_type == "extender" ]; then
            echo $(cat /sys/class/net/br-wan/address)
        else
            echo $(cat /sys/class/net/erouter0/address)
        fi
        ;;
    -eip)
        if [ $device_type == "extender" ]; then
            echo $(ip addr show br-wan | grep 'inet ' | awk '{print $2}' | cut -f1 -d'/')
        else
            echo $(ip addr show erouter0 | grep 'inet ' | awk '{print $2}' | cut -f1 -d'/')
        fi
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
