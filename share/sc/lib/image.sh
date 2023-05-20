check_image() {
    local _name _tag _it _d

    _name="$1"
    _tag="$2"

    if [ -z "$_tag" ]; then
	_tag="1.0"
    fi

    _d=$image_store_path
    _it="${_name}_${_tag}.xz"
    if [ ! -f $_d/$_it -o ! -f $_d/${_it}.meta -o ! -f $_d/${_it}.skein ]; then
	false
	return
    fi

    xz -t $_d/$_it
}

build_image() {
    local _name _tag

    _name="$1" &&  shift
    _tag="$1" && shift
    
    load_role_config "$_name"
    if ! create_pot "$_name"; then
	echo "create pot $_name failed"
	exit 1
    fi

    run_command pot mount-in -p "$_name" \
		-m $sc_mountpoint \
		-d $TOP
    run_command pot mount-in -p "$_name" \
		-d $conf_mountpoint \
		-m $conf_mountpoint
    run_command pot mount-in -p "$_name" \
		-d $data_mountpoint \
		-m $data_mountpoint
    
    if ! start_pot "$_name"; then
	echo "start pot $_name failed"
	exit 1
    fi

    pot_exec "$_name" sysrc sendmail_enable="NONE"

    run_helper "$_name" install "$_name"

    run_command pot stop -p "$_name"
}

export_image() {
    local _name _tag

    _name="$1"
    _tag="$2"

    load_role_config "$_name"

    if pot_existed "$_name"; then
	run_command pot stop -p "$_name"
    else
	build_image "$_name" "$_tag"
    fi
    
    run_command rm /opt/pot/jails/$_name/conf/fscomp.conf
    run_command touch /opt/pot/jails/$_name/conf/fscomp.conf

    run_command pot snapshot -r -p "$_name"

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

config_image()
{
    local _i _t _op

    _i="$1" 
    _t="$2" 

    if [ -z "$_t" ]; then
	_t="1.0"
    fi
    
    _op=$(echo "${_i}_${_t}" |sed -e 's/\./_/g')
    
    load_role_config "$_i"

    run_command rm -Rf /var/cache/pot/${_i}_${_t}.xz*

    if pot_existed "$_i"; then
	run_command pot stop -p "$_i"
	run_command pot destroy -p "$_i"
    fi
    
    if pot_existed "$_op"; then
	run_command pot destroy -p "$_op"
    fi
    
    if check_image "$_i" "$_t"; then
	:
    else
	build_image "$_i" "$_t"
	export_image "$_i" "$_t"
    fi
    
    run_command pot import -p "$_i" -t "$_t" \
		-U $image_store_path

    run_command pot clone -p "$_i" -P "$_op"

    run_command pot mount-in -p "$_i" -d $TOP -m $sc_mountpoint
    run_command pot mount-in -p "$_i" -d $conf_mountpoint -m $conf_mountpoint
    run_command pot mount-in -p "$_i" -d $data_mountpoint -m $data_mountpoint
    run_command pot start -p "$_i"

    run_helper "$_i" config "$_i"    

    # stop the pot
    run_command pot stop -p "$_i"
}

deploy_image() {
    local _i _t _boot _op

    _i="$1" 
    _t="$2" 

    if config_image "$_i" "$_t"; then
	echo deploy image  "$_i" done
	run_command pot set-attr -p "$_i" -A start-at-boot -V yes
	run_command pot set-cmd -p "$_i" -c "'$sc_mountpoint/share/sc/tools/helper -f /var/tmp/sc.conf start $_i'"
	run_command pot stop "$_i"
	run_command pot start "$_i"
    else
	echo config image "$_i" failed
    fi
}

