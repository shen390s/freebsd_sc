gen_seahub_start_script() {
    cat <<EOF
sysrc seahub_port="$(get_config seahub.port)"
sysrc seahub_enable="YES"
EOF
}
seahub_config() {
    local _s

    _s=$(get_role_conf_dir seafile)/start_seahub.sh

    save_command_output $_s gen_seahub_start_script
}

seahub_enable() {
    true
}

seahub_start() {
    local _s

    _s=$(get_role_conf_dir seafile)/start_seahub.sh
    run_command sh $_s
}
