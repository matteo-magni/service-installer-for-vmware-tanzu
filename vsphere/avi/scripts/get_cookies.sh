#!/usr/bin/env bash

set -euo pipefail

AVI_HOST=
AVI_USER=
AVI_PASS=

usage() {
    echo "Usage: $0 -h AVI_HOST -u AVI_USER -p AVI_PASS"
}

while getopts 'h:u:p:' opt; do
    case "$opt" in
        h)
            AVI_HOST="$OPTARG"
            ;;
        u)
            AVI_USER="$OPTARG"
            ;;
        p)
            AVI_PASS="$OPTARG"
            ;;
        *)
            echo "ERROR: invalid option" >&2
            usage
            exit 1
    esac
done

[ -z "$AVI_HOST" ] || [ -z "$AVI_USER" ] || [ -z "$AVI_PASS" ] && echo "ERROR: Missing arguments" >&2 && usage >&2 && exit 1

curl -sfSLk --data-urlencode "username=${AVI_USER}" --data-urlencode "password=${AVI_PASS}" -D - -o /dev/null https://${AVI_HOST}/login | grep -oE '^set-cookie: [^;]+' | cut -d" " -f2 | tr '\n' ';'
