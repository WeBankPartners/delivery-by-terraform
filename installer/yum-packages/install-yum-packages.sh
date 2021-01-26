#!/bin/bash

set -e

ENV_FILE=$1

source $ENV_FILE

sudo yum install -y unzip jq
