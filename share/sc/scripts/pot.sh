. $TOP/share/sc/scripts/common.sh
. $TOP/share/sc/scripts/vxlan.sh

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

pot_patch() {
    local _p _dir _t

    _dir=$TOP/share/sc/patches/pot

    for _p in $_dir/*.diff; do
	_t=`basename $_p | sed -e 's/.diff/.patched/g'`

	if [ ! -f /usr/local/share/pot/.$_t ]; then
	    run_cmd patch -d /usr/local/share/pot < $_p
	    run_cmd touch /usr/local/share/pot/.$_t
	fi
    done
}

update_jails_conf() {
    local _jails _j _root _ip _idx _f _idx1 _idx2

    _jails=`/usr/local/bin/pot ls -q |xargs echo `
    _root=`/usr/local/bin/pot config -g fs_root |awk '{print $3}'`
    _idx=`my_host_idx`
    
    if [ -z "$_root" ]; then
	return
    fi

    for _j in $_jails; do
	_f=$_root/jails/$_j/conf/pot.conf

	if [ ! -f $_f ]; then
	    continue
	fi
	
	_ip=`sysrc -i -n -f $_f ip`
	if [ -z "$_ip" ]; then
	    continue
	fi

	_idx2=`expr $_hostid % 253`
	_idx1=`expr $_hostid / 253`
	_idx1=`expr 192 + $_idx1`
	_ip=`echo $_ip |awk -F. '{print $4}'`
	_ip="10.${_idx1}.${_idx2}.${_ip}"

	save_output ${_f}.new  eval "cat ${_f} |grep -E -v '^ip='"
	save_output ${_f}.new echo "ip=${_ip}"

	if [ -f ${_f}.new ]; then
	    run_cmd mv  ${_f}.new $_f
	fi
    done
}

pot_conf_data() {
    local _hostid _idx1 _idx2

    _hostid=`my_host_idx`

    if [ -z "$_hostid" ]; then
	_hostid=0
    fi
    
    _idx2=`expr $_hostid % 253`
    _idx1=`expr $_hostid / 253`
    _idx1=`expr 192 + $_idx1`
    cat <<EOF
POT_NETWORK=10.${_idx1}.${_idx2}.0/24
POT_GATEWAY=10.${_idx1}.${_idx2}.1
POT_DNS_IP=10.${_idx1}.${_idx2}.2
EOF
}
config_pot() {
    local _hostid _f

    _hostid=`my_host_idx`

    _f=/usr/local/etc/pot/pot.conf
    
    save_output ${_f}.new  eval "cat $_f |grep -E -v '^(POT_NETWORK|POT_GATEWAY|POT_DNS_IP)='"
    save_output ${_f}.new pot_conf_data

    if [ -f ${_f}.new ]; then
	run_cmd mv ${_f}.new $_f
    fi
    
    update_jails_conf
    
    run_cmd /usr/local/bin/pot init
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
    local _f
    if pot_need_update ; then
	case "$1" in
	    client|server)
		_f=/usr/local/bin/pot
		if [ ! -f $_f -o ! -x $_f ]; then
		    install_pkgs pot
		fi

		_f=/usr/local/bin/potnet
		if [ ! -f $_f -o ! -x $_f ]; then
		    install_pkgs potnet
		fi
		
		config_pot
		;;
	    *)
		echo
		;;
	esac
    fi
}

pot_start() {
    local _pot_bridge _ip _vxlan_if
    
    PATH=$PATH:/usr/local/bin
    export PATH
    
    /usr/local/bin/pot vnet-start
    _pot_bridge=`sc_pot_bridge`

    if [ -z "$_pot_bridge" ]; then
	return
    fi
    
    _ip=`ifconfig $_pot_bridge |awk '/inet/ {print $2}'`

    # re-generate ther addr for bridge
    ifconfig $_pot_bridge ether random
    ifconfig $_pot_bridge ${_ip}/10

    _vxlan_if=`vxlan_create $NETIF`

    if [ ! -z "$_vxlan_if" ]; then
	ifconfig $_pot_bridge addm ${_vxlan_if}
    fi
    
    # prune jails
    /usr/local/bin/pot prune
}
