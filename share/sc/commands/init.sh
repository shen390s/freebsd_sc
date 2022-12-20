
sc_init() {
    local _role _stage

    _role="$1"
    shift

    if [ -z "$_role" ]; then
	_role="master"
    fi

    for _stage in install config start; do
	if $TOP/share/sc/tools/$_stage "$_role" ; then
	    :
	else
	    echo  "$_role" failed in "$_stage"
	    exit 1
	fi
    done
}

sc_init_help() {
    echo "init  [master | slave]  setup current host as node of cluster"
}

add_commands init
