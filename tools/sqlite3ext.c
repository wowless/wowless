#include "lauxlib.h"
#include "lualib.h"
#include "sqlite3.h"

static int tools_sqlite3ext_quote(lua_State *L) {
  const char *from = luaL_checkstring(L, 1);
  char *escaped = sqlite3_mprintf("%q", from);
  if (!escaped) {
    return luaL_error(L, "sqlite3_mprintf failed");
  }
  lua_pushstring(L, escaped);
  sqlite3_free(escaped);
  return 1;
}

static struct luaL_Reg extlib[] = {
    {"quote", tools_sqlite3ext_quote},
    {NULL,    NULL                  },
};

int luaopen_tools_sqlite3ext(lua_State *L) {
  lua_newtable(L);
  luaL_register(L, NULL, extlib);
  return 1;
}
