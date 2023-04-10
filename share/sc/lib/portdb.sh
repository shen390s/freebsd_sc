# routes for port management

portdb_path=$conf_mountpoint/traefik/portdb

portdb_http_init() {
    cat >$portdb_path/httpdb <<EOF
traefik,9002,traefik
websecure,9443,
http,8080,
EOF
}

portdb_tcp_init() {
    touch $portdb_path/tcpdb
}

portdb_init() {
    local _next_tcp_port _next_http_port
    
    if [ ! -d ${portdb_path} ]; then
	mkdir -p $portdb_path
    fi

    if [ ! -f ${portdb_path}/meta ]; then
	_next_tcp_port=${sc_tcp_start_port}
	_next_http_port=${sc_http_start_port}

	if [ -z "$_next_tcp_port" ]; then
	    _next_tcp_port=2022
	fi

	if [ -z "$_next_http_port" ]; then
	    _next_http_port=8088
	fi
	
	cat >${portdb_path}/meta <<EOF
NEXT_TCP_PORT=$_next_tcp_port
NEXT_HTTP_PORT=$_next_http_port
EOF
	portdb_http_init
	portdb_tcp_init
    fi
}

get_next_port() {
    local _t

    _t="$1"

    case "$_t" in
	tcp)
	    cat ${portdb_path}/meta | \
		grep "NEXT_TCP_PORT=" | \
		awk -F= '{print $2}'
	    ;;
	http)
	    cat ${portdb_path}/meta | \
		grep "NEXT_HTTP_PORT=" | \
		awk -F= '{print $2}'
	    ;;
	*)
	    echo 0
	    ;;
    esac
}

update_next_port() {
    local _t _v _db

    _t="$1"
    _v="$2"

    cp ${portdb_path}/meta ${portdb_path}/meta.tmp
    if [ "x$_t" = "xtcp" ]; then
	(cat ${portdb_path}/meta.tmp | grep -v "NEXT_TCP_PORT="
	 echo "NEXT_TCP_PORT=$_v"
	) > ${portdb_path}/meta
    else
	(cat ${portdb_path}/meta.tmp |grep -v "NEXT_HTTP_PORT="
	 echo "NEXT_HTTP_PORT=$_v"
	) >${portdb_path}/meta
    fi

    rm ${portdb_path}/meta.tmp
}

get_match_entry() {
    local _e _n _h _hosts _it

    _n="$1"
    _h="$2"
    while read _e; do
	_hosts=$(echo $_e |awk -F, '{print $3}')
	if [ -z "$_hosts" ]; then
	    continue
	fi

	for _it in $_hosts; do
	    if [ "x$_n:$_h" = "x${_it}" ]; then
		echo $_e
		return
	    fi
	done
    done

    echo
}

get_match_db_entry() {
    local _db _n _h

    _db="$1"
    _n="$2"
    _h="$3"

    if [ ! -f $_db ]; then
	echo
	return
    fi
    
    cat $_db |get_match_entry "$_n" "$_h"
}

alloc_exist_http_entry() {
    local _e _n _h _hosts _it _h1 _match

    _n="$1"
    _host="$2"

    while read _e; do
	if [ "xtraefik" = "x$(echo $_e|awk -F, '{print $1}')" ]; then
	    # skip traefik dashboard entry
	    continue
	fi
	
	_hosts=$(echo $_e |awk -F, '{print $3}')

	_match=no
	for _it in $_hosts; do
	    _h1=$(echo $_it |awk -F: '{print $2}')
	    if [ "x$_h1" = "x$_host" ]; then
		_match=yes
		break
	    fi
	done

	if [ "x$_match" = "xno" ]; then
	    # we can use this entry, because there is
	    # no service use this entry in same host
	    echo $_e
	    return
	fi
    done

    # no entry found
    echo
}

get_http_alloc() {
    local _n _host _db _e _v

    _n="$1"
    _host="$2"
    _db=${portdb_path}/httpdb

    _e=$(get_match_db_entry "$_db" "$_n" "$_h")
    if [ -z "$_e" ]; then
	_e=$(cat ${_db} | alloc_exist_http_entry "$_n" "$_host")
	if [ -z "$_e" ]; then
	    # we need to alloc a new entry
	    _v=$(get_next_port http)
	    _e="${_n}${_v},${_v},${_n}:${_h}"
	    # update db
	    echo "$_e" >> ${portdb_path}/httpdb
	    update_next_port http $(expr ${_v} + 1)
	else
	    # use existed entry
	    cp ${_db} ${_db}.tmp
	    (cat ${_db}.tmp |grep -v "$_e"
	     echo "$_e ${_n}:${_h}"
	    ) >${_db}
	    rm ${_db}.tmp

	    _e="$_e ${_n}:${_h}"
	fi
    fi
    
    echo "$_e"
}

get_tcp_alloc() {
    local _n _host _db _e _v

    _n="$1"
    _h="$2"
    _db=${portdb_path}/tcpdb

    _e=$(get_match_db_entry "$_db" "$_n" "$_h")
    if [ -z "$_e" ]; then
	# no entry found
	_v=$(get_next_port tcp)
	_e="${_n}${_v},${_v},${_n}:${_h}"
	echo "$_e" >> ${portdb_path}/tcpdb
	update_next_port tcp $(expr ${_v} + 1)
    fi

    echo "$_e"
}

get_port_alloc() {
    local _n _h _e _t

    _t="$1"
    _n="$2"
    _h="$3"

    if [ "x$_t" = "xtcp" ]; then
	_e=$(get_tcp_alloc "$_n" "$_h")
    else
	_e=$(get_http_alloc "$_n" "$_h")
    fi
    
    echo $_e 
}

get_all_entrypoints() {
    local _it _dbs _db

    _dbs=""
    for _it in httpdb tcpdb; do
	_db=${portdb_path}/$_it
	
	if [ -f "$_db" ]; then
	    _dbs="$_dbs $_db"
	fi
    done
    (for _it in $_dbs; do
	 cat $_it
     done) | \
	sed -e '/^$/d' | \
	awk -F, '{printf("%s:%s\n",$1,$2)}' | \
	xargs echo
}

get_port() {
    local _e

    _e=$(get_port_alloc "$@")

    echo $_e |awk -F, '{print $2}'
}

get_svc_entrypoint() {
    get_port_alloc "$@" |awk -F, '{print $1}'
}
