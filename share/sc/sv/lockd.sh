lockd_pkgs() {
    echo
}

lockd_enable() {
    run_command sysrc rpc_lockd_enable="YES"
}
