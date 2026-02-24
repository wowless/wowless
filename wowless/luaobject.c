#include "lauxlib.h"
#include "lua.h"

#define LUAOBJECT_KEY_PREFIX "wowless.luaobject."

/*
 * luaobject.register(typename, metatable)
 * Registers a luaobject type by storing the metatable in the registry
 * under "wowless.luaobject.<typename>".
 */
static int luaobject_register(lua_State *L) {
  luaL_checkstring(L, 1);
  luaL_checktype(L, 2, LUA_TTABLE);
  lua_pushstring(L, LUAOBJECT_KEY_PREFIX);
  lua_pushvalue(L, 1);
  lua_concat(L, 2);
  lua_pushvalue(L, 2);
  lua_rawset(L, LUA_REGISTRYINDEX);
  return 0;
}

/*
 * luaobject.new(typename)
 * Creates a new luaobject userdata of the registered type.
 */
static int luaobject_new(lua_State *L) {
  luaL_checkstring(L, 1);
  lua_pushstring(L, LUAOBJECT_KEY_PREFIX);
  lua_pushvalue(L, 1);
  lua_concat(L, 2);
  lua_rawget(L, LUA_REGISTRYINDEX);
  if (!lua_istable(L, -1)) {
    return luaL_error(L, "unknown luaobject type: %s", lua_tostring(L, 1));
  }
  lua_newuserdata(L, 0);
  lua_insert(L, -2);
  lua_setmetatable(L, -2);
  return 1;
}

static const struct luaL_Reg luaobjectlib[] = {
    {"new",      luaobject_new     },
    {"register", luaobject_register},
    {NULL,       NULL              },
};

int luaopen_wowless_luaobject(lua_State *L) {
  lua_newtable(L);
  luaL_register(L, NULL, luaobjectlib);
  return 1;
}
