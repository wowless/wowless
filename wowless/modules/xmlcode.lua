local path = require('path')

return function(bindings, datalua)
  local function LoadChunk(str, filename, line)
    local pre = line and string.rep('\n', line - 1) or ''
    return assert(loadstring_untainted(pre .. str, '@' .. path.normalize(filename):gsub('/', '\\')))
  end
  return require('build.products.' .. datalua.product .. '.xmlcode')(bindings.bindings, LoadChunk)
end
