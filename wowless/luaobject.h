#ifndef WOWLESS_LUAOBJECT_H
#define WOWLESS_LUAOBJECT_H

#include <stdbool.h>
#include <stddef.h>

#include "lua.h"

extern const char wowless_luaobject_marker;

struct wowless_luaobject_data {
  const void *marker;
  int type_id;
};

static inline const struct wowless_luaobject_data *wowless_toluaobject(
    lua_State *L, int idx) {
  if (lua_type(L, idx) != LUA_TUSERDATA ||
      lua_objlen(L, idx) != sizeof(struct wowless_luaobject_data)) {
    return NULL;
  }
  const struct wowless_luaobject_data *ud =
      (const struct wowless_luaobject_data *)lua_touserdata(L, idx);
  return ud->marker == &wowless_luaobject_marker ? ud : NULL;
}

static inline bool wowless_isluaobject(lua_State *L, int idx, int type_id) {
  const struct wowless_luaobject_data *ud = wowless_toluaobject(L, idx);
  return ud && ud->type_id == type_id;
}

void wowless_luaobject_make_mt(lua_State *L, int methods_idx,
                               const char *typename_str);

#endif /* WOWLESS_LUAOBJECT_H */
