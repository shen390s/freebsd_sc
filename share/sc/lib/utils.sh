gen_kv_awk() {
    local _it _k _var _v _z _s _df

    _df=$(mktemp)
    cat <<EOF
BEGIN {
  RS=""
}
{
$(for _it in $*; do
      _k=$(echo $_it |awk -F: '{print $1}')
      _var=$(echo $_it |awk -F: '{print $2}')
      echo "BEGIN_${_k}" >>${_df}
      value_of_var "${_var}" | uuencode -m - >>${_df}
      echo "END_${_k}" >>${_df}
      echo "s=\"cat ${_df} | sed -n -e '/BEGIN_${_k}/,/END_${_k}/p' |grep -v '${_k}' | uudecode -m -o /dev/stdout\";"
      echo "s | getline ENVIRON[\"${_k}\"];"
done)

split(\$0,a,"%%");

for (idx=1; idx <= length(a); idx ++) {
    if (idx % 2 != 0) {
       printf("%s", a[idx]);
    }
    else {
       printf("%s", ENVIRON[a[idx]]);
    }
}
printf("\n");
$(echo "s=\"rm -Rf ${_df}\";")
system(s);
}
EOF
}

fill_kv_file() {
   local _fsrc _fdst _awk _dir _prog

   _fsrc="$1"
   _fdst="$2"
   shift 2

   _prog=$(mktemp)
   gen_kv_awk "$@" >$_prog
   # cat $_prog >&2
   
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
		       eval "cat $_fsrc |awk -f $_prog"
   rm -Rf $_prog
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

