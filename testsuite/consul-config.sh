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
    echo "Running test for making consul $1 configuration"

    case "$1" in
	client)
	    CLUSTER_HOSTS="$MY_NAME h1:1 h2:1 :h3 1"
	    ;;
	server)
	    CLUSTER_HOSTS="$MY_NAME:1 h1:1 h2:1 h3:1"
	    ;;
    esac
    
    config_consul_client

    if [ "X$1" = "Xserver" ]; then
	config_consul_srv
    fi
}

run_case() {
    test_config "client"
    test_config "server"
}
