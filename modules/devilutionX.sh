
#!/bin/bash

CPIGS_WORKSPACE_DEVILUTIONX=$CPIGS_WORKSPACE/devilutionX
mkdir -p $CPIGS_WORKSPACE_DEVILUTIONX

function devilutionX_install()
{
    pushd .
    cd $CPIGS_WORKSPACE_DEVILUTIONX

    git clone https://github.com/diasurgical/devilutionX
    sudo apt install -y cmake libsdl2-dev libbz2-dev libsodium-dev

    cd devilutionX
	rm -f CMakeCache.txt

	cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release -DTARGET_PLATFORM=cpigamesh -DDISABLE_LTO=ON
	cmake --build build -j $(getconf _NPROCESSORS_ONLN)
    cd ..

    cp devilutionX/Packaging/cpi-gamesh/Devilution.png devilutionX.png

    touch installed

    echo "Installation finished. Please ensure /home/cpi/.local/share/diasurgical/devilution/DIABDAT.MPQ to be present."

    popd
}

function devilutionX_update()
{
    if ! [ -f $CPIGS_WORKSPACE_DEVILUTIONX/installed ]; then
        cpigs_error "Please install first"
        return -1
    fi

    pushd .
    cd $CPIGS_WORKSPACE_DEVILUTIONX/devilutionX
    git pull
    rm -f CMakeCache.txt

	cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release -DTARGET_PLATFORM=cpigamesh -DDISABLE_LTO=ON
	cmake --build build -j $(getconf _NPROCESSORS_ONLN)

    popd
}

function devilutionX_link()
{
    if ! [ -f $CPIGS_WORKSPACE_DEVILUTIONX/installed ]; then
        cpigs_error "Please install first"
        return -1
    fi

    if ! [ -f /home/cpi/.local/share/diasurgical/devilution/DIABDAT.MPQ ]; then
        cpigs_error "DIABDAT.MPQ not found in /home/cpi/.local/share/diasurgical/devilution. Please install first."
        return -1
    fi

    local pos=`cpigs_ask "Launcher Item Position" "20"`
    local title=`cpigs_ask "Launcher Item Title" "devilutionX"`

    local script="/tmp/cpigs/script"
    local icon="$CPIGS_WORKSPACE_DEVILUTIONX/devilutionX.png"
    
    echo "`realpath $CPIGS_WORKSPACE_DEVILUTIONX/devilutionX/build/devilutionx`" > $script

    cpigs_link $pos $title $script $icon
}

function devilutionX()
{
while [ "$#" -gt 0 ]; do
    case "$1" in
      text)
         echo "Diablo build for modern operating systems, see https://github.com/diasurgical/devilutionX"
         shift 1
        ;;
      install)
          devilutionX_install
          return 0
          ;;
      update)
          devilutionX_update
          return 0
          ;;
      link)
          devilutionX_link
          return 0
          ;;
      --help)
        echo "install: download and compile devilutionX"
        echo "update: update devilutionX"
        echo "link: create a link in the launcher for devilutionX"
        shift 1
        ;;
      *)
          echo "unknown parameter $1"
          shift 1
          ;;
    esac
  done
}

cpigs_register "devilutionX"
