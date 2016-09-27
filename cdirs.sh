#!/bin/bash

cdir() {
    if [ "$#" -gt "1" ]; then
        echo -e "\033[31mUsage: cdir <num|label|path>\033[0m"
        return 0
    elif [ "$#" -eq "0" ]; then
        replace_cd
    else
        replace_cd `_cdir "$1"`
    fi
}

setdir() {
    local opts=$(getopt -l "global,help" -o "hg" -- $@) || return -1
    eval set -- ${opts}
    while true
    do
        case "$1" in
            -h|--help)
                shift
                ;;
            -g|--global)
                _setdir $(eval "echo \$$(( $# - 1 ))") $(eval "echo \$$#") global
                return 0
                ;;
            --)
                shift
                break
        esac
    done

    if [ $# -ne 2 ]; then
        echo -e "\033[31mUsage: setdir <label> <path>\033[0m"
        return -1
    else
        _setdir $@
    fi
}

lsdir() {
    local opts=$(getopt -l "print:,help" -o "hp:" -- $@) || return -1
    eval set -- ${opts}
    while true
    do
        case "$1" in
            -h|--help)
                shift
                ;;
            -p|--print)
                local path="$(get_path $2)"
                echo ${path} | grep "^.*/$" &>/dev/null && echo ${path%/*} || echo ${path}
                return 0
                ;;
            --)
                shift
                break
                ;;
        esac
    done

    _lsdir $@
}

cldir() {
    local opts=$(getopt -l "all,reset,help,reload,global" -o "gha" -- $@) || return -1
    local global_flag=0
    eval set -- ${opts}
    while true
    do
        case "$1" in
            -h|--help)
                shift
                ;;
            --reset)
                reset
                return 0
                ;;
            --reload)
                gmpy_cdir_initialized=0
                load_default_label
                return 0
                ;;
            -a|--all)
                clear_all
                return 0
                ;;
            -g|--global)
                shift
                global_flag=1
                ;;
            --)
                shift
                break
                ;;
            *)
                shift
                ;;
        esac
    done

    if [ "${global_flag}" -eq "1" ]; then
        for (( num=1; num<=${#}; num++ ))
        do
            clear_global_dir $(eval echo "\$${num}")
        done
    fi
    _cldir $@
}

# clear_global_dir <num|dir|path>
clear_global_dir() {
    case "$(check_type $1)" in
        num)
            clear_global_dir_from_label $(get_label_from_env $(get_env_from_num $1))
            ;;
        label)
            clear_global_dir_from_label $1
            ;;
        path)
            local path=$(get_absolute_path $1)
            clear_global_dir_from_label $(get_label_from_env $(get_env_from_path ${path}))
            ;;
    esac
}

# replace_cd <path>
replace_cd() {
    local alias_cd=$(alias | grep "cd=.*$" | awk '{print $2}')
    [ -n "${alias_cd}" ] && unalias cd
    cd $1
    [ -n "${alias_cd}" ] && eval alias ${alias_cd}
}

# reset
# turn back to initial status
reset() {
    clear_all
    load_default_label
}

# clear_all
clear_all() {
    for env in $(get_all_env)
    do
        clear_dir_from_num $(get_num_from_env ${env})
    done

    gmpy_cdir_initialized=0
    gmpy_cdir_cnt=0
}

gmpy_init() {
    local opts=$(getopt -l "replace-cd,help" -o "h" -- $@) || return -1
    eval set -- ${opts}
    while true
    do
        case "$1" in
            -h|--help)
                shift
                ;;
            --replace-cd)
                alias cd="cdir"
                shift
                ;;
            --)
                shift
                break
                ;;
            *)
                shift
                ;;
        esac
    done

    gmpy_cdir_prefix="gmpy_cdir"
    gmpy_cdir_initialized=0
    load_default_label

    complete -F complete_func -o dirnames "cdir" "setdir" "lsdir" "cldir" "$([ "$(type -t cd)" = "alias" ] && echo "cd")"

}

# complete_func <input>
complete_func() {
    local cmd="${1##*/}"
    local word=${COMP_WORDS[COMP_CWORD]}
    local line=${COMP_LINE}
    local labels
    local opts_cnt

    case ${cmd} in
        cldir|lsdir)
            labels=$(get_all_label)
            ;;
        setdir)
            opts_cnt=$(echo ${line} | sed -r 's/[^-][[:alpha:]]+//g' | wc -w)
            [ "$(( ${COMP_CWORD} - ${opts_cnt} ))" -eq "1" ] && labels=$(get_all_label)
            ;;
        cd|cdir)
            [ "${COMP_CWORD}" -eq "1" ] && labels=$(get_all_label)
            ;;
    esac
    COMPREPLY=($(compgen -W "${labels}" -- "${word}"))
}

# get_all_label
get_all_label() {
    for env in $(get_all_env)
    do
        echo -n "$(get_label_from_env ${env}) "
    done
}

# load_default_label
# load default label by ~/.cdir_default
load_default_label() {
    [ "${gmpy_cdir_initialized}" = "1" ] && return 0
    [ ! -f ~/.cdir_default ] && return -1

    for line in $(cat ~/.cdir_default | egrep -v "^#.*$|^$" | grep "=")
    do
         _setdir $(echo $line | sed "s/=/ /g") "no_print"
    done
    gmpy_cdir_initialized=1
}

# get_path <label|num|path>
# echo the result
get_path() {
    if [ $# -ne 1 ]; then
        return -1
    fi

    case "`check_type "$1"`" in
        "path")
            echo $1
            ;;
        "num")
            echo $(get_path_from_num $1)
            ;;
        "label")
            [ "$(check_label $1)" = "yes" ] && echo $(get_path_from_label $1) || echo $1
            ;;
    esac
}

# check_label <label>
check_label() {
    [ -n "$(echo $1 | egrep "^[[:alpha:]]([[:alnum:]]*_*[[:alnum:]]*)*$")" ] && echo yes || echo no
}

# get_path_from_num <num>
get_path_from_num() {
    local var=$(get_env_from_num $1 | head -n 1)
    [ -n "${var}" ] && echo $(get_path_from_env ${var})
}

# get_path_from_label <label>
get_path_from_label() {
    local var=$(get_env_from_label $1 | head -n 1)
    [ -n "${var}" ] && echo $(get_path_from_env ${var}) || echo $1
}

# is_exited_dir <label|num|path>
is_exited_dir() {
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
# only check the string format but not whether exist the dir
# num: only number
# path: string wiht ./ or ../ or /, sometime it can be ~ or begin with ~
# label: other else
check_type() {
    if [ $# -ne 1 ]; then
        return -1
    fi

    if $(echo $1 | egrep "^[0-9]+$" &>/dev/null); then
        echo num
        return 0
    fi

    if [ -n "$(echo $1 | egrep "\./|\.\./|/")" ] \
        || [ "${1:0:1}" = "~" ] \
        || [ "$1" = "-" ] \
        || [ "$1" = "." ] \
        || [ "$1" = ".." ]; then
        echo path
        return 0
    fi

    echo label
}

# set_env <var> <path>
set_env() {
    eval "export $1=$2"
}

# get_absolute_path <path>
get_absolute_path() {
    local pwd_path="${PWD}"
    local para_path="$1"

    # deal with word like - ~ . ..
    if [ "${para_path}" = "-" ]; then
        echo "${OLDPWD}"
        return 0
    elif [ "${para_path}" = "." ]; then
        echo "${PWD}"
        return 0
    elif [ "${para_path}" = ".." ]; then
        echo "${PWD%/*}"
        return 0
    elif [ "${para_path}" = "~" ]; then
        echo "${HOME}"
        return 0
    elif [ "${para_path:0:1}" = "~" ]; then
        para_path="${HOME}${para_path:1}"
    fi


    # deal with word like ./ ../
    while [ -n "$(echo ${para_path} | egrep "\./|\.\./")" ]
    do
        if [ "${para_path%%/*}" = ".." ]; then
            pwd_path=${pwd_path%/*}
        elif [ ! "${para_path%%/*}" = "." ]; then
            pwd_path="${pwd_path}/${para_path%%/*}"
        fi
        pwd_path="${para_path#*/}"
    done

    if [ ! "${pwd_path}" = "${PWD}" ]; then
        echo "${pwd_path}/${para_path}"
    elif [ -d ${para_path} ] && [ ! "${para_path:0:1}" = "/" ]; then
        echo ${PWD}/${para_path}
    else
        echo ${para_path}
    fi
}

# _setdir <label> <path> [no_print|global]
# $3 can be that no_print,global
_setdir() {
    #get path
    local path=$(get_absolute_path $2)

    if [ "$(is_exited_dir ${path})" = "no" ]; then
        echo -e "\033[31m$2 is not existed\033[0m"
    fi

    if [ "$(check_label $1)" = "no" ];then
        echo -en "\033[31mlabel error: \033[0m"
        echo "label start with a letter and is a combination of letters, numbers and _"
        return -1
    fi


    #get var
    local var=$(get_env_from_label $1 | head -n 1)
    if [ -n "${var}" ]; then
        echo $3 | grep -w "no_print" &>/dev/null || echo -en "\033[31mmodify:\033[0m\t"
        var=${var%%=*}
    else
        echo $3 | grep -w "no_print" &>/dev/null || echo -en "\033[31mcreate:\033[0m\t"
        add_num_cnt
        var=${gmpy_cdir_prefix}_$(get_num_cnt)_$1
    fi

    if [ -n "${path}" ] && [ -n "${var}" ]; then
        set_env ${var} ${path}
        if echo $3 | grep -w "global" &>/dev/null; then
            clear_global_dir_from_label "$1"
            set_dir_defalut "$1" "${path}"
        fi
        echo $3 | grep -w "no_print" &>/dev/null || ls_format $(get_env_from_label $1 | head -n 1)
    fi
}

# clear_global_dir_from_label <label1> <label2> ...
# enable more than one parameters
clear_global_dir_from_label() {
    local label
    for (( num=1; num<=$# ; num++ ))
    do
        label=$(eval echo \$${num})
        sed -i "/^${label}=.*$/d" ~/.cdir_default
    done
}

# set_dir_defalut <label> <path>
set_dir_defalut() {
    echo "$1=${path}" >> ~/.cdir_default
}

# _cdir <label|num|path>
_cdir() {
    if [ "`is_exited_dir "$1"`" = "yes" ]; then
        echo $1
        return 0
    fi

    echo $(get_path "$1")
}

# _lsdir [num1|label1|path1] [num2|label2|path2] ...
_lsdir() {
    if [ $# -gt 0 ]; then
        for para in $@
        do
            ls_one_dir $para
        done
    else
        ls_all_dirs
    fi
}

# ls_all_dirs
ls_all_dirs() {
    for env in $(get_all_env)
    do
        ls_format ${env}
    done
}

# get_all_env
get_all_env() {
    env | egrep "${gmpy_cdir_prefix}_[0-9]+_.*=.*$" | sort
}

get_num_cnt() {
    [ -z "${gmpy_cdir_cnt}" ] && export gmpy_cdir_cnt=0
    echo ${gmpy_cdir_cnt}
}

add_num_cnt() {
    export gmpy_cdir_cnt=$(( $(get_num_cnt) + 1 ))
}

# ls_one_dir <num|label|path>
ls_one_dir() {
    case "`check_type $1`" in
        num)
            ls_format "$(get_env_from_num $1)"
            ;;
        path)
            for env in $(get_env_from_path $(get_absolute_path $1))
            do
                ls_format ${env}
            done
            ;;
        label)  #support regular expression
            for env in $(get_env_from_label $1)
            do
                ls_format "${env}"
            done
            ;;
    esac
}

# ls_format <env>
ls_format() {
    if [ ! "${1:0:9}" = "${gmpy_cdir_prefix}" ]; then 
        return -1
    fi
    
    local num=$(get_num_from_env $1)
    local label=$(get_label_from_env $1)
    local path=$(get_path_from_env $1)

    if [ -n "${num}" ] && [ -n "${label}" ] && [ -n "${path}" ]; then
        echo -e "\033[32m${num})\t${label}\t\t${path}\033[0m"
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
# enable more than one perematers
get_label_from_env() {
    local label
    for (( num=1; num<=$# ; num++ ))
    do
        label=$(eval echo \$${num})
        label=${label#*_}
        label=${label#*_}
        label=${label#*_}
        label=${label%%=*}

        echo -n "${label} "
    done
}

# get_path_from_env <gmpy_cdir_num_label=path>
get_path_from_env() {
    echo ${1##*=}
}

# _cldir <num1|label1|path1> <num2|label2|path2> ...
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

# get_var_from_env <env>
get_var_from_env() {
   echo ${1%=*} 
}

# clear_dir_from_num <num>
clear_dir_from_num() {
    local env=$(get_env_from_num $1)
    unset $(get_var_from_env ${env}) && echo -e "\033[31mdelete:\033[0m\t$(ls_format ${env})"
}

# clear_dir_from_path <path>
clear_dir_from_path() {
    for env in $(get_env_from_path $(get_absolute_path $1))
    do
        unset $(get_var_from_env ${env}) && echo -e "\033[31mdelete:\033[0m\t$(ls_format ${env})"
    done
}

# clear_dir_from_label <label>
clear_dir_from_label() {
    for env in $(get_env_from_label $1)
    do
        unset $(get_var_from_env ${env}) && echo -e "\033[31mdelete:\033[0m\t$(ls_format ${env})"
    done
}

# get_env_from_num <num>
get_env_from_num() {
    local env=$(env | grep "^${gmpy_cdir_prefix}_$1_.*=.*$")
    [ $(echo ${env} | wc -l) -eq 1 ] && echo ${env}
}

# get_env_from_path <path>
# enable echo more than one env
get_env_from_path() {
    local env=$(env | egrep "^${gmpy_cdir_prefix}_[0-9]+_.*=$1/?$" | sort)
    [ -n "${env}" ] && echo ${env}
}

# get_env_from_label <label>
# enable echo more than one env if input regular expression
get_env_from_label() {
    local env=$(env | egrep "^${gmpy_cdir_prefix}_[0-9]+_$1=.*$" | sort)
    [ $(echo ${env} | wc -l) -eq 1 ] && echo ${env}
}

gmpy_init $@
