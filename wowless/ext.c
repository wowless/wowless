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

static int wowless_ext_newstate(lua_State *L) {
  size_t chunklen;
  const char *chunk = luaL_checklstring(L, 1, &chunklen);
  lua_State *L2 = luaL_newstate();
  if (!L2) {
    return luaL_error(L, "failed to create Lua state");
  }
  luaL_openlibsx(L2, LUALIB_STANDARD);
  luaL_openlibsx(L2, LUALIB_ELUNE);
  luamain_setup_preloads(L2);
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
  if (lua_pcall(L2, 1, 1, 0) != 0) {
    const char *err = lua_tostring(L2, -1);
    lua_close(L2);
    return luaL_error(L, "%s", err ? err : "(unknown error in newstate)");
  }
  copy_prim_value(L, L2, -1);
  lua_close(L2);
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
