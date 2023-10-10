#include <lauxlib.h>
#include <lualib.h>

static struct luaL_Reg lib[] = {
    {NULL, NULL}
};

int luaopen_wowless_sandbox(lua_State *L) {
  lua_newtable(L);
  luaL_register(L, NULL, lib);
  return 1;
}
