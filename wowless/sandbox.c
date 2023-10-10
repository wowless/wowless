#include <lauxlib.h>
#include <lualib.h>

typedef struct {
  lua_State *L;
} sandbox;

static const char sandbox_metatable[] = "wowless sandbox";

static int sandbox_create(lua_State *L) {
  lua_State *SL = luaL_newstate();
  if (!SL) {
    return luaL_error(L, "out of memory");
  }
  sandbox *S = lua_newuserdata(L, sizeof(*S));
  S->L = SL;
  luaL_getmetatable(L, sandbox_metatable);
  lua_setmetatable(L, -2);
  return 1;
}

static sandbox *sandbox_check(lua_State *L, int index) {
  return luaL_checkudata(L, index, sandbox_metatable);
}

static int sandbox_gc(lua_State *L) {
  sandbox *S = sandbox_check(L, 1);
  lua_close(S->L);
  return 0;
}

static int sandbox_dump(lua_State *L) {
  sandbox *S = sandbox_check(L, 1);
  lua_State *SL = S->L;
  lua_pushnil(SL);
  while (lua_next(SL, LUA_GLOBALSINDEX) != 0) {
    puts(lua_tostring(SL, -2));
    lua_pop(SL, 1);
  }
  return 0;
}

static void sandbox_import_recursive(lua_State *L, lua_State *SL) {
  lua_pushnil(L);
  while (lua_next(L, -2) != 0) {
    if (!lua_type(L, -2) == LUA_TSTRING) {
      lua_settop(SL, 0);
      luaL_error(L, "invalid key");
    }
    lua_pushstring(SL, lua_tostring(L, -2));
    switch (lua_type(L, -1)) {
      case LUA_TNUMBER:
        lua_pushnumber(SL, lua_tonumber(L, -1));
        break;
      case LUA_TSTRING:
        lua_pushstring(SL, lua_tostring(L, -1));
        break;
      case LUA_TTABLE:
        lua_newtable(SL);
        sandbox_import_recursive(L, SL);
        break;
      default:
        lua_settop(SL, 0);
        luaL_error(L, "invald value");
    }
    lua_settable(SL, -3);
    lua_pop(L, 1);
  }
}

static int sandbox_import(lua_State *L) {
  sandbox *S = sandbox_check(L, 1);
  luaL_checktype(L, 2, LUA_TTABLE);
  lua_settop(L, 2);
  lua_pushvalue(S->L, LUA_GLOBALSINDEX);
  sandbox_import_recursive(L, S->L);
  lua_pop(S->L, 1);
  return 0;
}

static struct luaL_Reg sandboxlib[] = {
    {"dump",   sandbox_dump  },
    {"import", sandbox_import},
    {NULL,     NULL          }
};

static struct luaL_Reg modulelib[] = {
    {"create", sandbox_create},
    {NULL,     NULL          }
};

int luaopen_wowless_sandbox(lua_State *L) {
  if (luaL_newmetatable(L, sandbox_metatable)) {
    lua_pushstring(L, "__index");
    lua_newtable(L);
    luaL_register(L, NULL, sandboxlib);
    lua_settable(L, -3);
    lua_pushstring(L, "__gc");
    lua_pushcfunction(L, sandbox_gc);
    lua_settable(L, -3);
    lua_pushstring(L, "__metatable");
    lua_pushstring(L, sandbox_metatable);
    lua_settable(L, -3);
  }
  lua_pop(L, 1);
  lua_newtable(L);
  luaL_register(L, NULL, modulelib);
  return 1;
}
