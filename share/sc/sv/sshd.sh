sshd_set_port() {
    local _p

    _p="$1"
    cd /etc/ssh
    run_command mv sshd_config /tmp/sshd_config
    save_command_output sshd_config cat /tmp/sshd_config | sed -E -e '/^Port[ \t\b]+[0-9]+' 
    save_command_output sshd_config echo "Port $_p" 
}
sshd_config() {
    local _port

    _port="$1"
    if [ -z "$_port" ]; then
	_port="22"
    fi

    if [ "x${_port}" = "x22" ]; then
	:
    else
	sshd_set_port "$_port"
    fi

    run_command service sshd onestart
}

sshd_enable() {
    run_command sysrc sshd_enable="YES"
}

sshd_start() {
    run_command service sshd start
}
