/* Licensed under the terms of the MIT License; see full copyright information
 * in the "LICENSE" file or at <http://www.lua.org/license.html> */

#define LUA_LIB

#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

static lua_State *optthread (lua_State *L, int *arg) {
    int idx = *arg;

    if (lua_isthread(L, idx)) {
        return lua_tothread(L, idx);
    } else {
        *arg = idx - 1;
        return L;
    }
}

static const char *seclib_taintmodes[] = { "disabled", "r", "w", "rw", NULL };

static int seclib_gettaintmode (lua_State *L) {
    int mode = lua_gettaintmode(L);
    lua_pushstring(L, seclib_taintmodes[mode]);
    return 1;
}

static int seclib_settaintmode (lua_State *L) {
    int mode = luaL_checkoption(L, 1, NULL, seclib_taintmodes);
    lua_settaintmode(L, mode);
    return 0;
}

static int seclib_getstacktaint (lua_State *L) {
    lua_State *L1 = luaL_optthread(L, 1, L);
    lua_pushstring(L, lua_getstacktaint(L1));
    return 1;
}

static int seclib_getvaluetaint (lua_State *L) {
    luaL_checkany(L, 1);
    lua_pushstring(L, lua_getvaluetaint(L, 1));
    return 1;
}

static int seclib_getobjecttaint (lua_State *L) {
    luaL_argcheck(L, (lua_type(L, 1) >= LUA_TSTRING), 1, "expected function, string, table, thread, or userdata");
    lua_pushstring(L, lua_getvaluetaint(L, 1));
    return 1;
}

static int seclib_getnewobjecttaint (lua_State *L) {
    lua_State *L1 = luaL_optthread(L, 1, L);
    lua_pushstring(L, lua_getnewobjecttaint(L1));
    return 1;
}

static int seclib_getnewclosuretaint (lua_State *L) {
    lua_State *L1 = luaL_optthread(L, 1, L);
    lua_pushstring(L, lua_getnewclosuretaint(L1));
    return 1;
}

static int seclib_getcalltaint (lua_State *L) {
    int arg = 1;
    lua_State *L1 = optthread(L, &arg);
    lua_Debug ar;

    if (lua_getstack(L1, luaL_checkint(L, arg + 1), &ar) != 0) {
        return luaL_argerror(L, arg + 1, "level out of range");
    }

    lua_pushstring(L, lua_getcalltaint(L1, &ar));
    return 1;
}

static int seclib_gettabletaint (lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    luaL_checkany(L, 1);
    lua_settop(L, 2);
    lua_pushstring(L, luaL_gettabletaint(L, 1));
    return 1;
}

static int seclib_getupvaluetaint (lua_State *L) {
    luaL_checktype(L, 1, LUA_TFUNCTION);
    luaL_checkint(L, 2);

    lua_pushstring(L, luaL_getupvaluetaint(L, 1, lua_toint(L, 2)));
    return 1;
}

static int seclib_getlocaltaint (lua_State *L) {
    int arg = 1;
    lua_State *L1 = optthread(L, &arg);
    int level = luaL_checkint(L, arg + 1);
    int index = luaL_checkint(L, arg + 2);
    lua_Debug ar;

    if (lua_getstack(L1, level, &ar) != 0) {
        return luaL_argerror(L, arg + 1, "level out of range");
    }

    lua_pushstring(L, luaL_getlocaltaint(L1, &ar, index));
    return 1;
}

static int seclib_setstacktaint (lua_State *L) {
    int arg = 1;
    lua_State *L1 = optthread(L, &arg);
    luaL_checkany(L, arg + 1);
    lua_setstacktaint(L1, luaL_optstring(L, arg + 1, NULL));
    return 0;
}

static int seclib_setvaluetaint (lua_State *L) {
    luaL_checkany(L, 1);
    luaL_checkany(L, 2);
    lua_settop(L, 2);
    lua_setvaluetaint(L, 1, luaL_optstring(L, 2, NULL));
    lua_settop(L, 1);
    return 1;
}

static int seclib_setobjecttaint (lua_State *L) {
    luaL_argcheck(L, (lua_type(L, 1) >= LUA_TSTRING), 1, "expected function, string, table, thread, or userdata");
    luaL_checkany(L, 2);
    lua_setobjecttaint(L, 1, luaL_optstring(L, 2, NULL));
    return 0;
}

static int seclib_setnewobjecttaint (lua_State *L) {
    int arg = 1;
    lua_State *L1 = optthread(L, &arg);
    luaL_checkany(L, arg + 1);
    lua_setnewobjecttaint(L1, luaL_optstring(L, arg + 1, NULL));
    return 0;
}

static int seclib_setnewclosuretaint (lua_State *L) {
    int arg = 1;
    lua_State *L1 = optthread(L, &arg);
    luaL_checkany(L, arg + 1);
    lua_setnewclosuretaint(L1, luaL_optstring(L, arg + 1, NULL));
    return 0;
}

static int seclib_settabletaint (lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    luaL_checkany(L, 2);
    luaL_checkany(L, 3);

    lua_settop(L, 3);
    lua_pushvalue(L, 2); /* push key */
    luaL_settabletaint(L, 1, luaL_optstring(L, 3, NULL));
    return 0;
}

static int seclib_setupvaluetaint (lua_State *L) {
    luaL_checktype(L, 1, LUA_TFUNCTION);
    luaL_checkint(L, 2);
    luaL_checkany(L, 3);

    luaL_setupvaluetaint(L, 1, lua_toint(L, 2), lua_tostring(L, 3));
    return 0;
}

static int seclib_setlocaltaint (lua_State *L) {
    int arg = 1;
    lua_State *L1 = optthread(L, &arg);
    int level = luaL_checkint(L, arg + 1);
    int index = luaL_checkint(L, arg + 2);
    luaL_checkany(L, arg + 3);
    lua_Debug ar;

    if (lua_getstack(L1, level, &ar) != 0) {
        return luaL_argerror(L, arg + 1, "level out of range");
    }

    luaL_setlocaltaint(L1, &ar, index, luaL_optstring(L, arg + 3, NULL));
    return 0;
}

static int seclib_cleartaint (lua_State *L) {
    lua_cleartaint(L, 0);
    return 0;
}

static int seclib_resettaint (lua_State *L) {
    lua_resettaint(L);
    return 0;
}

static int seclib_newsecurefunction (lua_State *L) {
    luaL_createsecuredelegate(L);
    return 1;
}

const luaL_Reg seclib_funcs[] = {
    { "gettaintmode", seclib_gettaintmode },
    { "settaintmode", seclib_settaintmode },
    { "getstacktaint", seclib_getstacktaint },
    { "getvaluetaint", seclib_getvaluetaint },
    { "getobjecttaint", seclib_getobjecttaint },
    { "getnewobjecttaint", seclib_getnewobjecttaint },
    { "getnewclosuretaint", seclib_getnewclosuretaint },
    { "getcalltaint", seclib_getcalltaint },
    { "gettabletaint", seclib_gettabletaint },
    { "getupvaluetaint", seclib_getupvaluetaint },
    { "getlocaltaint", seclib_getlocaltaint },
    { "setstacktaint", seclib_setstacktaint },
    { "setvaluetaint", seclib_setvaluetaint },
    { "setobjecttaint", seclib_setobjecttaint },
    { "setnewobjecttaint", seclib_setnewobjecttaint },
    { "setnewclosuretaint", seclib_setnewclosuretaint },
    { "settabletaint", seclib_settabletaint },
    { "setupvaluetaint", seclib_setupvaluetaint },
    { "setlocaltaint", seclib_setlocaltaint },
    { "cleartaint", seclib_cleartaint },
    { "resettaint", seclib_resettaint },
    { "newsecurefunction", seclib_newsecurefunction },
    /* clang-format off */
    { NULL, NULL },
    /* clang-format on */
};

LUALIB_API int luaopen_security (lua_State *L) {
    luaL_register(L, LUA_DBLIBNAME, seclib_funcs);
    return 1;
}
