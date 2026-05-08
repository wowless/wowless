#ifndef WOWLESS_UIOBJECT_H
#define WOWLESS_UIOBJECT_H

#include <stddef.h>
#include <stdint.h>

#include "lua.h"

/*
 * C-side identity for uiobjects. The lightuserdata at obj[0] (and the
 * full userdata at internal[0]) point to a struct wowless_uiobject. The
 * full userdata holds Lua-managed memory; the lightuserdata is a raw
 * alias used for cheap identity in keys and stub typechecks.
 */

#define WOWLESS_UIOBJECT_MAGIC 0x57554F00u /* "WUO\0" */
#define WOWLESS_UIOBJECT_ISA_WORDS 2       /* up to 128 types per product */

struct wowless_uiobject {
  uint32_t magic;
  uint16_t type_id;
  uint16_t _pad;
};

struct wowless_uiobject_typeinfo {
  const char *lower_name;
  const char *display_name;
  uint64_t isa[WOWLESS_UIOBJECT_ISA_WORDS];
};

/*
 * Allocates a struct wowless_uiobject as a Lua-managed full userdata.
 * Pushes (full_userdata, lightuserdata) on the stack. Caller is
 * responsible for keeping the full userdata alive (we anchor it on
 * the internal table at index 0 in api.lua).
 */
void wowless_uiobject_alloc(lua_State *L, uint16_t type_id);

static inline const struct wowless_uiobject *wowless_uiobject_check_ptr(
    const void *p) {
  const struct wowless_uiobject *u = p;
  return (u && u->magic == WOWLESS_UIOBJECT_MAGIC) ? u : NULL;
}

static inline int wowless_uiobject_isa_id(
    const struct wowless_uiobject *u,
    const struct wowless_uiobject_typeinfo *typeinfo, uint16_t target_id) {
  uint64_t bit = (uint64_t)1 << (target_id & 63);
  return (typeinfo[u->type_id].isa[target_id >> 6] & bit) != 0;
}

#endif /* WOWLESS_UIOBJECT_H */
