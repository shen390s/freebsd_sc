get_config() {
    local _k _fn

    _k=$(echo "$1" |sed -e 's/\./_/g')
    shift

    _fn=$(printf "valueOf_%s" ${_k})

    if [ "x$(fn_defined ${_fn})" = "xyes" ]; then
	eval "${_fn}"
    else
	echo
    fi
}
