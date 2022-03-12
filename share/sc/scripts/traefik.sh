. $TOP/share/sc/scripts/common.sh

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
    local _c1 _c2

    _c1=/usr/local/etc/sc/sc.conf
    _c2=/usr/local/etc/traefik.toml

    if [ ! -f $_c2 -o `file_newer $_c1 $_c2` ]; then
	_DATACENTER="$DATACENTER"
	_DOMAIN="$DOMAIN"
	render_to /usr/local/etc/traefik.toml \
		  $TOP/share/sc/templates/traefik.toml.template
	touch /var/run/.sc.traefik.updated
    fi
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
