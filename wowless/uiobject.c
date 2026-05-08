#include "wowless/uiobject.h"

void wowless_uiobject_alloc(lua_State *L, uint16_t type_id) {
  struct wowless_uiobject *u =
      lua_newuserdata(L, sizeof(struct wowless_uiobject));
  u->magic = WOWLESS_UIOBJECT_MAGIC;
  u->type_id = type_id;
  u->_pad = 0;
  lua_pushlightuserdata(L, u);
}
