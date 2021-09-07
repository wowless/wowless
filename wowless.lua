local tag = arg[2] or 'wow_classic'
local api = require('wowless.runner').run({
  loglevel = arg[1] and tonumber(arg[1]) or 0,
  dir = 'extracts/' .. tag .. '/Interface',
  version = arg[3] or 'TBC',
  otherAddonDirs = { arg[4] },
})
if api.GetErrorCount() ~= 0 then
  io.stderr:write('failure on ' .. tag .. '\n')
  os.exit(1)
end
