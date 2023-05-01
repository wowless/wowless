#include <stdlib.h>
#include <stdio.h>
#include "lualib.h"
#include "lauxlib.h"

extern int luaopen_wowless_ext(lua_State *);

struct module {
  const char* name;
  lua_CFunction func;
};
static const struct module modules[] = {
  { "wowless.ext", luaopen_wowless_ext },
};

int main(int argc, char **argv) {
  lua_State *L = luaL_newstate();
  if (L == NULL) {
    return EXIT_FAILURE;
  }
  luaL_openlibsx(L, LUALIB_ELUNE);
  luaL_openlibsx(L, LUALIB_STANDARD);
  lua_getfield(L, LUA_REGISTRYINDEX, "_LOADED");
  for (size_t i = 0; i < sizeof(modules) / sizeof(struct module); ++i) {
    const struct module *m = &modules[i];
    lua_pushcfunction(L, m->func);
    lua_pushstring(L, m->name);
    lua_call(L, 1, 1);
    lua_setfield(L, -2, m->name);
  }
  lua_pop(L, 1);
  lua_newtable(L);
  for (int i = 0; i < argc; ++i) {
    lua_pushstring(L, argv[i]);
    lua_rawseti(L, -2, i);
  }
  lua_setglobal(L, "arg");
  if (luaL_dofile(L, "wowless.lua") != 0) {
    puts(lua_tostring(L, -1));
  }
  lua_close(L);
  return EXIT_SUCCESS;
}
