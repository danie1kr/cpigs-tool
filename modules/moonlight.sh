#!/bin/bash
function moonlight()
{
while [ "$#" -gt 0 ]; do
    case "$1" in
      text)
         echo "remote game streaming, see https://moonlight-stream.org/"
         shift 1
        ;;
      help)
        echo "install"
        echo "update"
        echo "shortcut"
        shift 1
        ;;
      *)
          echo "unknown parameter $1"
          shift 1
          ;;
    esac
  done
}

register "moonlight"
