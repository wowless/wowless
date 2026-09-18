/* Licensed under the terms of the MIT License; see full copyright information
 * in the "LICENSE" file or at <http://www.lua.org/license.html> */

#define lbaselib_c
#define LUA_LIB

#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

#include <ctype.h>
#include <stdlib.h>
#include <string.h>

static int luaB_print (lua_State *L) {
    int n = lua_gettop(L); /* number of arguments */
    int i;
    lua_getglobal(L, "tostring");
    for (i = 1; i <= n; i++) {
        const char *s;
        size_t l;
        lua_pushvalue(L, -1); /* function to be called */
        lua_pushvalue(L, i); /* value to print */
        lua_call(L, 1, 1);
        s = lua_tolstring(L, -1, &l); /* get result */
        if (s == NULL) {
            return luaL_error(L, "'tostring' must return a string to 'print'");
        }
        if (i > 1) {
            luaL_writestring("\t", 1);
        }
        luaL_writestring(s, l);
        lua_pop(L, 1); /* pop result */
    }
    luaL_writeline();
    return 0;
}

static int luaB_tonumber (lua_State *L) {
    int base = luaL_optint(L, 2, 10);
    if (base == 10) { /* standard conversion */
        luaL_checkany(L, 1);
        if (lua_isnumber(L, 1)) {
            lua_pushnumber(L, lua_tonumber(L, 1));
            return 1;
        }
    } else {
        const char *s1 = luaL_checkstring(L, 1);
        char *s2;
        unsigned long n;
        luaL_argcheck(L, 2 <= base && base <= 36, 2, "base out of range");
        n = strtoul(s1, &s2, base);
        if (s1 != s2) { /* at least one valid digit? */
            while (isspace((unsigned char) (*s2))) {
                s2++; /* skip trailing spaces */
            }
            if (*s2 == '\0') { /* no invalid trailing characters? */
                lua_pushnumber(L, (lua_Number) n);
                return 1;
            }
        }
    }
    lua_pushnil(L); /* else not a number */
    return 1;
}

static int luaB_error (lua_State *L) {
    int level = luaL_optint(L, 2, 1);
    lua_settop(L, 1);
    if (lua_isstring(L, 1) && level > 0) { /* add extra information? */
        luaL_where(L, level);
        lua_pushvalue(L, 1);
        lua_concat(L, 2);
    }
    return lua_error(L);
}

static int luaB_getmetatable (lua_State *L) {
    luaL_checkany(L, 1);
    if (!lua_getmetatable(L, 1)) {
        lua_pushnil(L);
        return 1; /* no metatable */
    }
    luaL_getmetafield(L, 1, "__metatable");
    return 1; /* returns either __metatable field (if present) or metatable */
}

static int luaB_setmetatable (lua_State *L) {
    int t = lua_type(L, 2);
    luaL_checktype(L, 1, LUA_TTABLE);
    luaL_argcheck(L, t == LUA_TNIL || t == LUA_TTABLE, 2, "nil or table expected");
    if (luaL_getmetafield(L, 1, "__metatable")) {
        luaL_error(L, "cannot change a protected metatable");
    }
    lua_settop(L, 2);
    lua_setmetatable(L, 1);
    return 1;
}

static void getfunc (lua_State *L, int opt) {
    if (lua_isfunction(L, 1)) {
        lua_pushvalue(L, 1);
    } else {
        lua_Debug ar;
        int level = opt ? luaL_optint(L, 1, 1) : luaL_checkint(L, 1);
        luaL_argcheck(L, level >= 0, 1, "level must be non-negative");
        if (lua_getstack(L, level, &ar) == 0) {
            luaL_argerror(L, 1, "invalid level");
        }
        lua_getinfo(L, "f", &ar);
        if (lua_isnil(L, -1)) {
            luaL_error(L, "no function environment for tail call at level %d", level);
        }
    }
}

static int luaB_getfenv (lua_State *L) {
    if (!lua_getcompatopt(L, LUA_COMPATGCDEBUG) && !lua_ishookallowed(L)) {
        return 0; /* getfenv calls not allowed in '__gc' execution. */
    }

    getfunc(L, 1);
    if (lua_iscfunction(L, -1)) { /* is a C function? */
        lua_pushvalue(L, LUA_GLOBALSINDEX); /* return the thread's global env. */
    } else {
        lua_getfenv(L, -1);
    }

    if (luaL_getmetafield(L, -1, "__environment") == 0) {
        lua_taintstack(L, lua_getobjecttaint(L, -2));
    }

    return 1;
}

static int luaB_setfenv (lua_State *L) {
    luaL_checktype(L, 2, LUA_TTABLE);
    getfunc(L, 0);

    if (!lua_getcompatopt(L, LUA_COMPATSETFENV)) {
        lua_getfenv(L, -1);

        if (luaL_getmetafield(L, -1, "__environment")) {
            luaL_error(L, "cannot change a protected environment");
        } else {
            lua_pop(L, 1); /* pop fenv */
        }
    }

    lua_taintobject(L, -1);
    lua_pushvalue(L, 2);
    if (lua_isnumber(L, 1) && lua_tonumber(L, 1) == 0) {
        /* change environment of current thread */
        lua_pushthread(L);
        lua_insert(L, -2);
        lua_setfenv(L, -2);
        return 0;
    } else if (lua_iscfunction(L, -2) || lua_setfenv(L, -2) == 0) {
        luaL_error(L, "'setfenv' cannot change environment of given object");
    }
    return 1;
}

static int luaB_rawequal (lua_State *L) {
    luaL_checkany(L, 1);
    luaL_checkany(L, 2);
    lua_pushboolean(L, lua_rawequal(L, 1, 2));
    return 1;
}

static int luaB_rawget (lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    luaL_checkany(L, 2);
    lua_settop(L, 2);
    lua_rawget(L, 1);
    return 1;
}

static int luaB_rawset (lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    luaL_checkany(L, 2);
    luaL_checkany(L, 3);
    lua_settop(L, 3);
    lua_rawset(L, 1);
    return 1;
}

static int luaB_gcinfo (lua_State *L) {
    lua_pushinteger(L, lua_getgccount(L));
    return 1;
}

static int luaB_collectgarbage (lua_State *L) {
    static const char *const opts[] = { "stop", "restart", "collect", "count", "step", "setpause", "setstepmul", NULL };
    static const int optsnum[] = { LUA_GCSTOP, LUA_GCRESTART,  LUA_GCCOLLECT,   LUA_GCCOUNT,
                                   LUA_GCSTEP, LUA_GCSETPAUSE, LUA_GCSETSTEPMUL };
    int o = luaL_checkoption(L, 1, "collect", opts);
    int ex = luaL_optint(L, 2, 0);
    int res = lua_gc(L, optsnum[o], ex);
    switch (optsnum[o]) {
        case LUA_GCCOUNT: {
            int b = lua_gc(L, LUA_GCCOUNTB, 0);
            lua_pushnumber(L, res + ((lua_Number) b / 1024));
            return 1;
        }
        case LUA_GCSTEP: {
            lua_pushboolean(L, res);
            return 1;
        }
        default: {
            lua_pushnumber(L, res);
            return 1;
        }
    }
}

static int luaB_type (lua_State *L) {
    luaL_checkany(L, 1);
    lua_pushstring(L, luaL_typename(L, 1));
    return 1;
}

static int luaB_next (lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    lua_settop(L, 2); /* create a 2nd argument if there isn't one */
    if (lua_next(L, 1)) {
        return 2;
    } else {
        lua_pushnil(L);
        return 1;
    }
}

static int luaB_pairs (lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    lua_pushvalue(L, lua_upvalueindex(1)); /* return generator, */
    lua_pushvalue(L, 1); /* state, */
    lua_pushnil(L); /* and initial value */
    return 3;
}

static int ipairsaux (lua_State *L) {
    int i = luaL_checkint(L, 2);
    luaL_checktype(L, 1, LUA_TTABLE);
    i++; /* next value */
    lua_pushinteger(L, i);
    lua_rawgeti(L, 1, i);
    return (lua_isnil(L, -1)) ? 0 : 2;
}

static int luaB_ipairs (lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    lua_pushvalue(L, lua_upvalueindex(1)); /* return generator, */
    lua_pushvalue(L, 1); /* state, */
    lua_pushinteger(L, 0); /* and initial value */
    return 3;
}

static int load_aux (lua_State *L, int status) {
    if (status == 0) { /* OK? */
        return 1;
    } else {
        lua_pushnil(L);
        lua_insert(L, -2); /* put before error message */
        return 2; /* return nil plus error message */
    }
}

static int luaB_loadstring (lua_State *L) {
    size_t l;
    const char *s = luaL_checklstring(L, 1, &l);
    const char *chunkname = luaL_optstring(L, 2, s);
    lua_setstacktaint(L, LUA_LOADSTRING_TAINT);
    return load_aux(L, luaL_loadbuffer(L, s, l, chunkname));
}

static int luaB_loadstringuntainted (lua_State *L) {
    size_t l;
    const char *s = luaL_checklstring(L, 1, &l);
    const char *chunkname = luaL_optstring(L, 2, s);
    return load_aux(L, luaL_loadbuffer(L, s, l, chunkname));
}

static int luaB_loadfile (lua_State *L) {
    const char *fname = luaL_optstring(L, 1, NULL);
    return load_aux(L, luaL_loadfile(L, fname));
}

/*
** Reader for generic `load' function: `lua_load' uses the
** stack for internal stuff, so the reader cannot change the
** stack top. Instead, it keeps its resulting string in a
** reserved slot inside the stack.
*/
static const char *generic_reader (lua_State *L, void *ud, size_t *size) {
    (void) ud; /* to avoid warnings */
    luaL_checkstack(L, 2, "too many nested functions");
    lua_pushvalue(L, 1); /* get function */
    lua_call(L, 0, 1); /* call it */
    if (lua_isnil(L, -1)) {
        *size = 0;
        return NULL;
    } else if (lua_isstring(L, -1)) {
        lua_replace(L, 3); /* save string in a reserved stack slot */
        return lua_tolstring(L, 3, size);
    } else {
        luaL_error(L, "reader function must return a string");
    }
    return NULL; /* to avoid warnings */
}

static int luaB_load (lua_State *L) {
    int status;
    const char *cname = luaL_optstring(L, 2, "=(load)");
    luaL_checktype(L, 1, LUA_TFUNCTION);
    lua_settop(L, 3); /* function, eventual name, plus one reserved slot */
    status = lua_load(L, generic_reader, NULL, cname);
    return load_aux(L, status);
}

static int luaB_dofile (lua_State *L) {
    const char *fname = luaL_optstring(L, 1, NULL);
    int n = lua_gettop(L);
    if (luaL_loadfile(L, fname) != 0) {
        lua_error(L);
    }
    lua_call(L, 0, LUA_MULTRET);
    return lua_gettop(L) - n;
}

static int luaB_assert (lua_State *L) {
    luaL_checkany(L, 1);
    if (!lua_toboolean(L, 1)) {
        return luaL_error(L, "%s", luaL_optstring(L, 2, "assertion failed!"));
    }
    return lua_gettop(L);
}

static int luaB_unpack (lua_State *L) {
    int i;
    int e;
    int n;
    luaL_checktype(L, 1, LUA_TTABLE);
    i = luaL_optint(L, 2, 1);
    e = luaL_opt(L, luaL_checkint, 3, (int) lua_objlen(L, 1));
    if (i > e) {
        return 0; /* empty range */
    }
    n = e - i + 1; /* number of elements */
    if (n <= 0 || !lua_checkstack(L, n)) { /* n <= 0 means arith. overflow */
        return luaL_error(L, "too many results to unpack");
    }
    lua_rawgeti(L, 1, i); /* push arg[i] (avoiding overflow problems) */
    while (i++ < e) { /* push arg[i + 1...e] */
        lua_rawgeti(L, 1, i);
    }
    return n;
}

static int luaB_select (lua_State *L) {
    int n = lua_gettop(L);
    if (lua_type(L, 1) == LUA_TSTRING && *lua_tostring(L, 1) == '#') {
        lua_pushinteger(L, n - 1);
        return 1;
    } else {
        int i = luaL_checkint(L, 1);
        if (i < 0) {
            i = n + i;
        } else if (i > n) {
            i = n;
        }
        luaL_argcheck(L, 1 <= i, 1, "index out of range");
        return n - i;
    }
}

static int luaB_pcall (lua_State *L) {
    int status;
    luaL_checkany(L, 1);
    status = lua_pcall(L, lua_gettop(L) - 1, LUA_MULTRET, 0);
    lua_pushboolean(L, (status == 0));
    lua_insert(L, 1);
    return lua_gettop(L); /* return status + all results */
}

static int luaB_pcallwithenv (lua_State *L) {
    int narg = lua_gettop(L) - 2;
    int nret;
    int status;

    if (!lua_isfunction(L, 1) || !lua_istable(L, 2)) {
        luaL_error(L, "Usage: local success, ... = pcallwithenv(f, env, [args...])");
    }

    /* Some stack trickery is needed here due to the argument order being
     * somewhat suboptimal.
     *
     * First we need to put a reference to the function before the arguments;
     * unfortunately this needs to be a copy + insert because we need a ref
     * to the function later to restore its environment which would otherwise
     * be consumed by the call.
     *
     * For environments we need to store the current environment; we do so
     * by pushing it onto the stack and swapping it with the desired
     * environment at stack index 2.
     *
     * The closure also needs to be tainted, but this is a bit less clear -
     * it's assumed for now that we need to attempt to taint it on both
     * swaps of the environment. */

    lua_pushvalue(L, 1); /* push copy of function... */
    lua_insert(L, 3); /* ...and insert it before the arguments */
    lua_pushvalue(L, 2); /* push copy of desired environment */
    lua_getfenv(L, 1); /* push existing function environment... */
    lua_replace(L, 2); /* ...and replace the desired one */

    if (luaL_getmetafield(L, 2, "__environment")) {
        luaL_error(L, "cannot use pcallwithenv on a function with a protected environment");
    }

    lua_taintobject(L, 1);
    lua_setfenv(L, 1); /* replace existing environment on the function */

    status = lua_pcall(L, narg, LUA_MULTRET, 0);
    lua_pushboolean(L, (status == 0));
    lua_insert(L, 3);
    nret = lua_gettop(L) - 2;

    lua_pushvalue(L, 2); /* push original environment... */
    lua_setfenv(L, 1); /* ...and restore it onto the function */
    lua_taintobject(L, 1);

    return nret;
}

static int luaB_xpcall (lua_State *L) {
    int status;
    int n = lua_gettop(L);
    luaL_checkany(L, 2);
    lua_pushvalue(L, 1); /* exchange function... */
    lua_copy(L, 2, 1); /* ...and error handler */
    lua_replace(L, 2);
    status = lua_pcall(L, n - 2, LUA_MULTRET, 1);
    lua_pushboolean(L, (status == 0));
    lua_replace(L, 1);
    return lua_gettop(L); /* return status + all results */
}

static int luaB_tostring (lua_State *L) {
    luaL_tolstring(L, 1, NULL);
    return 1;
}

static int luaB_newproxy (lua_State *L) {
    lua_settop(L, 1);
    lua_newuserdata(L, 0); /* create proxy */
    if (lua_toboolean(L, 1) == 0) {
        return 1; /* no metatable */
    } else if (lua_isboolean(L, 1)) {
        lua_newtable(L); /* create a new metatable `m' ... */
        lua_pushvalue(L, -1); /* ... and mark `m' as a valid metatable */
        lua_pushboolean(L, 1);
        lua_rawset(L, lua_upvalueindex(1)); /* weaktable[m] = true */
    } else {
        int validproxy = 0; /* to check if weaktable[metatable(u)] == true */
        if (lua_getmetatable(L, 1)) {
            lua_rawget(L, lua_upvalueindex(1));
            validproxy = lua_toboolean(L, -1);
            lua_pop(L, 1); /* remove value */
        }
        luaL_argcheck(L, validproxy, 1, "boolean or proxy expected");
        lua_getmetatable(L, 1); /* metatable is valid; get it */
    }
    lua_setmetatable(L, 2);
    return 1;
}

static int luaB_forceinsecure (lua_State *L) {
    luaL_forceinsecure(L);
    return 0;
}

static int luaB_issecure (lua_State *L) {
    lua_settop(L, 0);
    lua_pushboolean(L, luaL_issecure(L));
    return 1;
}

static int luaB_issecurevariable (lua_State *L) {
    if (lua_tostring(L, 1)) {
        lua_pushvalue(L, LUA_GLOBALSINDEX);
        lua_insert(L, 1);
    }

    if (!lua_istable(L, 1) || !lua_tostring(L, 2)) {
        return luaL_error(L, "Usage: issecurevariable([table,] \"variable\")");
    }

    lua_settop(L, 2);
    const char *taint = luaL_gettabletaint(L, 1);

    if (taint) {
        lua_pushboolean(L, 0);
        lua_pushstring(L, taint);
    } else {
        lua_pushboolean(L, 1);
        lua_pushnil(L);
    }

    return 2;
}

static int luaB_securecall (lua_State *L) {
    lua_TaintState savedts;
    int status;

    lua_savetaint(L, &savedts);

    /* If the supplied function is a string then look up the function in _G. */
    if (lua_tostring(L, 1)) {
        lua_pushvalue(L, 1);
        lua_rawget(L, LUA_GLOBALSINDEX);
        lua_replace(L, 1);
    }

    status = lua_pcall(L, (lua_gettop(L) - 1), LUA_MULTRET, LUA_ERRORHANDLERINDEX);
    if (status != 0) {
        lua_pop(L, 1);
    }
    lua_restoretaint(L, &savedts);
    lua_settoptaint(L, lua_gettop(L), lua_getstacktaint(L));

    return lua_gettop(L);
}

static int luaB_securecallfunction (lua_State *L) {
    luaL_securecall(L, (lua_gettop(L) - 1), LUA_MULTRET, LUA_ERRORHANDLERINDEX);
    return lua_gettop(L);
}

static int luaB_secureexecuterange (lua_State *L) {
    int nargs = lua_gettop(L) - 2;
    luaL_checktype(L, 1, LUA_TTABLE);
    luaL_checktype(L, 2, LUA_TFUNCTION);
    luaL_secureforeach(L, 1, nargs, 0);
    return 0;
}

static int luaB_geterrorhandler (lua_State *L) {
    lua_pushvalue(L, LUA_ERRORHANDLERINDEX);
    lua_getfenv(L, -1);
    if (luaL_getmetafield(L, -1, "__environment") == 0) {
        lua_settop(L, 1);
    }
    return 1;
}

static const char *f_errorobjname (lua_State *L, int level) {
    const char *name = NULL;
    int base = lua_gettop(L);
    lua_Debug ar;

    if (lua_getstack(L, level, &ar) == 0) {
        goto exit;
    } else if (lua_getinfo(L, "S", &ar) == 0 || *ar.source != '*') {
        goto exit;
    } else if (lua_getlocal(L, &ar, 1) == NULL) {
        goto exit;
    } else if (lua_type(L, -1) != LUA_TTABLE) {
        goto exit;
    }

    lua_rawgeti(L, -1, 0);

    if (!lua_isuserdata(L, -1) || !luaL_callmeta(L, -1, "__name")) {
        goto exit;
    }

    if (!lua_isstring(L, -1)) {
        lua_pushliteral(L, "<unnamed>");
    }

    lua_replace(L, base + 1);
    name = lua_tostring(L, base + 1);

exit:
    lua_settop(L, base + (name ? 1 : 0));
    return name;
}

static int f_errorhandler (lua_State *L) {
    if (!lua_isstring(L, 1)) {
        lua_pushliteral(L, "UNKNOWN ERROR");
        lua_replace(L, 1);
    }

    {
        /* The reference error handler has special support for an "*:" token
         * in error messages that originate from script handlers.
         *
         * When printing a stack trace that involves a UI widget script handler
         * the "source" of the function for the script handler if defined in
         * XML will be the string "*"; this shows up in the stack trace as
         * showing calls such as "*:OnMouseDown".
         *
         * When an error occurs within the immediate body of the function the
         * client will replace the asterisk with the name of the frame object
         * found in the first local value of that stack frame.
         *
         * In a pure Lua scenario this can be replicated by making use of
         * custom chunk names with loadstring; load a chunk with "*:" in its
         * name and ensure its first local value is a frame and then trigger
         * an immediate error (without calling the C "error" function). */

        const char *err = lua_tolstring(L, -1, NULL);
        const char *match = strstr(err, "*:");
        const char *name;

        if (match && (name = f_errorobjname(L, 1)) != NULL) {
            lua_pushlstring(L, err, (match - err)); /* before asterisk */
            lua_pushstring(L, name);
            lua_pushstring(L, match + 1); /* after asterisk */
            lua_concat(L, 3);
            lua_replace(L, 1);
        }
    }

    if (!lua_getcompatopt(L, LUA_COMPATINERRORHANDLER)) {
        lua_pushboolean(L, 1);
        lua_rawseti(L, LUA_REGISTRYINDEX, LUA_RIDX_INERRORHANDLER);
    }

    lua_settop(L, 1);
    lua_pushvalue(L, lua_upvalueindex(1));
    lua_insert(L, 1);
    lua_call(L, 1, 1);

    if (!lua_getcompatopt(L, LUA_COMPATINERRORHANDLER)) {
        lua_pushboolean(L, 0);
        lua_rawseti(L, LUA_REGISTRYINDEX, LUA_RIDX_INERRORHANDLER);
    }

    return 1;
}

static int luaB_seterrorhandler (lua_State *L) {
    if (!lua_isfunction(L, 1)) {
        return luaL_error(L, "Usage: seterrorhandler(errfunc)");
    }

    lua_settop(L, 1);

    /* Create an environment table that references the supplied function. */
    lua_createtable(L, 0, 0);
    lua_createtable(L, 0, 1);
    lua_pushvalue(L, 1);
    lua_setfield(L, 3, "__environment");
    lua_setmetatable(L, 2);
    lua_insert(L, 1);

    /* Bind the error handler proxy and set its environment. */
    lua_pushcclosure(L, f_errorhandler, 1);
    lua_insert(L, 1);
    lua_setfenv(L, 1);
    lua_replace(L, LUA_ERRORHANDLERINDEX);
    return 0;
}

static void aux_getorigfunc_untainted (lua_State *L, void *ud) {
    lua_unused(ud);
    lua_setstacktaint(L, NULL);
    lua_gettable(L, 1);
}

static int luaB_hooksecurefunc (lua_State *L) {
    lua_TaintState entryts;
    lua_TaintState savedts;

    if (!lua_istable(L, 1)) {
        lua_pushvalue(L, LUA_GLOBALSINDEX);
        lua_insert(L, 1);
    }

    if (!lua_tostring(L, 2) || !lua_isfunction(L, 3)) {
        return luaL_error(L, "Usage: hooksecurefunc([table,] \"function\", hookfunc)");
    }

    lua_settop(L, 3);
    lua_savetaint(L, &entryts); /* save initial entry taint */
    lua_pushvalue(L, 2); /* [4] = "function" */
    lua_protecttaint(L, aux_getorigfunc_untainted, NULL); /* [4] = origfunc */
    lua_savetaint(L, &savedts); /* save lookup taint */
    lua_restoretaint(L, &entryts); /* restore initial entry taint in case of error */

    if (!lua_isfunction(L, 4)) {
        return luaL_error(L, "hooksecurefunc(): %s is not a function", lua_tostring(L, 2));
    }

    lua_insert(L, 3); /* [3] = origfunc, [4] = hookfunc */
    lua_setvaluetaint(L, 3, savedts.stacktaint); /* origfunc should have lookup taint */
    lua_setvaluetaint(L, 4, entryts.stacktaint); /* hookfunc should have entry taint */
    lua_restoretaint(L, &entryts); /* restore initial entry taint again */
    luaL_createsecurehook(L); /* [3] = securehook */
    lua_setvaluetaint(L, 3, NULL);
    lua_rawset(L, 1); /* table["function"] = securehook */

    return 0;
}

static int luaB_scrub (lua_State *L) {
    const int argc = lua_gettop(L);
    int argi;
    int type;

    for (argi = 1; argi <= argc; ++argi) {
        type = lua_type(L, argi);

        if (type != LUA_TNUMBER && type != LUA_TSTRING && type != LUA_TBOOLEAN) {
            lua_pushnil(L);
            lua_replace(L, argi);
        }
    }

    return argc;
}

/**
 * Base library registration
 */

static const luaL_Reg baselib_shared[] = {
    { "assert", luaB_assert },
    { "collectgarbage", luaB_collectgarbage },
    { "error", luaB_error },
    { "forceinsecure", luaB_forceinsecure },
    { "gcinfo", luaB_gcinfo },
    { "geterrorhandler", luaB_geterrorhandler },
    { "getfenv", luaB_getfenv },
    { "getmetatable", luaB_getmetatable },
    { "hooksecurefunc", luaB_hooksecurefunc },
    { "issecure", luaB_issecure },
    { "issecurevariable", luaB_issecurevariable },
    { "loadstring_untainted", luaB_loadstringuntainted },
    { "next", luaB_next },
    { "pcall", luaB_pcall },
    { "pcallwithenv", luaB_pcallwithenv },
    { "print", luaB_print },
    { "rawequal", luaB_rawequal },
    { "rawget", luaB_rawget },
    { "rawset", luaB_rawset },
    { "scrub", luaB_scrub },
    { "securecall", luaB_securecall },
    { "securecallfunction", luaB_securecallfunction },
    { "secureexecuterange", luaB_secureexecuterange },
    { "select", luaB_select },
    { "seterrorhandler", luaB_seterrorhandler },
    { "setfenv", luaB_setfenv },
    { "setmetatable", luaB_setmetatable },
    { "tonumber", luaB_tonumber },
    { "tostring", luaB_tostring },
    { "type", luaB_type },
    { "unpack", luaB_unpack },
    { "xpcall", luaB_xpcall },
    /* clang-format off */
    { NULL, NULL },
    /* clang-format on */
};

static const luaL_Reg baselib_lua[] = {
    { "dofile", luaB_dofile },
    { "load", luaB_load },
    { "loadfile", luaB_loadfile },
    { "loadstring", luaB_loadstringuntainted },
    /* clang-format off */
    { NULL, NULL },
    /* clang-format on */
};

static const luaL_Reg baselib_elune[] = {
    { "loadstring", luaB_loadstring },
    /* clang-format off */
    { NULL, NULL },
    /* clang-format on */
};

static void baselib_openshared (lua_State *L) {
    /* register shared functions */
    luaL_setfuncs(L, baselib_shared, 0);

    /* register `_VERSION' field */
    lua_pushliteral(L, LUA_VERSION);
    lua_setglobal(L, "_VERSION");

    /* `ipairs' and `pairs' need auxiliary functions as upvalues */
    lua_pushcclosure(L, ipairsaux, 0);
    lua_pushcclosure(L, luaB_ipairs, 1);
    lua_setfield(L, -2, "ipairs");

    lua_pushcclosure(L, luaB_next, 0);
    lua_pushcclosure(L, luaB_pairs, 1);
    lua_setfield(L, -2, "pairs");

    /* `newproxy' needs a weaktable as upvalue */
    lua_createtable(L, 0, 1); /* new table `w' */
    lua_pushvalue(L, -1); /* `w' will be its own metatable */
    lua_setmetatable(L, -2);
    lua_pushliteral(L, "kv");
    lua_setfield(L, -2, "__mode"); /* metatable(w).__mode = "kv" */
    lua_pushcclosure(L, luaB_newproxy, 1);
    lua_setglobal(L, "newproxy"); /* set global `newproxy' */
}

LUALIB_API int luaopen_base (lua_State *L) {
    /* set global '_G' */
    lua_pushvalue(L, LUA_GLOBALSINDEX);
    lua_setfield(L, LUA_GLOBALSINDEX, LUA_BASELIBNAME);

    /* register '_G' base library */
    luaL_register(L, LUA_BASELIBNAME, baselib_lua);
    baselib_openshared(L);

    /* open coroutine library for backwards compatibility */
    luaopen_coroutine(L);

    return 2;
}

LUALIB_API int luaopen_elune_base (lua_State *L) {
    /* set field '_G' */
    lua_pushvalue(L, LUA_ENVIRONINDEX);
    lua_pushvalue(L, -1);
    lua_setfield(L, -2, LUA_BASELIBNAME);

    /* register '_G' base library */
    luaL_setfuncs(L, baselib_elune, 0);
    baselib_openshared(L);

    return 1;
}
