#include "lauxlib.h"
#include "lua.h"
#include "luaconf.h"
#include "lualib.h"
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
      copy_prim_value(dst, src, lua_gettop(src));     /* copy value */
      if (lua_isnil(dst, -1)) {
        lua_pop(dst, 2); /* skip nil values */
      } else {
        lua_settable(dst, -3);
      }
    }
    lua_pop(src, 1); /* pop value, keep key for lua_next */
  }
}

static int errhandler(lua_State *L) {
  const char *msg = lua_tostring(L, 1);
  luaL_traceback(L, L, msg, 1);
  return 1;
}

static int wowless_ext_newstate(lua_State *L) {
  size_t chunklen;
  const char *chunk = luaL_checklstring(L, 1, &chunklen);
  lua_settop(L, 2); /* normalize: chunk at [1], config at [2] */
  lua_State *NL = luaL_newstate();
  if (!NL) {
    return luaL_error(L, "failed to create Lua state");
  }
  luaL_openlibsx(NL, LUALIB_STANDARD);
  luaL_openlibsx(NL, LUALIB_ELUNE);
  luamain_setup_preloads(NL);
  if (lua_istable(L, 2)) {
    copy_prim_table(NL, L, 2); /* [1] config */
  } else {
    lua_pushnil(NL); /* [1] nil */
  }
  if (luaL_loadbuffer(NL, chunk, chunklen, "=(wowless.ext.newstate)")) {
    lua_pushstring(L, lua_tostring(NL, -1));
    lua_close(NL);
    return lua_error(L);
  }
  lua_insert(NL, -2); /* [1] chunk, [2] config */
  lua_pushcfunction(NL, errhandler);
  lua_insert(NL, 1); /* [1] errhandler, [2] chunk, [3] config */
  if (lua_pcall(NL, 1, 1, 1) != 0) {
    lua_pushstring(L, lua_tostring(NL, -1));
    lua_close(NL);
    return lua_error(L);
  }
  copy_prim_value(L, NL, -1);
  lua_close(NL);
  return 1;
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
