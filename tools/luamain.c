#include "tools/luamain.h"

#include <stdio.h>
#include <stdlib.h>

#include "lauxlib.h"
#include "lualib.h"

static int errhandler(lua_State *L) {
  const char *msg = lua_tostring(L, 1);
  luaL_traceback(L, L, msg, 1);
  return 1;
}

int main(int argc, char **argv) {
  lua_State *L = luaL_newstate();
  if (L == NULL) {
    return EXIT_FAILURE;
  }
  luaL_openlibsx(L, LUALIB_STANDARD);
  luaL_openlibsx(L, LUALIB_ELUNE);
  lua_getglobal(L, "package");
  lua_getfield(L, -1, "preload");
  for (size_t i = 0; i < luamain.npreloads; ++i) {
    const struct preload *preload = luamain.preloads[i];
    for (size_t j = 0; j < preload->nmodules; ++j) {
      const struct module *m = preload->modules[j];
      luaL_loadbuffer(L, m->code, m->size, m->file);
      lua_setfield(L, -2, m->name);
    }
    for (size_t j = 0; j < preload->ncmodules; ++j) {
      const struct cmodule *m = &preload->cmodules[j];
      lua_pushcfunction(L, m->func);
      lua_setfield(L, -2, m->name);
    }
  }
  lua_pop(L, 2);
  lua_getglobal(L, "package");
  lua_getfield(L, -1, "loaders");
  lua_createtable(L, 1, 0);
  lua_rawgeti(L, -2, 1);
  lua_rawseti(L, -2, -1);
  lua_setfield(L, -1, "loaders");
  lua_pop(L, 2);
  lua_newtable(L);
  for (int i = 0; i < argc; ++i) {
    lua_pushstring(L, argv[i]);
    lua_rawseti(L, -2, i);
  }
  lua_setglobal(L, "arg");
  lua_pushcfunction(L, errhandler);
  const struct module *m = luamain.module;
  int ret = luaL_loadbuffer(L, m->code, m->size, m->file);
  if (ret || lua_pcall(L, 0, LUA_MULTRET, -2)) {
    fprintf(stderr, "%s\n", lua_tostring(L, -1));
    return EXIT_FAILURE;
  }
  lua_close(L);
  return EXIT_SUCCESS;
}
