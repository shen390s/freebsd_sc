pot_pkgs() {
    echo pot
}

pot_config() {
    run_command pot init
    run_command pot vnet-start
}
