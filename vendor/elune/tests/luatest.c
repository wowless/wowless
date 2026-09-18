/*
** elune tests
**
** Licensed under the terms of the MIT License; see full copyright information
** in the "LICENSE" file or at <http://www.lua.org/license.html>
*/

#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

#include <acutest.h>

static int luatest_panichandler (lua_State *L) {
    acutest_check_(0, __FILE__, __LINE__, "lua panic");
    acutest_message_("%s", luaL_optstring(L, -1, "<unknown error>"));
    lua_close(L);
    acutest_abort_();
    return 0; /* unreachable */
}

static lua_State *luatest_newstate (void) {
    lua_State *L = luaL_newstate();
    lua_setprofilingenabled(L, 1);
    lua_settaintmode(L, LUA_TAINTRDRW);
    lua_atpanic(L, luatest_panichandler);
    return L;
}

/*
** C API Test Cases
*/

static void f_protecttaint_normal (lua_State *L, void *ud) {
    lua_setstacktaint(L, (const char *) ud);
    lua_pushliteral(L, "test");
}

static void test_protecttaint_secure_normal (void) {
    lua_State *L = luatest_newstate();
    lua_protecttaint(L, &f_protecttaint_normal, NULL);
    TEST_CHECK((luaL_issecure(L)));
    TEST_CHECK((luaL_issecurevalue(L, -1)));
    lua_close(L);
}

static void test_protecttaint_tainted_normal (void) {
    lua_State *L = luatest_newstate();
    lua_protecttaint(L, &f_protecttaint_normal, LUA_FORCEINSECURE_TAINT);
    TEST_CHECK((!luaL_issecure(L)));
    TEST_CHECK((!luaL_issecurevalue(L, -1)));
    lua_close(L);
}

static void f_protecttaint_error (lua_State *L, void *ud) {
    lua_setstacktaint(L, (const char *) ud);
    lua_pushliteral(L, "error");
    lua_error(L);
}

static int f_protecttaint_inner (lua_State *L) {
    lua_protecttaint(L, &f_protecttaint_error, lua_touserdata(L, 1));
    return 0;
}

static void test_protecttaint_secure_error (void) {
    int status;

    lua_State *L = luatest_newstate(); /* start secure */
    status = lua_cpcall(L, &f_protecttaint_inner, LUA_FORCEINSECURE_TAINT);
    TEST_CHECK((status != 0));
    TEST_CHECK((luaL_issecure(L)));
    lua_close(L);
}

static void test_protecttaint_tainted_error (void) {
    int status;

    lua_State *L = luatest_newstate();
    lua_setstacktaint(L, LUA_FORCEINSECURE_TAINT); /* start tainted */
    status = lua_cpcall(L, &f_protecttaint_inner, NULL);
    TEST_CHECK((status != 0));
    TEST_CHECK((!luaL_issecure(L)));
    lua_close(L);
}

/*
** Scripted Test Cases
*/

static int luatest_errorhandler (lua_State *L) {
    acutest_check_(0, __FILE__, __LINE__, "error handler");
    luaL_traceback(L, L, lua_tostring(L, 1), 2);
    acutest_message_("%s", lua_tostring(L, -1));
    return 0;
}

static int luatest_case (lua_State *L) {
    acutest_case_("%s", luaL_checkstring(L, 1));
    lua_pushcclosure(L, &luatest_errorhandler, 0);
    lua_replace(L, LUA_ERRORHANDLERINDEX);
    luaL_securecall(L, 0, 0, LUA_ERRORHANDLERINDEX);
    return 0;
}

static void test_scriptcases (void) {
    lua_State *L = luatest_newstate();
    luaL_openlibsx(L, LUALIB_ELUNE);

    /* Add custom test case registration function to environment. */
    lua_pushcclosure(L, &luatest_case, 0);
    lua_setfield(L, LUA_GLOBALSINDEX, "case");

    if (!TEST_CHECK((luaL_dofile(L, "luatest_scriptcases.lua") == 0))) {
        TEST_MSG("%s", (luaL_optstring(L, -1, "<unknown script error>")));
    }

    lua_close(L);
}

static void test_coroutinescriptcases (void) {
    lua_State *L = luatest_newstate();
    luaL_openlibs(L);

    /* Add custom test case registration function to environment. */
    lua_pushcclosure(L, &luatest_case, 0);
    lua_setfield(L, LUA_GLOBALSINDEX, "case");

    if (!TEST_CHECK((luaL_dofile(L, "luatest_coroutine.lua") == 0))) {
        TEST_MSG("%s", (luaL_optstring(L, -1, "<unknown script error>")));
    }

    lua_close(L);
}

static void test_profilingscriptcases (void) {
    lua_State *L = luatest_newstate();
    luaL_openlibs(L);

    /* Add custom test case registration function to environment. */
    lua_pushcclosure(L, &luatest_case, 0);
    lua_setfield(L, LUA_GLOBALSINDEX, "case");

    if (!TEST_CHECK((luaL_dofile(L, "luatest_profiling.lua") == 0))) {
        TEST_MSG("%s", (luaL_optstring(L, -1, "<unknown script error>")));
    }

    lua_close(L);
}

/*
** Test Case Registration
*/

TEST_LIST = {
    { "lua_protecttaint: stack remains secure after call", test_protecttaint_secure_normal },
    { "lua_protecttaint: stack remains tainted after call", test_protecttaint_tainted_normal },
    { "lua_protecttaint: stack restored to secure on error", test_protecttaint_secure_error },
    { "lua_protecttaint: stack restored to tainted on error", test_protecttaint_tainted_error },
    { "scripted test cases", test_scriptcases },
    { "coroutine script tests", test_coroutinescriptcases },
    { "profiling script tests", test_profilingscriptcases },
    /* clang-format off */
    { NULL, NULL },
    /* clang-format on */
};
