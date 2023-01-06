sc_config() {
    local _role _tag

    _role="$1" 
    shift

    _tag="1.0"

    config_image "$_role" "$_tag"
}

sc_mkconfig() {
    cat >sc.conf <<EOF
$(cat $TOP/etc/sc.conf.default)
EOF
}

sc_config_help() {
    echo "config image_name tag, configure service"
}

sc_mkconfig_help() {
    echo "generate cluster configuration"
}

add_commands "config" "mkconfig"
