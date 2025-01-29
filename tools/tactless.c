#include "tactless.h"

#include <stdlib.h>

#include "lauxlib.h"
#include "lualib.h"

static int tactopen(lua_State *L) {
  tactless **u = lua_newuserdata(L, sizeof(tactless *));
  *u = tactless_open(luaL_checkstring(L, 2), luaL_optstring(L, 3, 0));
  if (!*u) {
    return 0;
  }
  luaL_getmetatable(L, "tactless");
  lua_setmetatable(L, -2);
  return 1;
}

static int tactcall(lua_State *L) {
  tactless **u = luaL_checkudata(L, 1, "tactless");
  lua_Number fdid = lua_tonumber(L, 2);
  unsigned char *s;
  size_t size;
  if (fdid) {
    s = tactless_get_fdid(*u, fdid, &size);
  } else {
    s = tactless_get_name(*u, luaL_checkstring(L, 2), &size);
  }
  if (!s) {
    return 0;
  }
  lua_pushlstring(L, s, size);
  free(s);
  return 1;
}

static int tactbuild(lua_State *L) {
  char hash[33];
  int major, minor, patch, build;
  if (!tactless_current_build(luaL_checkstring(L, 1), hash, &major, &minor,
                              &patch, &build)) {
    return 0;
  }
  lua_pushlstring(L, hash, 32);
  lua_pushnumber(L, major);
  lua_pushnumber(L, minor);
  lua_pushnumber(L, patch);
  lua_pushnumber(L, build);
  return 5;
}

static int tactgc(lua_State *L) {
  tactless **u = luaL_checkudata(L, 1, "tactless");
  tactless_close(*u);
  return 0;
}

int luaopen_tactless(lua_State *L) {
  if (luaL_newmetatable(L, "tactless")) {
    lua_pushcfunction(L, tactcall);
    lua_setfield(L, -2, "__call");
    lua_pushcfunction(L, tactgc);
    lua_setfield(L, -2, "__gc");
    lua_pushstring(L, "tactless");
    lua_setfield(L, -2, "__metatable");
  }
  lua_newtable(L);
  if (luaL_newmetatable(L, "tactlesslib")) {
    lua_pushcfunction(L, tactopen);
    lua_setfield(L, -2, "__call");
    lua_newtable(L);
    lua_pushcfunction(L, tactbuild);
    lua_setfield(L, -2, "build");
    lua_setfield(L, -2, "__index");
    lua_pushstring(L, "tactlesslib");
    lua_setfield(L, -2, "__metatable");
  }
  lua_setmetatable(L, -2);
  return 1;
}
