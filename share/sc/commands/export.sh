sc_export() {
    local _role _tag

    _role="$1"
    shift

    _tag="$1"
    if [ -z "$_tag" ]; then
	_tag="1.0"
    fi

    export_image "$_role" "$_tag"
}

sc_export_help() {
    echo "export image_name tag"
}

add_commands "export" 
