#include "lua.h"

/*
 * Called directly (no lua_call) from a generated, genusage-checked
 * api_<name> wrapper -- see tools/prep.lua's `implimpls.native` and `fn`
 * selection, which also emits each function's extern "C" declaration into
 * the generated per-product stub file that calls it.
 *
 * By the time control reaches here, the generated genusage wrapper has
 * already verified arg 1 is a table and any further nilable args (if
 * present) are unconstrained; a nilable arg may still be entirely absent
 * from the stack, so functions that take one normalize it to nil below.
 */
int wowless_native_table_contains(lua_State *L) {
  lua_settop(L, 2); /* pad with nil if value was omitted */

  lua_pushnil(L); /* initial key for iteration */
  while (lua_next(L, 1)) {
    if (lua_rawequal(L, -1, 2)) {
      lua_pushboolean(L, 1);
      return 1;
    }
    lua_pop(L, 1);
  }

  lua_pushboolean(L, 0);
  return 1;
}

int wowless_native_table_keys(lua_State *L) {
  int n = 0;

  lua_newtable(L);
  lua_pushnil(L); /* initial key for iteration */
  while (lua_next(L, 1)) {
    lua_pop(L, 1);
    lua_pushvalue(L, -1);
    lua_rawseti(L, -3, ++n);
  }

  return 1;
}

int wowless_native_table_removevalue(lua_State *L) {
  lua_settop(L, 2); /* pad with nil if value was omitted */

  int n = (int)lua_objlen(L, 1);
  int removed = 0;
  for (int pos = n; pos >= 1; pos--) {
    lua_rawgeti(L, 1, pos);
    int match = lua_rawequal(L, -1, 2);
    lua_pop(L, 1);
    if (match) {
      for (int i = pos; i < n; i++) {
        lua_rawgeti(L, 1, i + 1);
        lua_rawseti(L, 1, i);
      }
      lua_pushnil(L);
      lua_rawseti(L, 1, n);
      n--;
      removed++;
    }
  }

  lua_pushinteger(L, removed);
  return 1;
}
