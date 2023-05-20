seafile_pkgs() {
    echo seafile-server
}

gen_start_seafile_script() {
    local _cnf_dir _data_dir

    _cnf_dir=$(get_role_conf_dir seafile)
    _data_dir=$(get_role_data_dir seafile)
    cat <<EOF
sysrc seafile_ccnet="$_cnf_dir/ccnet"
sysrc seafile_conf="$_cnf_dir/conf"
sysrc seafile_datadir="${_data_dir}/data"
sysrc seafile_logdir="${_data_dir}/seafile-logs"
sysrc seafile_enable="YES"
service seafile start
EOF
}

prepare_seafile() {
    local _cnf_dir _dc _domain _seafilepass _dbpass _data_dir _s

    _cnf_dir=$(get_role_conf_dir seafile)
    _dc="$datacenter"
    _domain="$domain"
    _seafilepass=$(get_config seafile.pass)
    _dbpass=$(get_config seafile.dbpass)
    _data_dir=$(get_role_data_dir seafile)
    _s=$(get_role_conf_dir seafile)/start_seafile.sh

   if [ -d /usr/local/www/haiwen/ccnet ]; then
      run_command rm -Rf /usr/local/www/haiwen/ccnet
   fi

   if [ -d $_data_dir/data ]; then
      run_command rm -Rf $_data_dir/data
   fi

   if [ -L /usr/local/www/haiwei/seafile-server-latest ]; then
       run_command unlink /usr/local/www/haiwei/seafile-server-latest
   fi

   run_command /usr/local/www/haiwen/seafile-server/setup-seafile-mysql.sh \
	       auto \
               -n seafile \
	       -p $(get_config seafile.port) \
               -i seafile.$_dc.$_domain \
               -d $_data_dir/data -e 0 \
               -u seafile -w "$_seafilepass" -r "$_dbpass"

   if [ ! -d $_cnf_dir ]; then
       run_command mkdir -p $_cnf_dir
   fi

   for _d in ccnet conf; do
       if [ -d /usr/local/www/haiwen/$_d ]; then
          run_command cp -Rf /usr/local/www/haiwen/$_d $_cnf_dir/$_d
       fi
   done

   save_command_output $_s gen_start_seafile_script
   run_command chmod a+x "$_s"
}

seafile_config() {
    prepare_seafile 
}

seafile_enable() {
    true
}

seafile_start() {
    local _s

    _s=$(get_role_conf_dir seafile)/start_seafile.sh
    run_command sh $_s
}
