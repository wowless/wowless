#!/bin/bash
loglevel=${1-100}
eval $($(dirname $0)/../.lua/bin/luarocks path)
lua -e "require 'wowless.loader'.run($loglevel)"
