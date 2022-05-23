#!/usr/bin/env bash

set -euo pipefail

# set defaults
DEBUG=${DEBUG:-}
AVI_METHOD="${AVI_METHOD:-GET}"
AVI_HOST="${AVI_HOST:-}"
AVI_USER="${AVI_USER:-}"
AVI_PASS="${AVI_PASS:-}"
AVI_VERSION="${AVI_VERSION:-}"
AVI_ENDPOINT="${AVI_ENDPOINT:-}"
JSON_BODY="${JSON_BODY:-}"

usage() {
    cat <<EOF
Usage: $0 [-d] [-h AVI_HOST] [-u AVI_USER] [-p AVI_PASS] [-v AVI_VERSION] [-j JSON_BODY] [-e AVI_ENDPOINT] [-m AVI_METHOD]
All arguments must be provided either on the CLI or via environment variables
EOF
}

while getopts 'dh:u:p:v:j:e:m:' opt; do
    case "$opt" in
        d)
            DEBUG=1
            ;;
        h)
            AVI_HOST="$OPTARG"
            ;;
        u)
            AVI_USER="$OPTARG"
            ;;
        p)
            AVI_PASS="$OPTARG"
            ;;
        v)
            AVI_VERSION="$OPTARG"
            ;;
        j)
            JSON_BODY="$OPTARG"
            ;;
        e)
            AVI_ENDPOINT="$OPTARG"
            ;;
        m)
            AVI_METHOD="$OPTARG"
            ;;
        *)
            echo "ERROR: invalid option" >&2
            usage
            exit 1
    esac
done

shift $((OPTIND-1))

[ -z "$AVI_HOST" ] || [ -z "$AVI_USER" ] || [ -z "$AVI_PASS" ] || [ -z "$AVI_VERSION" ] || [ -z "$AVI_ENDPOINT" ] || [ -z "$AVI_METHOD" ] || [ -z "$JSON_BODY" -a "$AVI_METHOD" != "GET" ] && echo "ERROR: Missing arguments" >&2 && usage >&2 && exit 1

if [ "$DEBUG" == "1" ]; then set -x; fi

AVI_ENDPOINT="${AVI_ENDPOINT##/}"  # remove leading slashes
AVI_METHOD=$(echo "$AVI_METHOD" | tr [:lower:] [:upper:])  # make it uppercase

COOKIES=$(curl -sfSLk --data-urlencode "username=${AVI_USER}" --data-urlencode "password=${AVI_PASS}" -D - -o /dev/null https://${AVI_HOST}/login | grep -oE '^set-cookie: [^;]+' | cut -d" " -f2 | tr '\n' ';')
TOKEN=$(echo $COOKIES | grep -oE 'csrftoken=[^;]+' | cut -d= -f2)

curl -sSLk --fail-with-body \
    -X "${AVI_METHOD}" \
    -b "${COOKIES}" \
    -H "Referer: https://${AVI_HOST}" \
    -H "Content-Type: application/json" \
    -H "X-Avi-Version: ${AVI_VERSION}" \
    -H "X-CSRFToken: ${TOKEN}" \
    -d "${JSON_BODY}" \
    $* \
    https://${AVI_HOST}/api/${AVI_ENDPOINT}
