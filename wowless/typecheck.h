#ifndef WOWLESS_TYPECHECK_H
#define WOWLESS_TYPECHECK_H

#include "lauxlib.h"
#include "lua.h"

static inline void wowless_stubcheckenum(lua_State *L, int idx) {
  if (lua_type(L, idx) != LUA_TNUMBER) {
    luaL_typerror(L, idx, lua_typename(L, LUA_TNUMBER));
  }
}

static inline void wowless_stubchecknilableenum(lua_State *L, int idx) {
  switch (lua_type(L, idx)) {
    case LUA_TNUMBER:
    case LUA_TNIL:
    case LUA_TNONE:
      return;
    default:
      luaL_typerror(L, idx, lua_typename(L, LUA_TNUMBER));
  }
}

static inline void wowless_stubchecknumber(lua_State *L, int idx) {
  luaL_checknumber(L, idx);
}

static inline void wowless_stubchecknilablenumber(lua_State *L, int idx) {
  switch (lua_type(L, idx)) {
    case LUA_TSTRING:
      luaL_checknumber(L, idx);
      return;
    case LUA_TNUMBER:
    case LUA_TNIL:
    case LUA_TNONE:
      return;
    default:
      luaL_typerror(L, idx, lua_typename(L, LUA_TNUMBER));
  }
}

static inline void wowless_stubcheckstring(lua_State *L, int idx) {
  if (!lua_isstring(L, idx)) {
    luaL_typerror(L, idx, lua_typename(L, LUA_TSTRING));
  }
}

static inline void wowless_stubchecknilablestring(lua_State *L, int idx) {
  switch (lua_type(L, idx)) {
    case LUA_TNONE:
    case LUA_TNIL:
    case LUA_TNUMBER:
    case LUA_TSTRING:
      return;
    default:
      luaL_typerror(L, idx, lua_typename(L, LUA_TSTRING));
  }
}

static inline void wowless_stubcheckboolean(lua_State *L, int idx) {
  if (lua_isnoneornil(L, idx)) {
    luaL_typerror(L, idx, lua_typename(L, LUA_TBOOLEAN));
  }
}

static inline void wowless_stubchecknilableboolean(lua_State *L, int idx) {}

static inline void wowless_stubcheckunit(lua_State *L, int idx) {
  if (lua_type(L, idx) != LUA_TSTRING) {
    luaL_typerror(L, idx, lua_typename(L, LUA_TSTRING));
  }
}

static inline void wowless_stubchecknilableunit(lua_State *L, int idx) {
  switch (lua_type(L, idx)) {
    case LUA_TNONE:
    case LUA_TNIL:
    case LUA_TSTRING:
      return;
    default:
      luaL_typerror(L, idx, lua_typename(L, LUA_TSTRING));
  }
}

static inline void wowless_stubcheckunknown(lua_State *L, int idx) {
  if (lua_isnoneornil(L, idx)) {
    luaL_argerror(L, idx, "value expected");
  }
}

static inline void wowless_stubchecknilableunknown(lua_State *L, int idx) {}

#endif /* WOWLESS_TYPECHECK_H */
