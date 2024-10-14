#!/bin/bash
# Run xcodebuild for all targets.

base_path=$(git rev-parse --show-toplevel);

set -e

xcodebuild build -project ${base_path}/Kenmore-tvOS.xcodeproj -scheme Kenmore-tvOS -destination 'platform=tvOS Simulator,name=Apple TV 4K (3rd generation),OS=18.1';

exit 0
