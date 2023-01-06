
sc_init() {
    local _role _stage _status _d

    _role="server"

    for _stage in install config start; do
	run_helper "" $_stage "$_role"
	_status=$?

	if [ $_status -ne 0 ]; then
	    echo  "$_role" failed in "$_stage"
	    exit 1
	fi
    done
}

sc_init_help() {
    echo "init  setup current host as node of cluster"
}

add_commands init
