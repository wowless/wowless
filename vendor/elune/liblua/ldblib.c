/* Licensed under the terms of the MIT License; see full copyright information
 * in the "LICENSE" file or at <http://www.lua.org/license.html> */

#include <stdlib.h>
#include <string.h>

#define ldblib_c
#define LUA_LIB

#include "lua.h"

#include "lreadline.h"

#include "lauxlib.h"
#include "lualib.h"

static int db_getregistry (lua_State *L) {
    lua_pushvalue(L, LUA_REGISTRYINDEX);
    return 1;
}

static int db_getmetatable (lua_State *L) {
    luaL_checkany(L, 1);
    if (!lua_getmetatable(L, 1)) {
        lua_pushnil(L); /* no metatable */
    }
    return 1;
}

static int db_setmetatable (lua_State *L) {
    int t = lua_type(L, 2);
    luaL_argcheck(L, t == LUA_TNIL || t == LUA_TTABLE, 2, "nil or table expected");
    lua_settop(L, 2);
    lua_pushboolean(L, lua_setmetatable(L, 1));
    return 1;
}

static int db_getfenv (lua_State *L) {
    luaL_checkany(L, 1);
    lua_getfenv(L, 1);
    return 1;
}

static int db_setfenv (lua_State *L) {
    luaL_checktype(L, 2, LUA_TTABLE);
    lua_settop(L, 2);
    if (lua_setfenv(L, 1) == 0) {
        luaL_error(L, "'setfenv' cannot change environment of given object");
    }
    return 1;
}

static void settabss (lua_State *L, const char *i, const char *v) {
    lua_pushstring(L, v);
    lua_setfield(L, -2, i);
}

static void settabsi (lua_State *L, const char *i, int v) {
    lua_pushinteger(L, v);
    lua_setfield(L, -2, i);
}

static lua_State *getthread (lua_State *L, int *arg) {
    if (lua_isthread(L, 1)) {
        *arg = 1;
        return lua_tothread(L, 1);
    } else {
        *arg = 0;
        return L;
    }
}

static void treatstackoption (lua_State *L, lua_State *L1, const char *fname) {
    if (L == L1) {
        lua_pushvalue(L, -2);
        lua_remove(L, -3);
    } else {
        lua_xmove(L1, L, 1);
    }
    lua_setfield(L, -2, fname);
}

static int db_getinfo (lua_State *L) {
    lua_Debug ar;
    int arg;
    lua_State *L1 = getthread(L, &arg);
    const char *options = luaL_optstring(L, arg + 2, "flnSu");
    if (lua_isnumber(L, arg + 1)) {
        if (!lua_getstack(L1, lua_toint(L, arg + 1), &ar)) {
            lua_pushnil(L); /* level out of range */
            return 1;
        }
    } else if (lua_isfunction(L, arg + 1)) {
        lua_pushfstring(L, ">%s", options);
        options = lua_tostring(L, -1);
        lua_pushvalue(L, arg + 1);
        lua_xmove(L, L1, 1);
    } else {
        return luaL_argerror(L, arg + 1, "function or level expected");
    }
    if (!lua_getinfo(L1, options, &ar)) {
        return luaL_argerror(L, arg + 2, "invalid option");
    }
    lua_createtable(L, 0, 2);
    if (strchr(options, 'S')) {
        settabss(L, "source", ar.source);
        settabss(L, "short_src", ar.short_src);
        settabsi(L, "linedefined", ar.linedefined);
        settabsi(L, "lastlinedefined", ar.lastlinedefined);
        settabss(L, "what", ar.what);
    }
    if (strchr(options, 'l')) {
        settabsi(L, "currentline", ar.currentline);
    }
    if (strchr(options, 'u')) {
        settabsi(L, "nups", ar.nups);
    }
    if (strchr(options, 'n')) {
        settabss(L, "name", ar.name);
        settabss(L, "namewhat", ar.namewhat);
    }
    if (strchr(options, 'L')) {
        treatstackoption(L, L1, "activelines");
    }
    if (strchr(options, 'f')) {
        treatstackoption(L, L1, "func");
    }
    return 1; /* return table */
}

static int db_getlocal (lua_State *L) {
    int arg;
    lua_State *L1 = getthread(L, &arg);
    lua_Debug ar;
    const char *name;
    if (!lua_getstack(L1, luaL_checkint(L, arg + 1), &ar)) { /* out of range? */
        return luaL_argerror(L, arg + 1, "level out of range");
    }
    name = lua_getlocal(L1, &ar, luaL_checkint(L, arg + 2));
    if (name) {
        lua_xmove(L1, L, 1);
        lua_pushstring(L, name);
        lua_pushvalue(L, -2);
        return 2;
    } else {
        lua_pushnil(L);
        return 1;
    }
}

static int db_setlocal (lua_State *L) {
    int arg;
    lua_State *L1 = getthread(L, &arg);
    lua_Debug ar;
    if (!lua_getstack(L1, luaL_checkint(L, arg + 1), &ar)) { /* out of range? */
        return luaL_argerror(L, arg + 1, "level out of range");
    }
    luaL_checkany(L, arg + 3);
    lua_settop(L, arg + 3);
    lua_xmove(L, L1, 1);
    lua_pushstring(L, lua_setlocal(L1, &ar, luaL_checkint(L, arg + 2)));
    return 1;
}

static int auxupvalue (lua_State *L, int get) {
    const char *name;
    int n = luaL_checkint(L, 2);
    luaL_checktype(L, 1, LUA_TFUNCTION);
    if (lua_iscfunction(L, 1)) {
        return 0; /* cannot touch C upvalues from Lua */
    }
    name = get ? lua_getupvalue(L, 1, n) : lua_setupvalue(L, 1, n);
    if (name == NULL) {
        return 0;
    }
    lua_pushstring(L, name);
    lua_insert(L, -(get + 1));
    return get + 1;
}

static int db_getupvalue (lua_State *L) {
    return auxupvalue(L, 1);
}

static int db_setupvalue (lua_State *L) {
    luaL_checkany(L, 3);
    return auxupvalue(L, 0);
}

static const char KEY_HOOK = 'h';

static void hookf (lua_State *L, lua_Debug *ar) {
    static const char *const hooknames[] = {
        "call", "return", "line", "count", "tail return",
    };

    lua_pushlightuserdata(L, (void *) &KEY_HOOK);
    lua_rawget(L, LUA_REGISTRYINDEX);
    lua_pushlightuserdata(L, L);
    lua_rawget(L, -2);
    if (lua_isfunction(L, -1)) {
        lua_pushstring(L, hooknames[(int) ar->event]);
        if (ar->currentline >= 0) {
            lua_pushinteger(L, ar->currentline);
        } else {
            lua_pushnil(L);
        }
        lua_assert(lua_getinfo(L, "lS", ar));
        lua_call(L, 2, 0);
    }
}

static int makemask (const char *smask, int count) {
    int mask = 0;
    if (strchr(smask, 'c')) {
        mask |= LUA_MASKCALL;
    }
    if (strchr(smask, 'r')) {
        mask |= LUA_MASKRET;
    }
    if (strchr(smask, 'l')) {
        mask |= LUA_MASKLINE;
    }
    if (count > 0) {
        mask |= LUA_MASKCOUNT;
    }
    return mask;
}

static char *unmakemask (int mask, char *smask) {
    int i = 0;
    if (mask & LUA_MASKCALL) {
        smask[i++] = 'c';
    }
    if (mask & LUA_MASKRET) {
        smask[i++] = 'r';
    }
    if (mask & LUA_MASKLINE) {
        smask[i++] = 'l';
    }
    smask[i] = '\0';
    return smask;
}

static void gethooktable (lua_State *L) {
    lua_pushlightuserdata(L, (void *) &KEY_HOOK);
    lua_rawget(L, LUA_REGISTRYINDEX);
    if (!lua_istable(L, -1)) {
        lua_pop(L, 1);
        lua_createtable(L, 0, 1);
        lua_pushlightuserdata(L, (void *) &KEY_HOOK);
        lua_pushvalue(L, -2);
        lua_rawset(L, LUA_REGISTRYINDEX);
    }
}

static int db_sethook (lua_State *L) {
    int arg;
    int mask;
    int count;
    lua_Hook func;
    lua_State *L1 = getthread(L, &arg);
    if (lua_isnoneornil(L, arg + 1)) {
        lua_settop(L, arg + 1);
        func = NULL;
        mask = 0;
        count = 0; /* turn off hooks */
    } else {
        const char *smask = luaL_checkstring(L, arg + 2);
        luaL_checktype(L, arg + 1, LUA_TFUNCTION);
        count = luaL_optint(L, arg + 3, 0);
        func = hookf;
        mask = makemask(smask, count);
    }
    gethooktable(L);
    lua_pushlightuserdata(L, L1);
    lua_pushvalue(L, arg + 1);
    lua_rawset(L, -3); /* set new hook */
    lua_pop(L, 1); /* remove hook table */
    lua_sethook(L1, func, mask, count); /* set hooks */
    return 0;
}

static int db_gethook (lua_State *L) {
    int arg;
    lua_State *L1 = getthread(L, &arg);
    char buff[4];
    int mask = lua_gethookmask(L1);
    lua_Hook hook = lua_gethook(L1);
    if (hook != NULL && hook != hookf) { /* external hook? */
        lua_pushliteral(L, "external hook");
    } else {
        gethooktable(L);
        lua_pushlightuserdata(L, L1);
        lua_rawget(L, -2); /* get hook */
        lua_remove(L, -2); /* remove hook table */
    }
    lua_pushstring(L, unmakemask(mask, buff));
    lua_pushinteger(L, lua_gethookcount(L1));
    return 3;
}

static int db_debug (lua_State *L) {
    for (;;) {
        const char *line;
        size_t len;

        if (luaL_readline(L, "lua_debug> ") != 0) {
            return 0; /* error reading line */
        }

        line = lua_tolstring(L, -1, &len);

        if (strcmp(line, "cont") == 0) {
            return 0; /* explicit break */
        }

        if (luaL_loadbuffer(L, line, len, "=(debug command)") || lua_pcall(L, 0, 0, 0)) {
            luaL_writestringerror("%s\n", lua_tostring(L, -1));
        }

        if (len > 0) {
            luaL_saveline(L, line);
        }

        lua_settop(L, 0); /* pop line and any errors */
    }
}

static int db_traceback (lua_State *L) {
    int arg;
    lua_State *L1 = getthread(L, &arg);
    const char *msg = lua_tostring(L, arg + 1);
    if (msg == NULL && !lua_isnoneornil(L, arg + 1)) { /* non-string 'msg'? */
        lua_pushvalue(L, arg + 1); /* return it untouched */
    } else {
        int level = luaL_optint(L, arg + 2, (L == L1) ? 1 : 0);
        luaL_traceback(L, L1, msg, level);
    }
    return 1;
}

static int db_geterrorhandler (lua_State *L) {
    lua_pushvalue(L, LUA_ERRORHANDLERINDEX);
    return 1;
}

static int db_seterrorhandler (lua_State *L) {
    luaL_checkany(L, 1);
    lua_replace(L, LUA_ERRORHANDLERINDEX);
    return 0;
}

static int db_getobjectsize (lua_State *L) {
    luaL_checkany(L, 1);
    lua_pushinteger(L, lua_objsize(L, 1));
    return 1;
}

static int db_iscfunction (lua_State *L) {
    lua_pushboolean(L, lua_iscfunction(L, 1));
    return 1;
}

static int db_newcfunction (lua_State *L) {
    luaL_checkany(L, 1);
    luaL_createdelegate(L);
    return 1;
}

static int db_ref (lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    luaL_checkany(L, 2);
    lua_pushinteger(L, luaL_ref(L, 1));
    return 1;
}

static int db_unref (lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    luaL_unref(L, 1, luaL_checkint(L, 2));
    return 0;
}

static const char *db_compatopts[] = { "setfenv", "gctaint", "gcdebug", "inerrorhandler", NULL };

static int db_getcompatopt (lua_State *L) {
    lua_State *L1;
    int opt;
    int val;
    int arg;

    L1 = getthread(L, &arg);
    opt = luaL_checkoption(L, arg + 1, NULL, db_compatopts);
    val = lua_getcompatopt(L1, opt);

    lua_pushinteger(L, val);
    return 1;
}

static int db_setcompatopt (lua_State *L) {
    lua_State *L1;
    int opt;
    int val;
    int arg;

    L1 = getthread(L, &arg);
    opt = luaL_checkoption(L, arg + 1, NULL, db_compatopts);
    val = luaL_checkint(L, arg + 2);

    lua_setcompatopt(L1, opt, val);
    return 0;
}

static int db_getexceptmask (lua_State *L) {
    lua_State *L1;
    int arg;
    int mask;
    char smask[4];

    L1 = getthread(L, &arg);
    mask = lua_getexceptmask(L);

    int i = 0;
    if (mask & LUA_EXCEPTFPECOERCE) {
        smask[i++] = 'f';
    }
    if (mask & LUA_EXCEPTFPESTRICT) {
        smask[i++] = 'F';
    }
    if (mask & LUA_EXCEPTOVERFLOW) {
        smask[i++] = 'o';
    }
    smask[i] = '\0';

    lua_pushstring(L1, smask);
    return 1;
}

static int db_setexceptmask (lua_State *L) {
    lua_State *L1;
    const char *smask;
    int arg;
    int mask;

    L1 = getthread(L, &arg);
    smask = luaL_checkstring(L, arg + 1);

    mask = 0;
    if (strchr(smask, 'f')) {
        mask |= LUA_EXCEPTFPECOERCE;
    }
    if (strchr(smask, 'F')) {
        mask |= LUA_EXCEPTFPESTRICT;
    }
    if (strchr(smask, 'o')) {
        mask |= LUA_EXCEPTOVERFLOW;
    }

    lua_setexceptmask(L1, mask);
    return 0;
}

static int db_getscripttimeout (lua_State *L) {
    lua_ScriptTimeout timeout;
    lua_getscripttimeout(L, &timeout);

    lua_pushnumber(L, (lua_Number) timeout.ticks / lua_clockrate(L));
    lua_pushinteger(L, timeout.instructions);
    return 2;
}

static int db_setscripttimeout (lua_State *L) {
    lua_ScriptTimeout timeout;
    timeout.ticks = (lua_Clock) (luaL_checknumber(L, 1) * lua_clockrate(L));
    timeout.instructions = luaL_checkint(L, 2);
    lua_setscripttimeout(L, &timeout);
    return 0;
}

static int db_debugprofilestart (lua_State *L) {
    lua_Clock *start = (lua_Clock *) lua_touserdata(L, lua_upvalueindex(1));
    *start = lua_clocktime(L);
    return 0;
}

static int db_debugprofilestop (lua_State *L) {
    lua_Clock stop = lua_clocktime(L);
    lua_Clock start = *((lua_Clock *) lua_touserdata(L, lua_upvalueindex(1)));
    lua_Clock rate = lua_clockrate(L);

    lua_pushnumber(L, (((lua_Number) stop - start) * 1e3) / rate);
    return 1;
}

static int db_stack (lua_State *L) {
    lua_State *L1 = L;
    int level = 1;
    int ntop = 12;
    int nbase = 10;
    int firstpart = 1;
    int startlevel;
    lua_Debug ar;

    /* This is basically the Lua 5.0 version of debug.traceback, with added
     * support for an optional thread and the top/base parameters. */

    if (lua_type(L, 1) == LUA_TTHREAD) {
        /* This is technically broken and can crash if the thread is garbage
         * collected mid-stack generation - but such behavior is accurate to
         * reference so... */
        L1 = lua_tothread(L, 1);
        lua_remove(L, 1);
    }

    if (!lua_ishookallowed(L1) && !lua_getcompatopt(L1, LUA_COMPATGCDEBUG)) {
        return 0; /* '__gc' metamethod is executing. */
    }

    if (lua_isnumber(L, 1)) {
        level = (int) lua_tonumber(L, 1);
        lua_remove(L, 1);
    }

    if (lua_isnumber(L, 1)) {
        ntop = (int) lua_tonumber(L, 1);
        lua_remove(L, 1);
    }

    if (lua_isnumber(L, 1)) {
        nbase = (int) lua_tonumber(L, 1);
        lua_remove(L, 1);
    }

    if (lua_gettop(L) == 0) {
        lua_pushliteral(L, "");
    } else if (!lua_isstring(L, 1)) {
        return 1;
    }

    startlevel = level;

    while (lua_getstack(L1, level++, &ar)) {
        if ((ntop + startlevel) < level && firstpart) {
            if (!lua_getstack(L1, level + nbase, &ar)) {
                level--;
            } else {
                lua_pushliteral(L, "...\n");
                while (lua_getstack(L1, level + nbase, &ar)) {
                    level++;
                }
            }

            firstpart = 0;
            continue;
        }

        lua_getinfo(L1, "Snl", &ar);
        lua_pushfstring(L, "%s:", ar.short_src);

        if (ar.currentline > 0) {
            lua_pushfstring(L, "%d:", ar.currentline);
        }

        switch (*ar.namewhat) {
            case 'g':
            case 'l':
            case 'f':
            case 'm':
                lua_pushfstring(L, " in function `%s'", ar.name);
                break;
            default: {
                if (*ar.what == 'm') {
                    lua_pushfstring(L, " in main chunk");
                } else if (*ar.what == 'C' || *ar.what == 't') {
                    lua_pushliteral(L, " ?");
                } else {
                    lua_pushfstring(L, " in function <%s:%d>", ar.short_src, ar.linedefined);
                }
            }
        }

        lua_pushliteral(L, "\n");
        lua_concat(L, lua_gettop(L));
    }

    lua_concat(L, lua_gettop(L));
    return 1;
}

static void aux_dumpvalue (lua_State *L, const char *name, int idx, int recurse) {
    const char *indent;
    idx = lua_absindex(L, idx);

    if (!recurse) {
        indent = " "; /* only a single level of recursion is really supported */
    } else {
        indent = "";
    }

    switch (lua_type(L, idx)) {
        case LUA_TNONE:
            LUA_FALLTHROUGH;
        case LUA_TNIL:
            lua_pushfstring(L, "%s%s = nil\n", indent, name);
            break;
        case LUA_TBOOLEAN:
            lua_pushfstring(L, "%s%s = %s\n", indent, name, lua_toboolean(L, idx) ? "true" : "false");
            break;
        case LUA_TNUMBER:
            lua_pushfstring(L, "%s%s = %s\n", indent, name, lua_tostring(L, idx));
            break;
        case LUA_TSTRING:
            lua_pushfstring(L, "%s%s = \"%s\"\n", indent, name, lua_tostring(L, idx));
            break;
        case LUA_TTABLE: {
            /* When using buffer operations we're permitted to use stack space
             * between calls so long as such usage is balanced; as such all
             * calls to luaL_addvalue need to ensure that no additional values
             * are present on the stack.
             *
             * For table traversal this requires us to allocate one stack slot
             * _above_ the buffer to temporarily hold the key while we append
             * to the buffer. */

            luaL_Buffer B;
            int kidx;

            lua_pushnil(L); /* initial traversal key */
            kidx = lua_gettop(L);
            luaL_buffinit(L, &B);

            lua_rawgeti(L, idx, 0); /* push object userdata */

            if (lua_isuserdata(L, -1) && luaL_callmeta(L, -1, "__name")) {
                if (lua_isstring(L, -1)) {
                    lua_pushfstring(L, "%s%s = %s {\n", indent, name, lua_tostring(L, -1));
                } else {
                    lua_pushfstring(L, "%s%s = <unnamed> {\n", indent, name);
                }

                lua_replace(L, -2); /* replace object name */
            } else {
                lua_pushfstring(L, "%s%s = <table> {\n", indent, name);
            }

            lua_replace(L, -2); /* replace object userdata */
            luaL_addvalue(&B); /* open table */

            if (recurse--) {
                lua_pushvalue(L, kidx); /* push initial key */

                while (lua_next(L, idx)) {
                    const char *kname;
                    lua_copy(L, -2, kidx); /* copy key to traversal slot */

                    if ((kname = lua_tostring(L, -2)) == NULL) {
                        kname = ""; /* default key name appropriately for reference */
                    }

                    aux_dumpvalue(L, kname, -1, recurse);
                    lua_replace(L, -3); /* replace key */
                    lua_pop(L, 1); /* pop value */
                    luaL_addvalue(&B); /* append to buffer */
                    lua_pushvalue(L, kidx); /* push traversal key */
                }
            }

            lua_pushfstring(L, "%s}\n", indent);
            luaL_addvalue(&B); /* close table */
            luaL_pushresult(&B); /* concat table buffer */
            lua_remove(L, kidx); /* pop traversal key space */
            break;
        }
        case LUA_TFUNCTION: {
            lua_Debug ar;
            lua_pushvalue(L, idx);
            lua_getinfo(L, ">nS", &ar);

            if (!ar.name && !ar.source) {
                lua_pushfstring(L, "%s%s = <function> defined %d\n", indent, name, ar.linedefined);
            } else if (!ar.name) {
                lua_pushfstring(L, "%s%s = <function> defined %s:%d\n", indent, name, ar.source, ar.linedefined);
            } else {
                lua_pushfstring(L, "%s%s = %s() defined %s:%d\n", indent, name, ar.name, ar.source, ar.linedefined);
            }

            break;
        }
        case LUA_TLIGHTUSERDATA:
            LUA_FALLTHROUGH;
        case LUA_TUSERDATA:
            lua_pushfstring(L, "%s%s = <userdata>\n", indent, name);
            break;
        default:
            lua_pushfstring(L, "%s%s = <%s>\n", indent, name, lua_typename(L, lua_type(L, idx)));
            break;
    }
}

static int db_locals (lua_State *L) {
    int level = (int) luaL_optnumber(L, 1, 1);
    int enabled;
    luaL_Buffer B;
    lua_Debug ar;

    if (!lua_getcompatopt(L, LUA_COMPATINERRORHANDLER)) {
        enabled = 1; /* 'debuglocals' can be called outside error handler in recent versions. */
    } else {
        lua_rawgeti(L, LUA_REGISTRYINDEX, LUA_RIDX_INERRORHANDLER);
        enabled = lua_toboolean(L, -1);
        lua_pop(L, 1);
    }

    if (!enabled) {
        return 0; /* called outside of the global error handler. */
    } else if (!lua_ishookallowed(L) && !lua_getcompatopt(L, LUA_COMPATGCDEBUG)) {
        return 0; /* '__gc' metamethod is executing. */
    } else if (level < 1) {
        level = 1;
    }

    luaL_buffinit(L, &B);

    if (lua_getstack(L, level, &ar) != 0) {
        const char *name = NULL;
        int local = 1;
        int upval = 1;

        while ((name = lua_getlocal(L, &ar, local++)) != NULL) {
            int recurse = 1;
            aux_dumpvalue(L, name, -1, recurse);
            lua_replace(L, -2); /* replace local */
            luaL_addvalue(&B);
        }

        lua_getinfo(L, "f", &ar); /* push function */

        while ((name = lua_getupvalue(L, -1, upval++)) != NULL) {
            int recurse = 1;
            aux_dumpvalue(L, name, -1, recurse);
            lua_replace(L, -2); /* replace upvalue */
            luaL_addvalue(&B);
        }

        lua_pop(L, 1); /* pop function */
    }

    luaL_pushresult(&B);
    return 1;
}

/**
 * Debug library registration
 */

static const luaL_Reg dblib_lua[] = {
    { "debug", db_debug },
    { "getcompatopt", db_getcompatopt },
    { "geterrorhandler", db_geterrorhandler },
    { "getexceptmask", db_getexceptmask },
    { "getfenv", db_getfenv },
    { "gethook", db_gethook },
    { "getinfo", db_getinfo },
    { "getlocal", db_getlocal },
    { "getmetatable", db_getmetatable },
    { "getobjectsize", db_getobjectsize },
    { "getregistry", db_getregistry },
    { "getscripttimeout", db_getscripttimeout },
    { "getupvalue", db_getupvalue },
    { "iscfunction", db_iscfunction },
    { "newcfunction", db_newcfunction },
    { "ref", db_ref },
    { "setcompatopt", db_setcompatopt },
    { "seterrorhandler", db_seterrorhandler },
    { "setexceptmask", db_setexceptmask },
    { "setfenv", db_setfenv },
    { "sethook", db_sethook },
    { "setlocal", db_setlocal },
    { "setmetatable", db_setmetatable },
    { "setscripttimeout", db_setscripttimeout },
    { "setupvalue", db_setupvalue },
    { "traceback", db_traceback },
    { "unref", db_unref },
    /* clang-format off */
    { NULL, NULL },
    /* clang-format on */
};

static const luaL_Reg dblib_global[] = {
    { "debugstack", db_stack },
    { "debuglocals", db_locals },
    /* clang-format off */
    { NULL, NULL },
    /* clang-format on */
};

static void dblib_opendebugprofile (lua_State *L) {
    /**
     * The debugprofilestart and debugprofilestop functions act as paired calls
     * and need to share a "start" time as state between the two. We store this
     * in some full-userdata stored as upvalues on each closure.
     *
     * On creation the start time is left as zero so that any calls to the
     * debugprofilestop API will return time-since-state-creation until a
     * call to debugprofilestart is made.
     */

    lua_Clock *start = (lua_Clock *) lua_newuserdata(L, sizeof(lua_Clock));
    *start = 0;

    lua_pushvalue(L, -1);
    lua_pushcclosure(L, db_debugprofilestart, 1);
    lua_setfield(L, -3, "debugprofilestart");
    lua_pushcclosure(L, db_debugprofilestop, 1);
    lua_setfield(L, -2, "debugprofilestop");
}

LUALIB_API int luaopen_debug (lua_State *L) {
    luaL_register(L, "_G", dblib_global);
    dblib_opendebugprofile(L);
    luaL_register(L, LUA_DBLIBNAME, dblib_lua);
    return 1;
}

LUALIB_API int luaopen_elune_debug (lua_State *L) {
    lua_pushvalue(L, LUA_ENVIRONINDEX);
    luaL_setfuncs(L, dblib_global, 0);
    dblib_opendebugprofile(L);
    return 0;
}
