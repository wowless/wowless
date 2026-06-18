#include "lauxlib.h"
#include "lua.h"

static void assert_host_mode(lua_State *L) {
  int tm = lua_gettaintmode(L);
  if (tm != LUA_TAINTDISABLED) {
    luaL_error(L, "wowless bug: host taint mode %d", tm);
  }
  const char *st = lua_getstacktaint(L);
  if (st != NULL) {
    luaL_error(L, "wowless bug: host stack taint %s", st);
  }
}

static int call_safely(lua_State *L) {
  assert_host_mode(L);
  lua_getfenv(L, 1);
  lua_pushvalue(L, LUA_ENVIRONINDEX);
  if (!lua_rawequal(L, -1, -2)) {
    return luaL_error(L, "wowless bug: expected framework function");
  }
  lua_pop(L, 2);
  lua_pushvalue(L, lua_upvalueindex(1));
  lua_insert(L, 1);
  lua_pcall(L, lua_gettop(L) - 2, 0, 1);
  assert_host_mode(L);
  return 0;
}

static int call_sandbox(lua_State *L) {
  assert_host_mode(L);
  lua_getfenv(L, 1);
  lua_pushvalue(L, LUA_ENVIRONINDEX);
  if (lua_rawequal(L, -1, -2)) {
    return luaL_error(L, "wowless bug: expected sandbox function");
  }
  lua_pop(L, 2);
  lua_pushvalue(L, lua_upvalueindex(1));
  lua_insert(L, 1);
  lua_settaintmode(L, LUA_TAINTRDRW);
  int err = lua_pcall(L, lua_gettop(L) - 2, LUA_MULTRET, 1);
  int tm = lua_gettaintmode(L);
  lua_settaintmode(L, LUA_TAINTDISABLED);
  lua_setstacktaint(L, NULL);
  if (tm != LUA_TAINTRDRW) {
    return luaL_error(L, "wowless bug: sandbox taint mode %d", tm);
  }
  lua_pushboolean(L, !err);
  lua_replace(L, 1);
  return lua_gettop(L);
}

static int make_module(lua_State *L) {
  lua_getfield(L, 1, "ErrorHandler");
  lua_newtable(L);
  lua_pushvalue(L, 2);
  lua_pushcclosure(L, call_safely, 1);
  lua_setfield(L, 3, "CallSafely");
  lua_pushvalue(L, 2);
  lua_pushcclosure(L, call_sandbox, 1);
  lua_setfield(L, 3, "CallSandbox");
  return 1;
}

int luaopen_wowless_modules_security(lua_State *L) {
  lua_pushcfunction(L, make_module);
  return 1;
}
