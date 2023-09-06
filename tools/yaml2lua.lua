local t = assert(require('wowapi.yaml').parseFile(arg[1]))
local s = 'return ' .. require('pl.pretty').write(t)
require('pl.file').write(arg[2], s)
