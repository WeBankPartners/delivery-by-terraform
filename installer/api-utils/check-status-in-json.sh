#!/bin/bash

SUCCESS_CONDITION_EXPR=${1:-'.status == "OK"'}

jq --exit-status "if ${SUCCESS_CONDITION_EXPR} then . else halt_error end"
