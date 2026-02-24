#include "wowless/luaobject.h"

#include "lauxlib.h"
#include "lua.h"

#define LUAOBJECT_KEY_PREFIX "wowless.luaobject."
#define LUAOBJECT_OBJS_KEY "wowless.luaobject.objs"

/* luaobject.register(typename, metatable)
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

/* luaobject.register_objs(objs)
 * Stores the module-private objs weak table in the registry so C can reach it.
 */
static int luaobject_register_objs(lua_State *L) {
  luaL_checktype(L, 1, LUA_TTABLE);
  lua_pushliteral(L, LUAOBJECT_OBJS_KEY);
  lua_pushvalue(L, 1);
  lua_rawset(L, LUA_REGISTRYINDEX);
  return 0;
}

/* luaobject.new(typename)
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

/* luaobject_make_internal(L, name, namelen)
 * Creates a userdata, builds the backing { type, table, luarep } table,
 * registers it in objs, and leaves ud, backing on the stack.
 */
static void luaobject_make_internal(lua_State *L, const char *name,
                                    size_t namelen) {
  /* look up metatable from registry */
  lua_pushliteral(L, LUAOBJECT_KEY_PREFIX);
  lua_pushlstring(L, name, namelen);
  lua_concat(L, 2);
  lua_rawget(L, LUA_REGISTRYINDEX); /* mt */
  if (!lua_istable(L, -1)) {
    luaL_error(L, "unknown luaobject type: %.*s", (int)namelen, name);
  }

  /* create userdata and attach metatable; stack: mt, ud */
  lua_newuserdata(L, 0);
  lua_pushvalue(L, -2);
  lua_setmetatable(L, -2);
  lua_remove(L, -2); /* stack: ud */

  /* create backing table { type=name, table={}, luarep=ud } */
  lua_createtable(L, 0, 3); /* stack: ud, backing */
  lua_pushlstring(L, name, namelen);
  lua_setfield(L, -2, "type");
  lua_createtable(L, 0, 0);
  lua_setfield(L, -2, "table");
  lua_pushvalue(L, -2);          /* ud */
  lua_setfield(L, -2, "luarep"); /* stack: ud, backing */

  /* objs[ud] = backing */
  lua_pushliteral(L, LUAOBJECT_OBJS_KEY);
  lua_rawget(L, LUA_REGISTRYINDEX); /* stack: ud, backing, objs */
  lua_pushvalue(L, -3);             /* ud */
  lua_pushvalue(L, -3);             /* backing */
  lua_rawset(L, -3);                /* objs[ud] = backing */
  lua_pop(L, 1);                    /* pop objs; stack: ud, backing */
}

/* wowless_luaobject_make(L, name, namelen)
 * Creates a luaobject and leaves the userdata on the stack (for C stubs).
 */
void wowless_luaobject_make(lua_State *L, const char *name, size_t namelen) {
  luaobject_make_internal(L, name, namelen);
  lua_pop(L, 1); /* pop backing; stack: ud */
}

/* luaobject.make(typename)
 * Creates a luaobject and returns the backing table (for Lua callers).
 */
static int luaobject_make(lua_State *L) {
  size_t namelen;
  const char *name = luaL_checklstring(L, 1, &namelen);
  luaobject_make_internal(L, name, namelen);
  lua_remove(L, -2); /* remove ud; stack: backing */
  return 1;
}

static const struct luaL_Reg luaobjectlib[] = {
    {"make",          luaobject_make         },
    {"new",           luaobject_new          },
    {"register",      luaobject_register     },
    {"register_objs", luaobject_register_objs},
    {NULL,            NULL                   },
};

int luaopen_wowless_luaobject(lua_State *L) {
  lua_newtable(L);
  luaL_register(L, NULL, luaobjectlib);
  return 1;
}
