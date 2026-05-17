#include "wowless/primtable.h"

#include "lauxlib.h"

int wowless_copy_prim_table(lua_State *dst, lua_State *src, int srcidx);

int wowless_copy_prim_value(lua_State *dst, lua_State *src, int srcidx) {
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
      return wowless_copy_prim_table(dst, src, srcidx);
    default:
      return lua_type(src, srcidx);
  }
}

int wowless_copy_prim_table(lua_State *dst, lua_State *src, int srcidx) {
  if (srcidx < 0) {
    srcidx = lua_gettop(src) + 1 + srcidx;
  }
  lua_newtable(dst);
  lua_pushnil(src);
  while (lua_next(src, srcidx)) {
    int keytype = lua_type(src, -2);
    if (keytype == LUA_TSTRING || keytype == LUA_TNUMBER) {
      wowless_copy_prim_value(dst, src,
                              lua_gettop(src) - 1); /* key: always ok */
      int err = wowless_copy_prim_value(dst, src, lua_gettop(src)); /* value */
      if (err) {
        lua_pop(dst, 1); /* key copy */
        lua_pop(src, 2); /* value + key from iteration */
        lua_pop(dst, 1); /* partial table */
        return err;
      }
      lua_settable(dst, -3);
    }
    lua_pop(src, 1); /* pop value, keep key for lua_next */
  }
  return 0;
}
