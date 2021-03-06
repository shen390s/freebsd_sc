DRY_RUN=yes
DATACENTER=dc1
MY_NAME=`hostname`

case `uname -s` in
    Darwin)
	NETIF=en0
	;;
    FreeBSD)
	NETIF=em0
	;;
    *)
	NETIF=eth0
	;;
esac

test_config() {
    echo "Running test for making traefik $1 configuration"

    case "$1" in
	client)
	    CLUSTER_HOSTS="$MY_NAME h1:1 h2:1 :h3 1"
	    ;;
	server)
	    CLUSTER_HOSTS="$MY_NAME:1 h1:1 h2:1 h3:1"
	    TRAEFIK_EXTRA_ENTRYPOINTS="tcp1:3313 tcp2:3314"
	    ;;
    esac
    
    if [ "X$1" = "Xserver" ]; then
	config_traefik server
    else
	echo We need do nothing for client
    fi
}

run_case() {
    test_config "client"
    test_config "server"
}
