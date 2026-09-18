/* Licensed under the terms of the MIT License; see full copyright information
 * in the "LICENSE" file or at <http://www.lua.org/license.html> */

#define linit_c
#define LUA_LIB

#include "lauxlib.h"
#include "lua.h"
#include "lualib.h"

static const luaL_Reg lualibs[] = {
    {LUA_BASELIBNAME,           luaopen_base    },
    {LUA_BITLIBNAME,            luaopen_bit     },
    {LUA_DBLIBNAME,             luaopen_debug   },
    {LUA_DBLIBNAME ".security", luaopen_security},
    {LUA_DBLIBNAME ".stats",    luaopen_stats   },
    {LUA_IOLIBNAME,             luaopen_io      },
    {LUA_LOADLIBNAME,           luaopen_package },
    {LUA_MATHLIBNAME,           luaopen_math    },
    {LUA_OSLIBNAME,             luaopen_os      },
    {LUA_STRLIBNAME,            luaopen_string  },
    {LUA_TABLIBNAME,            luaopen_table   },
    {LUA_COMPATLIBNAME,         luaopen_compat  },
    /* clang-format off */
    { NULL, NULL },
    /* clang-format on */
};

LUALIB_API void luaL_openlibs(lua_State *L) {
  for (const luaL_Reg *lib = lualibs; lib->func; lib++) {
    lua_pushcclosure(L, lib->func, 0);
    lua_pushstring(L, lib->name);
    lua_call(L, 1, 0);
  }
}
