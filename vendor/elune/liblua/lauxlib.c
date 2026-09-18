/* Licensed under the terms of the MIT License; see full copyright information
 * in the "LICENSE" file or at <http://www.lua.org/license.html> */

/* This file uses only the official API of Lua.
** Any function declared here could be written as an application function.
*/

#define lauxlib_c
#define LUA_LIB

#include "lauxlib.h"

#include "lua.h"

#include <ctype.h>
#include <errno.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if defined(LUA_USE_WINDOWS)
#include <windows.h>

#include <bcrypt.h>
#endif

#if defined(LUA_USE_LINUX)
#include <sys/random.h>
#endif

#define FREELIST_REF 0 /* free list of references */

/*
** {======================================================
** Error-report functions
** =======================================================
*/

LUALIB_API int luaL_argerror (lua_State *L, int narg, const char *extramsg) {
    lua_Debug ar;
    if (!lua_getstack(L, 0, &ar)) { /* no stack frame? */
        return luaL_error(L, "bad argument #%d (%s)", narg, extramsg);
    }
    lua_getinfo(L, "n", &ar);
    if (strcmp(ar.namewhat, "method") == 0) {
        narg--; /* do not count `self' */
        if (narg == 0) { /* error is in the self argument itself? */
            return luaL_error(L, "calling '%s' on bad self (%s)", ar.name, extramsg);
        }
    }
    if (ar.name == NULL) {
        ar.name = "?";
    }
    return luaL_error(L, "bad argument #%d to '%s' (%s)", narg, ar.name, extramsg);
}

LUALIB_API int luaL_typerror (lua_State *L, int narg, const char *tname) {
    const char *msg = lua_pushfstring(L, "%s expected, got %s", tname, luaL_typename(L, narg));
    return luaL_argerror(L, narg, msg);
}

static void tag_error (lua_State *L, int narg, int tag) {
    luaL_typerror(L, narg, lua_typename(L, tag));
}

LUALIB_API void luaL_where (lua_State *L, int level) {
    lua_Debug ar;
    if (lua_getstack(L, level, &ar)) { /* check function at level */
        lua_getinfo(L, "Sl", &ar); /* get info about it */
        if (ar.currentline > 0) { /* is there info? */
            lua_pushfstring(L, "%s:%d: ", ar.short_src, ar.currentline);
            return;
        }
    }
    lua_pushliteral(L, ""); /* else, no information available... */
}

LUALIB_API int luaL_error (lua_State *L, const char *fmt, ...) {
    va_list argp;
    va_start(argp, fmt);
    luaL_where(L, 1);
    lua_pushvfstring(L, fmt, argp);
    va_end(argp);
    lua_concat(L, 2);
    return lua_error(L);
}

/* }====================================================== */

LUALIB_API int luaL_checkoption (lua_State *L, int narg, const char *def, const char *const lst[]) {
    const char *name = (def) ? luaL_optstring(L, narg, def) : luaL_checkstring(L, narg);
    int i;
    for (i = 0; lst[i]; i++) {
        if (strcmp(lst[i], name) == 0) {
            return i;
        }
    }
    return luaL_argerror(L, narg, lua_pushfstring(L, "invalid option '%s'", name));
}

LUALIB_API int luaL_newmetatable (lua_State *L, const char *tname) {
    lua_getfield(L, LUA_REGISTRYINDEX, tname); /* get registry.name */
    if (!lua_isnil(L, -1)) { /* name already in use? */
        return 0; /* leave previous value on top, but return 0 */
    }
    lua_pop(L, 1);
    lua_newtable(L); /* create metatable */
    lua_pushvalue(L, -1);
    lua_setfield(L, LUA_REGISTRYINDEX, tname); /* registry.name = metatable */
    return 1;
}

LUALIB_API void *luaL_checkudata (lua_State *L, int ud, const char *tname) {
    void *p = lua_touserdata(L, ud);
    if (p != NULL) { /* value is a userdata? */
        if (lua_getmetatable(L, ud)) { /* does it have a metatable? */
            lua_getfield(L, LUA_REGISTRYINDEX, tname); /* get correct metatable */
            if (lua_rawequal(L, -1, -2)) { /* does it have the correct mt? */
                lua_pop(L, 2); /* remove both metatables */
                return p;
            }
        }
    }
    luaL_typerror(L, ud, tname); /* else error */
    return NULL; /* to avoid warnings */
}

LUALIB_API void luaL_checkstack (lua_State *L, int space, const char *mes) {
    if (!lua_checkstack(L, space)) {
        luaL_error(L, "stack overflow (%s)", mes);
    }
}

LUALIB_API void luaL_checktype (lua_State *L, int narg, int t) {
    if (lua_type(L, narg) != t) {
        tag_error(L, narg, t);
    }
}

LUALIB_API void luaL_checkany (lua_State *L, int narg) {
    if (lua_type(L, narg) == LUA_TNONE) {
        luaL_argerror(L, narg, "value expected");
    }
}

LUALIB_API const char *luaL_checklstring (lua_State *L, int narg, size_t *len) {
    const char *s = lua_tolstring(L, narg, len);
    if (!s) {
        tag_error(L, narg, LUA_TSTRING);
    }
    return s;
}

LUALIB_API const char *luaL_optlstring (lua_State *L, int narg, const char *def, size_t *len) {
    if (lua_isnoneornil(L, narg)) {
        if (len) {
            *len = (def ? strlen(def) : 0);
        }
        return def;
    } else {
        return luaL_checklstring(L, narg, len);
    }
}

LUALIB_API lua_Number luaL_checknumber (lua_State *L, int narg) {
    lua_Number d = lua_tonumber(L, narg);
    if (d == 0 && !lua_isnumber(L, narg)) { /* avoid extra test when d is not 0 */
        tag_error(L, narg, LUA_TNUMBER);
    }
    return d;
}

LUALIB_API lua_Number luaL_optnumber (lua_State *L, int narg, lua_Number def) {
    return luaL_opt(L, luaL_checknumber, narg, def);
}

LUALIB_API lua_Integer luaL_checkinteger (lua_State *L, int narg) {
    lua_Integer d = lua_tointeger(L, narg);
    if (d == 0 && !lua_isnumber(L, narg)) { /* avoid extra test when d is not 0 */
        tag_error(L, narg, LUA_TNUMBER);
    }
    return d;
}

LUALIB_API lua_Integer luaL_optinteger (lua_State *L, int narg, lua_Integer def) {
    return luaL_opt(L, luaL_checkinteger, narg, def);
}

LUALIB_API int luaL_getmetafield (lua_State *L, int obj, const char *event) {
    if (!lua_getmetatable(L, obj)) { /* no metatable? */
        return 0;
    }
    lua_pushstring(L, event);
    lua_rawget(L, -2);
    if (lua_isnil(L, -1)) {
        lua_pop(L, 2); /* remove metatable and metafield */
        return 0;
    } else {
        lua_remove(L, -2); /* remove only metatable */
        return 1;
    }
}

LUALIB_API int luaL_callmeta (lua_State *L, int obj, const char *event) {
    obj = lua_absindex(L, obj);
    if (!luaL_getmetafield(L, obj, event)) { /* no metafield? */
        return 0;
    }
    lua_pushvalue(L, obj);
    lua_call(L, 1, 1);
    return 1;
}

static int libsize (const luaL_Reg *l) {
    int size = 0;
    for (; l && l->name; l++) {
        size++;
    }
    return size;
}

LUALIB_API void luaL_pushmodule (lua_State *L, const char *modname, int sizehint) {
    luaL_findtable(L, LUA_REGISTRYINDEX, "_LOADED", 1); /* get _LOADED table */
    lua_getfield(L, -1, modname); /* get _LOADED[modname] */
    if (!lua_istable(L, -1)) { /* not found? */
        lua_pop(L, 1); /* remove previous result */
        /* try global variable (and create one if it does not exist) */
        if (luaL_findtable(L, LUA_GLOBALSINDEX, modname, sizehint) != NULL) {
            luaL_error(L, "name conflict for module " LUA_QS, modname);
        }
        lua_pushvalue(L, -1);
        lua_setfield(L, -3, modname); /* _LOADED[modname] = new table */
    }
    lua_remove(L, -2); /* remove _LOADED table */
}

LUALIB_API void luaL_openlib (lua_State *L, const char *libname, const luaL_Reg *l, int nup) {
    if (libname) {
        luaL_pushmodule(L, libname, libsize(l)); /* get/create library table */
        lua_insert(L, -(nup + 1)); /* move library table to below upvalues */
    }

    if (l) {
        luaL_setfuncs(L, l, nup);
    } else {
        lua_pop(L, nup); /* remove upvalues */
    }
}

LUALIB_API void luaL_register (lua_State *L, const char *libname, const luaL_Reg *l) {
    luaL_openlib(L, libname, l, 0);
}

LUALIB_API const char *luaL_gsub (lua_State *L, const char *s, const char *p, const char *r) {
    const char *wild;
    size_t l = strlen(p);
    luaL_Buffer b;
    luaL_buffinit(L, &b);
    while ((wild = strstr(s, p)) != NULL) {
        luaL_addlstring(&b, s, wild - s); /* push prefix */
        luaL_addstring(&b, r); /* push replacement in place of pattern */
        s = wild + l; /* continue after `p' */
    }
    luaL_addstring(&b, s); /* push last suffix */
    luaL_pushresult(&b);
    return lua_tostring(L, -1);
}

LUALIB_API const char *luaL_findtable (lua_State *L, int idx, const char *fname, int szhint) {
    const char *e;
    lua_pushvalue(L, idx);
    do {
        e = strchr(fname, '.');
        if (e == NULL) {
            e = fname + strlen(fname);
        }
        lua_pushlstring(L, fname, e - fname);
        lua_rawget(L, -2);
        if (lua_isnil(L, -1)) { /* no such field? */
            lua_pop(L, 1); /* remove this nil */
            lua_createtable(L, 0, (*e == '.' ? 1 : szhint)); /* new table for field */
            lua_pushlstring(L, fname, e - fname);
            lua_pushvalue(L, -2);
            lua_settable(L, -4); /* set new table into field */
        } else if (!lua_istable(L, -1)) { /* field has a non-table value? */
            lua_pop(L, 2); /* remove table and value */
            return fname; /* return problematic part of the name */
        }
        lua_remove(L, -2); /* remove previous table */
        fname = e + 1;
    } while (*e == '.');
    return NULL;
}

/*
** {======================================================
** Generic Buffer manipulation
** =======================================================
*/

#define bufflen(B) ((B)->p - (B)->buffer)
#define bufffree(B) ((size_t) (LUAL_BUFFERSIZE - bufflen(B)))

#define LIMIT (LUA_MINSTACK / 2)

static int emptybuffer (luaL_Buffer *B) {
    size_t l = bufflen(B);
    if (l == 0) {
        return 0; /* put nothing on stack */
    } else {
        lua_pushlstring(B->L, B->buffer, l);
        B->p = B->buffer;
        B->lvl++;
        return 1;
    }
}

static void adjuststack (luaL_Buffer *B) {
    if (B->lvl > 1) {
        lua_State *L = B->L;
        int toget = 1; /* number of levels to concat */
        size_t toplen = lua_strlen(L, -1);
        do {
            size_t l = lua_strlen(L, -(toget + 1));
            if (B->lvl - toget + 1 >= LIMIT || toplen > l) {
                toplen += l;
                toget++;
            } else {
                break;
            }
        } while (toget < B->lvl);
        lua_concat(L, toget);
        B->lvl = B->lvl - toget + 1;
    }
}

LUALIB_API char *luaL_prepbuffer (luaL_Buffer *B) {
    if (emptybuffer(B)) {
        adjuststack(B);
    }
    return B->buffer;
}

LUALIB_API void luaL_addlstring (luaL_Buffer *B, const char *s, size_t l) {
    while (l--) {
        luaL_addchar(B, *s++);
    }
}

LUALIB_API void luaL_addstring (luaL_Buffer *B, const char *s) {
    luaL_addlstring(B, s, strlen(s));
}

LUALIB_API void luaL_pushresult (luaL_Buffer *B) {
    emptybuffer(B);
    lua_concat(B->L, B->lvl);
    B->lvl = 1;
}

LUALIB_API void luaL_addvalue (luaL_Buffer *B) {
    lua_State *L = B->L;
    size_t vl;
    const char *s = lua_tolstring(L, -1, &vl);
    if (vl <= bufffree(B)) { /* fit into buffer? */
        memcpy(B->p, s, vl); /* put it there */
        B->p += vl;
        lua_pop(L, 1); /* remove from stack */
    } else {
        if (emptybuffer(B)) {
            lua_insert(L, -2); /* put buffer before new value */
        }
        B->lvl++; /* add new value into B stack */
        adjuststack(B);
    }
}

LUALIB_API void luaL_buffinit (lua_State *L, luaL_Buffer *B) {
    B->L = L;
    B->p = B->buffer;
    B->lvl = 0;
}

/* }====================================================== */

LUALIB_API int luaL_ref (lua_State *L, int t) {
    int ref;
    t = lua_absindex(L, t);
    if (lua_isnil(L, -1)) {
        lua_pop(L, 1); /* remove from stack */
        return LUA_REFNIL; /* `nil' has a unique fixed reference */
    }
    lua_rawgeti(L, t, FREELIST_REF); /* get first free element */
    ref = lua_toint(L, -1); /* ref = t[FREELIST_REF] */
    lua_pop(L, 1); /* remove it from stack */
    if (ref != 0) { /* any free element? */
        lua_rawgeti(L, t, ref); /* remove it from list */
        lua_setvaluetaint(L, -1, NULL);
        lua_rawseti(L, t, FREELIST_REF); /* (t[FREELIST_REF] = t[ref]) */
    } else { /* no free elements */
        ref = (int) lua_objlen(L, t);
        ref++; /* create new reference */
    }
    lua_rawseti(L, t, ref);
    return ref;
}

LUALIB_API void luaL_unref (lua_State *L, int t, int ref) {
    if (ref >= 0) {
        t = lua_absindex(L, t);
        lua_rawgeti(L, t, FREELIST_REF);
        lua_setvaluetaint(L, -1, NULL);
        lua_rawseti(L, t, ref); /* t[ref] = t[FREELIST_REF] */
        lua_pushinteger(L, ref);
        lua_setvaluetaint(L, -1, NULL);
        lua_rawseti(L, t, FREELIST_REF); /* t[FREELIST_REF] = ref */
    }
}

/*
** {======================================================
** Load functions
** =======================================================
*/

typedef struct LoadF {
    int extraline;
    FILE *f;
    char buff[LUAL_BUFFERSIZE];
} LoadF;

static const char *getF (lua_State *L, void *ud, size_t *size) {
    LoadF *lf = (LoadF *) ud;
    (void) L;
    if (lf->extraline) {
        lf->extraline = 0;
        *size = 1;
        return "\n";
    }
    if (feof(lf->f)) {
        return NULL;
    }
    *size = fread(lf->buff, 1, sizeof(lf->buff), lf->f);
    return (*size > 0) ? lf->buff : NULL;
}

static int errfile (lua_State *L, const char *what, int fnameindex) {
    const char *serr = strerror(errno);
    const char *filename = lua_tostring(L, fnameindex) + 1;
    lua_pushfstring(L, "cannot %s %s: %s", what, filename, serr);
    lua_remove(L, fnameindex);
    return LUA_ERRFILE;
}

LUALIB_API int luaL_loadfile (lua_State *L, const char *filename) {
    LoadF lf;
    int status;
    int readstatus;
    int c;
    int fnameindex = lua_gettop(L) + 1; /* index of filename on the stack */
    lf.extraline = 0;
    if (filename == NULL) {
        lua_pushliteral(L, "=stdin");
        lf.f = stdin;
    } else {
        lua_pushfstring(L, "@%s", filename);
        lf.f = fopen(filename, "r");
        if (lf.f == NULL) {
            return errfile(L, "open", fnameindex);
        }
    }
    c = getc(lf.f);
    if (c == '#') { /* Unix exec. file? */
        lf.extraline = 1;
        while ((c = getc(lf.f)) != EOF && c != '\n') {
            ; /* skip first line */
        }
        if (c == '\n') {
            c = getc(lf.f);
        }
    }
    if (c == LUA_SIGNATURE[0] && filename) { /* binary file? */
        lf.f = freopen(filename, "rb", lf.f); /* reopen in binary mode */
        if (lf.f == NULL) {
            return errfile(L, "reopen", fnameindex);
        }
        /* skip eventual `#!...' */
        while ((c = getc(lf.f)) != EOF && c != LUA_SIGNATURE[0]) {
            ;
        }
        lf.extraline = 0;
    }
    ungetc(c, lf.f);
    status = lua_load(L, getF, &lf, lua_tostring(L, -1));
    readstatus = ferror(lf.f);
    if (filename) {
        fclose(lf.f); /* close file (even in case of errors) */
    }
    if (readstatus) {
        lua_settop(L, fnameindex); /* ignore results from `lua_load' */
        return errfile(L, "read", fnameindex);
    }
    lua_remove(L, fnameindex);
    return status;
}

typedef struct LoadS {
    const char *s;
    size_t size;
} LoadS;

static const char *getS (lua_State *L, void *ud, size_t *size) {
    LoadS *ls = (LoadS *) ud;
    (void) L;
    if (ls->size == 0) {
        return NULL;
    }
    *size = ls->size;
    ls->size = 0;
    return ls->s;
}

LUALIB_API int luaL_loadbuffer (lua_State *L, const char *buff, size_t size, const char *name) {
    LoadS ls;
    ls.s = buff;
    ls.size = size;
    return lua_load(L, getS, &ls, name);
}

LUALIB_API int(luaL_loadstring)(lua_State *L, const char *s) {
    return luaL_loadbuffer(L, s, strlen(s), s);
}

/* }====================================================== */

static void *l_alloc (void *ud, void *ptr, size_t osize, size_t nsize) {
    lua_unused(ud);
    lua_unused(osize);

    if (nsize == 0) {
        free(ptr);
        return NULL;
    } else {
        return realloc(ptr, nsize);
    }
}

static int panic (lua_State *L) {
    luaL_writestringerror("PANIC: unprotected error in call to Lua API (%s)\n", lua_tostring(L, -1));
    return 0; /* return to Lua to abort */
}

LUALIB_API lua_State *luaL_newstate (void) {
    lua_State *L = lua_newstate(l_alloc, NULL);
    if (L) {
        lua_atpanic(L, &panic);
    }
    return L;
}

/*
** {======================================================================
** Auxilliary Library Extension APIs
** =======================================================================
*/

LUALIB_API int luaL_checkint (lua_State *L, int narg) {
    int i = lua_toint(L, narg);

    if (i == 0 && !lua_isnumber(L, narg)) {
        luaL_typerror(L, narg, lua_typename(L, LUA_TNUMBER));
    }

    return i;
}

LUALIB_API int luaL_optint (lua_State *L, int narg, int def) {
    return luaL_opt(L, luaL_checkint, narg, def);
}

LUALIB_API long luaL_checklong (lua_State *L, int narg) {
    long i = lua_tolong(L, narg);

    if (i == 0 && !lua_isnumber(L, narg)) {
        luaL_typerror(L, narg, lua_typename(L, LUA_TNUMBER));
    }

    return i;
}

LUALIB_API long luaL_optlong (lua_State *L, int narg, long def) {
    return luaL_opt(L, luaL_checklong, narg, def);
}

LUALIB_API lua_State *luaL_checkthread (lua_State *L, int narg) {
    lua_State *L1 = lua_tothread(L, narg);

    if (!L1) {
        luaL_typerror(L, narg, lua_typename(L, LUA_TTHREAD));
    }

    return L1;
}

LUALIB_API lua_State *luaL_optthread (lua_State *L, int narg, lua_State *def) {
    return luaL_opt(L, luaL_checkthread, narg, def);
}

LUALIB_API const char *luaL_tolstring (lua_State *L, int idx, size_t *len) {
    if (!luaL_callmeta(L, idx, "__tostring")) { /* no metafield? */
        switch (lua_type(L, idx)) {
            case LUA_TNUMBER:
            case LUA_TSTRING:
                lua_pushvalue(L, idx);
                break;
            case LUA_TBOOLEAN:
                lua_pushstring(L, (lua_toboolean(L, idx) ? "true" : "false"));
                break;
            case LUA_TNIL:
                lua_pushliteral(L, "nil");
                break;
            default:
                lua_pushfstring(L, "%s: %p", luaL_typename(L, idx), lua_topointer(L, idx));
                break;
        }
    }
    return lua_tolstring(L, -1, len);
}

LUALIB_API int luaL_getsubtable (lua_State *L, int idx, const char *fname) {
    lua_getfield(L, idx, fname);

    if (lua_istable(L, -1)) {
        return 1; /* table already there */
    } else {
        lua_pop(L, 1); /* remove previous result */
        idx = lua_absindex(L, idx);
        lua_newtable(L);
        lua_pushvalue(L, -1); /* copy to be left at top */
        lua_setfield(L, idx, fname); /* assign new table to field */
        return 0; /* false, because did not find table there */
    }
}

LUALIB_API void luaL_requiref (lua_State *L, const char *modname, lua_CFunction openf, int glb) {
    lua_pushcfunction(L, openf);
    lua_pushstring(L, modname); /* argument to open function */
    lua_call(L, 1, 1); /* open module */
    luaL_getsubtable(L, LUA_REGISTRYINDEX, "_LOADED");
    lua_pushvalue(L, -2); /* make copy of module (call result) */
    lua_setfield(L, -2, modname); /* _LOADED[modname] = module */
    lua_pop(L, 1); /* remove _LOADED table */

    if (glb) {
        lua_pushvalue(L, -1); /* copy of 'mod' */
        lua_setglobal(L, modname); /* _G[modname] = module */
    }
}

LUALIB_API void luaL_setfuncs (lua_State *L, const luaL_Reg *l, int nup) {
    luaL_checkstack(L, nup, "too many upvalues");

    for (; l->name != NULL; l++) {
        int i;

        for (i = 0; i < nup; i++) { /* copy upvalues to top of stack */
            lua_pushvalue(L, -nup);
        }

        lua_pushcclosure(L, l->func, nup);
        lua_setfield(L, -(nup + 2), l->name);
    }

    lua_pop(L, nup);
}

/**
 * Error reporting functions
 */

enum { TRACELEVELS1 = 12 }; /* size of the first part of the stack */
enum { TRACELEVELS2 = 10 }; /* size of the second part of the stack */

static void pushfuncname (lua_State *L, const lua_Debug *ar) {
    if (*ar->namewhat != '\0') { /* is there a name? */
        lua_pushfstring(L, "function '%s'", ar->name);
    } else if (*ar->what == 'm') { /* main? */
        lua_pushliteral(L, "main chunk");
    } else if (*ar->what == 'C' || *ar->what == 't') {
        lua_pushliteral(L, "?");
    } else {
        lua_pushfstring(L, "function <%s:%d>", ar->short_src, ar->linedefined);
    }
}

static int countlevels (lua_State *L) {
    lua_Debug ar;
    int li = 1;
    int le = 1;
    /* find an upper bound */
    while (lua_getstack(L, le, &ar)) {
        li = le;
        le *= 2;
    }
    /* do a binary search */
    while (li < le) {
        int m = (li + le) / 2;
        if (lua_getstack(L, m, &ar)) {
            li = m + 1;
        } else {
            le = m;
        }
    }
    return le - 1;
}

LUALIB_API void luaL_traceback (lua_State *L, lua_State *L1, const char *msg, int level) {
    lua_Debug ar;
    int top = lua_gettop(L);
    int numlevels = countlevels(L1);
    int mark = (numlevels > TRACELEVELS1 + TRACELEVELS2) ? TRACELEVELS1 : 0;
    if (msg) {
        lua_pushfstring(L, "%s\n", msg);
    }
    lua_pushliteral(L, "stack traceback:");
    while (lua_getstack(L1, level++, &ar)) {
        if (level == mark) { /* too many levels? */
            lua_pushliteral(L, "\n\t..."); /* add a '...' */
            level = numlevels - TRACELEVELS2; /* and skip to last ones */
        } else {
            lua_getinfo(L1, "Sln", &ar);
            lua_pushfstring(L, "\n\t%s:", ar.short_src);
            if (ar.currentline > 0) {
                lua_pushfstring(L, "%d:", ar.currentline);
            }
            lua_pushliteral(L, " in ");
            pushfuncname(L, &ar);
            lua_concat(L, lua_gettop(L) - top);
        }
    }
    lua_concat(L, lua_gettop(L) - top);
}

/**
 * Security APIs
 */

LUALIB_API int luaL_issecure (lua_State *L) {
    return lua_getstacktaint(L) == NULL;
}

LUALIB_API int luaL_issecurevalue (lua_State *L, int idx) {
    return lua_getvaluetaint(L, idx) == NULL;
}

LUALIB_API int luaL_issecureobject (lua_State *L, int idx) {
    return lua_getobjecttaint(L, idx) == NULL;
}

static void aux_gettable_untainted (lua_State *L, void *ud) {
    lua_unused(ud);
    lua_setstacktaint(L, NULL);
    lua_gettable(L, -2);
}

LUALIB_API const char *luaL_gettabletaint (lua_State *L, int idx) {
    lua_TaintState savedts;
    const char *taint;
    int tidx = lua_absindex(L, idx);
    int kidx = lua_absindex(L, -1);

    lua_checkstack(L, 2);
    lua_savetaint(L, &savedts);
    lua_pushvalue(L, tidx);
    lua_pushvalue(L, kidx);
    lua_protecttaint(L, aux_gettable_untainted, NULL);
    lua_settop(L, kidx - 1);
    taint = lua_getstacktaint(L);
    lua_restoretaint(L, &savedts);

    return taint;
}

LUALIB_API const char *luaL_getlocaltaint (lua_State *L, const lua_Debug *ar, int n) {
    lua_TaintState savedts;
    const char *taint;

    lua_checkstack(L, 1);
    lua_savetaint(L, &savedts);
    lua_setstacktaint(L, NULL);
    if (lua_getlocal(L, ar, n)) {
        lua_pop(L, 1);
    }
    taint = lua_getstacktaint(L);
    lua_restoretaint(L, &savedts);

    return taint;
}

LUALIB_API const char *luaL_getupvaluetaint (lua_State *L, int funcindex, int n) {
    lua_TaintState savedts;
    const char *taint;

    lua_checkstack(L, 1);
    lua_savetaint(L, &savedts);
    lua_setstacktaint(L, NULL);
    if (lua_getupvalue(L, funcindex, n)) {
        lua_pop(L, 1);
    }
    taint = lua_getstacktaint(L);
    lua_restoretaint(L, &savedts);

    return taint;
}

static void aux_settable_untainted (lua_State *L, void *ud) {
    lua_unused(ud);
    lua_setstacktaint(L, NULL);
    lua_settable(L, -2);
}

LUALIB_API void luaL_settabletaint (lua_State *L, int idx, const char *name) {
    lua_TaintState savedts;
    int tidx = lua_absindex(L, idx);
    int kidx = lua_absindex(L, -1);

    lua_savetaint(L, &savedts);
    lua_pushvalue(L, kidx);
    lua_gettable(L, tidx);
    lua_setvaluetaint(L, -1, name);
    lua_protecttaint(L, aux_settable_untainted, NULL);
    lua_restoretaint(L, &savedts);
}

LUALIB_API void luaL_setlocaltaint (lua_State *L, const lua_Debug *ar, int n, const char *name) {
    lua_TaintState savedts;

    lua_checkstack(L, 1);
    lua_savetaint(L, &savedts);

    if (lua_getlocal(L, ar, n)) {
        lua_setvaluetaint(L, -1, name);
        lua_setlocal(L, ar, n);
    }

    lua_restoretaint(L, &savedts);
}

LUALIB_API void luaL_setupvaluetaint (lua_State *L, int funcindex, int n, const char *name) {
    lua_TaintState savedts;

    lua_checkstack(L, 1);
    lua_savetaint(L, &savedts);

    if (lua_getupvalue(L, funcindex, n)) {
        lua_setvaluetaint(L, -1, name);
        lua_setupvalue(L, funcindex, n);
    }

    lua_restoretaint(L, &savedts);
}

LUALIB_API int luaL_securecall (lua_State *L, int nargs, int nresults, int errfunc) {
    int status = luaL_securepcall(L, nargs, nresults, errfunc);
    if (status != 0) {
        lua_pop(L, 1);
    }
    return status;
}

LUALIB_API int luaL_securepcall (lua_State *L, int nargs, int nresults, int errfunc) {
    lua_TaintState savedts;
    lua_savetaint(L, &savedts);
    return luaL_pcallas(L, nargs, nresults, errfunc, &savedts);
}

LUALIB_API int luaL_securecpcall (lua_State *L, lua_CFunction func, void *ud) {
    lua_TaintState savedts;
    lua_savetaint(L, &savedts);
    return luaL_cpcallas(L, func, ud, &savedts);
}

LUALIB_API void luaL_secureforeach (lua_State *L, int idx, int nargs, int errfunc) {
    lua_TaintState savedts;
    int minstack = nargs + 5; /* min 5 slots required for all pushed values */
    int funcidx;

    lua_checkstack(L, minstack);
    lua_savetaint(L, &savedts);
    funcidx = lua_absindex(L, -(nargs + 1));
    idx = lua_absindex(L, idx);
    errfunc = lua_absindex(L, errfunc);

    lua_pushnil(L); /* push initial key */

    while (lua_next(L, idx)) {
        lua_pushvalue(L, funcidx);
        lua_pushvalue(L, -3); /* push key */
        lua_pushvalue(L, -3); /* push value */

        for (int i = 1; i <= nargs; ++i) { /* push additional arguments */
            lua_pushvalue(L, funcidx + i);
        }

        if (lua_pcall(L, nargs + 2, 0, errfunc) != LUA_OK) {
            lua_pop(L, 1); /* pop error value */
        }

        lua_pop(L, 1); /* pop value; retain key for next */
        lua_restoretaint(L, &savedts);
    }

    lua_pop(L, 1); /* pop function */
}

static int f_insecuredelegate (lua_State *L) {
    lua_pushvalue(L, lua_upvalueindex(1));
    lua_insert(L, 1);
    lua_call(L, (lua_gettop(L) - 1), LUA_MULTRET);
    return lua_gettop(L);
}

LUALIB_API void luaL_createdelegate (lua_State *L) {
    lua_pushcclosure(L, &f_insecuredelegate, 1);
}

static int f_securedelegate (lua_State *L) {
    lua_TaintState savedts;
    int nargs = lua_gettop(L);
    int nresults;
    int argi;
    int status;

    /* Wrap all function arguments in delegates that can taint when invoked. */
    for (argi = 1; argi <= nargs; ++argi) {
        if (lua_isfunction(L, argi)) {
            lua_pushvalue(L, argi);
            luaL_createdelegate(L);
            lua_replace(L, argi);
        }
    }

    lua_savetaint(L, &savedts);
    lua_pushvalue(L, lua_upvalueindex(1));
    lua_insert(L, 1);
    lua_setstacktaint(L, NULL);
    lua_settoptaint(L, nargs, NULL);
    status = lua_pcall(L, nargs, LUA_MULTRET, 0);
    nresults = lua_gettop(L);
    lua_restoretaint(L, &savedts);
    lua_settoptaint(L, nresults, lua_getstacktaint(L));

    if (status != 0) {
        lua_error(L);
    }
    return nresults;
}

LUALIB_API void luaL_createsecuredelegate (lua_State *L) {
    lua_pushcclosure(L, &f_securedelegate, 1);
}

static int f_securehook (lua_State *L) {
    lua_TaintState savedts;
    int nargs;
    int nresults;
    int argi;
    int status;

    nargs = lua_gettop(L);

    /* Set up and call initial function */
    lua_checkstack(L, nargs + 1);
    lua_pushvalue(L, lua_upvalueindex(1));
    for (argi = 1; argi <= nargs; ++argi) {
        lua_pushvalue(L, argi);
    }
    lua_call(L, nargs, LUA_MULTRET);
    nresults = (lua_gettop(L) - nargs);

    /* Set up and call posthook function */
    lua_checkstack(L, nargs + 1);
    lua_savetaint(L, &savedts);
    lua_pushvalue(L, lua_upvalueindex(2));
    for (argi = 1; argi <= nargs; ++argi) {
        lua_pushvalue(L, argi);
    }
    status = lua_pcall(L, nargs, 0, LUA_ERRORHANDLERINDEX);
    if (status != 0) {
        lua_pop(L, 1);
    }
    lua_restoretaint(L, &savedts);

    return nresults;
}

LUALIB_API void luaL_createsecurehook (lua_State *L) {
    lua_pushcclosure(L, &f_securehook, 2);
}

LUALIB_API void luaL_forceinsecure (lua_State *L) {
    if (luaL_issecure(L)) {
        lua_setstacktaint(L, LUA_FORCEINSECURE_TAINT);
    }
}

LUALIB_API int luaL_pcallas (lua_State *L, int nargs, int nresults, int errfunc, lua_TaintState *ts) {
    int base;
    int status;

    base = lua_absindex(L, -(nargs + 1));
    lua_exchangetaint(L, ts);
    status = lua_pcall(L, nargs, nresults, errfunc);
    nresults = (lua_gettop(L) - (base - 1));
    lua_exchangetaint(L, ts);
    lua_settoptaint(L, nresults, lua_getstacktaint(L));

    return status;
}

LUALIB_API int luaL_cpcallas (lua_State *L, lua_CFunction func, void *ud, lua_TaintState *ts) {
    int status;

    lua_exchangetaint(L, ts);
    status = lua_cpcall(L, func, ud);
    lua_exchangetaint(L, ts);
    if (status != 0) {
        lua_setvaluetaint(L, -1, lua_getstacktaint(L));
    }

    return status;
}

LUALIB_API int luaL_loadas (lua_State *L, lua_Reader reader, void *dt, const char *chunkname, lua_TaintState *ts) {
    int status;

    lua_exchangetaint(L, ts);
    status = lua_load(L, reader, dt, chunkname);
    lua_exchangetaint(L, ts);
    lua_setvaluetaint(L, -1, lua_getstacktaint(L));

    return status;
}

LUALIB_API int luaL_loadfileas (lua_State *L, const char *filename, lua_TaintState *ts) {
    int status;

    lua_exchangetaint(L, ts);
    status = luaL_loadfile(L, filename);
    lua_exchangetaint(L, ts);
    lua_setvaluetaint(L, -1, lua_getstacktaint(L));

    return status;
}

LUALIB_API int luaL_loadbufferas (lua_State *L, const char *buff, size_t sz, const char *name, lua_TaintState *ts) {
    int status;

    lua_exchangetaint(L, ts);
    status = luaL_loadbuffer(L, buff, sz, name);
    lua_exchangetaint(L, ts);
    lua_setvaluetaint(L, -1, lua_getstacktaint(L));

    return status;
}

LUALIB_API int luaL_loadstringas (lua_State *L, const char *s, lua_TaintState *ts) {
    int status;

    lua_exchangetaint(L, ts);
    status = luaL_loadstring(L, s);
    lua_exchangetaint(L, ts);
    lua_setvaluetaint(L, -1, lua_getstacktaint(L));

    return status;
}

LUALIB_API lua_Number luaL_securerandom (lua_State *L) {
    lua_unused(L);

#if defined(LUA_USE_LINUX)
    /* Linux implementation */
    uint32_t i;
    ssize_t read = 0;

    do {
        ssize_t result = getrandom((&i) + read, sizeof(i) - read, 0);

        if (result < 0) {
            lua_pushfstring(L, "%s", strerror(errno));
            return lua_error(L);
        } else {
            read += result;
        }
    } while (read != sizeof(i));

    return ((lua_Number) i / UINT32_MAX);
#elif defined(LUA_USE_MACOS)
    /* macOS implementation */
    return ((lua_Number) arc4random() / UINT32_MAX);
#elif defined(LUA_USE_WINDOWS)
    uint32_t i;
    BCryptGenRandom(NULL, (PUCHAR) &i, sizeof(i), BCRYPT_USE_SYSTEM_PREFERRED_RNG);
    return ((lua_Number) i / UINT32_MAX);
#else
    luaL_error(L, "secure random generator not available on this platform");
    return 0;
#endif
}

LUALIB_API void luaL_writestring (const char *s, size_t sz) {
    fwrite(s, sizeof(char), sz, stdout);
}

LUALIB_API void luaL_writestringerror (const char *s, ...) {
    va_list args;
    va_start(args, s);
    vfprintf(stderr, s, args);
    va_end(args);
    fflush(stderr);
}

LUALIB_API void luaL_writeline (void) {
    luaL_writestring("\n", 1);
    fflush(stdout);
}

/* }====================================================================== */
