#ifndef WOWLESS_STUBS_H
#define WOWLESS_STUBS_H

#include "lua.h"

struct wowless_stub_entry {
  const char *name;
  lua_CFunction func;
  int secureonly;
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
