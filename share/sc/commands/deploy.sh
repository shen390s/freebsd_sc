sc_deploy() {
    local _role _job

    _role="$1"
    shift 1

    if load_role_config "$_role" ; then
	_job=$(mktemp /tmp/${_role}.XXXXX)
	job_render "$_role" "$_job"
	cat "$_job"
	run_command nomad run "$_job"
	rm -Rf "$_job"
    else
	echo "role ${_role} can not be found"
	exit 1
    fi
}

sc_deployimage() {
    local _role _tag

    _role="$1"
    _tag="$2"

    if [ -z "$_tag" ]; then
	_tag="1.0"
    fi

    deploy_image "$_role" "$_tag"
}

sc_deploy_help() {
    echo deploy service
}

sc_deployimage_help() {
    echo deployimage name tag
}
add_commands deploy deployimage
