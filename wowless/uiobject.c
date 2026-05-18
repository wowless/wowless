#include "lauxlib.h"
#include "lua.h"

/*
 * Stored at the start of every uiobject token userdata.
 * Its address acts as an in-memory marker so we can identify our userdata
 * without needing a metatable (keeping getmetatable(token) == nil).
 */
static const char wowless_uiobject_marker;

struct wowless_uiobject_data {
  const void *marker;
  int id;
};

static int wowless_uiobject_new(lua_State *L) {
  int id = luaL_checkinteger(L, 1);
  struct wowless_uiobject_data *ud =
      lua_newuserdata(L, sizeof(struct wowless_uiobject_data));
  ud->marker = &wowless_uiobject_marker;
  ud->id = id;
  return 1;
}

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
    {"id",  wowless_uiobject_id },
    {"new", wowless_uiobject_new},
    {NULL,  NULL                }
};

int luaopen_wowless_uiobject(lua_State *L) {
  lua_newtable(L);
  luaL_register(L, NULL, lib);
  return 1;
}
