local f = io.open(arg[2], 'wb')
f:write(require('wowless.png').write(require('wowless.blp').read(arg[1])))
f:close()
