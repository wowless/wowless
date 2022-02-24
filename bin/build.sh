#!/bin/bash
set -e
(cd tainted-lua && cmake --preset linux && cmake --build --preset linux)
luarocks build --no-install
