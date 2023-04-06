sc_build() {
    local _role _tag

    _role="$1"
    shift 1
	
    _tag="$1"
    if [ -z "$_tag" ]; then
	_tag="1.0"
    fi

    if build_image "$_role" "$_tag"; then
	:
    else
	echo "build image $_role $_tag failed"
    fi

    if export_image "$_role" "$_tag"; then
	echo "build image $_role $_tag done!"
    else
	echo "export image $_role $_tag failed!"
    fi
}

sc_build_help() {
    echo "build image of service"
}

add_commands "build"
