/* Licensed under the terms of the MIT License; see full copyright information
 * in the "LICENSE" file or at <http://www.lua.org/license.html> */

#ifndef lreadline_h
#define lreadline_h

#include "lua.h"

LUALIB_API int luaL_readline (lua_State *L, const char *prompt);
LUALIB_API void luaL_saveline (lua_State *L, const char *line);
LUALIB_API void luaL_setreadlinename (lua_State *L, const char *name);

#endif
