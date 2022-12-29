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

pot_config() {
    run_command pot init
    run_command pot vnet-start
#    run_command sysrc pot_enable="YES"
    mk_boot_config
}

pot_enable() {
    run_command sysrc pot_enable="YES"
}
