. $TOP/share/sc/scripts/common.sh

hosts_apply() {
    echo apply hosts role $1
    case "$1" in
	client|server)
	    update_hosts $HOSTS
	    ;;
	*)
	    ;;
    esac
}
