# Author: Azuroso
# Fix for relaying ipv6 in luci-proto-relay

temp_save_folder="/tmp/tmp/ipv6_relay_subnets";

#INTERFACE="wan6";
#ACTION="iflink";
METRIC_SETTING=1024;

function print_log(){
    logger -t IPV6_Relay "$1";
    echo "$1" >> /tmp/tmp/test_94-relay.log
}


print_log "IPV6_Relay:$(env)";


function get_ipv6_subnet_string(){
    echo `ip -6 route show default | sed -n -e 's/default from //' -e 's/ via .*$//g' -e '/64$/p'`
}



function clear_custom_routes(){
    if [ ! -f "${temp_save_folder}/subnets" ]; then
        msg_str="Skipping routes deletion for ${INTERFACE} on event ${ACTION} due to failure in finding save subnets.";
        print_log "${msg_str}";
        return
    fi
    ipv6_subnet_str=`cat "${temp_save_folder}/subnets"`;
    #print_log "${ipv6_subnet_str}.";
    subnet_array_strs=($(echo "${ipv6_subnet_str}" | tr ' ' '\n'));

    for subnet_str in "${subnet_array_strs[@]}"
    do
        
        return_str=`ip -6 route del ${subnet_str} dev br-lan metric ${METRIC_SETTING}`;
        if [ $? -eq 0 ] ; then
            msg_str="Route deleted for ${INTERFACE} on event ${ACTION} on subnet ${subnet_str}.";
            print_log "${msg_str}";
        else
            msg_str="Route failed to delete for ${INTERFACE} on event ${ACTION} on subnet ${subnet_str}. ${return_str}";
            print_log "${msg_str}";
        fi
        
    done

    > "${temp_save_folder}/subnets";
}


function set_custom_routes(){

    ipv6_subnet_str=`get_ipv6_subnet_string`;
    subnet_array_strs=($(echo "${ipv6_subnet_str}" | tr ' ' '\n'));
    #print_log "${ipv6_subnet_str}.";

    if [[ ! -d ${temp_save_folder} ]] ; then
        mkdir -p ${temp_save_folder};
    fi

    for subnet_str in "${subnet_array_strs[@]}"
    do
        #echo "$subnet_str"
        return_str=`ip -6 route add ${subnet_str} dev br-lan metric ${METRIC_SETTING}`;
        if [ $? -eq 0 ] ; then
            msg_str="Route added for ${INTERFACE} on event ${ACTION} on subnet ${subnet_str}.";
            print_log "${msg_str}";
        else
            msg_str="Route failed to add for ${INTERFACE} on event ${ACTION} on subnet ${subnet_str}. ${return_str}";
            print_log "${msg_str}";
        fi
        
    done
}


#INTERFACE="wan6";
#ACTION="ifdown";



if [[ "${INTERFACE}" == "wan6" ]] ; then

    if [[ "${ACTION}" == "ifupdate" || "${ACTION}" == "iflink" || "${ACTION}" == "ifup" ]] ; then

        clear_custom_routes;

        test_route_mask=`ubus call network.interface.wan6 status | jsonfilter -e '@["route"][0].mask'`;
        if [ ${test_route_mask} -eq 64 ]; then
            set_custom_routes;
        else
            print_log "Have event ${ACTION} on ${INTERFACE} occurred, but no ipv6 subnets obtained.";
        fi
        

    fi
    if [[ "${ACTION}" == "free" || "${ACTION}" == "ifdown" ]] ; then
        clear_custom_routes;
    fi
fi

