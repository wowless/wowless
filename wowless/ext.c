#include "lauxlib.h"
#include "lua.h"
#include "luaconf.h"
#include "lualib.h"
#include "tools/luamain.h"
#include "wowless/primtable.h"

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

static int errhandler(lua_State *L) {
  const char *msg = lua_tostring(L, 1);
  luaL_traceback(L, L, msg, 1);
  return 1;
}

struct newstate_args {
  const char *chunk;
  size_t chunklen;
  lua_State *outer;
};

static int ext_newstate_body(lua_State *L) {
  struct newstate_args *a = lua_touserdata(L, lua_upvalueindex(1));
  if (lua_istable(a->outer, 2)) {
    int err = wowless_copy_prim_table(L, a->outer, 2);
    if (err) {
      return luaL_error(L, "primtable: unsupported type '%s'",
                        lua_typename(L, err));
    }
  } else {
    lua_pushnil(L);
  }
  if (luaL_loadbuffer(L, a->chunk, a->chunklen, "=(wowless.ext.newstate)")) {
    return lua_error(L);
  }
  lua_insert(L, -2); /* chunk before config */
  lua_call(L, 1, 1);
  return 1;
}

static int wowless_ext_newstate(lua_State *L) {
  size_t chunklen;
  const char *chunk = luaL_checklstring(L, 1, &chunklen);
  lua_settop(L, 2);
  lua_State *NL = luaL_newstate();
  if (!NL) {
    return luaL_error(L, "failed to create Lua state");
  }
  luaL_openlibsx(NL, LUALIB_STANDARD);
  luaL_openlibsx(NL, LUALIB_ELUNE);
  luamain_setup_preloads(NL);
  struct newstate_args args = {chunk, chunklen, L};
  lua_pushcfunction(NL, errhandler); /* [1] */
  lua_pushlightuserdata(NL, &args);
  lua_pushcclosure(NL, ext_newstate_body, 1); /* [2] */
  if (lua_pcall(NL, 0, 1, 1) != 0) {
    lua_pushstring(L, lua_tostring(NL, -1));
    lua_close(NL);
    return lua_error(L);
  }
  int err = wowless_copy_prim_value(L, NL, -1);
  int type_id = err;
  lua_close(NL);
  if (type_id) {
    return luaL_error(L, "primtable: unsupported type '%s'",
                      lua_typename(L, type_id));
  }
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
