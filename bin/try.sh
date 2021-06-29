#!/bin/bash
loglevel=${1-100}
eval $($(dirname $0)/../.lua/bin/luarocks path)
lua <<EOF
local api = require('wowless.loader').run($loglevel)
api.SendEvent('PLAYER_LOGIN')
api.SendEvent('PLAYER_ENTERING_WORLD')
EOF
