#!/bin/sh

# File: zerotier_daemon.sh
# Relative Path: \
# File Created: Sunday, 18th February 2024 12:08:58
# Author: Azuroso
# -----
# Last Modified: Sunday, 18th February 2024 12:10:37
# -----
# Copyright 2024 Azuroso

#Recommanded to add intervals of 5 minutes to check if connected otherwise restart the service.
#Only for openwrt.

function checkNetworkStatus(){
    ping -c 1 www.baidu.com > /dev/null;
    echo $?;
}

function getZerotierStatus(){
    local status_str=`zerotier-cli status`;
    echo -n "${status_str}" | awk '{print $1}';
}

function restartZerotierService(){
    /etc/init.d/zerotier restart;
    echo $?;
}



ztStatusCode=`getZerotierStatus`;
if [[ "${ztStatusCode}" != 200 ]]; then
    networkStatusCode=`checkNetworkStatus`;
    #echo "${ztStatusCode},${networkStatusCode}";
    if [[ "${networkStatusCode}" != 0 ]]; then
        logger -t ZT-NW-Daemon "Non-connected zerotier status-code ${ztStatusCode} with network available, restarting zerotier service.";
        restartCode=`restartZerotierService`;
        logger -t ZT-NW-Daemon "Zerotier service restart result code ${restartCode}.";
    else
        logger -t ZT-NW-Daemon "Non-connected zerotier status-code ${ztStatusCode} without network available, waiting for network.";
    fi
fi

exit 0;