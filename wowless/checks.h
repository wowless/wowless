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
  if (lua_type(L, index) != type) {
    luaL_typerror(L, index, lua_typename(L, type));
  }
}

static void asserttypeornil(lua_State *L, int index, enum lua_Type type) {
  if (!lua_isnoneornil(L, index) && lua_type(L, index) != type) {
    luaL_typerror(L, index, lua_typename(L, type));
  }
}

static void assertpresent(lua_State *L, int index) {
  luaL_argcheck(L, !lua_isnoneornil(L, index), index, "value expected");
}
