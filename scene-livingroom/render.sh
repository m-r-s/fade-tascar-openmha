#!/bin/bash

# Get the directory this script is stored in and its name
DIR=$(cd "$( dirname "$0" )" && pwd)
SCN=$(basename "$0")

if [ $# -lt 1 ]; then
  echo "usage: ${SCN} <TYPE> <OUTFILE> <START> <DURATION> <X> <Y> <Z> <RECEIVERTYPE> <RECEIVERAZIMUTH> <TV> <CR> <REVERB>"
  echo ""
  exit 1
fi

TYPE="$1"
OUTFILE="$2"
START="$3"
DURATION="$4"
X="$5"
Y="$6"
Z="$7"
RECEIVERTYPE="$8"
RECEIVERAZIMUTH="$9"
TV="${10}"
CR="${11}"
REVERB="${12}"

FS=44100
FRAGSIZE=1024

case $TYPE in
  environment)
    PROBEMUTE="true"
    [ "$TV" == 1 ] && TVMUTE="false" || TVMUTE="true"
    [ "$CR" == 1 ] && CRMUTE="false" || CRMUTE="true"
  ;;
  hrir)
    PROBEMUTE="false"
    TVMUTE="true"
    CRMUTE="true"
  ;;
  *)
    echo "unknown type"
    exit 1
  ;;
esac

[ "$REVERB" == 1 ] && REVERBMUTE="false" || REVERBMUTE="true"

sed -e "s/RECEIVERTYPE/${RECEIVERTYPE}/g" \
    -e "s/RECEIVERAZIMUTH/${RECEIVERAZIMUTH}/g" \
    -e "s/PROBEMUTE/${PROBEMUTE}/g" \
    -e "s/TVMUTE/${TVMUTE}/g" \
    -e "s/CRMUTE/${CRMUTE}/g" \
    -e "s/REVERBMUTE/${REVERBMUTE}/g" \
    -e "s/PROBESTART/${START}/g" \
    -e "s/PROBEXXX/${X}/g" -e "s/PROBEYYY/${Y}/g" -e "s/PROBEZZZ/${Z}/g" \
    "${DIR}/environment.tsc" > "${DIR}/environment.tmp.tsc" || exit 1

tascar_renderfile -r "${FS}" -f "${FRAGSIZE}" -o "${OUTFILE}" -t "${START}" -u "${DURATION}" "${DIR}/environment.tmp.tsc"

sox "${OUTFILE}" -r16000 -b32 "${OUTFILE}.tmp.wav" || exit 1
mv "${OUTFILE}.tmp.wav" "${OUTFILE}" || exit 1
