#!/bin/bash

script_cdirs="cdirs.sh"

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

check_cdirs() {
    src="`pwd`/${script_cdirs}"
    #check existed
    [ ! -f ${src} ] && {
        src="$(get_absolute_path $(dirname $0))/${script_cdirs}"
        [ ! -f ${src} ] && {
            return 1
        }
    }
    chmod u+x ${src}
    return 0
}

print_help() {
    echo "Usage: ./install.sh [-h|--help] [--uninstall] [--unreplace-cd]"
}

uninstall() {
    [ -f ~/.bashrc ] && sed -i '/set for cdir/,/end for cdir/d' ~/.bashrc
}

if [ "$#" -gt 1 ]; then
    print_help
    exit 1
elif [ "$#" -eq 1 ]; then
    case "$1" in
        --uninstall)
            uninstall
            echo -e "\033[31mcdirs has unistalled, have a fun day\033[0m"
            exit 0
            ;;
        --unreplace-cd)
            not_replace_cd=1
            [ -f ~/.bashrc ] && sed -i '/set for cdir/,/end for cdir/d' ~/.bashrc
            shift
            ;;
        --help|-h)
            print_help
            exit 0
            ;;
        *)
            print_help
            exit 1
            ;;
    esac
fi



echo -n "finding cdirs.sh ... "
check_cdirs && echo YES || {
    echo NO
    echo -e "\033[31mcan not find cdirs.sh\033[0m"
    exit 1
}

echo -n "setting cdirs to ~/.bashrc ... "
uninstall
cat >> ~/.bashrc <<EOF
# == set for cdir ==
[ "\$(type -t cd)" = "alias" ] && unalias cd
wait
source ${src} $([ -z "${not_replace_cd}" ] && echo "--replace-cd")
# == end for cdir ==
EOF
echo "YES"

echo -e "\033[31mcdirs has installed, please re-open bash\033[0m"
echo -e "\033[32msee more $([ -z "${not_replace_cd}" ] && echo "cd|")cdir|setdir|lsdir|cldir --help\033[0m"
