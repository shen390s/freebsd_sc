gen_passwd() {
    local _u

    _u="$1"

    echo "${_u}123456"
}

user_home() {
    local _u _role

    _role="$1"
    _u="$2"

    echo "${data_mountpoint}/${_role}/users/${_u}"
}
gen_users_data() {
    local _users _it _uid 

    _role="$1"
    shift
    _uid=1110
    for _it in $*; do
	echo "$_it:$_uid:::::$_it::/bin/sh:$(gen_passwd $_it)"
	_uid=$(expr "$_uid" + 1)
    done
}

setup_user_keys() {
    local _role _u _home

    _role="$1"
    _u="$2"
    
    if [ -d $sc_mountpoint/share/sc/data/users/$_u/.ssh ]; then
	_home=$(user_home "$_role" "$_u")
	if [ ! -d "$_home" ]; then
	    run_command mkdir -p $_home
	fi

	run_command cp -Rf $sc_mountpoint/share/sc/data/users/$_u/.ssh \
	   $_home/.ssh
	
	run_command chown -Rf $_u $_home
	run_command chmod 0700 $_home/.ssh
    fi
}

setup_user_home() {
    local _role _u _home

    _role="$1"
    _u="$2"

    _home=$(user_home "$_role" "$_u")
    if [ ! -d $_home ]; then
	run_command mkdir -p  $_home
    fi

    run_command chown -Rf $_u $_home 
    run_command pw usermod "$_u" -d "$_home"
#    setup_user_keys "$_role" "$_u"
}

create_users() {
    local _role _u _uf _users

    _role="$1"
    shift

    _users="$*"
    _uf=$(mktemp /tmp/users.XXXXX)
    gen_users_data "$_role" $_users>$_uf

    run_command rmuser -y "$_users"

    run_command adduser -f $_uf
}

config_users() {
    local _role _users _u

    _role="$1"
    shift
    _users="$*"
    for _u in $_users; do
	setup_user_home "$_role" "$_u"
    done
}
