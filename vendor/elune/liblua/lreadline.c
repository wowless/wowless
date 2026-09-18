/* Licensed under the terms of the MIT License; see full copyright information
 * in the "LICENSE" file or at <http://www.lua.org/license.html> */

#define LUA_LIB

#include "lreadline.h"

#include "lauxlib.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if defined(LUA_USE_READLINE)
#include <readline/history.h>
#include <readline/readline.h>
#endif

LUALIB_API int luaL_readline (lua_State *L, const char *prompt) {
#if defined(LUA_USE_READLINE)
    char *str = readline(prompt);

    if (str != NULL) {
        size_t len = strlen(str);
        lua_pushlstring(L, str, len);
        free(str);
        return 0;
    } else {
        return 1;
    }
#else
    char buf[LUA_MAXINPUT];
    size_t len = (sizeof(buf) / sizeof(buf[0]));

    luaL_writestring(prompt, strlen(prompt));

    if (fgets(buf, (int) len, stdin) != NULL) {
        len = strlen(buf);

        if (len > 0 && buf[len - 1] == '\n') { /* line ends with newline? */
            buf[--len] = '\0'; /* remove it */
        }

        lua_pushlstring(L, buf, len);
        return 0;
    } else {
        return 1;
    }
#endif
}

LUALIB_API void luaL_saveline (lua_State *L, const char *line) {
    lua_unused(L);

#if defined(LUA_USE_READLINE)
    add_history(line);
#else
    lua_unused(line);
#endif
}

LUALIB_API void luaL_setreadlinename (lua_State *L, const char *name) {
    lua_unused(L);

#if defined(LUA_USE_READLINE)
    rl_readline_name = (char *) name;
#else
    lua_unused(name);
#endif
}
