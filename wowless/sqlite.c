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

static int dburows(lua_State *L) {
  lua_settop(L, 2);
  lua_pushcfunction(L, dbprepare);
  lua_insert(L, 1);
  lua_call(L, 2, 1);
  lua_pushvalue(L, lua_upvalueindex(1));
  lua_insert(L, 1);
  return 2;
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

static int sqliteopenmemory(lua_State *L) { return doopen(L, ":memory:"); }

static int stmtbindvalues(lua_State *L) {
  sqlite3_stmt *stmt = checkstmt(L, 1);
  int n = lua_gettop(L);
  for (int i = 2; i <= n; ++i) {
    int ty = lua_type(L, i);
    int code;
    switch (ty) {
      case LUA_TBOOLEAN:
        code = sqlite3_bind_int(stmt, i - 1, lua_toboolean(L, i));
        break;
      case LUA_TNUMBER:
        code = sqlite3_bind_double(stmt, i - 1, lua_tonumber(L, i));
        break;
      case LUA_TSTRING: {
        size_t sz;
        const char *text = lua_tolstring(L, i, &sz);
        code = sqlite3_bind_text(stmt, i - 1, text, sz, SQLITE_TRANSIENT);
        break;
      }
      default:
        return luaL_error(L, "unexpected value type %s", lua_typename(L, ty));
    }
    if (code != SQLITE_OK) {
      return luaL_error(L, "sqlite error in bind: %s", sqlite3_errstr(code));
    }
  }
  return 0;
}

static int stmtgc(lua_State *L) {
  sqlite3_stmt *stmt = checkstmt(L, 1);
  sqlite3_finalize(stmt);
  return 0;
}

static int stmtgeniter(lua_State *L) {
  checkstmt(L, 1);
  lua_settop(L, 1);
  lua_pushvalue(L, lua_upvalueindex(1));
  lua_insert(L, 1);
  return 2;
}

static int stmtreset(lua_State *L) {
  sqlite3_stmt *stmt = checkstmt(L, 1);
  int code = sqlite3_reset(stmt);
  if (code != SQLITE_OK) {
    return luaL_error(L, "sqlite error on reset: %s", sqlite3_errstr(code));
  }
  return 0;
}

static void pushcolval(lua_State *L, sqlite3_stmt *stmt, int col) {
  int ty = sqlite3_column_type(stmt, col);
  switch (ty) {
    case SQLITE_FLOAT:
    case SQLITE_INTEGER:
      lua_pushnumber(L, sqlite3_column_double(stmt, col));
      break;
    case SQLITE_TEXT: {
      const char *text = (const char *)sqlite3_column_text(stmt, col);
      int len = sqlite3_column_bytes(stmt, col);
      lua_pushlstring(L, text, len);
      break;
    }
    default:
      luaL_error(L, "unexpected sqlite type %d", ty);
  }
}

static int stepaux(lua_State *L, sqlite3_stmt *stmt) {
  int code = sqlite3_step(stmt);
  if (code == SQLITE_DONE) {
    return 0;
  } else if (code != SQLITE_ROW) {
    return luaL_error(L, "sqlite error on step: %s", sqlite3_errstr(code));
  }
  return sqlite3_column_count(stmt);
}

static int stmtrowsaux(lua_State *L) {
  sqlite3_stmt *stmt = checkstmt(L, 1);
  int cols = stepaux(L, stmt);
  if (cols == 0) {
    return 0;
  } else {
    lua_createtable(L, cols, 0);
    for (int i = 0; i < cols; ++i) {
      pushcolval(L, stmt, i);
      lua_rawseti(L, -2, i + 1);
    }
    return 1;
  }
}

static int stmturowsaux(lua_State *L) {
  sqlite3_stmt *stmt = checkstmt(L, 1);
  int cols = stepaux(L, stmt);
  lua_settop(L, 0);
  luaL_checkstack(L, cols, "sqlite: too many columns for stack");
  for (int i = 0; i < cols; ++i) {
    pushcolval(L, stmt, i);
  }
  return cols;
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
    lua_pushcfunction(L, stmturowsaux);
    lua_pushcclosure(L, dburows, 1);
    lua_setfield(L, -2, "urows");
    lua_setfield(L, -2, "__index");
    lua_pushcfunction(L, dbgc);
    lua_setfield(L, -2, "__gc");
  }
  lua_pop(L, 1);
  if (luaL_newmetatable(L, "wowless.sqlite.stmt")) {
    lua_newtable(L);
    lua_pushcfunction(L, stmtbindvalues);
    lua_setfield(L, -2, "bind_values");
    lua_pushcfunction(L, stmtreset);
    lua_setfield(L, -2, "reset");
    lua_pushcfunction(L, stmtrowsaux);
    lua_pushcclosure(L, stmtgeniter, 1);
    lua_setfield(L, -2, "rows");
    lua_pushcfunction(L, stmturowsaux);
    lua_pushcclosure(L, stmtgeniter, 1);
    lua_setfield(L, -2, "urows");
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
