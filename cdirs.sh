#!/bin/bash

cdir_options_list="hnlp"
lsdir_options_list="hp:"
cldir_options_list="gha"
setdir_options_list="hg"

cdir_options_list_full="reload,reset,num,label,path,help"
lsdir_options_list_full="print:,help"
cldir_options_list_full="all,reset,help,reload,global"
setdir_options_list_full="global,help"
gmpy_init_options_list_full="replace-cd,help"

cdir() {
    local force_type
    local opts="$(getopt -l "${cdir_options_list_full}" -o "${cdir_options_list}" -- $@)" || return 1
    eval set -- "${opts}"
    while true
    do
        case "$1" in
            -h|--help)
                print_help "cdir"
                return 0
                ;;
            -l|--label)
                force_type="label"
                shift
                ;;
            -n|--num)
                force_type="num"
                shift
                ;;
            -p|--path)
                force_type="path"
                shift
                ;;
            --reload)
                gmpy_cdir_initialized=0
                load_default_label
                return 0
                ;;
            --reset)
                reset
                return 0
                ;;
            --)
                shift
                break
        esac
    done

    if [ "$#" -gt "1" ]; then
        replace_cd "$*"
    elif [ "$#" -eq "0" ]; then
        replace_cd
    else
        replace_cd `_cdir "$1" "${force_type}"`
    fi
}

setdir() {
    local global_flag=0
    local opts="$(getopt -l "${setdir_options_list_full}" -o "${setdir_options_list}" -- $@)" || return 1
    eval set -- "${opts}"
    while true
    do
        case "$1" in
            -h|--help)
                print_help "setdir"
                return 0
                ;;
            -g|--global)
                global_flag=1
                shift
                ;;
            --)
                shift
                break
        esac
    done

    if [ "$#" -ne "2" ]; then
        _setdir "$1" "$(shift;echo "$*")" "$([ "${global_flag}" -eq "1" ] && echo global)"
    else
        _setdir $@ "$([ "${global_flag}" -eq "1" ] && echo global)"
    fi
}

lsdir() {
    local opts="$(getopt -l "${lsdir_options_list_full}" -o "${lsdir_options_list}" -- $@)" || return 1
    eval set -- "${opts}"
    while true
    do
        case "$1" in
            -h|--help)
                print_help "lsdir"
                return 0
                ;;
            -p|--print)
                local path="$(get_path $2)"
                echo "${path}" | grep "^.*/$" &>/dev/null && echo "${path%/*}" || echo "${path}"
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
    local opts="$(getopt -l "${cldir_options_list_full}" -o "${cldir_options_list}" -- $@)" || return 1
    local global_flag=0
    eval set -- "${opts}"
    while true
    do
        case "$1" in
            -h|--help)
                print_help "cldir"
                return 0
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
        for (( num=1; num<=$#; num++ ))
        do
            clear_global_dir "$(eval echo "\$${num}")"
        done
    fi
    _cldir $@
}

# print_help <cdir|lsdir|setdir|cldir>
print_help() {
    case "$1" in
        cdir)
            echo -e "\033[33mcdir [-h|--help] [-n|--num] [-l|--label] [-p|--path] [--reload] [--reset] <num|label|path>\033[0m"
            echo "--------------"
            echo -e "\033[32mcdir <num|label|path> :\033[0m"
            echo -e "    cd to path that pointed out by num|label|path\n"
            echo -e "\033[32mcdir [-h|--help] :\033[0m"
            echo -e "    show this introduction\n"
            echo -e "\033[32mcdir [-n|--num] <parameter> :\033[0m"
            echo -e "    describe parameter as num mandatorily\n"
            echo -e "\033[32mcdir [-l|--label] <parameter> :\033[0m"
            echo -e "    describe parameter as label mandatorily\n"
            echo -e "\033[32mcdir [-p|--path] <parameter> :\033[0m"
            echo -e "    describe parameter as path mandatorily\n"
            echo -e "\033[32mcdir [--reload] :\033[0m"
            echo -e "    reload ~/.cdir_default, which record the static label-path\n"
            echo -e "\033[32mcdir [--reset] :\033[0m"
            echo -e "    clear all label-path and reload ~/.cdir_default, which record the static label-path\n"
            echo -e "\033[31mNote: cdir is a superset of cd, so you can use it as cd too (In fact, my support for this scripts is to replace cd)\033[0m"
            ;;
        setdir)
            echo -e "\033[33msetdir [-h|--help] [-g|--global] <label> <path>\033[0m"
            echo "--------------"
            echo -e "\033[32msetdir <label> <path> :\033[0m"
            echo -e "    set label to path, after that, you can use \"cdir label\" or \"cdir num\" to go to path (the num is setted by system and you can see by command \"lsdir\""
            echo -e "    moreover, path strings is support characters like . or .. or ~ or -"
            echo -e "    eg. \"setdir work .\" or \"setdir cdirs ~/cdirs\" or \"setdir last_dir -\" or others\n"
            echo -e "\033[32msetdir [-h|--help] :\033[0m"
            echo -e "    show this introduction\n"
            echo -e "\033[32msetdir [-g|--gloabl] <label> <path> :\033[0m"
            echo -e "    set label to path, moreover, record it in ~/.cdir_default. In this way, you can set this label-path automatically everytimes you run a terminal\n"
            echo -e "\033[31mNote: label starts with a letter and is a combination of letters, character _ and number\033[0m"
            ;;
        cldir)
            echo -e "\033[33mcldir [-h|--help] [-g|--global] [-a|--all] [--reset] [--reload] <num1|label1|path1> <num2|label2|path2> ...\033[0m"
            echo "--------------"
            echo -e "\033[32mcldir <num1|label1|path1> <num2|label2|path2> ... :\033[0m"
            echo -e "    clear the label-path. if path, clear all label-path matching this path; if label, it supports regular expression\n"
            echo -e "\033[32mcldir [-h|--help] :\033[0m"
            echo -e "    show this introduction\n"
            echo -e "\033[32mcldir [-g|--gloabl] <num|label|path> :\033[0m"
            echo -e "    unset label to path, moreover, delete it in ~/.cdir_default. see also setdir -h|--hlep\n"
            echo -e "\033[32mcldir [-a|--all] :\033[0m"
            echo -e "    clear all label-path\n"
            echo -e "\033[32mcldir [--reset] :\033[0m"
            echo -e "    clear all label-path and reload ~/.cdir_default, which record the static label-path\n"
            echo -e "\033[32mcldir [--reload] :\033[0m"
            echo -e "    reload ~/.cdir_default, which record the static label-path"
            ;;
        lsdir)
            echo -e "\033[33mlsdir [-h|--help] [-p|--print <num|label|path>] <num1|label1|path1> <num2|label2|path2> ...\033[0m"
            echo "--------------"
            echo -e "\033[32mlsdir <num1|label1|path1> <num2|label2|path2> ... :\033[0m"
            echo -e "    list the label-path. if path, list all label-path matching this path; if label, it supports regular expression\n"
            echo -e "\033[32mlsdir [-h|--help] :\033[0m"
            echo -e "    show this introduction\n"
            echo -e "\033[32mlsdir [-p|--print <num|label|path>] :\033[0m"
            echo -e "    only print path of label-path, which is usefull to embedded in other commands"
            echo -e "    eg. cat \`lsdir -p cdirs\`/readme.txt => cat /home/user/cdirs/readme.txt"
            ;;
    esac
}

# clear_global_dir <num|dir|path>
clear_global_dir() {
    case "$(check_type $1)" in
        num)
            clear_global_dir_from_label "$(get_label_from_env "$(get_env_from_num "$1")")"
            ;;
        label)
            clear_global_dir_from_label "$1"
            ;;
        path)
            local path="$(get_absolute_path "$1")"
            clear_global_dir_from_label "$(get_label_from_env "$(get_env_from_path "${path}")")"
            ;;
    esac
}

# replace_cd <path>
replace_cd() {
    local alias_cd="$(alias | grep "cd=.*$" | awk '{print $2}')"
    [ -n "${alias_cd}" ] && unalias cd
    if [ "$(type -t cd)" = "builtin" ]; then
        if [ -n "$*" ]; then
            cd "$*"
        else
            cd
        fi
    fi
    [ -n "${alias_cd}" ] && eval alias "${alias_cd}"
}

# reset
# turn back to initial status
reset() {
    clear_all
    echo "-----------"
    load_default_label
}

# clear_all
clear_all() {
    local oIFS="${IFS}"
    IFS=$'\n'
    for env in $(get_all_env)
    do
        clear_dir_from_num "$(get_num_from_env "${env}")"
    done
    IFS="${oIFS}"

    gmpy_cdir_initialized=0
    gmpy_cdir_cnt=0
}

gmpy_init() {
    local opts="$(getopt -l "${gmpy_init_options_list_full}" -o "h" -- $@)" || return 1
    eval set -- "${opts}"
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
    load_default_label "no_print"

    complete -F complete_func -o dirnames "cdir" "setdir" "lsdir" "cldir" "$([ "$(type -t cd)" = "alias" ] && echo "cd")"

}

# complete_func <input>
complete_func() {
    local cmd="${1##*/}"
    local word="${COMP_WORDS[COMP_CWORD]}"
    local line="${COMP_LINE}"
    local complete_list
    local opts_cnt

    case "${cmd}" in
        cldir|lsdir)
            if [ "${word:0:2}" = "--" ]; then
                complete_list="--$(eval "echo \"\${${cmd}_options_list_full}\" | sed 's/,/ --/g' | sed 's/://g'")"
            elif [ "${word:0:1}" = "-" ] && [ ! "${word:1:2}" = '-' ]; then
                complete_list="$(eval "echo \"\${${cmd}_options_list}\" | sed 's/://g' | sed 's/[[:alpha:]]/-& /g'")"
            else
                complete_list="$(get_all_label)"
            fi
            ;;
        setdir)
            if [ "${word:0:2}" = "--" ]; then
                complete_list="--$(eval "echo \"\${${cmd}_options_list_full}\" | sed 's/,/ --/g' | sed 's/://g'")"
            elif [ "${word:0:1}" = "-" ] && [ ! "${word:1:2}" = '-' ]; then
                complete_list="$(eval "echo \"\${${cmd}_options_list}\" | sed 's/://g' | sed 's/[[:alpha:]]/-& /g'")"
            else
                opts_cnt="$(( $(echo ${line} | wc -w) - $(echo "${line}" | sed -r 's/ -[[:alpha:]]+ / /g' | wc -w) ))"
                [ "$(( ${COMP_CWORD} - ${opts_cnt} ))" -eq "1" ] && complete_list="$(get_all_label)"
            fi
            ;;
        cd|cdir)
            if [ "${word:0:2}" = "--" ]; then
                complete_list="--$(echo "${cdir_options_list_full}" | sed 's/,/ --/g' | sed 's/://g')"
            elif [ "${word:0:1}" = "-" ] && [ ! "${word:1:2}" = '-' ]; then
                complete_list="$(echo "${cdir_options_list}" | sed 's/://g' | sed 's/[[:alpha:]]/-& /g')"
            else
                case "${COMP_WORDS[$(( ${COMP_CWORD} - 1 ))]}" in
                    "-l"|"--label")
                        complete_list="$(get_all_label)"
                        ;;
                    "-n"|"--num")
                        complete_list="$(get_all_num)"
                        ;;
                    "-p"|"--path")
                        complete_list=
                        ;;
                    *)
                        opts_cnt="$(( $(echo ${line} | wc -w) - $(echo "${line}" | sed -r 's/ --?[[:alpha:]]+ / /g' | wc -w) ))"
                        [ "$(( ${COMP_CWORD} - ${opts_cnt} ))" -eq "1" ] && complete_list="$(get_all_label)"
                        ;;
                esac
            fi
            ;;
    esac
    COMPREPLY=($(compgen -W "${complete_list}" -- "${word}"))
}

# get_all_num
get_all_num() {
    local oIFS="${IFS}"
    IFS=$'\n'
    for env in $(get_all_env)
    do
        echo -n "$(get_num_from_env ${env}) "
    done
    local IFS="${oIFS}"
}

# get_all_label
get_all_label() {
    local oIFS="${IFS}"
    IFS=$'\n'
    for env in $(get_all_env)
    do
        echo -n "$(get_label_from_env ${env}) "
    done
    local IFS="${oIFS}"
}

# load_default_label [no_print]
# load default label by ~/.cdir_default
load_default_label() {
    [ "${gmpy_cdir_initialized}" = "1" ] && return 0
    [ ! -f ~/.cdir_default ] && return 2

    local oIFS="${IFS}"
    IFS=$'\n'
    for line in $(cat ~/.cdir_default | egrep -v "^#.*$|^$" | grep "=")
    do
        IFS="${oIFS}"
        _setdir "${line%%=*}" "${line##*=}" "$1"
        IFS=$'\n'
    done
    IFS="${oIFS}"
    gmpy_cdir_initialized=1
}

# get_path <label|num|path> [num|label|path](point out the type)
# echo the result
get_path() {
    local path
    case "$([ -n "$2" ] && echo "$2" || check_type "$1")" in
        "path")
            path="$1"
            ;;
        "num")
            path="$(get_path_from_num "$1")"
            ;;
        "label")
            [ "$(check_label $1)" = "yes" ] && path="$(get_path_from_label "$1")"
            ;;
    esac

    [ -n "${path}" ] && echo "${path}" || echo "$1"
}

# check_label <label>
check_label() {
    [ -n "$(echo "$1" | egrep "^[[:alpha:]]([[:alnum:]]*_*[[:alnum:]]*)*$")" ] && echo yes || echo no
}

# get_path_from_num <num>
get_path_from_num() {
    local env="$(get_env_from_num "$1" | head -n 1)"
    [ -n "${env}" ] && echo "$(get_path_from_env "${env}")"
}

# get_path_from_label <label>
get_path_from_label() {
    local env="$(get_env_from_label "$1" | head -n 1)"
    [ -n "${env}" ] && echo "$(get_path_from_env "${env}")" || echo "$1"
}

# is_exited_dir <label|num|path>
is_exited_dir() {
    case "${1}" in
        -)
            echo yes
            ;;
        *)
            [ -d "$1" ] && echo yes || echo no
            ;;
    esac
}

# check_type <label|num|path>
# only check the string format but not whether exist the dir
# num: only number
# path: string wiht ./ or ../ or /, sometime it can be ~ or begin with ~
# label: other else
check_type() {
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

    echo "label"
}

# set_env <var> <path>
set_env() {
    eval "export $1=\"$2\""
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

    # delete last letter /
    para_path=$(echo "${para_path}" | sed 's/\(.*\)\/$/\1/g')

    # deal with word like ./ ../
    while [ -n "$(echo "${para_path}" | egrep "\./|\.\./")" ]
    do
        if [ "${para_path%%/*}" = ".." ]; then
            pwd_path="${pwd_path%/*}"
        elif [ ! "${para_path%%/*}" = "." ]; then
            pwd_path="${pwd_path}/${para_path%%/*}"
        fi
        para_path="${para_path#*/}"
    done

    if [ ! "${pwd_path}" = "${PWD}" ]; then
        echo "${pwd_path}/${para_path}"
    elif [ -d "${para_path}" ] && [ ! "${para_path:0:1}" = "/" ]; then
        echo "${PWD}/${para_path}"
    else
        echo "${para_path}"
    fi
}

# _setdir <label> <path> [no_print|global]
# $3 can be that no_print,global
_setdir() {
    #get path
    local path="$(get_absolute_path "$2")"

    if [ "$(is_exited_dir "${path}")" = "no" ]; then
        echo -e "\033[31m${path} is not existed\033[0m"
        return 2
    fi

    if [ "$(check_label "$1")" = "no" ];then
        echo -en "\033[31mlabel error: \033[0m"
        echo "label starts with a letter and is a combination of letters, numbers and _"
        return 1
    fi


    #get var
    local var="$(get_env_from_label $1 | head -n 1)"
    if [ -n "${var}" ]; then
        echo "$3" | grep -w "no_print" &>/dev/null || echo -en "\033[31mmodify:\033[0m\t"
        var="${var%%=*}"
    else
        echo "$3" | grep -w "no_print" &>/dev/null || echo -en "\033[31mcreate:\033[0m\t"
        add_num_cnt
        var="${gmpy_cdir_prefix}_$(get_num_cnt)_$1"
    fi

    if [ -n "${path}" ] && [ -n "${var}" ]; then
        set_env "${var}" "${path}"
        if echo "$3" | grep -w "global" &>/dev/null; then
            clear_global_dir_from_label "$1"
            set_dir_defalut "$1" "${path}"
        fi
        echo "$3" | grep -w "no_print" &>/dev/null || ls_format "$(get_env_from_label "$1" | head -n 1)"
    fi
}

# clear_global_dir_from_label <label1> <label2> ...
# enable more than one parameters
clear_global_dir_from_label() {
    local label

    [ ! -f ~/.cdir_default ] && return 2

    for (( num=1; num<=$# ; num++ ))
    do
        label="$(eval echo \$${num})"
        sed -i "/^${label}=.*$/d" ~/.cdir_default
    done
}

# set_dir_defalut <label> <path>
set_dir_defalut() {
    echo "$1=${path}" >> ~/.cdir_default
}

# _cdir <label|num|path> [num|label|path](point out the type)
_cdir() {
    if [ -n "$2" ]; then
        echo "$(get_path "$1" "$2")"
    else
        if [ "`is_exited_dir "$1"`" = "yes" ]; then
            echo "$1"
            return 0
        fi

        echo "$(get_path "$1")"
    fi
}

# _lsdir [num1|label1|path1] [num2|label2|path2] ...
_lsdir() {
    if [ "$#" -gt 0 ]; then
        for para in $@
        do
            ls_one_dir "${para}"
        done
    else
        ls_all_dirs
    fi
}

# ls_all_dirs
ls_all_dirs() {
    local oIFS="${IFS}"
    IFS=$'\n'
    for env in $(get_all_env)
    do
        ls_format "${env}"
    done
    IFS=${oIFS}
}

# get_all_env
get_all_env() {
    env | egrep "${gmpy_cdir_prefix}_[0-9]+_.*=.*$" | sort -t '_' -n -k 3
}

get_num_cnt() {
    [ -z "${gmpy_cdir_cnt}" ] && export gmpy_cdir_cnt=0
    echo "${gmpy_cdir_cnt}"
}

add_num_cnt() {
    export gmpy_cdir_cnt="$(( $(get_num_cnt) + 1 ))"
}

# ls_one_dir <num|label|path>
ls_one_dir() {
    case "`check_type "$1"`" in
        num)
            ls_format "$(get_env_from_num "$1")"
            ;;
        path)
            local oIFS="${IFS}"
            IFS=$'\n'
            for env in $(get_env_from_path "$(get_absolute_path "$1")")
            do
                ls_format "${env}"
            done
            IFS="${oIFS}"
            ;;
        label)  #support regular expression
            local oIFS="${IFS}"
            IFS=$'\n'
            for env in $(get_env_from_label "$1")
            do
                ls_format "${env}"
            done
            IFS="${oIFS}"
            ;;
    esac
}

# ls_format <env>
ls_format() {
    if [ ! "${1:0:9}" = "${gmpy_cdir_prefix}" ]; then 
        return 1
    fi
    
    local num="$(get_num_from_env "$1")"
    local label="$(get_label_from_env "$1")"
    local path="$(get_path_from_env "$1")"

    if [ -n "${num}" ] && [ -n "${label}" ] && [ -n "${path}" ]; then
        printf '\033[32m%d)\t%-16s\t%s\033[0m\n' "${num}" "${label}" "${path}"
    fi
}

# get_num_from_env <gmpy_cdir_num_label=path>
get_num_from_env() {
    local num
    num="${1#*_}"
    num="${num#*_}"
    num="${num%%_*}"

    echo "${num}"
}

# get_label_from_env <gmpy_cdir_num_label=path>
# enable more than one perematers
get_label_from_env() {
    local label
    for (( num=1; num<=$# ; num++ ))
    do
        label="$(eval echo \$${num})"
        label="${label#*_}"
        label="${label#*_}"
        label="${label#*_}"
        label="${label%%=*}"

        echo -n "${label}"
    done
}

# get_path_from_env <gmpy_cdir_num_label=path>
get_path_from_env() {
    echo "${1##*=}"
}

# _cldir <num1|label1|path1> <num2|label2|path2> ...
_cldir() {
    if [ $# -lt 1 ]; then
        echo "Usage: cldir <num1|label1|path1> <num2|label2|path2> ..."
        return 1
    fi

    for para in $@
    do
        case "$(check_type "${para}")" in
            "num")
                clear_dir_from_num "${para}"
                ;;
            "label")
                clear_dir_from_label "${para}"
                ;;
            "path")
                clear_dir_from_path "${para}"
                ;;
        esac
    done
}

# get_var_from_env <env>
get_var_from_env() {
   echo "${1%=*}"
}

# clear_dir_from_num <num>
clear_dir_from_num() {
    local env="$(get_env_from_num "$1")"
    unset "$(get_var_from_env "${env}")" && echo -e "\033[31mdelete:\033[0m\t$(ls_format "${env}")"
}

# clear_dir_from_path <path>
clear_dir_from_path() {
    local oIFS=${IFS}
    IFS=$'\n'
    for env in $(get_env_from_path "$(get_absolute_path "$1")")
    do
        unset "$(get_var_from_env "${env}")" && echo -e "\033[31mdelete:\033[0m\t$(ls_format "${env}")"
    done
    IFS="${oIFS}"
}

# clear_dir_from_label <label>
clear_dir_from_label() {
    local oIFS="${IFS}"
    IFS=$'\n'
    for env in $(get_env_from_label "$1")
    do
        unset "$(get_var_from_env "${env}")" && echo -e "\033[31mdelete:\033[0m\t$(ls_format "${env}")"
    done
    IFS="${oIFS}"
}

# get_env_from_num <num>
get_env_from_num() {
    local env="$(env | grep "^${gmpy_cdir_prefix}_$1_.*=.*$")"
    [ "$(echo "${env}" | wc -l)" -eq "1" ] && echo "${env}"
}

# get_env_from_path <path>
# enable echo more than one env
get_env_from_path() {
    local env="$(env | egrep "^${gmpy_cdir_prefix}_[0-9]+_.*=$1/?$" | sort -t '_' -k 3 -n)"
    [ -n "${env}" ] && echo "${env}"
}

# get_env_from_label <label>
# enable echo more than one env if input regular expression
get_env_from_label() {
    local env="$(env | egrep "^${gmpy_cdir_prefix}_[0-9]+_$1=.*$" | sort -t '_' -k 3 -n)"
    [ -n "${env}" ] && echo "${env}"
}

gmpy_init $@
