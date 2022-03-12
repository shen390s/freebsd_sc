. $TOP/share/sc/scripts/common.sh

nomad_stop() {
    run_cmd service nomad stop
}

mk_nomad_client_config() {
    local _servers _s _sep
    if is_server; then
	_servers="\"127.0.0.1:4647\""
    else
	_servers=""
	_sep=""
	for _s in `get_server_list`; do
	    _servers="$_servers $_sep \"$_s:4647\""
	    _sep=','
	done
    fi

    _DATACENTER="$DATACENTER"
    _SERVERS="$_servers"
    render_to /usr/local/etc/nomad/client.hcl \
	      $TOP/share/sc/templates/nomad-client.hcl.template 
}

mk_nomad_srv_config() {
    local _bind_ip _vars

    _bind_ip=`get_bind_ip $NETIF`

    if is_server; then
	_BIND_ADDR="$_bind_ip"
	_VOTE_COUNT=`get_voted_server_count`
	render_to /usr/local/etc/nomad/server.hcl \
		  $TOP/share/sc/templates/nomad-server.hcl.template 
    else
	save_output /usr/local/etc/nomad/server.hcl \
		    echo server { enabled = false } 
		    #printf 'server {\n\tenabled = false\n}\n'
    fi
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

nomad_apply_sc() {
    install_pkgs nomad nomad-pot-driver
    config_nomad
    enable_nomad
}

nomad_apply_none() {
    nomad_stop
    disable_nomad
    uninstall_pkgs nomad-pot-driver nomad
    nomad_cleanup
}

nomad_apply() {
    case "$1" in
	server|client)
	    nomad_apply_sc "$1"
	    ;;
	*)
	    nomad_apply_none
	    ;;
    esac
}
