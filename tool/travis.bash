#!/bin/bash
cd "$(git rev-parse --show-toplevel)"
pub get
dartanalyzer . # TODO: move this back into success check
pub run dart_style:format -n test/ lib/ example/ && \
[[ "$(pub run dart_style:format -n test/ lib/ example/ | grep -c .dart)" -eq "0" ]] && \ # TODO: Simplify this!
pub run test -p "chrome,vm" test/unit/browser_test_runner.dart test/unit/core_test_runner.dart # TODO: add option to specify test runner files
# TODO: add converage back
# if [ "$TEST_ENV" = "travis" ]; then
#   DARTIUM_EXPIRATION_TIME="1577836800" DART_FLAGS=--checked xvfb-run -s '-screen 0 1024x768x24' pub run dart_dev coverage --no-html
# else
#   DARTIUM_EXPIRATION_TIME="1577836800" DART_FLAGS=--checked pub run dart_dev coverage --no-html
# fi