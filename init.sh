#!/bin/bash
# Descrptions:
#   the entry of cdir, setdir, lsdir, rmdir, whisch is to set for env functions

cdir() {
    cd `cdirs cdir $@`
}

setdir() {
    cdirs setdir $@
}

lsdir() {
    cdirs lsdir $@
}

cldir() {
    cdirs cldir $@
}
