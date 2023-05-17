local product = unpack(arg)
local lualua = require('lualua')
local sqlitedb = require('lsqlite3').open(('build/products/%s/data.sqlite3'):format(product))

local function pushvalue(s, x)
  local tx = type(x)
  if tx == 'table' then
    s:newtable()
    for k, v in pairs(x) do
      pushvalue(s, k)
      pushvalue(s, v)
      s:rawset(-3)
    end
  elseif tx == 'string' then
    s:pushstring(x)
  elseif tx == 'number' then
    s:pushnumber(x)
  else
    error('cannot push value of type ' .. tx)
  end
end

local function toobject(s, k)
  assert(s:istable(k))
  s:rawgeti(k, 0)
  local t = s:touserdata(-1)
  s:pop(1)
  return t
end

local function CreateFrame(s)
  assert(s:tostring(1) == 'Frame')
  local name = not s:isnoneornil(2) and s:tostring(2) or nil
  local parent = not s:isnoneornil(3) and toobject(s, 3) or nil
  s:newtable()
  local t = s:newuserdata()
  s:rawseti(-2, 0)
  t.name = name
  t.parent = parent
  s:getfield(lualua.REGISTRYINDEX, 'WowlessFrameMT')
  s:setmetatable(-2)
  s:pushvalue(-1)
  t.ref = s:ref(lualua.REGISTRYINDEX)
  return 1
end

local frameindex = {
  GetName = function(s)
    local t = toobject(s, 1)
    if t.name then
      s:pushstring(t.name)
      return 1
    end
  end,
  GetParent = function(s)
    local t = toobject(s, 1)
    if t.parent then
      s:rawgeti(lualua.REGISTRYINDEX, t.parent.ref)
      return 1
    end
  end,
}

local s = lualua.newstate()
for tag, text in sqlitedb:urows('SELECT BaseTag, TagText_lang FROM GlobalStrings') do
  s:pushstring(text)
  s:setglobal(tag)
end
for k, v in pairs(require(('build.data.products.%s.globals'):format(product))) do
  pushvalue(s, v)
  s:setglobal(k)
end
s:newtable()
s:newtable()
for k, v in pairs(frameindex) do
  s:pushcfunction(v)
  s:setfield(-2, k)
end
s:setfield(-2, '__index')
s:setfield(lualua.REGISTRYINDEX, 'WowlessFrameMT')
s:pushcfunction(CreateFrame)
s:setglobal('CreateFrame')
s:openlibs()
s:loadstring([[
  local f = CreateFrame('Frame', 'ThisIsMyVerySpecialFrame')
  assert(f:GetName() == 'ThisIsMyVerySpecialFrame')
  local g = CreateFrame('Frame', nil, f)
  assert(g:GetName() == nil)
  assert(f ~= g)
  assert(f:GetParent() == nil)
  assert(g:GetParent() == f)
]])
s:call(0, 0)

--[==[
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
]==]
--
