#/bin/bash

VOL_TRACK_FILE="$HOME/.volume_watch"
VOL_CHANGE_LOG="$HOME/volume_change.log"

function getCurrentVolume {
  amixer -D pulse get Master | grep -oE '[[:digit:]]+%' | sort -u
}

function getLastVolume {
  if [ -f "${VOL_TRACK_FILE}" ]; then
    cat ${VOL_TRACK_FILE}
  fi
}

LST_VOL="$(getLastVolume)"
CUR_VOL="$(getCurrentVolume)"

echo ${CUR_VOL} > ${VOL_TRACK_FILE}

if [ -n "${LST_VOL}" -a "${CUR_VOL}" != "${LST_VOL}" ]; then
  MSG="Volume changed from ${LST_VOL} to ${CUR_VOL}"
  echo "[$(date -Iseconds)] ${MSG}" >> ${VOL_CHANGE_LOG}
  notify-send -t 1000 'Volume Change' "${MSG}"
fi
