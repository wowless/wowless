#include "CascLib.h"

#include "lauxlib.h"
#include "lua.h"

static const char *storage_str = "wowless.casclib.storage";

static int storage_gc(lua_State *L) {
  HANDLE *ph = luaL_checkudata(L, 1, storage_str);
  CascCloseStorage(*ph);
  return 0;
}

static int casc_open_storage(lua_State *L) {
  const char *path = luaL_checkstring(L, 1);
  HANDLE *h = lua_newuserdata(L, sizeof(HANDLE));
  luaL_getmetatable(L, storage_str);
  lua_setmetatable(L, -2);
  if (!CascOpenStorage(path, CASC_LOCALE_ENUS, h)) {
    luaL_error(L, "casc error %d", GetCascError());
  }
  return 1;
}

int luaopen_tools_casclib(lua_State *L) {
  if (luaL_newmetatable(L, storage_str)) {
    lua_pushcfunction(L, storage_gc);
    lua_setfield(L, -2, "__gc");
    lua_newtable(L);
    lua_setfield(L, -2, "__index");
    lua_pushstring(L, storage_str);
    lua_setfield(L, -2, "__metatable");
  }
  lua_pop(L, 1);
  lua_pushcfunction(L, casc_open_storage);
  return 1;
}
