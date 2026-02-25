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

static inline void wowless_stubcheckfunction(lua_State *L, int idx) {
  if (lua_type(L, idx) != LUA_TFUNCTION) {
    luaL_typerror(L, idx, lua_typename(L, LUA_TFUNCTION));
  }
}

static inline void wowless_stubchecknilablefunction(lua_State *L, int idx) {
  switch (lua_type(L, idx)) {
    case LUA_TFUNCTION:
    case LUA_TNIL:
    case LUA_TNONE:
      return;
    default:
      luaL_typerror(L, idx, lua_typename(L, LUA_TFUNCTION));
  }
}

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

static inline void wowless_stubchecktable(lua_State *L, int idx) {
  if (lua_type(L, idx) != LUA_TTABLE) {
    luaL_typerror(L, idx, lua_typename(L, LUA_TTABLE));
  }
}

static inline void wowless_stubchecknilabletable(lua_State *L, int idx) {
  switch (lua_type(L, idx)) {
    case LUA_TTABLE:
    case LUA_TNIL:
    case LUA_TNONE:
      return;
    default:
      luaL_typerror(L, idx, lua_typename(L, LUA_TTABLE));
  }
}

static inline void wowless_stubcheckluaobject(lua_State *L, int idx,
                                              const char *typename,
                                              size_t typenamelen) {
  if (lua_type(L, idx) != LUA_TUSERDATA) {
    luaL_typerror(L, idx, "luaobject");
  }
  lua_getfield(L, lua_upvalueindex(1), "IsLuaObject");
  lua_pushvalue(L, idx);
  lua_pushlstring(L, typename, typenamelen);
  lua_call(L, 2, 1);
  if (!lua_toboolean(L, -1)) {
    luaL_typerror(L, idx, "luaobject");
  }
  lua_pop(L, 1);
}

static inline void wowless_stubchecknilableluaobject(lua_State *L, int idx,
                                                     const char *typename,
                                                     size_t typenamelen) {
  if (!lua_isnoneornil(L, idx)) {
    wowless_stubcheckluaobject(L, idx, typename, typenamelen);
  }
}

static inline void wowless_stubcheckuiobject(lua_State *L, int idx,
                                             const char *typename,
                                             size_t typenamelen) {
  if (lua_type(L, idx) != LUA_TTABLE) {
    luaL_typerror(L, idx, "uiobject");
  }
  lua_rawgeti(L, idx, 0);
  if (lua_type(L, -1) != LUA_TUSERDATA) {
    luaL_typerror(L, idx, "uiobject");
  }
  lua_getfield(L, lua_upvalueindex(1), "IsUiObject");
  lua_insert(L, -2);
  lua_pushlstring(L, typename, typenamelen);
  lua_call(L, 2, 1);
  if (!lua_toboolean(L, -1)) {
    luaL_typerror(L, idx, "uiobject");
  }
  lua_pop(L, 1);
}

static inline void wowless_stubchecknilableuiobject(lua_State *L, int idx,
                                                    const char *typename,
                                                    size_t typenamelen) {
  if (!lua_isnoneornil(L, idx)) {
    wowless_stubcheckuiobject(L, idx, typename, typenamelen);
  }
}

static inline void wowless_stubcheckunknown(lua_State *L, int idx) {
  if (lua_isnoneornil(L, idx)) {
    luaL_argerror(L, idx, "value expected");
  }
}

static inline void wowless_stubchecknilableunknown(lua_State *L, int idx) {}

static inline void wowless_stubcreateluaobject(lua_State *L,
                                               const char *typename,
                                               size_t typenamelen) {
  lua_getfield(L, lua_upvalueindex(1), "CreateLuaObject");
  lua_pushlstring(L, typename, typenamelen);
  lua_call(L, 1, 1);
}

static inline void wowless_stubcreateuiobject(lua_State *L,
                                              const char *typename,
                                              size_t typenamelen) {
  lua_getfield(L, lua_upvalueindex(1), "CreateUiObject");
  lua_pushlstring(L, typename, typenamelen);
  lua_call(L, 1, 1);
}

static inline void wowless_applymixin(lua_State *L, const char *mixin_name) {
  int tbl = lua_gettop(L);
  lua_getglobal(L, mixin_name);
  if (lua_type(L, -1) == LUA_TTABLE) {
    lua_pushnil(L);
    while (lua_next(L, tbl + 1)) {
      lua_pushvalue(L, -2);
      lua_insert(L, -3);
      lua_rawset(L, tbl);
    }
  }
  lua_pop(L, 1);
}

#endif /* WOWLESS_TYPECHECK_H */
