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

static int wowless_luaobject_new(lua_State *L) {
  int type_id = luaL_checkinteger(L, 1);
  luaL_checktype(L, 2, LUA_TTABLE);
  luaL_checktype(L, 3, LUA_TTABLE);
  struct wowless_luaobject_data *ud =
      (struct wowless_luaobject_data *)lua_newuserdata(
          L, sizeof(struct wowless_luaobject_data));
  ud->marker = &wowless_luaobject_marker;
  ud->type_id = type_id;
  lua_pushvalue(L, 2);
  lua_setmetatable(L, -2);
  lua_pushvalue(L, 3);
  lua_setfenv(L, -2);
  return 1;
}

static const struct luaL_Reg lib[] = {
    {"getenv", wowless_luaobject_getenv},
    {"new",    wowless_luaobject_new   },
    {NULL,     NULL                    }
};

int luaopen_wowless_luaobject(lua_State *L) {
  lua_newtable(L);
  luaL_register(L, NULL, lib);
  return 1;
}
