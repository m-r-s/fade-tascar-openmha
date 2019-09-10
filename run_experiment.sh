#!/bin/bash

SCENE="scene-complex-processing"

XLIM=(-2 4)
YLIM=(-4 2)
RESOLUTION=(2 1 0.5)
Zs=(0.0)

mkdir -p data
mkdir -p resultsQ
mkdir -p resultsF

for R in ${RESOLUTION[@]}; do
  echo "Resolution: ${R}"
  Xs=($(octave-cli -q --eval "printf('%.1f ',${XLIM[0]}:${R}:${XLIM[1]})"))
  Ys=($(octave-cli -q --eval "printf('%.1f ',${YLIM[0]}:${R}:${YLIM[1]})"))
  echo "X = ${Xs[@]}"
  echo "Y = ${Ys[@]}"
  echo "Render missing conditions"
  ./${SCENE}/render_environment.sh "environment.wav" 6
  for X in ${Xs[@]}; do
    for Y in ${Ys[@]}; do
      for Z in ${Zs[@]}; do
        if [ ! -e "data/x${X}_y${Y}_z${Z}" ]; then
          mkdir -p "data/x${X}_y${Y}_z${Z}"
          mkdir -p "data/x${X}_y${Y}_z${Z}/hrirs/"
          mkdir -p "data/x${X}_y${Y}_z${Z}/noises/"
          cp "environment.wav" "data/x${X}_y${Y}_z${Z}/noises/environment.wav"
          for I in 0 1 2 3 4 5; do
            ./${SCENE}/render_hrir.sh "data/x${X}_y${Y}_z${Z}/hrirs/hrir${I}.wav" "${I}" "${X}" "${Y}" "${Z}"
          done
        fi
      done
    done
  done

  echo "Run fast simulations"
  ls -1 data | xargs -L1 ./run_simulation.sh Q

  echo "Run full simulations"
  ls -1 data | xargs -L1 ./run_simulation.sh F

  echo "Collect results"
  ./collect_results.sh resultsF > data-F.txt

  echo "Update figures"
  ./plot_data.m
done
