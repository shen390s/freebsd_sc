gitea_pkgs() {
    echo gitea bash
}

gitea_mkdirs() {
    local _d _it

    _d=$data_mountpoint/gitea

    if [ ! -d $_d ]; then
	run_command mkdir -p $_d
    fi

    for _it in data conf data/tmp/uploads gitea-repositories data/avatars indexers data/home; do
	run_command mkdir -p $_d/$_it
	run_command chown -Rf git:git $_d/$_it
    done
}

gitea_mk_git_home() {
    local _d

    _d=$data_mountpoint/gitea/users/git

    if [ ! -d $_d ]; then
	run_command mkdir -p $_d
	run_command chown -Rf git:git $_d
    fi

    run_command pw usermod -n git -d $_d
}

gitea_mk_app_ini() {
    local _my_ip _dc _dm _s _d _dir _data _pt1 _pt2

    _d="$1"
    _my_ip=$(get_my_ip)
    _dc="$datacenter"
    _dm="$domain"
    _data="$data_mountpoint"
    _pt1=$(get_config "gitea.port")
    _pt2=$(get_config "gitea.ssh.port")

    _s="$TOP/share/sc/templates/gitea_app.ini.t"

    if [ -f "$_s" ]; then

	if [ "x${_d}" = "x-" ]; then
	    :
	else
	    _dir=$(dirname $_d)
	    if [ ! -d $_dir ]; then
		run_command mkdir -p "$_dir"
	    fi
	fi

	fill_kv_file "$_s" "$_d" \
		     MY_IP:_my_ip \
		     DATACENTER:_dc \
		     DOMAIN:_dm \
		     DATA_DIR:_data \
		     HTTP_PORT:_pt1 \
		     SSH_PORT:_pt2
    fi		     
}

gitea_config() {
    gitea_mkdirs
    gitea_mk_app_ini ${conf_mountpoint}/gitea/app.ini  
}

gitea_enable() {
    run_command sysrc gitea_enable="YES"
}
