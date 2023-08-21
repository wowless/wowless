#!/bin/sh
set -ex
git submodule update --init --depth 1
python3 -m venv env
# shellcheck source=/dev/null
. env/bin/activate
python3 -m pip install -r requirements.txt
hererocks -l 5.1.5 -r 3.8.0 env
luarocks build
lua tools/mkninja.lua
