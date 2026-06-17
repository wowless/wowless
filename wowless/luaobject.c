#include "wowless/luaobject.h"

#include <string.h>

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

static int luaobject_eq(lua_State *L) {
  lua_getfenv(L, 1);
  lua_getfenv(L, 2);
  lua_pushboolean(L, lua_rawequal(L, -2, -1));
  return 1;
}

/* upvalue 1: methods */
static int luaobject_index(lua_State *L) {
  lua_pushvalue(L, 2);
  lua_rawget(L, lua_upvalueindex(1));
  if (!lua_isnil(L, -1)) {
    return 1;
  }
  lua_pop(L, 1);
  lua_getfenv(L, 1);
  lua_getfield(L, -1, "table");
  lua_pushvalue(L, 2);
  lua_rawget(L, -2);
  return 1;
}

/* upvalue 1: methods */
static int luaobject_newindex(lua_State *L) {
  lua_pushvalue(L, 2);
  lua_rawget(L, lua_upvalueindex(1));
  if (!lua_isnil(L, -1)) {
    lua_pop(L, 1);
    return luaL_error(L, "Attempted to assign to read-only key %s",
                      lua_tostring(L, 2));
  }
  lua_pop(L, 1);
  static const char *const metamethod_keys[] = {
      "__eq", "__index", "__metatable", "__newindex", "__tostring", NULL};
  const char *key = lua_tostring(L, 2);
  if (key) {
    for (const char *const *k = metamethod_keys; *k; k++) {
      if (strcmp(key, *k) == 0) {
        return luaL_error(L, "Attempted to assign to read-only key %s", key);
      }
    }
  }
  lua_getfenv(L, 1);
  lua_getfield(L, -1, "table");
  lua_pushvalue(L, 2);
  lua_pushvalue(L, 3);
  lua_rawset(L, -3);
  return 0;
}

/* upvalue 1: typename string */
static int luaobject_tostring(lua_State *L) {
  lua_getfenv(L, 1);
  lua_pushfstring(L, "%s: %p", lua_tostring(L, lua_upvalueindex(1)),
                  lua_topointer(L, -1));
  return 1;
}

void wowless_luaobject_register_mt(lua_State *L, int mt_idx, int type_id,
                                   int methods_idx, const char *typename_str) {
  lua_newtable(L); /* metatable */
  lua_pushcfunction(L, luaobject_eq);
  lua_setfield(L, -2, "__eq");
  lua_pushvalue(L, methods_idx);
  lua_pushcclosure(L, luaobject_index, 1);
  lua_setfield(L, -2, "__index");
  lua_pushboolean(L, 0);
  lua_setfield(L, -2, "__metatable");
  lua_pushvalue(L, methods_idx);
  lua_pushcclosure(L, luaobject_newindex, 1);
  lua_setfield(L, -2, "__newindex");
  if (typename_str) {
    lua_pushstring(L, typename_str);
    lua_pushcclosure(L, luaobject_tostring, 1);
    lua_setfield(L, -2, "__tostring");
  }
  lua_rawseti(L, mt_idx, type_id);
}

/* upvalue 1: metatables (type_id -> metatable) */
static int wowless_luaobject_new(lua_State *L) {
  int type_id = luaL_checkinteger(L, 1);
  luaL_checktype(L, 2, LUA_TTABLE); /* env */
  struct wowless_luaobject_data *ud =
      (struct wowless_luaobject_data *)lua_newuserdata(
          L, sizeof(struct wowless_luaobject_data));
  ud->marker = &wowless_luaobject_marker;
  ud->type_id = type_id;
  lua_rawgeti(L, lua_upvalueindex(1), type_id);
  lua_setmetatable(L, -2);
  lua_pushvalue(L, 2);
  lua_setfenv(L, -2);
  return 1;
}

int luaopen_wowless_luaobject(lua_State *L) {
  lua_newtable(L); /* module */
  lua_pushcfunction(L, wowless_luaobject_getenv);
  lua_setfield(L, -2, "getenv");

  lua_newtable(L); /* metatables: type_id -> metatable */
  lua_pushvalue(L, -1);
  lua_setfield(L, -3, "metatables");

  lua_pushcclosure(L, wowless_luaobject_new, 1);
  lua_setfield(L, -2, "new");

  return 1;
}
