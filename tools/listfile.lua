local t = {}
local listfile = require('pl.file').read('vendor/listfile/community-listfile.csv')
for line in listfile:gmatch('[^\r\n]+') do
  local id, name = line:match('(%d+);dbfilesclient/([a-z0-9-_]+).db2')
  if id then
    t[name] = tonumber(id)
  end
end

local u = require('tools.util')
u.writeifchanged(arg[1], u.returntable(t))
