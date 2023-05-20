mysql_pkgs() {
    echo mysql80-server
}

mysql_cnf() {
    local _role _d

    _role="$1"
    _d=$(get_role_conf_dir "$_role")/mysql
    if [ ! -d $_d ]; then
	run_command mkdir -p $_d
    fi

    echo $_d/my.cnf
}

mysql_data_dir() {
    local _role _d

    _role="$1"

    _d=$(get_role_data_dir "$_role")/var/db

    if [ ! -d $_d ]; then
	run_command mkdir -p $_d
    fi

    echo $_d
}
mk_mysql_cnf() {
    local _role db_root

    _role="$1"
    db_root=$(mysql_data_dir "$_role")
    cat <<EOF
[client]
port                            = 3306
socket                          = /tmp/mysql.sock

[mysql]
prompt                          = \u@\h [\d]>\_
no_auto_rehash

[mysqld]
user                            = mysql
port                            = 3306
socket                          = /tmp/mysql.sock
bind-address                    = 127.0.0.1
basedir                         = /usr/local
datadir                         = $db_root/mysql
tmpdir                          = $db_root/mysql_tmpdir
slave-load-tmpdir               = $db_root/mysql_tmpdir
secure-file-priv                = $db_root/mysql_secure
log-bin                         = mysql-bin
log-output                      = TABLE
master-info-repository          = TABLE
relay-log-info-repository       = TABLE
relay-log-recovery              = 1
slow-query-log                  = 1
server-id                       = 1
sync_binlog                     = 1
sync_relay_log                  = 1
binlog_cache_size               = 16M
expire_logs_days                = 30
default_password_lifetime       = 0
enforce-gtid-consistency        = 1
gtid-mode                       = ON
safe-user-create                = 1
lower_case_table_names          = 1
explicit-defaults-for-timestamp = 1
myisam-recover-options          = BACKUP,FORCE
open_files_limit                = 32768
table_open_cache                = 16384
table_definition_cache          = 8192
net_retry_count                 = 16384
key_buffer_size                 = 256M
max_allowed_packet              = 64M
long_query_time                 = 0.5
innodb_buffer_pool_size         = 1G
innodb_data_home_dir            = $db_root/mysql
innodb_log_group_home_dir       = $db_root/mysql
innodb_data_file_path           = ibdata1:128M:autoextend
innodb_temp_data_file_path      = ibtmp1:128M:autoextend
innodb_flush_method             = O_DIRECT
innodb_log_file_size            = 256M
innodb_log_buffer_size          = 16M
innodb_write_io_threads         = 8
innodb_read_io_threads          = 8
innodb_autoinc_lock_mode        = 2
skip-symbolic-links

[mysqldump]
max_allowed_packet              = 256M
quote_names
quick
EOF
}

gen_update_dbpass() {
    local _pass

    _pass="$1"
    cat <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$_pass';
FLUSH PRIVILEGES;
EOF
}

gen_start_db_script() {
    local _role _my_cnf 

    _role="$1"
    _my_cnf=$(mysql_cnf "$_role")
    
    cat <<EOF
sysrc mysql_enable="YES"
sysrc mysql_optfile="$_my_cnf"
sysrc mysql_dbdir="$(mysql_data_dir $_role)/mysql"
sysrc mysql_confdir="$(dirname $_my_cnf)"
service mysql-server start
EOF
}

prepare_db() {
    local _role _mysql_data_dir _my_cnf _dbpass _cnt _s

    _role="$1"
    _dbpass=$(get_config "$_role".dbpass)
    _mysql_data_dir=$(mysql_data_dir "$_role")
    _my_cnf=$(mysql_cnf "$_role")
    _s=$(get_role_conf_dir "$_role")/start_mysql.sh

    for _d in mysql mysql_secure mysql_tmpdir; do
	if [ ! -d $_mysql_data_dir/$_d ]; then
            run_command mkdir -p $_mysql_data_dir/$_d
            run_command chown -Rf mysql:mysql $_mysql_data_dir/$_d
	fi
    done

    save_command_output $_my_cnf mk_mysql_cnf "$_role"
    save_command_output "$_s" gen_start_db_script "$_role"
    run_command chmod a+x "$_s"

    # start mysql
    run_command sh "$_s"
    
    if [ -f /root/.mysql_secret ]; then
	mysql_root_pass=$(cat /root/.mysql_secret| sed -e 's/^#.*$//g' -e '/^$/d' | head -n 1)
    else
	mysql_root_pass=""
    fi

    save_command_output /tmp/chdbpass.sql gen_update_dbpass "$_dbpass"

    _cnt=0

    while [ $_cnt -lt 100 ]; do
	if [ -S /tmp/mysql.sock ]; then
	    break
	fi

	_cnt=$(expr $_cnt + 1)
	sleep 10
    done
    
    run_command mysql -u root --password="$mysql_root_pass" --connect-expired-password < /tmp/chdbpass.sql
}

mysql_config() {
    local _role

    _role="$1"
    
    prepare_db "$_role"
}

mysql_enable() {
    true
}

mysql_start() {
    local _s

    _s=$(get_role_conf_dir "$1")/start_mysql.sh
    run_command sh "$_s"
}
