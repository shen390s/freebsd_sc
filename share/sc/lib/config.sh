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

get_role_conf_dir() {
    local _role _d

    _role="$1"

    _d=$conf_mountpoint/$_role
    if [ ! -d $_d ]; then
	mkdir -p $_d
    fi

    echo $_d
}

get_role_data_dir() {
    local _role _d

    _role="$1"
    _d=$data_mountpoint/$_role
    if [ ! -d $_d ]; then
	mkdir -p $_d
    fi

    echo $_d
}
