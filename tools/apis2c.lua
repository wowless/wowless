local function skip(v)
  if v.impl or v.stdlib or v.alias or v.debug then
    return true
  end
  local inskips = {
    Actor = true,
    ModelScene = true,
    Texture = true,
  }
  for _, input in ipairs(v.inputs or {}) do
    if inskips[input.type] or type(input.type) == 'table' then
      return true
    end
  end
  for _, output in ipairs(v.outputs or {}) do
    if (output.type.arrayof or output.type.structure) and (not output.nilable or output.stub) then
      return true
    end
    if output.type == 'table' and output.stub then
      return true
    end
  end
  return false
end
local sorted = require('pl.tablex').sort
local p = arg[1]
local t = {}
print('#include <lauxlib.h>')
print('#include <lualib.h>')
local enums = dofile('runtime/products/' .. p .. '/globals.lua').Enum
for k, v in sorted((dofile('runtime/products/' .. p .. '/apis.lua'))) do
  if not skip(v) then
    local dot = k:find('%.')
    local ns = dot and k:sub(1, dot - 1) or ''
    local mn = k:sub((dot or 0) + 1)
    local fn = ('wowless_%s_%s'):format(p, k:gsub('%.', '__'))
    t[ns] = t[ns] or {}
    t[ns][mn] = fn
    print(('static int %s(lua_State *L) {'):format(fn))
    for i, input in ipairs(v.inputs or {}) do
      local opt = input.nilable or input.default ~= nil
      if input.type == 'number' then
        if opt then
          print(('  luaL_optnumber(L, %d, 0);'):format(i))
        else
          print(('  luaL_checknumber(L, %d);'):format(i))
        end
      elseif input.type == 'boolean' then
        if opt then
          print(('  luaL_argcheck(L, lua_isboolean(L, %d) || lua_isnoneornil(L, %d), %d, 0);'):format(i, i, i))
        else
          print(('  luaL_argcheck(L, lua_isboolean(L, %d), %d, 0);'):format(i, i))
        end
      elseif input.type == 'string' or input.type == 'unit' or input.type == 'uiAddon' then
        if opt then
          print(('  luaL_optstring(L, %d, 0);'):format(i))
        else
          print(('  luaL_checkstring(L, %d);'):format(i))
        end
      elseif input.type == 'table' then
        if opt then
          print(('  luaL_argcheck(L, lua_istable(L, %d) || lua_isnoneornil(L, %d), %d, 0);'):format(i, i, i))
        else
          print(('  luaL_argcheck(L, lua_istable(L, %d), %d, 0);'):format(i, i))
        end
      elseif input.type == 'function' then
        if opt then
          print(('  luaL_argcheck(L, lua_isfunction(L, %d) || lua_isnoneornil(L, %d), %d, 0);'):format(i, i, i))
        else
          print(('  luaL_argcheck(L, lua_isfunction(L, %d), %d, 0);'):format(i, i))
        end
      elseif input.type == 'unknown' then
        if not opt then
          print(('  luaL_argcheck(L, !lua_isnoneornil(L, %d), %d, 0);'):format(i, i))
        end
      else
        error('wat inputs ' .. k)
      end
    end
    local outputs = v.outputs or {}
    for _, output in ipairs(outputs) do
      local stub = output.stub or output.default
      if output.nilable and not stub then
        print('  lua_pushnil(L);')
      elseif output.type == 'number' then
        print(('  lua_pushnumber(L, %d);'):format(stub or 1))
      elseif output.type == 'boolean' then
        print(('  lua_pushboolean(L, %s);'):format(stub and 1 or 0))
      elseif output.type == 'string' then
        print(('  lua_pushstring(L, "%s");'):format(stub or ''))
      elseif output.type == 'nil' then
        print('  lua_pushnil(L);')
      elseif output.type == 'oneornil' then
        assert(stub == nil)
        print('  lua_pushnil(L);')
      elseif output.type == 'table' then
        print('  lua_newtable(L);')
        for sk, sv in pairs(stub or {}) do
          assert(type(sk) == 'string', 'weird table key ' .. k)
          if type(sv) == 'number' then
            print(('  lua_pushnumber(L, %d);'):format(sv))
            print(('  lua_setfield(L, -2, "%s");'):format(sk))
          else
            error('weird table value ' .. k)
          end
        end
      elseif output.type.enum then
        -- Unfortunately we cannot rely on the existence of a Meta enum,
        -- so we go fishing for the minimum value manually.
        local x
        for _, e in pairs(enums[output.type.enum]) do
          x = (not x or e < x) and e or x
        end
        print(('  lua_pushnumber(L, %d);'):format(stub or x))
      else
        error('wat outputs ' .. k)
      end
    end
    print(('  return %d;'):format(#outputs))
    print('}')
  end
end
for k, v in sorted(t) do
  print(('static struct luaL_Reg reg_%s[] = {'):format(k))
  for vk, vv in sorted(v) do
    print(('  { "%s", %s },'):format(vk, vv))
  end
  print('  { 0, 0 },')
  print('};')
end
print('static int register_apis(lua_State *L) {')
print('  luaL_argcheck(L, lua_istable(L, 1), 1, 0);')
print('  lua_settop(L, 1);')
for k in sorted(t) do
  if k == '' then
    print('  luaL_register(L, NULL, reg_);')
  else
    print('  lua_newtable(L);')
    print(('  luaL_register(L, NULL, reg_%s);'):format(k))
    print(('  lua_setfield(L, -2, "%s");'):format(k))
  end
end
print('  return 0;')
print('}')
print(('int luaopen_runtime_%s_capi(lua_State *L) {'):format(p))
print('  lua_pushcfunction(L, register_apis);')
print('  return 1;')
print('}')
