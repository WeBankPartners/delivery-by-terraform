#!/bin/bash

set -e

ENV_FILE=$1
INPUT_FILE=$2
OUTPUT_FILE=$3

source $ENV_FILE
eval "cat >$OUTPUT_FILE <<EOF
$(sed -e 's/`/``/g' $INPUT_FILE)
EOF
"
