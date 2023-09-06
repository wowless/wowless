local t = assert(require('wowapi.yaml').parseFile(arg[1]))
io.output(arg[2])
io.write('return ')
io.write(require('pl.pretty').write(t))
