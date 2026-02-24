#include "lauxlib.h"
#include "lua.h"

#define UIOBJECT_ISA_PREFIX "wowless.uiobject.isa."
#define UIOBJECT_PROXIES_KEY "wowless.uiobject.proxies"

/*
 * uiobject.register(typename, isa_table)
 * Stores the isa_table in the registry under "wowless.uiobject.isa.<typename>".
 */
static int uiobject_register(lua_State *L) {
  luaL_checkstring(L, 1);
  luaL_checktype(L, 2, LUA_TTABLE);
  lua_pushstring(L, UIOBJECT_ISA_PREFIX);
  lua_pushvalue(L, 1);
  lua_concat(L, 2);
  lua_pushvalue(L, 2);
  lua_rawset(L, LUA_REGISTRYINDEX);
  return 0;
}

/*
 * uiobject.new(typename)
 * Creates a new uiobject proxy userdata (no metatable) and registers
 * it in the weak proxy table with the type's isa table.
 */
static int uiobject_new(lua_State *L) {
  luaL_checkstring(L, 1);
  lua_pushstring(L, UIOBJECT_ISA_PREFIX);
  lua_pushvalue(L, 1);
  lua_concat(L, 2);
  lua_rawget(L, LUA_REGISTRYINDEX);
  if (!lua_istable(L, -1)) {
    return luaL_error(L, "unknown uiobject type: %s", lua_tostring(L, 1));
  }
  lua_newuserdata(L, 0);
  lua_pushliteral(L, UIOBJECT_PROXIES_KEY);
  lua_rawget(L, LUA_REGISTRYINDEX);
  lua_pushvalue(L, -2);
  lua_pushvalue(L, -4);
  lua_rawset(L, -3);
  lua_pop(L, 1);
  lua_remove(L, -2);
  return 1;
}

static const struct luaL_Reg uiobjectlib[] = {
    {"new",      uiobject_new     },
    {"register", uiobject_register},
    {NULL,       NULL             },
};

int luaopen_wowless_uiobject(lua_State *L) {
  lua_pushliteral(L, UIOBJECT_PROXIES_KEY);
  lua_newtable(L);
  lua_newtable(L);
  lua_pushliteral(L, "k");
  lua_setfield(L, -2, "__mode");
  lua_setmetatable(L, -2);
  lua_rawset(L, LUA_REGISTRYINDEX);
  lua_newtable(L);
  luaL_register(L, NULL, uiobjectlib);
  return 1;
}
