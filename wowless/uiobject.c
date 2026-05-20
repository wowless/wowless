#include "wowless/uiobject.h"

#include "lauxlib.h"
#include "lua.h"

/*
 * Address acts as an in-memory type marker for wowless uiobject token
 * userdatas.
 */
const char wowless_uiobject_marker = 0;

static int wowless_uiobject_id(lua_State *L) {
  if (lua_type(L, 1) == LUA_TUSERDATA &&
      lua_objlen(L, 1) == sizeof(struct wowless_uiobject_data)) {
    struct wowless_uiobject_data *ud = lua_touserdata(L, 1);
    if (ud->marker == &wowless_uiobject_marker) {
      lua_pushinteger(L, ud->id);
      return 1;
    }
  }
  return 0;
}

static const struct luaL_Reg lib[] = {
    {"id", wowless_uiobject_id},
    {NULL, NULL               }
};

int luaopen_wowless_uiobject(lua_State *L) {
  lua_newtable(L);
  luaL_register(L, NULL, lib);
  return 1;
}
