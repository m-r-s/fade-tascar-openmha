#!/bin/bash

SUFFIX=''
XRANGE='-2.0:0.5:1.5'
YRANGE='-2.0:0.5:0.5'
ZRANGE='0.0'
SCENEDIR='scene-livingroom/'
SCENESTART='5'
SCENEDURATION='10'
RECEIVERTYPE='ortf'
REVERB='1'

for TV in 1 0; do
  for CR in 1 0; do
    for RECEIVERAZIMUTH in 0 45 90 135 180; do
     DISPLAY=:0 ./run_rendermap.sh maps/livingroom-var${SUFFIX}/ "$XRANGE" "$YRANGE" "$ZRANGE" "$SCENEDIR" "$SCENESTART" "$SCENEDURATION" "$RECEIVERTYPE" "$RECEIVERAZIMUTH" "$TV" "$CR" "$REVERB"
    done
  done
done

