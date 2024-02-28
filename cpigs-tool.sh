#!/bin/bash

SELF=$0
MODULES=()

function register()
{
   local module=$1
   MODULES+=($module)
}


MODULES_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

# todo: source all
source "$MODULES_DIR/modules/moonlight.sh"

function help()
{
    echo "usage: $0 [options] module ..."
    echo "options:"
    echo "--help: this text"
    echo "--list: list all known modules"
}

function list()
{
    echo "registered modules"
    for module in "${MODULES[@]}"
    do
        local name="$module"
        local text=`$module text`
        echo "$name: $text"
    done
}

function call()
{
    local module=$1
    shift 1 
    echo "calling $module with $@"
    $module "$@"
}

while [ "$#" -gt 0 ]; do
    case "$1" in
      --help)
         help
         exit 0
        ;;
      --list)
        list
        exit 0
        ;;
      *)
        module=$1
        shift 1
        call $module "$@" 
        exit 0
        ;;
    esac
done
