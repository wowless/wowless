#ifndef __LUAMAIN_H__
#define __LUAMAIN_H__

#include "tools/file2c.h"
#include "tools/lua2c.h"

struct luamain {
  const struct module *module;
  const struct preload **preloads;
  int npreloads;
};

extern const struct luamain luamain;

#endif
