extern "C" {
#include "wowless/stubs.h"

#include "lauxlib.h"
#include "wowless/bubblewrap.h"
#include "wowless/luaobject.h"
}

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

static void load_impl_data(lua_State *L, const struct wowless_impl_data *d) {
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
}

static void load_entry(lua_State *L, const struct wowless_stub_entry *e) {
  if (e->impldata) {
    load_impl_data(L, e->impldata);
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

/*
 * Variant of load_entries that deduplicates closures via a func-ptr-keyed table
 * so that inherited methods share the same Lua function object across types.
 */
static void load_entries_dedup(lua_State *L, const struct wowless_stub_entry *e,
                               int dedup_idx) {
  lua_newtable(L); /* sandbox */
  for (; e->name; e++) {
    lua_pushlightuserdata(L, reinterpret_cast<void *>(e->func));
    lua_rawget(L, dedup_idx);
    if (lua_isnil(L, -1)) {
      lua_pop(L, 1);
      load_entry(L, e);
      lua_pushlightuserdata(L, reinterpret_cast<void *>(e->func));
      lua_pushvalue(L, -2); /* dup closure */
      lua_rawset(L, dedup_idx);
    }
    lua_setfield(L, -2, e->name); /* into sandbox */
  }
}

int wowless_load_luaobject_stubs(lua_State *L) {
  const auto *spec = static_cast<const wowless_luaobject_type_entry *>(
      lua_touserdata(L, lua_upvalueindex(1)));
  /* arg 1: modules, arg 2: luaobject module, arg 3: tostring_enabled */
  bool tostring_enabled = lua_toboolean(L, 3);
  lua_getfield(L, 1, "cgencode");
  lua_insert(L, 1);
  /* Stack: [cgencode=1, modules=2, luaobject=3, bool=4] */
  lua_getfield(L, 3, "metatables");
  /* Stack: [cgencode=1, modules=2, luaobject=3, bool=4, metatables=5] */
  lua_newtable(L); /* dedup=6 */
  lua_newtable(L); /* result=7 */
  for (const wowless_luaobject_type_entry *t = spec; t->type_name; t++) {
    load_entries_dedup(L, t->methods, 6); /* pushes methods=8 */
    wowless_luaobject_register_mt(L, 5, t->type_id, 8,
                                  tostring_enabled ? t->type_name : nullptr);
    lua_pop(L, 1); /* pop methods=8 */
    lua_newtable(L);
    lua_pushinteger(L, t->type_id);
    lua_setfield(L, -2, "typeid");
    lua_setfield(L, 7, t->type_name);
  }
  lua_remove(L, 6); /* remove dedup */
  return 1;
}

static int make_uiobject_method_stub(lua_State *L) {
  auto fn = reinterpret_cast<lua_CFunction>(lua_touserdata(L, lua_upvalueindex(1)));
  lua_pushvalue(L, lua_upvalueindex(2)); /* cgencode */
  lua_pushcclosure(L, fn, 1);
  return 1;
}

static int make_uiobject_impl_stub(lua_State *L) {
  /* upvalues: 1=cgencode, 2=luafn, 3=fn ptr */
  auto fn = reinterpret_cast<lua_CFunction>(lua_touserdata(L, lua_upvalueindex(3)));
  lua_pushvalue(L, lua_upvalueindex(1)); /* cgencode */
  lua_pushvalue(L, lua_upvalueindex(2)); /* luafn */
  lua_pushcclosure(L, fn, 2);
  return 1;
}

int wowless_load_uiobject_method_stubs(lua_State *L) {
  const auto *spec = static_cast<const wowless_uiobject_method_entry *>(
      lua_touserdata(L, lua_upvalueindex(1)));
  /* arg 1 is modules */
  lua_getfield(L, 1, "cgencode");
  lua_insert(L, 1);
  /* Stack: [cgencode=1, modules=2] */
  lua_newtable(L); /* sandbox factories */
  lua_newtable(L); /* host Lua functions */
  for (const auto *e = spec; e->key; e++) {
    load_impl_data(L, e->host);
    if (e->sandbox_delegates_to_host) {
      lua_pushvalue(L, -1);        /* dup luafn for host table */
      lua_setfield(L, -3, e->key); /* into host table */
      lua_pushvalue(L, 1);         /* cgencode */
      lua_insert(L, -2);           /* cgencode, luafn */
      lua_pushlightuserdata(L, reinterpret_cast<void *>(e->func));
      lua_pushcclosure(L, make_uiobject_impl_stub, 3);
    } else {
      lua_setfield(L, -2, e->key); /* into host table */
      lua_pushlightuserdata(L, reinterpret_cast<void *>(e->func));
      lua_pushvalue(L, 1); /* cgencode */
      lua_pushcclosure(L, make_uiobject_method_stub, 2);
    }
    lua_setfield(L, -3, e->key); /* into sandbox table */
  }
  return 2;
}

int wowless_load_eventcheck_stubs(lua_State *L) {
  const auto *reg =
      static_cast<const luaL_Reg *>(lua_touserdata(L, lua_upvalueindex(1)));
  /* arg 1 is modules; extract cgencode from it */
  lua_getfield(L, 1, "cgencode");
  lua_newtable(L);
  for (const luaL_Reg *r = reg; r->name; r++) {
    lua_pushvalue(L, 2);
    lua_pushcclosure(L, r->func, 1);
    lua_setfield(L, -2, r->name);
  }
  return 1;
}

int wowless_load_stubs(lua_State *L) {
  const auto *spec =
      static_cast<const wowless_stubs_spec *>(lua_touserdata(L, lua_upvalueindex(1)));
  lua_getfield(L, 1, "cgencode");
  lua_insert(L, 1);
  load_entries(L, spec->global);
  for (const wowless_ns_entry *ns = spec->ns; ns->ns; ns++) {
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
