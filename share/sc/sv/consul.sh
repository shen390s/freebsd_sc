consul_pkgs() {
    echo consul
}

consul_config() {
    true
}

consul_enable() {
    sysrc consul_enable="YES"
}

consul_start() {
    service consul start
}

consul_stop() {
    service consul stop
}
