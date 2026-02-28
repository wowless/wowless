#ifndef WOWLESS_BUBBLEWRAP_H
#define WOWLESS_BUBBLEWRAP_H

#include "lua.h"

/*
 * Wraps the function at the top of the stack in a bubblewrapper closure,
 * replacing it in-place. The resulting closure is a C function that handles
 * taint mode switching when called from sandbox (addon) code.
 */
void wowless_bubblewrap(lua_State *L);

#endif /* WOWLESS_BUBBLEWRAP_H */
