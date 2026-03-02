#include "wowless/bubblewrap.h"

#include "lauxlib.h"

const char *wowless_bubblewrap_cstub_enter(lua_State *L) {
  int inmode = lua_gettaintmode(L);
  if (inmode != LUA_TAINTRDRW) {
    luaL_error(L, "wowless bug: sandbox taint mode %d", inmode);
  }
  lua_settaintmode(L, LUA_TAINTDISABLED);
  const char *intaint = lua_getstacktaint(L);
  lua_setstacktaint(L, NULL);
  if (intaint) {
    lua_pushstring(L, intaint);
    lua_setfield(L, LUA_ENVIRONINDEX, "THETAINT");
  }
  return intaint;
}

void wowless_bubblewrap_cstub_exit(lua_State *L, const char *intaint) {
  int outmode = lua_gettaintmode(L);
  const char *outtaint = lua_getstacktaint(L);
  lua_setstacktaint(L, intaint);
  lua_settaintmode(L, LUA_TAINTRDRW);
  lua_pushnil(L);
  lua_setfield(L, LUA_ENVIRONINDEX, "THETAINT");
  if (outmode != LUA_TAINTDISABLED) {
    luaL_error(L, "wowless bug: host taint mode %d", outmode);
  }
  if (outtaint) {
    luaL_error(L, "wowless bug: host stack taint %s", outtaint);
  }
}

static int bubblewrapper(lua_State *L) {
  const char *intaint = wowless_bubblewrap_cstub_enter(L);
  lua_pushvalue(L, lua_upvalueindex(1));
  lua_insert(L, 1);
  int err = lua_pcall(L, lua_gettop(L) - 1, LUA_MULTRET, 0);
  wowless_bubblewrap_cstub_exit(L, intaint);
  return err == 0 ? lua_gettop(L) : lua_error(L);
}

void wowless_bubblewrap(lua_State *L) { lua_pushcclosure(L, bubblewrapper, 1); }

static int bubblewrap(lua_State *L) {
  lua_settop(L, 1);
  wowless_bubblewrap(L);
  return 1;
}

int luaopen_wowless_bubblewrap(lua_State *L) {
  lua_pushcfunction(L, bubblewrap);
  return 1;
}
