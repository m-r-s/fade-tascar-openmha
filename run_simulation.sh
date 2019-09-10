#!/bin/bash

DIR=$(cd "$( dirname "$0" )" && pwd)

# SIMULATION MODE: Q(UICK) or F(ULL)
MODE="$1"

# HEAD RELATED IMPULSE RESPONSES
DATA="$2"

# TARGETFILE FOR RESULTS
RESULTSFILE="${DIR}/results${MODE}/${DATA}.txt"

# FEATURE CONFIG
FEATURES="sgbfb-abel"
FEATURES_PROFILE=0

# PROCESSING CONFIG
PROCESSING_DIR="${DIR}/processing-openMHA"

# TARGET THRESHOLD
THRESHOLD='0.5'

case "${MODE}" in
  'Q')
    # FAST SIMULATION SETTINGS
    TRAIN_SAMPLES='120'
    TEST_SAMPLES='40'
    SIMRANGE=-60:6:30
  ;;
  'F')
    # FULL SIMULATION SETTINGS
    TRAIN_SAMPLES='480'
    TEST_SAMPLES='120'
    RESULTSFILEQ="${DIR}/resultsQ/${DATA}.txt"
    POI=$(cat ${RESULTSFILEQ})
    if [ -z "${POI}" ]; then
      echo "POI could not be determined"
      exit 1
    fi
    SIMRANGE="$((${POI}-9)):3:$((${POI}+9))"
  ;;
esac

echo "RUN SIMULATION FOR DATA=${DATA} MODE=${MODE} SIMRANGE=${SIMRANGE}"

if [ -e "$RESULTSFILE" ]; then
  echo "resultsfile '${RESULTSFILE}' exists - skip"
  exit 0
fi

WORKDIR=$(mktemp -d -p /dev/shm/)
cd "$WORKDIR" || exit 1

fade simulation corpus-matrix "${TRAIN_SAMPLES}" "${TEST_SAMPLES}" "${SIMRANGE}" || exit 1
fade simulation parallel

echo "Copy hrir, speech, and noise files"
cp -L -t "simulation/source/hrir-speech/" "${DIR}/data/${DATA}/hrirs/"* || exit 1
cp -L -t "simulation/source/speech/" "${DIR}/matrix/speech/"*  || exit 1
cp -L -t "simulation/source/noise/" "${DIR}/data/${DATA}/noises/"* || exit 1

case "${MODE}" in
  'Q')
    # Only consider the diagonal SNR-matched train/test
    sed -i -e "s/^CONDITION_CODE=.*$/CONDITION_CODE='o o'/g" \
      "simulation/config/corpus/format.cfg"
  ;;
esac

fade simulation corpus-generate || exit 1
fade simulation processing "${PROCESSING_DIR}" || exit 1
fade simulation corpus-format || exit 1
[ -e "simulation/corpus" ] && rm -rf "simulation/corpus"
fade simulation features "${FEATURES}" "${FEATURES_PROFILE}" || exit 1
[ -e "simulation/processing" ] && rm -rf "simulation/processing"
fade simulation training || exit 1
fade simulation recognition || exit 1
fade simulation evaluation || exit 1

echo "FINISHED: $PWD"

case "${MODE}" in
  'Q')
    POI=$(cat "simulation/evaluation/summary" | sed -E 's/(^| )[^_]*_snr/ /g' | cut -d' ' -f2,4,5 | \
      sort -n | awk -F' ' -vt="${THRESHOLD}" \
        '{x1=$1;y1=$3/$2;if (y1>t) {if (NR>1) {printf "%.0f",x2+(x2-x1)/(y2-y1)*(t-y2)} exit} x2=x1;y2=y1}')
    echo "$POI" > "${RESULTSFILE}"
    cp simulation/evaluation/summary "${RESULTSFILE/%.txt/.sum}"
  ;;
  'F')
    fade simulation figures word ${THRESHOLD} || exit 1
    sed -n '2{p;q}' simulation/figures/table.txt | tr -s ' ' | cut -d' ' -f2 > "${RESULTSFILE}"
    cp simulation/figures/table.txt "${RESULTSFILE/%.txt/.tab}"
    cp simulation/figures/environment.eps "${RESULTSFILE/%.txt/.eps}"
  ;;
esac

cd "$DIR"

[ -e "${WORKDIR}" ] && rm -rf "${WORKDIR}"
