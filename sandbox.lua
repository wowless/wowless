local product = unpack(arg)
local lualua = require('lualua')
local sqlitedb = require('lsqlite3').open(('build/products/%s/data.sqlite3'):format(product))
local datalua = require(('build.products.%s.data'):format(product))

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

local globalfns = {
  CreateFrame = function(s)
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
  end,
}

local function MixinForStubs(s)
  s:settop(2)
  s:rawget(lualua.GLOBALSINDEX)
  s:pushnil()
  while s:next(2) do
    s:pushvalue(3)
    s:insert(4)
    s:settable(1)
  end
  s:pop(1)
  return 1
end

local function pushapi(s, api)
  if api.stub then
    s:loadstring('local Mixin = ...; return function() ' .. api.stub .. ' end')
    s:pushvalue(1)
    s:call(1, 1)
  else
    s:loadstring('')
  end
end

local s = lualua.newstate()
for tag, text in sqlitedb:urows('SELECT BaseTag, TagText_lang FROM GlobalStrings') do
  s:pushstring(text)
  s:setglobal(tag)
end
for k, v in pairs(datalua.globals) do
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
do
  local gapis, nsapis = {}, {}
  for k, v in pairs(datalua.apis) do
    local p = k:find('%.')
    if p then
      local ns = k:sub(1, p - 1)
      nsapis[ns] = nsapis[ns] or {}
      nsapis[ns][k:sub(p + 1)] = v
    else
      gapis[k] = v
    end
  end
  s:pushcfunction(MixinForStubs)
  for k, v in pairs(gapis) do
    pushapi(s, v)
    s:setglobal(k)
  end
  for ns, apis in pairs(nsapis) do
    s:newtable()
    for k, v in pairs(apis) do
      pushapi(s, v)
      s:setfield(-2, k)
    end
    s:setglobal(ns)
  end
  s:pop(1)
end
for k, v in pairs(globalfns) do
  s:pushcfunction(v)
  s:setglobal(k)
end
s:openlibs()
s:loadstring([[
  local f = CreateFrame('Frame', 'ThisIsMyVerySpecialFrame')
  assert(f:GetName() == 'ThisIsMyVerySpecialFrame')
  local g = CreateFrame('Frame', nil, f)
  assert(g:GetName() == nil)
  assert(f ~= g)
  assert(f:GetParent() == nil)
  assert(g:GetParent() == f)
  print((C_CreatureInfo.GetFactionInfo or GetFactionInfo)(1))
  print(C_ArtifactUI.GetAppearanceInfo(1, 1))
  Vector3DMixin = { rofl = 'copter' }
  for k, v in pairs(C_Commentator.GetStartLocation(1)) do
    print(k, v)
  end
]])
s:call(0, 0)
