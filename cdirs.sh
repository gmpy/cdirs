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
    [ -n "${var}" ] && echo $(split_path ${var})
}

# get_path_from_label <label>
get_path_from_label() {
    var=$(env | grep "${gmpy_cdir_prefix}_[0-9]_$1" | head -n 1)
    [ -n "${var}" ] && echo $(split_path ${var})
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

# _cdir <label|num|path>
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

# _lsdir [num|label]
_lsdir() {
    if [ $# -gt 1 ]; then
        echo "Usage: lsdir [num|label]"
        return -1
    fi
   
    if [ $# -eq 1 ]; then
        ls_one_dir $1
    else
        ls_all_dirs
    fi
}

# ls_all_dirs
ls_all_dirs() {
    for (( cnt=1; cnt<=${gmpy_cdir_cnt} ; cnt++ ))
    do
        ls_format $(env | grep "${gmpy_cdir_prefix}_${cnt}" | head -n 1)
    done
}

# ls_one_dir <num|label>
ls_one_dir() {
    case "`check_type $1`" in
        num)
            ls_format "$(env | grep "${gmpy_cdir_prefix}_$1" | head -n 1)"
            ;;
        label)
            ls_format "$(env | grep "${gmpy_cdir_prefix}_[0-9]_$1" | head -n 1)"
            ;;
        *)
            echo "Usage: lsdir [num|label]"
            ;;
    esac
}

# ls_format <gmpy_cdir_num_label=path>
ls_format() {
    if [ ! ${1:0:9} = ${gmpy_cdir_prefix} ]; then 
        return -1
    fi
    
    local num=$(split_num $1)
    local label=$(split_label $1)
    local path=$(split_path $1)

    [ $(check_type ${num}) = "num" ] && echo -en "${num} :" || return -1
    [ $(check_type ${label}) = "label" ] && echo -en "\t${label}" || return -1
    [ $(check_type ${path}) = "path" ] && echo -e "\t\t${path}" || return -1

}

# split_num <gmpy_cdir_num_label=path>
split_num() {
    local num
    num=${1#*_}
    num=${num#*_}
    num=${num%_*}

    echo ${num}
}

# split_label <gmpy_cdir_num_label=path>
split_label() {
    local label
    label=${1##*_}
    label=${label%=*}

    echo ${label}
}

# split_path <gmpy_cdir_num_label=path>
split_path() {
    echo ${1#*=}
}

# _cldir <num|label|path>
_cldir() {
    sleep 1
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
            _lsdir $@
            ;;
        "cldir")
            shift
            _cldir $@
            ;;
        *)
            echo "Usage: cdir|setdir|lsdir|cldir"
            return -1
            ;;
    esac
}

gmpy $@
