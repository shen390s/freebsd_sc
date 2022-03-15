. $TOP/share/sc/scripts/common.sh

get_interf_ip() {
    get_interface_ips "$1"
}

vxlanid() {
    if [ -z "$VXLAN_ID" ]; then
	echo 42
    else
	echo $VXLAN_ID
    fi
}

vxlan_group() {
    local _group

    _group=224.0.1.`vxlanid`
    
    echo $_group 
}

vxlan_inet() {
    local _host _inet _idx1 _idx2

    _host=`my_host_idx`
    # do not use IP address
    # - x.x.x.0
    # - x.x.x.254
    # - x.x.x.255
    _idx1=`expr $_host / 253`
    _idx2=`expr $_host % 253`
    _idx2=`expr $_idx2 + 1`
    _inet="172.16.${_idx1}.${_idx2}"
    echo $_inet
}

vxlan_if() {
    local _vxlans _vxlanid _v _idx

    _vxlans=`ifconfig -a |grep '^vxlan' |awk -F: '{ print $1}'`
    _vxlanid=`vxlanid`

    for _v in $_vxlans; do
	_idx=`ifconfig $_v |grep vxlan |grep vni |awk '{ print $3}'`

	if [ "X$_idx" = "X$_vxlanid" ]; then
	    echo $_v
	    return
	fi
    done

    echo 
}

vxlan_create () {
    local _vxlandev _inet _vxlanlocal _vxlanid _vxlangroup _host _vxlan_if

    _vxlandev="$1"
    
    _vxlanlocal=`get_interf_ip $_vxlandev`
    _vxlanid=`vxlanid`
    _vxlangroup=`vxlan_group`
    _inet=`vxlan_inet`

    route add -net `echo $_vxlangroup |awk -F. '{print $1}'`/8 -interface "$_vxlandev" 2>&1 >/dev/null

    _vxlan_if=`vxlan_if`
    if [ -z "$_vxlan_if" ]; then
	_vxlan_if=`ifconfig vxlan create`
    fi

    if [ ! -z "$_vxlan_if" ]; then
	ifconfig $_vxlan_if ether random
	ifconfig $_vxlan_if vxlanid $_vxlanid \
		 vxlanlocal $_vxlanlocal \
		 vxlangroup $_vxlangroup \
		 vxlandev "$_vxlandev" 
	ifconfig $_vxlan_if inet "$_inet" \
		 up
    fi
    echo "$_vxlan_if"
}

