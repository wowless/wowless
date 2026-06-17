#include "wowless/luaobject.h"

#include "lauxlib.h"
#include "lua.h"

/*
 * Address acts as an in-memory type marker for wowless luaobject token
 * userdatas.
 */
const char wowless_luaobject_marker = 0;

static int wowless_luaobject_getenv(lua_State *L) {
  const struct wowless_luaobject_data *ud = wowless_toluaobject(L, 1);
  if (ud) {
    lua_getfenv(L, 1);
    return 1;
  }
  return 0;
}

static int wowless_luaobject_gettypeid(lua_State *L) {
  const struct wowless_luaobject_data *ud = wowless_toluaobject(L, 1);
  if (ud) {
    lua_pushinteger(L, ud->type_id);
    return 1;
  }
  return 0;
}

static int luaobject_eq(lua_State *L) {
  lua_getfenv(L, 1);
  lua_getfenv(L, 2);
  lua_pushboolean(L, lua_rawequal(L, -2, -1));
  return 1;
}

/* upvalue 1: state table (cache, typenames, readonly, mt) */

static int luaobject_index(lua_State *L) {
  const struct wowless_luaobject_data *ud = wowless_toluaobject(L, 1);
  if (ud) {
    lua_getfield(L, lua_upvalueindex(1), "cache");
    lua_rawgeti(L, -1, ud->type_id);
    if (!lua_isnil(L, -1)) {
      lua_pushvalue(L, 2);
      lua_rawget(L, -2);
      if (!lua_isnil(L, -1)) {
        return 1;
      }
      lua_pop(L, 2);
    } else {
      lua_pop(L, 1);
    }
    lua_pop(L, 1); /* pop cache */
  }
  lua_getfenv(L, 1);
  lua_getfield(L, -1, "table");
  lua_pushvalue(L, 2);
  lua_rawget(L, -2);
  return 1;
}

static int luaobject_newindex(lua_State *L) {
  const struct wowless_luaobject_data *ud = wowless_toluaobject(L, 1);
  if (ud) {
    lua_getfield(L, lua_upvalueindex(1), "cache");
    lua_rawgeti(L, -1, ud->type_id);
    lua_remove(L, -2); /* remove cache, keep methods */
    if (!lua_isnil(L, -1)) {
      lua_pushvalue(L, 2);
      lua_rawget(L, -2);
      if (!lua_isnil(L, -1)) {
        lua_pop(L, 2);
        return luaL_error(L, "Attempted to assign to read-only key %s",
                          lua_tostring(L, 2));
      }
      lua_pop(L, 1); /* pop nil result */
    }
    lua_pop(L, 1); /* pop methods or nil */
    lua_getfield(L, lua_upvalueindex(1), "readonly");
    lua_pushvalue(L, 2);
    lua_rawget(L, -2);
    lua_remove(L, -2); /* remove readonly table */
    if (!lua_isnil(L, -1)) {
      lua_pop(L, 1);
      return luaL_error(L, "Attempted to assign to read-only key %s",
                        lua_tostring(L, 2));
    }
    lua_pop(L, 1); /* pop nil */
  }
  lua_getfenv(L, 1);
  lua_getfield(L, -1, "table");
  lua_pushvalue(L, 2);
  lua_pushvalue(L, 3);
  lua_rawset(L, -3);
  return 0;
}

static int luaobject_tostring(lua_State *L) {
  const struct wowless_luaobject_data *ud = wowless_toluaobject(L, 1);
  if (ud) {
    lua_getfield(L, lua_upvalueindex(1), "typenames");
    lua_rawgeti(L, -1, ud->type_id);
    if (lua_type(L, -1) == LUA_TSTRING) {
      const char *tn = lua_tostring(L, -1);
      lua_getfenv(L, 1);
      lua_pushfstring(L, "%s: %p", tn, lua_topointer(L, -1));
      return 1;
    }
  }
  return 0;
}

static int luaobject_register_mt(lua_State *L) {
  int type_id = luaL_checkinteger(L, 1);
  luaL_checktype(L, 2, LUA_TTABLE); /* methods */
  lua_getfield(L, lua_upvalueindex(1), "cache");
  lua_pushvalue(L, 2);
  lua_rawseti(L, -2, type_id);
  lua_pop(L, 1);
  if (lua_type(L, 3) == LUA_TSTRING) {
    lua_getfield(L, lua_upvalueindex(1), "typenames");
    lua_pushvalue(L, 3);
    lua_rawseti(L, -2, type_id);
    lua_pop(L, 1);
  }
  return 0;
}

static int wowless_luaobject_new(lua_State *L) {
  int type_id = luaL_checkinteger(L, 1);
  luaL_checktype(L, 2, LUA_TTABLE); /* env */
  struct wowless_luaobject_data *ud =
      (struct wowless_luaobject_data *)lua_newuserdata(
          L, sizeof(struct wowless_luaobject_data));
  ud->marker = &wowless_luaobject_marker;
  ud->type_id = type_id;
  lua_getfield(L, lua_upvalueindex(1), "mt");
  lua_setmetatable(L, -2);
  lua_pushvalue(L, 2);
  lua_setfenv(L, -2);
  return 1;
}

static int wowless_luaobject_makemt(lua_State *L) {
  int tostring_enabled = lua_toboolean(L, 1);
  lua_newtable(L); /* shared metatable */
  lua_pushcfunction(L, luaobject_eq);
  lua_setfield(L, -2, "__eq");
  lua_pushvalue(L, lua_upvalueindex(1));
  lua_pushcclosure(L, luaobject_index, 1);
  lua_setfield(L, -2, "__index");
  lua_pushboolean(L, 0);
  lua_setfield(L, -2, "__metatable");
  lua_pushvalue(L, lua_upvalueindex(1));
  lua_pushcclosure(L, luaobject_newindex, 1);
  lua_setfield(L, -2, "__newindex");
  if (tostring_enabled) {
    lua_pushvalue(L, lua_upvalueindex(1));
    lua_pushcclosure(L, luaobject_tostring, 1);
    lua_setfield(L, -2, "__tostring");
  }
  lua_setfield(L, lua_upvalueindex(1), "mt");
  lua_getfield(L, lua_upvalueindex(1), "readonly");
  static const char *const always_readonly[] = {
      "__eq", "__index", "__metatable", "__newindex", NULL};
  for (const char *const *k = always_readonly; *k; k++) {
    lua_pushboolean(L, 1);
    lua_setfield(L, -2, *k);
  }
  if (tostring_enabled) {
    lua_pushboolean(L, 1);
    lua_setfield(L, -2, "__tostring");
  }
  lua_pop(L, 1); /* pop readonly */
  return 0;
}

int luaopen_wowless_luaobject(lua_State *L) {
  lua_newtable(L); /* module */
  lua_pushcfunction(L, wowless_luaobject_getenv);
  lua_setfield(L, -2, "getenv");
  lua_pushcfunction(L, wowless_luaobject_gettypeid);
  lua_setfield(L, -2, "gettypeid");

  lua_newtable(L); /* state */
  lua_newtable(L);
  lua_setfield(L, -2, "cache");
  lua_newtable(L);
  lua_setfield(L, -2, "typenames");
  lua_newtable(L);
  lua_setfield(L, -2, "readonly");
  /* state["mt"] is set by makemt */

  lua_pushvalue(L, -1);
  lua_pushcclosure(L, luaobject_register_mt, 1);
  lua_setfield(L, -3, "register_mt");

  lua_pushvalue(L, -1);
  lua_pushcclosure(L, wowless_luaobject_new, 1);
  lua_setfield(L, -3, "new");

  lua_pushvalue(L, -1);
  lua_pushcclosure(L, wowless_luaobject_makemt, 1);
  lua_setfield(L, -3, "makemt");

  lua_pop(L, 1); /* pop state */
  return 1;
}
