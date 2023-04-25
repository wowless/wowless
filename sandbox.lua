local product = unpack(arg)

local lualua = require('lualua')
local s = lualua.newstate()
s:openlibs()

local function mkfn(v)
  return function(ss)
    local outputs = v.outputs or {}
    ss:checkstack(#outputs)
    for _, output in ipairs(outputs) do
      if output.type == 'number' then
        ss:pushnumber(1)
      elseif output.type == 'boolean' then
        ss:pushboolean(false)
      elseif output.type == 'string' then
        ss:pushstring('')
      elseif output.type == 'oneornil' then
        ss:pushnil()
      elseif output.type == 'nil' then
        ss:pushnil()
      elseif output.type == 'unknown' then
        ss:pushnil()
      elseif output.type == 'table' then
        ss:newtable()
      elseif output.type.arrayof then
        ss:pushnumber(1)
      elseif output.type.structure then
        ss:pushnumber(1)
      elseif output.type.enum then
        ss:pushnumber(1)
      else
        error('invalid type ' .. output.type)
      end
    end
    return #outputs
  end
end

local apis = require('wowapi.yaml').parseFile('data/products/' .. product .. '/apis.yaml')
local globals, namespaces = {}, {}
for k, v in pairs(apis) do
  if not v.impl and not v.alias and not v.stdlib then
    local p = k:find('%.')
    if p then
      local ns = k:sub(1, p - 1)
      namespaces[ns] = namespaces[ns] or {}
      namespaces[ns][k:sub(p + 1)] = v
    else
      globals[k] = v
    end
  end
end
for k, v in pairs(globals) do
  s:pushcfunction(mkfn(v))
  s:setglobal('MooCow' .. k)
end
for nk, nv in pairs(namespaces) do
  s:newtable()
  for k, v in pairs(nv) do
    s:pushcfunction(mkfn(v))
    s:setfield(-2, k)
  end
  s:setglobal('CowMoo' .. nk)
end
s:loadstring([[
  for k, v in pairs(_G) do
    if k:sub(1, 6) == 'MooCow' then
      print(k, v())
    elseif k:sub(1, 6) == 'CowMoo' then
      for kk, vv in pairs(v) do
        print(k, kk, vv())
      end
    end
  end
]])
s:call(0, 0)
