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
        cpigs_error "Please run install command first"
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
        cpigs_error "Please run install command first"
        return -1
    fi

    printf "\nSelect a RetroArch playlist: \n"
    local idx=0
    local playlists=()
    for pl in $CPIGS_RETROARCH_CONFIG/playlists/*.lpl; do
        printf "[%2d] %s\n" "$idx" "$pl"
        playlists[$idx]=$pl
        ((idx++))
    done
    if [ $idx == 0 ]; then printf "no playlists found\n"; return 0; fi

    local playlistIdx=`cpigs_ask "Playlist id"`
    if ! [ "${playlists[$playlistIdx]+abc}" ]; then printf "invalid index\n"; return 0; fi
    local playlistName="${playlists[$playlistIdx]}"

    printf "\nSelect a game from ${playlistName}:\n(other games might not be fully configured with a core. Run them from retroArch just once.)\n"
    local games=()
    mapfile -t games < <(jq '.items[] | select(.core_path != "DETECT") | .label' "${playlists[$playlistIdx]}")
    idx=0
    for game in "${games[@]}"; do
        printf "[%2d] %s\n" "$idx" "`echo ${game} | sed 's/\"//g'`"
        ((idx++))
    done
    if [ $idx == 0 ]; then printf "no games found in playlist ${playlistName}\n"; return 0; fi

    local gameIdx=`cpigs_ask "Game id"`
    if ! [ "${games[$gameIdx]+abc}" ]; then printf "invalid index\n"; return 0; fi
    local name="${games[$gameIdx]}"
    local rom=`jq ".items[] | select(.label == ${name}) | .path" "${playlists[$playlistIdx]}"`
    local core=`jq ".items[] | select(.label == ${name}) | .core_path" "${playlists[$playlistIdx]}"`

    printf "\nConfigure Launcher Item for ${name}:\n"
    local pos=`cpigs_ask "Launcher Item Position" "20"`
    local title=`cpigs_ask "Launcher Item Title" "retroarch"`

    name=`echo ${name} | sed "s/\"//g"`
#    echo $name
#    echo $rom
#    echo $core
    local script="/tmp/cpigs/script"
    mkdir -p /tmp/cpigs
    touch $script

    echo "`realpath ${CPIGS_WORKSPACE_RETROARCH}/RetroArch/retroarch` -L ${core} ${rom}" > $script

#    cat $script

    local systemBasename=`basename "${playlists[$playlistIdx]}"`
    local icon="${CPIGS_RETROARCH_CONFIG}/thumbnails/${systemBasename%.*}/Named_Boxarts/${name}.png"
    icon=`echo $icon | sed "s/\&/_/g"`
    if ! [ -f "${icon}" ]; then
        icon="$CPIGS_WORKSPACE_RETROARCH/retroarch.png"
    fi 

    script=`realpath "${script}"`
    icon=`realpath "${icon}"`

    cpigs_link "$pos" "$title" "$script" "$icon"
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
