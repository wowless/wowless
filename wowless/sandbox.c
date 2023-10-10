#include <lauxlib.h>
#include <lualib.h>

typedef struct {
  lua_State *L;
} sandbox;

static const char sandbox_metatable[] = "wowless sandbox";

static int sandbox_create(lua_State *L) {
  lua_State *SL = luaL_newstate();
  if (!SL) {
    return luaL_error(L, "out of memory");
  }
  sandbox *S = lua_newuserdata(L, sizeof(*S));
  S->L = SL;
  return 1;
}

static sandbox *sandbox_check(lua_State *L, int index) {
  return luaL_checkudata(L, index, sandbox_metatable);
}

static int sandbox_gc(lua_State *L) {
  sandbox *S = sandbox_check(L, 1);
  lua_close(S->L);
  return 0;
}

static struct luaL_Reg sandboxlib[] = {
    {NULL, NULL}
};

static struct luaL_Reg modulelib[] = {
    {"create", sandbox_create},
    {NULL,     NULL          }
};

int luaopen_wowless_sandbox(lua_State *L) {
  if (luaL_newmetatable(L, sandbox_metatable)) {
    lua_pushstring(L, "__index");
    lua_newtable(L);
    luaL_register(L, NULL, sandboxlib);
    lua_settable(L, -3);
    lua_pushstring(L, "__gc");
    lua_pushcfunction(L, sandbox_gc);
    lua_settable(L, -3);
    lua_pushstring(L, "__metatable");
    lua_pushstring(L, sandbox_metatable);
    lua_settable(L, -3);
  }
  lua_pop(L, 1);
  lua_newtable(L);
  luaL_register(L, NULL, modulelib);
  return 1;
}
