#ifndef __LUA2C_H__
#define __LUA2C_H__

#include "lualib.h"
#include "tools/file2c.h"

struct cmodule {
  const char *name;
  lua_CFunction func;
};

struct preload {
  const struct preload **preloads;
  int npreloads;
  const struct module **modules;
  int nmodules;
  const struct cmodule *cmodules;
  int ncmodules;
};

#endif
