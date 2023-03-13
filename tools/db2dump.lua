local db2 = require('wowless.db2')
local content = assert(require('pl.file').read(arg[1]))
local sig = assert(arg[2])
for row in db2.rows(content, sig) do
  require('pl.pretty').dump(row)
end
