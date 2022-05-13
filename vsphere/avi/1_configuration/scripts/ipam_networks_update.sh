#!/usr/bin/env bash

set -euo pipefail

AVI_HOST=
AVI_USER=
AVI_PASS=
AVI_VERSION=
AVI_IPAM_UUID=
BODY=

usage() {
    echo "Usage: $0 -h AVI_HOST -u AVI_USER -p AVI_PASS -v AVI_VERSION -i AVI_IPAM_UUID -j JSON_BODY"
}

while getopts 'h:u:p:v:i:j:' opt; do
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
        v)
            AVI_VERSION="$OPTARG"
            ;;
        i)
            AVI_IPAM_UUID="$OPTARG"
            ;;
        j)
            JSON_BODY="$OPTARG"
            ;;
        *)
            echo "ERROR: invalid option" >&2
            usage
            exit 1
    esac
done

[ -z "$AVI_HOST" ] || [ -z "$AVI_USER" ] || [ -z "$AVI_PASS" ] || [ -z "$AVI_VERSION" ] || [ -z "$AVI_IPAM_UUID" ] || [ -z "$JSON_BODY" ] && echo "ERROR: Missing arguments" >&2 && usage >&2 && exit 1

COOKIES=$($(dirname $0)/get_cookies.sh -h ${AVI_HOST} -u ${AVI_USER} -p ${AVI_PASS})
TOKEN=$(echo $COOKIES | grep -oE 'csrftoken=[^;]+' | cut -d= -f2)

set -x
curl -sfSLk \
    -X PATCH \
    -b "${COOKIES}" \
    -H "Referer: https://${AVI_HOST}" \
    -H "Content-Type: application/json" \
    -H "X-Avi-Version: ${AVI_VERSION}" \
    -H "X-CSRFToken: ${TOKEN}" \
    -d "${JSON_BODY}" \
    https://${AVI_HOST}/api/ipamdnsproviderprofile/${AVI_IPAM_UUID}
