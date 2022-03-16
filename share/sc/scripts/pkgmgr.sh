. $TOP/share/sc/scripts/funcs.sh

pkg_installed() {
    local _pkg

    _pkg=`echo $1|sed -e 's/-/_/g'`

    if fn_defined "${_pkg}_existed" ; then
	if eval "${_pkg}_existed"; then
	    echo yes
	else
	    echo no
	fi
    else
	if pkg info -e "$_pkg" 2>&1 >/dev/null; then
	    echo yes
	else
	    echo no
	fi
    fi
}

install_pkgs() {
    local _pkg

    for _pkg in $*; do
	if [ "X`pkg_installed $_pkg`" = "Xyes" ]; then
	    :
	else
	    run_cmd pkg install -y $_pkg
	fi
    done
}

uninstall_pkgs() {
    local _pkg
    
    for _pkg in $*; do
	if [ "X`pkg_installed $_pkg`" = "Xyes" ]; then
	    run_cmd pkg remove -y $_pkg\*
	fi
	# ignore error of uninstall package
	true
    done
}

pot_existed() {
    test -f /usr/local/bin/pot && \
	test -x /usr/local/bin/pot  
}

consul_existed() {
    test -f /usr/local/bin/nomad && \
	test -x /usr/local/bin/nomad
}

traefik_existed() {
    test -f /usr/local/bin/traefik && \
	test -x /usr/local/bin/traefik
}

nomad_existed() {
    test -f /usr/local/bin/nomad && \
	test -x /usr/local/bin/nomad
}

nomad_pot_driver_existed() {
    test -f /usr/local/libexec/nomad/plugins/nomad-pot-driver && \
	test -x /usr/local/libexec/nomad/plugins/nomad-pot-driver
}
