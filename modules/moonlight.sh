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

    local pos=`cpigs_ask "Launcher Item Position" "20"`
    local title=`cpigs_ask "Launcher Item Title" "moonlight"`

    local script="/tmp/cpigs/script"
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
