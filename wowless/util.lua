local function mixin(t, ...)
  for _, kv in ipairs({ ... }) do
    for k, v in pairs(kv) do
      t[k] = v
    end
  end
  return t
end

local readfile = (function()
  local lfs = require('lfs')
  local function dirtab(dir, t)
    for f in lfs.dir(dir .. '/') do
      local ff = dir .. '/' .. f
      local k = f:lower()
      if lfs.attributes(ff, 'mode') ~= 'directory' then
        assert(t[k] == nil, 'multiple directory entries called ' .. ff)
        t[k] = ff
      elseif f ~= '.' and f ~= '..' then
        assert(type(t[k]) ~= 'string', 'multiple directory entries called ' .. ff)
        t[k] = t[k] or {}
        table.insert(t[k], ff)
      end
    end
  end
  local cache = {}
  dirtab('', cache)
  local function resolve(p)
    local c = cache
    local dd = ''
    for k in p:gmatch('[^/]+') do
      assert(type(c) == 'table', dd .. ' is not a directory')
      dd = dd .. '/' .. k
      local ck = c[k]
      assert(ck ~= nil, 'unknown ' .. dd)
      if type(ck) == 'table' and type(next(ck)) == 'number' then
        local t = {}
        for _, d in ipairs(ck) do
          dirtab(d, t)
        end
        c[k] = t
        ck = t
      end
      c = ck
    end
    return c
  end
  local function getContent(fn)
    local f = assert(io.open(fn, 'rb'))
    local content = f:read('*all')
    f:close()
    if content:sub(1, 3) == '\239\187\191' then
      content = content:sub(4)
    end
    return content
  end
  local path = require('path')
  return function(filename)
    local fullname = path.normalize(path.join(path.currentdir(), filename))
    return getContent(resolve(fullname:lower()))
  end
end)()

local function tget(t, s)
  local dot = s:find('%.')
  if dot then
    local p = s:sub(1, dot - 1)
    return t[p] and t[p][s:sub(dot + 1)]
  else
    return t[s]
  end
end

local function tset(t, s, v)
  local dot = s:find('%.')
  if dot then
    local p = s:sub(1, dot - 1)
    t[p] = t[p] or {}
    t[p][s:sub(dot + 1)] = v
  else
    t[s] = v
  end
  return t
end

return {
  mixin = mixin,
  readfile = readfile,
  tget = tget,
  tset = tset,
}
