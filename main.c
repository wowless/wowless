#include <stdlib.h>
#include <stdio.h>
#include "lualib.h"
#include "lauxlib.h"

extern int luaopen_build_cmake_ext(lua_State *);
extern int luaopen_lfs(lua_State *);
extern int luaopen_lsqlite3(lua_State *);
extern int luaopen_lxp(lua_State *);
extern int luaopen_yaml(lua_State *);
extern int luaopen_zlib(lua_State *);

struct module {
  const char* name;
  lua_CFunction func;
};
static const struct module modules[] = {
  { "build.cmake.ext", luaopen_build_cmake_ext },
  { "lfs", luaopen_lfs },
  { "lsqlite3", luaopen_lsqlite3 },
  { "lxp", luaopen_lxp },
  { "yaml", luaopen_yaml },
  { "zlib", luaopen_zlib },
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
  for (int i = 1; i < argc; ++i) {
    lua_pushstring(L, argv[i]);
    lua_rawseti(L, -2, i - 1);
  }
  lua_setglobal(L, "arg");
  if (luaL_dofile(L, argv[1]) != 0) {
    puts(lua_tostring(L, -1));
  }
  lua_close(L);
  return EXIT_SUCCESS;
}
