#ifndef WOWLESS_TYPECHECK_H
#define WOWLESS_TYPECHECK_H

#include "lauxlib.h"
#include "lua.h"
#include "wowless/stubs.h"

static inline void wowless_stubchecknumber(lua_State *L, int idx) {
  luaL_checknumber(L, idx);
}

static inline void wowless_stubcheckenum(lua_State *L, int idx) {
  wowless_stubchecknumber(L, idx);
}

static inline void wowless_implcoercenumber(lua_State *L, int idx) {
  lua_Number n = lua_tonumber(L, idx);
  if (n == 0 && !lua_isnumber(L, idx)) {
    luaL_typerror(L, idx, lua_typename(L, LUA_TNUMBER));
  }
  lua_pushnumber(L, n);
  lua_replace(L, idx);
}

static inline void wowless_implchecknumber(lua_State *L, int idx) {
  if (lua_type(L, idx) != LUA_TNUMBER) {
    wowless_implcoercenumber(L, idx);
  }
}

static inline void wowless_implchecknilablenumber(lua_State *L, int idx) {
  switch (lua_type(L, idx)) {
    case LUA_TNUMBER:
    case LUA_TNIL:
    case LUA_TNONE:
      return;
    default:
      wowless_implcoercenumber(L, idx);
  }
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

static inline void wowless_stubchecknilableenum(lua_State *L, int idx) {
  wowless_stubchecknilablenumber(L, idx);
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

static inline void wowless_stubcheckfileasset(lua_State *L, int idx) {
  wowless_stubcheckstring(L, idx);
}

static inline void wowless_stubchecknilablefileasset(lua_State *L, int idx) {
  wowless_stubchecknilablestring(L, idx);
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
  idx = lua_absindex(L, idx);
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
  idx = lua_absindex(L, idx);
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

static inline void wowless_stubchecknil(lua_State *L, int idx) {
  if (!lua_isnoneornil(L, idx)) {
    luaL_typerror(L, idx, "nil");
  }
}

static inline void wowless_stubchecknilablenil(lua_State *L, int idx) {
  wowless_stubchecknil(L, idx);
}

static inline void wowless_implchecknil(lua_State *L, int idx) {
  wowless_stubchecknil(L, idx);
}

static inline void wowless_implchecknilablenil(lua_State *L, int idx) {
  wowless_stubchecknil(L, idx);
}

static inline void wowless_imploutputnil(lua_State *L, int idx) {
  if (!lua_isnil(L, idx)) {
    wowless_outputtyperror(L, idx, "nil");
  }
}

static inline void wowless_imploutputnilablenil(lua_State *L, int idx) {
  wowless_imploutputnil(L, idx);
}

static inline void wowless_stubcheckstringenum(lua_State *L, int idx,
                                               const char *enumname,
                                               size_t enumnamelen) {
  idx = lua_absindex(L, idx);
  luaL_checktype(L, idx, LUA_TSTRING);
  lua_getfield(L, lua_upvalueindex(1), "CheckStringEnum");
  lua_pushvalue(L, idx);
  lua_pushlstring(L, enumname, enumnamelen);
  lua_call(L, 2, 1);
  if (!lua_toboolean(L, -1)) {
    luaL_argerror(L, idx, "invalid string enum value");
  }
  lua_pop(L, 1);
}

static inline void wowless_stubchecknilablestringenum(lua_State *L, int idx,
                                                      const char *enumname,
                                                      size_t enumnamelen) {
  if (!lua_isnoneornil(L, idx)) {
    wowless_stubcheckstringenum(L, idx, enumname, enumnamelen);
  }
}

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

static inline void wowless_implcoerceboolean(lua_State *L, int idx) {
  lua_pushboolean(L, lua_toboolean(L, idx));
  lua_replace(L, idx);
}

static inline void wowless_implcheckboolean(lua_State *L, int idx) {
  switch (lua_type(L, idx)) {
    case LUA_TBOOLEAN:
      return;
    case LUA_TNIL:
    case LUA_TNONE:
      luaL_typerror(L, idx, lua_typename(L, LUA_TBOOLEAN));
      return;
    default:
      wowless_implcoerceboolean(L, idx);
  }
}

static inline void wowless_implchecknilableboolean(lua_State *L, int idx) {
  switch (lua_type(L, idx)) {
    case LUA_TBOOLEAN:
    case LUA_TNIL:
    case LUA_TNONE:
      return;
    default:
      wowless_implcoerceboolean(L, idx);
  }
}

static inline void wowless_implcheckstring(lua_State *L, int idx) {
  luaL_checkstring(L, idx);
}

static inline void wowless_implchecknilablestring(lua_State *L, int idx) {
  if (!lua_isnoneornil(L, idx)) {
    luaL_checkstring(L, idx);
  }
}

static inline void wowless_implcheckfileasset(lua_State *L, int idx) {
  switch (lua_type(L, idx)) {
    case LUA_TSTRING:
    case LUA_TNUMBER:
      return;
    default:
      luaL_argerror(L, idx, "string or number expected");
  }
}

static inline void wowless_implchecknilablefileasset(lua_State *L, int idx) {
  switch (lua_type(L, idx)) {
    case LUA_TSTRING:
    case LUA_TNUMBER:
    case LUA_TNIL:
    case LUA_TNONE:
      return;
    default:
      luaL_argerror(L, idx, "string or number expected");
  }
}

static inline void wowless_implcheckfunction(lua_State *L, int idx) {
  wowless_stubcheckfunction(L, idx);
}

static inline void wowless_implchecknilablefunction(lua_State *L, int idx) {
  wowless_stubchecknilablefunction(L, idx);
}

static inline void wowless_implchecktable(lua_State *L, int idx) {
  wowless_stubchecktable(L, idx);
}

static inline void wowless_implchecknilabletable(lua_State *L, int idx) {
  wowless_stubchecknilabletable(L, idx);
}

static inline void wowless_imploutputboolean(lua_State *L, int idx) {
  if (lua_type(L, idx) != LUA_TBOOLEAN) {
    wowless_outputtyperror(L, idx, lua_typename(L, LUA_TBOOLEAN));
  }
}

static inline void wowless_imploutputnilableboolean(lua_State *L, int idx) {
  switch (lua_type(L, idx)) {
    case LUA_TBOOLEAN:
    case LUA_TNIL:
      return;
    default:
      wowless_outputtyperror(L, idx, lua_typename(L, LUA_TBOOLEAN));
  }
}

static inline void wowless_imploutputnumber(lua_State *L, int idx) {
  if (lua_type(L, idx) != LUA_TNUMBER) {
    wowless_outputtyperror(L, idx, lua_typename(L, LUA_TNUMBER));
  }
}

static inline void wowless_imploutputnilablenumber(lua_State *L, int idx) {
  switch (lua_type(L, idx)) {
    case LUA_TNUMBER:
    case LUA_TNIL:
      return;
    default:
      wowless_outputtyperror(L, idx, lua_typename(L, LUA_TNUMBER));
  }
}

static inline void wowless_imploutputstring(lua_State *L, int idx) {
  if (lua_type(L, idx) != LUA_TSTRING) {
    wowless_outputtyperror(L, idx, lua_typename(L, LUA_TSTRING));
  }
}

static inline void wowless_imploutputnilablestring(lua_State *L, int idx) {
  switch (lua_type(L, idx)) {
    case LUA_TSTRING:
    case LUA_TNIL:
      return;
    default:
      wowless_outputtyperror(L, idx, lua_typename(L, LUA_TSTRING));
  }
}

static inline void wowless_imploutputfileasset(lua_State *L, int idx) {
  switch (lua_type(L, idx)) {
    case LUA_TSTRING:
    case LUA_TNUMBER:
      return;
    default:
      wowless_outputerror(L, idx, "string or number expected");
  }
}

static inline void wowless_imploutputnilablefileasset(lua_State *L, int idx) {
  switch (lua_type(L, idx)) {
    case LUA_TSTRING:
    case LUA_TNUMBER:
    case LUA_TNIL:
      return;
    default:
      wowless_outputerror(L, idx, "string or number expected");
  }
}

static inline void wowless_imploutputfunction(lua_State *L, int idx) {
  if (lua_type(L, idx) != LUA_TFUNCTION) {
    wowless_outputtyperror(L, idx, lua_typename(L, LUA_TFUNCTION));
  }
}

static inline void wowless_imploutputnilablefunction(lua_State *L, int idx) {
  switch (lua_type(L, idx)) {
    case LUA_TFUNCTION:
    case LUA_TNIL:
      return;
    default:
      wowless_outputtyperror(L, idx, lua_typename(L, LUA_TFUNCTION));
  }
}

static inline void wowless_imploutputtable(lua_State *L, int idx) {
  if (lua_type(L, idx) != LUA_TTABLE) {
    wowless_outputtyperror(L, idx, lua_typename(L, LUA_TTABLE));
  }
}

static inline void wowless_imploutputnilabletable(lua_State *L, int idx) {
  switch (lua_type(L, idx)) {
    case LUA_TTABLE:
    case LUA_TNIL:
      return;
    default:
      wowless_outputtyperror(L, idx, lua_typename(L, LUA_TTABLE));
  }
}

static inline void wowless_stubcheckextraargs(lua_State *L, int nsins,
                                              const char *fname) {
  if (lua_gettop(L) > nsins) {
    wowless_stub_log_extra_args(L, fname);
  }
}

static inline void wowless_stubchecknreturns(lua_State *L, int nret,
                                             int nexpected, const char *fname) {
  if (nret != nexpected) {
    luaL_error(L, "wrong number of return values to %q: want %d, got %d", fname,
               nexpected, nret);
  }
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
