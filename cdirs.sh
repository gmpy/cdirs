#!/bin/bash

# config file
gmpy_cdirs_config="~/.cdirsrc"

cdir_options_list="hn:l:p:t:d:f:"
lsdir_options_list="hp:"
cldir_options_list="gha"
setdir_options_list="hg"

cdir_options_list_full="reload,reset,num:,label:,path:,help,tag:,find:,depth:"
lsdir_options_list_full="path:,help"
cldir_options_list_full="all,reset,help"
setdir_options_list_full="global,help"
init_options_list_full="unalias-cd"

cdir() {
    local _type label_path opts tag_path fdir fdepth

    opts="$(getopt -l "${cdir_options_list_full}" -o "${cdir_options_list}" -- $@)" || return 1
    eval set -- "${opts}"
    while true
    do
        case "$1" in
            -h|--help)
                gmpy_cdirs_print_help "cdir"
                return 0
                ;;
            -l|--label)
                _type="label"
                shift
                label_path="$1"
                shift
                break
                ;;
            -n|--num)
                _type="num"
                shift
                label_path="$1"
                shift
                break
                ;;
            -p|--path)
                _type="path"
                shift
                label_path="$1"
                shift
                break
                ;;
            --reload)
                gmpy_cdirs_load_config
                gmpy_cdirs_load_global_labels
                return 0
                ;;
            --reset)
                gmpy_cdirs_reset
                return 0
                ;;
            -t|--tag)
                shift
                gmpy_cdirs_check_label_existed "$1" || {
                    echo "$1: no this tag|label"
                    return 1
                }
                tag_path="$(_cdir "$1" "label")"
                shift
                ;;
            -f|--find)
                shift
                fdir="$1"
                shift
                ;;
            -d|--depth)
                shift
                gmpy_cdirs_check_whether_num "$1" || {
                    echo "$1: -d|--depth need a num"
                    return 1
                }
                fdepth="$1"
                shift
                ;;
            --)
                shift
                break
        esac
    done

    [ -z "${label_path}" ] && label_path="$*"

    # -f|--find|-F|--Find
    if [ -n "${fdir}" ]; then
        tag_path=${tag_path:-"."}
        fdepth=${fdepth:-${gmpy_cdirs_find_default_depth}}
        gmpy_cdirs_cd_find "${fdir}" "${tag_path}" "${fdepth}"
    else
        gmpy_cdirs_builtin_cd "$(_cdir "${label_path}" "${_type}")"
    fi
}

setdir() {
    local flag opts

    flag="no_global"
    opts="$(getopt -l "${setdir_options_list_full}" -o "${setdir_options_list}" -- $@)" || return 1
    eval set -- "${opts}"
    while true
    do
        case "$1" in
            -h|--help)
                gmpy_cdirs_print_help "setdir"
                return 0
                ;;
            -g|--global)
                flag="global"
                shift
                ;;
            --)
                shift
                break
        esac
    done

    if [ "$#" -lt "2" ]; then
        if [ "$1" = ',' ]; then
            gmpy_cdirs_set_mark
        elif gmpy_cdirs_check_label $1; then
            _setdir $1 "." "${flag}"
        else
            gmpy_cdirs_print_help "setdir"
        fi
    elif [ "$#" -eq "2" ]; then
        _setdir $@ "${flag}"
    elif [ "$#" -gt "2" ]; then
        _setdir "$1" "$(shift;echo "$*")" "${flag}"
    fi
}

lsdir() {
    local opts word
    local flag="not_only_path"

    opts=`getopt -o "${lsdir_options_list}" -l "${lsdir_options_list_full}" -- $@` || return 1
    eval set -- "${opts}"
    while true
    do
        case "$1" in
            -h|--help)
                gmpy_cdirs_print_help "lsdir"
                return 0
                ;;
            -p|--path)
                flag="only_path"
                shift
                word="$1"
                shift
                ;;
            --)
                shift
                break
                ;;
        esac
    done

    [ -n "${word}" -a "${flag}" = "only_path" ] \
        && _lsdir "${flag}" "${word}" \
        || _lsdir "${flag}" $@
}

cldir() {
    local opts all_flag
    local global_flag="no_global"

    opts="$(getopt -l "${cldir_options_list_full}" -o "${cldir_options_list}" -- $@)" || return 1
    eval set -- "${opts}"
    while true
    do
        case "$1" in
            -h|--help)
                gmpy_cdirs_print_help "cldir"
                return 0
                ;;
            -a|--all)
                shift
                all_flag="all"
                ;;
            -g|--global)
                shift
                global_flag="global"
                ;;
            --)
                shift
                break
                ;;
        esac
    done

    if [ "${all_flag}" = "all" ]; then
        local res="n"
        while true
        do
            read -n 1 -p "Are you sure to clear all labels$([ "${global_flag}" = "global" ] \
                && echo " but also global labels")? [y/n] " res
            echo
            case "${res}" in
                y|Y)
                    break
                    ;;
                n|N)
                    return 0
                    ;;
                *)
                    continue
                    ;;
            esac
        done
        gmpy_cdirs_clear_all "${global_flag}"
        return 0
    fi

    if [ $# -lt 1 ]; then
        gmpy_cdirs_print_help "cldir"
        return 1
    fi
    _cldir "${global_flag}" $@
}

# _cdir <label|num|path> [num|label|path](point out the type)
_cdir() {
    [ -z "$1" ] && return 0
    [ -d "$1" -a ! "$2" = "num" -a ! "$2" = "label" ] && {
        echo "$1"
        return 0
    }
    echo "$(gmpy_cdirs_get_path "$1" "$2")"
}

# _lsdir <only_path|not_only_path> [num1|label1|path1] [num2|label2|path2] ...
_lsdir() {
    local path_flag="$1" && shift
    [ "${path_flag}" = "not_only_path" ] && {
        printf '\033[32m%s\t%-16s\t%s\033[0m\n' "num" "label" "path"
        printf '\033[32m%s\t%-16s\t%s\033[0m\n' "---" "-----" "----"
    }
    if [ "$#" -gt 0 ]; then
        for para in $@
        do
            if [ "${para}" = "," ]; then
                if [ "${path_flag}" = "not_only_path" ]; then
                    gmpy_cdirs_list_mark
                else
                    gmpy_cdirs_get_path "0" "num"
                fi
            else
                if [ "${path_flag}" = "not_only_path" ]; then
                    gmpy_cdirs_ls_one_dir "${para}"
                else
                    gmpy_cdirs_get_path "${para}"
                fi
            fi
        done
    else
        gmpy_cdirs_ls_all_dirs
    fi
}

# _setdir <label> <path> <global|no_global>
_setdir() {
    local path="$(gmpy_cdirs_get_absolute_path "$2")"
    local num

    if [ ! -d "${path}" ]; then
        echo -e "\033[31m$2 isn't existed or directory\033[0m"
        return 2
    fi

    gmpy_cdirs_check_label "$1" || {
        echo -en "\033[31mERROR: label fromat\n\033[0m"
        echo -n "label starts with "
        [ -n "${gmpy_cdirs_mark_symbol}" ] \
            && echo -n "'${gmpy_cdirs_mark_symbol}'" \
            || echo -n "letter"
        echo -n " and combinates with letter, number and symbol "
        echo "'${gmpy_cdirs_label_symbol}'"
        return 1
    }

    if gmpy_cdirs_check_label_existed "$1"; then
        echo -en "\033[31mmodify:\033[0m\t"
        num="$(gmpy_cdirs_get_num_from_label "$1")"
        gmpy_cdirs_clear_dir "$3" "$1" &>/dev/null
    else
        echo -en "\033[31mcreate:\033[0m\t"
        gmpy_cdirs_add_num_cnt
        num="$(gmpy_cdirs_get_num_cnt)"
    fi

    gmpy_cdirs_set_env "$3" "${num}" "$1" "${path}"
    gmpy_cdirs_ls_format "${num}" "$1" "${path}"
}

# _cldir <no_global|global> <num1|label1|path1> <num2|label2|path2> ...
_cldir() {
    local global_flag="$1"
    shift

    for para in $@
    do
        if [ "${para}" = "," ]; then
            gmpy_cdirs_clear_mark
        else
            gmpy_cdirs_clear_dir "${global_flag}" "${para}"
        fi
    done
}

##########################################################################################
#                                                                                        #
#   cdirs library                                                                        #
#   version: 2.000                                                                       #
#   author: gmpy                                                                         #
#   date: 2017-1-10                                                                      #
#                                                                                        #
##########################################################################################

# /tmp/cdirs/cdirs.env.$$
# <num> <label> <path>
# 3     work    /home/user/cdirs

#================ count num ================#
gmpy_cdirs_get_num_cnt() {
    [ -z "${gmpy_cdirs_cnt}" ] && export gmpy_cdirs_cnt=1
    echo "${gmpy_cdirs_cnt}"
}

gmpy_cdirs_add_num_cnt() {
    export gmpy_cdirs_cnt="$(( ${gmpy_cdirs_cnt} + 1 ))"
}

#================ mark ================#
# gmpy_cdirs_set_mark
gmpy_cdirs_set_mark() {
    [ -r "${gmpy_cdirs_env}" -a -w "${gmpy_cdirs_env}" ] || return 1
    if grep "^0 " ${gmpy_cdirs_env} &>/dev/null; then
        gmpy_cdirs_clear_dir "no_global" "0" &>/dev/null
        echo -en "\033[31mmodify:\033[0m\t"
    else
        echo -en "\033[31mcreate:\033[0m\t"
    fi
    gmpy_cdirs_set_env "no_global" "0" "," "${PWD}"
    gmpy_cdirs_list_mark
}

# gmpy_cdirs_list_mark
gmpy_cdirs_list_mark() {
    gmpy_cdirs_ls_one_dir "0"
}

# gmpy_cdirs_clear_mark
gmpy_cdirs_clear_mark() {
    gmpy_cdirs_check_label_existed "0" && {
        gmpy_cdirs_clear_dir "no_global" "0"
    }
}

#================ GET path\label\num\env ================#

# gmpy_cdirs_get_path_from_num <num>
gmpy_cdirs_get_path_from_num() {
    [ -r "${gmpy_cdirs_env}" ] \
        && eval "awk '\$1~/^$1$/{print \$3}' ${gmpy_cdirs_env}"
}

# gmpy_cdirs_get_path_from_label <label>
gmpy_cdirs_get_path_from_label() {
    [ -r "${gmpy_cdirs_env}" ] \
        && eval "awk '\$2~/^$1$/{print \$3}' ${gmpy_cdirs_env}"
}

# gmpy_cdirs_get_label_from_num <num>
gmpy_cdirs_get_label_from_num() {
    [ -r "${gmpy_cdirs_env}" ] \
        && eval "awk '\$1~/^$1$/{print \$3}' ${gmpy_cdirs_env}"
}

# gmpy_cdirs_get_num_from_label <label>
gmpy_cdirs_get_num_from_label() {
    [ -r "${gmpy_cdirs_env}" ] \
        && eval "awk '\$2~/^$1$/{print \$1}' ${gmpy_cdirs_env}"
}

# gmpy_cdirs_get_env_from_num <num>
gmpy_cdirs_get_env_from_num() {
    [ -r "${gmpy_cdirs_env}" ] \
        && eval "awk '\$1~/^$1$/{print \$1 \" \" \$2 \" \" \$3}' ${gmpy_cdirs_env}"
}

# gmpy_cdirs_get_env_from_path <path>
# allow more than one envs
gmpy_cdirs_get_env_from_path() {
    [ -r "${gmpy_cdirs_env}" ] \
        && egrep "$1/?$" ${gmpy_cdirs_env} | sort -k 1 -n | awk '{print $1 " " $2 " " $3}'
}

# gmpy_cdirs_get_env_from_label <label>
# enable echo more than one env if input regular expression
gmpy_cdirs_get_env_from_label() {
    [ -r "${gmpy_cdirs_env}" ] \
        && eval "awk '\$2~/^$1$/{print \$1 \" \" \$2 \" \" \$3}' ${gmpy_cdirs_env}" \
            | sort -k 1 -n
}

# gmpy_cdirs_get_all_num
gmpy_cdirs_get_all_num() {
    [ -r "${gmpy_cdirs_env}" ] \
        && awk '{print $1}' ${gmpy_cdirs_env}
}

# gmpy_cdirs_get_all_label
gmpy_cdirs_get_all_label() {
    [ -r "${gmpy_cdirs_env}" ] \
        && awk '($2!~/^,$/ && $1!~/^$/){print $2}' ${gmpy_cdirs_env}
}

# gmpy_cdirs_get_path <label|num|path> [num|label|path](point out the type)
gmpy_cdirs_get_path() {
    local _type
    [ -n "$2" ] && _type="$2" || _type="$(gmpy_cdirs_check_type "$1")"
    case "${_type}" in
        "num")
            echo "$(gmpy_cdirs_get_path_from_num "$1")"
            ;;
        "label")
            gmpy_cdirs_check_label_existed "$1" \
                && echo "$(gmpy_cdirs_get_path_from_label "$1")" \
                || echo "$1"
            ;;
        *)
            echo "$(gmpy_cdirs_get_absolute_path $1)"
            ;;
    esac
}

# gmpy_cdirs_get_absolute_path <path>
gmpy_cdirs_get_absolute_path() {
    echo $(echo "$(cd "$1" &>/dev/null && pwd)" | sed 's/\(.*\)\/$/\1/g')
}

#================ CHECK path\label\num ================#

# gmpy_cdirs_check_type <label|num|path>
# only check the string format but not whether exist the dir
# num: only number
# path: string wiht ./ or ../ or /, sometime it can be ~ or begin with ~
# label: others else
gmpy_cdirs_check_type() {
    if [ "$#" -ne "1" ]; then
        return 1
    fi

    if $(echo "$1" | egrep "^[0-9]+$" &>/dev/null); then
        echo "num"
        return 0
    fi

    if [ -n "$(echo "$1" | egrep "\./|\.\./|/")" ] \
        || [ "${1:0:1}" = "~" ] \
        || [ "$1" = "-" ] \
        || [ "$1" = "." ] \
        || [ "$1" = ".." ]; then
        echo "path"
        return 0
    fi

    gmpy_cdirs_check_label "$1" && echo "label" || echo "null"
}

# gmpy_cdirs_check_label <label>
gmpy_cdirs_check_label() {
    [ -n "$(echo "$1" \
        | egrep "^${gmpy_cdirs_mark_symbol}([[:alnum:]]+${gmpy_cdirs_label_symbol}*)*$")" ] \
        && return 0 || return 1
}

#gmpy_cdirs_check_label_existed <num|label>
gmpy_cdirs_check_label_existed() {
    [ -r "${gmpy_cdirs_env}" ] || return 1
    case "$(gmpy_cdirs_check_type "$1")" in
        "label")
            grep " $1 " ${gmpy_cdirs_env} &>/dev/null && return 0 || return 1
            ;;
        "num")
            grep "^$1 " ${gmpy_cdirs_env} &>/dev/null && return 0 || return 1
            ;;
        *)
            return 1
            ;;
    esac
}

#================ LIST path\label\num ================#

# gmpy_cdirs_ls_all_dirs
gmpy_cdirs_ls_all_dirs() {
    local oIFS line

    [ -r "${gmpy_cdirs_env}" ] || return 1
    oIFS="${IFS}"
    IFS=$'\n'
    for line in $(grep -v "^$" ${gmpy_cdirs_env} | sort -k 1 -n)
    do
        IFS="${oIFS}"
        gmpy_cdirs_ls_format ${line}
        IFS=$'\n'
    done
    IFS="${oIFS}"
}

# gmpy_cdirs_ls_one_dir <num|label|path>
gmpy_cdirs_ls_one_dir() {
    case "`gmpy_cdirs_check_type "$1"`" in
        num)
            gmpy_cdirs_ls_format $(gmpy_cdirs_get_env_from_num "$1")
            ;;
        path)
            local line
            while read line
            do
                gmpy_cdirs_ls_format ${line}
            done <<< "$(gmpy_cdirs_get_env_from_path "$(gmpy_cdirs_get_absolute_path $1)")"
            ;;
        *)  #support regular expression
            local line
            while read line
            do
                gmpy_cdirs_ls_format ${line}
            done <<< "$(gmpy_cdirs_get_env_from_label "$1")"
            ;;
    esac
}

# gmpy_cdirs_ls_format <num> <label> <path>
gmpy_cdirs_ls_format() {
    [ $# -ne 3 ] && return 1
    echo "$@" \
        | awk '{printf ("\033[32m%d)\t%-16s\t%s\033[0m\n",$1,$2,$3)}'
}


#================ CLEAR path\label\num ================#

# gmpy_cdirs_clear_global_label_from_label <label>
gmpy_cdirs_clear_global_label_from_label() {
    [ $# -lt 1 ] && return 1
    [ ! -f ${gmpy_cdirs_default} ] && return 2
    sed -i "/^$1 *=/d" ${gmpy_cdirs_default} && return 0 || return 1
}

# gmpy_cdirs_clear_dir <global|no_global> <num|label|path>
gmpy_cdirs_clear_dir() {
    local env num label
    case "$(gmpy_cdirs_check_type "$2")" in
        "num")
            env="$(gmpy_cdirs_get_env_from_num "$2" | head -n 1)"
            num="$2"
            label="$(echo "${env}" | awk '{print $2}')"
            ;;
        "label")
            env="$(gmpy_cdirs_get_env_from_label "$2" | head -n 1)"
            num="$(echo "${env}" | awk '{print $1}')"
            label="${2}"
            ;;
        "path")
            env="$(gmpy_cdirs_get_env_from_path "$2" | head -n 1)"
            num="$(echo "${env}" | awk '{print $1}')"
            label="$(echo "${env}" | awk '{print $2}')"
            ;;
        *)
            return 1
            ;;
    esac
    [ -z "${env}" -o -z "${num}" -o -z "${label}" ] && return 1

    echo -ne "\033[31mdelete:\t\033[0m"
    [ "$1" = "global" ] && {
        gmpy_cdirs_clear_global_label_from_label "${label}" \
            && echo -ne "\033[33m[global]\033[0m"
    }
    [ -r "${gmpy_cdirs_env}" -a -w "${gmpy_cdirs_env}" ] || return 1
    eval "sed -i '/^${num} /d' ${gmpy_cdirs_env}"
    gmpy_cdirs_ls_format ${env}
}

# gmpy_cdirs_clear_all [no_global|global]
gmpy_cdirs_clear_all() {
    [ "$1" = "global" ] && echo > ${gmpy_cdirs_default}
    [ -w "${gmpy_cdirs_env}" ] \
        && echo > ${gmpy_cdirs_env}
}

#================ SET path\label\num ================#

# gmpy_cdirs_set_global_dir <label> <path>
gmpy_cdirs_set_global_dir() {
    echo "$1 = ${path}" >> ${gmpy_cdirs_default}
}

# gmpy_cdirs_set_env <global|no_global> <num> <label> <path>
gmpy_cdirs_set_env() {
    [ "$1" = "global" ] \
        && gmpy_cdirs_set_global_dir "$3" "$4" && echo -ne "\033[33m[global]\033[0m"
    [ -w "${gmpy_cdirs_env}" ] \
        && echo "$2 $3 $4" >> ${gmpy_cdirs_env}
}

# gmpy_cdirs_reset
# Turn back to initial status
gmpy_cdirs_reset() {
    gmpy_cdirs_clear_all
    unset gmpy_cdirs_cnt
    gmpy_cdirs_load_config
    gmpy_cdirs_load_global_labels
}

#================ global dirs ================#

# gmpy_cdirs_load_global_labels
# load default label by ~/.cdir_default
gmpy_cdirs_load_global_labels() {
    eval "[ ! -f ${gmpy_cdirs_default} ] && return 2"

    local line
    local oIFS="${IFS}"
    IFS=$'\n'
    for line in $(eval "cat ${gmpy_cdirs_default}" | egrep -v "^#.*$|^$" | grep "=")
    do
        IFS="${oIFS}"
        # Enable path with variable
        _setdir $(echo ${line%%=*}) "$(eval echo ${line##*=})" "no_global"
        IFS=$'\n'
    done
    IFS="${oIFS}"
}

#================ help ================#

# gmpy_cdirs_print_help <cdir|lsdir|setdir|cldir>
gmpy_cdirs_print_help() {
    case "$1" in
        cdir)
            echo -e "\033[33mcdir [-h|--help] [--reload] [--reset] [<-n|--num> <num>] [<-l|--label|> <label>] [<-p|--path> <path>] [num|label|path]\033[0m"
            echo -e "\033[33mcdir [-t|--tag <label>] [-d|--depth <num>] -f <dir>\033[0m"
            echo -e "\033[33mcdir <,>\033[0m"
            echo "--------------"
            echo -e "\033[32mcdir [num|label|path] :\033[0m"
            echo -e "    Change directory to num-path, label-path or path."
            echo -e "    The num or label is set by <setdir>, you can get all nums and labels by <lsdir>."
            echo -e "    See also <setdir -h> and <lsdir -h>"
            echo -ne "\033[31m"
            echo -e "    Note: cdir [path] is the same as builtin cd [path]\033[0m\n"
            echo -e "\033[32mcdir [-n|--num <num>] [<-l|--label|> <label>] [<-p|--path> <path>] :\033[0m"
            echo -e "    Specify out the parameter type as num|label|path"
            echo -ne "\033[31m"
            echo -e "    Note: if there is a directory which name is the same as num|label,"
            echo -e "    cdir will go to this directory rather than num-path|label-path\033[0m\n"
            echo -e "\033[32mcdir [-t|--tag <label>] [-d|--depth <num>] -f <dir>\033[0m"
            echo -e "    Find directory from label-path specified by -t|--tag or current directory default."
            echo -e "    And the maximum depth to find is specified by -d|--depth."
            echo -e "    If get any directory matched <dir>, go to it."
            echo -ne "\033[31m"
            echo -e "    Note: <dir> can be in wildcard, see more command find\033[0m"
            echo -e "\033[32mcdir , :\033[0m"
            echo -e "    Change directory to mark-path, which is set by <setdir ,>. See also <setdir --help>\n"
            echo -e "\033[32mcdir -h|--help :\033[0m"
            echo -e "    Show this messages\n"
            echo -e "\033[32mcdir --reload :\033[0m"
            echo -e "    Reload global label-path and setting but do not clear any label-path"
            echo -e "    [ default: ~/.cdirs_default and ~/.cdirsrc ]\n"
            echo -e "\033[32mcdir --reset :\033[0m"
            echo -e "    Reload global label-path and setting but also clear any label-path"
            echo -e "    [ default: ~/.cdirs_default and ~/.cdirsrc ]\n"
            echo -ne "\033[31m"
            echo -e "    Note: cdir is a superset of cd, so you can use it like cd"
            echo -e "          (In fact, my support for cdirs is to replace cd)\033[0m"
            ;;
        setdir)
            echo -e "\033[33msetdir [-h|--help] [-g|--global] <label> <path>\033[0m"
            echo -e "\033[33msetdir <,>\033[0m"
            echo "--------------"
            echo -e "\033[32msetdir [-g|--global] label path :\033[0m"
            echo -e "    Set label-path, then, you can use \"cdir <label>\" or \"cdir <num>\" to go to path."
            echo -e "    If setdir with -g|--global, label will be also record in global label-path"
            echo -e "    [ default: ~/.cdirs_default ]"
            echo -e "    The num increase by degrees in default, and the path must be directory and existed"
            echo -e "    The label is in format:"
            echo -n "        label starts with "
                            [ -n "${gmpy_cdirs_mark_symbol}" ] \
                            && echo -n "'${gmpy_cdirs_mark_symbol}'" \
                            || echo -n "letter"
                            echo -n " and combinates with letter, number and symbol "
                            echo "'${gmpy_cdirs_label_symbol}'"
            echo -e "    Moreover, path strings is support characters like . or .. or ~ or -"
            echo -e "    Eg. \"setdir ,work .\" or \"setdir ,cdirs ~/cdirs\" or \"setdir ,last_dir -\" or others\n"
            echo -e "\033[32msetdir , :\033[0m"
            echo -e "    Set current path as mark-path, which is usefull and quick for recording working path."
            echo -e "    You can go back fastly by \"cdir ,\"\n"
            echo -e "\033[32msetdir [-h|--help] :\033[0m"
            echo -e "    Show this messages\n"
            echo -en "\033[31mNote: label starts with "
                            [ -n "${gmpy_cdirs_mark_symbol}" ] \
                            && echo -n "'${gmpy_cdirs_mark_symbol}'" \
                            || echo -n "letter"
                            echo -n " and combinates with letter, number and symbol "
                            echo "'${gmpy_cdirs_label_symbol}'\033[0m"
            ;;
        cldir)
            echo -e "\033[33mcldir [-h|--help] [-g|--global] [-a|--all] <num1|label1|path1> <num2|label2|path2> ...\033[0m"
            echo -e "\033[33mcldir <,>\033[0m"
            echo "--------------"
            echo -e "\033[32mcldir [-g|--global] <num1|label1|path1> <num2|label2|path2> ... :\033[0m"
            echo -e "    Clear label-path. If path, clear all label-path matching this path"
            echo -e "    If -g|--global existed, also clear global label-path [ defualt: ~/.cdirs_default ]\n"
            echo -e "\033[32mcldir , :\033[0m"
            echo -e "    Clear the mark-path. see also \"setdir --help\"\n"
            echo -e "\033[32mcldir -h|--help :\033[0m"
            echo -e "    Show this messages\n"
            echo -e "\033[32mcldir [-g|--global] -a|--all :\033[0m"
            echo -e "    Clear all label-path"
            echo -e "    If -g|--global existed, clear all global label-path [ defualt: ~/.cdirs_default ]\n"
            ;;
        lsdir)
            echo -e "\033[33mlsdir [-h|--help] [-p|--path <num|label|path>] <num1|label1|path1> <num2|label2|path2> ...\033[0m"
            echo -e "\033[33mlsdir <,>\033[0m"
            echo "--------------"
            echo -e "\033[32mlsdir <num1|label1|path1> <num2|label2|path2> ... :\033[0m"
            echo -e "    List the label-path. if path, list all label-path matching this path\n"
            echo -e "\033[32mlsdir <,> :\033[0m"
            echo -e "    List the mark-path. see also \"setdir --help\"\n"
            echo -e "\033[32mlsdir [-h|--help] :\033[0m"
            echo -e "    Show this messages\n"
            echo -e "\033[32mlsdir [-p|--path <num|label|path>] :\033[0m"
            echo -e "    Only print path of label-path, which is usefull to embedded in other commands"
            echo -e "    Eg. cat \`lsdir -p cdirs\`/readme.txt => cat /home/user/cdirs/readme.txt"
            ;;
    esac
}

#================ basical ================#

#gmpy_cdirs_load_config
gmpy_cdirs_load_config() {
    eval "[ -f "${gmpy_cdirs_config}" ] && source ${gmpy_cdirs_config}"
}

# gmpy_cdirs_builtin_cd <path>
gmpy_cdirs_builtin_cd() {
    echo $1 | grep " " &>/dev/null \
        && builtin cd "$*" \
        || builtin cd $@
}

gmpy_cdirs_init() {
    local alias_cd=1
    local opts="$(getopt -l "${init_options_list_full}" -o "h" -- $@)" || return 1
    eval set -- "${opts}"
    while true
    do
        case "$1" in
            --unalias-cd)
                alias_cd=0
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

    [ "${alias_cd}" -eq "1" ] && alias cd='cdir'

    gmpy_cdirs_load_config
    gmpy_cdirs_env="/tmp/cdirs/cdirs.env.$$" \
        && mkdir -p /tmp/cdirs -m 1777\
        && touch ${gmpy_cdirs_env}
    [ -z "${gmpy_cdirs_default}" ] \
        && gmpy_cdirs_default="${HOME}/.cdirs_default"
    [ -z "${gmpy_cdirs_mark_symbol}" ] \
        && gmpy_cdirs_mark_symbol=','
    [ -z "${gmpy_cdirs_label_symbol}" ] \
        && gmpy_cdirs_label_symbol='-'
    [ -z "${gmpy_cdirs_find_default_depth}" ] \
        && gmpy_cdirs_find_default_depth=2
    gmpy_cdirs_load_global_labels &>/dev/null

    complete -F gmpy_cdirs_complete_func -o dirnames \
        "setdir" "lsdir" "cldir" "cdir" \
        "$([ "${alias_cd}" -eq "1" ] && echo "cd")"

}

#================ completation ================#

# gmpy_cdirs_complete_func <input>
gmpy_cdirs_complete_func() {
    local cmd="$1"
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local pre="${COMP_WORDS[COMP_CWORD-1]}"
    local line="${COMP_LINE}"
    local complete_list

    case "${cmd}" in
        cldir|lsdir)
            if [ "${cur:0:2}" = "--" ]; then
                complete_list="--$(eval "echo \"\${${cmd}_options_list_full}\" | sed 's/,/ --/g' | sed 's/://g'")"
            elif [ "${cur:0:1}" = "-" ]; then
                complete_list="$(eval "echo \"\${${cmd}_options_list}\" | sed 's/://g' | sed 's/[[:alpha:]]/-& /g'")"
            else
                complete_list="$(gmpy_cdirs_get_all_label)"
            fi
            ;;
        setdir)
            if [ "${cur:0:2}" = "--" ]; then
                complete_list="--$(echo "${setdir_options_list_full}" | sed 's/,/ --/g' | sed 's/://g')"
            elif [ "${cur:0:1}" = "-" ]; then
                complete_list="$(echo "${setdir_options_list}" | sed 's/://g' | sed 's/[[:alpha:]]/-& /g')"
            else
                local opts_cnt="$(( $(echo ${line} | wc -w) - $(echo "${line}" | sed -r 's/ -[[:alpha:]]+ / /g' | wc -w) ))"
                [ $(( ${COMP_CWORD} - ${opts_cnt} )) -eq 1 ] && complete_list="$(gmpy_cdirs_get_all_label)"
            fi
            ;;
        cd|cdir)
            case "${pre}" in
                "-l"|"--label")
                    complete_list="$(gmpy_cdirs_get_all_label)"
                    ;;
                "-n"|"--num")
                    complete_list="$(gmpy_cdirs_get_all_num)"
                    ;;
                "-p"|"--path")
                    complete_list=
                    ;;
                "-t"|"--tag")
                    complete_list="$(gmpy_cdirs_get_all_label)"
                    ;;
                "-d"|"--depth")
                    complete_list=
                    ;;
                "-f"|"--find")
                    local tag_path opt cnt fdepth

                    # get tag
                    cnt=0
                    for opt in ${COMP_WORDS[@]}
                    do
                        cnt=$(( ${cnt} + 1 ))
                        [ "${opt}" = "-t" \
                            -o "${opt}" = "--tag" ] && break
                    done
                    tag_path="$(_cdir "${COMP_WORDS[cnt]:-"."}" "label")"

                    # get depth
                    cnt=0
                    for opt in ${COMP_WORDS[@]}
                    do
                        cnt=$(( ${cnt} + 1 ))
                        [ "${opt}" = "-d" \
                            -o "${opt}" = "--depth" ] && break
                    done
                    fdepth="${COMP_WORDS[cnt]:-${gmpy_cdirs_find_default_depth}}"

                    # save previous tag_path|depth|dirs for complete quick
                    [ "${tag_path}" = "${gmpy_cdirs_previous_tag}" \
                        -a "${fdepth}" = "${gmpy_cdirs_previous_depth}" \
                        -a -n "${gmpy_cdirs_previous_dirs}" ] \
                        && complete_list="${gmpy_cdirs_previous_dirs}" \
                        || {
                            complete_list="$(gmpy_cdirs_get_dirs_name "${tag_path}" "${fdepth}")"
                            gmpy_cdirs_previous_depth="${fdepth}"
                            gmpy_cdirs_previous_tag="${tag_path}"
                            gmpy_cdirs_previous_dirs="${complete_list}"
                        }
                    ;;
                *)
                    if [ "${cur:0:2}" = "--" ]; then
                        complete_list="--$(echo "${cdir_options_list_full}" | sed 's/,/ --/g' | sed 's/://g')"
                    elif [ "${cur:0:1}" = "-" ]; then
                        complete_list="$(echo "${cdir_options_list}" | sed 's/://g' | sed 's/[[:alpha:]]/-& /g')"
                    elif [ -n "${gmpy_cdirs_mark_symbol}" -a "${cur:0:1}" = "${gmpy_cdirs_mark_symbol}" ]; then
                        complete_list="$(gmpy_cdirs_get_all_label)"
                    elif [ -z "${gmpy_cdirs_mark_symbol}" ]; then
                        complete_list="$(gmpy_cdirs_get_all_label)"
                    fi
                    ;;
            esac
        ;;
    esac
    COMPREPLY=($(compgen -W "${complete_list}" -- "${cur}"))
}

#================ find dir ================#

#gmpy_cdirs_find_dirs <dir> <tag_path> <maxdepth>
gmpy_cdirs_find_dirs() {
    local cmd
    cmd="find $2 -maxdepth $3 -name \"${1}\" -type d 2>/dev/null"
    echo $(eval "${cmd}")
}

#gmpy_cdirs_get_dirs_name <tag_path> <find_depth>
gmpy_cdirs_get_dirs_name() {
    local cmd
    cmd="find $1 -maxdepth $2 -type d 2>/dev/null | xargs -I {} basename {}"
    echo $(eval "${cmd}")
}

#gmpy_cdirs_cd_find <dirname> <tag_path> <find_depth>
gmpy_cdirs_cd_find() {
    local f_result f_cnt
    [ -d "$2" ] || {
        echo "$2: Not existed or directory"
        return 1
    }
    gmpy_cdirs_check_whether_num "$3" || {
        echo "$3: Not num for depth"
        return 1
    }
    f_result=($(gmpy_cdirs_find_dirs "$1" "$2" "$3"))
    f_cnt=${#f_result[@]}

    if [ "${f_cnt}" -gt "1" ]; then
        local cnt=0
        local result
        echo "Which one do you want:"
        for result in ${f_result[@]}
        do
            echo "${cnt}: ${result}"
            cnt="$(( ${cnt} + 1 ))"
        done
        while true
        do
            read -p "Your choice: " cnt
            gmpy_cdirs_check_whether_num "${cnt}" || {
                echo -e "\033[31m${cnt}: Invaild Input - Not Num\033[0m"
                continue
            }
            [ "${cnt}" -ge "${f_cnt}" ] && {
                echo -e "\033[31m${cnt}: Invaild Input - Error Num\033[0m"
                continue
            }
            echo -e "\033[32m${f_result[cnt]}\033[0m"
            gmpy_cdirs_builtin_cd "${f_result[cnt]}"
            break
        done
    elif [ "${f_cnt}" -eq "1" ]; then
        echo -e "\033[32m${f_result}\033[0m"
        gmpy_cdirs_builtin_cd "${f_result}"
    else
        echo -e "\033[31mCan't find $1\033[0m"
    fi
    # for complete quick
    unset gmpy_cdirs_previous_depth
    unset gmpy_cdirs_previous_tag
    unset gmpy_cdirs_previous_dirs
}

#gmpy_cdirs_check_whether_num <num>
gmpy_cdirs_check_whether_num() {
    echo "$1" | egrep "^[[:digit:]]+$" &>/dev/null
}

gmpy_cdirs_init $@
