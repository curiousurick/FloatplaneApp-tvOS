#!/bin/bash
# Run xcodebuild for all targets.

base_path=$(git rev-parse --show-toplevel);

set -e

xcodebuild test -project "${base_path}/FloatplaneApp-Models/FloatplaneApp-Models.xcodeproj" -scheme FloatplaneApp-Models -destination 'platform=tvOS Simulator,name=Apple TV 4K (3rd generation),OS=16.1' build test;

xcodebuild test -project FloatplaneApp-Utilities/FloatplaneApp-Utilities.xcodeproj -scheme FloatplaneApp-Utilities -destination 'platform=tvOS Simulator,name=Apple TV 4K (3rd generation),OS=16.1' build test;

xcodebuild test -project FloatplaneApp-DataStores/FloatplaneApp-DataStores.xcodeproj -scheme FloatplaneApp-DataStores -destination 'platform=tvOS Simulator,name=Apple TV 4K (3rd generation),OS=16.1' build test;

xcodebuild test -project FloatplaneApp-Operations/FloatplaneApp-Operations.xcodeproj -scheme FloatplaneApp-Operations -destination 'platform=tvOS Simulator,name=Apple TV 4K (3rd generation),OS=16.1' build test;

xcodebuild -project FloatplaneApp-App/FloatplaneApp.xcodeproj -scheme FloatplaneApp -destination 'platform=tvOS Simulator,name=Apple TV 4K (3rd generation),OS=16.1' build;

exit 0
