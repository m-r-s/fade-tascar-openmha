#!/bin/bash
DIR=$(cd "$( dirname "$0" )" && pwd)

OUTFILE="$1"
T="$2"
X="$3"
Y="$4"
Z="$5"

export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/dbus/system_bus_socket

sed -e "s/XXX/${X}/g" -e "s/YYY/${Y}/g" -e "s/ZZZ/${Z}/g" "${DIR}/target.tsc" > "${DIR}/target.tmp.tsc"
octave -q --eval "fs=48000;audiowrite('${DIR}/impulse.wav',[10.^(-28.979./20);zeros(fs-1,1)],fs,'BitsPerSample',32);"

killall -9 jackd &> /dev/null
killall -9 tascar_cli &> /dev/null
sleep 1

jackd --sync --silent -r -d dummy -r48000 -p256 2>&1 | sed 's/^/[JACK]/g' &
sleep 0.5
tascar_cli "${DIR}/target.tmp.tsc" 2>&1 | sed 's/^/[TASCAR]/g' &
sleep 1
send_osc 9999 '/transport/stop'
send_osc 9999 '/transport/locate' "0"
send_osc 9999 '/transport/locate' "${T}"
tascar_jackio -v -f -t "${DIR}/statistics.txt" -o "${OUTFILE}" "${DIR}/impulse.wav" render.main:probe.0 hrirconv:out_0 hrirconv:out_1 2>&1 | sed 's/^/[JACKIO]/g'
cat "${DIR}/statistics.txt"
killall -9 jackd &> /dev/null
killall -9 tascar_cli &> /dev/null
