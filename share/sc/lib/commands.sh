load_commands() {
    local _f

    sc_commands=""
    for _f in $TOP/share/sc/commands/*.sh; do
	if [ -f $_f ]; then
	    . $_f
	fi
    done
}

add_commands() {
    local _c

    for _c in "$@"; do
	sc_commands="$sc_commands $_c"
    done
}
