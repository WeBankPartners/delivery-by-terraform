#!/bin/bash

jq --exit-status 'if .status == "OK" and .message == "Success" then . else halt_error end'
