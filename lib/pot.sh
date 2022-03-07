. $TOP/lib/common.sh

pot_pkgs() {
    echo pot 
}

config_pot() {
    run_cmd pot init
}

pot_apply() {
    case "$1" in
	client|server)
	    run_cmd pkg install -y pot
	    config_pot
	    ;;
	*)
	    echo
	    ;;
    esac
}

