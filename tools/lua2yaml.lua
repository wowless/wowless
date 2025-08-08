local t = assert(dofile(arg[1]))
local s = require('wowapi.yaml').pprint(t)
assert(require('pl.dir').makepath(require('pl.path').dirname(arg[2])))
assert(require('pl.file').write(arg[2], s))
