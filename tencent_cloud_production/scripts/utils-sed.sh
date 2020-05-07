#!/bin/bash

echo "Replace [$1] to [$2] in file[$3]"
sed -i "s~$1~$2~g" $3