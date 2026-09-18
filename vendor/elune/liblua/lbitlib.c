/* Licensed under the terms of the MIT License; see full copyright information
 * in the "LICENSE" file or at <http://www.lua.org/license.html> */

#define lbitlib_c
#define LUA_LIB

#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

#define bit_checksigned(L, i) ((int32_t) luaL_checkinteger(L, i))
#define bit_checkunsigned(L, i) ((uint32_t) luaL_checkinteger(L, i))

static int bit_band (lua_State *L) {
    const int top = lua_gettop(L);
    int pos = 2;
    uint32_t result = bit_checkunsigned(L, 1);

    for (; pos <= top; ++pos) {
        result &= bit_checkunsigned(L, pos);
    }

    lua_pushinteger(L, (lua_Integer) result);
    return 1;
}

static int bit_bor (lua_State *L) {
    const int top = lua_gettop(L);
    int pos = 2;
    uint32_t result = bit_checkunsigned(L, 1);

    for (; pos <= top; ++pos) {
        result |= bit_checkunsigned(L, pos);
    }

    lua_pushinteger(L, (lua_Integer) result);
    return 1;
}

static int bit_bxor (lua_State *L) {
    const int top = lua_gettop(L);
    int pos = 2;
    uint32_t result = bit_checkunsigned(L, 1);

    for (; pos <= top; ++pos) {
        result ^= bit_checkunsigned(L, pos);
    }

    lua_pushinteger(L, (lua_Integer) result);
    return 1;
}

static int bit_bnot (lua_State *L) {
    uint32_t result = ~bit_checkunsigned(L, 1);
    lua_pushinteger(L, (lua_Integer) result);
    return 1;
}

static int bit_lshift (lua_State *L) {
    uint32_t result = bit_checkunsigned(L, 1);
    result <<= bit_checkunsigned(L, 2);
    lua_pushinteger(L, (lua_Integer) result);
    return 1;
}

static int bit_rshift (lua_State *L) {
    uint32_t result = bit_checkunsigned(L, 1);
    result >>= bit_checkunsigned(L, 2);
    lua_pushinteger(L, (lua_Integer) result);
    return 1;
}

static int bit_arshift (lua_State *L) {
    int32_t result = bit_checksigned(L, 1);
    result >>= bit_checksigned(L, 2);
    lua_pushinteger(L, (lua_Integer) result);
    return 1;
}

static int bit_mod (lua_State *L) {
    int32_t result = bit_checksigned(L, 1);
    result %= bit_checksigned(L, 2);
    lua_pushinteger(L, (lua_Integer) result);
    return 1;
}

/**
 * Bit library registration
 */

static const luaL_Reg bitlib_shared[] = {
    { "band", bit_band },
    { "bor", bit_bor },
    { "bxor", bit_bxor },
    { "bnot", bit_bnot },
    { "lshift", bit_lshift },
    { "rshift", bit_rshift },
    { "arshift", bit_arshift },
    { "mod", bit_mod },
    /* clang-format off */
    { NULL, NULL },
    /* clang-format on */
};

LUALIB_API int luaopen_bit (lua_State *L) {
    luaL_register(L, LUA_BITLIBNAME, bitlib_shared);
    return 1;
}

LUALIB_API int luaopen_elune_bit (lua_State *L) {
    luaL_getsubtable(L, LUA_ENVIRONINDEX, LUA_BITLIBNAME);
    luaL_setfuncs(L, bitlib_shared, 0);
    return 1;
}
