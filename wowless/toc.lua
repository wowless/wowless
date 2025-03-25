local flavors = require('runtime.flavors')
local path = require('path')
local readfile = require('wowless.util').readfile

local function mksuffixes(flavor)
  local t = {
    '_' .. flavor,
    '-' .. flavor,
  }
  for _, alt in ipairs(flavors[flavor].alternates) do
    table.insert(t, '_' .. alt)
    table.insert(t, '-' .. alt)
  end
  table.insert(t, '_Standard')
  table.insert(t, '-Standard')
  table.insert(t, '')
  return t
end

return function(flavor)
  local suffixes = mksuffixes(flavor)

  local function resolve(dir)
    local base = path.basename(dir)
    for _, suffix in ipairs(suffixes) do
      local file = path.join(dir, base .. suffix .. '.toc')
      local success, content = pcall(readfile, file)
      if success then
        return file, content
      end
    end
  end

  return {
    resolve = resolve,
  }
end
