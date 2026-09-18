/* Licensed under the terms of the MIT License; see full copyright information
 * in the "LICENSE" file or at <http://www.lua.org/license.html> */

#define lcompatlib_c
#define LUA_LIB

#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

static const char script[] =
    "\n"
    "-------------------------------------------------------------------\n"
    "local table = table\n"
    "foreach = table.foreach\n"
    "foreachi = table.foreachi\n"
    "getn = table.getn\n"
    "tinsert = table.insert\n"
    "tremove = table.remove\n"
    "sort = table.sort\n"
    "wipe = table.wipe\n"
    "-------------------------------------------------------------------\n"
    "local math = math\n"
    "abs = math.abs\n"
    "acos = function (x) return math.deg(math.acos(x)) end\n"
    "asin = function (x) return math.deg(math.asin(x)) end\n"
    "atan = function (x) return math.deg(math.atan(x)) end\n"
    "atan2 = function (x,y) return math.deg(math.atan2(x,y)) end\n"
    "ceil = math.ceil\n"
    "cos = function (x) return math.cos(math.rad(x)) end\n"
    "deg = math.deg\n"
    "exp = math.exp\n"
    "floor = math.floor\n"
    "frexp = math.frexp\n"
    "ldexp = math.ldexp\n"
    "log = math.log\n"
    "log10 = math.log10\n"
    "max = math.max\n"
    "min = math.min\n"
    "mod = math.fmod\n"
    "PI = math.pi\n"
    "rad = math.rad\n"
    "random = math.random\n"
    "sin = function (x) return math.sin(math.rad(x)) end\n"
    "sqrt = math.sqrt\n"
    "tan = function (x) return math.tan(math.rad(x)) end\n"
    "-------------------------------------------------------------------\n"
    "local string = string\n"
    "strbyte = string.byte\n"
    "strchar = string.char\n"
    "strfind = string.find\n"
    "format = string.format\n"
    "gmatch = string.gmatch\n"
    "gsub = string.gsub\n"
    "strlen = string.len\n"
    "strlower = string.lower\n"
    "strmatch = string.match\n"
    "strrep = string.rep\n"
    "strrev = string.reverse\n"
    "strsub = string.sub\n"
    "strupper = string.upper\n"
    "-------------------------------------------------------------------\n"
    "string.trim = strtrim\n"
    "string.split = strsplit\n"
    "string.join = strjoin\n"
    "-------------------------------------------------------------------\n"
    "\n";

LUALIB_API int luaopen_compat (lua_State *L) {
    if (luaL_loadbuffer(L, script, sizeof(script) - 1, "compat.lua") != 0) {
        lua_error(L);
    } else {
        lua_call(L, 0, 0);
    }

    return 0;
}
