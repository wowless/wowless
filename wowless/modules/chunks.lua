local path = require('path')

return function()
  local function LoadChunk(str, filename, line, taint)
    local pre = line and string.rep('\n', line - 1) or ''
    debug.setstacktaint(taint)
    debug.settaintmode('rw')
    local fn = assert(loadstring_untainted(pre .. str, '@' .. path.normalize(filename):gsub('/', '\\')))
    debug.settaintmode('disabled')
    debug.setstacktaint(nil)
    return fn
  end
  return {
    LoadChunk = LoadChunk,
  }
end
