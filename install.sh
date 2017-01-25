#!/bin/bash

script_cdirs="cdirs.sh"

# get_absolute_path <path>
get_absolute_path() {
    echo $(echo "$(cd "$1" &>/dev/null && pwd)" | sed 's/\(.*\)\/$/\1/g')
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
    echo "Usage: ./install.sh [-h|--help] [--uninstall] [--unalias-cd]"
}

uninstall() {
    [ -f ~/.bashrc ] && sed -i '/set for cdirs/,/end for cdirs/d' ~/.bashrc
    [ -f ~/.bash_logout ] && sed -i '/set for cdirs/,/end for cdirs/d' ~/.bash_logout
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
        --unalias-cd)
            unalias_cd=1
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

uninstall
echo -n "setting cdirs to ~/.bashrc ... "
cat >> ~/.bashrc <<EOF
# == set for cdirs ==
source ${src}$([ "${unalias_cd}" = "1" ] && echo " --unalias-cd")
# == end for cdirs ==
EOF
echo "YES"

echo -n "setting cdirs to ~/.bash_logout ... "
cat >> ~/.bash_logout <<EOF
# == set for cdirs ==
[ -n "\${gmpy_cdirs_env}" ] && rm \${gmpy_cdirs_env}
# == end for cdirs ==
EOF
echo "YES"

echo -e "\033[31mcdirs has installed, please reload ~/.bashrc <source ~/.bashrc>\033[0m"
echo -e "\033[32msee more $([ -z "${not_replace_cd}" ] && echo "cd|")cdir|setdir|lsdir|cldir --help\033[0m"
