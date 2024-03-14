#!/bin/bash

CPIGS_WORKSPACE_MOONLIGHT=$CPIGS_WORKSPACE/moonlight
mkdir -p $CPIGS_WORKSPACE_MOONLIGHT

function moonlight_install()
{
    pushd .
    cd $CPIGS_WORKSPACE_MOONLIGHT

    curl -1sLf 'https://dl.cloudsmith.io/public/moonlight-game-streaming/moonlight-qt/setup.deb.sh' | sudo -E bash
    sudo apt install -y moonlight-qt 

    wget 'https://raw.githubusercontent.com/moonlight-stream/moonlight-qt/master/app/res/moonlight.svg'

    rsvg-convert -w 256 -h 256 moonlight.svg -o moonlight.png

    touch installed

    popd
}

function moonlight_update()
{
    if ! [ -f $CPIGS_WORKSPACE_MOONLIGHT/installed ]; then
        cpigs_error "Please install first"
        return -1
    fi
    
    sudo apt update
    sudo apt install --only-upgrade -y moonlight-qt
}

function moonlight_link()
{
    if ! [ -f $CPIGS_WORKSPACE_MOONLIGHT/installed ]; then
        cpigs_error "Please install first"
        return -1
    fi

    local host=`cpigs_ask "Moonlight Host" ""`

    printf "\nSelect an application on ${host}:\n"
    local apps=()
    mapfile -t apps < <(DISPLAY=:0 moonlight-qt list ${host})
    local idx=0
    for app in "${apps[@]}"; do
        printf "[%2d] %s\n" "$idx" "$app"
        ((idx++))
    done
    if [ $idx == 0 ]; then printf "no apps found on host ${host}\n"; return 0; fi

    local appIdx=`cpigs_ask "Application id"`
    if ! [ "${apps[$appIdx]+abc}" ]; then printf "invalid index\n"; return 0; fi
    local app="${apps[$appIdx]}"
    local options=`cpigs_ask "Additional options" "--resolution 320x240 --bitrate 800"`

    printf "\nConfigure Launcher Item for ${app} on ${host}:\n"
    local pos=`cpigs_ask "Launcher Item Position" "20"`
    local title=`cpigs_ask "Launcher Item Title" "moonlight"`

    local script="/tmp/cpigs/script"
    echo "moonlight-qt stream \"${host}\" \"${app}\" ${options}" > $script
    local icon="$CPIGS_WORKSPACE_MOONLIGHT/moonlight.png"
    cpigs_link $pos $title $script $icon
}

function moonlight()
{
while [ "$#" -gt 0 ]; do
    case "$1" in
      text)
         echo "remote game streaming, see https://moonlight-stream.org/"
         shift 1
        ;;
      install)
          moonlight_install
          return 0
          ;;
      update)
          moonlight_update
          return 0
          ;;
      link)
          moonlight_link
          return 0
          ;;
      --help)
        echo "install: add moonlight-qt repository, download and install it"
        echo "update: apt update moonlight-qt"
        echo "link: create a link in the launcher for a machine and application"
        shift 1
        ;;
      *)
          echo "unknown parameter $1"
          shift 1
          ;;
    esac
  done
}

cpigs_register "moonlight"
