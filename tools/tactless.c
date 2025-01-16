#include "tactless.h"

#include "lauxlib.h"
#include "lualib.h"

static int tactopen(lua_State *L) {
  tactless *t = tactless_open(luaL_checkstring(L, 1));
  if (!t) {
    return 0;
  }
  tactless **u = lua_newuserdata(L, sizeof(t));
  *u = t;
  luaL_getmetatable(L, "tactless");
  lua_setmetatable(L, -2);
  return 1;
}

static int tactfetch(lua_State *L) {
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
  return 1;
}

int luaopen_tactless(lua_State *L) {
  if (luaL_newmetatable(L, "tactless")) {
    lua_pushcfunction(L, tactfetch);
    lua_setfield(L, -2, "__call");
    lua_pushstring(L, "tactless");
    lua_setfield(L, -2, "__metatable");
  }
  lua_pushcfunction(L, tactopen);
  return 1;
}
