/* Licensed under the terms of the MIT License; see full copyright information
 * in the "LICENSE" file or at <http://www.lua.org/license.html> */

#include <stddef.h>

#define ltablib_c
#define LUA_LIB

#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

#define aux_getn(L, n) (luaL_checktype(L, n, LUA_TTABLE), ((int) lua_objlen(L, n)))

static int table_foreachi (lua_State *L) {
    int i;
    int n = aux_getn(L, 1);
    luaL_checktype(L, 2, LUA_TFUNCTION);
    for (i = 1; i <= n; i++) {
        lua_pushvalue(L, 2); /* function */
        lua_pushinteger(L, i); /* 1st argument */
        lua_rawgeti(L, 1, i); /* 2nd argument */
        lua_call(L, 2, 1);
        if (!lua_isnil(L, -1)) {
            return 1;
        }
        lua_pop(L, 1); /* remove nil result */
    }
    return 0;
}

static int table_foreach (lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    luaL_checktype(L, 2, LUA_TFUNCTION);
    lua_pushnil(L); /* first key */
    while (lua_next(L, 1)) {
        lua_pushvalue(L, 2); /* function */
        lua_pushvalue(L, -3); /* key */
        lua_pushvalue(L, -3); /* value */
        lua_call(L, 2, 1);
        if (!lua_isnil(L, -1)) {
            return 1;
        }
        lua_pop(L, 2); /* remove value and result */
    }
    return 0;
}

static int table_maxn (lua_State *L) {
    lua_Number max = 0;
    luaL_checktype(L, 1, LUA_TTABLE);
    lua_pushnil(L); /* first key */
    while (lua_next(L, 1)) {
        lua_pop(L, 1); /* remove value */
        if (lua_type(L, -1) == LUA_TNUMBER) {
            lua_Number v = lua_tonumber(L, -1);
            if (v > max) {
                max = v;
            }
        }
    }
    lua_pushnumber(L, max);
    return 1;
}

static int table_getn (lua_State *L) {
    lua_pushinteger(L, aux_getn(L, 1));
    return 1;
}

static int table_setn (lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    return luaL_error(L, "'setn' is obsolete");
}

static int table_insert (lua_State *L) {
    int e = aux_getn(L, 1) + 1; /* first empty element */
    int pos; /* where to insert new element */
    switch (lua_gettop(L)) {
        case 2: { /* called with only 2 arguments */
            pos = e; /* insert new element at the end */
            break;
        }
        case 3: {
            int i;
            pos = luaL_checkint(L, 2); /* 2nd argument is the position */
            if (pos > e) {
                e = pos; /* `grow' array if necessary */
            }
            for (i = e; i > pos; i--) { /* move up elements */
                lua_rawgeti(L, 1, i - 1);
                lua_rawseti(L, 1, i); /* t[i] = t[i-1] */
            }
            break;
        }
        default: {
            return luaL_error(L, "wrong number of arguments to 'insert'");
        }
    }
    lua_rawseti(L, 1, pos); /* t[pos] = v */
    return 0;
}

static int table_remove (lua_State *L) {
    int e = aux_getn(L, 1);
    int pos = luaL_optint(L, 2, e);
    if (!(1 <= pos && pos <= e)) { /* position is outside bounds? */
        return 0; /* nothing to remove */
    }
    lua_rawgeti(L, 1, pos); /* result = t[pos] */
    for (; pos < e; pos++) {
        lua_rawgeti(L, 1, pos + 1);
        lua_rawseti(L, 1, pos); /* t[pos] = t[pos+1] */
    }
    lua_pushnil(L);
    lua_rawseti(L, 1, e); /* t[e] = nil */
    return 1;
}

static void addfield (lua_State *L, luaL_Buffer *b, int i) {
    lua_rawgeti(L, 1, i);
    if (!lua_isstring(L, -1)) {
        luaL_error(L, "invalid value (%s) at index %d in table for 'concat'", luaL_typename(L, -1), i);
    }
    luaL_addvalue(b);
}

static int table_concat (lua_State *L) {
    luaL_Buffer b;
    size_t lsep;
    int i;
    int last;
    const char *sep = luaL_optlstring(L, 2, "", &lsep);
    luaL_checktype(L, 1, LUA_TTABLE);
    i = luaL_optint(L, 3, 1);
    last = luaL_opt(L, luaL_checkint, 4, (int) lua_objlen(L, 1));
    luaL_buffinit(L, &b);
    for (; i < last; i++) {
        addfield(L, &b, i);
        luaL_addlstring(&b, sep, lsep);
    }
    if (i == last) { /* add last value (if interval was not empty) */
        addfield(L, &b, i);
    }
    luaL_pushresult(&b);
    return 1;
}

/*
** {======================================================
** Quicksort
** (based on `Algorithms in MODULA-3', Robert Sedgewick;
**  Addison-Wesley, 1993.)
*/

static void set2 (lua_State *L, int i, int j) {
    lua_rawseti(L, 1, i);
    lua_rawseti(L, 1, j);
}

static int sort_comp (lua_State *L, int a, int b) {
    if (!lua_isnil(L, 2)) { /* function? */
        int res;
        lua_pushvalue(L, 2);
        lua_pushvalue(L, a - 1); /* -1 to compensate function */
        lua_pushvalue(L, b - 2); /* -2 to compensate function and `a' */
        lua_call(L, 2, 1);
        res = lua_toboolean(L, -1);
        lua_pop(L, 1);
        return res;
    } else { /* a < b? */
        return lua_lessthan(L, a, b);
    }
}

static void auxsort (lua_State *L, int l, int u) {
    while (l < u) { /* for tail recursion */
        int i;
        int j;
        /* sort elements a[l], a[(l+u)/2] and a[u] */
        lua_rawgeti(L, 1, l);
        lua_rawgeti(L, 1, u);
        if (sort_comp(L, -1, -2)) { /* a[u] < a[l]? */
            set2(L, l, u); /* swap a[l] - a[u] */
        } else {
            lua_pop(L, 2);
        }
        if (u - l == 1) {
            break; /* only 2 elements */
        }
        i = (l + u) / 2;
        lua_rawgeti(L, 1, i);
        lua_rawgeti(L, 1, l);
        if (sort_comp(L, -2, -1)) { /* a[i]<a[l]? */
            set2(L, i, l);
        } else {
            lua_pop(L, 1); /* remove a[l] */
            lua_rawgeti(L, 1, u);
            if (sort_comp(L, -1, -2)) { /* a[u]<a[i]? */
                set2(L, i, u);
            } else {
                lua_pop(L, 2);
            }
        }
        if (u - l == 2) {
            break; /* only 3 elements */
        }
        lua_rawgeti(L, 1, i); /* Pivot */
        lua_pushvalue(L, -1);
        lua_rawgeti(L, 1, u - 1);
        set2(L, i, u - 1);
        /* a[l] <= P == a[u-1] <= a[u], only need to sort from l+1 to u-2 */
        i = l;
        j = u - 1;
        for (;;) { /* invariant: a[l..i] <= P <= a[j..u] */
            /* repeat ++i until a[i] >= P */
            while (lua_rawgeti(L, 1, ++i), sort_comp(L, -1, -2)) {
                if (i > u) {
                    luaL_error(L, "invalid order function for sorting");
                }
                lua_pop(L, 1); /* remove a[i] */
            }
            /* repeat --j until a[j] <= P */
            while (lua_rawgeti(L, 1, --j), sort_comp(L, -3, -1)) {
                if (j < l) {
                    luaL_error(L, "invalid order function for sorting");
                }
                lua_pop(L, 1); /* remove a[j] */
            }
            if (j < i) {
                lua_pop(L, 3); /* pop pivot, a[i], a[j] */
                break;
            }
            set2(L, i, j);
        }
        lua_rawgeti(L, 1, u - 1);
        lua_rawgeti(L, 1, i);
        set2(L, u - 1, i); /* swap pivot (a[u-1]) with a[i] */
        /* a[l..i-1] <= a[i] == P <= a[i+1..u] */
        /* adjust so that smaller half is in [j..i] and larger one in [l..u] */
        if (i - l < u - i) {
            j = l;
            i = i - 1;
            l = i + 2;
        } else {
            j = i + 1;
            i = u;
            u = j - 2;
        }
        auxsort(L, j, i); /* call recursively the smaller one */
    } /* repeat the routine for the larger one */
}

static int table_sort (lua_State *L) {
    int n = aux_getn(L, 1);
    luaL_checkstack(L, 40, ""); /* assume array is smaller than 2^40 */
    if (!lua_isnoneornil(L, 2)) { /* is there a 2nd argument? */
        luaL_checktype(L, 2, LUA_TFUNCTION);
    }
    lua_settop(L, 2); /* make sure there is two arguments */
    auxsort(L, 1, n);
    return 0;
}

static int table_wipe (lua_State *L) {
    lua_settop(L, 1);
    luaL_checktype(L, 1, LUA_TTABLE);

    lua_pushnil(L); /* initial key for iteration */

    while (lua_next(L, 1) != 0) {
        lua_pop(L, 1);
        lua_pushvalue(L, -1);
        lua_pushnil(L);
        lua_settable(L, 1);
    }

    return 1;
}

static int table_removemulti (lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);

    const int length = (int) lua_objlen(L, 1);
    const int index = luaL_optint(L, 2, length);
    const int count = luaL_optint(L, 3, 1);

    if (length == 0) {
        return 0; /* Accurate to reference. ¯\_(ツ)_/¯ */
    } else if (index <= 0 || count < 0 || (index + count - 1) > length) {
        return luaL_error(L, "parameters out of bounds");
    }

    lua_settop(L, 1); /* Keep the table as the only thing on the stack. */

    for (int dsti = index; dsti <= length; ++dsti) {
        const int srci = dsti + count;

        if (dsti <= (index + count - 1)) {
            /* We're removing this, so push onto the stack to return it. */
            lua_rawgeti(L, 1, dsti);
        }

        if (srci <= length) {
            lua_rawgeti(L, 1, srci);
        } else {
            lua_pushnil(L);
        }

        lua_rawseti(L, 1, dsti);
    }

    return count;
}

/**
 * Table library registration
 */

static const luaL_Reg tablib_shared[] = {
    { "concat", table_concat },
    { "foreach", table_foreach },
    { "foreachi", table_foreachi },
    { "getn", table_getn },
    { "maxn", table_maxn },
    { "insert", table_insert },
    { "remove", table_remove },
    { "removemulti", table_removemulti },
    { "setn", table_setn },
    { "sort", table_sort },
    { "wipe", table_wipe },
    /* clang-format off */
    { NULL, NULL },
    /* clang-format on */
};

LUALIB_API int luaopen_table (lua_State *L) {
    luaL_register(L, LUA_TABLIBNAME, tablib_shared);
    return 1;
}

LUALIB_API int luaopen_elune_table (lua_State *L) {
    luaL_getsubtable(L, LUA_ENVIRONINDEX, LUA_TABLIBNAME);
    luaL_setfuncs(L, tablib_shared, 0);
    return 1;
}
