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

mk_sshd_config() {
    local _of

    _of="$1"

    cat $_of |sed -e 's/^Port[ \t\b]*=.*$//g'
    echo "Port = 3022"
}

gitea_update_sshd_config() {
    local _d

    _d=/etc/ssh/sshd_config
    run_command cp $_d $_d.orig
    
    save_command_output /etc/ssh/sshd_config mk_sshd_config $_d.orig
}

gitea_mk_app_ini() {
    local _my_ip _dc _dm _s _d _dir _data

    _d="$1"
    _my_ip=$(get_my_ip)
    _dc="$datacenter"
    _dm="$domain"
    _data="$data_mountpoint"

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
		     DATA_DIR:_data
    fi		     
}

gitea_config() {
    gitea_mkdirs
    gitea_mk_app_ini ${conf_mountpoint}/gitea/app.ini  
    gitea_update_sshd_config
}

gitea_enable() {
    run_command sysrc gitea_enable="YES"
}
