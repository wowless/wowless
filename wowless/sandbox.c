#include <lauxlib.h>
#include <lua.h>

static const char UD[] = "wowless-sandbox";

static int sandbox_create(lua_State *L) {
  lua_State **S = (lua_State **)lua_newuserdata(L, sizeof(lua_State *));
  *S = luaL_newstate();
  luaL_getmetatable(L, UD);
  lua_setmetatable(L, -2);
  return 1;
}

static int sandbox_dostring(lua_State *L) {
  lua_settop(L, 2);
  lua_State *S = *(lua_State **)luaL_checkudata(L, 1, UD);
  const char *str = luaL_checkstring(L, 2);
  if (luaL_dostring(S, str) == 0) {
    lua_settop(S, 0);
  } else {
    lua_pushstring(L, lua_tostring(S, 1));
    lua_settop(S, 0);
    lua_error(L);
  }
  return 0;
}

int luaopen_wowless_sandbox(lua_State *L) {
  if (luaL_newmetatable(L, UD)) {
    lua_newtable(L);
    lua_pushcfunction(L, sandbox_dostring);
    lua_setfield(L, -2, "dostring");
    lua_setfield(L, -2, "__index");
    lua_pushstring(L, UD);
    lua_setfield(L, -2, "__metatable");
    lua_pop(L, 1);
  }
  lua_newtable(L);
  lua_pushcfunction(L, sandbox_create);
  lua_setfield(L, -2, "create");
  return 1;
}
