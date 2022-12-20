get_config() {
    local _prefix _it _n

    _prefix="$1"
    _it="$2"
    shift 2
    
    if [ -z "${_prefix}" ]; then
	_n="${_it}"
    else
	_n="${_prefix}_${_it}"
    fi
    
    eval "echo \$${_n}"
}
