/*
If not stated otherwise in this file or this component's LICENSE
file the following copyright and licenses apply:

Copyright [2020] [RDK Management]

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <ctype.h>
#include <stdbool.h>
#include <errno.h>

#include "log.h"
#include "target.h"


typedef struct
{
    uint8_t  vif_radio_idx;
    char     *cloud_ifname;
    char     *device_ifname;
    char     *bridge;
    char     *gre_bridge;
    uint16_t vlan_id;
} ifmap_t;

// TODO: Fill with correct interfaces and bridges
static ifmap_t  ifmap[] = {
   // idx   cloud-ifname     dev-ifname  bridge    gre-br            vlan     description
   // { 3,    "wifi4",   "wifi4",    "brlan0", "wifi4", 0 },  // 2G onboard
   // { 3,    "wifi5",   "wifi5",    "brlan0", "wifi5",  0 },  // 5G onboard
   // { 1,    "wifi2",   "wifi2",    "brlan0", "wifi2", 0 },  // 2G Backhaul
    { 1,    "wifi3",   "wifi3",    "brlan0", "wifi3",  0 },  // 5G Backhaul
   // { 2,    "wifi0",    "wifi0",    "brlan0",  NULL,            0 },  // 2G User SSID
    { 2,    "wifi1",    "wifi1",    "brlan0",  NULL,            0 },  // 5G User SSID
    { 0,    NULL,            NULL,       NULL,     NULL,             0 }
};


bool target_map_ifname_init(void)
{
    static bool init = false;
    ifmap_t     *mp;

    if (init)
    {
        return true;
    }
    init = true;

    target_map_init();

    // Register cloud <-> device interface mappings

    mp = ifmap;
    while (mp->device_ifname)
    {
        target_map_insert(mp->cloud_ifname, mp->device_ifname);

        mp++;
    }

    return true;
}

char* target_map_ifname_to_bridge(const char *ifname)
{
    ifmap_t     *mp;

    mp = ifmap;
    while (mp->device_ifname)
    {
        if (!strcmp(ifname, mp->device_ifname) || !strcmp(ifname, mp->cloud_ifname))
        {
            return mp->bridge;
        }

        mp++;;
    }

    return NULL;
}

char* target_map_ifname_to_gre_bridge(const char *ifname)
{
    ifmap_t     *mp;

    mp = ifmap;
    while (mp->device_ifname)
    {
        if (!strcmp(ifname, mp->device_ifname) || !strcmp(ifname, mp->cloud_ifname))
        {
            return mp->gre_bridge;
        }

        mp++;;
    }

    return NULL;
}

uint16_t target_map_ifname_to_vlan(const char *ifname)
{
    ifmap_t     *mp;

    mp = ifmap;
    while (mp->device_ifname)
    {
        if (!strcmp(ifname, mp->device_ifname) || !strcmp(ifname, mp->cloud_ifname))
        {
            return mp->vlan_id;
        }

        mp++;;
    }

    return 0;
}

uint8_t target_map_ifname_to_vif_radio_idx(const char *ifname)
{
    ifmap_t     *mp;

    mp = ifmap;
    while (mp->device_ifname)
    {
        if (!strcmp(ifname, mp->device_ifname) || !strcmp(ifname, mp->cloud_ifname))
        {
            return mp->vif_radio_idx;
        }

        mp++;;
    }

    return 0;
}

uint16_t target_map_bridge_to_vlan(const char *bridge)
{
    ifmap_t     *mp;

    mp = ifmap;
    while (mp->device_ifname)
    {
        if (!strcmp(bridge, mp->bridge))
        {
            return mp->vlan_id;
        }

        mp++;;
    }

    return 0;
}

char* target_map_vlan_to_bridge(uint16_t vlan_id)
{
    ifmap_t     *mp;

    mp = ifmap;
    while (mp->device_ifname)
    {
        if (vlan_id == mp->vlan_id)
        {
            return mp->bridge;
        }

        mp++;;
    }

    return NULL;
}

bool target_map_update_vlan(const char *ifname, uint16_t vlan_id)
{
    ifmap_t     *mp;

    mp = ifmap;
    while (mp->device_ifname)
    {
        if (!strcmp(ifname, mp->device_ifname) || !strcmp(ifname, mp->cloud_ifname))
        {
            mp->vlan_id = vlan_id;
            return true;
        }

        mp++;;
    }

    return false;
}
