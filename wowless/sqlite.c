#include "lauxlib.h"
#include "lua.h"
#include "sqlite3.h"

static sqlite3 *checkdb(lua_State *L, int idx) {
  sqlite3 **db = luaL_checkudata(L, idx, "wowless.sqlite.db");
  return *db;
}

static sqlite3_stmt *checkstmt(lua_State *L, int idx) {
  sqlite3_stmt **stmt = luaL_checkudata(L, idx, "wowless.sqlite.stmt");
  return *stmt;
}

static int dbclose(lua_State *L) {
  sqlite3 **db = luaL_checkudata(L, 1, "wowless.sqlite.db");
  if (sqlite3_close_v2(*db) != SQLITE_OK) {
    return luaL_error(L, "sqlite error on close: %s", sqlite3_errmsg(*db));
  }
  *db = 0;
  return 0;
}

static int dberrmsg(lua_State *L) {
  sqlite3 *db = checkdb(L, 1);
  lua_pushstring(L, sqlite3_errmsg(db));
  return 1;
}

static int dbexec(lua_State *L) {
  sqlite3 *db = checkdb(L, 1);
  const char *sql = luaL_checkstring(L, 2);
  lua_pushnumber(L, sqlite3_exec(db, sql, 0, 0, 0));
  return 1;
}

static int dbgc(lua_State *L) {
  sqlite3 *db = checkdb(L, 1);
  sqlite3_close_v2(db);
  return 0;
}

static int dbprepare(lua_State *L) {
  sqlite3 *db = checkdb(L, 1);
  size_t sz;
  const char *sql = luaL_checklstring(L, 2, &sz);
  sqlite3_stmt **stmt = lua_newuserdata(L, sizeof(*stmt));
  luaL_getmetatable(L, "wowless.sqlite.stmt");
  lua_setmetatable(L, -2);
  return sqlite3_prepare_v2(db, sql, sz + 1, stmt, 0) == SQLITE_OK ? 1 : 0;
}

static int doopen(lua_State *L, const char *filename) {
  sqlite3 **db = lua_newuserdata(L, sizeof(*db));
  luaL_getmetatable(L, "wowless.sqlite.db");
  lua_setmetatable(L, -2);
  if (sqlite3_open(filename, db) != SQLITE_OK) {
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

static int sqliteopen(lua_State *L) {
  const char *filename = luaL_checkstring(L, 1);
  return doopen(L, filename);
}

static int sqliteopenmemory(lua_State *L) {
  return doopen(L, ":memory:");
}

static int stmtgc(lua_State *L) {
  sqlite3_stmt *stmt = checkstmt(L, 1);
  sqlite3_finalize(stmt);
  return 0;
}

static int stmtreset(lua_State *L) {
  sqlite3_stmt *stmt = checkstmt(L, 1);
  int code = sqlite3_reset(stmt);
  if (code != SQLITE_OK) {
    return luaL_error(L, "sqlite error on reset: %s", sqlite3_errstr(code));
  }
  return 0;
}

int luaopen_lsqlite3(lua_State *L) {
  if (luaL_newmetatable(L, "wowless.sqlite.db")) {
    lua_newtable(L);
    lua_pushcfunction(L, dbclose);
    lua_setfield(L, -2, "close");
    lua_pushcfunction(L, dberrmsg);
    lua_setfield(L, -2, "errmsg");
    lua_pushcfunction(L, dbexec);
    lua_setfield(L, -2, "exec");
    lua_pushcfunction(L, dbprepare);
    lua_setfield(L, -2, "prepare");
    lua_setfield(L, -2, "__index");
    lua_pushcfunction(L, dbgc);
    lua_setfield(L, -2, "__gc");
  }
  lua_pop(L, 1);
  if (luaL_newmetatable(L, "wowless.sqlite.stmt")) {
    lua_newtable(L);
    lua_pushcfunction(L, stmtreset);
    lua_setfield(L, -2, "reset");
    lua_setfield(L, -2, "__index");
    lua_pushcfunction(L, stmtgc);
    lua_setfield(L, -2, "__gc");
  }
  lua_pop(L, 1);
  lua_newtable(L);
  lua_pushcfunction(L, sqliteopen);
  lua_setfield(L, -2, "open");
  lua_pushcfunction(L, sqliteopenmemory);
  lua_setfield(L, -2, "open_memory");
  lua_pushnumber(L, 0);
  lua_setfield(L, -2, "OK");
  return 1;
}
