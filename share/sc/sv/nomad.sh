nomad_pkgs() {
    echo nomad nomad-pot-driver
}

nomad_config() {
    true
}

nomad_enable() {
    run_command sysrc nomad_enable="YES"
}

nomad_start() {
    run_command service nomad start
}

nomad_stop() {
    run_command service nomad stop
}
