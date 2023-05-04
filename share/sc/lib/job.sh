job_mk_rule() {
    local _role _ty

    _role="$1"
    _ty="$2"
    
    if [ "x${_ty}" = "xtcp" ]; then
	printf 'HostSNI(`*`)\n'
    else
	printf 'HOST(`%s.%s.%s`)\n' ${_role} $datacenter $domain
    fi
}

gen_port_assign_public_bridge() {
    local _s _sn

    _s="$1"
    _sn=$(echo $_s |awk -F: '{print $1}')

    printf "\t  port \"%s\" {}\n" ${_sn}
}

gen_port_assign_host() {
    local _s _sn _pt

    _s="$1"
    _sn=$(echo $_s|awk -F: '{print $1}')
    _pt=$(echo "$_s" |awk -F: '{print $3}')
    cat <<EOF
port "${_sn}" {
    static = ${_pt}
}
EOF
}


job_mk_services() {
    local _it _s _role _sn _ty _pt _ic _io _rl _tc _se

    _role="$1"

    _s="$TOP/share/sc/templates/service.t"
    for _it in $(get_config "${_role}.services"); do
	_sn=$(echo $_it |awk -F: '{print $1}')
	_ty=$(echo $_it |awk -F: '{print $2}')
	_pt=$(echo $_it |awk -F: '{print $3}')
	_ic=$(echo $_it |awk -F: '{print $4}')
	_io=$(echo $_it |awk -F: '{print $5}')

	if [ -z "${_ty}" ]; then
	    _ty="tcp"
	fi

	if [ -z "${_ic}" ]; then
	    _ic="10s"
	fi

	if [ -z "${_io}" ]; then
	    _io="20s"
	fi

	_rl=$(job_mk_rule "$_role" "$_ty")
	_se=$(get_svc_entrypoint "$_ty" "$_sn" "$_role")

	# always use tcp service check
	_tc="tcp"

	fill_kv_file "$_s" "-" \
		     SERVICE_NAME:_sn \
		     SERVICE_TYPE:_ty \
		     SERVICE_PORT:_pt \
		     SERVICE_CHECK_TYPE:_tc \
		     SERVICE_CHECK_INTERVAL:_ic \
		     SERVICE_CHECK_TIMEOUT:_io \
		     SERVICE_RULE:_rl \
		     SERVICE_ENTRYPOINT:_se
    done
}

job_port_assign() {
    local _r _nm _it

    _r="$1"
    _nm=$(get_config "${_r}.network")
    for _it in $(get_config "${_r}.services"); do
	if [ "x${_nm}" = "xinherit" ]; then
	    gen_port_assign_host "${_it}"
	else
	    gen_port_assign_public_bridge "${_it}"
	fi
    done
}

job_mk_mounts() {
    local _it _m _sep

    _m=""
    _sep=""

    for _it in $conf_mountpoint $data_mountpoint; do
	_m="$_m $_sep \"${_it}:${_it}\""
	_sep=","
    done

    _m="$_m,\"$TOP:$sc_mountpoint\""
    echo "$_m" |sed -e 's/ //g'
}

job_cpu_hz() {
    echo 200
}

job_memory_mb() {
    echo 1024
}

job_mk_port_maps() {
    local _r _nm _it _sn _pt

    _r="$1"
    _nm=$(get_config "${_r}.network")

    if [ "x${_nm}" = "xinherit" ]; then
	return
    fi

    printf "\t\tport_map = {\n"
    for _it in $(get_config "${_r}.services"); do
	_sn=$(echo $_it|awk -F: '{print $1}')
	_pt=$(echo $_it|awk -F: '{print $3}')
	printf "\t\t\t%s = \"%s\"\n" ${_sn} $_pt
    done
    printf "\t\t}\n"
}

job_render() {
    local _role _dst _s _dir _job _dc _jg _jr _jt _js _il _pn _pt _psc _psa _ppm _pnm _pmnt _pchz _pmr _pa

    _role="$1"
    _dst="$2"

    _s="$TOP/share/sc/templates/role.job.t"

    load_role_config "$_role"

    if [ "x${_dst}" = "x-" ]; then
	:
    else
	_dir=$(dirname $_dst)
	if [ ! -d $_dir ]; then
	    run_command mkdir -p "$_dir"
	fi
    fi

    _job="$_role"
    _dc="$datacenter"
    _jg="$_job"
    _jr=1
    _jt="$_job"
    _js=$(job_mk_services "$_role" |sed -e 's/^/\t    /g') 
    _il="file://$image_store_path"
    _pn="$_job"
    _pt="1.0"
    _psc="$sc_mountpoint/share/sc/tools/helper"
    _psa="\"-f\",\"/var/tmp/sc.conf\",\"start\",\"${_role}\""
    _ppm=$(job_mk_port_maps "$_role")
    _pnm=$(get_config "${_role}.network")
    case "${_pnm}" in
	inherit)
	    _pnm="host"
	    ;;
	*)
	    _pnm="public-bridge"
	    ;;
    esac

    _pmnt=$(job_mk_mounts "$_role")
    _pchz=$(job_cpu_hz "$_role")
    _pmr=$(job_memory_mb "$_role")
    _pa=$(job_port_assign "$_role")

    fill_kv_file "$_s" "$_dst" \
		 JOB:_job \
		 DATACENTER:_dc \
		 JOBGROUP:_jg \
		 JOB_REPLICAS:_jr \
		 JOB_TASK:_jt \
		 JOB_SERVICES:_js \
		 IMAGE_LOCATION:_il \
		 POT_NAME:_pn \
		 POT_TAG:_pt \
		 POT_START_CMD:_psc \
		 POT_START_ARGS:_psa \
		 POT_PORT_MAPS:_ppm \
		 POT_NETWORK_MODE:_pnm \
		 POT_MOUNTS:_pmnt \
		 POT_CPU_HZ:_pchz \
		 POT_MEMORY_REQ:_pmr \
		 PORTS_ASSIGN:_pa
}
