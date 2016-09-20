#!/bin/bash
# Descrptions:
#   the entry of cdir, setdir, lsdir, rmdir, whisch is to set for env functions

cdir() {
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
