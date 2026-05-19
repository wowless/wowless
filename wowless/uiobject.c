#include "wowless/uiobject.h"

#include <stdlib.h>

#include "lauxlib.h"
#include "lua.h"

/*
 * Address acts as an in-memory type marker for wowless uiobject token
 * userdatas.
 */
const char wowless_uiobject_marker = 0;

/*
 * type_new(bit1, bit2, ...) -> lightuserdata
 * Allocates a wowless_uitype whose isa_mask is the OR of (1 << bitN) for each
 * argument. Precomputed by prep to include all transitive ancestor bits.
 */
static int wowless_uitype_new(lua_State *L) {
  struct wowless_uitype *t = malloc(sizeof(struct wowless_uitype));
  t->isa_mask = 0;
  for (int i = 1; i <= lua_gettop(L); i++) {
    int bit = (int)luaL_checkinteger(L, i);
    if (bit >= 0) {
      t->isa_mask |= UINT64_C(1) << bit;
    }
  }
  lua_pushlightuserdata(L, t);
  return 1;
}

/*
 * new(id, type_lightuserdata) -> userdata
 * Creates a uiobject token userdata. Copies isa_mask from the type descriptor
 * so the check in wowless_isuiobject needs no indirection.
 */
static int wowless_uiobject_new(lua_State *L) {
  int id = luaL_checkinteger(L, 1);
  const struct wowless_uitype *type = lua_touserdata(L, 2);
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
    {"id",       wowless_uiobject_id },
    {"new",      wowless_uiobject_new},
    {"type_new", wowless_uitype_new  },
    {NULL,       NULL                }
};

int luaopen_wowless_uiobject(lua_State *L) {
  lua_newtable(L);
  luaL_register(L, NULL, lib);
  return 1;
}
