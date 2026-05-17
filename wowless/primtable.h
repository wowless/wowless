#ifndef WOWLESS_PRIMTABLE_H
#define WOWLESS_PRIMTABLE_H

#include "lua.h"

/*
 * Copy a primitive value from src[srcidx] to dst.
 * Returns 0 on success (value pushed on dst).
 * Returns the Lua type code on failure (nothing pushed on dst).
 * Supported types: nil, boolean, number, string, table (recursively).
 */
int wowless_copy_prim_value(lua_State *dst, lua_State *src, int srcidx);

/*
 * Copy a table from src[srcidx] to dst as a new table.
 * Returns 0 on success (table pushed on dst).
 * Returns the Lua type code of the first unsupported value (nothing pushed on
 * dst). Non-string/non-number keys are silently skipped.
 */
int wowless_copy_prim_table(lua_State *dst, lua_State *src, int srcidx);

#endif
