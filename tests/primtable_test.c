#include "wowless/primtable.h"

#include <stdio.h>
#include <string.h>

#include "lauxlib.h"
#include "lua.h"

static int nfail;

#define CHECK(cond)                                                   \
  do {                                                                \
    if (!(cond)) {                                                    \
      fprintf(stderr, "FAIL %s:%d: %s\n", __FILE__, __LINE__, #cond); \
      nfail++;                                                        \
    }                                                                 \
  } while (0)

static lua_State *mkstate(void) {
  lua_State *L = luaL_newstate();
  if (!L) {
    fputs("luaL_newstate failed\n", stderr);
    return NULL;
  }
  return L;
}

static int dummy(lua_State *L) {
  (void)L;
  return 0;
}

static void test_nil(void) {
  lua_State *src = mkstate(), *dst = mkstate();
  lua_pushnil(src);
  CHECK(wowless_copy_prim_value(dst, src, -1) == 0);
  CHECK(lua_isnil(dst, -1));
  lua_close(src);
  lua_close(dst);
}

static void test_bool_false(void) {
  lua_State *src = mkstate(), *dst = mkstate();
  lua_pushboolean(src, 0);
  CHECK(wowless_copy_prim_value(dst, src, -1) == 0);
  CHECK(lua_isboolean(dst, -1) && !lua_toboolean(dst, -1));
  lua_close(src);
  lua_close(dst);
}

static void test_bool_true(void) {
  lua_State *src = mkstate(), *dst = mkstate();
  lua_pushboolean(src, 1);
  CHECK(wowless_copy_prim_value(dst, src, -1) == 0);
  CHECK(lua_isboolean(dst, -1) && lua_toboolean(dst, -1));
  lua_close(src);
  lua_close(dst);
}

static void test_number(void) {
  lua_State *src = mkstate(), *dst = mkstate();
  lua_pushnumber(src, 42.5);
  CHECK(wowless_copy_prim_value(dst, src, -1) == 0);
  CHECK(lua_isnumber(dst, -1) && lua_tonumber(dst, -1) == 42.5);
  lua_close(src);
  lua_close(dst);
}

static void test_string(void) {
  lua_State *src = mkstate(), *dst = mkstate();
  lua_pushstring(src, "hello");
  CHECK(wowless_copy_prim_value(dst, src, -1) == 0);
  CHECK(lua_isstring(dst, -1) && strcmp(lua_tostring(dst, -1), "hello") == 0);
  lua_close(src);
  lua_close(dst);
}

static void test_table(void) {
  lua_State *src = mkstate(), *dst = mkstate();
  lua_newtable(src);
  lua_pushstring(src, "k");
  lua_pushnumber(src, 7);
  lua_settable(src, -3);
  CHECK(wowless_copy_prim_value(dst, src, -1) == 0);
  CHECK(lua_istable(dst, -1));
  lua_getfield(dst, -1, "k");
  CHECK(lua_tonumber(dst, -1) == 7);
  lua_close(src);
  lua_close(dst);
}

static void test_nested_table(void) {
  lua_State *src = mkstate(), *dst = mkstate();
  lua_newtable(src);
  lua_newtable(src);
  lua_pushstring(src, "a");
  lua_pushnumber(src, 1);
  lua_settable(src, -3);
  lua_setfield(src, -2, "t");
  CHECK(wowless_copy_prim_value(dst, src, -1) == 0);
  lua_getfield(dst, -1, "t");
  CHECK(lua_istable(dst, -1));
  lua_getfield(dst, -1, "a");
  CHECK(lua_tonumber(dst, -1) == 1);
  lua_close(src);
  lua_close(dst);
}

static void test_function_error(void) {
  lua_State *src = mkstate(), *dst = mkstate();
  lua_pushcfunction(src, dummy);
  CHECK(wowless_copy_prim_value(dst, src, -1) == LUA_TFUNCTION);
  CHECK(lua_gettop(dst) == 0);
  lua_close(src);
  lua_close(dst);
}

static void test_thread_error(void) {
  lua_State *src = mkstate(), *dst = mkstate();
  lua_newthread(src);
  CHECK(wowless_copy_prim_value(dst, src, -1) == LUA_TTHREAD);
  CHECK(lua_gettop(dst) == 0);
  lua_close(src);
  lua_close(dst);
}

static void test_userdata_error(void) {
  lua_State *src = mkstate(), *dst = mkstate();
  lua_newuserdata(src, 1);
  CHECK(wowless_copy_prim_value(dst, src, -1) == LUA_TUSERDATA);
  CHECK(lua_gettop(dst) == 0);
  lua_close(src);
  lua_close(dst);
}

static void test_nested_unsupported_error(void) {
  lua_State *src = mkstate(), *dst = mkstate();
  lua_newtable(src);
  lua_pushstring(src, "f");
  lua_pushcfunction(src, dummy);
  lua_settable(src, -3);
  CHECK(wowless_copy_prim_value(dst, src, -1) == LUA_TFUNCTION);
  CHECK(lua_gettop(dst) == 0);
  lua_close(src);
  lua_close(dst);
}

/* Non-string/non-number keys are silently skipped. */
static void test_nonscalar_keys_skipped(void) {
  lua_State *src = mkstate(), *dst = mkstate();
  lua_newtable(src);
  lua_pushboolean(src, 1); /* boolean key — skipped */
  lua_pushnumber(src, 1);
  lua_settable(src, -3);
  lua_pushstring(src, "k"); /* string key — kept */
  lua_pushnumber(src, 2);
  lua_settable(src, -3);
  CHECK(wowless_copy_prim_value(dst, src, -1) == 0);
  CHECK(lua_istable(dst, -1));
  lua_getfield(dst, -1, "k");
  CHECK(lua_tonumber(dst, -1) == 2);
  lua_pop(dst, 1);
  int count = 0;
  lua_pushnil(dst);
  while (lua_next(dst, -2)) {
    count++;
    lua_pop(dst, 1);
  }
  CHECK(count == 1);
  lua_close(src);
  lua_close(dst);
}

/* wowless_copy_prim_table handles a negative srcidx correctly. */
static void test_negative_index(void) {
  lua_State *src = mkstate(), *dst = mkstate();
  lua_newtable(src);
  lua_pushstring(src, "v");
  lua_pushnumber(src, 9);
  lua_settable(src, -3);
  lua_pushnil(src); /* extra item so -2 is the table */
  CHECK(wowless_copy_prim_table(dst, src, -2) == 0);
  CHECK(lua_istable(dst, -1));
  lua_getfield(dst, -1, "v");
  CHECK(lua_tonumber(dst, -1) == 9);
  lua_close(src);
  lua_close(dst);
}

int main(void) {
  test_nil();
  test_bool_false();
  test_bool_true();
  test_number();
  test_string();
  test_table();
  test_nested_table();
  test_function_error();
  test_thread_error();
  test_userdata_error();
  test_nested_unsupported_error();
  test_nonscalar_keys_skipped();
  test_negative_index();
  if (nfail) {
    fprintf(stderr, "%d test(s) failed\n", nfail);
    return 1;
  }
  return 0;
}
