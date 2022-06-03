#!/usr/bin/env bash

set -euo pipefail

declare HOST=$1
declare STATUS=$2
declare TIMEOUT=$3

HOST=$HOST STATUS=$STATUS timeout --foreground -s TERM $TIMEOUT bash -c \
    'while [[ ${STATUS_RECEIVED} != ${STATUS} ]];\
        do STATUS_RECEIVED=$(curl -skLfSo /dev/null --connect-timeout 5 -w ''%{http_code}'' ${HOST}) ; \
        sleep 10;\
    done'
