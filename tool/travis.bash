#!/bin/bash

# Go to root directory (for consistency)
cd "$(git rev-parse --show-toplevel)"

# Run pub get
pub get

# Run Analyzer and error if it fails
dart tool/runAnalyzer.dart || exit 1;

# Run Format check and error if it fails
dart tool/runFormat.dart || exit 2;

# Run Tests
pub run build_runner test -- --reporter=expanded -p "chrome,vm" test/unit/browser_runner_test.dart test/unit/core_runner_test.dart # TODO: add option to specify test runner files
# TODO: add converage back when it becomes available https://github.com/dart-lang/coverage/issues/229
# if [ "$TEST_ENV" = "travis" ]; then
#   DARTIUM_EXPIRATION_TIME="1577836800" DART_FLAGS=--checked xvfb-run -s '-screen 0 1024x768x24' pub run dart_dev coverage --no-html
# else
#   DARTIUM_EXPIRATION_TIME="1577836800" DART_FLAGS=--checked pub run dart_dev coverage --no-html
# fi