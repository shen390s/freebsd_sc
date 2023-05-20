svc_call() {
    local _s _fn

    _s="$1"
    _fn="$2"
    shift 2

    eval "${_s}_${_fn} \"$@\""
}

svc_generic() {
    local _s _action

    _s="$1"
    _action="$2"
    shift 2

    if [ "x$(fn_defined ${_s}_${_action})" = "xyes" ]; then
	svc_call "$_s" "$_action" "$@"
    else
	if [ "x${_action}" = "xpkgs" ]; then
	    echo "${_s}"
	else
	    echo
	fi
    fi
}

svc_pkgs() {
    local _s

    _s="$1"
    shift
    
    svc_generic "$_s" "pkgs" "$@"
}

svc_requires() {
    local _s

    _s="$1"
    shift
    
    svc_generic "$_s" "requires" "$@"
}

svc_install() {
    local _s _pkgs

    _s="$1"
    shift
    
    if [ "x$(fn_defined ${_s}_install)" = "xyes" ]; then
	svc_call "$_s" "install" "$@"
    else
	_pkgs=$(svc_pkgs "$_s" "$@")
	if [ ! -z "$_pkgs" ]; then
	    pkg_install $_pkgs
	fi
    fi
}

svc_config() {
    local _s

    _s="$1"
    shift
    
    svc_generic "$_s" "config" "$@"
}

svc_enable() {
    local _s
    _s="$1"
    shift

    if [ "x$(fn_defined ${_s}_enable)" = "xyes" ]; then
	svc_call "$_s" "enable" "$@"
    else
	run_command sysrc ${_s}_enable="YES"
    fi
}

svc_start() {
    local _s

    _s="$1"
    shift

    if [ "x$(fn_defined ${_s}_start)" = "xyes" ]; then
	svc_call "$_s" "start" "$@"
    else
	run_command service "$_s" start "$@"
    fi
}

svc_stop() {
    local _s
    _s="$1"
    shift

    if [ "x$(fn_defined ${_s}_stop)" = "xyes" ]; then
	svc_call "$_s" "stop"
    else
	run_command service "$_s" stop
    fi
}

svc_restart() {
    local _s

    _s="$1"
    shift

    svc_stop "$_s" "$@" && \
	svc_start "$_s" "$@"
}
