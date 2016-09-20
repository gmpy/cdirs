#!/bin/bash

gmpy_cdir_prefix="gmpy_cdir"

# get_path <label|num|path>
# echo the result
get_path() {
    if [ $# -ne 1 ]; then
        return -1
    fi

    case "`check_type $1`" in
        "path")
            echo $1
            ;;
        "num")
            echo $(get_path_from_num $1)
            ;;
        "label")
            echo $(get_path_from_label $1)
            ;;
    esac
}

# get_path_from_num <num>
get_path_from_num() {
    var=$(env | grep "${gmpy_cdir_prefix}_$1" | head -n 1)
    [ -n "${var}" ] && echo ${var#*=}
}

# get_path_from_label <label>
get_path_from_label() {
    var=$(env | grep "${gmpy_cdir_prefix}_[0-9]_$1" | head -n 1)
    [ -n "${var}" ] && echo ${var#*=}
}

# check_type <label|num|path>
# echo the result
check_type() {
    if [ $# -ne 1 ]; then
        echo "Usage: check_type <label|num|path>"
        return -1
    fi

    case ${1:0:1} in
        -|.|~|/)
            echo path
            ;;
        0|1|2|3|4|5|6|7|8|9)
            echo num
            ;;
        *)
            echo label
            ;;
    esac
}

# set_env <variable> <path>
set_env() {
    eval "export $1=$2"
}

_setdir() {
    if [ $# -ne 2 ]; then
        echo "Usage: setdir <label> <path>"
        return -1
    fi

    if [ ! "`check_type $1`" = "label" ] || [ ! "`check_type $2`" = "path" ]; then
        echo "Usage: setdir <label> <path>"
        return -1
    fi

    export gmpy_cdir_cnt=$(( ${gmpy_cdir_cnt} + 1 ))
    set_env ${gmpy_cdir_prefix}_${gmpy_cdir_cnt}_$1 $2
}

#_cdir <label|num|path>
_cdir() {
    if [ "$#" -ne "1" ]; then
        return -1
    fi

    if [ "`check_type $1`" = "path" ];then
        echo $1
        return 0
    fi

    echo $(get_path $1)
}

#why it name gmpy? just i enjoy!
gmpy() {
    if [ $# -lt 1 ]; then
        echo "Usage: cdir|setdir|lsdir|cldir"
        return -1
    fi

    case "$1" in
        "cdir")
            shift
            _cdir $@
            ;;
        "setdir")
            shift
            _setdir $@
            ;;
        "lsdir")
            shift
            lsdir $@
            ;;
        "cldir")
            shift
            cldir $@
            ;;
        *)
            echo "Usage: cdir|setdir|lsdir|cldir"
            return -1
            ;;
    esac
}

gmpy $@
