#ifndef WOWLESS_LUAOBJECT_H
#define WOWLESS_LUAOBJECT_H

#include <stddef.h>

#include "lua.h"

void wowless_luaobject_make(lua_State *L, const char *name, size_t namelen);

#endif /* WOWLESS_LUAOBJECT_H */
