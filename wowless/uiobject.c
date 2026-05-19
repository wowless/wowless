#include "wowless/uiobject.h"

#include "lauxlib.h"
#include "lua.h"

/*
 * Address acts as an in-memory type marker for wowless uiobject token
 * userdatas.
 */
const char wowless_uiobject_marker = 0;

struct wowless_uitype *wowless_uitypes_by_bit[64];

/*
 * new(id, bit) -> userdata
 * Creates a uiobject token userdata. Indexes wowless_uitypes_by_bit with the
 * type's bit index (set by the product stubs module) and copies its isa_mask
 * into the userdata so wowless_isuiobject checks need no indirection.
 */
static int wowless_uiobject_new(lua_State *L) {
  int id = luaL_checkinteger(L, 1);
  int bit = luaL_checkinteger(L, 2);
  const struct wowless_uitype *type =
      (bit >= 0 && bit < 64) ? wowless_uitypes_by_bit[bit] : NULL;
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
