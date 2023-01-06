consul_config_files() {
    cat <<EOF
consul_client.hcl.t:client.hcl
consul_server.hcl.t:server.hcl
EOF
}

consul_render_config() {
    local _s _d _encrypt _dc _my_ip _join_list _dir

    _s="$1"
    _d="$2"
    shift 2

    _my_ip=$(get_my_ip)
    _dc="$datacenter"
    _encrypt="$encrypt"
    _join_list=$(mk_join_list "$servers" |sed  -e 's/ //g')
    _vote_cnt=$(list_cnt "$servers")

    if [ -f $_s ]; then
	_dir=$(dirname $_d)
	if [ ! -d $_dir ]; then
	    run_command mkdir -p $_dir
	fi

	fill_kv_file "$_s" "$_d" \
		     MY_IP:_my_ip \
		     DATACENTER:_dc \
		     ENCRYPT:_encrypt \
		     JOIN_LIST:_join_list \
		     VOTE_COUNT:_vote_cnt
    fi
}
consul_pkgs() {
    echo consul
}

consul_mkconfig() {
    local _s _d _it

    run_command rm -Rf /usr/local/etc/consul.d/*
    
    for _it in $(consul_config_files | xargs echo); do
	_s=$(echo $_it |awk -F: '{print $1}')
	_d=$(echo $_it |awk -F: '{print $2}')
	_s="$TOP/share/sc/templates/$_s"
	_d="/usr/local/etc/consul.d/$_d"

	consul_render_config "$_s" "$_d"
    done
    run_command  chown -Rf consul:consul /usr/local/etc/consul.d

    if [ ! -d /var/db/consul ]; then
	run_command mkdir -p /var/db/consul
	run_command chown -Rf consul:consul /var/db/consul
    fi
}

consul_config() {
    consul_mkconfig
    consul_enable
}

consul_enable() {
    run_command sysrc consul_enable="YES"
}

consul_start() {
    run_command service consul start
}

consul_stop() {
    run_command service consul stop
}
