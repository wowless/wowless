local t = assert(require('wowapi.yaml').parseFile(arg[1]))
local tu = require('tools.util')
assert(require('pl.dir').makepath(require('pl.path').dirname(arg[2])))
assert(require('pl.file').write(arg[2], tu.returntable(t)))
