# Created Date: Mo Jul 2023
# Author: Azuroso
# -----
# Last Modified: Mon Jul 10 2023
# Modified By: Azuroso
# -----
# Copyright (c) 2023 Azuroso
# -----
# HISTORY:
# Date      	By	Comments
# ----------	---	---------------------------------------------------------

# Fix for relaying ipv6 in luci-proto-relay

temp_save_folder="/tmp/tmp/ipv6_relay_subnets";
subnets_save_path="${temp_save_folder}/subnets";

IS_DEBUGGING=0;
INTERFACE=$1;
ACTION=$2;
#ACTION="iflink";
METRIC_SETTING=255;

ASSIGNED_MASK=64;

function print_log(){
    logger -t IPV6_Relay "$1";
    echo "$1" >> ${temp_save_folder}/test_94-relay.log
}

function assert_dir_exists(){
    if [[ ! -d "${temp_save_folder}" ]] ; then
        mkdir -p ${temp_save_folder};
    fi
}


function get_ipv6_subnet_string(){
    local tgtnetworkstrs=($(ubus call network.interface.${INTERFACE} status | jsonfilter -e "@.route[@.mask=${ASSIGNED_MASK}].target"));
    local formatted_output="";
    for subnet_str in "${tgtnetworkstrs[@]}"
    do
        #echo "$subnet_str,$formatted_output";
        if [ ${#subnet_str} -gt 5 ] ; then
            formatted_output+="${subnet_str}/${ASSIGNED_MASK}\n";
        else
            msg_str="Route ${subnet_str} of ${INTERFACE} on is suspious. Skipped.";
            print_log "${msg_str}";
        fi
    done

    echo -e "$formatted_output";
}



function clear_custom_routes(){
    if [ ! -f ${subnets_save_path} ]; then
        msg_str="Skipping routes deletion for ${INTERFACE} on event ${ACTION} due to failure in finding saved subnets.";
        print_log "${msg_str}";
        return
    fi
    local ipv6_subnet_str=`cat "${subnets_save_path}"`;
    #print_log "${ipv6_subnet_str}.";
    local subnet_array_strs=($(echo "${ipv6_subnet_str}"));
    #($(echo "${ipv6_subnet_str}" | tr ' ' '\n')); #Default using '\n' as array seperator.

    for subnet_str in "${subnet_array_strs[@]}"
    do
        if [ ${#subnet_str} -gt 5 ] ; then
            return_str=`ip -6 route del ${subnet_str} dev br-lan metric ${METRIC_SETTING}`;
            if [ $? -eq 0 ] ; then
                msg_str="Route deleted for ${INTERFACE} on event ${ACTION} on subnet ${subnet_str}.";
                print_log "${msg_str}";
            else
                msg_str="Route failed to delete for ${INTERFACE} on event ${ACTION} on subnet ${subnet_str}. ${return_str}";
                print_log "${msg_str}";
            fi
        fi
    done

    > "${subnets_save_path}";
}


function set_custom_routes(){

    local ipv6_subnet_str=`get_ipv6_subnet_string`;
    local subnet_array_strs=($(echo "${ipv6_subnet_str}"));
    
    #($(echo "${ipv6_subnet_str}" | tr ' ' '\n'));
    #print_log "${ipv6_subnet_str}.";

    if [[ ! -d "${temp_save_folder}" ]] ; then
        mkdir -p ${temp_save_folder};
    fi

    for subnet_str in "${subnet_array_strs[@]}"
    do
        if [ ${#subnet_str} -le 5 ] ; then
            print_log "Skipping invalid subnet String: ${subnet_str}";
            continue
        fi
        return_str=`ip -6 route add ${subnet_str} dev br-lan metric ${METRIC_SETTING}`;
        if [ $? -eq 0 ] ; then
            msg_str="Route added for ${INTERFACE} on event ${ACTION} on subnet ${subnet_str}.";
            
            print_log "${msg_str}";
        else
            msg_str="Route failed to add for ${INTERFACE} on event ${ACTION} on subnet ${subnet_str}. ${return_str}";
            print_log "${msg_str}";
        fi
        
    done
    echo -n "${ipv6_subnet_str}" > "${subnets_save_path}";
}

assert_dir_exists;
#INTERFACE="wan6";
#ACTION="ifdown";
if [ -z "$INTERFACE" ]; then
    print_log "\$Interface variable is empty.";
fi

if [[ $IS_DEBUGGING == 1 ]]; then
    print_log "IPV6_Relay:$(env)";
fi




if [[ "${ACTION}" == "ifupdate" || "${ACTION}" == "iflink" || "${ACTION}" == "ifup" ]] ; then

    clear_custom_routes;

    test_route_mask=`ubus call network.interface.${INTERFACE} status | jsonfilter -e '@["route"][0].mask'`;
    if [ "${test_route_mask}" -eq ${ASSIGNED_MASK} ]; then
        set_custom_routes;
    else
        print_log "Have event ${ACTION} on ${INTERFACE} occurred, but invalid subnets found.";
    fi
    

fi
if [[ "${ACTION}" == "free" || "${ACTION}" == "ifdown" ]] ; then
    clear_custom_routes;
fi


