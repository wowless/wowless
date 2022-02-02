local function mixin(t, ...)
  for _, kv in ipairs({ ... }) do
    for k, v in pairs(kv) do
      t[k] = v
    end
  end
  return t
end

local function recursiveMixin(t, u, failOnOverwrite)
  for k, v in pairs(u) do
    local tv = t[k]
    if tv == nil or type(tv) ~= 'table' or type(v) ~= 'table' then
      assert(tv == nil or not failOnOverwrite, ('overwriting %q'):format(k))
      t[k] = v
    else
      recursiveMixin(tv, v, failOnOverwrite)
    end
  end
  return t
end

local readfile = (function()
  local lfs = require('lfs')
  local path = require('path')
  local cachedDirs = {}
  local nameCache = {}
  local function cacheDir(dir)
    if not cachedDirs[dir] then
      cachedDirs[dir] = true
      cacheDir(path.dirname(dir))
      if dir == '' then
        for f in lfs.dir('.') do
          nameCache[f:lower()] = f
        end
      else
        local rdir = assert(nameCache[dir], 'unknown directory ' .. dir)
        for f in lfs.dir(rdir) do
          local fn = path.join(rdir, f)
          nameCache[fn:lower()] = fn
        end
      end
    end
  end
  local function resolveCase(name)
    local lname = name:lower()
    cacheDir(path.dirname(lname))
    return assert(nameCache[lname], 'unknown file ' .. name)
  end
  return function(filename)
    local fn = resolveCase(path.normalize(filename))
    local f = assert(io.open(fn:gsub('\\', '/'), 'rb'))
    local content = f:read('*all')
    f:close()
    if content:sub(1, 3) == '\239\187\191' then
      content = content:sub(4)
    end
    return content
  end
end)()

local function strjoin(sep, ...)
  return table.concat({ ... }, sep)
end

local function strsplit(sep, s, n)
  assert(string.len(sep) == 1)
  n = n or math.huge
  local result = {}
  while true do
    local pos = string.find(s, '%' .. sep)
    if not pos or #result == n - 1 then
      table.insert(result, s)
      return unpack(result)
    end
    table.insert(result, s:sub(0, pos - 1))
    s = s:sub(pos + 1)
  end
end

local function strtrim(s)
  local ret = s:gsub('^%s*', ''):gsub('%s*$', '')
  return ret
end

local function tappend(t, t2)
  for _, v in ipairs(t2) do
    table.insert(t, v)
  end
  return t
end

local function twipe(t)
  for k in pairs(t) do
    t[k] = nil
  end
  return t
end

return {
  mixin = mixin,
  readfile = readfile,
  recursiveMixin = recursiveMixin,
  strjoin = strjoin,
  strsplit = strsplit,
  strtrim = strtrim,
  tappend = tappend,
  twipe = twipe,
}
