traefik_pkgs() {
    echo traefik
}

mk_entrypoints() {
    local _it _n _v _data

    for _it in $entry_points; do
	_n=$(echo $_it |awk -F: '{print $1}')
	_v=$(echo $_it |awk -F: '{print $2}')

	printf "  [entryPoints.%s]\n" ${_n}
	printf "     address = \":%s\"\n" ${_v}
    done

}
traefik_render_config() {
    local _s _d _entrypoints _dc _domain _my_ip

    _s="$1"
    _d="$2"
    shift 2
    _my_ip=$(get_my_ip)
    _dc="$datacenter"
    _domain="$domain"
    _entrypoints="$(mk_entrypoints)"

    if [ -f $_s ]; then
	_dir=$(dirname $_d)
	if [ ! -d $_dir ]; then
	    run_command mkdir -p $_dir
	fi

	fill_kv_file "$_s" "$_d" \
		     MY_IP:_my_ip \
		     DATACENTER:_dc \
		     DOMAIN:_domain \
		     ENTRY_POINTS:_entrypoints
    fi
}
traefik_mkconfig() {
    local _s _d

    _s="$TOP/share/sc/templates/traefik.toml.t"
    _d="/usr/local/etc/traefik.toml"

    traefik_render_config "$_s" "$_d"
}
traefik_config() {
    traefik_mkconfig
    traefik_enable
}

traefik_enable() {
    run_command sysrc traefik_enable="YES"
}

traefik_start() {
    run_command service traefik start
}

traefik_stop() {
    run_command service traefik stop
}
