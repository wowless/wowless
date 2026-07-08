local path = require('path')

return function(security)
  local function LoadChunk(str, filename, line, taint, env, closureTaint, ...)
    local pre = line and string.rep('\n', line - 1) or ''
    debug.setstacktaint(taint)
    debug.settaintmode('rw')
    local fn = assert(loadstring_untainted(pre .. str, '@' .. path.normalize(filename):gsub('/', '\\')))
    debug.settaintmode('disabled')
    debug.setstacktaint(nil)
    if env then
      setfenv(fn, env)
    end
    debug.setnewclosuretaint(closureTaint)
    local results = { security.CallSandbox(fn, ...) }
    debug.setnewclosuretaint(nil)
    return unpack(results)
  end
  return {
    LoadChunk = LoadChunk,
  }
end
