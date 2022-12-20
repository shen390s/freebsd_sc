sc_test() {
    local _case _c

    _case="$@"

    for _c in $_case; do
	. $TOP/testsuite/$_c
	run_test
    done
}

sc_test_help() {
    echo "test case1 [... casen] "
}

add_commands test
