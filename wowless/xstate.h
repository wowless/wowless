#ifndef WOWLESS_XSTATE_H
#define WOWLESS_XSTATE_H

#include "lua.h"

/*
 * Copy a value from src[srcidx] to dst.
 * Returns 0 on success (value pushed on dst).
 * Returns the Lua type code on failure (nothing pushed on dst).
 * Supported types: nil, boolean, number, string, table (recursively,
 * including table keys).
 */
int wowless_copy_xstate_value(lua_State *dst, lua_State *src, int srcidx);

#endif
