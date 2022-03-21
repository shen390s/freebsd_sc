. $TOP/share/sc/scripts/common.sh

nomad_stop() {
    run_cmd service nomad stop
}

nomad_need_update() {
    local _c1 _c2 _c3

    _c1=/usr/local/etc/sc/sc.conf
    _c2=/usr/local/etc/nomad/client.hcl
    _c3=/usr/local/etc/nomad/server.hcl

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


mk_nomad_client_config() {
    render_to /usr/local/etc/nomad/client.hcl \
	      $TOP/share/sc/templates/nomad-client.hcl.template 

    run_cmd touch /var/run/.sc.nomad.updated
}

mk_nomad_srv_config() {
    if is_server; then
	render_to /usr/local/etc/nomad/server.hcl \
		  $TOP/share/sc/templates/nomad-server.hcl.template 
    else
	run_cmd rm -Rf /usr/local/etc/nomad/server.hcl
	save_output /usr/local/etc/nomad/server.hcl \
		    echo server { enabled = false } 
    fi
    run_cmd touch /var/run/.sc.nomad.updated
}

config_nomad_client() {
    mk_nomad_client_config
}


config_nomad_srv() {
    mk_nomad_srv_config
}

config_nomad() {
    if [ ! -d /usr/local/etc/nomad ]; then
	mkdir -p /usr/local/etc/nomad
    fi
    
    config_nomad_client
    config_nomad_srv
}

enable_nomad() {
    set_conf rc nomad_env \
	    "PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/sbin:/bin"
    set_conf rc nomad_user "root"
    set_conf rc nomad_enable "YES"
    set_conf rc nomad_args \
	    "-config=/usr/local/etc/nomad"
}

disable_nomad() {
    local _var

    for _var in nomad_env nomad_user nomad_args nomad_enable; do
	set_conf rc $_var
    done
}

nomad_cleanup() {
    run_cmd rm -Rf /var/tmp/nomad
    run_cmd rm -Rf /use/local/etc/nomad
}

nomad_install() {
    local _f

    _f=/usr/local/bin/nomad
    if [ ! -f $_f -o ! -x $_f ]; then
	install_pkgs nomad
    fi

    _f=/usr/local/libexec/nomad/plugins/nomad-pot-driver
    if [ ! -f $_f -o ! -x $_f ]; then
	install_pkgs nomad-pot-driver
    fi
}

nomad_uninstall() {
    uninstall_pkgs nomad-pot-driver nomad
}

nomad_apply_sc() {
    config_nomad
    enable_nomad
}

nomad_apply_none() {
    nomad_stop
    disable_nomad
    nomad_cleanup
}

nomad_apply() {
    if nomad_need_update ; then
	case "$1" in
	    server|client)
		nomad_apply_sc "$1"
		;;
	    *)
		nomad_apply_none
		;;
	esac
    fi
}

nomad_start() {
    case "$1" in
	client|server)
	    if [ -f /var/run/.sc.nomad.updated ]; then
		run_cmd service nomad restart
		rm -Rf /var/run/.sc.nomad.updated
	    fi
	    ;;
	*)
	    true
	    ;;
    esac
}
