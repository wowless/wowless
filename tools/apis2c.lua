local function skip(k, v)
  if v.impl or v.stdlib or v.alias or k:find('%.') then
    return true
  end
  for _, input in ipairs(v.inputs or {}) do
    if input.type == 'Texture' or input.type.enum then
      return true
    end
  end
  for _, output in ipairs(v.outputs or {}) do
    if (output.type.arrayof or output.type.structure) and not output.nilable then
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
for k, v in sorted((dofile('runtime/products/' .. p .. '/apis.lua'))) do
  if not skip(k, v) then
    t[k] = ('wowless_%s_%s'):format(p, k)
    print(('static int %s(lua_State *L) {'):format(t[k]))
    for i, input in ipairs(v.inputs or {}) do
      if input.type == 'number' then
        if input.nilable then
          print(('  luaL_optnumber(L, %d, 0);'):format(i))
        else
          print(('  luaL_checknumber(L, %d);'):format(i))
        end
      elseif input.type == 'boolean' then
        print(('  luaL_argcheck(L, lua_isboolean(L, %d), %d, 0);'):format(i, i))
      elseif input.type == 'string' or input.type == 'unit' or input.type == 'uiAddon' then
        if input.nilable then
          print(('  luaL_optstring(L, %d, 0);'):format(i))
        else
          print(('  luaL_checkstring(L, %d);'):format(i))
        end
      elseif input.type == 'table' then
        if input.nilable then
          print(('  luaL_argcheck(L, lua_istable(L, %d) || lua_isnoneornil(L, %d), %d, 0);'):format(i, i, i))
        else
          print(('  luaL_argcheck(L, lua_istable(L, %d), %d, 0);'):format(i, i))
        end
      elseif input.type == 'unknown' then
        if not input.nilable then
          print(('  luaL_argcheck(L, !lua_isnoneornil(L, %d), %d, 0);'):format(i, i))
        end
      else
        error('wat inputs ' .. k)
      end
    end
    local outputs = v.outputs or {}
    for _, output in ipairs(outputs) do
      if output.nilable and not output.stub then
        print('  lua_pushnil(L);')
      elseif output.type == 'number' then
        print(('  lua_pushnumber(L, %d);'):format(output.stub or 1))
      elseif output.type == 'boolean' then
        print(('  lua_pushboolean(L, %s);'):format(output.stub and 1 or 0))
      elseif output.type == 'string' then
        print(('  lua_pushstring(L, "%s");'):format(output.stub or ''))
      elseif output.type == 'nil' then
        print('  lua_pushnil(L);')
      elseif output.type == 'oneornil' then
        assert(output.stub == nil)
        print('  lua_pushnil(L);')
      elseif output.type == 'table' then
        print('  lua_newtable(L);')
        for sk, sv in pairs(output.stub or {}) do
          assert(type(sk) == 'string', 'weird table key ' .. k)
          if type(sv) == 'number' then
            print(('  lua_pushnumber(L, %d);'):format(sv))
            print(('  lua_setfield(L, -2, "%s");'):format(sk))
          else
            error('weird table value ' .. k)
          end
        end
      else
        error('wat outputs ' .. k)
      end
    end
    print(('  return %d;'):format(#outputs))
    print('}')
  end
end
print('static struct luaL_Reg regt[] = {')
for k, v in sorted(t) do
  print(('  { "%s", %s },'):format(k, v))
end
print('  { 0, 0 },')
print('};')
print('static int register_apis(lua_State *L) {')
print('  luaL_argcheck(L, lua_istable(L, 1), 1, 0);')
print('  lua_settop(L, 1);')
print('  luaL_register(L, NULL, regt);')
print('  return 0;')
print('}')
print(('int luaopen_runtime_%s_capi(lua_State *L) {'):format(p))
print('  lua_pushcfunction(L, register_apis);')
print('  return 1;')
print('}')
