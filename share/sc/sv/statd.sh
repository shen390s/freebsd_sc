statd_pkgs() {
    echo
}

statd_enable() {
    run_command sysrc rpc_statd_enable="YES"
}
