create_pot() {
    local _name _base _net

    _name="$1" && shift
    
    if pot info -p "$_name" 2>&1 >/dev/null; then
	run_command pot destroy -F -r "$_name"
    fi
    
    _net=$(get_config "$_name" "network")
    if [ -z "$_net" ]; then
	_net="public-bridge"
    fi

    _base=$(get_config "$_name" "base")
    if [ -z "$_base" ]; then
	_base=$(uname -r |awk -F- '{print $1}')
    fi

    run_command pot create -p "$_name" \
		-N "$_net" -t single \
		-b "$_base"
}

start_pot() {
    local _pot

    _pot="$1" && shift
    run_command pot start "$_pot"
}

pot_exec() {
    local _p _c _nc _z
    
    _p="$1" && shift
    _c="$1" && shift

    if is_dry_run; then
	run_command echo run commands in pot "$_p": "$@" 
	_nc=$(echo "$_c" |sed -e s@$sc_mountpoint@$TOP@g)
	if [ "x$debug" = "xyes" ]; then
	    _z="-x"
	else
	    _z=""
	fi
	
	eval "dry_run=yes /bin/sh $_z $_nc $@"
    else
	run_command pot exec -p "$_p" \
		    "$_c" "$@"
    fi
}

build_image() {
    local _name _tag

    _name="$1" &&  shift
    _tag="$1" && shift
    
    if ! create_pot "$_name"; then
	echo "create pot $_name failed"
	exit 1
    fi

    run_command pot mount-in -p "$_name" \
		-m $sc_mountpoint \
		-d $TOP
    
    if ! start_pot "$_name"; then
	echo "start pot $_name failed"
	exit 1
    fi

    pot_exec "$_name" \
	     $sc_mountpoint/share/sc/tools/helper install "$_name"

    run_command pot stop -p "$_name"

    run_command pot snapshot -p "$_name"

    if [ ! -z "$_tag" ]; then
	run_command pot export -p "$_name" \
		    -t "$_tag" -D $image_store_path
    else
	run_command pot export -p "$_name" \
		    -D $image_store_path
    fi

    run_command pot destroy -p "$_name"
}

deploy_image() {
    local _i _t _boot _op

    _i="$1" && shift
    _t="$1" && shift
    _boot="$1" && shift

    if [ -z "$_t" ]; then
	_t="1.0"
    fi

    if [ -z "$_boot" ]; then
	_boot="no"
    fi
    
    run_command pot import -p "$_i" -t "$_t" \
		-U $image_store_path
    op=$(echo "${_i}_${_t}" |sed -e 's/\./_/g')
    run_command pot clone -p "$_i" -P "$op"

    if [ "x${_boot}" = "xyes" ]; then
	run_command pot set-attr "$_i" -A start-at-boot -V yes
    fi

    run_command pot mount-in -p "$_i" -d $TOP -m $sc_mountpoint
    run_command pot mount-in -p "$_i" -d $conf_mountpoint -m $conf_mountpoint
    run_command pot mount-in -p "$_i" -d $data_mountpoint -m $data_mountpoint
    run_command pot start -p "$_i"
    pot_exec "$_i" $sc_mountpoint/share/sc/tools/helper \
	     config "$_i"

    echo deploy image  "$_i" done
}

