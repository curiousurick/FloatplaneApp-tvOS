#!/bin/bash

base_path=$(git rev-parse --show-toplevel);

RED='\033[0;31m'
GREEN='\033[1;32m'
NC='\033[0m'

set -e

which -s brew
if [[ $? != 0 ]] ; then
    echo "Brew is not installed. Please install brew with the following command and try again."
    echo "${GREEN}ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\"${NC}"
    exit 1
fi

which -s swiftformat
if [[ $? != 0 ]] ; then
    brew install swiftformat;
fi

swiftformat $1 $(git rev-parse --show-toplevel)/
