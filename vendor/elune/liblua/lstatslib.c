/* Licensed under the terms of the MIT License; see full copyright information
 * in the "LICENSE" file or at <http://www.lua.org/license.html> */

#define LUA_LIB

#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

static void aux_pushtime (lua_State *L, lua_Clock ticks) {
    lua_pushnumber(L, (lua_Number) ticks / lua_clockrate(L));
}

static int statslib_gettickcount (lua_State *L) {
    lua_pushnumber(L, (lua_Number) lua_clocktime(L));
    return 1;
}

static int statslib_gettickfrequency (lua_State *L) {
    lua_pushnumber(L, (lua_Number) lua_clockrate(L));
    return 1;
}

static int statslib_gettime (lua_State *L) {
    lua_Clock ticks;

    if (lua_type(L, 1) == LUA_TNUMBER) {
        ticks = (lua_Clock) lua_tonumber(L, 1);
    } else {
        ticks = lua_clocktime(L);
    }

    aux_pushtime(L, ticks);
    return 1;
}

static int statslib_getelapsedtime (lua_State *L) {
    lua_Clock tickstart = (lua_Clock) luaL_checknumber(L, 1);
    lua_Clock tickend = (lua_Clock) luaL_checknumber(L, 2);
    aux_pushtime(L, (tickend - tickstart));
    return 1;
}

static int statslib_collectstats (lua_State *L) {
    lua_collectstats(L);
    return 0;
}

static int statslib_resetstats (lua_State *L) {
    lua_resetstats(L);
    return 0;
}

static int statslib_getglobalstats (lua_State *L) {
    lua_GlobalStats stats;
    lua_getglobalstats(L, &stats);

    lua_createtable(L, 0, 5);
    lua_pushnumber(L, (lua_Number) stats.bytesused);
    lua_setfield(L, -2, "bytesused");
    lua_pushnumber(L, (lua_Number) stats.bytesallocated);
    lua_setfield(L, -2, "bytesallocated");

    return 1;
}

static int statslib_getfunctionstats (lua_State *L) {
    lua_FunctionStats stats;
    luaL_checktype(L, 1, LUA_TFUNCTION);
    lua_getfunctionstats(L, 1, &stats);

    lua_createtable(L, 0, 3);
    lua_pushnumber(L, stats.calls);
    lua_setfield(L, -2, "calls");
    lua_pushnumber(L, (lua_Number) stats.ownticks);
    lua_setfield(L, -2, "ownticks");
    lua_pushnumber(L, (lua_Number) stats.subticks);
    lua_setfield(L, -2, "subticks");

    return 1;
}

static int statslib_getsourcestats (lua_State *L) {
    lua_SourceStats stats;
    luaL_checkany(L, 1);
    lua_getsourcestats(L, luaL_optstring(L, 1, NULL), &stats);

    lua_createtable(L, 0, 4);
    lua_pushnumber(L, (lua_Number) stats.execticks);
    lua_setfield(L, -2, "execticks");
    lua_pushnumber(L, (lua_Number) stats.bytesowned);
    lua_setfield(L, -2, "bytesowned");

    return 1;
}

static int statslib_isprofilingenabled (lua_State *L) {
    lua_pushboolean(L, lua_isprofilingenabled(L));
    return 1;
}

static int statslib_setprofilingenabled (lua_State *L) {
    luaL_checkany(L, 1);
    lua_setprofilingenabled(L, lua_toboolean(L, 1));
    return 0;
}

const luaL_Reg statslib_funcs[] = {
    { "collectstats", statslib_collectstats },
    { "getelapsedtime", statslib_getelapsedtime },
    { "getfunctionstats", statslib_getfunctionstats },
    { "getglobalstats", statslib_getglobalstats },
    { "getsourcestats", statslib_getsourcestats },
    { "gettickcount", statslib_gettickcount },
    { "gettickfrequency", statslib_gettickfrequency },
    { "gettime", statslib_gettime },
    { "isprofilingenabled", statslib_isprofilingenabled },
    { "resetstats", statslib_resetstats },
    { "setprofilingenabled", statslib_setprofilingenabled },
    /* clang-format off */
    { NULL, NULL },
    /* clang-format on */
};

LUALIB_API int luaopen_stats (lua_State *L) {
    luaL_register(L, LUA_DBLIBNAME, statslib_funcs);
    return 1;
}
