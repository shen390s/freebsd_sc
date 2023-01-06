nomad_config_files() {
    echo "nomad_client.hcl.t:client.hcl"

    if is_master; then
	echo "nomad_server.hcl.t:server.hcl"
    fi
}

nomad_render_config() {
    local _s _d _dc _join_list _my_ip _vote_cnt _dir

    _s="$1"
    _d="$2"
    
    _my_ip=$(get_my_ip)
    _dc="$datacenter"
    _join_list=$(mk_join_list "$servers" |sed -e 's/ //g')
    _vote_cnt=$(list_cnt "$servers")

    if [ -f $_s ]; then
	_dir=$(dirname $_d)
	if [ ! -d $_dir ]; then
	    run_command mkdir -p "$_dir"
	fi

	fill_kv_file "$_s" "$_d" \
		     MY_IP:_my_ip \
		     DATACENTER:_dc \
		     JOIN_LIST:_join_list \
		     VOTE_COUNT:_vote_cnt
    fi

}

nomad_pkgs() {
    echo nomad nomad-pot-driver
}

nomad_mkconfig() {
    local _s _d _it

    run_command rm -Rf /usr/local/etc/nomad/*

    for _it in $(nomad_config_files| xargs echo); do
	_s=$(echo $_it |awk -F: '{print $1}')
	_d=$(echo $_it |awk -F: '{print $2}')
	_s="$TOP/share/sc/templates/$_s"
	_d="/usr/local/etc/nomad/$_d"
	nomad_render_config "$_s" "$_d"
    done

    run_command chown -Rf nomad:nomad /usr/local/etc/nomad
}
nomad_config() {

    nomad_mkconfig
    run_command sysrc nomad_args="\"-config=/usr/local/etc/nomad\""
    run_command sysrc nomad_user="root"
    run_command sysrc nomad_env="\"PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/sbin:/bin\""
}

nomad_enable() {
    run_command sysrc nomad_enable="YES"
}

nomad_start() {
    run_command service nomad start
}

nomad_stop() {
    run_command service nomad stop
}
