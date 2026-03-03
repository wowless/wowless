-- Generates wowless/typecheck.h from data/types.yaml.
local types = assert(require('wowapi.yaml').parseFile('data/types.yaml'))
local sorted = require('pl.tablex').sort

local lines = {}
local function emit(fmt, ...)
  table.insert(lines, string.format(fmt, ...))
end
local function nl()
  table.insert(lines, '')
end

-- Map Lua type name -> C LUA_T* constant suffix (uppercase)
local lua_type_to_c = {
  boolean = 'BOOLEAN',
  ['function'] = 'FUNCTION',
  number = 'NUMBER',
  string = 'STRING',
  table = 'TABLE',
  userdata = 'USERDATA',
}

local function c_type(name)
  return assert(lua_type_to_c[name], 'unknown lua type: ' .. name)
end

emit('/* Generated from data/types.yaml by tools/gentypes.lua. */')
emit('#ifndef WOWLESS_TYPECHECK_H')
emit('#define WOWLESS_TYPECHECK_H')
nl()
emit('#include "lauxlib.h"')
emit('#include "lua.h"')

-- ---- Scalar type checkers ----
-- Emit non-nilable + nilable pair for each scalar (non-alias, non-per_type,
-- non-upvalue-generic) c_input type.

local function emit_scalar(name, tdef)
  local inp = tdef.c_input
  local kind = inp.kind

  local nilable_kind = (tdef.c_nilable or {}).kind

  if kind == 'exact' then
    local ct = c_type(inp.c_lua_type)
    nl()
    emit('static inline void wowless_stubcheck%s(lua_State *L, int idx) {', name)
    emit('  if (lua_type(L, idx) != LUA_T%s) {', ct)
    emit('    luaL_typerror(L, idx, lua_typename(L, LUA_T%s));', ct)
    emit('  }')
    emit('}')
    nl()
    emit('static inline void wowless_stubchecknilable%s(lua_State *L, int idx) {', name)
    emit('  switch (lua_type(L, idx)) {')
    emit('    case LUA_T%s:', ct)
    emit('    case LUA_TNIL:')
    emit('    case LUA_TNONE:')
    emit('      return;')
    emit('    default:')
    emit('      luaL_typerror(L, idx, lua_typename(L, LUA_T%s));', ct)
    emit('  }')
    emit('}')
  elseif kind == 'isstring' then
    -- accepts LUA_TSTRING and LUA_TNUMBER (mirrors lua_isstring behaviour)
    nl()
    emit('static inline void wowless_stubcheck%s(lua_State *L, int idx) {', name)
    emit('  if (!lua_isstring(L, idx)) {')
    emit('    luaL_typerror(L, idx, lua_typename(L, LUA_TSTRING));')
    emit('  }')
    emit('}')
    nl()
    emit('static inline void wowless_stubchecknilable%s(lua_State *L, int idx) {', name)
    emit('  switch (lua_type(L, idx)) {')
    emit('    case LUA_TNONE:')
    emit('    case LUA_TNIL:')
    emit('    case LUA_TNUMBER:')
    emit('    case LUA_TSTRING:')
    emit('      return;')
    emit('    default:')
    emit('      luaL_typerror(L, idx, lua_typename(L, LUA_TSTRING));')
    emit('  }')
    emit('}')
  elseif kind == 'checknumber' then
    nl()
    emit('static inline void wowless_stubcheck%s(lua_State *L, int idx) {', name)
    emit('  luaL_checknumber(L, idx);')
    emit('}')
    nl()
    if nilable_kind == 'also_string' then
      emit('static inline void wowless_stubchecknilable%s(lua_State *L, int idx) {', name)
      emit('  switch (lua_type(L, idx)) {')
      emit('    case LUA_TSTRING:')
      emit('      luaL_checknumber(L, idx);')
      emit('      return;')
      emit('    case LUA_TNUMBER:')
      emit('    case LUA_TNIL:')
      emit('    case LUA_TNONE:')
      emit('      return;')
      emit('    default:')
      emit('      luaL_typerror(L, idx, lua_typename(L, LUA_TNUMBER));')
      emit('  }')
      emit('}')
    else
      emit('static inline void wowless_stubchecknilable%s(lua_State *L, int idx) {', name)
      emit('  if (!lua_isnoneornil(L, idx)) {')
      emit('    luaL_checknumber(L, idx);')
      emit('  }')
      emit('}')
    end
  elseif kind == 'noneornil_error' then
    local ct = c_type(inp.c_error_type)
    nl()
    emit('static inline void wowless_stubcheck%s(lua_State *L, int idx) {', name)
    emit('  if (lua_isnoneornil(L, idx)) {')
    emit('    luaL_typerror(L, idx, lua_typename(L, LUA_T%s));', ct)
    emit('  }')
    emit('}')
    nl()
    -- nilable_kind should be 'noop' for these
    emit('static inline void wowless_stubchecknilable%s(lua_State *L, int idx) {}', name)
  elseif kind == 'nonnilvalue_error' then
    nl()
    emit('static inline void wowless_stubcheck%s(lua_State *L, int idx) {', name)
    emit('  if (lua_isnoneornil(L, idx)) {')
    emit('    luaL_argerror(L, idx, "value expected");')
    emit('  }')
    emit('}')
    nl()
    -- nilable_kind should be 'noop'
    emit('static inline void wowless_stubchecknilable%s(lua_State *L, int idx) {}', name)
  end
end

-- Emit scalars in sorted order so the output is deterministic.
for name, tdef in sorted(types) do
  local inp = tdef.c_input
  if inp then
    local kind = inp.kind
    if
      kind ~= 'alias'
      and kind ~= 'per_type'
      and kind ~= 'upvalue_luaobject'
      and kind ~= 'upvalue_uiobject'
      and kind ~= 'upvalue_stringenum'
    then
      emit_scalar(name, tdef)
    end
  end
end

-- ---- Generic parameterized-type checkers (luaobject, uiobject, stringenum) ----

nl()
emit('static inline void wowless_stubcheckluaobject(lua_State *L, int idx,')
emit('                                              const char *typename,')
emit('                                              size_t typenamelen) {')
emit('  idx = lua_absindex(L, idx);')
emit('  if (lua_type(L, idx) != LUA_TUSERDATA) {')
emit('    luaL_typerror(L, idx, "luaobject");')
emit('  }')
emit('  lua_getfield(L, lua_upvalueindex(1), "IsLuaObject");')
emit('  lua_pushvalue(L, idx);')
emit('  lua_pushlstring(L, typename, typenamelen);')
emit('  lua_call(L, 2, 1);')
emit('  if (!lua_toboolean(L, -1)) {')
emit('    luaL_typerror(L, idx, "luaobject");')
emit('  }')
emit('  lua_pop(L, 1);')
emit('}')
nl()
emit('static inline void wowless_stubchecknilableluaobject(lua_State *L, int idx,')
emit('                                                     const char *typename,')
emit('                                                     size_t typenamelen) {')
emit('  if (!lua_isnoneornil(L, idx)) {')
emit('    wowless_stubcheckluaobject(L, idx, typename, typenamelen);')
emit('  }')
emit('}')

nl()
emit('static inline void wowless_stubcheckuiobject(lua_State *L, int idx,')
emit('                                             const char *typename,')
emit('                                             size_t typenamelen) {')
emit('  idx = lua_absindex(L, idx);')
emit('  if (lua_type(L, idx) != LUA_TTABLE) {')
emit('    luaL_typerror(L, idx, "uiobject");')
emit('  }')
emit('  lua_rawgeti(L, idx, 0);')
emit('  if (lua_type(L, -1) != LUA_TUSERDATA) {')
emit('    luaL_typerror(L, idx, "uiobject");')
emit('  }')
emit('  lua_getfield(L, lua_upvalueindex(1), "IsUiObject");')
emit('  lua_insert(L, -2);')
emit('  lua_pushlstring(L, typename, typenamelen);')
emit('  lua_call(L, 2, 1);')
emit('  if (!lua_toboolean(L, -1)) {')
emit('    luaL_typerror(L, idx, "uiobject");')
emit('  }')
emit('  lua_pop(L, 1);')
emit('}')
nl()
emit('static inline void wowless_stubchecknilableuiobject(lua_State *L, int idx,')
emit('                                                    const char *typename,')
emit('                                                    size_t typenamelen) {')
emit('  if (!lua_isnoneornil(L, idx)) {')
emit('    wowless_stubcheckuiobject(L, idx, typename, typenamelen);')
emit('  }')
emit('}')

nl()
emit('static inline void wowless_stubcheckstringenum(lua_State *L, int idx,')
emit('                                               const char *enumname,')
emit('                                               size_t enumnamelen) {')
emit('  idx = lua_absindex(L, idx);')
emit('  luaL_checktype(L, idx, LUA_TSTRING);')
emit('  lua_getfield(L, lua_upvalueindex(1), "CheckStringEnum");')
emit('  lua_pushvalue(L, idx);')
emit('  lua_pushlstring(L, enumname, enumnamelen);')
emit('  lua_call(L, 2, 1);')
emit('  if (!lua_toboolean(L, -1)) {')
emit('    luaL_argerror(L, idx, "invalid string enum value");')
emit('  }')
emit('  lua_pop(L, 1);')
emit('}')
nl()
emit('static inline void wowless_stubchecknilablestringenum(lua_State *L, int idx,')
emit('                                                      const char *enumname,')
emit('                                                      size_t enumnamelen) {')
emit('  if (!lua_isnoneornil(L, idx)) {')
emit('    wowless_stubcheckstringenum(L, idx, enumname, enumnamelen);')
emit('  }')
emit('}')

-- ---- Object creation helpers ----

nl()
emit('static inline void wowless_stubcreateluaobject(lua_State *L,')
emit('                                               const char *typename,')
emit('                                               size_t typenamelen) {')
emit('  lua_getfield(L, lua_upvalueindex(1), "CreateLuaObject");')
emit('  lua_pushlstring(L, typename, typenamelen);')
emit('  lua_call(L, 1, 1);')
emit('}')

nl()
emit('static inline void wowless_stubcreateuiobject(lua_State *L,')
emit('                                              const char *typename,')
emit('                                              size_t typenamelen) {')
emit('  lua_getfield(L, lua_upvalueindex(1), "CreateUiObject");')
emit('  lua_pushlstring(L, typename, typenamelen);')
emit('  lua_call(L, 1, 1);')
emit('}')

-- ---- Utility helpers ----

nl()
emit('static inline void wowless_stubcheckextraargs(lua_State *L, int nsins,')
emit('                                              const char *fname) {')
emit('  if (lua_gettop(L) > nsins) {')
emit('    wowless_stub_log_extra_args(L, fname);')
emit('  }')
emit('}')

nl()
emit('static inline void wowless_stubchecknreturns(lua_State *L, int nret,')
emit('                                             int nexpected, const char *fname) {')
emit('  if (nret != nexpected) {')
emit('    luaL_error(L, "wrong number of return values to %s: want %s, got %s", fname,', '%q', '%d', '%d')
emit('               nexpected, nret);')
emit('  }')
emit('}')

nl()
emit('static inline void wowless_applymixin(lua_State *L, const char *mixin_name) {')
emit('  int tbl = lua_gettop(L);')
emit('  lua_getglobal(L, mixin_name);')
emit('  if (lua_type(L, -1) == LUA_TTABLE) {')
emit('    lua_pushnil(L);')
emit('    while (lua_next(L, tbl + 1)) {')
emit('      lua_pushvalue(L, -2);')
emit('      lua_insert(L, -3);')
emit('      lua_rawset(L, tbl);')
emit('    }')
emit('  }')
emit('  lua_pop(L, 1);')
emit('}')

nl()
emit('#endif /* WOWLESS_TYPECHECK_H */')

local outpath = 'wowless/typecheck.h'
assert(require('pl.dir').makepath(require('pl.path').dirname(outpath)))
assert(require('pl.file').write(outpath, table.concat(lines, '\n') .. '\n'))
