#include <stdio.h>
#include <stdlib.h>

#include "lauxlib.h"
#include "lualib.h"

extern int luaopen_lfs(lua_State *);
extern int luaopen_lsqlite3(lua_State *);
extern int luaopen_wowless_ext(lua_State *);
extern int luaopen_zlib(lua_State *);
extern void preload_argparse(lua_State *);
extern void preload_date(lua_State *);
extern void preload_expat(lua_State *);
extern void preload_luapath(lua_State *);
extern void preload_luassert(lua_State *);
extern void preload_lyaml(lua_State *);
extern void preload_minheap(lua_State *);
extern void preload_penlight(lua_State *);
extern void preload_say(lua_State *);
extern void preload_tsort(lua_State *);
extern void preload_vstruct(lua_State *);

struct module {
  const char *name;
  lua_CFunction func;
};
static const struct module modules[] = {
    {"lfs",         luaopen_lfs        },
    {"lsqlite3",    luaopen_lsqlite3   },
    {"wowless.ext", luaopen_wowless_ext},
    {"zlib",        luaopen_zlib       },
};

int main(int argc, char **argv) {
  lua_State *L = luaL_newstate();
  if (L == NULL) {
    return EXIT_FAILURE;
  }
  luaL_openlibsx(L, LUALIB_ELUNE);
  luaL_openlibsx(L, LUALIB_STANDARD);
  preload_argparse(L);
  preload_date(L);
  preload_expat(L);
  preload_luapath(L);
  preload_luassert(L);
  preload_lyaml(L);
  preload_minheap(L);
  preload_penlight(L);
  preload_say(L);
  preload_tsort(L);
  preload_vstruct(L);
  lua_getglobal(L, "package");
  lua_pushstring(L, "./?.lua");
  lua_setfield(L, -2, "path");
  lua_getfield(L, -1, "loaders");
  lua_createtable(L, 2, 0);
  lua_rawgeti(L, -2, 1);
  lua_rawseti(L, -2, -1);
  lua_rawgeti(L, -2, 2);
  lua_rawseti(L, -2, -1);
  lua_setfield(L, -1, "loaders");
  lua_pop(L, 1);
  lua_getfield(L, -1, "preload");
  for (size_t i = 0; i < sizeof(modules) / sizeof(struct module); ++i) {
    const struct module *m = &modules[i];
    lua_pushcfunction(L, m->func);
    lua_setfield(L, -2, m->name);
  }
  lua_pop(L, 2);
  lua_newtable(L);
  for (int i = 0; i < argc; ++i) {
    lua_pushstring(L, argv[i]);
    lua_rawseti(L, -2, i);
  }
  lua_setglobal(L, "arg");
  if (luaL_dofile(L, "tools/runtests.lua") != 0) {
    puts(lua_tostring(L, -1));
  }
  lua_close(L);
  return EXIT_SUCCESS;
}
