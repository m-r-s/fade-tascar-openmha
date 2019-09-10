#!/bin/bash
DIR=$(cd "$( dirname "$0" )" && pwd)

octave -q --eval "fs=48000;audiowrite('${DIR}/impulse.wav',[10.^(-28.979./20);zeros(fs-1,1)],fs,'BitsPerSample',32);"

killall -9 jackd &> /dev/null
killall -9 tascar_cli &> /dev/null
sleep 1
jackd --sync --silent -r -d dummy -r48000 -p256 2>&1 | sed 's/^/[JACK]/g' &
sleep 0.5
tascar_cli "${DIR}/calibrate-omni.tsc" 2>&1 | sed 's/^/[TASCAR]/g' &
sleep 1
tascar_jackio -v -f -t "${DIR}/statistics.txt" -o "${DIR}/recording.wav" "${DIR}/impulse.wav" render.main:probe.0 render.main:out 2>&1 | sed 's/^/[JACKIO]/g'
cat "${DIR}/statistics.txt"
killall -9 jackd &> /dev/null
killall -9 tascar_cli &> /dev/null
./evaluate_calibration.m


killall -9 jackd &> /dev/null
killall -9 tascar_cli &> /dev/null
sleep 1
jackd --sync --silent -r -d dummy -r48000 -p256 2>&1 | sed 's/^/[JACK]/g' &
sleep 0.5
tascar_cli "${DIR}/calibrate-hrir.tsc" 2>&1 | sed 's/^/[TASCAR]/g' &
sleep 1
tascar_jackio -v -f -t "${DIR}/statistics.txt" -o "${DIR}/recording.wav" "${DIR}/impulse.wav" render.main:probe.0 hrirconv:out_0 hrirconv:out_1 2>&1 | sed 's/^/[JACKIO]/g'
cat "${DIR}/statistics.txt"
killall -9 jackd &> /dev/null
killall -9 tascar_cli &> /dev/null
./evaluate_calibration.m

