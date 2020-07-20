#!/bin/bash

set -e

ENV_FILE=$1

source $ENV_FILE

yum install -y unzip httpie
