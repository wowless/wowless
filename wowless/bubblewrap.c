#include "lauxlib.h"
#include "lualib.h"

static int bubblewrapper(lua_State *L) {
  int inmode = lua_gettaintmode(L);
  if (inmode != LUA_TAINTRDRW) {
    return luaL_error(L, "wowless bug: sandbox taint mode %d", inmode);
  }
  lua_settaintmode(L, LUA_TAINTDISABLED);
  const char *intaint = lua_getstacktaint(L);
  lua_setstacktaint(L, 0);
  lua_pushvalue(L, lua_upvalueindex(1));
  lua_insert(L, 1);
  int err = lua_pcall(L, lua_gettop(L) - 1, LUA_MULTRET, 0);
  int outmode = lua_gettaintmode(L);
  const char *outtaint = lua_getstacktaint(L);
  lua_setstacktaint(L, intaint);
  lua_settaintmode(L, LUA_TAINTRDRW);
  if (outmode != LUA_TAINTDISABLED) {
    return luaL_error(L, "wowless bug: host taint mode %d", outmode);
  }
  if (outtaint) {
    return luaL_error(L, "wowless bug: host stack taint %s", outtaint);
  }
  return err == 0 ? lua_gettop(L) : lua_error(L);
}

static int bubblewrap(lua_State *L) {
  lua_settop(L, 1);
  lua_pushcclosure(L, bubblewrapper, 1);
  return 1;
}

int luaopen_wowless_bubblewrap(lua_State *L) {
  lua_pushcfunction(L, bubblewrap);
  return 1;
}
