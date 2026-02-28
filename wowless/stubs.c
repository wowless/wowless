#include "wowless/stubs.h"

#include "lauxlib.h"
#include "wowless/bubblewrap.h"

static void load_entry(lua_State *L, const struct wowless_stub_entry *e) {
  if (e->impldata) {
    const struct wowless_impl_data *d = e->impldata;
    if (luaL_loadbuffer(L, d->impl, d->impl_len, d->chunkname) != 0) {
      lua_error(L);
    }
    int nargs = 0;
    if (d->modules) {
      for (const char *const *m = d->modules; *m; m++, nargs++) {
        lua_getfield(L, 2, *m);
      }
    }
    if (d->sqls) {
      lua_getfield(L, 2, "sqls");
      int sqls_idx = lua_gettop(L);
      for (const char *const *s = d->sqls; *s; s++, nargs++) {
        lua_getfield(L, sqls_idx, *s);
      }
      lua_remove(L, sqls_idx);
    }
    lua_call(L, nargs, 1);
    if (!d->nobubblewrap) {
      wowless_bubblewrap(L);
    }
  } else {
    lua_pushvalue(L, 1);
    lua_pushcclosure(L, e->func, 1);
  }
}

static void load_entries(lua_State *L, const struct wowless_stub_entry *e) {
  lua_newtable(L);
  lua_newtable(L);
  for (; e->name; e++) {
    load_entry(L, e);
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
  lua_getfield(L, 1, "cgencode");
  lua_insert(L, 1);
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
