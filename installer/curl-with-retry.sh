#!/bin/bash

set -e

RETRIES=50

while [ $RETRIES -gt 0 ]; do
  if $(curl --connect-timeout 30 --speed-time 60 --speed-limit 1000 "$@"); then
    exit 0
  else
    RETRIES=$((RETRIES - 1))
    PAUSE=$(( ( RANDOM % 5 ) + 1 ))
    echo "Retry in $PAUSE seconds, $RETRIES times remaining..."
    sleep "$PAUSE"
  fi
done

exit 1
