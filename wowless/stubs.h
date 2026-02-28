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
  int nobubblewrap;
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

int wowless_load_stubs(lua_State *L);

#endif /* WOWLESS_STUBS_H */
