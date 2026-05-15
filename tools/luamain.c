#include "tools/luamain.h"

#include <stdio.h>
#include <stdlib.h>

#include "lauxlib.h"
#include "lualib.h"

void luamain_setup_preloads(lua_State *L) {
  lua_newtable(L); /* [1] work stack of preload* to process */
  for (size_t i = 1; i <= luamain.npreloads; ++i) {
    const struct preload *p = luamain.preloads[luamain.npreloads - i];
    lua_pushlightuserdata(L, (void *)p);
    lua_rawseti(L, 1, (int)i);
  }
  lua_newtable(L);               /* [2] seen set */
  lua_getglobal(L, "package");   /* [3] */
  lua_getfield(L, 3, "preload"); /* [4] package.preload */
  for (size_t nstack = luamain.npreloads; nstack > 0;) {
    lua_rawgeti(L, 1, (int)nstack--);
    const struct preload *p = lua_touserdata(L, -1);
    lua_gettable(L, 2);
    if (!lua_toboolean(L, -1)) {
      lua_pushlightuserdata(L, (void *)p);
      lua_pushboolean(L, 1);
      lua_settable(L, 2);
      for (size_t j = 0; j < p->npreloads; ++j) {
        lua_pushlightuserdata(L, (void *)p->preloads[j]);
        lua_rawseti(L, 1, (int)++nstack);
      }
      for (size_t j = 0; j < p->nmodules; ++j) {
        const struct module *m = p->modules[j];
        luaL_loadbuffer(L, m->code, m->size, m->file);
        lua_setfield(L, 4, m->name);
      }
      for (size_t j = 0; j < p->ncmodules; ++j) {
        const struct cmodule *m = &p->cmodules[j];
        lua_pushcfunction(L, m->func);
        lua_setfield(L, 4, m->name);
      }
    }
    lua_settop(L, 4);
  }
  lua_settop(L, 0);
  lua_getglobal(L, "package");    /* package */
  lua_getfield(L, -1, "loaders"); /* package, loaders */
  lua_rawgeti(L, -1, 1);          /* package, loaders, loaders[1] */
  lua_remove(L, -2);              /* package, loaders[1] */
  lua_newtable(L);                /* package, loaders[1], new_loaders */
  lua_insert(L, -2);              /* package, new_loaders, loaders[1] */
  lua_rawseti(L, -2, 1);          /* package, new_loaders */
  lua_setfield(L, -2, "loaders"); /* package */
  lua_pop(L, 1);
}

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
  luamain_setup_preloads(L);
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
