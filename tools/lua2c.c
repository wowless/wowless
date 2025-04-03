#include "tools/lua2c.h"

#include "lauxlib.h"

void preload(lua_State *L, const struct preload *preload) {
  lua_getglobal(L, "package");
  lua_getfield(L, -1, "preload");
  for (size_t i = 0; i < preload->nmodules; ++i) {
    const struct module *m = preload->modules[i];
    luaL_loadbuffer(L, m->code, m->size, m->file);
    lua_setfield(L, -2, m->name);
  }
  for (size_t i = 0; i < preload->ncmodules; ++i) {
    const struct cmodule *m = &preload->cmodules[i];
    lua_pushcfunction(L, m->func);
    lua_setfield(L, -2, m->name);
  }
  lua_pop(L, 2);
}
