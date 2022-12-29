nomad_pkgs() {
    echo nomad nomad-pot-driver
}

nomad_config() {
    run_command sysrc nomad_args="\"-config=/usr/local/etc/nomad\""
    run_command sysrc nomad_user="root"
    run_command sysrc nomad_env="\"PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/sbin:/bin\""
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
