#!/bin/bash

gmpy_cdir_cdir_options_list="hnlp"
gmpy_cdir_lsdir_options_list="hp:"
gmpy_cdir_cldir_options_list="gha"
gmpy_cdir_setdir_options_list="hg"

gmpy_cdir_cdir_options_list_full="lsdir,cldir,setdir,reload,reset,num,label,path,help"
gmpy_cdir_lsdir_options_list_full="print:,help"
gmpy_cdir_cldir_options_list_full="all,reset,help,reload,global"
gmpy_cdir_setdir_options_list_full="global,help"
gmpy_cdir_init_options_list_full="replace-cd,help"

cdir() {
    local line="$@"
    if $(echo ${line} | grep "\-\-setdir" &>/dev/null && return 0 || return 1); then
        line=$(echo ${line} | sed 's/--setdir//g')
        setdir ${line}
        return 0
    elif $(echo ${line} | grep "\-\-lsdir" &>/dev/null && return 0 || return 1); then
        line=$(echo ${line} | sed 's/--lsdir//g')
        lsdir ${line}
        return 0
    elif $(echo ${line} | grep "\-\-cldir" &>/dev/null && return 0 || return 1); then
        line=$(echo ${line} | sed 's/--cldir//g')
        cldir ${line}
        return 0
    fi

    local force_type
    local opts="$(getopt -l "${gmpy_cdir_cdir_options_list_full}" -o "${gmpy_cdir_cdir_options_list}" -- $@)" || return 1
    eval set -- "${opts}"
    while true
    do
        case "$1" in
            -h|--help)
                gmpy_cdir_print_help "cdir"
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
                gmpy_cdir_load_default_label
                return 0
                ;;
            --reset)
                gmpy_cdir_reset
                return 0
                ;;
            --lsdir|--cldir|--setdir)
                return 0
                ;;
            --)
                shift
                break
        esac
    done

    if [ "$#" -gt "1" ]; then #for path with space
        gmpy_cdir_replace_cd "$*"
    elif [ "$#" -eq "0" ]; then
        gmpy_cdir_replace_cd
    elif [ "$#" -eq "1" ] && [ "$1" = "," ]; then
        local path="$(eval "echo \${${gmpy_cdir_prefix}_mark"})"
        [ -z "${path}" ] && return 0
        gmpy_cdir_replace_cd "${path}"
    else
        gmpy_cdir_replace_cd $(_cdir "$1" "${force_type}")
    fi
}

setdir() {
    local global_flag=0
    local opts="$(getopt -l "${gmpy_cdir_setdir_options_list_full}" -o "${gmpy_cdir_setdir_options_list}" -- $@)" || return 1
    eval set -- "${opts}"
    while true
    do
        case "$1" in
            -h|--help)
                gmpy_cdir_print_help "setdir"
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

    if [ "$#" -lt "2" ]; then
        if [ "$1" = ',' ]; then
            gmpy_cdir_set_mark
        else
            echo -e "\033[33msetdir [-h|--help] [-g|--global] <label> <path>\033[0m"
        fi
    elif [ "$#" -eq "2" ]; then
        _setdir $@ "$([ "${global_flag}" -eq "1" ] && echo global)"
    elif [ "$#" -gt "2" ]; then
        _setdir "$1" "$(shift;echo "$*")" "$([ "${global_flag}" -eq "1" ] && echo global)"
    fi
}

lsdir() {
    local opts="$(getopt -l "${gmpy_cdir_lsdir_options_list_full}" -o "${gmpy_cdir_lsdir_options_list}" -- $@)" || return 1
    eval set -- "${opts}"
    while true
    do
        case "$1" in
            -h|--help)
                gmpy_cdir_print_help "lsdir"
                return 0
                ;;
            -p|--print)
                local path="$(gmpy_cdir_get_path $2)"
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
    local opts="$(getopt -l "${gmpy_cdir_cldir_options_list_full}" -o "${gmpy_cdir_cldir_options_list}" -- $@)" || return 1
    local global_flag=0
    local all_flag=0
    eval set -- "${opts}"
    while true
    do
        case "$1" in
            -h|--help)
                gmpy_cdir_print_help "cldir"
                return 0
                ;;
            --reset)
                gmpy_cdir_reset
                return 0
                ;;
            --reload)
                gmpy_cdir_initialized=0
                gmpy_cdir_load_default_label
                return 0
                ;;
            -a|--all)
                shift
                all_flag=1
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

    if [ "${all_flag}" -eq "1" ]; then
        local res="n"
        while true
        do
            read -n 1 -p "Are you sure to clear all labels$([ "${global_flag}" -eq "1" ] && echo " but also global labels")? [y/n]" res
            case "${res}" in
                y|Y)
                    echo
                    break
                    ;;
                n|N)
                    echo
                    return 0
                    ;;
                *)
                    echo
                    continue
                    ;;
            esac
        done

        gmpy_cdir_clear_all $([ "${global_flag}" -eq "1" ] && echo "global")
        return 0
    fi

    if [ $# -lt 1 ]; then
        echo -e "\033[33mcldir [-h|--help] [-g|--global] [-a|--all] [--reset] [--reload] <num1|label1|path1> <num2|label2|path2> ...\033[0m"
        return 1
    fi
    _cldir $([ "${global_flag}" -eq "1" ] && echo "global" || echo "no_global") $@
}

# gmpy_cdir_set_mark
gmpy_cdir_set_mark() {
    local var="${gmpy_cdir_prefix}_mark"
    gmpy_cdir_set_env "${var}" "${PWD}"
    if [ -n "$(eval "echo \${${var}}")" ]; then
        echo -en "\033[31mcreate:\033[0m\t"
    else
        echo -en "\033[31mmodify:\033[0m\t"
    fi
    gmpy_cdir_list_mark
}

# gmpy_cdir_list_mark
gmpy_cdir_list_mark() {
    local var="${gmpy_cdir_prefix}_mark"
    local path=$(gmpy_cdir_get_path_from_env $(eval "echo \${${var}}"))
    [ -n "${path}" ] && printf '\033[32m%d)\t%-16s\t%s\033[0m\n' "0" "," "${path}"
}

# gmpy_cdir_clear_mark
gmpy_cdir_clear_mark() {
    local var="${gmpy_cdir_prefix}_mark"
    [ -n "$(eval "echo \${${var}}")" ] || return 0
    echo -en "\033[31mdelete:\033[0m\t"
    gmpy_cdir_list_mark
    unset ${var}
}

# gmpy_cdir_print_help <cdir|lsdir|setdir|cldir>
gmpy_cdir_print_help() {
    case "$1" in
        cdir)
            echo -e "\033[33mcdir [--setdir|--lsdir|--cldir] [-h|--help] [-n|--num] [-l|--label] [-p|--path] [--reload] [--reset] <num|label|path>\033[0m"
            echo -e "\033[33mcdir <,>\033[0m"
            echo "--------------"
            echo -e "\033[32mcdir <num|label|path> :\033[0m"
            echo -e "    cd to path that pointed out by num|label|path\n"
            echo -e "\033[32mcdir <,> :\033[0m"
            echo -e "    cd to special label-path, which is set by \"setdir ,\", see also \"setdir --help\"\n"
            echo -e "\033[32mcdir [--setdir|--lsdir|--cldir] <num|label|path> ... :\033[0m"
            echo -e "    the same as command \"setdir|lsdir|cldir\",see also \"setdir -h\", \"lsdir -h\", \"cldir -h\"\n"
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
            echo -e "\033[33msetdir <,>\033[0m"
            echo "--------------"
            echo -e "\033[32msetdir <label> <path> :\033[0m"
            echo -e "    set label to path, after that, you can use \"cdir label\" or \"cdir num\" to go to path (the num is setted by system and you can see by command \"lsdir\""
            echo -e "    moreover, path strings is support characters like . or .. or ~ or -"
            echo -e "    eg. \"setdir work .\" or \"setdir cdirs ~/cdirs\" or \"setdir last_dir -\" or others\n"
            echo -e "\033[32msetdir <,> :\033[0m"
            echo -e "    set current path as a special label ',' , which is usefull and quick for recording working path , you can go back fastly by \"cdir ,\"\n"
            echo -e "\033[32msetdir [-h|--help] :\033[0m"
            echo -e "    show this introduction\n"
            echo -e "\033[32msetdir [-g|--gloabl] <label> <path> :\033[0m"
            echo -e "    set label to path, moreover, record it in ~/.cdir_default. In this way, you can set this label-path automatically everytimes you run a terminal\n"
            echo -e "\033[31mNote: label starts with a letter and is a combination of letters, character _ and number\033[0m"
            ;;
        cldir)
            echo -e "\033[33mcldir [-h|--help] [-g|--global] [-a|--all] [--reset] [--reload] <num1|label1|path1|,> <num2|label2|path2|,> ...\033[0m"
            echo "--------------"
            echo -e "\033[32mcldir <num1|label1|path1> <num2|label2|path2> ... :\033[0m"
            echo -e "    clear the label-path. if path, clear all label-path matching this path; if label, it supports regular expression\n"
            echo -e "\033[32mcldir <,>:\033[0m"
            echo -e "    clear the special label-path. see also \"setdir --help\"\n"
            echo -e "\033[32mcldir [-h|--help] :\033[0m"
            echo -e "    show this introduction\n"
            echo -e "\033[32mcldir [-g|--gloabl] <num|label|path> :\033[0m"
            echo -e "    unset label to path, moreover, delete it in ~/.cdir_default. see also \"setdir -h|--hlep\"\n"
            echo -e "\033[32mcldir [-a|--all] :\033[0m"
            echo -e "    clear all label-path\n"
            echo -e "\033[32mcldir [--reset] :\033[0m"
            echo -e "    clear all label-path and reload ~/.cdir_default, which record the static label-path\n"
            echo -e "\033[32mcldir [--reload] :\033[0m"
            echo -e "    reload ~/.cdir_default, which record the static label-path"
            ;;
        lsdir)
            echo -e "\033[33mlsdir [-h|--help] [-p|--print <num|label|path>] <num1|label1|path1|,> <num2|label2|path2|,> ...\033[0m"
            echo "--------------"
            echo -e "\033[32mlsdir <num1|label1|path1> <num2|label2|path2> ... :\033[0m"
            echo -e "    list the label-path. if path, list all label-path matching this path; if label, it supports regular expression\n"
            echo -e "\033[32mlsdir <,> :\033[0m"
            echo -e "    list the special label-path. see also \"setdir --help\"\n"
            echo -e "\033[32mlsdir [-h|--help] :\033[0m"
            echo -e "    show this introduction\n"
            echo -e "\033[32mlsdir [-p|--print <num|label|path>] :\033[0m"
            echo -e "    only print path of label-path, which is usefull to embedded in other commands"
            echo -e "    eg. cat \`lsdir -p cdirs\`/readme.txt => cat /home/user/cdirs/readme.txt"
            ;;
    esac
}

# gmpy_cdir_clear_global_label <num|dir|path>
gmpy_cdir_clear_global_label() {
    case "$(gmpy_cdir_check_type $1)" in
        num)
            gmpy_cdir_clear_global_label_from_label "$(gmpy_cdir_get_label_from_env "$(gmpy_cdir_get_env_from_num "$1")")"
            ;;
        label)
            gmpy_cdir_clear_global_label_from_label "$1"
            ;;
        path)
            local path="$(gmpy_cdir_get_absolute_path "$1")"
            gmpy_cdir_clear_global_label_from_label "$(gmpy_cdir_get_label_from_env "$(gmpy_cdir_get_env_from_path "${path}")")"
            ;;
    esac
    return 0
}

# gmpy_cdir_replace_cd <path>
gmpy_cdir_replace_cd() {
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

# gmpy_cdir_reset
# turn back to initial status
gmpy_cdir_reset() {
    gmpy_cdir_clear_all
    echo "-----------"
    gmpy_cdir_load_default_label
}

# gmpy_cdir_clear_all [global]
gmpy_cdir_clear_all() {
    local oIFS="${IFS}"
    IFS=$'\n'
    for env in $(gmpy_cdir_get_all_env)
    do
        gmpy_cdir_clear_dir_from_num $([ "$1" = "global" ] && echo global || echo no_global) "$(gmpy_cdir_get_num_from_env "${env}")"
    done
    IFS="${oIFS}"

    gmpy_cdir_initialized=0
    gmpy_cdir_cnt=0
}

gmpy_cdir_init() {
    local opts="$(getopt -l "${gmpy_cdir_init_options_list_full}" -o "h" -- $@)" || return 1
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
    gmpy_cdir_load_default_label "no_print"

    complete -F gmpy_cdir_complete_func -o dirnames "cdir" "setdir" "lsdir" "cldir" "$([ "$(type -t cd)" = "alias" ] && echo "cd")"

}

# gmpy_cdir_complete_func <input>
gmpy_cdir_complete_func() {
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
                complete_list="$(gmpy_cdir_get_all_label)"
            fi
            ;;
        setdir)
            if [ "${word:0:2}" = "--" ]; then
                complete_list="--$(eval "echo \"\${${cmd}_options_list_full}\" | sed 's/,/ --/g' | sed 's/://g'")"
            elif [ "${word:0:1}" = "-" ] && [ ! "${word:1:2}" = '-' ]; then
                complete_list="$(eval "echo \"\${${cmd}_options_list}\" | sed 's/://g' | sed 's/[[:alpha:]]/-& /g'")"
            else
                opts_cnt="$(( $(echo ${line} | wc -w) - $(echo "${line}" | sed -r 's/ -[[:alpha:]]+ / /g' | wc -w) ))"
                [ "$(( ${COMP_CWORD} - ${opts_cnt} ))" -eq "1" ] && complete_list="$(gmpy_cdir_get_all_label)"
            fi
            ;;
        cd|cdir)
            if $(echo ${line} | egrep "\-\-cldir|\-\-lsdir|\-\-setdir" &>/dev/null && return 0 || return 1); then
                if $(echo ${line} | grep "\-\-setdir" &>/dev/null && return 0 || return 1); then
                    if [ "${word:0:2}" = "--" ]; then
                        complete_list="--$(echo "${gmpy_cdir_setdir_options_list_full}" | sed 's/,/ --/g' | sed 's/://g')"
                    elif [ "${word:0:1}" = "-" ] && [ ! "${word:1:2}" = '-' ]; then
                        complete_list="$(echo "${gmpy_cdir_setdir_options_list}" | sed 's/://g' | sed 's/[[:alpha:]]/-& /g')"
                    else
                        opts_cnt="$(( $(echo ${line} | wc -w) - $(echo "${line}" | sed -r 's/ -[[:alpha:]]+ / /g' | wc -w) ))"
                        [ "$(( ${COMP_CWORD} - ${opts_cnt} ))" -eq "2" ] && complete_list="$(gmpy_cdir_get_all_label)"
                    fi
                elif $(echo ${line} | grep "\-\-lsdir" &>/dev/null && return 0 || return 1); then
                    if [ "${word:0:2}" = "--" ]; then
                        complete_list="--$(echo "${gmpy_cdir_lsdir_options_list_full}" | sed 's/,/ --/g' | sed 's/://g')"
                    elif [ "${word:0:1}" = "-" ] && [ ! "${word:1:2}" = '-' ]; then
                        complete_list="$(echo "${gmpy_cdir_lsdir_options_list}" | sed 's/://g' | sed 's/[[:alpha:]]/-& /g')"
                    else
                        complete_list="$(gmpy_cdir_get_all_label)"
                    fi
                elif $(echo ${line} | grep "\-\-cldir" &>/dev/null && return 0 || return 1); then
                    if [ "${word:0:2}" = "--" ]; then
                        complete_list="--$(echo "${gmpy_cdir_cldir_options_list_full}" | sed 's/,/ --/g' | sed 's/://g')"
                    elif [ "${word:0:1}" = "-" ] && [ ! "${word:1:2}" = '-' ]; then
                        complete_list="$(echo "${gmpy_cdir_cldir_options_list}" | sed 's/://g' | sed 's/[[:alpha:]]/-& /g')"
                    else
                        complete_list="$(gmpy_cdir_get_all_label)"
                    fi
                fi
            else
                case "${COMP_WORDS[$(( ${COMP_CWORD} - 1 ))]}" in
                    "-l"|"--label")
                        complete_list="$(gmpy_cdir_get_all_label)"
                        ;;
                    "-n"|"--num")
                        complete_list="$(gmpy_cdir_get_all_num)"
                        ;;
                    "-p"|"--path")
                        complete_list=
                        ;;
                    *)
                        if [ "${word:0:2}" = "--" ]; then
                            complete_list="--$(echo "${gmpy_cdir_cdir_options_list_full}" | sed 's/,/ --/g' | sed 's/://g')"
                        elif [ "${word:0:1}" = "-" ] && [ ! "${word:1:2}" = '-' ]; then
                            complete_list="$(echo "${gmpy_cdir_cdir_options_list}" | sed 's/://g' | sed 's/[[:alpha:]]/-& /g')"
                        else
                            complete_list="$(gmpy_cdir_get_all_label)"
                        fi
                        ;;
                esac
            fi
        ;;
    esac
    COMPREPLY=($(compgen -W "${complete_list}" -- "${word}"))
}

# gmpy_cdir_get_all_num
gmpy_cdir_get_all_num() {
    local oIFS="${IFS}"
    IFS=$'\n'
    for env in $(gmpy_cdir_get_all_env)
    do
        echo -n "$(gmpy_cdir_get_num_from_env ${env}) "
    done
    local IFS="${oIFS}"
}

# gmpy_cdir_get_all_label
gmpy_cdir_get_all_label() {
    local oIFS="${IFS}"
    IFS=$'\n'
    for env in $(gmpy_cdir_get_all_env)
    do
        echo -n "$(gmpy_cdir_get_label_from_env ${env}) "
    done
    local IFS="${oIFS}"
}

# gmpy_cdir_load_default_label [no_print]
# load default label by ~/.cdir_default
gmpy_cdir_load_default_label() {
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

# gmpy_cdir_get_path <label|num|path> [num|label|path](point out the type)
# echo the result
gmpy_cdir_get_path() {
    local path
    case "$([ -n "$2" ] && echo "$2" || gmpy_cdir_check_type "$1")" in
        "path")
            path="$1"
            ;;
        "num")
            path="$(gmpy_cdir_get_path_from_num "$1")"
            ;;
        "label")
            [ "$(gmpy_cdir_check_label $1)" = "yes" ] && path="$(gmpy_cdir_get_path_from_label "$1")"
            ;;
    esac

    [ -n "${path}" ] && echo "${path}" || echo "$1"
}

# gmpy_cdir_check_label <label>
gmpy_cdir_check_label() {
    [ -n "$(echo "$1" | egrep "^[[:alpha:]]([[:alnum:]]*_*[[:alnum:]]*)*$")" ] && echo yes || echo no
}

# gmpy_cdir_get_path_from_num <num>
gmpy_cdir_get_path_from_num() {
    local env="$(gmpy_cdir_get_env_from_num "$1" | head -n 1)"
    [ -n "${env}" ] && echo "$(gmpy_cdir_get_path_from_env "${env}")"
}

# gmpy_cdir_get_path_from_label <label>
gmpy_cdir_get_path_from_label() {
    local env="$(gmpy_cdir_get_env_from_label "$1" | head -n 1)"
    [ -n "${env}" ] && echo "$(gmpy_cdir_get_path_from_env "${env}")" || echo "$1"
}

# gmpy_cdir_is_exited_dir <label|num|path>
gmpy_cdir_is_exited_dir() {
    case "${1}" in
        -)
            echo yes
            ;;
        *)
            [ -d "$1" ] && echo yes || echo no
            ;;
    esac
}

# gmpy_cdir_check_type <label|num|path>
# only check the string format but not whether exist the dir
# num: only number
# path: string wiht ./ or ../ or /, sometime it can be ~ or begin with ~
# label: other else
gmpy_cdir_check_type() {
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

# gmpy_cdir_set_env <var> <path>
gmpy_cdir_set_env() {
    eval "export $1=\"$2\""
}

# gmpy_cdir_get_absolute_path <path>
gmpy_cdir_get_absolute_path() {
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
    local path="$(gmpy_cdir_get_absolute_path "$2")"

    if [ "$(gmpy_cdir_is_exited_dir "${path}")" = "no" ]; then
        echo -e "\033[31m${path} is not existed\033[0m"
        return 2
    fi

    if [ "$(gmpy_cdir_check_label "$1")" = "no" ];then
        echo -en "\033[31mlabel error: \033[0m"
        echo "label starts with a letter and is a combination of letters, numbers and _"
        return 1
    fi


    #get var
    local var="$(gmpy_cdir_get_env_from_label $1 | head -n 1)"
    if [ -n "${var}" ]; then
        echo "$3" | grep -w "no_print" &>/dev/null || echo -en "\033[31mmodify:\033[0m\t"
        var="${var%%=*}"
    else
        echo "$3" | grep -w "no_print" &>/dev/null || echo -en "\033[31mcreate:\033[0m\t"
        gmpy_cdir_add_num_cnt
        var="${gmpy_cdir_prefix}_$(gmpy_cdir_get_num_cnt)_$1"
    fi

    if [ -n "${path}" ] && [ -n "${var}" ]; then
        if echo "$3" | grep -w "global" &>/dev/null; then
            gmpy_cdir_clear_global_label_from_label "$1"
            gmpy_cdir_set_dir_defalut "$1" "${path}"
            echo -en "\033[33m[global] \033[0m"
        fi
        gmpy_cdir_set_env "${var}" "${path}"
        echo "$3" | grep -w "no_print" &>/dev/null || gmpy_cdir_ls_format "$(gmpy_cdir_get_env_from_label "$1" | head -n 1)"
    fi
}

# gmpy_cdir_clear_global_label_from_label <label1> <label2> ...
# enable more than one parameters
gmpy_cdir_clear_global_label_from_label() {
    local label

    [ ! -f ~/.cdir_default ] && return 2

    for (( num=1; num<=$# ; num++ ))
    do
        label="$(eval echo \$${num})"
        sed -i "/^${label}=.*$/d" ~/.cdir_default
    done
}

# gmpy_cdir_set_dir_defalut <label> <path>
gmpy_cdir_set_dir_defalut() {
    echo "$1=${path}" >> ~/.cdir_default
}

# _cdir <label|num|path> [num|label|path](point out the type)
_cdir() {
    if [ -n "$2" ]; then
        echo "$(gmpy_cdir_get_path "$1" "$2")"
    else
        if [ "`gmpy_cdir_is_exited_dir "$1"`" = "yes" ]; then
            echo "$1"
            return 0
        fi

        echo "$(gmpy_cdir_get_path "$1")"
    fi
}

# _lsdir [num1|label1|path1] [num2|label2|path2] ...
_lsdir() {
    printf '\033[32m%s\t%-16s\t%s\033[0m\n' "num" "label" "path"
    printf '\033[32m%s\t%-16s\t%s\033[0m\n' "---" "-----" "----"
    if [ "$#" -gt 0 ]; then
        for para in $@
        do
            if [ "${para}" = "," ]; then
                gmpy_cdir_list_mark
            else
                gmpy_cdir_ls_one_dir "${para}"
            fi
        done
    else
        gmpy_cdir_ls_all_dirs
    fi
}

# gmpy_cdir_ls_all_dirs
gmpy_cdir_ls_all_dirs() {
    gmpy_cdir_list_mark
    local oIFS="${IFS}"
    IFS=$'\n'
    for env in $(gmpy_cdir_get_all_env)
    do
        gmpy_cdir_ls_format "${env}"
    done
    IFS=${oIFS}
}

# gmpy_cdir_get_all_env
gmpy_cdir_get_all_env() {
    env | egrep "${gmpy_cdir_prefix}_[0-9]+_.*=.*$" | sort -t '_' -n -k 3
}

gmpy_cdir_get_num_cnt() {
    [ -z "${gmpy_cdir_cnt}" ] && export gmpy_cdir_cnt=0
    echo "${gmpy_cdir_cnt}"
}

gmpy_cdir_add_num_cnt() {
    export gmpy_cdir_cnt="$(( $(gmpy_cdir_get_num_cnt) + 1 ))"
}

# gmpy_cdir_ls_one_dir <num|label|path>
gmpy_cdir_ls_one_dir() {
    case "`gmpy_cdir_check_type "$1"`" in
        num)
            gmpy_cdir_ls_format "$(gmpy_cdir_get_env_from_num "$1")"
            ;;
        path)
            local oIFS="${IFS}"
            IFS=$'\n'
            for env in $(gmpy_cdir_get_env_from_path "$(gmpy_cdir_get_absolute_path "$1")")
            do
                gmpy_cdir_ls_format "${env}"
            done
            IFS="${oIFS}"
            ;;
        label)  #support regular expression
            local oIFS="${IFS}"
            IFS=$'\n'
            for env in $(gmpy_cdir_get_env_from_label "$1")
            do
                gmpy_cdir_ls_format "${env}"
            done
            IFS="${oIFS}"
            ;;
    esac
}

# gmpy_cdir_ls_format <env>
gmpy_cdir_ls_format() {
    if [ ! "${1:0:9}" = "${gmpy_cdir_prefix}" ]; then 
        return 1
    fi
    
    local num="$(gmpy_cdir_get_num_from_env "$1")"
    local label="$(gmpy_cdir_get_label_from_env "$1")"
    local path="$(gmpy_cdir_get_path_from_env "$1")"

    if [ -n "${num}" ] && [ -n "${label}" ] && [ -n "${path}" ]; then
        printf '\033[32m%d)\t%-16s\t%s\033[0m\n' "${num}" "${label}" "${path}"
    fi
}

# gmpy_cdir_get_num_from_env <gmpy_cdir_num_label=path>
gmpy_cdir_get_num_from_env() {
    local num
    num="${1#*_}"
    num="${num#*_}"
    num="${num%%_*}"

    echo "${num}"
}

# gmpy_cdir_get_label_from_env <gmpy_cdir_num_label=path>
# enable more than one perematers
gmpy_cdir_get_label_from_env() {
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

# gmpy_cdir_get_path_from_env <gmpy_cdir_num_label=path>
gmpy_cdir_get_path_from_env() {
    echo "${1##*=}"
}

# _cldir <no_global|global> <num1|label1|path1> <num2|label2|path2> ...
_cldir() {
    local global_flag="$1"
    shift

    for para in $@
    do
        if [ "${para}" = "," ]; then
            gmpy_cdir_clear_mark
        else
            case "$(gmpy_cdir_check_type "${para}")" in
                "num")
                    gmpy_cdir_clear_dir_from_num ${global_flag} "${para}"
                    ;;
                "label")
                    gmpy_cdir_clear_dir_from_label ${global_flag} "${para}"
                    ;;
                "path")
                    gmpy_cdir_clear_dir_from_path ${global_flag} "${para}"
                    ;;
            esac
        fi
    done
}

# gmpy_cdir_get_var_from_env <env>
gmpy_cdir_get_var_from_env() {
   echo "${1%=*}"
}

# gmpy_cdir_clear_dir_from_num <global|no_global> <num>
gmpy_cdir_clear_dir_from_num() {
    local env="$(gmpy_cdir_get_env_from_num "$2")"
    local var="$(gmpy_cdir_get_var_from_env "${env}")"

    [ -n "${env}" ] && echo -ne "\033[31mdelete:\t\033[0m" || return 1
    [ "$1" = "global" ] && gmpy_cdir_clear_global_label "$(gmpy_cdir_get_label_from_env ${env})" && echo -ne "\033[33m$([ "$1" = "global" ] && echo "[global] ")\033[0m"
    unset ${var} && gmpy_cdir_ls_format "${env}"
}

# gmpy_cdir_clear_dir_from_path <global|no_global> <path>
gmpy_cdir_clear_dir_from_path() {
    local oIFS=${IFS}
    IFS=$'\n'
    for env in $(gmpy_cdir_get_env_from_path "$(gmpy_cdir_get_absolute_path "$2")")
    do
        [ -n "${env}" ] && echo -ne "\033[31mdelete:\t\033[0m" || return 1
        [ "$1" = "global" ] && gmpy_cdir_clear_global_label "$(gmpy_cdir_get_label_from_env ${env})" && echo -ne "\033[33m$([ "$1" = "global" ] && echo "[global] ")\033[0m"
        unset "$(gmpy_cdir_get_var_from_env "${env}")" && gmpy_cdir_ls_format "${env}"
    done
    IFS="${oIFS}"
}

# gmpy_cdir_clear_dir_from_label <global|no_global> <label>
gmpy_cdir_clear_dir_from_label() {
    local oIFS="${IFS}"
    IFS=$'\n'
    for env in $(gmpy_cdir_get_env_from_label "$2")
    do
        [ -n "${env}" ] && echo -ne "\033[31mdelete:\t\033[0m" || return 1
        [ "$1" = "global" ] && gmpy_cdir_clear_global_label "$(gmpy_cdir_get_label_from_env ${env})" && echo -ne "\033[33m$([ "$1" = "global" ] && echo "[global] ")\033[0m"
        unset "$(gmpy_cdir_get_var_from_env "${env}")" && gmpy_cdir_ls_format "${env}"
    done
    IFS="${oIFS}"
}

# gmpy_cdir_get_env_from_num <num>
gmpy_cdir_get_env_from_num() {
    local env="$(env | grep "^${gmpy_cdir_prefix}_$1_.*=.*$")"
    [ "$(echo "${env}" | wc -l)" -eq "1" ] && echo "${env}"
}

# gmpy_cdir_get_env_from_path <path>
# enable echo more than one env
gmpy_cdir_get_env_from_path() {
    local env="$(env | egrep "^${gmpy_cdir_prefix}_[0-9]+_.*=$1/?$" | sort -t '_' -k 3 -n)"
    [ -n "${env}" ] && echo "${env}"
}

# gmpy_cdir_get_env_from_label <label>
# enable echo more than one env if input regular expression
gmpy_cdir_get_env_from_label() {
    local env="$(env | egrep "^${gmpy_cdir_prefix}_[0-9]+_$1=.*$" | sort -t '_' -k 3 -n)"
    [ -n "${env}" ] && echo "${env}"
}

gmpy_cdir_init $@
