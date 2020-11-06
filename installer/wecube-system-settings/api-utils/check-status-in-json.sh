#!/bin/bash

SUCCESS_CONDITION_EXPR=${1:-'.status == "OK" and .message == "Success"'}

jq --exit-status "if ${SUCCESS_CONDITION_EXPR} then . else halt_error end"
