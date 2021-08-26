local loglevel = arg[1] and tonumber(arg[1]) or 0
local dir = 'extracts/' .. (arg[2] or 'wow_classic') .. '/Interface'
local version = arg[3] or 'TBC'

require('wowless.runner').run(loglevel, dir, version)
