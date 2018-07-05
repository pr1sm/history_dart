#!/bin/bash
cd "$(git rev-parse --show-toplevel)"
pub run dart_dev format --check && \
pub run dart_dev analyze && \
pub run dart_dev test -p vm -p chrome && \
pub run dart_dev coverage --no-html