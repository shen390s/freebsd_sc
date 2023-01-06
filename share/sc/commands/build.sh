sc_build() {
    local _role _tag

    _role="$1"
    shift 1
	
    _tag="1.0"

    build_image "$_role" "$_tag"
}

sc_build_help() {
    echo "build image of service"
}

add_commands "build"
