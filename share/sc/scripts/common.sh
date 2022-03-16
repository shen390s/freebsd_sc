. $TOP/share/sc/scripts/funcs.sh
. $TOP/share/sc/scripts/pkgmgr.sh

parse_opts() {
    local _tag _optf

    _tag="$1"
    shift

    case "$_tag" in
	apply|install)
	    _optf="nc:i:"
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
	    --)
		shift
		break
		;;
	esac
    done
    export CONF NETIF DRY_RUN
}

file_modify_time() {
    eval $(stat -s "$1")
    echo $st_mtime
}

file_newer() {
    local _mt1 _mt2

    _mt1=`file_modify_time "$1"`
    _mt2=`file_modify_time "$2"`

    if [ $_mt1 -gt $_mt2 ]; then
	echo yes
    else
	echo no
    fi
}

set_boot_conf() {
    if [ -z "$2" ]; then
	run_cmd sysrc -f /boot/loader.conf -i -x "$1"
	# ignore error variable not existed
	true
    else
	run_cmd sysrc -f /boot/loader.conf "$1=\"$2\""
    fi
}

set_rc_conf() {
    if [ -z "$2" ]; then
	run_cmd sysrc -i -x "$1"
	#  ignore error variable not existed
	true
    else
	run_cmd sysrc "$1=\"$2\""
    fi
}

set_conf() {
    local _tab _file  _key _value

    _tab="$1"
    _key="$2"
    _value="$3"

    if fn_defined "set_${_tab}_conf" ; then
	eval "set_${_tab}_conf \"$_key\" \"$_value\""
    else
	echo "Unknown conf $_tab"
	false
    fi
}

get_boot_conf() {
    sysrc -f /boot/loader.conf -n -i "$1"
}

get_rc_conf() {
    sysrc -n -i "$1"
}

get_conf() {
    local _tab _key

    _tab="$1"
    _key="$2"

    if fn_defined "get_${_tab}_conf" ; then
	eval "get_${_tab}_conf \"$_key\""
    else
	echo
    fi
}

get_server_list() {
    local _servers _h _item _is_server

    if [ ! -z "$SERVER_HOSTS" ]; then
	echo "$SERVER_HOSTS"
	return
    fi
    
    _servers=
    for _item in $CLUSTER_HOSTS; do
	_is_server=`echo $_item |awk -F: '{print $2}'`
	_h=`echo $_item |awk -F: '{print $1}'`
	if [ -z "$_is_server" -o "X$_is_server" != "X1" ]; then
	    true
	else
	    _servers="$_servers $_h"
	fi
    done

    SERVER_HOSTS="$_servers"
    export SERVER_HOSTS
    echo "$_servers"
}

get_all_hosts() {
    local _all_hosts _item _h

    if [ ! -z $ALL_HOSTS ]; then
	echo "$ALL_HOSTS"
	return
    fi
    
    _all_hosts=
    for _item in $CLUSTER_HOSTS; do
	_h=`echo $_item | awk -F: '{print $1}'`
	_all_hosts="$_all_hosts $_h"
    done

    ALL_HOSTS="$_all_hosts"
    export ALL_HOSTS

    echo "$_all_hosts"
}

my_host_idx() {
    local _all_hosts _h _idx _host

    _all_hosts=`get_all_hosts`
    _h=`hostname`
    _idx=0

    for _host in $_all_hosts; do
	if [ "X$_h" == "X$_host" ]; then
	    echo $_idx
	    return
	fi
	_idx=`expr $_idx + 1`
    done   
}

get_server_count() {
    local _servers _nc _s

    _nc=0
    _servers=`get_server_list`
    for _s in $_servers; do
	_nc=`expr $_nc + 1`
    done
    echo $_nc
}

get_voted_server_count() {
    local _nc

    _nc=`get_server_count`
    _nc=`expr $_nc / 2`
    expr $_nc + 1
}

is_server() {
    local _host _servers

    _host=`hostname`
    _servers=`get_server_list`

    name_in_list $_host "$_servers"
}


get_interface_ips() {
    local _if

    _if="$1"

    # do not include ip address with vhid
    ifconfig "$_if" |grep -v vhid|awk '$1 == "inet" {print $2}' |xargs echo
}

get_bind_ip() {
    get_interface_ips "$1"| awk '{print $1}'
}

shape_server_hosts() {
    local _h _sep _hosts

    _set=
    _hosts=
    for _h in `get_server_list`; do
	_hosts="$_hosts$_sep\"$_h\""
	_sep=","
    done
    echo "$_hosts"
}

update_host_entry() {
    local _line _comments _data _break _ip _host _ip2 _found _ok
    
    _host="$1"
    _ip="$2"

    _break=no
    _ok=no
    while :; do
	if read _line; then
	    :
	else
	    _break=yes
	fi

	if [ ! -z "$_line" ]; then
	    _data=`echo $_line | sed -e 's/#.*$//g'`
	    if [ -z "$_data" ]; then
		echo "$_line"
	    else
		_comments=`echo $_line | sed -e 's/^[^#]*$//g' -e '/^$/d' -e 's/^[^#]*#/#/g'`
		set -- $_data
		_ip2="$1" &&  shift
		
		if [ "X$_ip" = "X$_ip2" ]; then
		    if name_in_list $_host "$*" ; then
			:
		    else
			_data="$_data $_host"
		    fi
		    _ok=yes
		else
		    _data=`exclude_from_list $_host $_data`
		fi
		
		if [ -z "$_comments" ]; then
		    echo "$_data"
		else
		    echo "$_data$_comments"
		fi
	    fi
	fi
	
	if [ "X$_break" = "Xyes" ]; then
	    break
	fi
    done

    if [ "X$_ok" = "Xno" ]; then
	echo "$_ip $_host"
    fi
}

update_hosts() {
    local _host _ip _item _cmd_pre _cmd _sep

    _cmd_pre="touch /etc/hosts && cp /etc/hosts /etc/hosts.old && cat /etc/hosts.old"
    _cmd=""
    _sep=""
    for _item in $*; do
	_host=`echo $_item |awk -F: '{print $1}'`
	_ip=`echo $_item | awk -F: '{print $2}'`
	_cmd="$_cmd $_sep update_host_entry $_host $_ip"
	_sep=" | "
    done

    if [ ! -z "$_cmd" ]; then
	if [ -f /etc/hosts ]; then
	    run_cmd mv /etc/hosts /etc/hosts.1
	fi
	
	save_output /etc/hosts eval "$_cmd_pre | $_cmd"
	if [ -f /etc/hosts ]; then
	    run_cmd rm -Rf /etc/hosts.1
	else
	    run_cmd cp /etc/hosts.1 /etc/hosts
	fi
    fi

    if [ -f /etc/hosts ]; then
	if [ -f /etc/hosts.old ]; then
	    rm -Rf /etc/hosts.old
	fi
    else
	if [ -f /etc/hosts.old ]; then
	    mv /etc/hosts.old /etc/hosts
	fi
    fi
}

update_fstab_entry() {
    local _line _fs1 _fs _mnt1 _mnt _break _ok _data _comments

    _fs="$1"
    _mnt="$2"

    _break=no
    _ok=no

    while :; do
	if read _line ; then
	    :
	else
	    _break=yes
	fi

	if [ ! -z "$_line" ]; then
	    _data=`echo $_line | sed -e 's/#.*$//g'`
	    if [ -z "$_data" ]; then
		echo "$_line"
	    else
		_comments=`echo $_line | sed -e 's/^[^#]*$//g' -e '/^$/d' -e 's/^[^#]*#/#/g'`

		_fs1=`echo $_data |awk '{print $1}'`
		_mnt1=`echo $_data | awk '{print $2}'`

		if [ "X$_fs1" = "X$_fs" ]; then
		    if [ "X$_mnt1" = "X$_mnt" ]; then
			_ok=yes
		    fi
		    echo "$_line"
		else
		    if [ "X$_mnt1" = "X$_mnt" ]; then
			# FIXME: conflict mount point
			echo "# FIXME: please edit following line"
			echo "# $_line"
			echo "$_fs $_mnt nfs rw 0 0"
			_ok=yes
		    else
			echo "$_line"
		    fi
		fi
	    fi
	fi

	if [ "X$_break" = "Xyes" ]; then
	    break
	fi
    done

    if [ "X$_ok" = "Xno" ]; then
	echo "$_fs $_mnt nfs rw 0 0"
    fi
}

render_in() {
    local _data  _line _done

    _done=no
    while [ "X$_done" = "Xno" ]; do
	if read _line ; then
	    :
	else
	    _done=yes
	fi
	
	_data=`echo $_line |sed -e 's/"/\\\\"/g'`
	eval "echo \"$_data\""
    done
}

render_template() {
    cat "$1"| render_in
}

render_to() {
    local _to _tp

    _to="$1"
    _tp="$2"
    run_cmd rm -Rf "$_to"
    save_output "$_to" render_template "$_tp"
}

