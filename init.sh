#!/bin/bash
# Descrptions:
#   the entry of cdir, setdir, lsdir, rmdir, whisch is to set for env functions

cdir() {
    if [ "$#" -gt "1" ]; then
        echo "Usage: cdir <num|label|path>"
        return 0
    fi
    cd `scdir cdir $@`
}

setdir() {
    source scdir setdir $@
}

lsdir() {
    scdir lsdir $@
}

cldir() {
    source scdir cldir $@
}
