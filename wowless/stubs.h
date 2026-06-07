#ifndef WOWLESS_STUBS_H
#define WOWLESS_STUBS_H

#include <stddef.h>

#include "lua.h"

struct wowless_impl_data {
  const char *impl;
  size_t impl_len;
  const char *chunkname;
  const char *const *modules; /* NULL-terminated array, or NULL */
  const char *const *sqls;    /* NULL-terminated array, or NULL */
};

struct wowless_stub_entry {
  const char *name;
  lua_CFunction func;
  int secureonly;
  const struct wowless_impl_data *impldata; /* NULL for C stub entries */
};

struct wowless_ns_entry {
  const char *ns;
  const struct wowless_stub_entry *entries;
};

struct wowless_stubs_spec {
  const struct wowless_stub_entry *global;
  const struct wowless_ns_entry *ns;
};

struct wowless_luaobject_type_entry {
  const char *type_name;
  int type_id;
  const struct wowless_stub_entry *methods;
};

struct wowless_uiobject_method_entry {
  const char *key;
  lua_CFunction func;
  const struct wowless_impl_data *host; /* host impl, loaded as Lua function */
  int sandbox_delegates_to_host; /* non-zero when sandbox stub calls through to
                                    host impl */
};

int wowless_load_stubs(lua_State *L);
int wowless_load_luaobject_stubs(lua_State *L);
int wowless_load_uiobject_method_stubs(lua_State *L);
int wowless_load_eventcheck_stubs(lua_State *L);
void wowless_stub_log_extra_args(lua_State *L, const char *fname);
int wowless_impl_stub(lua_State *L);
int wowless_impl_stub_nobubblewrap(lua_State *L);
int wowless_outputerror(lua_State *L, int idx, const char *extramsg);
int wowless_outputtyperror(lua_State *L, int idx, const char *tname);

#endif /* WOWLESS_STUBS_H */
