/* Licensed under the terms of the MIT License; see full copyright information
 * in the "LICENSE" file or at <http://www.lua.org/license.html> */

#define lcorolib_c
#define LUA_LIB

#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

enum lua_CoroutineStatus {
    CO_RUN = 0, /* running */
    CO_SUS = 1, /* suspended */
    CO_NOR = 2, /* 'normal' (it resumed another coroutine) */
    CO_DEAD = 3,
};

static const char *const statnames[] = {
    "running",
    "suspended",
    "normal",
    "dead",
};

static int auxstatus (lua_State *L, lua_State *co) {
    if (L == co) {
        return CO_RUN;
    }
    switch (lua_status(co)) {
        case LUA_YIELD:
            return CO_SUS;
        case 0: {
            lua_Debug ar;
            if (lua_getstack(co, 0, &ar) > 0) { /* does it have frames? */
                return CO_NOR; /* it is running */
            } else if (lua_gettop(co) == 0) {
                return CO_DEAD;
            } else {
                return CO_SUS; /* initial state */
            }
        }
        default: /* some error occured */
            return CO_DEAD;
    }
}

static int luaB_costatus (lua_State *L) {
    lua_State *co = lua_tothread(L, 1);
    luaL_argcheck(L, co, 1, "coroutine expected");
    lua_pushstring(L, statnames[auxstatus(L, co)]);
    return 1;
}

static int auxresume (lua_State *L, lua_State *co, int narg) {
    int status = auxstatus(L, co);
    if (!lua_checkstack(co, narg)) {
        luaL_error(L, "too many arguments to resume");
    }
    if (status != CO_SUS) {
        lua_pushfstring(L, "cannot resume %s coroutine", statnames[status]);
        return -1; /* error flag */
    }
    lua_xmove(L, co, narg);
    status = lua_resumefrom(co, L, narg);
    if (status == 0 || status == LUA_YIELD) {
        int nres = lua_gettop(co);
        if (!lua_checkstack(L, nres + 1)) {
            luaL_error(L, "too many results to resume");
        }
        lua_xmove(co, L, nres); /* move yielded values */
        return nres;
    } else {
        lua_xmove(co, L, 1); /* move error message */
        return -1; /* error flag */
    }
}

static int luaB_coresume (lua_State *L) {
    lua_State *co = lua_tothread(L, 1);
    int r;
    luaL_argcheck(L, co, 1, "coroutine expected");
    r = auxresume(L, co, lua_gettop(L) - 1);
    if (r < 0) {
        lua_pushboolean(L, 0);
        lua_insert(L, -2);
        return 2; /* return false + error message */
    } else {
        lua_pushboolean(L, 1);
        lua_insert(L, -(r + 1));
        return r + 1; /* return true + `resume' returns */
    }
}

static int luaB_cocreate (lua_State *L) {
    lua_State *L1 = lua_newthread(L);
    luaL_argcheck(L, lua_isfunction(L, 1) && !lua_iscfunction(L, 1), 1, "Lua function expected");
    lua_pushvalue(L, 1); /* move function to top */
    lua_xmove(L, L1, 1); /* move function from L to L1 */
    return 1;
}

static int auxwrap (lua_State *L) {
    lua_State *co = lua_tothread(L, lua_upvalueindex(1));
    int r = auxresume(L, co, lua_gettop(L));
    if (r < 0) {
        if (lua_isstring(L, -1)) { /* error object is a string? */
            luaL_where(L, 1); /* add extra info */
            lua_insert(L, -2);
            lua_concat(L, 2);
        }
        lua_error(L); /* propagate error */
    }
    return r;
}

static int luaB_cowrap (lua_State *L) {
    luaB_cocreate(L);
    lua_pushcclosure(L, auxwrap, 1);
    return 1;
}

static int luaB_coyield (lua_State *L) {
    return lua_yield(L, lua_gettop(L));
}

static int luaB_corunning (lua_State *L) {
    if (lua_pushthread(L)) {
        lua_pushnil(L); /* main thread is not a coroutine */
    }
    return 1;
}

static int luaB_comainthread (lua_State *L) {
    lua_rawgeti(L, LUA_REGISTRYINDEX, LUA_RIDX_MAINTHREAD);
    return 1;
}

static int aux_cocall (lua_State *from, lua_State *to, int nargs) {
    int base;
    int status;
    int nresults;

    if (from != to) {
        lua_checkstack(to, (nargs + 1));
        lua_copytaint(from, to);
        lua_xmove(from, to, (nargs + 1));
    }

    base = lua_absindex(to, -(nargs + 1));
    status = lua_pcall(to, nargs, LUA_MULTRET, 0);
    nresults = (lua_gettop(to) - (base - 1));

    if (from != to) {
        lua_copytaint(to, from);
        lua_checkstack(from, nresults);
        lua_xmove(to, from, nresults);
    }

    if (status != 0) {
        lua_error(from);
    }

    return nresults;
}

static int luaB_cocall (lua_State *L) {
    lua_State *L1 = luaL_checkthread(L, 1);
    luaL_checkany(L, 2);
    return aux_cocall(L, L1, (lua_gettop(L) - 2));
}

static int aux_cobind (lua_State *L) {
    lua_State *L1 = lua_tothread(L, lua_upvalueindex(1));
    lua_checkstack(L, 1);
    lua_pushvalue(L, lua_upvalueindex(2));
    lua_insert(L, 1);
    return aux_cocall(L, L1, (lua_gettop(L) - 1));
}

static int luaB_cobind (lua_State *L) {
    luaL_checkthread(L, 1);
    luaL_checkany(L, 2);
    lua_settop(L, 2);
    lua_pushcclosure(L, &aux_cobind, 2);
    return 1;
}

/**
 * Coroutine library registration
 */

static const luaL_Reg corolib_shared[] = {
    { "create", luaB_cocreate },
    { "resume", luaB_coresume },
    { "running", luaB_corunning },
    { "status", luaB_costatus },
    { "wrap", luaB_cowrap },
    { "yield", luaB_coyield },
    /* clang-format off */
    { NULL, NULL },
    /* clang-format on */
};

static const luaL_Reg corolib_lua[] = {
    { "bind", luaB_cobind },
    { "call", luaB_cocall },
    { "mainthread", luaB_comainthread },
    /* clang-format off */
    { NULL, NULL },
    /* clang-format on */
};

static const luaL_Reg corolib_elune[] = {
    /* clang-format off */
    { NULL, NULL },
    /* clang-format on */
};

LUALIB_API int luaopen_coroutine (lua_State *L) {
    luaL_register(L, LUA_COLIBNAME, corolib_lua);
    luaL_setfuncs(L, corolib_shared, 0);
    return 1;
}

LUALIB_API int luaopen_elune_coroutine (lua_State *L) {
    luaL_getsubtable(L, LUA_ENVIRONINDEX, LUA_COLIBNAME);
    luaL_setfuncs(L, corolib_elune, 0);
    luaL_setfuncs(L, corolib_shared, 0);
    return 1;
}
