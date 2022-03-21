fn_defined() {
    local  _fn _z

    _fn="$1"
    _z=`type "$_fn" 2>/dev/null | head -n 1`
    case "$_z" in
	${_fn}*function*)
	    true
	    ;;
	*)
	    false
	    ;;
    esac
}

uniq_list() {
    echo $* |xargs -n 1 echo |sort |uniq |xargs echo
}

run_cmd() {
    if [ "X$DRY_RUN" = "Xyes" ]; then
	echo "$@"
    else
	eval "$@"
    fi
}

save_output() {
    local _to

    _to="$1"
    shift

    if [ "X$DRY_RUN" = "Xyes" ]; then
	echo
	echo "!!!Following data will be appended to file $_to !!!"
	echo
	eval "$@"
    else
	eval "$@ >> $_to"
    fi
}

random_num() {
    local _min _max

    _min="$1"
    _max="$2"

    if [ -z "$_min" ]; then
	_min=10
    fi

    if [ -z "$_max" ]; then
	_max=200
    fi
    
    awk -v min=$_min -v max=$_max 'BEGIN{srand(); print int(min+rand()*(max-min+1))}'
}

name_in_list() {
    local _name _n2

    _name="$1"
    shift

    for _n2 in $*; do
	if [ "X$_name" = "X$_n2" ]; then
	    true
	    return
	fi
    done
    false
}

exclude_from_list() {
    local _item _all _ix _sep

    _item="$1"
    shift
    _all=""
    _sep=""

    for _ix in $*; do
	if [ "X$_item" =  "X$_ix" ]; then
	    :
	else
	    _all="$_all$_sep$_ix"
	    _sep=" "
	fi
    done

    echo "$_all"
}

enable_racct() {
    local _sfile
    
    cp /boot/loader.conf /boot/loader.conf.old
    _sfile=`mktemp -q /tmp/.XXXXX.awk`
    if [ $? -ne 0 ]; then
	return
    fi

    cat >$_sfile <<EOF
BEGIN {
   found = 0
}

/^kern.racct.enable=/ { 
   printf("kern.racct.enable=\"1\"\n"); found = 1 
}

! /^kern.racct.enable=/ { 
   print 
}

END {
   if ( found == 0) {
       printf("kern.racct.enable=\"1\"\n")
   }
}
EOF
    
    save_output /boot/loader.conf \
		awk -f $_sfile /boot/loader.conf.old

    if [ -f /boot/loader.conf.old ]; then
	if [ -f /boot/loader.conf ]; then
	    rm -Rf /boot/loader.conf.old
	else
	    mv /boot/loader.conf.old
	fi
    fi
}

file_modify_time() {
    eval $(stat -s "$1")
    echo $st_mtime
}

file_newer() {
    local _mt1 _mt2

    _mt1=`file_modify_time "$1"`
    _mt2=`file_modify_time "$2"`

    if [ $_mt1 -gt $_mt2 ]; then
	echo yes
    else
	echo no
    fi
}

get_server_list() {
    local _servers _h _item _is_server

    if [ ! -z "$SERVER_HOSTS" ]; then
	echo "$SERVER_HOSTS"
	return
    fi
    
    _servers=
    for _item in $CLUSTER_HOSTS; do
	_is_server=`echo $_item |awk -F: '{print $2}'`
	_h=`echo $_item |awk -F: '{print $1}'`
	if [ -z "$_is_server" -o "X$_is_server" != "X1" ]; then
	    true
	else
	    _servers="$_servers $_h"
	fi
    done

    SERVER_HOSTS="$_servers"
    export SERVER_HOSTS
    echo "$_servers"
}

get_all_hosts() {
    local _all_hosts _item _h

    if [ ! -z $ALL_HOSTS ]; then
	echo "$ALL_HOSTS"
	return
    fi
    
    _all_hosts=
    for _item in $CLUSTER_HOSTS; do
	_h=`echo $_item | awk -F: '{print $1}'`
	_all_hosts="$_all_hosts $_h"
    done

    ALL_HOSTS="$_all_hosts"
    export ALL_HOSTS

    echo "$_all_hosts"
}

my_host_idx() {
    local _all_hosts _h _idx _host

    _all_hosts=`get_all_hosts`
    _h=`hostname`
    _idx=0

    for _host in $_all_hosts; do
	if [ "X$_h" == "X$_host" ]; then
	    echo $_idx
	    return
	fi
	_idx=`expr $_idx + 1`
    done   
}

is_server() {
    local _host _servers

    _host=`hostname`
    _servers=`get_server_list`

    name_in_list $_host "$_servers"
}

get_server_count() {
    local _servers _nc _s

    _nc=0
    _servers=`get_server_list`
    for _s in $_servers; do
	_nc=`expr $_nc + 1`
    done
    echo $_nc
}

get_voted_server_count() {
    local _nc

    _nc=`get_server_count`
    _nc=`expr $_nc / 2`
    expr $_nc + 1
}

get_interface_ips() {
    local _if

    _if="$1"

    # do not include ip address with vhid
    ifconfig "$_if" |grep -v vhid|awk '$1 == "inet" {print $2}' |xargs echo
}

get_bind_ip() {
    get_interface_ips "$1"| awk '{print $1}'
}

