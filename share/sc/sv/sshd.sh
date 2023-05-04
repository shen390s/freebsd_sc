sshd_config() {
    run_command service sshd onestart
}

sshd_enable() {
    run_command sysrc sshd_enable="YES"
}

sshd_start() {
    run_command service sshd start
}
