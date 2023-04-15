#!/bin/bash

set -e

base_path=$(git rev-parse --show-toplevel);

export GREEN='\033[0;32m'
export RED='\033[0;31m'
export NC='\033[0m' # No Color

# SwiftFormat specific scripts
if [[ $1 = "format" ]] ; then
    sh ${base_path}/scripts/swiftformat.sh
    exit 0
elif [[ $1 = "lint" ]] ; then
    sh ${base_path}/scripts/swiftformat.sh --lint
    exit 0
fi

# Default scripts for build
sh ${base_path}/scripts/swiftformat.sh --lint
sh ${base_path}/scripts/xcodebuilds.sh

echo -e "${GREEN}Build is passing!${NC}"

exit 0
