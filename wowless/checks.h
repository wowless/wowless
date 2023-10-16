#include <lauxlib.h>
#include <lualib.h>

static void assertnumber(lua_State *L, int index) {
  if (!lua_isnumber(L, index)) {
    luaL_typerror(L, index, lua_typename(L, LUA_TNUMBER));
  }
}

static void assertnumberornil(lua_State *L, int index) {
  if (!lua_isnoneornil(L, index) && !lua_isnumber(L, index)) {
    luaL_typerror(L, index, lua_typename(L, LUA_TNUMBER));
  }
}

static void assertstring(lua_State *L, int index) {
  if (!lua_isstring(L, index)) {
    luaL_typerror(L, index, lua_typename(L, LUA_TSTRING));
  }
}

static void assertstringornil(lua_State *L, int index) {
  if (!lua_isnoneornil(L, index) && !lua_isstring(L, index)) {
    luaL_typerror(L, index, lua_typename(L, LUA_TSTRING));
  }
}

static void asserttype(lua_State *L, int index, enum lua_Type type) {
  luaL_checktype(L, index, type);
}

static void asserttypeornil(lua_State *L, int index, enum lua_Type type) {
  if (!lua_isnoneornil(L, index)) {
    luaL_checktype(L, index, type);
  }
}

static void assertpresent(lua_State *L, int index) {
  luaL_argcheck(L, !lua_isnoneornil(L, index), index, "value expected");
}

struct nsreg {
  const char *name;
  luaL_Reg *reg;
};

static int register_apis(lua_State *L) {
  luaL_checktype(L, 1, LUA_TTABLE);
  lua_settop(L, 1);
  luaL_Reg *global = lua_touserdata(L, lua_upvalueindex(1));
  struct nsreg *nsregs = lua_touserdata(L, lua_upvalueindex(2));
  luaL_register(L, NULL, global);
  for (struct nsreg *n = nsregs; n->reg; ++n) {
    lua_newtable(L);
    luaL_register(L, NULL, n->reg);
    lua_setfield(L, -2, n->name);
  }
  return 0;
}

static int setup_runtime(lua_State *L, luaL_Reg *global, struct nsreg *nsregs) {
  lua_pushlightuserdata(L, global);
  lua_pushlightuserdata(L, nsregs);
  lua_pushcclosure(L, register_apis, 2);
  return 1;
}
