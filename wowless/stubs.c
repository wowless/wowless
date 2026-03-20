#include "wowless/stubs.h"

#include "lauxlib.h"
#include "wowless/bubblewrap.h"

int wowless_impl_stub(lua_State *L) {
  lua_pushvalue(L, lua_upvalueindex(2));
  lua_insert(L, 1);
  const char *intaint = wowless_bubblewrap_cstub_enter(L);
  int err = lua_pcall(L, lua_gettop(L) - 1, LUA_MULTRET, 0);
  wowless_bubblewrap_cstub_exit(L, intaint);
  return err == 0 ? lua_gettop(L) : lua_error(L);
}

int wowless_impl_stub_nobubblewrap(lua_State *L) {
  lua_pushvalue(L, lua_upvalueindex(2));
  lua_insert(L, 1);
  lua_call(L, lua_gettop(L) - 1, LUA_MULTRET);
  return lua_gettop(L);
}

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
    if (e->func) {
      lua_pushvalue(L, 1);
      lua_insert(L, -2);
      lua_pushcclosure(L, e->func, 2);
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

int wowless_outputtyperror(lua_State *L, int idx, const char *tname) {
  return wowless_outputerror(
      L, idx,
      lua_pushfstring(L, "%s expected, got %s", tname,
                      lua_typename(L, lua_type(L, idx))));
}

int wowless_outputerror(lua_State *L, int idx, const char *extramsg) {
  lua_Debug ar;
  const char *fname = "?";
  if (lua_getstack(L, 0, &ar)) {
    lua_getinfo(L, "n", &ar);
    if (ar.name) {
      fname = ar.name;
    }
  }
  return luaL_error(L, "bad return #%d from '%s' (%s)", idx, fname, extramsg);
}

void wowless_stub_log_extra_args(lua_State *L, const char *fname) {
  lua_Debug ar;
  const char *src = "?";
  int line = 0;
  if (lua_getstack(L, 1, &ar) && lua_getinfo(L, "Sl", &ar)) {
    src = ar.source + (ar.source[0] == '@' || ar.source[0] == '=');
    line = ar.currentline;
  }
  lua_getfield(L, lua_upvalueindex(1), "log");
  lua_pushinteger(L, 1);
  lua_pushfstring(L, "warning: too many arguments passed to %s at %s:%d", fname,
                  src, line);
  lua_call(L, 2, 0);
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
