. $TOP/share/sc/scripts/common.sh

pot_pkgs() {
    echo pot 
}

pot_need_update() {
    local _c1 _c2 

    _c1=/usr/local/etc/sc/sc.conf
    _c2=/usr/local/etc/pot/pot.conf

    if [ ! -f $_c2 ]; then
	:
    elif [ "X`file_newer $_c1 $_c2`" = "Xyes" ]; then
	:
    else
	false
    fi
}

update_jails_conf() {
    local _jails _j _root _ip _idx _f

    _jails=`pot ls -q`
    _root=`pot config -g fs_root |awk -F= '{print $2}'`
    _idx=`my_host_idx`
    
    if [ -z "$_root" ]; then
	return
    fi

    for _j in $_jails; do
	_f=$_root/jails/$_j/conf/pot.conf
	_ip=`sysrc -i -n -f $_f ip`
	if [ -z "$_ip" ]; then
	    continue
	fi

	_ip=`echo $_ip |awk -F. '{print $4}'`
	_ip="10.192.${_idx}.${_ip}"

	run_cmd cp  $_f ${_f}.old
	save_output $_f eval "cat ${_f}.old |grep -E -v '^ip='"
	save_output $_f echo "ip=${_ip}"

	if [ -f ${_f}.old ]; then
	    rm -Rf ${_f}.old
	fi
    done
}

pot_conf_data() {
    local _hostid

    _hostid=`my_host_idx`

    if [ -z "$_hostid" ]; then
	_hostid=0
    fi
    
    cat <<EOF
POT_NETWORK=10.192.${_hostid}.0/24
POT_GATEWAY=10.192.${_hostid}.1
POT_DNS_IP=10.192.${_hostid}.2
EOF
}
config_pot() {
    local _hostid _f

    _hostid=`my_host_idx`

    _f=/usr/local/etc/pot/pot.conf
    
    run_cmd cp $_f ${_f}.old

    set -x
    save_output $_f eval "cat $_f.old |grep -E -v '^(POT_NETWORK|POT_GATEWAY|POT_DNS_IP)='"
    save_output $_f pot_conf_data

    if [ -f ${_f}.old ]; then
	rm -Rf ${_f}.old
    fi
    
    update_jails_conf
    
    run_cmd pot init
}

sc_pot_bridge() {
    local _bridges _b _ip

    . /usr/local/etc/pot/pot.default.conf
    . /usr/local/etc/pot/pot.conf
    
    _bridges=`ifconfig |grep ^bridge | cut -f1 -d':'`

    for _b in $_bridges; do
	_ip=`ifconfig "$_b" |awk '/inet/ { print $2}'`

	if [ "$_ip" = "$POT_GATEWAY" ]; then
	    echo "$_b"
	    return

	fi
    done
}

pot_apply() {
    if pot_need_update ; then
	case "$1" in
	    client|server)
		run_cmd pkg install -y pot
		config_pot
		;;
	    *)
		echo
		;;
	esac
    fi
}

pot_start() {
    local _pot_bridge _ip
    
    /usr/local/bin/pot vnet-start
    _pot_bridge=`sc_pot_bridge`

    if [ ! -z "$_pot_bridge" ]; then
	_ip=`ifconfig $_pot_bridge |awk '/inet/ {print $2}'`
	ifconfig $_pot_bridge ${_ip}/10
    fi

    echo "POT bridge $_pot_bridge"
}
