#include "wowless/uiobject.h"

#include "lauxlib.h"
#include "lua.h"

/*
 * Address acts as an in-memory type marker for wowless uiobject token
 * userdatas.
 */
const char wowless_uiobject_marker = 0;

/*
 * new(id, typename) -> userdata
 * Creates a uiobject token userdata. Looks up typename in the wowless_uitypes
 * registry table (populated by the product stubs module) and copies its
 * isa_mask into the userdata so wowless_isuiobject checks need no indirection.
 */
static int wowless_uiobject_new(lua_State *L) {
  int id = luaL_checkinteger(L, 1);
  size_t len;
  const char *name = luaL_checklstring(L, 2, &len);
  lua_pushliteral(L, "wowless_uitypes");
  lua_rawget(L, LUA_REGISTRYINDEX);
  lua_pushlstring(L, name, len);
  lua_rawget(L, -2);
  const struct wowless_uitype *type = lua_touserdata(L, -1);
  lua_pop(L, 2);
  struct wowless_uiobject_data *ud =
      lua_newuserdata(L, sizeof(struct wowless_uiobject_data));
  ud->marker = &wowless_uiobject_marker;
  ud->id = id;
  ud->isa_mask = type ? type->isa_mask : 0;
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
