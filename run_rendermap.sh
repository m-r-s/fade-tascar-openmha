#!/bin/bash

# Get the directory this script is stored in and its name
DIR=$(cd "$( dirname "$0" )" && pwd)
SCN=$(basename "$0")

if [ $# -lt 1 ]; then
  echo "usage: ${SCN} <MAPDIR> <XRANGE> <YRANGE> <ZRANGE> <SCENEDIR> <SCENESTART> <SCENEDURATION> [SCENEPARAMETERS]"
  echo ""
  exit 1
fi

MAPDIR="$1"
XRANGE="$2"
YRANGE="$3"
ZRANGE="$4"
SCENEDIR="$5"
START="$6"
DURATION="$7"
shift 7
SCENEPARAMETERS=("$@")

SCENEDIR=$(cd "${SCENEDIR}" && echo "${PWD}")
PARAMETERSTRING="${SCENEPARAMETERS[@]}"
PARAMETERSTRING="parameter_${PARAMETERSTRING// /_}"

mkdir -p "${MAPDIR}" || exit 1
mkdir -p "${MAPDIR}/${PARAMETERSTRING}" || exit 1

cd "${MAPDIR}/${PARAMETERSTRING}" || exit 1

Xs=($(octave-cli -q --eval "printf('%.2f ',${XRANGE})"))
Ys=($(octave-cli -q --eval "printf('%.2f ',${YRANGE})"))
Zs=($(octave-cli -q --eval "printf('%.2f ',${ZRANGE})"))
N=$[${#Xs[@]} * ${#Ys[@]} * ${#Zs[@]}]
echo "X = ${Xs[@]}"
echo "Y = ${Ys[@]}"
echo "Z = ${Zs[@]}"
echo "N = ${N}"
echo "START = ${START}"
echo "DURATION = ${DURATION}"

mkdir -p "scenedb" || exit 1
if [ ! -e "environment.wav" ]; then
  echo "Render environment.wav"
  "${SCENEDIR}/render.sh" "environment" "environment.wav" "$START" "$DURATION" 0 0 0 "${SCENEPARAMETERS[@]}" || exit 1
fi

for X in ${Xs[@]}; do
  for Y in ${Ys[@]}; do
    for Z in ${Zs[@]}; do
      SCENEPOINTDIR="scenedb/x${X}_y${Y}_z${Z}"
      if [ ! -e "${SCENEPOINTDIR}" ]; then
        echo "Render impulse responses for ${SCENEPOINTDIR}"
        mkdir -p "${SCENEPOINTDIR}" || exit 1
        mkdir -p "${SCENEPOINTDIR}/hrirs/" || exit 1
        mkdir -p "${SCENEPOINTDIR}/noises/" || exit 1
        cp "environment.wav" "${SCENEPOINTDIR}/noises/environment.wav" || exit 1
        Ts=($(octave-cli -q --eval "printf('%.2f ',${START}+linspace(0,${DURATION}-1,5))"))
        for T in ${Ts[@]}; do
          "${SCENEDIR}/render.sh" "hrir" "${SCENEPOINTDIR}/hrirs/hrir${T}.wav" "${T}" 1 "${X}" "${Y}" "${Z}" "${SCENEPARAMETERS[@]}" || exit 1
        done
      fi
    done
  done
done

echo "Run fast simulations"
ls -1 scenedb | xargs -L1 "${DIR}/run_simulation.sh" quick
"${DIR}/collect_results.sh" results-quick > data-quick.txt

echo "Update figures"
"${DIR}/plot_data.m"

echo "Run full simulations"
ls -1 scenedb | xargs -L1 "${DIR}/run_simulation.sh" full
"${DIR}/collect_results.sh" results-full > data-levels.txt

echo "Update figures"
"${DIR}/plot_data.m"

