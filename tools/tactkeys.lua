local wowtxt = require('pl.file').read('vendor/tactkeys/WoW.txt')
local t = {}
for line in wowtxt:gmatch('[^\r\n]+') do
  local k, v = line:match('^([0-9A-F]+) ([0-9A-F]+)')
  t[k:lower()] = v:lower()
end
local u = require('tools.util')
u.writeifchanged(arg[1], u.returntable(t))
