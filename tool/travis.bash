#!/bin/bash
cd "$(git rev-parse --show-toplevel)"
pub get --packages-dir
pub run dart_dev format --check && \
pub run dart_dev analyze && \
pub run dart_dev test -p vm -p chrome && \
if [ "$TEST_ENV" = "travis"]; then
  DARTIUM_EXPIRATION_TIME="1577836800" DART_FLAGS=--checked xvfb-run -s '-screen 0 1024x768x24' pub run dart_dev coverage --no-html
else
  DARTIUM_EXPIRATION_TIME="1577836800" DART_FLAGS=--checked pub run dart_dev coverage --no-html
fi