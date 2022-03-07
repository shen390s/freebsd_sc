. $TOP/lib/common.sh

traefik_stop() {
    case "$1" in
	server)
	    run_cmd service traefik stop
	    ;;
	*)
	    true
	    ;;
    esac
}

mk_traefik_config() {
    
    _DATACENTER="$DATACENTER"
    _DOMAIN="$DOMAIN"
    render_to /usr/local/etc/traefik.toml \
	      $TOP/conf/templates/traefik.toml.template
}

config_traefik() {
    case "$1" in
	server)
	    mk_traefik_config
	    ;;
	*)
	    run_cmd rm -Rf /usr/local/etc/traefik.toml
	    ;;
    esac
}

enable_traefik() {
    case "$1" in
	server)
	    set_conf rc traefik_enable YES
	    ;;
	*)
	    set_conf rc traefik_enable
	    ;;
    esac
}

traefik_apply_server() {
    install_pkgs traefik
    config_traefik "server"
    enable_traefik "server"
}

traefik_apply_none() {
    traefik_stop
    enable_traefik "none"
    config_traefik "none"
    uninstall_pkgs traefik
}

traefik_apply() {
    case "$1" in
	server)
	    traefik_apply_server
	    ;;
	*)
	    traefik_apply_none
	    ;;
    esac
}
