#include "wowless/xstate.h"

/* xstate_copy_table calls wowless_copy_xstate_value declared in the header. */
static int xstate_copy_table(lua_State *dst, lua_State *src, int srcidx) {
  if (srcidx < 0) {
    srcidx = lua_gettop(src) + 1 + srcidx;
  }
  lua_newtable(dst);
  lua_pushnil(src);
  while (lua_next(src, srcidx)) {
    int err =
        wowless_copy_xstate_value(dst, src, lua_gettop(src) - 1); /* key */
    if (err) {
      lua_pop(src, 2); /* key + value */
      lua_pop(dst, 1); /* partial table */
      return err;
    }
    err = wowless_copy_xstate_value(dst, src, lua_gettop(src)); /* value */
    if (err) {
      lua_pop(dst, 1); /* copied key */
      lua_pop(src, 2); /* key + value */
      lua_pop(dst, 1); /* partial table */
      return err;
    }
    lua_settable(dst, -3);
    lua_pop(src, 1); /* pop value, keep key for lua_next */
  }
  return 0;
}

int wowless_copy_xstate_value(lua_State *dst, lua_State *src, int srcidx) {
  switch (lua_type(src, srcidx)) {
    case LUA_TNIL:
      lua_pushnil(dst);
      return 0;
    case LUA_TBOOLEAN:
      lua_pushboolean(dst, lua_toboolean(src, srcidx));
      return 0;
    case LUA_TNUMBER:
      lua_pushnumber(dst, lua_tonumber(src, srcidx));
      return 0;
    case LUA_TSTRING:
      lua_pushstring(dst, lua_tostring(src, srcidx));
      return 0;
    case LUA_TTABLE:
      return xstate_copy_table(dst, src, srcidx);
    default:
      return lua_type(src, srcidx);
  }
}
