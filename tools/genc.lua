local product = arg[1]
local datalua = require('build.products.' .. product .. '.data')
local structures = require('build.structures')
local sorted = require('pl.tablex').sort
local t = {}
local function e(s)
  table.insert(t, s)
end
e('#include <lua.h>')
e('#include <lauxlib.h>')
e('')
e('struct wowapi_function {')
e('  const char* name;')
e('  lua_CFunction func;')
e('  const char* luaimpl;')
e('};')
e('')
local namespaces, globals = {}, {}
for name, cfg in pairs(datalua.apis) do
  cfg.impl = datalua.impls[name]
  local pos = name:find('%.')
  if pos then
    local ns = name:sub(1, pos - 1)
    namespaces[ns] = namespaces[ns] or {}
    namespaces[ns][name:sub(pos + 1)] = cfg
  else
    globals[name] = cfg
  end
end
local function emitFunc(name, cfg)
  e(('static int wowapi_%s(lua_State *L) {'):format(name))
  if cfg.inputs and #cfg.inputs == 1 then -- TODO dump multi-input configs
    for i, param in ipairs(cfg.inputs[1]) do
      if param.type == 'number' and not param.nilable then
        e(('  lua_Number arg%d = luaL_checknumber(L, %d);'):format(i, i))
      elseif param.type == 'string' and not param.nilable then
        e(('  const char *arg%d = luaL_checkstring(L, %d);'):format(i, i))
      elseif param.type == 'boolean' and not param.nilable then
        e(('  int arg%d = lua_toboolean(L, %d);'):format(i, i))
      elseif (param.type == 'table' or structures[param.type]) and not param.nilable then
        e(('  luaL_checktype(L, %d, LUA_TTABLE);'):format(i))
      elseif param.type == 'unknown' and not param.nilable then
        e(('  if (lua_type(L, %d) == LUA_TNIL) {'):format(i))
        e(('    luaL_typerror(L, %d, "non-nil");'):format(i))
        e('  }')
      elseif param.type == 'unit' and not param.nilable then
        e(('  const char *arg%d = luaL_checkstring(L, %d);'):format(i, i))
      elseif not param.nilable and param.type == 'unknown' then
        error('invalid param on ' .. cfg.name)
      end
    end
  end
  if cfg.status == 'implemented' then
    e('  lua_pushvalue(L, lua_upvalueindex(1));')
    e('  lua_insert(L, 1);')
    e('  lua_call(L, lua_gettop(L) - 1, LUA_MULTRET);')
    e('  return lua_gettop(L);')
  elseif cfg.outputs then
    for _, out in ipairs(cfg.outputs) do
      if out.stub or out.default then
        local value = out.stub or out.default
        local ty = type(value)
        if ty == 'number' then
          e(('  lua_pushnumber(L, %d);'):format(value))
        elseif ty == 'boolean' then
          e(('  lua_pushboolean(L, %d);'):format(value and 1 or 0))
        elseif ty == 'string' then
          e(('  lua_pushlstring(L, "%s", %d);'):format(value, #value))
        elseif ty == 'table' then
          e('  lua_newtable(L);')
          -- TODO populate
        else
          error('wat ' .. ty)
        end
      elseif out.nilable or out.type == 'nil' then
        e('  lua_pushnil(L);')
      elseif out.type == 'number' then
        e('  lua_pushnumber(L, 1);')
      elseif out.type == 'string' then
        e('  lua_pushlstring(L, "", 0);')
      elseif out.type == 'boolean' then
        e('  lua_pushboolean(L, 1);')
      elseif out.type == 'table' then
        e('  lua_newtable(L);')
      else
        --error(out.type)
        e('  lua_pushnil(L); /* lies */')
      end
    end
    e(('  return %d;'):format(#cfg.outputs))
  else
    e('  return 0;')
  end
  e('}')
  e('')
end
local function quote(s)
  return s:gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n')
end
for ns, nsv in sorted(namespaces) do
  for apiname, apicfg in sorted(nsv) do
    emitFunc(ns .. '_' .. apiname, apicfg)
  end
  e(('static struct wowapi_function wowapi_%s_index[] = {'):format(ns))
  for apiname, apicfg in sorted(nsv) do
    e(
      ('  {"%s", wowapi_%s, "%s"},'):format(
        apiname,
        ns .. '_' .. apiname,
        quote(apicfg.impl or apicfg.stub or 'return')
      )
    )
  end
  e('  {NULL, NULL, NULL},')
  e('};')
  e('')
end
for apiname, apicfg in sorted(globals) do
  emitFunc(apiname, apicfg)
end
e('static struct wowapi_function wowapi_index[] = {')
for apiname, apicfg in sorted(globals) do
  e(('  {"%s", wowapi_%s, "%s"},'):format(apiname, apiname, quote(apicfg.impl or apicfg.stub or 'return')))
end
e('  {NULL, NULL, NULL},')
e('};')
e('')
e('struct wowapi_namespace {')
e('  const char *name;')
e('  const struct wowapi_function *index;')
e('};')
e('')
e('static struct wowapi_namespace wowapi_namespaces[] = {')
for ns in sorted(namespaces) do
  e(('  {"%s", wowapi_%s_index},'):format(ns, ns))
end
e('  {NULL, NULL},')
e('};')
e('')
e(('int luaopen_build_products_%s_wowapi(lua_State *L) {'):format(product))
e('  lua_newtable(L);')
e('  for (const struct wowapi_function *r = wowapi_index; r->name != NULL; ++r) {')
e('    if (luaL_loadstring(L, r->luaimpl) != 0) {')
e('      lua_error(L);')
e('    }')
e('    lua_pushcclosure(L, r->func, 1);')
e('    lua_setfield(L, -2, r->name);')
e('  }')
e('  for (const struct wowapi_namespace *ns = wowapi_namespaces; ns->name != NULL; ++ns) {')
e('    lua_newtable(L);')
e('    for (const struct wowapi_function *r = ns->index; r->name != NULL; ++r) {')
e('      if (luaL_loadstring(L, r->luaimpl) != 0) {')
e('        lua_error(L);')
e('      }')
e('      lua_pushcclosure(L, r->func, 1);')
e('      lua_setfield(L, -2, r->name);')
e('    }')
e('    lua_setfield(L, -2, ns->name);')
e('  }')
e('  return 1;')
e('}')
e('')
require('pl.file').write('build/products/' .. product .. '/wowapi.c', table.concat(t, '\n'))
