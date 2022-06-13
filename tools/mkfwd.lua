local n = arg[1]
local nn = arg[2] or n
local w = require('pl.file').write
local f = string.format
w(f('data/api/%s.yaml', n), f('---\nname: %s\nstatus: implemented\n', n))
w(f('data/impl/%s.lua', n), f('return %s(...)\n', nn))
