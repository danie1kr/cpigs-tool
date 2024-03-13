#!/bin/bash

SELF=$0
MODULES=()

CPIGS_DIR=`dirname "$0"`
CPIGS_WORKSPACE=$CPIGS_DIR/../cpigs-tool-workspace
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
    if ! [[ $PWD/ = /home/cpi/apps/Menu/* ]]; then
        echo "Please run inside /home/cpi/apps/Menu"
        exit -1
    fi

    local pos=$1
    local title=$2
    local script=$3
    local icon=$4
#    echo "linking $title on pos $pos with script $script and icon $icon"

    local scriptFile="${PWD}/$1_$2.sh"
    local subPath="${PWD#/home/cpi/apps/Menu}"
    local iconFile="/home/cpi/launchergo/skin/default/Menu/GameShell${subPath}/$2.png"

#    echo $scriptFile
#    echo $subPath
#    echo $iconFile

    cp "${script}" "${scriptFile}"
    cp "${icon}" "${iconFile}"
    chmod +x "${scriptFile}"

    echo "Restart LauncherGo to see change"
}

for module in $CPIGS_DIR/modules/*.sh; do
    source $module
done

function bootstrap()
{
    sudo apt install -y librsvg2-bin jq
}

function help()
{
    echo "usage: $0 [options] module ..."
    echo "options:"
    echo "--bootstrap: install dependencies"
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

# banner
echo \
" __ __   __  __    ___         
/  |__)|/ _ (_  __  | _  _ | _ 
\__|   |\\__)__)     |(_)(_)|_) v$(git -C ${CPIGS_DIR} rev-parse --short HEAD) $(git -C ${CPIGS_DIR} log -1 --format=\"%at\" | xargs -I{} date -d @{} +%Y/%m/%d-%H:%M:%S)
https://github.com/danie1kr/cpigs-tool
"

# setup
mkdir -p /tmp/cpigs

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
      --bootstrap)
        bootstrap
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
