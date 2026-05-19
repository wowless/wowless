#ifndef WOWLESS_UIOBJECT_H
#define WOWLESS_UIOBJECT_H

#include <stddef.h>
#include <stdint.h>

#include "lua.h"

extern const char wowless_uiobject_marker;

struct wowless_uitype {
  uint64_t isa_mask;
};

struct wowless_uiobject_data {
  const void *marker;
  int id;
  uint64_t isa_mask;
};

static inline int wowless_uiobject_getid(lua_State *L, int idx) {
  if (lua_type(L, idx) != LUA_TUSERDATA ||
      lua_objlen(L, idx) != sizeof(struct wowless_uiobject_data)) {
    return 0;
  }
  struct wowless_uiobject_data *ud =
      (struct wowless_uiobject_data *)lua_touserdata(L, idx);
  if (ud->marker != &wowless_uiobject_marker) {
    return 0;
  }
  return ud->id;
}

#endif /* WOWLESS_UIOBJECT_H */
