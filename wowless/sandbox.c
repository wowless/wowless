#include <lauxlib.h>
#include <lualib.h>

static int sandbox_create(lua_State *L) {
  lua_newtable(L);
  return 1;
}

static struct luaL_Reg lib[] = {
    {"create", sandbox_create},
    {NULL,     NULL          }
};

int luaopen_wowless_sandbox(lua_State *L) {
  lua_newtable(L);
  luaL_register(L, NULL, lib);
  return 1;
}
