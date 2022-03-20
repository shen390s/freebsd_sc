
render_line() {
    local _line _fmt _comments _data _args _cmd _z _v _val

    _line="$1"
    _data=$(echo $_line |sed -e 's/#.*$//g')
    _comments=$(echo $_line |sed -e 's/^[^#]*#/#/g' -e 's/^[^#]*$//g')
    _fmt=$(echo $_data |sed -e 's/%%[a-zA-Z0-9_]*%%/%s/g')
    _args=$(echo $_data |grep -o "%%[a-zA-Z0-9]*%%" |sed -e 's/%%//g' |xargs echo)
    
    _cmd="printf \"$_fmt\" "
    for _v in $_args; do
	_val=$(getvar "$_v")
	_cmd="$_cmd '$_val'"
    done

    _z=$(eval "$_cmd")
    if [ -z "$_comments" ]; then
	:
    else
	_z=$(echo "$_z$_comments")
    fi
    echo $_z
}

getvar() {
    local _var

    _var="$1"

    case "$_var" in
	*)
	    echo [value of $_var]
	    ;;
    esac
}
