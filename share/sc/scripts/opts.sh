parse_opts() {
    local _tag _optf

    _tag="$1"
    shift

    case "$_tag" in
	apply|install)
	    _optf="vnc:i:"
	    ;;
	test)
	    _optf="v"
	    ;;
	*)
	    _optf=""
	    ;;
    esac

    if [ -z "$_optf" ]; then
	true
	return
    fi
    
    _args=`getopt $_optf $*`
    if [ $? != 0 ]; then
	false
	return
    fi

    set -- $_args
    while :; do
	case "$1" in
	    -c)
		CONF="$2"
		shift 2
		;;
	    -i)
		NETIF="$2"
		shift 2
		;;
	    -n)
		DRY_RUN=yes
		shift 
		;;
	    -v)
		DEBUG=yes
		shift
		;;
	    --)
		shift
		break
		;;
	esac
    done

    if [ "X$DEBUG" = "Xyes" ]; then
	set -x
    fi
    
    case "$_tag" in
	test)
	    CASES="$@"
	    export CASES
	    ;;
	*)
	    true
	    ;;
    esac
    
    export CONF NETIF DRY_RUN DEBUG
}
