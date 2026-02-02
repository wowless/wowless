#include "lauxlib.h"
#include "lua.h"

static int domixin(lua_State *L) {
  int n = lua_gettop(L);
  for (int i = 2; i <= n; ++i) {
    luaL_checktype(L, i, LUA_TTABLE);
  }
  for (int i = 2; i <= n; ++i) {
    lua_pushnil(L);
    while (lua_next(L, i)) {
      lua_pushvalue(L, -2);
      lua_insert(L, -3);
      lua_rawset(L, 1);
    }
  }
  lua_settop(L, 1);
  return 1;
}

static int mixin(lua_State *L) {
  luaL_checkstack(L, 3, "Mixin");
  luaL_checktype(L, 1, LUA_TTABLE);
  return domixin(L);
}

static int createfrommixins(lua_State *L) {
  luaL_checkstack(L, 4, "CreateFromMixins");
  lua_newtable(L);
  lua_insert(L, 1);
  return domixin(L);
}

int luaopen_wowless_mixin(lua_State *L) {
  lua_newtable(L);
  lua_pushcfunction(L, mixin);
  lua_setfield(L, -2, "Mixin");
  lua_pushcfunction(L, createfrommixins);
  lua_setfield(L, -2, "CreateFromMixins");
  return 1;
}
