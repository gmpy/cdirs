#!/bin/bash

################# library #################
cdirs_set_mark() {
    cdirs_yellow "[create] "
    cdirs_ls_one "," "${PWD}"
    cdirs_mark="${PWD}"
}

cdirs_get_mark() {
    echo ${cdirs_mark}
}

cdirs_del_mark() {
    cdirs_yellow "[delete] "
    cdirs_ls_one "," "${cdirs_mark}"
    unset cdirs_mark
}

cdirs_help() {
    case "$1" in
        "cd")
            cdirs_white "Usage: cd [option]... <dir|label|${cdirs_mark_symbol}>\n"
            cdirs_white "change directory to 'dir'"
            cdirs_white " or label-dir or mark-dir '${cdirs_mark_symbol}'."
            cdirs_white " see also 'cds -h'\n\n"
            cdirs_white "[OPTIONS]\n"
            cdirs_white "  -h        :  show this message and exit\n"
            cdirs_white "  -l        :  regard as label rather than path\n"
            cdirs_white "  -g        :  cd to global label, lose sight of local label\n"
            cdirs_white "  --reset   :  reset cdirs\n"
            cdirs_white "  --reload  :  reload config and default label\n\n"
            cdirs_white "[NOTE]\n"
            cdirs_white "1. if match both dir and label, change to dir\n"
            cdirs_white "2. if match label from both local and global, change to local\n\n"
            cdirs_white "We have 3 types of label: default|global|local\n"
            cdirs_white "Only when initialize cdirs, default labels on ${cdirs_default_env}"
            cdirs_white " are loaded.\n"
            cdirs_white "Label is set to global on ${cdirs_global_env} by default"
            cdirs_white " which are shared for all bash.\n"
            cdirs_white "However, the change directory priority: local > global ,\n"
            cdirs_white "which means cdirs will change to local rather than global"
            cdirs_white " if label match both global and local.\n"
            ;;
        "cds")
            cdirs_white "Usage: cds [option]... [${cdirs_mark_symbol}] <label> [dir]\n"
            cdirs_white "sign label for dir (current dir by default) to global or local(-l)\n"
            cdirs_white "'cds ,' means mark current dir,"
            cdirs_white " and we can go back mark-dir by 'cd ,' anywhere anytime\n\n"
            cdirs_white "[OPTIONS]\n"
            cdirs_white "  -h :  show this message and exit\n"
            cdirs_white "  -g :  sign in global\n"
            cdirs_white "  -l :  sign in local\n"
            cdirs_white "  -d :  sign in default\n"
            cdirs_white "  -a :  same as '-lgd'\n\n"
            cdirs_white "[NOTE]\n"
            cdirs_white "1. if no sign directory, use current directory instead.\n"
            cdirs_white "2. sign to global by default which are shared for all bash\n\n"
            cdirs_white "We have 3 types of label: default|global|local\n"
            cdirs_white "Only when initialize cdirs, default labels on ${cdirs_default_env}"
            cdirs_white " are loaded.\n"
            cdirs_white "Label is set to global on ${cdirs_global_env} by default"
            cdirs_white " which are shared for all bash.\n"
            cdirs_white "However, the change directory priority: local > global ,\n"
            cdirs_white "which means cdirs will change to local rather than global"
            cdirs_white " if label match both global and local.\n"
            ;;
        "cdd")
            cdirs_white "Usage: cdd [option]... [${cdirs_mark_symbol}|label]\n"
            cdirs_white "delete labels of default/global/local or delete mark-dir.\n"
            cdirs_white "if no any argument, delete all glboal labels.(carefully)\n\n"
            cdirs_white "[OPTIONS]\n"
            cdirs_white "\t-h :\tshow this message and exit\n"
            cdirs_white "\t-d :\tdelete defualt\n"
            cdirs_white "\t-l :\tdelete local\n"
            cdirs_white "\t-g :\tdelete global\n"
            cdirs_white "\t-a :\tsame as '-lgd'\n\n"
            cdirs_white "[NOTE]\n"
            cdirs_white "1. if no any argument, delete all global labels. (carefully)\n\n"
            cdirs_white "We have 3 types of label: default|global|local\n"
            cdirs_white "Only when initialize cdirs, default labels on ${cdirs_default_env}"
            cdirs_white " are loaded.\n"
            cdirs_white "Label is set to global on ${cdirs_global_env} by default"
            cdirs_white " which are shared for all bash.\n"
            cdirs_white "However, the change directory priority: local > global ,\n"
            cdirs_white "which means cdirs will change to local rather than global"
            cdirs_white " if label match both global and local.\n"
            ;;
        "cdl")
            cdirs_white "Usage: cdl [option]... [${cdirs_mark_symbol}|label]\n"
            cdirs_white "list all labels of top/default/local/global of global|local\n"
            cdirs_white "'top' means labels are from local cover global\n"
            cdirs_white "'cdl ,' will list mark-dir\n\n"
            cdirs_white "[OPTIONS]\n"
            cdirs_white "\t-h :\tshow this message and exit\n"
            cdirs_white "\t-p :\tshow path only\n"
            cdirs_white "\t-d :\tshow defualt\n"
            cdirs_white "\t-l :\tshow local\n"
            cdirs_white "\t-g :\tshow global\n"
            cdirs_white "\t-a :\tsame as '-lgd'\n\n"
            cdirs_white "[NOTE]\n"
            cdirs_white "1. if no any argument, list top (local cover global),"
            cdirs_white " which can use for 'cd <label>' directly\n\n"
            cdirs_white "We have 3 types of label: default|global|local\n"
            cdirs_white "Only when initialize cdirs, default labels on ${cdirs_default_env}"
            cdirs_white " are loaded.\n"
            cdirs_white "Label is set to global on ${cdirs_global_env} by default"
            cdirs_white " which are shared for all bash.\n"
            cdirs_white "However, the change directory priority: local > global ,\n"
            cdirs_white "which means cdirs will change to local rather than global"
            cdirs_white " if label match both global and local.\n"
            ;;
        "cdf")
            cdirs_white "Usage: cdf [option]... <dir>\n"
            cdirs_white "find directly from current directory or label-dir\n\n"
            cdirs_white "[OPTIONS]\n"
            cdirs_white "\t-h :\tshow this message and exit\n"
            cdirs_white "\t-d <num>:\tfind maxdepth\n"
            cdirs_white "\t-t <label>:\tfind from label\n"
            cdirs_white "[NOTE]\n"
            cdirs_white "1. find maxdepth is ${cdirs_find_depth} by default\n"
            cdirs_white "2. find current directory by default\n"
            ;;
        "cdb")
            cdirs_white "Usage: cdb [option]... <dir|num>\n"
            cdirs_white "change directory to dir (must be back-dir).\n"
            cdirs_white "cdb is usefull if you want to go back.\n"
            cdirs_white "'back-dir' is any back dir on current directory, for example,"
            cdirs_white " current path is '/a/b/c/d',\n"
            cdirs_white "the back-dir are : a b c d\n"
            cdirs_white "'cdb 2' is same as 'cd ../..' if '2' do not match from back-dir\n\n"
            cdirs_white "[OPTIONS]\n"
            cdirs_white "\t-h :\tshow this message and exit\n"
            cdirs_white "\t-d <num> :\tregard as depth num rather than dir name\n"
            ;;
        "cdj")
            cdirs_white "Usage: cdj [option]... <dir>\n"
            cdirs_white "jump to dir which had changed to before\n\n"
            cdirs_white "[OPTIONS]\n"
            cdirs_white "\t-h :\tshow this message and exit\n"
            ;;
    esac
}

cdirs_red() {
    \echo -ne "\033[31m$@\033[0m"
}

cdirs_yellow() {
    \echo -ne "\033[33m$@\033[0m"
}

cdirs_green() {
    \echo -ne "\033[32m$@\033[0m"
}

cdirs_white() {
    \echo -ne "$@"
}

cdirs_reset() {
    rm -f ${cdirs_global_env}
    rm -f ${cdirs_local_env}
    unset cdirs_config
    unset cdirs_local_env
    unset cdirs_global_env
    unset cdirs_default_env
    unset cdirs_mark_symbol
    unset cdirs_label_symbol
    unset cdirs_find_depth
    unset cdirs_find_pre_base
    unset cdirs_find_pre_dirs
    unset cdirs_find_pre_depth
    unset cdirs_jump_list

    cdirs_init
}

cdirs_load_config() {
    [ -f "${cdirs_config}" ] && source ${cdirs_config}
}

cdirs_load_default() {
    [ -r ${cdirs_default_env} ] || return 0

    cdirs_penv="${cdirs_local_env}"
    local line label path
    while read line
    do
        \grep -q "=" <<< ${line} || continue
        cdirs_cds_do $(sed 's/=/ /g' <<< ${line})
    done <<< "$(egrep -v "^#.*$|^$" ${cdirs_default_env})"
    unset cdirs_penv
}

cdirs_get_abs_path() {
    if [ -d "$1" ]; then
        \cd "$1" &>/dev/null && pwd
    elif [ "$1" = "-" ]; then
        \echo ${OLDPWD}
    else
        \echo $1
    fi
}

cdirs_check_label() {
    local format
    format="^${cdirs_mark_symbol}[[:alpha:]]"
    format="${format}([[:alnum:]]*${cdirs_label_symbol}*)*$"
    if ! \grep -qE ${format} <<< "$1"; then
        cdirs_red "INVALID label: $1\n"
        cdirs_green "label starts with"
        cdirs_green "${cdirs_mark_symbol}letter and combinates"
        cdirs_green "with letter, number and symbol ${cdirs_label_symbol}\n"
        cdirs_green "eg. ${cdirs_mark_symbol}work"
        cdirs_green "${cdirs_mark_symbol}kernel${cdirs_label_symbol}4\n"
        return 1
    else
        return 0
    fi
}

#cdirs_set_env <label> <path>
cdirs_set_env() {
    local env
    for env in ${cdirs_penv}
    do
        \echo "$1 = $2" >> ${env}
        cdirs_yellow "[create]"
        cdirs_green "[$(\awk -F'-' '{print $2}' <<< $(basename ${env}))] "
        cdirs_ls_one "$1" "$2"
    done
}

# cdirs_del_env <label>
cdirs_del_env() {
    local env path
    for env in ${cdirs_penv}
    do
        [ -w "${env}" ] || continue
        path="$(awk "/^$1 *=/{print \$3}" ${env})"
        [ -z "${path}" ] && continue

        \sed -i "/^$1 *=/d" ${env}
        cdirs_yellow "[delete]"
        cdirs_green "[$(\awk -F'-' '{print $2}' <<< $(basename ${env}))] "
        cdirs_ls_one "$1" "${path}"
    done
}

# cdirs_del_all
cdirs_del_all() {
    local p res msg
    for p in ${cdirs_penv}
    do
        msg="Are you sure to clear all"
        msg="${msg} $(awk -F'-' '{print $2}' <<< "$(basename ${p})") labels?"
        while true
        do
            read -p "${msg} [y/n]: " res
            case "${res}" in
                y|Y)
                    [ -w "${p}" -a -x "${p}" ] && rm -f ${p}
                    break
                    ;;
                n|N)
                    break
                    ;;
                *)
                    echo
                    continue
                    ;;
            esac
        done
    done
    return 0
}

cdirs_ls_top() {
    local top line label path
    top="$(grep -w "$(sed 's# #\\\|#g' <<< $@)" ${cdirs_global_env} 2>/dev/null)"

    while read line
    do
        \grep -q "=" <<< ${line} || continue
        label="$(\awk '{print $1}' <<< ${line})"
        top="$(sed -e "/^${label}/d" <<< "${top}")"
        top="$(echo -e "${top}\n${line}")"
    done <<< "$(grep -w "$(sed 's# #\\\|#g' <<< $@)" ${cdirs_local_env})"

    while read line
    do
        \grep -q "=" <<< ${line} || continue
        cdirs_yellow "[top] "
        cdirs_ls_one $(sed 's/=/ /g' <<< ${line})
    done <<< "${top}"
}

# cdirs_get_path <label> <penv>
cdirs_get_path() {
    [ -r "$2" ] || return 1
    local path="$(\awk "\$1~/^$1$/{print \$3}" $2)"
    [ -z "${path}" ] && return 1
    eval "\\echo ${path}"
}

# cdirs_get_top <label>
cdirs_get_top() {
    [ -d "$@" ] && echo "$@" && return 0

    ! cdirs_check_label "$1" &>/dev/null && echo "$@" && return 0
    cdirs_get_path "$1" ${cdirs_local_env} && return 0
    cdirs_get_path "$1" ${cdirs_global_env} && return 0

    echo "$@"
}

cdirs_ls_one() {
    local label=$1 && shift
    local path="$(cdirs_get_abs_path "$@")"
    cdirs_white "${label} : ${path}\n"
}

cdirs_get_all_label() {
    \awk '$1!~/^,$/{print $1}' ${cdirs_local_env} 2> /dev/null
    \awk '$1!~/^,$/{print $1}' ${cdirs_global_env} 2> /dev/null
}

cdirs_fix_cd() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local fix_list

    if [ "${cur:0:2}" = "--" ]; then
        fix_list="--reload --reset"
    elif [ "${cur:0:1}" = "-" ]; then
        fix_list="-h -l -g"
    else
        fix_list="$(cdirs_get_all_label)"
    fi

    COMPREPLY=($(compgen -W "${fix_list}" -- "${cur}"))
}

cdirs_fix_cds() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local fix_list

    if [ "${cur:0:1}" = "-" ]; then
        fix_list="-h -g -d -a -l"
    else
        fix_list="$(cdirs_get_all_label)"
    fi

    COMPREPLY=($(compgen -W "${fix_list}" -- "${cur}"))
}

cdirs_fix_cdl() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local fix_list

    if [ "${cur:0:1}" = "-" ]; then
        fix_list="-h -g -d -a -l"
    else
        fix_list="$(cdirs_get_all_label)"
    fi

    COMPREPLY=($(compgen -W "${fix_list}" -- "${cur}"))
}

cdirs_fix_cdd() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local fix_list

    if [ "${cur:0:1}" = "-" ]; then
        fix_list="-h -g -d -a -l"
    else
        fix_list="$(cdirs_get_all_label)"
    fi

    COMPREPLY=($(compgen -W "${fix_list}" -- "${cur}"))
}

cdirs_fix_cdj() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local fix_list

    fix_list="$(sed 's/ /\n/g' <<< "${cdirs_jump_list[@]}" \
        | xargs -I {} basename {})"

    COMPREPLY=($(compgen -W "${fix_list}" -- "${cur}"))
}

cdirs_fix_cdb() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local fix_list

    if [ "${cur:0:1}" = "-" ]; then
        fix_list="-d"
    else
        fix_list="$(sed 's#/# #g' <<< ${PWD})"
    fi

    COMPREPLY=($(compgen -W "${fix_list}" -- "${cur}"))
}

cdirs_fix_cdf() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local pre="${COMP_WORDS[COMP_CWORD-1]}"
    local fix_list

    if [ "${cur:0:1}" = "-" ]; then
        fix_list="-h -d -t"
    elif [ "${pre}" = "-t" ]; then
        fix_list="$(cdirs_get_all_label)"
    else
        local base depth
        base="$(grep -o -- '-t[[:space:]]*[[:print:]]*' <<< ${COMP_WORDS[@]} \
            | awk '{print $2}')"
        if [ -n "${base}" ]; then
            base=`cdirs_get_path ${base} ${cdirs_local_env}`
            base="${base:-"$(cdirs_get_path ${base} ${cdirs_global_env})"}"
        fi
        base="${base:-"${PWD}"}"

        depth="$(grep -o -- '-d[[:space:]]*[[:print:]]*' <<< ${COMP_WORDS[@]} \
            | awk '{print $2}')"
        if [ -n "${depth}" ]; then
            \egrep -q "^[0-9]+$" <<< "${depth}" || unset depth
        fi
        depth="${depth:-"${cdirs_find_depth}"}"

        # save previous tag|depth for fix quickly
        if ! [ "${base}" = "${cdirs_find_pre_base}" \
            -a "${depth}" = "${cdirs_find_pre_depth}" \
            -a -n "${cdirs_find_pre_dirs}" ]; then
            cdirs_find_pre_dirs="$(\
                find -L ${base} -maxdepth ${depth} -type d 2>/dev/null \
                    | grep -Ev '/\.[[:alnum:]]+' \
                    | sed "s#${base}##" \
                    | xargs -I {} basename {})"
            cdirs_find_pre_depth="${depth}"
            cdirs_find_pre_base="${base}"
        fi
        fix_list="${cdirs_find_pre_dirs}"
    fi

    COMPREPLY=($(compgen -W "${fix_list}" -- "${cur}"))
}

# cdirs_jump <path>
cdirs_jump() {
    if \cd "$@" && cdirs_white "${PWD}\n"; then
        cdirs_jump_list=( ${PWD} \
            $(sed "s# #\n#g" <<< ${cdirs_jump_list[@]} | grep -vw "^${PWD}$"))
        return 0
    else
        # cd failed, delete
        cdirs_jump_list=( \
            $(sed "s# #\n#g" <<< ${cdirs_jump_list[@]} | grep -vw "^$1$"))
        return 1
    fi
}

# cdirs_choice
cdirs_choice() {
    local cnt=0
    local all=($@)
    local dir

    cdirs_white "Which one do you want:\n" > /dev/tty
    for dir in ${all[@]}
    do
        \echo "${cnt}: ${dir}" > /dev/tty
        cnt="$(( ${cnt} + 1 ))"
    done

    while true
    do
        read -p "Your choice [default 0]: " cnt
        [ -z "${cnt}" ] && cnt=0
        \egrep -q "^[0-9]+$" <<< "${cnt}" || {
            cdirs_red "Invaild Num: $cnt\n" > /dev/tty
            continue
        }
        [ "${cnt}" -ge "${#all[@]}" ] && {
            cdirs_red "Invaild Num: $cnt\n" > /dev/tty
            continue
        }
        echo "${all[cnt]}"
        break
    done
}

cdirs_cd_do() {
    if [ -z "$1" ]; then
        cdirs_jump
    elif [ "$1" = '-' ]; then
        cdirs_jump "${OLDPWD}"
    elif [ "$1" = "${cdirs_mark_symbol}" ]; then
        cdirs_jump "$(cdirs_get_mark)"
    elif [ -n "${cdirs_penv}" ]; then
        cdirs_jump "$(cdirs_get_path "$1" "${cdirs_penv}")"
    else
        cdirs_jump "$(cdirs_get_top "$1")"
    fi
}

#cdirs_cds_do <label> <path>
cdirs_cds_do() {
    local label=$1 && shift
    local path="$(cdirs_get_abs_path "$@")"
    [ ! -d "$(eval "\\echo ${path}")" ] \
        && cdirs_red "non-existent or directory: $@\n" \
        && return 1
    cdirs_check_label "${label}" || return 1

    cdirs_del_env "${label}" &>/dev/null
    cdirs_set_env "${label}" "${path}"
}

# cdirs_cdl_do <labels>
cdirs_cdl_do() {
    if [ -z "${cdirs_penv}" ]; then
        [ -n "$(cdirs_get_mark)" ] \
            && cdirs_yellow "[top] " \
            && cdirs_ls_one "," "$(cdirs_get_mark)"
        cdirs_ls_top $@
        return
    fi

    local p
    for p in ${cdirs_penv}
    do
        [ -r "${p}" ] || continue
        while read line
        do
            \grep -q "=" <<< ${line} || continue
            \awk -F'-' '{printf "\033[33m[%s] \033[0m", $2}' <<< $(basename ${p})
            cdirs_ls_one $(sed 's/=/ /g' <<< ${line})
        done <<< "$(grep -w "$(sed 's# #\\\|#g' <<< $@)" ${p})"
    done
}

cdirs_cdd_do() {
    [ "$#" -eq 0 ] && cdirs_del_all && return

    local label
    for label in $@
    do
        [ "${label}" = "," ] && cdirs_del_mark && continue
        cdirs_del_env "${label}"
    done
}

cdirs_cdb_do() {
    # by num with -d
    if [ -n "$2" ]; then
        [ "$2" -ge "$(grep -o '/' <<< ${PWD} | wc -l)" ] && return
        cdirs_jump $(eval "echo ${PWD} | sed -r 's#(/[^/]+){$2}\$##'")
        return
    fi

    local path cur max_cnt
    # by name - get
    if [ -n "$1" ]; then
        cur="${PWD}"
        while cur=$(grep -wo ".*/$1" <<< ${cur})
        do
            path=(${path[@]} ${cur})
            cur="$(dirname "${cur}")"
        done
        max_cnt="${#path[@]}"
    else
        cur="${PWD}"
        while [ "${cur}" != '/' ]
        do
            path=(${path[@]} ${cur})
            cur="$(dirname "${cur}")"
        done
        max_cnt="${#path[@]}"
    fi
    # by name - do
    if [ "${max_cnt}" -le 0 ]; then
        \egrep -q "^[0-9]+$" <<< "$1" || return
        [ "$1" -ge "$(grep -o '/' <<< ${PWD} | wc -l)" ] && return
        cdirs_jump $(eval "echo ${PWD} | sed -r 's#(/[[:alnum:]]+){$1}\$##'")
        return
    elif [ "${max_cnt}" -eq 1 ]; then
        cdirs_jump "${path}"
    else
        cdirs_jump "$(cdirs_choice ${path[@]})"
    fi
}

# cdirs_cdf_do <base> <depth> <dir>
cdirs_cdf_do() {
    local f_dirs f_cnt
    f_dirs=($(find -L $1 -type d -maxdepth $2 -name $3 2>/dev/null \
        | grep -Ev '/\.[[:alnum:]]+'))
    f_cnt=${#f_dirs[@]}

    if [ "${f_cnt}" -gt "1" ]; then
        cdirs_jump "$(cdirs_choice ${f_dirs[@]})"
    elif [ "${f_cnt}" -eq "1" ]; then
        cdirs_jump "${f_dirs}"
    else
        cdirs_red "Not Found: $1\n"
    fi
}

cdirs_cdj_do() {
    local match path
    for path in ${cdirs_jump_list[@]}
    do
        [ "$1" = "$(basename ${path})" ] && match=(${match[@]} ${path})
    done

    [ "${#match[@]}" -eq 0 ] && cdirs_white "Mismatch $1\n" && return
    [ "${#match[@]}" -eq 1 ] && cdirs_jump ${match[0]} && return

    cdirs_jump "$(cdirs_choice ${match[@]})"
}

cdirs_cd() {
    local opts label
    opts="$(getopt -l "reload,reset" -o "hl:g" -- $@)" || return 1
    eval set -- "${opts}"
    while true
    do
        case "$1" in
            -h)
                cdirs_help "cd"
                return 0
                ;;
            --reload)
                cdirs_load_config &>/dev/null
                cdirs_load_default
                return 0
                ;;
            --reset)
                cdirs_reset
                return 0
                ;;
            -l)
                shift
                label="$1"
                ;;
            -g)
                cdirs_penv="${cdirs_global_env}"
                ;;
            --)
                shift
                break
                ;;
        esac
        shift
    done

    label="${label:-"$@"}"

    cdirs_cd_do "${label}"

    unset cdirs_penv
}

cdirs_cds() {
    local opts
    opts="$(getopt -o "hgdla" -- $@)" || return 1
    eval set -- "${opts}"
    while true
    do
        case "$1" in
            -h)
                cdirs_help "cds"
                return 0
                ;;
            -g)
                cdirs_penv="${cdirs_penv} ${cdirs_global_env}"
                ;;
            -d)
                cdirs_penv="${cdirs_penv} ${cdirs_default_env}"
                ;;
            -l)
                cdirs_penv="${cdirs_penv} ${cdirs_local_env}"
                ;;
            -a)
                cdirs_penv="${cdirs_global_env} ${cdirs_local_env} ${cdirs_default_env}"
                ;;
            --)
                shift
                break
                ;;
        esac
        shift
    done
    [ -z "${cdirs_penv}" ] && cdirs_penv="${cdirs_global_env}"

    if [ "$#" -le 0 ]; then
        cdirs_help "cds"
    elif [ "$1" = ',' ]; then
        cdirs_set_mark
    elif [ "$#" -eq 1 ]; then
        cdirs_cds_do "$1" "${PWD}"
    else
        cdirs_cds_do "$1" "$(shift; echo $@)"
    fi

    unset cdirs_penv
}

cdirs_cdl() {
    local opts
    opts=`getopt -o "hp:gdla" -- $@` || return 1
    eval set -- "${opts}"
    while true
    do
        case "$1" in
            -h)
                cdirs_help "cdl"
                return 0
                ;;
            -p)
                shift
                [ "$1" = "," ] \
                    && cdirs_get_mark \
                    || cdirs_get_top "$1"
                return 0
                ;;
            -g)
                cdirs_penv="${cdirs_penv} ${cdirs_global_env}"
                ;;
            -d)
                cdirs_penv="${cdirs_penv} ${cdirs_default_env}"
                ;;
            -l)
                cdirs_penv="${cdirs_penv} ${cdirs_local_env}"
                ;;
            -a)
                cdirs_penv="${cdirs_global_env} ${cdirs_local_env} ${cdirs_default_env}"
                ;;
            --)
                shift
                break
                ;;
        esac
        shift
    done

    if [ "$1" = ',' ]; then
        [ -n "${cdirs_mark}" ] && cdirs_ls_one "," $(cdirs_get_mark)
    else
        #if cdirs_penv NULL, list upper
        cdirs_cdl_do $@
    fi

    unset cdirs_penv
}

cdirs_cdd() {
    local opts
    opts=`getopt -o "hglda" -- $@` || return 1
    eval set -- "${opts}"
    while true
    do
        case "$1" in
            -h)
                cdirs_help "cdd"
                return 0
                ;;
            -g)
                cdirs_penv="${cdirs_penv} ${cdirs_global_env}"
                ;;
            -d)
                cdirs_penv="${cdirs_penv} ${cdirs_default_env}"
                ;;
            -l)
                cdirs_penv="${cdirs_penv} ${cdirs_local_env}"
                ;;
            -a)
                cdirs_penv="${cdirs_global_env} ${cdirs_local_env} ${cdirs_default_env}"
                ;;
            --)
                shift
                break
                ;;
        esac
        shift
    done
    [ -z "${cdirs_penv}" ] && cdirs_penv="${cdirs_global_env}"

    cdirs_cdd_do $@

    unset cdirs_penv
}

cdirs_cdj() {
    local opts depth
    opts=`getopt -o "h" -- $@` || return 1
    eval set -- "${opts}"
    while true
    do
        case "$1" in
            -h)
                cdirs_help "cdj"
                return 0
                ;;
            --)
                shift
                break
                ;;
        esac
    done

    if [ -n "$1" ]; then
        cdirs_cdj_do $1
    else
        cdirs_jump "${PWD}"
    fi
}

cdirs_cdb() {
    local opts depth
    opts=`getopt -o "hd:" -- $@` || return 1
    eval set -- "${opts}"
    while true
    do
        case "$1" in
            -h)
                cdirs_help "cdb"
                return 0
                ;;
            -d)
                shift
                \egrep -q "^[0-9]+$" <<< "$1" || {
                    cdirs_red "-d need a num: $1\n"
                    return 1
                }
                depth="$1"
                ;;
            --)
                shift
                break
        esac
        shift
    done

    cdirs_cdb_do "$*" "${depth}"
}

cdirs_cdf() {
    local opts base depth
    opts="$(getopt -o "hd:t:" -- $@)" || return 1
    eval set -- "${opts}"
    while true
    do
        case "$1" in
            -h)
                cdirs_help "cdf"
                return 0
                ;;
            -d)
                shift
                \egrep -q "^[0-9]+$" <<< "$1" || {
                    cdirs_red "-d need a num: $1\n"
                    return 1
                }
                depth="$1"
                ;;
            -t)
                shift
                base="$(cdirs_get_top $1)"
                ;;
            --)
                shift
                break
                ;;
        esac
        shift
    done
    [ "$#" -ne 1 ] && echo "Invalid Directory" && return 1
    [ -z "${base}" ] && base="${PWD}"
    [ -z "${depth}" ] && depth="${cdirs_find_depth}"

    cdirs_cdf_do "${base}" "${depth}" "$1"

    unset cdirs_find_pre_base
    unset cdirs_find_pre_dirs
    unset cdirs_find_pre_depth
}

cdirs_clean_old() {
    local config
    for config in $(find ${cdirs_local_env%/*}/* -user ${USER})
    do
        ps $(awk -F'.' '{print $3}' <<< ${config}) &>/dev/null \
            || rm -f ${config}
    done
    rm -f ${cdirs_local_env}
}

cdirs_init() {
    mkdir -p /tmp/cdirs -m 1777

    [ -z "${cdirs_config}" ] \
        && cdirs_config="${HOME}/.cdirsrc"
    [ -z "${cdirs_local_env}" ] \
        && cdirs_local_env="/tmp/cdirs/cdirs-local-$$" \
        && cdirs_clean_old
    [ -z "${cdirs_global_env}" ] \
        && cdirs_global_env="/tmp/cdirs/cdirs-global-${USER}"
    [ -z "${cdirs_default}" ] \
        && cdirs_default_env="${HOME}/.cdirs-default"
    [ -z "${cdirs_mark_symbol}" ] \
        && cdirs_mark_symbol=','
    [ -z "${cdirs_label_symbol}" ] \
        && cdirs_label_symbol='-'
    [ -z "${cdirs_find_default_depth}" ] \
        && cdirs_find_depth=3

    cdirs_load_config &>/dev/null
    cdirs_load_default &>/dev/null

    alias cd='cdirs_cd'
    alias cds='cdirs_cds'
    alias cdl='cdirs_cdl'
    alias cdd='cdirs_cdd'
    alias cdj='cdirs_cdj'
    alias cdb='cdirs_cdb'
    alias cdf='cdirs_cdf'

    complete -F cdirs_fix_cd -o dirnames "cd"
    complete -F cdirs_fix_cds -o dirnames "cds"
    complete -F cdirs_fix_cdl "cdl"
    complete -F cdirs_fix_cdd "cdd"
    complete -F cdirs_fix_cdj "cdj"
    complete -F cdirs_fix_cdb "cdb"
    complete -F cdirs_fix_cdf "cdf"
}

cdirs_init
