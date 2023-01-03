pot_pkgs() {
    echo pot
}

mk_boot_config() {
    local _oldv

    _oldv=$(get_boot_key "kern.racct.enable")

    if [ "x${_oldv}" = "x1" ]; then
	:
    else
	set_boot_key "kern.racct.enable" 1
    fi
}

patch_pot() {
    local _f _f1 _d

    _d=/usr/local/share/pot
    for _f in $TOP/share/sc/patches/pot/*.patch; do
	_f1=$(basename "$_f")
	if [ -f $_d/.${_f1}.done ]; then
	    continue
	fi

	if run_command patch -d $_d -b -i $_f; then
	    run_command touch $_d/.${_f1}.done
	fi
    done
}
pot_config() {
    patch_pot 
    run_command pot init
    run_command pot vnet-start
#    run_command sysrc pot_enable="YES"
    mk_boot_config
}

pot_enable() {
    run_command sysrc pot_enable="YES"
}
