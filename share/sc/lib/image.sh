create_pot() {
    local _name _base _net

    _name="$1" && shift
    
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

    run_command pot exec -p "$_name" \
		$sc_mountpoint/share/sc/tools/install

    run_command pot stop -p "$_name"

    run_command pot snapshot -p "$_name"

    if [ ! -z "$_tag" ]; then
	run_command pot export -p "$_name" \
		    -t "$_tag" -D $image_store_path
    else
	run_command pot export -p "$_name" \
		    -D $image_store_path
    fi
}

