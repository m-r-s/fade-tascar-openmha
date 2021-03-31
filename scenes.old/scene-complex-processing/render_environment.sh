#!/bin/bash
DIR=$(cd "$( dirname "$0" )" && pwd)

OUTFILE="$1"
DURATION="$2"
T="$3"

sed -e "s/XXX/${X}/g" -e "s/YYY/${Y}/g" -e "s/ZZZ/${Z}/g" "${DIR}/environment.tsc" > "${DIR}/environment.tmp.tsc"
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/dbus/system_bus_socket

killall -9 jackd &> /dev/null
killall -9 tascar_cli &> /dev/null
sleep 1
jackd --sync --silent -r -d dummy -r48000 -p256 2>&1 | sed 's/^/[JACK]/g' &
sleep 0.5
tascar_cli "${DIR}/environment.tmp.tsc" 2>&1 | sed 's/^/[TASCAR]/g' &
sleep 1
send_osc 9999 '/transport/locate' 0
send_osc 9999 '/transport/start'
tascar_jackio -v -f -t "${DIR}/statistics.txt" -d "${DURATION}" -o "${OUTFILE}" hrirconv:out_0 hrirconv:out_1 hrirconv:out_2 hrirconv:out_3 2>&1 | sed 's/^/[JACKIO]/g'
cat "${DIR}/statistics.txt"
killall -9 jackd &> /dev/null
killall -9 tascar_cli &> /dev/null
