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

    pot_exec "$_name" sysrc sendmail_enable="NONE"

    run_helper "$_name" install "$_name"

    run_command pot stop -p "$_name"

    # FIXME:
    run_command echo >/opt/pot/jails/$_name/conf/fscomp.conf

    run_command pot snapshot -p "$_name"

    if [ ! -d $image_store_path ]; then
	run_command mkdir -p $image_store_path
    fi
    
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

    _i="$1" 
    _t="$2" 
    _boot="$3" 

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

    run_helper "$_i" config "$_i"

    echo deploy image  "$_i" done
}

