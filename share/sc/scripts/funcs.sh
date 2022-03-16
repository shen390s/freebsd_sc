fn_defined() {
    local  _fn _z

    _fn="$1"
    _z=`type "$_fn" 2>/dev/null | head -n 1`
    case "$_z" in
	${_fn}*function*)
	    true
	    ;;
	*)
	    false
	    ;;
    esac
}

uniq_list() {
    echo $* |xargs -n 1 echo |sort |uniq |xargs echo
}

run_cmd() {
    if [ "X$DRY_RUN" = "Xyes" ]; then
	echo "$@"
    else
	eval "$@"
    fi
}

save_output() {
    local _to

    _to="$1"
    shift

    if [ "X$DRY_RUN" = "Xyes" ]; then
	echo
	echo "!!!Following data will be appended to file $_to !!!"
	echo
	eval "$@"
    else
	eval "$@ >> $_to"
    fi
}

random_num() {
    local _min _max

    _min="$1"
    _max="$2"

    if [ -z "$_min" ]; then
	_min=10
    fi

    if [ -z "$_max" ]; then
	_max=200
    fi
    
    awk -v min=$_min -v max=$_max 'BEGIN{srand(); print int(min+rand()*(max-min+1))}'
}

name_in_list() {
    local _name _n2

    _name="$1"
    shift

    for _n2 in $*; do
	if [ "X$_name" = "X$_n2" ]; then
	    true
	    return
	fi
    done
    false
}

exclude_from_list() {
    local _item _all _ix _sep

    _item="$1"
    shift
    _all=""
    _sep=""

    for _ix in $*; do
	if [ "X$_item" =  "X$_ix" ]; then
	    :
	else
	    _all="$_all$_sep$_ix"
	    _sep=" "
	fi
    done

    echo "$_all"
}
