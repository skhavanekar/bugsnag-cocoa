#!/usr/bin/env bash

osascript -e 'quit app "macOSTestApp"'
open features/fixtures/macos-swift-cocoapods/build/Build/Products/Debug/macOSTestApp.app \
    --args "EVENT_TYPE=$EVENT_TYPE" \
    "EVENT_MODE=$EVENT_MODE" \
    "EVENT_DELAY=$EVENT_DELAY" \
    "BUGSNAG_API_KEY=$BUGSNAG_API_KEY" \
    "MOCK_API_PORT=$MOCK_API_PORT"
