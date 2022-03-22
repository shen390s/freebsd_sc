. $TOP/share/sc/scripts/funcs.sh

render_line() {
    local _line _fmt _comments _data _args _cmd _z _v _val 

    _line="$1"
    _data=$(echo $_line |sed -e 's/#.*$//g')
    _comments=$(echo $_line |sed -e 's/^[^#]*#/#/g' -e 's/^[^#]*$//g')
    _fmt=$(echo $_data |sed -e 's/"/\\"/g' | sed -e 's/%%[a-zA-Z0-9_]*%%/%s/g')
    _args=$(echo $_data |grep -o "%%[a-zA-Z0-9_]*%%" |sed -e 's/%%//g' |xargs echo)
    
    _cmd="{ printf(\"$_fmt\" "
    for _v in $_args; do
	_val=$(getvar "$_v")
	_cmd="$_cmd , \"$_val\""
    done

    _cmd="$_cmd)}"
    _z=$(echo | awk "$_cmd")
    if [ -z "$_comments" ]; then
	:
    else
	_z=$(echo "$_z$_comments")
    fi
    echo $_z | sed -e 's/\^M/\n/g'
}

render_in() {
    local _data  _line _done

    _done=no
    while [ "X$_done" = "Xno" ]; do
	if read _line ; then
	    :
	else
	    _done=yes
	fi
	
	render_line "$_line"
    done
}

render_template() {
    cat "$1"| render_in
}

render_to() {
    local _to _tp

    _to="$1"
    _tp="$2"
    save_output "${_to}.new" render_template "$_tp"
    if [ -f "${_to}.new" ]; then
	run_cmd mv "${_to}.new" "${_to}"
    fi
}

shape_server_hosts() {
    local _h _sep _hosts

    _set=
    _hosts=
    for _h in `get_server_list`; do
	_hosts="$_hosts$_sep \\\"$_h\\\""
	_sep=","
    done
    echo "$_hosts"
}

mk_extra_entrypoints() {
    local _it _data _n _info

    _data=""
    for _it in $TRAEFIK_EXTRA_ENTRYPOINTS; do
	_n=$(echo $_it|awk -F: '{print $1}')
	_info=$(echo $_it|awk -F: '{print $2}')
	_data="$_data^M[entryPoints.${_n}]^M\taddress = \\\":${_info}\\\"^M"
    done

    echo $_data
}


mk_nomad_servers_with_port() {
    local _servers _s _sep
    
    if is_server; then
	_servers="\\\"127.0.0.1:4647\\\""
    else
	_servers=""
	_sep=""
	for _s in `get_server_list`; do
	    _servers="$_servers $_sep \\\"$_s:4647\\\""
	    _sep=','
	done
    fi
	
    echo "$_servers"
}

mk_servers() {
    shape_server_hosts
}

getvar() {
    local _var

    _var="$1"

    case "$_var" in
	_BIND_ADDR)
	    get_bind_ip $NETIF
	    ;;
	_DATACENTER)
	    echo "$DATACENTER"
	    ;;
	_DOMAIN)
	    echo "$DOMAIN"
	    ;;
	_EXTRA_ENTRY_POINTS)
	    mk_extra_entrypoints
	    ;;
	_NOMAD_SERVERS_WITH_PORT)
	    mk_nomad_servers_with_port
	    ;;
	_SERVERS)
	    mk_servers
	    ;;
	_VOTE_COUNT)
	    get_voted_server_count
	    ;;
	*)
	    echo [value of $_var]
	    ;;
    esac
}
