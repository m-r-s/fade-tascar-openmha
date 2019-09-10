#!/bin/bash

cd "${1}" && ls -1 *.txt | while read line; do echo -n $line | sed -E -e 's/.txt/ /g' | tr "_xyz" "   "; cat "$line" ; done

