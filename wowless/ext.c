#include "lauxlib.h"
#include "lua.h"
#include "luaconf.h"
#include "lualib.h"
#include "tools/lua2c.h"
#include "tools/luamain.h"

#ifndef ELUNE_VERSION
#error Must be compiled against Elune headers.
#endif

static int wowless_ext_getglobaltable(lua_State *L) {
  lua_settop(L, 0);
  lua_pushvalue(L, LUA_GLOBALSINDEX);
  return 1;
}

static int wowless_ext_setglobaltable(lua_State *L) {
  luaL_checktype(L, 1, LUA_TTABLE);
  lua_settop(L, 1);
  lua_pushvalue(L, LUA_GLOBALSINDEX);
  lua_insert(L, 1);
  lua_replace(L, LUA_GLOBALSINDEX);
  return 1;
}

static void copy_prim_table(lua_State *dst, lua_State *src, int srcidx);

static void copy_prim_value(lua_State *dst, lua_State *src, int srcidx) {
  switch (lua_type(src, srcidx)) {
    case LUA_TBOOLEAN:
      lua_pushboolean(dst, lua_toboolean(src, srcidx));
      break;
    case LUA_TNUMBER:
      lua_pushnumber(dst, lua_tonumber(src, srcidx));
      break;
    case LUA_TSTRING:
      lua_pushstring(dst, lua_tostring(src, srcidx));
      break;
    case LUA_TTABLE:
      copy_prim_table(dst, src, srcidx);
      break;
    default:
      lua_pushnil(dst);
      break;
  }
}

static void copy_prim_table(lua_State *dst, lua_State *src, int srcidx) {
  if (srcidx < 0) {
    srcidx = lua_gettop(src) + 1 + srcidx;
  }
  lua_newtable(dst);
  lua_pushnil(src);
  while (lua_next(src, srcidx)) {
    int keytype = lua_type(src, -2);
    if (keytype == LUA_TSTRING || keytype == LUA_TNUMBER) {
      copy_prim_value(dst, src, lua_gettop(src) - 1); /* copy key */
      copy_prim_value(dst, src, lua_gettop(src)); /* copy value (original -1) */
      if (lua_isnil(dst, -1)) {
        lua_pop(dst, 2); /* skip nil values */
      } else {
        lua_settable(dst, -3);
      }
    }
    lua_pop(src, 1); /* pop value, keep key for lua_next */
  }
}

static void setup_preloads(lua_State *L) {
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
  /* Restrict package.loaders to only the preload loader. */
  lua_getglobal(L, "package");    /* package */
  lua_getfield(L, -1, "loaders"); /* package, loaders */
  lua_rawgeti(L, -1, 1);          /* package, loaders, loaders[1] */
  lua_remove(L, -2);              /* package, loaders[1] */
  lua_newtable(L);                /* package, loaders[1], new_loaders */
  lua_insert(L, -2);              /* package, new_loaders, loaders[1] */
  lua_rawseti(L, -2, 1); /* package, new_loaders (new_loaders[1]=loaders[1]) */
  lua_setfield(L, -2, "loaders"); /* package (package.loaders=new_loaders) */
  lua_pop(L, 1);
}

static int wowless_ext_newstate(lua_State *L) {
  size_t chunklen;
  const char *chunk = luaL_checklstring(L, 1, &chunklen);
  lua_State *L2 = luaL_newstate();
  if (!L2) {
    return luaL_error(L, "failed to create Lua state");
  }
  luaL_openlibsx(L2, LUALIB_STANDARD);
  luaL_openlibsx(L2, LUALIB_ELUNE);
  setup_preloads(L2);
  if (lua_istable(L, 2)) {
    copy_prim_table(L2, L, 2);
  } else {
    lua_pushnil(L2);
  }
  if (luaL_loadbuffer(L2, chunk, chunklen, "=(wowless.ext.newstate)") != 0) {
    const char *err = lua_tostring(L2, -1);
    lua_close(L2);
    return luaL_error(L, "newstate load error: %s", err ? err : "(unknown)");
  }
  lua_insert(L2, -2); /* move chunk before arg */
  if (lua_pcall(L2, 1, 0, 0) != 0) {
    const char *err = lua_tostring(L2, -1);
    lua_close(L2);
    return luaL_error(L, "%s", err ? err : "(unknown error in newstate)");
  }
  lua_close(L2);
  return 0;
}

static struct luaL_Reg extlib[] = {
    {"getglobaltable", wowless_ext_getglobaltable},
    {"newstate",       wowless_ext_newstate      },
    {"setglobaltable", wowless_ext_setglobaltable},
    {NULL,             NULL                      }
};

int luaopen_wowless_ext(lua_State *L) {
  lua_newtable(L);
  luaL_register(L, NULL, extlib);
  return 1;
}
