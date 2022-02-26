#!/bin/bash
# Script to get the project git url

set -e

here=$(dirname $(dirname $0))

cd $here && repo="$(git config --get remote.origin.url)" || repo="none"

if [ "${repo}" != "none" ]; then
    repo="$(echo ${repo} | cut -d'@' -f2)"
    repo=${repo/:/\/}
fi

echo "{ \"repo\": \"${repo}\" }"

exit 0
