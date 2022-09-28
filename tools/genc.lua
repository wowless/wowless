local product = arg[1]
local parseYaml = require('wowapi.yaml').parseFile
local structures = require('build.structures')
local sorted = require('pl.tablex').sort
local t = {}
table.insert(t, '#include <lua.h>')
table.insert(t, '#include <lauxlib.h>')
table.insert(t, '')
local apiscfg = parseYaml('data/products/' .. product .. '/apis.yaml')
local namespaces, globals = {}, {}
for apiname, apidataname in pairs(apiscfg) do
  local apicfg = parseYaml('data/api/' .. apidataname .. '.yaml')
  local pos = apiname:find('%.')
  if pos then
    local ns = apiname:sub(1, pos - 1)
    namespaces[ns] = namespaces[ns] or {}
    namespaces[ns][apiname:sub(pos + 1)] = apicfg
  else
    globals[apiname] = apicfg
  end
end
local function emitFunc(name, cfg)
  table.insert(t, ('static int wowapi_%s(lua_State *L) {'):format(name))
  if cfg.inputs and #cfg.inputs == 1 then -- TODO dump multi-input configs
    for i, param in ipairs(cfg.inputs[1]) do
      if param.type == 'number' and not param.nilable then
        table.insert(t, ('  lua_Number arg%d = luaL_checknumber(L, %d);'):format(i, i))
      elseif param.type == 'string' and not param.nilable then
        table.insert(t, ('  const char *arg%d = luaL_checkstring(L, %d);'):format(i, i))
      elseif param.type == 'boolean' and not param.nilable then
        table.insert(t, ('  int arg%d = lua_toboolean(L, %d);'):format(i, i))
      elseif (param.type == 'table' or structures[param.type]) and not param.nilable then
        table.insert(t, ('  luaL_checktype(L, %d, LUA_TTABLE);'):format(i))
      elseif param.type == 'unknown' and not param.nilable then
        table.insert(t, ('  if (lua_type(L, %d) == LUA_TNIL) {'):format(i))
        table.insert(t, ('    luaL_typerror(L, %d, "non-nil");'):format(i))
        table.insert(t, '  }')
      elseif param.type == 'unit' and not param.nilable then
        table.insert(t, ('  const char *arg%d = luaL_checkstring(L, %d);'):format(i, i))
      elseif not param.nilable and param.type == 'unknown' then
        error('invalid param on ' .. cfg.name)
      end
    end
  end
  if cfg.status == 'implemented' then
    table.insert(t, '  /* TODO invoke implementation */')
  elseif cfg.outputs then
    for _, out in ipairs(cfg.outputs) do
      if out.stub or out.default then
        local value = out.stub or out.default
        local ty = type(value)
        if ty == 'number' then
          table.insert(t, ('  lua_pushnumber(L, %d);'):format(value))
        elseif ty == 'boolean' then
          table.insert(t, ('  lua_pushboolean(L, %d);'):format(value and 1 or 0))
        elseif ty == 'string' then
          table.insert(t, ('  lua_pushlstring(L, "%s", %d);'):format(value, #value))
        elseif ty == 'table' then
          table.insert(t, '  lua_newtable(L);')
          -- TODO populate
        else
          error('wat ' .. ty)
        end
      elseif out.nilable or out.type == 'nil' then
        table.insert(t, '  lua_pushnil(L);')
      elseif out.type == 'number' then
        table.insert(t, '  lua_pushnumber(L, 1);')
      elseif out.type == 'string' then
        table.insert(t, '  lua_pushlstring(L, "", 0);')
      elseif out.type == 'boolean' then
        table.insert(t, '  lua_pushboolean(L, 1);')
      elseif out.type == 'table' then
        table.insert(t, '  lua_newtable(L);')
      else
        --error(out.type)
        table.insert(t, '  lua_pushnil(L); /* lies */')
      end
    end
    table.insert(t, ('  return %d;'):format(#cfg.outputs))
  else
    table.insert(t, '  return 0;')
  end
  table.insert(t, '}')
  table.insert(t, '')
end
for ns, nsv in sorted(namespaces) do
  for apiname, apicfg in sorted(nsv) do
    emitFunc(ns .. '_' .. apiname, apicfg)
  end
  table.insert(t, ('static struct luaL_Reg wowapi_%s_index[] = {'):format(ns))
  for apiname in sorted(nsv) do
    table.insert(t, ('  {"%s", wowapi_%s},'):format(apiname, ns .. '_' .. apiname))
  end
  table.insert(t, '  {NULL, NULL},')
  table.insert(t, '};')
  table.insert(t, '')
end
for apiname, apicfg in sorted(globals) do
  emitFunc(apiname, apicfg)
end
table.insert(t, 'static struct luaL_Reg wowapi_index[] = {')
for apiname in sorted(globals) do
  table.insert(t, ('  {"%s", wowapi_%s},'):format(apiname, apiname))
end
table.insert(t, '  {NULL, NULL},')
table.insert(t, '};')
table.insert(t, '')
table.insert(t, 'struct wowapi_namespace {')
table.insert(t, '  char *name;')
table.insert(t, '  luaL_Reg *index;')
table.insert(t, '};')
table.insert(t, '')
table.insert(t, 'static struct wowapi_namespace wowapi_namespaces[] = {')
for ns in sorted(namespaces) do
  table.insert(t, ('  {"%s", wowapi_%s_index},'):format(ns, ns))
end
table.insert(t, '  {NULL, NULL},')
table.insert(t, '};')
table.insert(t, '')
table.insert(t, ('int luaopen_build_products_%s_wowapi(lua_State *L) {'):format(product))
table.insert(t, '  lua_newtable(L);')
table.insert(t, '  for (luaL_Reg *r = wowapi_index; r->name != NULL; ++r) {')
table.insert(t, '    lua_pushcfunction(L, r->func);')
table.insert(t, '    lua_setfield(L, -2, r->name);')
table.insert(t, '  }')
table.insert(t, '  for (struct wowapi_namespace *ns = wowapi_namespaces; ns->name != NULL; ++ns) {')
table.insert(t, '    lua_newtable(L);')
table.insert(t, '    for (luaL_Reg *r = ns->index; r->name != NULL; ++r) {')
table.insert(t, '      lua_pushcfunction(L, r->func);')
table.insert(t, '      lua_setfield(L, -2, r->name);')
table.insert(t, '    }')
table.insert(t, '    lua_setfield(L, -2, ns->name);')
table.insert(t, '  }')
table.insert(t, '  return 1;')
table.insert(t, '}')
table.insert(t, '')
require('pl.file').write('build/products/' .. product .. '/wowapi.c', table.concat(t, '\n'))
