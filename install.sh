#!/bin/bash

script_cdirs="cdirs.sh"

# get_abs_path <path>
get_abs_path() {
    \cd "$1" &>/dev/null && pwd
}

check_cdirs() {
    echo -n "Checking cdirs ... "

    src="`pwd`/${script_cdirs}"
    #check existed
    [ ! -f ${src} ] && {
        src="$(get_abs_path $(dirname $0))/${script_cdirs}"
        [ ! -f ${src} ] && echo NO && return 1
    }
    chmod u+x ${src}

    echo YES
}

print_help() {
    echo "Usage: ./install.sh [-h|--help] [--remove]"
}

remove() {
    [ -f ~/.bashrc ] \
        && sed -i '/set for cdirs/,/end for cdirs/d' ~/.bashrc
}

install() {
    echo -n "Install cdirs ... "

cat >> ~/.bashrc <<EOF
# == set for cdirs ==
source ${src}
# == end for cdirs ==
EOF

echo "YES"
}

main() {
    if [ "$#" -gt 1 ]; then
        print_help
        exit 0
    elif [ "$#" -eq 1 ]; then
        case "$1" in
            --remove)
                remove
                echo -e "\033[31mcdirs has unistalled, have a fun day\033[0m"
                exit 0
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

    check_cdirs || exit 1
    remove &>/dev/null
    install || exit 1

    echo -e "\033[31mcdirs has installed," \
        "please reload ~/.bashrc <source ~/.bashrc>\033[0m"
    echo -e "\033[32msee more cd|cds|cdl|cdd|cdb|cdf|cdj -h\033[0m"
}

main $@
