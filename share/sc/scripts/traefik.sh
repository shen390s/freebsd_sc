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

traefik_need_update() {
    local _c1 _c2

    _c1=/usr/local/etc/sc/sc.conf
    _c2=/usr/local/etc/traefik.toml

    if [ ! -f $_c2 -o "X`file_newer $_c1 $_c2`" = "Xyes" ]; then
	:
    else
	false
    fi
}
mk_traefik_config() {
    render_to /usr/local/etc/traefik.toml \
	      $TOP/share/sc/templates/traefik.toml.template
    run_cmd touch /var/run/.sc.traefik.updated
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
    local _f

    _f=/usr/local/bin/traefik
    if [ ! -f $_f -o ! -x $_f ]; then
	install_pkgs traefik
    fi
    
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
    if traefik_need_update ; then
	case "$1" in
	    server)
		traefik_apply_server
		;;
	    *)
		traefik_apply_none
		;;
	esac
    fi
}
