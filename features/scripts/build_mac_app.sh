#!/usr/bin/env bash

if [ ! -d "macOSTestApp.xcworkspace" ]; then
    cd "$(dirname "$0")/.."
fi

rm -rf build
xcrun xcodebuild \
  -scheme macOSTestApp \
  -workspace macOSTestApp.xcworkspace \
  -configuration Debug \
  -derivedDataPath build \
  -quiet \
  clean build
