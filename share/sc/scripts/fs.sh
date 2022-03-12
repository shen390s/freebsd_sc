. $TOP/share/sc/scripts/common.sh

fs_mount() {
    local _item _fs _mp

    for _item in $FSMOUNT; do
	_fs=`echo $_item|awk -F= '{print $1}'`
	_mp=`echo $_item|awk -F= '{print $2}'`

	if [ -z "$_fs" -o -z "$_mp" ]; then
	    # something wrong
	    continue
	fi
	
	if [ ! -d $_mp ]; then
	    run_cmd mkdir -p $_mp
	fi
	
	run_cmd mount -t nfs $_fs $_mp
    done
}
fs_start() {
    case "$1" in
	client|server)
	    fs_mount
	    ;;
	*)
	    true
	    ;;
    esac
}
