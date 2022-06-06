#!/bin/bash
set -e
bin/build.sh
lua tools/gentest.lua
busted -- "$@"
