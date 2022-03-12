. $TOP/share/sc/scripts/common.sh

carp_start() {
    case "$1" in
	server)
	    if kldstat | grep carp 2>&1 >/dev/null; then
		:
	    else
		run_cmd kldload carp
	    fi
	    
	    run_cmd ifconfig ${NETIF} inet vhid $TRAEFIK_VHID \
		    pass testpass alias $TRAEFIK_IPCONFIG \
		    advskew `random_num` up
	    ;;
	*)
	    true
	    ;;
    esac
}
