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
    var=$(get_env_from_num $1 | head -n 1)
    [ -n "${var}" ] && echo $(get_path_from_env ${var})
}

# get_path_from_label <label>
get_path_from_label() {
    var=$(get_env_from_label $1 | head -n 1)
    [ -n "${var}" ] && echo $(get_path_from_env ${var})
}

# is_dir_path <label|num|path>
is_dir_path() {
    case ${1} in
        -)
            echo yes
            ;;
        *)
            [ -d $1 ] && echo yes || echo no
            ;;
    esac
}

# check_type <label|num|path>
# echo the result
check_type() {
    if [ $# -ne 1 ]; then
        return -1
    fi

    if [ "$(is_dir_path $1)" = "yes" ]; then
        echo path
        return 0
    fi

    case ${1:0:1} in
        0|1|2|3|4|5|6|7|8|9)
            echo num
            ;;
        *)
            echo label
            ;;
    esac
}

# set_env <var> <path>
set_env() {
    eval "export $1=$2"
}

# get_absolute_path <path>
get_absolute_path() {
    local path="${PWD}"
    local path_tmp=$1

    if [ "$1" = "-" ]; then
        echo "${OLDPWD}"
        return 0
    elif [ "$1" = "." ]; then
        echo "${PWD}"
        return 0
    elif [ "$1" = ".." ]; then
        echo "${OLDPWD}"
        return 0
    elif [ "$1" = "~" ]; then
        echo "${HOME}"
        return 0
    fi

    while [ -n "$(echo ${path_tmp} | egrep "\./|\.\./")" ]
    do
        if [ "${path_tmp%%/*}" = ".." ]; then
            path=${path%/*}
        elif [ ! "${path_tmp%%/*}" = "." ]; then
            paht="${path}/${path_tmp%%/*}"
        fi
        path_tmp="${path_tmp#*/}"
    done

    [ ! "${path_tmp}" = "$1" ] && echo "${path}/${path_tmp}" && return 0

}

# _setdir <label> <path>
_setdir() {
    if [ $# -ne 2 ]; then
        echo "Usage: setdir <label> <path>"
        return -1
    fi

    if [ ! "`check_type $1`" = "label" ] || [ ! "`check_type $2`" = "path" ]; then
        echo "Usage: setdir <label> <path>"
        return -1
    fi

    #get path
    local path=$(get_absolute_path $2)

    #get var
    local var=$(get_env_from_label $1)
    if [ -n "${var}" ]; then
        var=${var%%=*}
    else
        add_num_cnt
        var=${gmpy_cdir_prefix}_$(get_num_cnt)_$1
    fi

    set_env ${var} ${path}
}

# _cdir <label|num|path>
_cdir() {
    if [ "$#" -ne "1" ]; then
        return -1
    fi

    if [ "`check_type $1`" = "path" ]; then
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
    for (( cnt=1; cnt <= $(get_num_cnt) ; cnt++ ))
    do
        ls_format $(get_env_from_num ${cnt} | head -n 1)
    done
}

get_num_cnt() {
    [ -z "${gmpy_cdir_cnt}" ] && export gmpy_cdir_cnt=0
    echo ${gmpy_cdir_cnt}
}

add_num_cnt() {
    export gmpy_cdir_cnt=$(( $(get_num_cnt) + 1 ))
}

# ls_one_dir <num|label>
ls_one_dir() {
    case "`check_type $1`" in
        num)
            ls_format "$(get_env_from_num $1 | head -n 1)"
            ;;
        label)
            ls_format "$(get_env_from_label $1 | head -n 1)"
            ;;
        *)
            echo "Usage: lsdir [num|label]"
            ;;
    esac
}

# ls_format <gmpy_cdir_num_label=path>
ls_format() {
    if [ ! "${1:0:9}" = "${gmpy_cdir_prefix}" ]; then 
        return -1
    fi
    
    local num=$(get_num_from_env $1)
    local label=$(get_label_from_env $1)
    local path=$(get_path_from_env $1)

    if [ -n "${num}" ]; then
        echo -en "${num} )"
    else
        echo 
        return -1
    fi

    if [ -n "${label}" ]; then
        echo -en "\t${label}"
    else
        echo 
        return -1
    fi

    if [ -n "${path}" ]; then
        echo -e "\t${path}"
    else
        echo 
        return -1
    fi
}

# get_num_from_env <gmpy_cdir_num_label=path>
get_num_from_env() {
    local num
    num=${1#*_}
    num=${num#*_}
    num=${num%%_*}

    echo ${num}
}

# get_label_from_env <gmpy_cdir_num_label=path>
get_label_from_env() {
    local label
    label=${1#*_}
    label=${label#*_}
    label=${label#*_}
    label=${label%%=*}

    echo ${label}
}

# get_path_from_env <gmpy_cdir_num_label=path>
get_path_from_env() {
    echo ${1##*=}
}

# _cldir <num|label|path>
_cldir() {
    if [ $# -lt 1 ]; then
        echo "Usage: cldir <num1|label1|path1> <num2|label2|path2> ..."
        return -1
    fi

    for para in $@
    do
        case "$(check_type ${para})" in
            "num")
                clear_dir_from_num ${para}
                ;;
            "label")
                clear_dir_from_label ${para}
                ;;
            "path")
                clear_dir_from_path ${para}
                ;;
        esac
    done
}

# split_env <env>
split_env() {
   echo ${1%=*} 
}

# clear_dir_from_num <num>
clear_dir_from_num() {
    unset $(split_env $(get_env_from_num $1))
}

# clear_dir_from_path <num>
clear_dir_from_path() {
    local path=$(get_absolute_path $1)
    unset $(split_env $(get_env_from_path ${path}))
}

# clear_dir_from_label <num>
clear_dir_from_label() {
    unset $(split_env $(get_env_from_label $1))
}

# get_env_from_num <num>
get_env_from_num() {
    local env=$(env | grep "^${gmpy_cdir_prefix}_$1_.*")
    [ $(echo ${env} | wc -l) -eq 1 ] && echo ${env}
}

# get_env_from_path <path>
get_env_from_path() {
    local env=$(env | egrep "^${gmpy_cdir_prefix}_[0-9]+_.*=$1/?$")
    [ $(echo ${env} | wc -l) -eq 1 ] && echo ${env}
}

# get_env_from_label <label>
get_env_from_label() {
    local env=$(env | egrep "^${gmpy_cdir_prefix}_[0-9]+_$1")
    [ $(echo ${env} | wc -l) -eq 1 ] && echo ${env}
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
