#!/bin/bash

set -e

INPUT_FILE=$1
OUTPUT_FILE=$2

sed -r "s/^([^=]+=)'(.*)'$/\1\2/g" "$INPUT_FILE" >"$OUTPUT_FILE"
