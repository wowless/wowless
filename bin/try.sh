#!/bin/bash
eval $($(dirname $0)/../.lua/bin/luarocks path)
lua -e 'require "wowless.loader".run(100, false)'
