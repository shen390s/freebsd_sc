. $TOP/share/sc/scripts/common.sh

consul_stop() {
    run_cmd service consul stop
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

consul_bind_ip() {
    get_bind_ip "$1"
}

consul_cleanup() {
    run_cmd rm -Rf /usr/local/etc/consul.d
    run_cmd rm -Rf /var/db/consul
}

consul_need_update() {
    local _c1 _c2 _c3

    _c1=/usr/local/etc/sc/sc.conf
    _c2=/usr/local/etc/consul.d/consul.hcl
    _c3=/usr/local/etc/consul.d/server.hcl

    if [ ! -f $_c2 ]; then
	:
    elif [ ! -f $_c3 ]; then
	:
    elif [ "X`file_newer $_c1 $_c2`" = "Xyes" ]; then
	:
    elif [ "X`file_newer $_c1 $_c3`" = "Xyes" ]; then
	:
    else
	false
    fi
}

config_consul_client() {
    local _bind_addr _server_hosts 

    _bind_addr=`consul_bind_ip $NETIF`
    _server_hosts=`shape_server_hosts`
    _DATACENTER="$DATACENTER"
    _BIND_ADDR="$_bind_addr"
    _SERVERS="$_server_hosts"
    render_to /usr/local/etc/consul.d/consul.hcl \
	      $TOP/share/sc/templates/consul.hcl.template 
    touch /var/run/.sc.consul.updated
}

config_consul_srv() {
    _VOTE_COUNT=`get_voted_server_count`
    render_to /usr/local/etc/consul.d/server.hcl \
	      $TOP/share/sc/templates/consul-server.hcl.template 
    touch /var/run/.sc.consul.updated
}

config_consul() {
    local _role

    _role="$1"
    
    if [ ! -d /usr/local/etc/consul.d ]; then
	run_cmd mkdir -p /usr/local/etc/consul.d
    fi
    
    if [ ! -d /var/db/consul ]; then
	run_cmd mkdir -p /var/db/consul
    fi
    
    run_cmd chown -Rf consul:consul /var/db/consul
    config_consul_client

    if [ "X$_role" = "Xserver" ]; then
	config_consul_srv
    fi
}

enable_consul() {
    set_conf rc consul_enable YES
}

disable_consul() {
    set_conf rc consul_enable
}

consul_apply_sc() {
    install_pkgs consul 
    config_consul "$1"
    enable_consul
}

consul_apply_none() {
    consul_stop
    disable_consul
    consul_cleanup
    uninstall_pkgs consul
}

consul_apply() {
    if consul_need_update ; then
	case "$1" in
	    client|server)
		consul_apply_sc "$1"
		;;
	    *)
		consul_apply_none
		;;
	esac
    fi
}

consul_start() {
    case "$1" in
	client|server)
	    if [ -f /var/run/.sc.consul.updated ]; then
		run_cmd service consul restart
		rm -Rf /var/run/.sc.consul.updated
	    fi
	    ;;
	*)
	    true   # we need to do nothing
	    ;;
    esac
}
