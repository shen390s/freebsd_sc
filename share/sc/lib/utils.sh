do_render() {
    local _src _c _k _v _it _render

    _src="$1"
    shift

    _c=""
    for _it in $*; do
        _k=$(echo "$_it" |awk -F: '{print $1}')
        _v=$(echo "$_it" |awk -F: '{print $2}')
        _c="$_c $_k=\"\$$_v\""
    done

    _render="$TOP/share/sc/tools/tfrender"
    if [ ! -x $_render ]; then
        (cd $TOP/share/sc/src && \
             make && \
             cp tfrender $_render)
    fi
    eval "$_c $TOP/share/sc/tools/tfrender $_src"
}

fill_kv_file() {
   local _fsrc _fdst _dir 

   _fsrc="$1"
   _fdst="$2"
   shift 2

   if [ "x${_fdst}" = "x-" ]; then
       :
   else
       _dir=$(dirname $_fdst)
       if [ -z "$_dir" ]; then
	   :
       else
	   if [ ! -d $_dir ]; then
               run_command mkdir -p $_dir
	   fi
       fi
       run_command rm -Rf $_fdst
   fi
   
   save_command_output "$_fdst" \
		       do_render "$_fsrc" "$@"
}

mk_join_list() {
    local _s _it _sep _lst

    _s="$1"
    _sep=""
    _lst=""
    
    for _it in $_s; do
	_lst="$_lst $_sep \"$_it\""
	_sep=","
    done

    echo $_lst
}

list_cnt() {
    local _s

    _s="$1"

    set -- $_s

    echo $#
}

in_list() {
    local _it _lst _x

    _it="$1"
    _lst="$2"

    for _x in $_lst; do
	if [ "x${_it}" = "x${_x}" ]; then
	    true
	    return
	fi
    done

    false
}

is_master() {
    local _my_ip

    _my_ip=$(get_my_ip)

    in_list "${_my_ip}" "$servers"
}

join_lines() {
    local _sep _line _m

    _sep="$1"
    _m=""

    while read _line; do
	_m="${_m}${_sep}${_line}"
    done

    echo "${_m}"
}

