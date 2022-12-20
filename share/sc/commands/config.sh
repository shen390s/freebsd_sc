do_configure() {
    true
}

sc_config() {
    local _role _xfile _tag

    _role="$1" && shift 1
    _tag="$1" && shift

    if [ -z "$_tag" ]; then
	_tag="1.0"
    fi
    
    _xfile="$TOP/share/sc/roles/$_role"

    if [ -f "$_xfile" ]; then
	. "$_xfile" 
	do_configure "$_role" "$_tag"
    else
	cat <<EOF
$_xfile can not be found.
EOF
	exit 1
    fi
	
}

sc_config_help() {
    echo "config image_name tag, configure service"
}

add_commands "config"
