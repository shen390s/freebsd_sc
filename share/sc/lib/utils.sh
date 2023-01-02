gen_kv_sed() {
   local _it _cmd _k _var _v

   _cmd="sed "
   for _it in $*; do
       _k=$(echo $_it | awk -F: '{print $1}')
       _v=$(echo $_it | awk -F: '{print $2}')
       _cmd="$_cmd -e \"s@%%$_k%%@\$$_v@g\" "
   done

   echo $_cmd
}

mk_newline() {
    sed -e 's/%%NEWLINE%%/\
/g'
}

mk_tab() {
    sed -e 's/%%TAB%%/    /g'
}

fill_kv_file() {
   local _fsrc _fdst _sed _dir

   _fsrc="$1"
   _fdst="$2"
   shift 2

   _sed=$(gen_kv_sed "$@")

   _dir=$(dirname $_fdst)
   if [ -z "$_dir" ]; then
      :
   else
      if [ ! -d $_dir ]; then
         run_command mkdir -p $_dir
      fi
   fi
   run_command rm -Rf $_fdst
   save_command_output "$_fdst" \
		       eval "cat $_fsrc | eval $_sed |mk_newline |mk_tab"
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

