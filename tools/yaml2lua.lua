local t = assert(require('wowapi.yaml').parseFile(arg[1]))
local s = 'return ' .. require('pl.pretty').write(t)
assert(require('pl.dir').makepath(require('pl.path').dirname(arg[2])))
assert(require('pl.file').write(arg[2], s))
