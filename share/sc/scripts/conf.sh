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

update_host_entry() {
    local _line _comments _data _break _ip _host _ip2 _found _ok
    
    _host="$1"
    _ip="$2"

    _break=no
    _ok=no
    while :; do
	if IFS= read -r _line; then
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

    _cmd_pre="touch /etc/hosts && cat /etc/hosts"
    _cmd=""
    _sep=""
    for _item in $*; do
	_host=`echo $_item |awk -F: '{print $1}'`
	_ip=`echo $_item | awk -F: '{print $2}'`
	_cmd="$_cmd $_sep update_host_entry $_host $_ip"
	_sep=" | "
    done

    if [ ! -z "$_cmd" ]; then
	save_output /etc/hosts.new eval "$_cmd_pre | $_cmd"
	if [ -f /etc/hosts.new ]; then
	    run_cmd mv /etc/hosts.new /etc/hosts 
	fi
    fi
}

