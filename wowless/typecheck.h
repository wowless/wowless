#ifndef WOWLESS_TYPECHECK_H
#define WOWLESS_TYPECHECK_H

extern "C" {
#include "lauxlib.h"
#include "lua.h"
#include "wowless/luaobject.h"
#include "wowless/stubs.h"
#include "wowless/uiobject.h"
}

#include <string.h>
#ifdef _MSC_VER
#define wowless_strcasecmp _stricmp
#else
#include <strings.h>
#define wowless_strcasecmp strcasecmp
#endif

#include <string_view>

static inline int wowless_forbidden(lua_State *L) {
  const char *taint = lua_getstacktaint(L);
  if (taint) {
    lua_getfield(L, lua_upvalueindex(1), "FireProtected");
    lua_pushstring(L, taint);
    lua_call(L, 1, 0);
    return 1;
  }
  return 0;
}

static inline bool wowless_isnumber(lua_State *L, int idx) {
  return lua_isnumber(L, idx);
}

static inline bool wowless_isnilablenumber(lua_State *L, int idx) {
  return lua_isnoneornil(L, idx) || lua_isnumber(L, idx);
}

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

static inline void wowless_implcheckenum(lua_State *L, int idx) {
  wowless_implchecknumber(L, idx);
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

static inline void wowless_implchecknilableenum(lua_State *L, int idx) {
  wowless_implchecknilablenumber(L, idx);
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

static inline bool wowless_isgender(lua_State *L, int idx) { return true; }

static inline void wowless_implcheckgender(lua_State *L, int idx) {
  if (lua_type(L, idx) != LUA_TNUMBER) {
    lua_pushnumber(L, lua_tonumber(L, idx));
    lua_replace(L, idx);
  }
}

static inline void wowless_stubcheckgender(lua_State *L, int idx) {}

static inline bool wowless_isstring(lua_State *L, int idx) {
  return lua_isstring(L, idx);
}

static inline bool wowless_isnilablestring(lua_State *L, int idx) {
  return lua_isnoneornil(L, idx) || lua_isstring(L, idx);
}

static inline void wowless_stubcheckstring(lua_State *L, int idx) {
  if (!wowless_isstring(L, idx)) {
    luaL_typerror(L, idx, lua_typename(L, LUA_TSTRING));
  }
}

static inline void wowless_stubchecknilablestring(lua_State *L, int idx) {
  if (!wowless_isnilablestring(L, idx)) {
    luaL_typerror(L, idx, lua_typename(L, LUA_TSTRING));
  }
}

static inline bool wowless_istextureasset(lua_State *L, int idx) {
  return lua_isstring(L, idx) || lua_istable(L, idx);
}

static inline bool wowless_isnilabletextureasset(lua_State *L, int idx) {
  return lua_isnoneornil(L, idx) || wowless_istextureasset(L, idx);
}

static inline void wowless_stubchecktextureasset(lua_State *L, int idx) {
  if (!wowless_istextureasset(L, idx)) {
    luaL_typerror(L, idx, "TextureAsset");
  }
}

static inline void wowless_stubchecknilabletextureasset(lua_State *L, int idx) {
  if (!wowless_isnilabletextureasset(L, idx)) {
    luaL_typerror(L, idx, "TextureAsset");
  }
}

static inline bool wowless_isfileasset(lua_State *L, int idx) {
  return wowless_isstring(L, idx);
}

static inline bool wowless_isnilablefileasset(lua_State *L, int idx) {
  return wowless_isnilablestring(L, idx);
}

static inline void wowless_stubcheckfileasset(lua_State *L, int idx) {
  wowless_stubcheckstring(L, idx);
}

static inline void wowless_stubchecknilablefileasset(lua_State *L, int idx) {
  wowless_stubchecknilablestring(L, idx);
}

static inline bool wowless_isboolean(lua_State *L, int idx) {
  return !lua_isnoneornil(L, idx);
}

static inline bool wowless_isnilableboolean(lua_State *L, int idx) {
  return true;
}

static inline void wowless_stubcheckboolean(lua_State *L, int idx) {
  if (!wowless_isboolean(L, idx)) {
    luaL_typerror(L, idx, lua_typename(L, LUA_TBOOLEAN));
  }
}

static inline void wowless_stubchecknilableboolean(lua_State *L, int idx) {}

static inline bool wowless_isfunction(lua_State *L, int idx) {
  return lua_type(L, idx) == LUA_TFUNCTION;
}

static inline bool wowless_isnilablefunction(lua_State *L, int idx) {
  int t = lua_type(L, idx);
  return t == LUA_TFUNCTION || t == LUA_TNIL || t == LUA_TNONE;
}

static inline void wowless_stubcheckfunction(lua_State *L, int idx) {
  if (!wowless_isfunction(L, idx)) {
    luaL_typerror(L, idx, lua_typename(L, LUA_TFUNCTION));
  }
}

static inline void wowless_stubchecknilablefunction(lua_State *L, int idx) {
  if (!wowless_isnilablefunction(L, idx)) {
    luaL_typerror(L, idx, lua_typename(L, LUA_TFUNCTION));
  }
}

static inline bool wowless_isunit(lua_State *L, int idx) {
  return lua_type(L, idx) == LUA_TSTRING;
}

static inline bool wowless_isnilableunit(lua_State *L, int idx) {
  int t = lua_type(L, idx);
  return t == LUA_TSTRING || t == LUA_TNIL || t == LUA_TNONE;
}

static inline void wowless_stubcheckunit(lua_State *L, int idx) {
  if (!wowless_isunit(L, idx)) {
    luaL_typerror(L, idx, lua_typename(L, LUA_TSTRING));
  }
}

static inline void wowless_stubchecknilableunit(lua_State *L, int idx) {
  if (!wowless_isnilableunit(L, idx)) {
    luaL_typerror(L, idx, lua_typename(L, LUA_TSTRING));
  }
}

static inline bool wowless_isuiaddon(lua_State *L, int idx) {
  return wowless_isstring(L, idx);
}

static inline bool wowless_isnilableuiaddon(lua_State *L, int idx) {
  return wowless_isnilablestring(L, idx);
}

static inline void wowless_stubcheckuiaddon(lua_State *L, int idx) {
  wowless_stubcheckstring(L, idx);
}

static inline void wowless_stubchecknilableuiaddon(lua_State *L, int idx) {
  wowless_stubchecknilablestring(L, idx);
}

static inline bool wowless_istable(lua_State *L, int idx) {
  return lua_type(L, idx) == LUA_TTABLE;
}

static inline bool wowless_isnilabletable(lua_State *L, int idx) {
  int t = lua_type(L, idx);
  return t == LUA_TTABLE || t == LUA_TNIL || t == LUA_TNONE;
}

static inline void wowless_stubchecktable(lua_State *L, int idx) {
  if (!wowless_istable(L, idx)) {
    luaL_typerror(L, idx, lua_typename(L, LUA_TTABLE));
  }
}

static inline void wowless_stubchecknilabletable(lua_State *L, int idx) {
  if (!wowless_isnilabletable(L, idx)) {
    luaL_typerror(L, idx, lua_typename(L, LUA_TTABLE));
  }
}

static inline bool wowless_isnilableluaobject(lua_State *L, int idx,
                                              int typeid_val) {
  return lua_isnoneornil(L, idx) || wowless_isluaobject(L, idx, typeid_val);
}

static inline void wowless_stubcheckluaobject(lua_State *L, int idx,
                                              int typeid_val) {
  if (!wowless_isluaobject(L, idx, typeid_val)) {
    luaL_typerror(L, idx, "luaobject");
  }
}

static inline void wowless_stubchecknilableluaobject(lua_State *L, int idx,
                                                     int typeid_val) {
  if (!wowless_isnilableluaobject(L, idx, typeid_val)) {
    luaL_typerror(L, idx, "luaobject");
  }
}

static inline bool wowless_isuiobject(lua_State *L, int idx, int type_bit) {
  idx = lua_absindex(L, idx);
  if (lua_type(L, idx) != LUA_TTABLE) {
    return false;
  }
  lua_rawgeti(L, idx, 0);
  bool result = false;
  if (lua_type(L, -1) == LUA_TUSERDATA &&
      lua_objlen(L, -1) == sizeof(struct wowless_uiobject_data)) {
    const struct wowless_uiobject_data *ud =
        (const struct wowless_uiobject_data *)lua_touserdata(L, -1);
    if (ud->marker == &wowless_uiobject_marker) {
      result = (ud->uitype->isa_mask >> type_bit) & 1;
    }
  }
  lua_pop(L, 1);
  return result;
}

static inline bool wowless_isnilableuiobject(lua_State *L, int idx,
                                             int type_bit) {
  return lua_isnoneornil(L, idx) || wowless_isuiobject(L, idx, type_bit);
}

static inline void wowless_stubcheckuiobject(lua_State *L, int idx,
                                             int type_bit) {
  if (!wowless_isuiobject(L, idx, type_bit)) {
    luaL_typerror(L, idx, "uiobject");
  }
}

static inline void wowless_stubchecknilableuiobject(lua_State *L, int idx,
                                                    int type_bit) {
  if (!wowless_isnilableuiobject(L, idx, type_bit)) {
    luaL_typerror(L, idx, "uiobject");
  }
}

static inline bool wowless_isunknown(lua_State *L, int idx) {
  return !lua_isnoneornil(L, idx);
}

static inline bool wowless_isnilableunknown(lua_State *L, int idx) {
  return true;
}

static inline void wowless_stubcheckunknown(lua_State *L, int idx) {
  if (!wowless_isunknown(L, idx)) {
    luaL_argerror(L, idx, "value expected");
  }
}

static inline void wowless_stubchecknilableunknown(lua_State *L, int idx) {}

static inline bool wowless_isnil(lua_State *L, int idx) {
  return lua_isnoneornil(L, idx);
}

static inline bool wowless_isnilablenil(lua_State *L, int idx) {
  return wowless_isnil(L, idx);
}

static inline void wowless_stubchecknil(lua_State *L, int idx) {
  if (!wowless_isnil(L, idx)) {
    luaL_typerror(L, idx, "nil");
  }
}

static inline void wowless_stubchecknilablenil(lua_State *L, int idx) {
  wowless_stubchecknil(L, idx);
}

static inline bool wowless_stringenum_check(const char *s,
                                            const char *const *values, int n) {
  int lo = 0, hi = n - 1;
  while (lo <= hi) {
    int mid = (lo + hi) / 2;
    int cmp = wowless_strcasecmp(s, values[mid]);
    if (cmp == 0) {
      return true;
    }
    if (cmp < 0) {
      hi = mid - 1;
    } else {
      lo = mid + 1;
    }
  }
  return false;
}

static inline bool wowless_isstringenum(lua_State *L, int idx,
                                        const char *const *values, int n) {
  if (lua_type(L, idx) != LUA_TSTRING) {
    return false;
  }
  return wowless_stringenum_check(lua_tostring(L, idx), values, n);
}

static inline bool wowless_isnilablestringenum(lua_State *L, int idx,
                                               const char *const *values,
                                               int n) {
  return lua_isnoneornil(L, idx) || wowless_isstringenum(L, idx, values, n);
}

static inline void wowless_stubcheckstringenum(lua_State *L, int idx,
                                               const char *const *values,
                                               int n) {
  if (!wowless_isstringenum(L, idx, values, n)) {
    if (lua_type(L, idx) != LUA_TSTRING) {
      luaL_checktype(L, idx, LUA_TSTRING);
    } else {
      luaL_argerror(L, idx, "invalid string enum value");
    }
  }
}

static inline void wowless_stubchecknilablestringenum(lua_State *L, int idx,
                                                      const char *const *values,
                                                      int n) {
  if (!wowless_isnilablestringenum(L, idx, values, n)) {
    if (lua_type(L, idx) != LUA_TSTRING) {
      luaL_checktype(L, idx, LUA_TSTRING);
    } else {
      luaL_argerror(L, idx, "invalid string enum value");
    }
  }
}

static inline void wowless_implcheckstringenum(lua_State *L, int idx,
                                               const char *const *values,
                                               int n) {
  if (lua_type(L, idx) != LUA_TSTRING) {
    luaL_typerror(L, idx, lua_typename(L, LUA_TSTRING));
    return;
  }
  const char *s = lua_tostring(L, idx);
  int lo = 0, hi = n - 1;
  while (lo <= hi) {
    int mid = (lo + hi) / 2;
    int cmp = wowless_strcasecmp(s, values[mid]);
    if (cmp == 0) {
      lua_pushstring(L, values[mid]);
      lua_replace(L, idx);
      return;
    }
    if (cmp < 0) {
      hi = mid - 1;
    } else {
      lo = mid + 1;
    }
  }
  luaL_argerror(L, idx, "invalid string enum value");
}

static inline void wowless_implchecknilablestringenum(lua_State *L, int idx,
                                                      const char *const *values,
                                                      int n) {
  if (!lua_isnoneornil(L, idx)) {
    wowless_implcheckstringenum(L, idx, values, n);
  }
}

static inline void wowless_imploutputstringenum(lua_State *L, int idx,
                                                const char *const *values,
                                                int n) {
  if (lua_type(L, idx) != LUA_TSTRING) {
    luaL_typerror(L, idx, lua_typename(L, LUA_TSTRING));
    return;
  }
  const char *s = lua_tostring(L, idx);
  int lo = 0, hi = n - 1;
  while (lo <= hi) {
    int mid = (lo + hi) / 2;
    int cmp = strcmp(s, values[mid]);
    if (cmp == 0) {
      return;
    }
    if (cmp < 0) {
      hi = mid - 1;
    } else {
      lo = mid + 1;
    }
  }
  luaL_argerror(L, idx, "invalid string enum value");
}

static inline void wowless_imploutputnilablestringenum(
    lua_State *L, int idx, const char *const *values, int n) {
  if (!lua_isnoneornil(L, idx)) {
    wowless_imploutputstringenum(L, idx, values, n);
  }
}

static inline void wowless_stubcreateluaobject(lua_State *L,
                                               std::string_view tname) {
  lua_getfield(L, lua_upvalueindex(1), "CreateLuaObject");
  lua_pushlstring(L, tname.data(), tname.size());
  lua_call(L, 1, 1);
}

static inline void wowless_stubcreateuiobject(lua_State *L,
                                              std::string_view tname) {
  lua_getfield(L, lua_upvalueindex(1), "CreateUiObject");
  lua_pushlstring(L, tname.data(), tname.size());
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

static inline void wowless_implcheckuiaddon(lua_State *L, int idx) {
  idx = lua_absindex(L, idx);
  wowless_stubcheckuiaddon(L, idx);
  lua_getfield(L, lua_upvalueindex(1), "GetUiAddon");
  lua_pushvalue(L, idx);
  lua_call(L, 1, 1);
  lua_replace(L, idx);
}

static inline void wowless_implchecknilableuiaddon(lua_State *L, int idx) {
  if (!lua_isnoneornil(L, idx)) {
    wowless_implcheckuiaddon(L, idx);
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

static inline void wowless_implcheckunit(lua_State *L, int idx) {
  idx = lua_absindex(L, idx);
  wowless_stubcheckunit(L, idx);
  lua_getfield(L, lua_upvalueindex(1), "GetUnit");
  lua_pushvalue(L, idx);
  lua_call(L, 1, 1);
  lua_replace(L, idx);
}

static inline void wowless_implchecknilableunit(lua_State *L, int idx) {
  if (!lua_isnoneornil(L, idx)) {
    wowless_implcheckunit(L, idx);
  }
}

static inline void wowless_implchecknil(lua_State *L, int idx) {
  wowless_stubchecknil(L, idx);
}

static inline void wowless_implchecknilablenil(lua_State *L, int idx) {
  wowless_stubchecknil(L, idx);
}

static inline void wowless_implcheckunknown(lua_State *L, int idx) {
  wowless_stubcheckunknown(L, idx);
}

static inline void wowless_implchecknilableunknown(lua_State *L, int idx) {}

static inline void wowless_implcheckany(lua_State *L, int idx) {}

static inline void wowless_implchecknilableany(lua_State *L, int idx) {}

static inline void wowless_implcheckluaobject(lua_State *L, int idx,
                                              int typeid_val,
                                              const char *tname) {
  idx = lua_absindex(L, idx);
  if (wowless_isluaobject(L, idx, typeid_val)) {
    lua_getfenv(L, idx);
    lua_replace(L, idx);
    return;
  }
  lua_getfield(L, lua_upvalueindex(1), "Coerce");
  lua_pushstring(L, tname);
  lua_pushvalue(L, idx);
  lua_call(L, 2, 1);
  if (!lua_isnil(L, -1)) {
    lua_replace(L, idx);
    return;
  }
  lua_pop(L, 1);
  luaL_typerror(L, idx, tname);
}

static inline void wowless_implchecknilableluaobject(lua_State *L, int idx,
                                                     int typeid_val,
                                                     const char *tname) {
  if (!lua_isnoneornil(L, idx)) {
    wowless_implcheckluaobject(L, idx, typeid_val, tname);
  }
}

static inline void wowless_implcheckuiobject(lua_State *L, int idx,
                                             int type_bit) {
  idx = lua_absindex(L, idx);
  if (lua_type(L, idx) == LUA_TTABLE) {
    lua_rawgeti(L, idx, 0);
    if (lua_type(L, -1) == LUA_TUSERDATA &&
        lua_objlen(L, -1) == sizeof(struct wowless_uiobject_data)) {
      const struct wowless_uiobject_data *ud =
          (const struct wowless_uiobject_data *)lua_touserdata(L, -1);
      if (ud->marker == &wowless_uiobject_marker &&
          ((ud->uitype->isa_mask >> type_bit) & 1)) {
        int id = ud->id;
        /* cgencode[1] is uiobjects.userdata (integer-keyed by ud->id); both
         * lookups hit the array part directly — keep uiobjects.userdata at
         * index 1 in cgencode's return table. */
        lua_rawgeti(L, lua_upvalueindex(1), 1);
        lua_rawgeti(L, -1, id);
        lua_replace(L, idx);
        lua_pop(L, 2);
        return;
      }
    }
  }
  luaL_typerror(L, idx, "uiobject");
}

static inline void wowless_implchecknilableuiobject(lua_State *L, int idx,
                                                    int type_bit) {
  if (!lua_isnoneornil(L, idx)) {
    wowless_implcheckuiobject(L, idx, type_bit);
  }
}

static inline void wowless_imploutputoneornil(lua_State *L, int idx) {
  if (!lua_isnil(L, idx) &&
      !(lua_type(L, idx) == LUA_TNUMBER && lua_tonumber(L, idx) == 1)) {
    wowless_outputtyperror(L, idx, "1 or nil");
  }
}

static inline void wowless_imploutputnilableoneornil(lua_State *L, int idx) {
  wowless_imploutputoneornil(L, idx);
}

static inline void wowless_imploutputnil(lua_State *L, int idx) {
  if (!lua_isnil(L, idx)) {
    wowless_outputtyperror(L, idx, "nil");
  }
}

static inline void wowless_imploutputnilablenil(lua_State *L, int idx) {
  wowless_imploutputnil(L, idx);
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

static inline void wowless_imploutputenum(lua_State *L, int idx) {
  wowless_imploutputnumber(L, idx);
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

static inline void wowless_imploutputnilableenum(lua_State *L, int idx) {
  wowless_imploutputnilablenumber(L, idx);
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

static inline void wowless_imploutputunit(lua_State *L, int idx) {
  wowless_imploutputstring(L, idx);
}

static inline void wowless_imploutputnilableunit(lua_State *L, int idx) {
  wowless_imploutputnilablestring(L, idx);
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

static inline void wowless_imploutputluaobject(lua_State *L, int idx,
                                               int typeid_val,
                                               std::string_view tname) {
  idx = lua_absindex(L, idx);
  if (lua_type(L, idx) == LUA_TTABLE) {
    lua_rawgeti(L, idx, 1);
    bool ok = lua_type(L, -1) == LUA_TNUMBER &&
              (int)lua_tointeger(L, -1) == typeid_val;
    lua_pop(L, 1);
    if (ok) {
      lua_getfield(L, lua_upvalueindex(1), "CreateProxy");
      lua_pushlstring(L, tname.data(), tname.size());
      lua_pushvalue(L, idx);
      lua_call(L, 2, 1);
      lua_replace(L, idx);
      return;
    }
  }
  wowless_outputtyperror(L, idx, "luaobject");
}

static inline void wowless_imploutputnilableluaobject(lua_State *L, int idx,
                                                      int typeid_val,
                                                      std::string_view tname) {
  if (!lua_isnoneornil(L, idx)) {
    wowless_imploutputluaobject(L, idx, typeid_val, tname);
  }
}

static inline void wowless_imploutputuiobject(lua_State *L, int idx,
                                              int type_bit) {
  idx = lua_absindex(L, idx);
  if (lua_type(L, idx) == LUA_TTABLE) {
    lua_rawgeti(L, idx, 1);
    if (lua_type(L, -1) == LUA_TUSERDATA &&
        lua_objlen(L, -1) == sizeof(struct wowless_uiobject_data)) {
      const struct wowless_uiobject_data *ud =
          (const struct wowless_uiobject_data *)lua_touserdata(L, -1);
      if (ud->marker == &wowless_uiobject_marker &&
          ((ud->uitype->isa_mask >> type_bit) & 1)) {
        lua_pop(L, 1);
        lua_getfield(L, idx, "luarep");
        lua_replace(L, idx);
        return;
      }
    }
    lua_pop(L, 1);
  }
  wowless_outputtyperror(L, idx, "uiobject");
}

static inline void wowless_imploutputnilableuiobject(lua_State *L, int idx,
                                                     int type_bit) {
  if (!lua_isnoneornil(L, idx)) {
    wowless_imploutputuiobject(L, idx, type_bit);
  }
}

static inline void wowless_imploutputunknown(lua_State *L, int idx) {}

static inline void wowless_imploutputnilableunknown(lua_State *L, int idx) {}

static inline void wowless_imploutputany(lua_State *L, int idx) {}

static inline void wowless_imploutputnilableany(lua_State *L, int idx) {}

static inline void wowless_stubcheckextraargs(lua_State *L, int nsins,
                                              const char *fname) {
  if (lua_gettop(L) > nsins) {
    wowless_stub_log_extra_args(L, fname);
  }
}

static inline void wowless_stubchecknreturns(lua_State *L, int nret,
                                             int nexpected, const char *fname) {
  if (nret != nexpected) {
    luaL_error(L, "wrong number of return values to %s: want %d, got %d", fname,
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

template <void Check(lua_State *, int)>
static void wowless_stubcheckarrayof(lua_State *L, int idx) {
  idx = lua_absindex(L, idx);
  wowless_stubchecktable(L, idx);
  int n = static_cast<int>(lua_objlen(L, idx));
  for (int i = 1; i <= n; i++) {
    lua_rawgeti(L, idx, i);
    Check(L, -1);
    lua_pop(L, 1);
  }
}

template <void Check(lua_State *, int)>
static void wowless_stubchecknilablearrayof(lua_State *L, int idx) {
  if (!lua_isnoneornil(L, idx)) {
    wowless_stubcheckarrayof<Check>(L, idx);
  }
}

#endif /* WOWLESS_TYPECHECK_H */
