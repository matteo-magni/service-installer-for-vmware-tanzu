#!/usr/bin/env bash

set -euo pipefail

API_SCRIPT=$(dirname $0)/avi.sh
declare -r AVI_METHOD="PATCH"

AVI_HOST="${AVI_HOST:-}"
AVI_USER="${AVI_USER:-}"
AVI_PASS="${AVI_PASS:-}"
AVI_VERSION="${AVI_VERSION:-}"
JSON_BODY="${JSON_BODY:-}"
AVI_IPAM_UUID="${AVI_IPAM_UUID:-}"

usage() {
    cat <<EOF
Usage: $0 [-h AVI_HOST] [-u AVI_USER] [-p AVI_PASS] [-v AVI_VERSION] [-j JSON_BODY] [-i AVI_IPAM_UUID]
All arguments must be provided either on the CLI or via environment variables
EOF

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

AVI_ENDPOINT="/ipamdnsproviderprofile/${AVI_IPAM_UUID}"

export AVI_METHOD AVI_HOST AVI_USER AVI_PASS AVI_VERSION JSON_BODY AVI_ENDPOINT

$API_SCRIPT
