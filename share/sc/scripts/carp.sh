. $TOP/share/sc/scripts/common.sh

carp_setup() {
    case "$1" in
	server)
	    set_conf boot carp_load YES
	    ;;
	*)
	    set_conf boot carp_load
	    ;;
    esac
}

enable_carp() {
    local _val
    case "$1" in
	server)
	    # we should ensure that normal DHCP address should be
	    # acquired before CARP address assigned this is because
	    # nomad will use 1st IP to register service to consul
	    _val=`get_conf rc ifconfig_${NETIF}`
	    if [ -z "$_val" -o "X$_val" = "DHCP" ]; then
		set_conf rc ifconfig_${NETIF} SYNCDHCP
	    fi
	    
	    set_conf rc ifconfig_${NETIF}_alias0 \
		    "inet vhid $TRAEFIK_VHID pass testpass alias $TRAEFIK_IPCONFIG advskew `random_num` up"
	    ;;
	*)
	    _val=`get_conf rc ifconfig_${NETIF}`

	    if [ "X$_val" = "XSYNCDHCP" ]; then
		set_conf rc ifconfig_${NETIF} DHCP
	    fi
	    
	    set_conf rc ifconfig_${NETIF}_alias0
	    ;;
    esac
}

carp_apply() {
    if carp_setup "$1"; then
	true
    else
	return
    fi
    
    enable_carp "$1" 
}
