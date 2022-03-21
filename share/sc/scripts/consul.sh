. $TOP/share/sc/scripts/common.sh

consul_stop() {
    run_cmd service consul stop
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
    render_to /usr/local/etc/consul.d/consul.hcl \
	      $TOP/share/sc/templates/consul.hcl.template 
    run_cmd touch /var/run/.sc.consul.updated
}

config_consul_srv() {
    render_to /usr/local/etc/consul.d/server.hcl \
	      $TOP/share/sc/templates/consul-server.hcl.template 
    run_cmd touch /var/run/.sc.consul.updated
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
    local _f

    _f=/usr/local/bin/consul
    if [ ! -f $_f -o ! -x $_f ]; then
	install_pkgs consul
    fi
    
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
