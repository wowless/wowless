#include "lua.h"
#include "lauxlib.h"
#include "sqlite3.h"

static sqlite3 *checkdb(lua_State *L, int idx) {
  sqlite3 **db = luaL_checkudata(L, idx, "wowless.sqlite.db");
  return *db;
}

static int errmsg(lua_State *L) {
  sqlite3 *db = checkdb(L, 1);
  lua_pushstring(L, sqlite3_errmsg(db));
  return 1;
}

static int exec(lua_State *L) {
  sqlite3 *db = checkdb(L, 1);
  const char *sql = luaL_checkstring(L, 2);
  lua_pushnumber(L, sqlite3_exec(db, sql, 0, 0, 0));
  return 1;
}

static int prepare(lua_State *L) {
  sqlite3 *db = checkdb(L, 1);
  size_t sz;
  const char *sql = luaL_checklstring(L, 2, &sz);
  sqlite3_stmt **stmt = lua_newuserdata(L, sizeof(*stmt));
  luaL_getmetatable(L, "wowless.sqlite.stmt");
  lua_setmetatable(L, -2);
  return sqlite3_prepare_v2(db, sql, sz + 1, stmt, 0) == SQLITE_OK ? 1 : 0;
}

static int db_gc(lua_State *L) {
  sqlite3 *db = checkdb(L, 1);
  if (sqlite3_close_v2(db) != SQLITE_OK) {
    return luaL_error(L, "sqlite error on close: %s", sqlite3_errmsg(db));
  }
  return 0;
}

static int open_memory(lua_State *L) {
  lua_settop(L, 0);
  sqlite3 **db = lua_newuserdata(L, sizeof(*db));
  luaL_getmetatable(L, "wowless.sqlite.db");
  lua_setmetatable(L, -2);
  if (sqlite3_open(":memory:", db) != SQLITE_OK) {
    if (!*db) {
      return luaL_error(L, "sqlite: out of memory");
    } else {
      int errcode = sqlite3_errcode(*db);
      sqlite3_close(*db);
      return luaL_error(L, "sqlite error on open: %s", sqlite3_errstr(errcode));
    }
  }
  return 1;
}

int luaopen_wowless_sqlite(lua_State *L) {
  if (luaL_newmetatable(L, "wowless.sqlite.db")) {
    lua_newtable(L);
    lua_pushcfunction(L, errmsg);
    lua_setfield(L, -2, "errmsg");
    lua_pushcfunction(L, exec);
    lua_setfield(L, -2, "exec");
    lua_pushcfunction(L, prepare);
    lua_setfield(L, -2, "prepare");
    lua_setfield(L, -2, "__index");
    lua_pushcfunction(L, db_gc);
    lua_setfield(L, -2, "__gc");
  }
  lua_pop(L, 1);
  lua_newtable(L);
  lua_pushcfunction(L, open_memory);
  lua_setfield(L, -2, "open_memory");
  return 1;
}
