#include "wowless/stubs.h"

#include "lauxlib.h"

static void load_entries(lua_State *L, const struct wowless_stub_entry *e) {
  lua_newtable(L);
  lua_newtable(L);
  for (; e->name; e++) {
    lua_pushvalue(L, 1);
    lua_pushcclosure(L, e->func, 1);
    if (!e->secureonly) {
      lua_pushvalue(L, -1);
      lua_setfield(L, -4, e->name);
    }
    lua_setfield(L, -2, e->name);
  }
}

int wowless_load_stubs(lua_State *L) {
  const struct wowless_stubs_spec *spec =
      lua_touserdata(L, lua_upvalueindex(1));
  const struct wowless_ns_entry *ns;
  load_entries(L, spec->global);
  for (ns = spec->ns; ns->ns; ns++) {
    load_entries(L, ns->entries);
    lua_setfield(L, -3, ns->ns);
    lua_pushnil(L);
    if (lua_next(L, -2)) {
      lua_pop(L, 2);
      lua_setfield(L, -3, ns->ns);
    } else {
      lua_pop(L, 1);
    }
  }
  return 2;
}
