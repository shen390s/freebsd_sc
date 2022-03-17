. $TOP/share/sc/scripts/funcs.sh

install_pkgs() {
    local _pkg

    for _pkg in $*; do
	run_cmd pkg install -y $_pkg
    done
}

uninstall_pkgs() {
    local _pkg
    
    for _pkg in $*; do
	run_cmd pkg remove -y $_pkg\*
	# ignore error of uninstall package
	true
    done
}

}
