return function(datalua, loadercfg)
  local util = require('wowless.util')
  if loadercfg.vfs ~= 'proxy' then
    return { readFile = util.readfile }
  end
  local rootDir = assert(loadercfg.rootDir, 'proxy vfs requires rootDir')
  local prefix = rootDir:gsub('\\', '/'):lower()
  if prefix:sub(-1) ~= '/' then
    prefix = prefix .. '/'
  end
  local fetch = require('tools.tactfull').open(datalua.product, datalua.build.hash)
  return {
    readFile = function(filename)
      local norm = filename:gsub('\\', '/'):lower()
      if norm:sub(1, #prefix) == prefix then
        local data = assert(fetch(filename:sub(#prefix + 1)), 'not found via proxy: ' .. filename)
        if data:sub(1, 3) == '\239\187\191' then
          data = data:sub(4)
        end
        return data
      end
      return util.readfile(filename)
    end,
  }
end
