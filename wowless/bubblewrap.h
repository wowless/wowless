#ifndef WOWLESS_BUBBLEWRAP_H
#define WOWLESS_BUBBLEWRAP_H

#include "lua.h"

/*
 * Wraps the function at the top of the stack in a bubblewrapper closure,
 * replacing it in-place. The resulting closure is a C function that handles
 * taint mode switching when called from sandbox (addon) code.
 */
void wowless_bubblewrap(lua_State *L);

/*
 * Enter host taint mode from sandbox. Returns the saved stack taint string
 * (may be NULL). Errors if not called from sandbox (RDRW) taint mode.
 */
const char *wowless_bubblewrap_cstub_enter(lua_State *L);

/*
 * Exit host taint mode, restoring sandbox taint mode and the saved stack
 * taint. Must be called with the saved stack taint from
 * wowless_bubblewrap_cstub_enter. Checks that no taint leaked out of the
 * host call. Errors if taint leaked; otherwise returns normally.
 */
void wowless_bubblewrap_cstub_exit(lua_State *L, const char *intaint);

#endif /* WOWLESS_BUBBLEWRAP_H */
