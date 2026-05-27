#ifndef WOWLESS_STUBS_H
#define WOWLESS_STUBS_H

#include <stddef.h>

#include "lua.h"

typedef struct wowless_impl_data {
  const char *impl;
  size_t impl_len;
  const char *chunkname;
  const char *const *modules; /* NULL-terminated array, or NULL */
  const char *const *sqls;    /* NULL-terminated array, or NULL */
} wowless_impl_data;

typedef struct wowless_stub_entry {
  const char *name;
  lua_CFunction func;
  int secureonly;
  const wowless_impl_data *impldata; /* NULL for C stub entries */
} wowless_stub_entry;

typedef struct wowless_ns_entry {
  const char *ns;
  const wowless_stub_entry *entries;
} wowless_ns_entry;

typedef struct wowless_stubs_spec {
  const wowless_stub_entry *global;
  const wowless_ns_entry *ns;
} wowless_stubs_spec;

typedef struct wowless_luaobject_type_entry {
  const char *type_name;
  int type_id;
  const wowless_stub_entry *methods;
} wowless_luaobject_type_entry;

typedef struct wowless_uiobject_method_entry {
  const char *key;
  lua_CFunction func;
} wowless_uiobject_method_entry;

int wowless_load_stubs(lua_State *L);
int wowless_load_luaobject_stubs(lua_State *L);
int wowless_load_uiobject_method_stubs(lua_State *L);
void wowless_stub_log_extra_args(lua_State *L, const char *fname);
int wowless_impl_stub(lua_State *L);
int wowless_impl_stub_nobubblewrap(lua_State *L);
int wowless_outputerror(lua_State *L, int idx, const char *extramsg);
int wowless_outputtyperror(lua_State *L, int idx, const char *tname);

#endif /* WOWLESS_STUBS_H */
