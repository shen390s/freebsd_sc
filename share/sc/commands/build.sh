sc_build() {
    local _role _xfile

    _role="$1"
    shift 1
    _xfile="$TOP/share/sc/roles/$_role"

    if [ -f "$_xfile" ]; then
	. "$_xfile" 
	build_image "$_role"
    else
	cat <<EOF
$_xfile can not be found.
EOF
	exit 1
    fi
	
}

sc_build_help() {
    echo "build image of service"
}

add_commands "build"
