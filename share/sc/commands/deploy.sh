sc_deploy() {
    local _role _job

    _role="$1"
    shift 1

    _job="$TOP/share/sc/jobs/${_role}.job"
    if [ -f "$_job" ]; then
	nomad run "$_job"
    else
	cat <<EOF
nomad job "$_job" can not be found
EOF
    fi
}

sc_deploy_help() {
    echo deploy service
}

add_commands deploy
