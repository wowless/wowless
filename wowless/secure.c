#include "lauxlib.h"
#include "lua.h"
#include "luaconf.h"
#include "lualib.h"

#ifndef ELUNE_VERSION
#error Must be compiled against Elune headers.
#endif

/*
 * securecallmethod(obj, method, ...) calls obj:method(...) securely.
 * Stack on entry: obj(1), method(2), args(3..n)
 */
static int wowless_secure_securecallmethod(lua_State *L) {
  lua_getfield(L, 1, luaL_checkstring(L, 2)); /* push obj[method] */
  lua_insert(L, 1); /* move fn to index 1: fn, obj, method, args */
  lua_remove(L, 3); /* remove method: fn, obj, args */
  luaL_securecall(L, (lua_gettop(L) - 1), LUA_MULTRET, LUA_ERRORHANDLERINDEX);
  return lua_gettop(L);
}

static struct luaL_Reg securelib[] = {
    {"securecallmethod", wowless_secure_securecallmethod},
    {NULL,               NULL                           }
};

int luaopen_wowless_secure(lua_State *L) {
  lua_newtable(L);
  luaL_register(L, NULL, securelib);
  return 1;
}
