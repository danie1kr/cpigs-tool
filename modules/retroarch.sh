#!/bin/bash

CPIGS_WORKSPACE_RETROARCH=$CPIGS_WORKSPACE/retroarch
mkdir -p $CPIGS_WORKSPACE_RETROARCH

CPIGS_RETROARCH_CONFIG="/home/cpi/.config/retroarch"

CPIGS_RETROARCH_CONFIGURE=('--enable-alsa' '--enable-udev' '--enable-floathard' '--enable-neon' '--enable-networking' '--enable-opengles' '--enable-egl' '--disable-kms' '--disable-xmb' '--disable-ozone' '--disable-materialui' '--disable-vg' '--enable-ffmpeg' '--enable-pulse' '--disable-oss' '--enable-freetype' '--enable-7zip' '--enable-dbus' '--disable-wayland' '--enable-sdl2' '--enable-threads' '--enable-xvideo' '--prefix=/usr')

function retroarch_install()
{
    pushd .
    cd $CPIGS_WORKSPACE_RETROARCH

    git clone https://github.com/libretro/RetroArch

    sudo apt -y install build-essential libudev-dev libegl-dev libasound2-dev libgbm-dev libdrm-dev libgles2-mesa-dev libavcodec-dev libavformat-dev libavdevice-dev libdbus-1-dev libpulse-dev libxkbcommon-dev libsdl2-dev libx11-xcb-dev libfreetype-dev

    cd RetroArch
    make clean
    CFLAGS=-mfpu=neon ./configure "${CPIGS_RETROARCH_CONFIGURE[@]}"
    make -j3
    cd ..
    cp RetroArch/media/icons/mipmap-xxxhdpi/ic_launcher.png retroarch.png

    touch installed

    popd
}

function retroarch_update()
{
    if ! [ -f $CPIGS_WORKSPACE_RETROARCH/installed ]; then
        cpigs_error "Please install first"
        return -1
    fi

    pushd .

    cd $CPIGS_WORKSPACE_RETROARCH/RetroArch
    git pull
    #make clean
    #CFLAGS=-mfpu=neon ./configure "${CPIGS_RETROARCH_CONFIGURE[@]}"
    make -j3

    popd
}

function retroarch_link()
{
    if ! [ -f $CPIGS_WORKSPACE_RETROARCH/installed ]; then
        cpigs_error "Please install first"
        return -1
    fi

    local pos=`cpigs_ask "Launcher Item Position" "20"`
    local title=`cpigs_ask "Launcher Item Title" "retroarch"`

    local idx=0
    local playlists=()
    for pl in "$CPIGS_RETROARCH_CONFIG/*.lpl"; do
        echo "[${idx}] $pl"
        playlists[$idx]=$CPIGS_RETROARCH_CONFIG/$pl
        ((idx++))
    done

    local playlistIdx=`cpigs_ask "Playlist id"`




    local script="/tmp/cpigs/script"
    local icon="$CPIGS_WORKSPACE_RETROARCH/retroarch.png"
    cpigs_link $pos $title $script $icon
}

function retroarch()
{
while [ "$#" -gt 0 ]; do
    case "$1" in
      text)
         echo "libreto API frontend, see https://www.libretro.com/"
         shift 1
        ;;
      install)
          retroarch_install
          return 0
          ;;
      update)
          retroarch_update
          return 0
          ;;
      link)
          retroarch_link
          return 0
          ;;
      --help)
        echo "install: clone retroarch repository, download and compile it"
        echo "update: git pull and compile again"
        echo "link: create a link in the launcher for an emulator and rom"
        shift 1
        ;;
      *)
          echo "unknown parameter $1"
          shift 1
          ;;
    esac
  done
}

cpigs_register "retroarch"
