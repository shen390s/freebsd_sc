fn_defined() {
    local _fn 

    _fn="$1"

    if type "$_fn" 2>/dev/null | grep "^${_fn}.*function" >/dev/null; then
	echo yes
    else
	echo no
    fi
}

filt_jargs() {
    local _var1 _var2 _s

    _var1="$1" && shift
    _var2="$1" && shift
    
    if [ "x$1" = "x-j" ]; then
	_s="$_var1=$2"
	# eval "echo \$$_var"
	shift 2
    else
	_s="$_var1=\"\""
    fi

    echo "$_s $_var2=$@"
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
    if [ "x$debug" = "xyes" ]; then
	set -x
    fi
}

run_command() {
    local _pexec

    if [ "x$1" = "x-j" ]; then
	_pexec="pot exec -p $2 "
	shift 2
    else
	_pexec=""
    fi
    
    
    if is_dry_run; then
	echo "run command: $_pexec $@"
    else
	eval $_pexec "$@"
    fi
}

save_command_output() {
    local _f _data

    _f="$1"
    shift

    _data=$(run_command "$@")

    if is_dry_run; then
	echo Following output data will be saved to "$_f":
	echo $_data
    else
	echo $_data >> "$_f"
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
