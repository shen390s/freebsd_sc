fn_defined() {
    local _fn 

    _fn="$1"

    if type "$_fn" 2>/dev/null | grep "^${_fn}.*function" >/dev/null; then
	echo yes
    else
	echo no
    fi
}

load_conf() {
    local _f

    for _f in $*; do
	. $_f
    done
}

is_dry_run() {
    if [ "x$dry_run" = "xyes" ]; then
	true
    else
	false
    fi
}

check_debug() {
    test "x$debug" = "xyes" && set -x
}

run_command() {
    if is_dry_run; then
	echo "run command: $_pexec $@"
    else
	eval "$@"
    fi
}

save_command_output() {
    local _f 

    _f="$1"
    shift

    if is_dry_run; then
	echo Following output data will be saved to "$_f":
	eval "$@"
    else
	eval "$@" >> "$_f"
    fi
}

boot_file() {
    if [ -z "$BOOTFILE" ]; then
	echo /boot/loader.conf
    else
	echo $BOOTFILE
    fi
}

get_boot_key() {
    local _key _c _bootf

    _key="$1"
    shift

    _c="awk -F= '{if (\$1 == \"${_key}\") print \$2 }'"

    _bootf=$(boot_file)
    
    cat $_bootf | \
	sed -e 's/#.*$//g' -e '/^$/d' | \
	eval "$_c"
}

set_boot_key() {
    local _k _v _v1 

    _k="$1"
    _v="$2"
    shift 2
    
    _v1=$(get_boot_key "$_k")
    if [ "x${_v1}" = "x${_v}" ]; then
	:
    else
	if cat $(boot_file) |sed -e 's/#.*$//g' -e '/^$/d' |grep "$_k=" 2>&1 >/dev/null; then
	    run_command sed -i -e "s/${_k}=.*$/${_k}=${_v}/g" $(boot_file)
	else
	    save_command_output $(boot_file) echo "${_k}=${_v}" 
	fi
    fi
}

get_mount() {
    local _from _mpt _c

    _from="$1" && shift

    _c="awk '{if (\$1 == \"${_from}\") print \$2 }'"
    cat /etc/fstab | \
	sed -e 's/#.*$//g' -e '/^$/d' | \
	eval "$_c"
}

add_mount() {
    local _from _mpt _fs _v

    _from="$1" && shift
    _mpt="$1" && shift
    _fs="$1" && shift
    
    _v=$(get_mount "$_from")
    if [ ! -z "$_v" ]; then
	if [ "x$_v" = "x$_mpt" ]; then
	    return
	else
	    echo Conflict fstab item "$_from"
	    exit 1
	fi
    fi

    save_command_output /etc/fstab echo "$_from $_mpt $_fs rw 0 0"
}

try_get_netif_ip() {
    local _prefix _max _idx _netif _ip

    _prefix="$1"
    _max="$2"

    if [ -z "$_prefix" ]; then
	_prefix="em"
    fi

    if [ -z "$_max" ]; then
	_max=0
    fi

    for _idx in $(seq 0 $_max); do
	_netif=$(printf "$_prefix" "$_idx")
	_ip=$(ifconfig "$_netif" |\
		  grep inet |\
		  head -n 1 |\
		  awk '{print $2}')
	if [ -z "$_ip" ]; then
	    :
	else
	    echo "$_ip"
	    return
	fi
    done

    echo
}

get_my_ip() {
    local _ip _if _maxif

    for _if in $netif_names; do
	case "$_if" in
	    epair*)
		_maxif=20
		;;
	    *)
		_maxif=0
		;;
	esac

	_ip=$(try_get_netif_ip "$_if" "$_maxif")

	if [ ! -z "$_ip" ]; then
	    echo "$_ip"
	    return
	fi
    done

    echo
}
