. $TOP/share/sc/scripts/common.sh

fs_setup() {
    local _item _fs _mp _cmd

    _cmd="cp /etc/fstab /etc/fstab.old && cat /etc/fstab.old"

    for _item in $FSMOUNT; do
	_fs=`echo $_item|awk -F= '{print $1}'`
	_mp=`echo $_item|awk -F= '{print $2}'`
	if [ ! -d $_mp ]; then
	    run_cmd mkdir -p $_mp
	fi
	
	# save_output /etc/fstab echo "$_fs $_mp nfs rw 0 0"  
	_cmd="$_cmd | update_fstab_entry $_fs $_mp"
    done

    if [ ! -z "$_cmd" ]; then
	save_output /etc/fstab eval "$_cmd"
    fi

    if [ -f /etc/fstab ]; then
	if [ -f /etc/fstab.old ]; then
	    rm -Rf /etc/fstab.old
	fi
    else
	if [ -f /etc/fstab.old ]; then
	    mv /etc/fstab.old /etc/fstab
	fi
    fi
}

fs_apply() {
    case "$1" in
	client|server)
	    fs_setup
	    ;;
	*)
	    echo 
	    ;;
    esac
}
