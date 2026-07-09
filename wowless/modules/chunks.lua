local path = require('path')

return function()
  local function LoadChunk(str, filename, line)
    local function doload()
      local pre = line and string.rep('\n', line - 1) or ''
      return loadstring_untainted(pre .. str, '@' .. path.normalize(filename):gsub('/', '\\'))
    end
    if filename:find('Wowless') then
      debug.setstacktaint('Wowless')
      debug.settaintmode('rw')
      local fn = doload()
      debug.settaintmode('disabled')
      debug.setstacktaint(nil)
      return assert(fn)
    else
      return assert(doload())
    end
  end
  return {
    LoadChunk = LoadChunk,
  }
end
