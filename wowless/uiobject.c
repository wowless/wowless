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
  const char *type; /* interned Lua string pointer; valid for lifetime of state */
};

static const struct wowless_uiobject_data *check_data(lua_State *L, int idx) {
  if (lua_type(L, idx) == LUA_TUSERDATA &&
      lua_objlen(L, idx) == sizeof(struct wowless_uiobject_data)) {
    const struct wowless_uiobject_data *ud = lua_touserdata(L, idx);
    if (ud->marker == &wowless_uiobject_marker) {
      return ud;
    }
  }
  return NULL;
}

static int wowless_uiobject_new(lua_State *L) {
  int id = luaL_checkinteger(L, 1);
  const char *type = luaL_checkstring(L, 2);
  struct wowless_uiobject_data *ud =
      lua_newuserdata(L, sizeof(struct wowless_uiobject_data));
  ud->marker = &wowless_uiobject_marker;
  ud->id = id;
  ud->type = type;
  return 1;
}

static int wowless_uiobject_id(lua_State *L) {
  const struct wowless_uiobject_data *ud = check_data(L, 1);
  if (ud) {
    lua_pushinteger(L, ud->id);
    return 1;
  }
  return 0;
}

static int wowless_uiobject_type(lua_State *L) {
  const struct wowless_uiobject_data *ud = check_data(L, 1);
  if (ud) {
    lua_pushstring(L, ud->type);
    return 1;
  }
  return 0;
}

static const struct luaL_Reg lib[] = {
    {"id",   wowless_uiobject_id  },
    {"new",  wowless_uiobject_new },
    {"type", wowless_uiobject_type},
    {NULL,   NULL                 }
};

int luaopen_wowless_uiobject(lua_State *L) {
  lua_newtable(L);
  luaL_register(L, NULL, lib);
  return 1;
}
