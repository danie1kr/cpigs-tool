#!/bin/bash

SELF=$0
MODULES=()

CPIGS_WORKSPACE=../cpigs-tool-workspace
mkdir -p $CPIGS_WORKSPACE

function cpigs_register()
{
   local module=$1
   MODULES+=($module)
}

function cpigs_error()
{
    echo $1
    exit -1
}

function cpigs_ask()
{
    read -p "$1 [$2]: " answer
    answer=${answer:-$2}
    echo $answer
}

function cpigs_link()
{
    local pos=$1
    local title=$2
    local script=$3
    local icon=$4
    echo "linking $title on pos $pos with script $script and icon $icon"
}

MODULES_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

# todo: source all
source "$MODULES_DIR/modules/moonlight.sh"

function bootstrap()
{
    sudo apt install -y librsvg2-bin
}

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
