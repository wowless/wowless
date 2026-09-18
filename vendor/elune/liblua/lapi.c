/* Licensed under the terms of the MIT License; see full copyright information
 * in the "LICENSE" file or at <http://www.lua.org/license.html> */

#include <assert.h>
#include <math.h>
#include <stdarg.h>
#include <string.h>

#define lapi_c
#define LUA_CORE

#include "lua.h"

#include "lapi.h"
#include "ldebug.h"
#include "ldo.h"
#include "lfunc.h"
#include "lgc.h"
#include "lmanip.h"
#include "lmem.h"
#include "lobject.h"
#include "lsec.h"
#include "lstate.h"
#include "lstring.h"
#include "ltable.h"
#include "ltm.h"
#include "lundump.h"
#include "lvm.h"

#define api_checknelems(L, n) api_check(L, (n) <= (L->top - L->base))

#define api_checkvalidindex(L, i) api_check(L, (i) != luaO_nilobject)

#define api_incr_top(L)                                                                                                \
    {                                                                                                                  \
        api_check(L, L->top < L->ci->top);                                                                             \
        L->top++;                                                                                                      \
    }

static TValue *index2adr (lua_State *L, int idx) {
    if (idx > 0) {
        TValue *o = L->base + (idx - 1);
        api_check(L, idx <= L->ci->top - L->base);
        if (o >= L->top) {
            return cast(TValue *, luaO_nilobject);
        } else {
            return o;
        }
    } else if (idx > LUA_ERRORHANDLERINDEX) {
        api_check(L, idx != 0 && -idx <= L->top - L->base);
        return L->top + idx;
    } else {
        switch (idx) { /* pseudo-indices */
            case LUA_ERRORHANDLERINDEX:
                return &G(L)->l_errfunc;
            case LUA_REGISTRYINDEX:
                return registry(L);
            case LUA_ENVIRONINDEX: {
                Closure *func = curr_func(L);
                sethvalue(L, &L->env, func->c.env);
                return &L->env;
            }
            case LUA_GLOBALSINDEX:
                return gt(L);
            default: {
                Closure *func = curr_func(L);
                idx = LUA_GLOBALSINDEX - idx;
                return (idx <= func->c.nupvalues) ? &func->c.upvalue[idx - 1] : cast(TValue *, luaO_nilobject);
            }
        }
    }
}

static Table *getcurrenv (lua_State *L) {
    if (L->ci == L->base_ci) { /* no enclosing function? */
        return hvalue(gt(L)); /* use global table as environment */
    } else {
        Closure *func = curr_func(L);
        return func->c.env;
    }
}

void luaA_pushobject (lua_State *L, const TValue *o) {
    setobj2s(L, L->top, o);
    api_incr_top(L);
}

LUA_API int lua_checkstack (lua_State *L, int size) {
    int res = 1;
    lua_lock(L);
    if (size > LUAI_MAXCSTACK || (L->top - L->base + size) > LUAI_MAXCSTACK) {
        res = 0; /* stack overflow */
    } else if (size > 0) {
        luaD_checkstack(L, size);
        if (L->ci->top < L->top + size) {
            L->ci->top = L->top + size;
        }
    }
    lua_unlock(L);
    return res;
}

LUA_API void lua_xmove (lua_State *from, lua_State *to, int n) {
    int i;
    if (from == to) {
        return;
    }
    lua_lock(to);
    api_checknelems(from, n);
    api_check(from, G(from) == G(to));
    api_check(from, to->ci->top - to->top >= n);
    from->top -= n;
    for (i = 0; i < n; i++) {
        setobj2s(to, to->top++, from->top + i);
    }
    lua_unlock(to);
}

LUA_API void lua_setlevel (lua_State *from, lua_State *to) {
    to->nCcalls = from->nCcalls;
}

LUA_API lua_CFunction lua_atpanic (lua_State *L, lua_CFunction panicf) {
    lua_CFunction old;
    lua_lock(L);
    old = G(L)->panic;
    G(L)->panic = panicf;
    lua_unlock(L);
    return old;
}

LUA_API lua_State *lua_newthread (lua_State *L) {
    lua_State *L1;
    lua_lock(L);
    luaC_checkGC(L);
    L1 = luaE_newthread(L);
    setthvalue(L, L->top, L1);
    api_incr_top(L);
    lua_unlock(L);
    luai_userstatethread(L, L1);
    return L1;
}

/*
** basic stack manipulation
*/

LUA_API int lua_gettop (lua_State *L) {
    return cast_int(L->top - L->base);
}

LUA_API void lua_settop (lua_State *L, int idx) {
    lua_lock(L);
    if (idx >= 0) {
        api_check(L, idx <= L->stack_last - L->base);
        while (L->top < L->base + idx) {
            setnilvalue(L, L->top++);
        }
        L->top = L->base + idx;
    } else {
        api_check(L, -(idx + 1) <= (L->top - L->base));
        L->top += idx + 1; /* `subtract' index (index is negative) */
    }
    lua_unlock(L);
}

LUA_API void lua_remove (lua_State *L, int idx) {
    StkId p;
    lua_lock(L);
    p = index2adr(L, idx);
    api_checkvalidindex(L, p);
    while (++p < L->top) {
        setobjs2s(L, p - 1, p);
    }
    L->top--;
    lua_unlock(L);
}

LUA_API void lua_insert (lua_State *L, int idx) {
    StkId p;
    StkId q;
    lua_lock(L);
    p = index2adr(L, idx);
    api_checkvalidindex(L, p);
    for (q = L->top; q > p; q--) {
        setobjs2s(L, q, q - 1);
    }
    setobjs2s(L, p, L->top);
    lua_unlock(L);
}

static void moveto (lua_State *L, StkId fr, int idx) {
    if (idx == LUA_ENVIRONINDEX) {
        Closure *func = curr_func(L);
        api_check(L, ttistable(fr));
        func->c.env = hvalue(fr);
        luaC_barrier(L, func, fr);
    } else {
        StkId to = index2adr(L, idx);
        api_checkvalidindex(L, to);
        setobj(L, to, fr);

        if (idx < LUA_GLOBALSINDEX) { /* function upvalue? */
            luaC_barrier(L, curr_func(L), fr);
        }
    }
}

LUA_API void lua_replace (lua_State *L, int idx) {
    lua_lock(L);
    /* explicit test for incompatible code */
    if (idx == LUA_ENVIRONINDEX && L->ci == L->base_ci) {
        luaG_runerror(L, "no calling environment");
    }
    api_checknelems(L, 1);
    moveto(L, L->top - 1, idx);
    L->top--;
    lua_unlock(L);
}

LUA_API void lua_pushvalue (lua_State *L, int idx) {
    lua_lock(L);
    setobj2s(L, L->top, index2adr(L, idx));
    api_incr_top(L);
    lua_unlock(L);
}

/*
** access functions (stack -> C)
*/

LUA_API int lua_type (lua_State *L, int idx) {
    StkId o = index2adr(L, idx);
    return (o == luaO_nilobject) ? LUA_TNONE : ttype(o);
}

LUA_API const char *lua_typename (lua_State *L, int t) {
    lua_unused(L);
    return (t == LUA_TNONE) ? "no value" : luaT_typenames[t];
}

LUA_API int lua_iscfunction (lua_State *L, int idx) {
    StkId o = index2adr(L, idx);
    return iscfunction(o);
}

LUA_API int lua_isnumber (lua_State *L, int idx) {
    TValue n;
    const TValue *o = index2adr(L, idx);
    return tonumber(L, o, &n);
}

LUA_API int lua_isstring (lua_State *L, int idx) {
    int t = lua_type(L, idx);
    return (t == LUA_TSTRING || t == LUA_TNUMBER);
}

LUA_API int lua_isuserdata (lua_State *L, int idx) {
    const TValue *o = index2adr(L, idx);
    return (ttisuserdata(o) || ttislightuserdata(o));
}

LUA_API int lua_rawequal (lua_State *L, int index1, int index2) {
    StkId o1 = index2adr(L, index1);
    StkId o2 = index2adr(L, index2);
    return (o1 == luaO_nilobject || o2 == luaO_nilobject) ? 0 : luaO_rawequalObj(o1, o2);
}

LUA_API int lua_equal (lua_State *L, int index1, int index2) {
    StkId o1;
    StkId o2;
    int i;
    lua_lock(L); /* may call tag method */
    o1 = index2adr(L, index1);
    o2 = index2adr(L, index2);
    i = (o1 == luaO_nilobject || o2 == luaO_nilobject) ? 0 : equalobj(L, o1, o2);
    lua_unlock(L);
    return i;
}

LUA_API int lua_lessthan (lua_State *L, int index1, int index2) {
    StkId o1;
    StkId o2;
    int i;
    lua_lock(L); /* may call tag method */
    o1 = index2adr(L, index1);
    o2 = index2adr(L, index2);
    i = (o1 == luaO_nilobject || o2 == luaO_nilobject) ? 0 : luaV_lessthan(L, o1, o2);
    lua_unlock(L);
    return i;
}

LUA_API lua_Number lua_tonumber (lua_State *L, int idx) {
    TValue n;
    const TValue *o = index2adr(L, idx);
    if (tonumber(L, o, &n)) {
        return nvalue(o);
    } else {
        return 0;
    }
}

LUA_API lua_Integer lua_tointeger (lua_State *L, int idx) {
    TValue n;
    const TValue *o = index2adr(L, idx);
    if (tonumber(L, o, &n)) {
        lua_Integer res;
        lua_Number num = nvalue(o);
        lua_number2integer(res, num);
        return res;
    } else {
        return 0;
    }
}

LUA_API int lua_toboolean (lua_State *L, int idx) {
    const TValue *o = index2adr(L, idx);
    return !l_isfalse(o);
}

LUA_API const char *lua_tolstring (lua_State *L, int idx, size_t *len) {
    StkId o = index2adr(L, idx);
    if (!ttisstring(o)) {
        lua_lock(L); /* `luaV_tostring' may create a new string */
        if (!luaV_tostring(L, o)) { /* conversion failed? */
            if (len != NULL) {
                *len = 0;
            }
            lua_unlock(L);
            return NULL;
        }
        luaC_checkGC(L);
        o = index2adr(L, idx); /* previous call may reallocate the stack */
        lua_unlock(L);
    }
    if (len != NULL) {
        *len = tsvalue(o)->len;
    }
    return svalue(o);
}

LUA_API size_t lua_objlen (lua_State *L, int idx) {
    StkId o = index2adr(L, idx);
    switch (ttype(o)) {
        case LUA_TSTRING:
            return tsvalue(o)->len;
        case LUA_TUSERDATA:
            return uvalue(o)->len;
        case LUA_TTABLE:
            return luaH_getn(hvalue(o));
        case LUA_TNUMBER: {
            size_t l;
            lua_lock(L); /* `luaV_tostring' may create a new string */
            l = (luaV_tostring(L, o) ? tsvalue(o)->len : 0);
            lua_unlock(L);
            return l;
        }
        default:
            return 0;
    }
}

LUA_API lua_CFunction lua_tocfunction (lua_State *L, int idx) {
    StkId o = index2adr(L, idx);
    return (!iscfunction(o)) ? NULL : clvalue(o)->c.f;
}

LUA_API void *lua_touserdata (lua_State *L, int idx) {
    StkId o = index2adr(L, idx);
    switch (ttype(o)) {
        case LUA_TUSERDATA:
            return (rawuvalue(o) + 1);
        case LUA_TLIGHTUSERDATA:
            return pvalue(o);
        default:
            return NULL;
    }
}

LUA_API lua_State *lua_tothread (lua_State *L, int idx) {
    StkId o = index2adr(L, idx);
    return (!ttisthread(o)) ? NULL : thvalue(o);
}

LUA_API const void *lua_topointer (lua_State *L, int idx) {
    StkId o = index2adr(L, idx);
    switch (ttype(o)) {
        case LUA_TTABLE:
            return hvalue(o);
        case LUA_TFUNCTION:
            return clvalue(o);
        case LUA_TTHREAD:
            return thvalue(o);
        case LUA_TUSERDATA:
        case LUA_TLIGHTUSERDATA:
            return lua_touserdata(L, idx);
        default:
            return NULL;
    }
}

/*
** push functions (C -> stack)
*/

LUA_API void lua_pushnil (lua_State *L) {
    lua_lock(L);
    setnilvalue(L, L->top);
    api_incr_top(L);
    lua_unlock(L);
}

LUA_API void lua_pushnumber (lua_State *L, lua_Number n) {
    lua_lock(L);
    setnvalue(L, L->top, n);
    api_incr_top(L);
    lua_unlock(L);
}

LUA_API void lua_pushinteger (lua_State *L, lua_Integer n) {
    lua_lock(L);
    setnvalue(L, L->top, cast_num(n));
    api_incr_top(L);
    lua_unlock(L);
}

LUA_API void lua_pushlstring (lua_State *L, const char *s, size_t len) {
    lua_lock(L);
    luaC_checkGC(L);
    setsvalue2s(L, L->top, luaS_newlstr(L, s, len));
    api_incr_top(L);
    lua_unlock(L);
}

LUA_API void lua_pushstring (lua_State *L, const char *s) {
    if (s == NULL) {
        lua_pushnil(L);
    } else {
        lua_pushlstring(L, s, strlen(s));
    }
}

LUA_API const char *lua_pushvfstring (lua_State *L, const char *fmt, va_list argp) {
    const char *ret;
    lua_lock(L);
    luaC_checkGC(L);
    ret = luaO_pushvfstring(L, fmt, argp);
    lua_unlock(L);
    return ret;
}

LUA_API const char *lua_pushfstring (lua_State *L, const char *fmt, ...) {
    const char *ret;
    va_list argp;
    lua_lock(L);
    luaC_checkGC(L);
    va_start(argp, fmt);
    ret = luaO_pushvfstring(L, fmt, argp);
    va_end(argp);
    lua_unlock(L);
    return ret;
}

LUA_API void lua_pushcclosure (lua_State *L, lua_CFunction fn, int n) {
    Closure *cl;
    lua_lock(L);
    luaC_checkGC(L);
    api_checknelems(L, n);
    cl = luaF_newCclosure(L, n, getcurrenv(L));
    cl->c.f = fn;
    L->top -= n;
    while (n--) {
        setobj2n(L, &cl->c.upvalue[n], L->top + n);
    }
    setclvalue(L, L->top, cl);
    lua_assert(iswhite(obj2gco(cl)));
    api_incr_top(L);
    lua_unlock(L);
}

LUA_API void lua_pushboolean (lua_State *L, int b) {
    lua_lock(L);
    setbvalue(L, L->top, (b != 0)); /* ensure that true is 1 */
    api_incr_top(L);
    lua_unlock(L);
}

LUA_API void lua_pushlightuserdata (lua_State *L, void *p) {
    lua_lock(L);
    setpvalue(L, L->top, p);
    api_incr_top(L);
    lua_unlock(L);
}

LUA_API int lua_pushthread (lua_State *L) {
    lua_lock(L);
    setthvalue(L, L->top, L);
    api_incr_top(L);
    lua_unlock(L);
    return (G(L)->mainthread == L);
}

/*
** get functions (Lua -> stack)
*/

LUA_API void lua_gettable (lua_State *L, int idx) {
    StkId t;
    lua_lock(L);
    t = index2adr(L, idx);
    api_checkvalidindex(L, t);
    luaV_gettable(L, t, L->top - 1, L->top - 1);
    lua_unlock(L);
}

LUA_API void lua_getfield (lua_State *L, int idx, const char *k) {
    StkId tbl;
    TValue key;
    lua_lock(L);
    tbl = index2adr(L, idx);
    api_checkvalidindex(L, tbl);
    setsvalue(L, &key, luaS_new(L, k));
    luaV_gettable(L, tbl, &key, L->top);
    api_incr_top(L);
    lua_unlock(L);
}

LUA_API void lua_rawget (lua_State *L, int idx) {
    StkId tbl;
    StkId key;
    lua_lock(L);
    tbl = index2adr(L, idx);
    key = L->top - 1;
    api_check(L, ttistable(tbl));
    setobjt2s(L, tbl, key, key, luaH_get(hvalue(tbl), key));
    lua_unlock(L);
}

LUA_API void lua_rawgeti (lua_State *L, int idx, int n) {
    StkId tbl;
    TValue k;
    lua_lock(L);
    tbl = index2adr(L, idx);
    api_check(L, ttistable(tbl));
    rawsetnvalue(&k, n);
    setobjt2s(L, tbl, &k, L->top, luaH_getnum(hvalue(tbl), n));
    api_incr_top(L);
    lua_unlock(L);
}

LUA_API void lua_createtable (lua_State *L, int narray, int nrec) {
    lua_lock(L);
    luaC_checkGC(L);
    sethvalue(L, L->top, luaH_new(L, narray, nrec));
    api_incr_top(L);
    lua_unlock(L);
}

LUA_API int lua_getmetatable (lua_State *L, int objindex) {
    const TValue *obj;
    Table *mt = NULL;
    int res;
    lua_lock(L);
    obj = index2adr(L, objindex);
    switch (ttype(obj)) {
        case LUA_TTABLE:
            mt = hvalue(obj)->metatable;
            break;
        case LUA_TUSERDATA:
            mt = uvalue(obj)->metatable;
            break;
        default:
            mt = G(L)->mt[ttype(obj)];
            break;
    }
    if (mt == NULL) {
        res = 0;
    } else {
        sethvalue(L, L->top, mt);
        api_incr_top(L);
        res = 1;
    }
    lua_unlock(L);
    return res;
}

LUA_API void lua_getfenv (lua_State *L, int idx) {
    StkId o;
    lua_lock(L);
    o = index2adr(L, idx);
    api_checkvalidindex(L, o);
    switch (ttype(o)) {
        case LUA_TFUNCTION:
            sethvalue(L, L->top, clvalue(o)->c.env);
            break;
        case LUA_TUSERDATA:
            sethvalue(L, L->top, uvalue(o)->env);
            break;
        case LUA_TTHREAD:
            setobj2s(L, L->top, gt(thvalue(o)));
            break;
        default:
            setnilvalue(L, L->top);
            break;
    }
    api_incr_top(L);
    lua_unlock(L);
}

/*
** set functions (stack -> Lua)
*/

LUA_API void lua_settable (lua_State *L, int idx) {
    StkId t;
    lua_lock(L);
    api_checknelems(L, 2);
    t = index2adr(L, idx);
    api_checkvalidindex(L, t);
    luaV_settable(L, t, L->top - 2, L->top - 1);
    L->top -= 2; /* pop index and value */
    lua_unlock(L);
}

LUA_API void lua_setfield (lua_State *L, int idx, const char *k) {
    StkId tbl;
    TValue key;
    lua_lock(L);
    api_checknelems(L, 1);
    tbl = index2adr(L, idx);
    api_checkvalidindex(L, tbl);
    setsvalue(L, &key, luaS_new(L, k));
    luaV_settable(L, tbl, &key, L->top - 1);
    L->top--; /* pop value */
    lua_unlock(L);
}

LUA_API void lua_rawset (lua_State *L, int idx) {
    StkId tbl;
    StkId key;
    StkId src;
    lua_lock(L);
    api_checknelems(L, 2);
    tbl = index2adr(L, idx);
    key = L->top - 2;
    src = L->top - 1;
    api_check(L, ttistable(tbl));
    setobj2t(L, tbl, key, luaH_set(L, hvalue(tbl), key), src);
    luaC_barriert(L, hvalue(tbl), src);
    L->top -= 2;
    lua_unlock(L);
}

LUA_API void lua_rawseti (lua_State *L, int idx, int n) {
    StkId tbl;
    TValue key;
    StkId src;
    lua_lock(L);
    api_checknelems(L, 1);
    tbl = index2adr(L, idx);
    src = L->top - 1;
    api_check(L, ttistable(tbl));
    rawsetnvalue(&key, n);
    setobj2t(L, tbl, &key, luaH_setnum(L, hvalue(tbl), n), src);
    luaC_barriert(L, hvalue(tbl), src);
    L->top--;
    lua_unlock(L);
}

LUA_API int lua_setmetatable (lua_State *L, int objindex) {
    TValue *obj;
    Table *mt;
    lua_lock(L);
    api_checknelems(L, 1);
    obj = index2adr(L, objindex);
    api_checkvalidindex(L, obj);
    if (ttisnil(L->top - 1)) {
        mt = NULL;
    } else {
        api_check(L, ttistable(L->top - 1));
        mt = hvalue(L->top - 1);
    }
    switch (ttype(obj)) {
        case LUA_TTABLE: {
            hvalue(obj)->metatable = mt;
            if (mt)
                luaC_objbarriert(L, hvalue(obj), mt);
            break;
        }
        case LUA_TUSERDATA: {
            uvalue(obj)->metatable = mt;
            if (mt)
                luaC_objbarrier(L, rawuvalue(obj), mt);
            break;
        }
        default: {
            G(L)->mt[ttype(obj)] = mt;
            break;
        }
    }
    L->top--;
    lua_unlock(L);
    return 1;
}

LUA_API int lua_setfenv (lua_State *L, int idx) {
    StkId o;
    int res = 1;
    lua_lock(L);
    api_checknelems(L, 1);
    o = index2adr(L, idx);
    api_checkvalidindex(L, o);
    api_check(L, ttistable(L->top - 1));
    switch (ttype(o)) {
        case LUA_TFUNCTION:
            clvalue(o)->c.env = hvalue(L->top - 1);
            break;
        case LUA_TUSERDATA:
            uvalue(o)->env = hvalue(L->top - 1);
            break;
        case LUA_TTHREAD:
            sethvalue(L, gt(thvalue(o)), hvalue(L->top - 1));
            break;
        default:
            res = 0;
            break;
    }
    if (res)
        luaC_objbarrier(L, gcvalue(o), hvalue(L->top - 1));
    L->top--;
    lua_unlock(L);
    return res;
}

/*
** `load' and `call' functions (run Lua code)
*/

#define adjustresults(L, nres)                                                                                         \
    {                                                                                                                  \
        if (nres == LUA_MULTRET && L->top >= L->ci->top)                                                               \
            L->ci->top = L->top;                                                                                       \
    }

#define checkresults(L, na, nr) api_check(L, (nr) == LUA_MULTRET || (L->ci->top - L->top >= (nr) - (na)))

LUA_API void lua_call (lua_State *L, int nargs, int nresults) {
    StkId func;
    lua_lock(L);
    api_checknelems(L, nargs + 1);
    checkresults(L, nargs, nresults);
    func = L->top - (nargs + 1);
    luaD_call(L, func, nresults);
    adjustresults(L, nresults);
    lua_unlock(L);
}

/*
** Execute a protected call.
*/
struct CallS { /* data to `f_call' */
    StkId func;
    int nresults;
};

static void f_call (lua_State *L, void *ud) {
    struct CallS *c = cast(struct CallS *, ud);
    luaD_call(L, c->func, c->nresults);
}

LUA_API int lua_pcall (lua_State *L, int nargs, int nresults, int errfunc) {
    struct CallS c;
    int status;
    ptrdiff_t func;
    lua_lock(L);
    api_checknelems(L, nargs + 1);
    checkresults(L, nargs, nresults);
    if (errfunc == 0 || errfunc == LUA_ERRORHANDLERINDEX) {
        func = errfunc;
    } else {
        StkId o = index2adr(L, errfunc);
        api_checkvalidindex(L, o);
        func = savestack(L, o);
    }
    c.func = L->top - (nargs + 1); /* function to be called */
    c.nresults = nresults;
    status = luaD_pcall(L, f_call, &c, savestack(L, c.func), func);
    adjustresults(L, nresults);
    lua_unlock(L);
    return status;
}

/*
** Execute a protected C call.
*/
struct CCallS { /* data to `f_Ccall' */
    lua_CFunction func;
    void *ud;
};

static void f_Ccall (lua_State *L, void *ud) {
    struct CCallS *c = cast(struct CCallS *, ud);
    Closure *cl;
    cl = luaF_newCclosure(L, 0, getcurrenv(L));
    cl->c.f = c->func;
    setclvalue(L, L->top, cl); /* push function */
    api_incr_top(L);
    setpvalue(L, L->top, c->ud); /* push only argument */
    api_incr_top(L);
    luaD_call(L, L->top - 2, 0);
}

LUA_API int lua_cpcall (lua_State *L, lua_CFunction func, void *ud) {
    struct CCallS c;
    int status;
    lua_lock(L);
    c.func = func;
    c.ud = ud;
    status = luaD_pcall(L, f_Ccall, &c, savestack(L, L->top), 0);
    lua_unlock(L);
    return status;
}

LUA_API int lua_load (lua_State *L, lua_Reader reader, void *data, const char *chunkname) {
    ZIO z;
    int status;
    lua_lock(L);
    if (!chunkname) {
        chunkname = "?";
    }
    luaZ_init(L, &z, reader, data);
    status = luaD_protectedparser(L, &z, chunkname);
    lua_unlock(L);
    return status;
}

LUA_API int lua_dump (lua_State *L, lua_Writer writer, void *data) {
    int status;
    TValue *o;
    lua_lock(L);
    api_checknelems(L, 1);
    o = L->top - 1;
    if (isLfunction(o)) {
        status = luaU_dump(L, clvalue(o)->l.p, writer, data, 0);
    } else {
        status = 1;
    }
    lua_unlock(L);
    return status;
}

LUA_API int lua_status (lua_State *L) {
    return L->status;
}

/*
** Garbage-collection function
*/

LUA_API int lua_gc (lua_State *L, int what, int data) {
    int res = 0;
    global_State *g;
    lua_lock(L);
    g = G(L);
    switch (what) {
        case LUA_GCSTOP: {
            g->GCthreshold = LUA_PTRDIFF_MAX;
            break;
        }
        case LUA_GCRESTART: {
            g->GCthreshold = g->totalbytes;
            break;
        }
        case LUA_GCCOLLECT: {
            luaC_fullgc(L);
            break;
        }
        case LUA_GCCOUNT: {
            /* GC values are expressed in Kbytes: #bytes/2^10 */
            res = cast_int(g->totalbytes >> 10);
            break;
        }
        case LUA_GCCOUNTB: {
            res = cast_int(g->totalbytes & 0x3ff);
            break;
        }
        case LUA_GCSTEP: {
            size_t a = (cast(size_t, data) << 10);
            if (a <= g->totalbytes) {
                g->GCthreshold = g->totalbytes - a;
            } else {
                g->GCthreshold = 0;
            }
            while (g->GCthreshold <= g->totalbytes) {
                luaC_step(L);
                if (g->gcstate == GCSpause) { /* end of cycle? */
                    res = 1; /* signal it */
                    break;
                }
            }
            break;
        }
        case LUA_GCSETPAUSE: {
            res = g->gcpause;
            g->gcpause = data;
            break;
        }
        case LUA_GCSETSTEPMUL: {
            res = g->gcstepmul;
            g->gcstepmul = data;
            break;
        }
        default:
            res = -1; /* invalid option */
    }
    lua_unlock(L);
    return res;
}

/*
** miscellaneous functions
*/

LUA_API int lua_error (lua_State *L) {
    lua_lock(L);
    api_checknelems(L, 1);
    luaG_errormsg(L);
    lua_unlock(L);
}

LUA_API int lua_next (lua_State *L, int idx) {
    StkId t;
    int more;
    lua_lock(L);
    t = index2adr(L, idx);
    api_check(L, ttistable(t));
    more = luaH_next(L, hvalue(t), L->top - 1);
    if (more) {
        api_incr_top(L);
    } else { /* no more elements */
        L->top -= 1; /* remove key */
    }
    lua_unlock(L);
    return more;
}

LUA_API void lua_concat (lua_State *L, int n) {
    lua_lock(L);
    api_checknelems(L, n);
    if (n >= 2) {
        luaC_checkGC(L);
        luaV_concat(L, n, cast_int(L->top - L->base) - 1);
        L->top -= (n - 1);
    } else if (n == 0) { /* push empty string */
        setsvalue2s(L, L->top, luaS_newlstr(L, "", 0));
        api_incr_top(L);
    }
    /* else n == 1; nothing to do */
    lua_unlock(L);
}

LUA_API lua_Alloc lua_getallocf (lua_State *L, void **ud) {
    lua_Alloc f;
    lua_lock(L);
    if (ud) {
        *ud = G(L)->ud;
    }
    f = G(L)->frealloc;
    lua_unlock(L);
    return f;
}

LUA_API void lua_setallocf (lua_State *L, lua_Alloc f, void *ud) {
    lua_lock(L);
    G(L)->ud = ud;
    G(L)->frealloc = f;
    lua_unlock(L);
}

LUA_API void *lua_newuserdata (lua_State *L, size_t size) {
    Udata *u;
    lua_lock(L);
    luaC_checkGC(L);
    u = luaS_newudata(L, size, getcurrenv(L));
    setuvalue(L, L->top, u);
    api_incr_top(L);
    lua_unlock(L);
    return u + 1;
}

static const char *aux_upvalue (StkId fi, int n, TValue **val) {
    Closure *f;
    if (!ttisfunction(fi)) {
        return NULL;
    }
    f = clvalue(fi);
    if (f->c.isC) {
        if (!(1 <= n && n <= f->c.nupvalues)) {
            return NULL;
        }
        *val = &f->c.upvalue[n - 1];
        return "";
    } else {
        Proto *p = f->l.p;
        if (!(1 <= n && n <= p->sizeupvalues)) {
            return NULL;
        }
        *val = f->l.upvals[n - 1]->v;
        return getstr(p->upvalues[n - 1]);
    }
}

LUA_API const char *lua_getupvalue (lua_State *L, int funcindex, int n) {
    const char *name;
    TValue *val;
    StkId fi;
    lua_lock(L);
    fi = index2adr(L, funcindex);
    name = aux_upvalue(fi, n, &val);
    if (name) {
        setobjuv2s(L, fi, L->top, val);
        api_incr_top(L);
    }
    lua_unlock(L);
    return name;
}

LUA_API const char *lua_setupvalue (lua_State *L, int funcindex, int n) {
    const char *name;
    TValue *val;
    StkId fi;
    lua_lock(L);
    fi = index2adr(L, funcindex);
    api_checknelems(L, 1);
    name = aux_upvalue(fi, n, &val);
    if (name) {
        L->top--;
        setobj2uv(L, fi, val, L->top);
        luaC_barrier(L, clvalue(fi), L->top);
    }
    lua_unlock(L);
    return name;
}

/*
** {======================================================================
** Lua Core Extension APIs
** =======================================================================
*/

LUA_API int lua_absindex (lua_State *L, int idx) {
    if (idx > 0 || idx <= LUA_ERRORHANDLERINDEX) {
        return idx;
    } else {
        return cast_int(L->top - L->base) + idx + 1;
    }
}

LUA_API void lua_copy (lua_State *L, int fromidx, int toidx) {
    StkId fr;
    lua_lock(L);
    fr = index2adr(L, fromidx);
    api_checkvalidindex(L, fr);
    moveto(L, fr, toidx);
    lua_unlock(L);
}

LUA_API size_t lua_objsize (lua_State *L, int idx) {
    StkId o;
    size_t s;

    lua_lock(L);
    o = index2adr(L, idx);
    s = (iscollectable(o) ? luaC_objectsize(gcvalue(o)) : 0);
    lua_unlock(L);

    return s;
}

LUA_API int lua_toint (lua_State *L, int idx) {
    lua_Number d = lua_tonumber(L, idx);
    int i;

    if ((L->exceptmask & LUA_EXCEPTOVERFLOW) && (d < INT_MIN || d > INT_MAX)) {
        lua_lock(L);
        luaG_overflowerror(L, d);
        lua_unlock(L);
    }

    lua_number2int(i, d);
    return i;
}

LUA_API long lua_tolong (lua_State *L, int idx) {
    lua_Number d = lua_tonumber(L, idx);

    /* Checking against INT_MIN/INT_MAX is accurate to reference; LP64 platforms
     * still undergo 32-bit integer range checks in-game. */
    if ((L->exceptmask & LUA_EXCEPTOVERFLOW) && (d < INT_MIN || d > INT_MAX)) {
        lua_lock(L);
        luaG_overflowerror(L, d);
        lua_unlock(L);
    }

    return (long) d;
}

static UpVal **getupvalref (lua_State *L, int fidx, int n, LClosure **pf) {
    LClosure *f;
    StkId fi = index2adr(L, fidx);
    api_check(L, isLfunction(fi)); /* Lua function expected */
    f = &clvalue(fi)->l;
    api_check(L, (1 <= n && n <= f->p->sizeupvalues)); /* invalid upvalue index */
    if (pf) {
        *pf = f;
    }
    return &f->upvals[n - 1]; /* get its upvalue pointer */
}

LUA_API void *lua_upvalueid (lua_State *L, int fidx, int n) {
    StkId fi = index2adr(L, fidx);
    api_check(L, ttisfunction(fi));

    if (isLfunction(fi)) { /* Lua closure */
        return *getupvalref(L, fidx, n, NULL);
    } else if (iscfunction(fi)) { /* C closure */
        CClosure *f = &clvalue(fi)->c;
        api_check(L, 1 <= n && n <= f->nupvalues); /* invalid upvalue index */
        return &f->upvalue[n - 1];
    } else {
        return NULL;
    }
}

LUA_API void lua_upvaluejoin (lua_State *L, int fidx1, int n1, int fidx2, int n2) {
    LClosure *f1;
    UpVal **up1 = getupvalref(L, fidx1, n1, &f1);
    UpVal **up2 = getupvalref(L, fidx2, n2, NULL);
    *up1 = *up2;
    luaC_objbarrier(L, f1, *up2);
}

/**
 * Core Security APIs
 */

static const char *gettaint (const TString *ts) {
    if (ts != NULL) {
        return getstr(ts);
    } else {
        return NULL;
    }
}

static TString *newtaint (lua_State *L, const char *name) {
    TString *taint = NULL;

    if (name != NULL) {
        taint = luaS_new(L, name);
        luaS_fix(taint);
    }

    return taint;
}

LUA_API int lua_gettaintmode (lua_State *L) {
    return cast_int(luaR_gettaintmode(L));
}

LUA_API void lua_settaintmode (lua_State *L, int mode) {
    luaR_settaintmode(L, cast_byte(mode));
}

LUA_API void lua_taintstack (lua_State *L, const char *name) {
    lua_lock(L);
    luaC_checkGC(L);
    luaR_taintstack(L, newtaint(L, name));
    lua_unlock(L);
}

LUA_API void lua_taintvalue (lua_State *L, int idx) {
    StkId o = index2adr(L, idx);
    api_checkvalidindex(L, o);
    luaR_taintvalue(L, o);
}

LUA_API void lua_taintobject (lua_State *L, int idx) {
    StkId o = index2adr(L, idx);
    api_checkvalidindex(L, o);

    if (iscollectable(o)) {
        lua_lock(L);
        luaR_taintobject(L, gcvalue(o));
        lua_unlock(L);
    }
}

LUA_API void lua_tainttop (lua_State *L, int n) {
    StkId o;
    api_checknelems(L, n);

    for (o = (L->top - n); o < L->top; ++o) {
        luaR_taintvalue(L, o);
    }
}

LUA_API const char *lua_getstacktaint (lua_State *L) {
    return gettaint(L->stacktaint);
}

LUA_API const char *lua_getvaluetaint (lua_State *L, int idx) {
    StkId o = index2adr(L, idx);
    api_checkvalidindex(L, o);
    return gettaint(o->taint);
}

LUA_API const char *lua_getobjecttaint (lua_State *L, int idx) {
    StkId o;
    TString *ts;

    lua_lock(L);
    o = index2adr(L, idx);
    api_checkvalidindex(L, o);
    ts = (iscollectable(o) ? gcvalue(o)->gch.taint : NULL);
    lua_unlock(L);

    return gettaint(ts);
}

LUA_API const char *lua_getnewobjecttaint (lua_State *L) {
    return gettaint(L->newgctaint);
}

LUA_API const char *lua_getnewclosuretaint (lua_State *L) {
    return gettaint(L->newcltaint);
}

LUA_API const char *lua_getcalltaint (lua_State *L, const lua_Debug *ar) {
    CallInfo *ci = (L->base_ci + ar->i_ci);
    TString *ts;

    if (ci == L->ci) {
        ts = L->stacktaint;
    } else {
        ts = ci->savedtaint;
    }

    return gettaint(ts);
}

LUA_API void lua_setstacktaint (lua_State *L, const char *name) {
    lua_lock(L);
    luaC_checkGC(L);
    luaR_setstacktaint(L, newtaint(L, name));
    lua_unlock(L);
}

LUA_API void lua_setvaluetaint (lua_State *L, int idx, const char *name) {
    StkId o = index2adr(L, idx);
    api_checkvalidindex(L, o);
    lua_lock(L);
    luaC_checkGC(L);
    o->taint = newtaint(L, name);
    lua_unlock(L);
}

LUA_API void lua_setobjecttaint (lua_State *L, int idx, const char *name) {
    StkId o;

    lua_lock(L);
    o = index2adr(L, idx);
    api_checkvalidindex(L, o);

    if (iscollectable(o)) {
        lua_lock(L);
        luaC_checkGC(L);
        luaR_setobjecttaint(L, gcvalue(o), newtaint(L, name));
        lua_unlock(L);
    }

    lua_unlock(L);
}

LUA_API void lua_settoptaint (lua_State *L, int n, const char *name) {
    StkId o;
    TString *ts;

    api_checknelems(L, n);

    lua_lock(L);
    luaC_checkGC(L);
    ts = newtaint(L, name);

    for (o = (L->top - n); o < L->top; ++o) {
        o->taint = ts;
    }

    lua_unlock(L);
}

LUA_API void lua_setnewobjecttaint (lua_State *L, const char *name) {
    lua_lock(L);
    luaC_checkGC(L);
    luaR_setnewgctaint(L, newtaint(L, name));
    lua_unlock(L);
}

LUA_API void lua_setnewclosuretaint (lua_State *L, const char *name) {
    lua_lock(L);
    luaC_checkGC(L);
    luaR_setnewcltaint(L, newtaint(L, name));
    lua_unlock(L);
}

LUA_API void lua_copytaint (lua_State *from, lua_State *to) {
    luaR_taintthread(to, from);
}

LUA_API void lua_savetaint (lua_State *L, lua_TaintState *ts) {
    ts->mode = cast_int(luaR_gettaintmode(L));
    ts->stacktaint = gettaint(L->stacktaint);
    ts->newobjecttaint = gettaint(L->newgctaint);
    ts->newclosuretaint = gettaint(L->newcltaint);
}

LUA_API void lua_restoretaint (lua_State *L, const lua_TaintState *ts) {
    lua_lock(L);
    luaC_checkGC(L);
    luaR_settaintmode(L, cast_byte(ts->mode));
    luaR_setstacktaint(L, newtaint(L, ts->stacktaint));
    luaR_setnewgctaint(L, newtaint(L, ts->newobjecttaint));
    luaR_setnewcltaint(L, newtaint(L, ts->newclosuretaint));
    lua_unlock(L);
}

LUA_API void lua_exchangetaint (lua_State *L, lua_TaintState *ts) {
    lua_TaintState temp;
    lua_savetaint(L, &temp);
    lua_restoretaint(L, ts);
    *ts = temp;
}

struct PTCallS {
    lua_PFunction func;
    void *ud;
};

void f_PTcall (lua_State *L, void *ud) {
    struct PTCallS *c = cast(struct PTCallS *, ud);
    lua_unlock(L);
    (*c->func)(L, c->ud);
    lua_lock(L);
}

LUA_API void lua_protecttaint (lua_State *L, lua_PFunction func, void *ud) {
    struct TaintState savedts;
    struct PTCallS c;
    int status;

    lua_lock(L);
    c.func = func;
    c.ud = ud;
    luaR_savetaint(L, &savedts);
    status = luaD_rawrunprotected(L, f_PTcall, &c);

    if (status != 0) {
        /* Note that as we're re-throwing we don't unwind CIs here; whoever
         * catches this error is expected to unwind them instead. */

        StkId err = L->top - 1;
        err->taint = NULL;

        luaR_loadtaint(L, &savedts);
        luaD_throw(L, status);
    }

    lua_unlock(L);
}

LUA_API void lua_cleartaint (lua_State *L, int n) {
    StkId o;
    api_checknelems(L, n);

    luaR_setstacktaint(L, NULL);
    luaR_setnewgctaint(L, NULL);
    luaR_setnewcltaint(L, NULL);

    for (o = L->top - n; o < L->top; o++) {
        o->taint = NULL;
    }
}

LUA_API void lua_resettaint (lua_State *L) {
    CallInfo *ci;
    StkId o;

    luaR_settaintmode(L, LUA_TAINTDISABLED);
    luaR_setstacktaint(L, NULL);
    luaR_setnewgctaint(L, NULL);
    luaR_setnewcltaint(L, NULL);

    /* Clear saved taint of all stack frames. */
    for (ci = L->base_ci; ci <= L->ci; ci++) {
        ci->savedtaint = NULL;
    }

    /* Clear taint of all stack values for all stack frames. */
    for (o = L->stack; o < L->top; o++) {
        o->taint = NULL;
    }
}

/**
 * Core Profiling and Statistics APIs
 */

LUA_API lua_Clock lua_clocktime (lua_State *L) {
    lua_Clock ticks;
    lua_lock(L);
    ticks = luaG_clocktime(G(L));
    lua_unlock(L);
    return ticks;
}

LUA_API lua_Clock lua_clockrate (lua_State *L) {
    lua_Clock rate;
    lua_lock(L);
    rate = luaG_clockrate(G(L));
    lua_unlock(L);
    return rate;
}

static SourceStats *getsourcestats (global_State *g, TString *owner) {
    SourceStats *st = g->sourcestats;
    SourceStats *pt = NULL;

    while (st != NULL && st->owner != owner) {
        pt = st;
        st = st->next;
    }

    if (st != NULL && pt != NULL) {
        /* Re-link to place this object at the head of stats list. */
        pt->next = st->next;
        st->next = g->sourcestats;
        g->sourcestats = st;
    }

    return st;
}

static SourceStats *newsourcestats (global_State *g, TString *owner) {
    SourceStats *st = getsourcestats(g, owner);

    if (st == NULL) {
        st = luaM_new(g->mainthread, SourceStats);
        st->owner = owner;
        st->execticks = 0;
        st->bytesowned = 0;
        st->next = g->sourcestats;
        g->sourcestats = st;
    }

    return st;
}

static void resetsourcestats (global_State *g) {
    SourceStats *st;

    /* Reset source-owned statistics */
    for (st = g->sourcestats; st != NULL; st = st->next) {
        st->execticks = 0;
        st->bytesowned = 0;
    }
}

static void resetfunctionstats (global_State *g) {
    GCObject *o;

    for (o = g->rootgc; o != NULL; o = o->gch.next) {
        if (ttisfunction(&o->gch)) {
            ClosureStats *cs = gco2cl(o)->c.stats;

            if (cs != NULL) {
                cs->calls = 0;
                cs->ownticks = 0;
                cs->subticks = 0;
            }
        }
    }
}

LUA_API int lua_isprofilingenabled (lua_State *L) {
    int enabled;

    lua_lock(L);
    enabled = G(L)->enablestats;
    lua_unlock(L);

    return enabled;
}

LUA_API void lua_setprofilingenabled (lua_State *L, int enable) {
    global_State *g;

    lua_lock(L);
    g = G(L);

    if (enable && !g->enablestats) { /* Enabling? */
        GCObject *o;
        luaC_checkGC(L);

        /* Allocate closure statistics */
        for (o = g->rootgc; o != NULL; o = o->gch.next) {
            if (ttisfunction(&o->gch)) {
                Closure *cl = gco2cl(o);

                if (cl->c.stats == NULL) {
                    cl->c.stats = luaF_newclosurestats(g->mainthread);
                }
            }
        }
    }

    g->enablestats = cast_byte(enable);
    lua_unlock(L);
}

LUA_API void lua_collectstats (lua_State *L) {
    global_State *g;
    GCObject *o;

    lua_lock(L);
    g = G(L);

    luaC_checkGC(L);
    resetsourcestats(g);

    for (o = g->rootgc; o != NULL; o = o->gch.next) {
        SourceStats *st = newsourcestats(g, o->gch.taint);

        st->bytesowned += luaC_objectsize(o);

        if (ttisfunction(&o->gch)) {
            ClosureStats *cs = gco2cl(o)->c.stats;

            if (cs != NULL) {
                st->execticks += cs->ownticks;
            }
        }
    }

    lua_unlock(L);
}

LUA_API void lua_resetstats (lua_State *L) {
    lua_lock(L);
    resetsourcestats(G(L));
    resetfunctionstats(G(L));
    lua_unlock(L);
}

LUA_API void lua_getglobalstats (lua_State *L, lua_GlobalStats *stats) {
    global_State *g;
    lua_lock(L);
    g = G(L);
    stats->bytesused = g->totalbytes;
    stats->bytesallocated = g->bytesallocated;
    lua_unlock(L);
}

LUA_API void lua_getsourcestats (lua_State *L, const char *source, lua_SourceStats *stats) {
    TString *ts;
    SourceStats *st;

    lua_lock(L);
    luaC_checkGC(L);
    ts = ((source != NULL) ? luaS_new(L, source) : NULL);
    st = getsourcestats(G(L), ts);

    if (st != NULL) {
        stats->execticks = st->execticks;
        stats->bytesowned = st->bytesowned;
    } else {
        stats->execticks = 0;
        stats->bytesowned = 0;
    }

    lua_unlock(L);
}

LUA_API void lua_getfunctionstats (lua_State *L, int funcindex, lua_FunctionStats *stats) {
    StkId o;
    ClosureStats *cs;

    lua_lock(L);
    o = index2adr(L, funcindex);
    api_checkvalidindex(L, o);
    api_check(L, ttisfunction(o));
    cs = clvalue(o)->c.stats;

    if (cs != NULL) {
        stats->calls = cs->calls;
        stats->ownticks = cs->ownticks;
        stats->subticks = cs->subticks;
    } else {
        stats->calls = 0;
        stats->ownticks = 0;
        stats->subticks = 0;
    }

    lua_unlock(L);
}

/**
 * Core Debugging and Exception APIs
 */

LUA_API int lua_getexceptmask (lua_State *L) {
    return cast_int(L->exceptmask);
}

LUA_API void lua_setexceptmask (lua_State *L, int mask) {
    L->exceptmask = cast_byte(mask);
}

LUA_API void lua_getscripttimeout (lua_State *L, lua_ScriptTimeout *timeout) {
    lua_lock(L);
    timeout->ticks = L->baseexeclimit;
    timeout->instructions = L->baseexeccount;
    lua_unlock(L);
}

LUA_API void lua_setscripttimeout (lua_State *L, const lua_ScriptTimeout *timeout) {
    lua_lock(L);

    if (timeout->ticks == 0 || timeout->instructions == 0) {
        L->baseexeclimit = 0;
        L->baseexeccount = L->execcount = 0;
    } else {
        L->baseexeclimit = timeout->ticks;
        L->baseexeccount = L->execcount = timeout->instructions;
    }

    lua_unlock(L);
}

LUA_API int lua_ishookallowed (lua_State *L) {
    return cast_int(L->allowhook);
}

/**
 * Runtime Compatibility Options APIs
 */

LUA_API int lua_getcompatopt (lua_State *L, int opt) {
    switch (opt) {
        case LUA_COMPATSETFENV:
        case LUA_COMPATGCTAINT:
        case LUA_COMPATGCDEBUG:
        case LUA_COMPATINERRORHANDLER:
            return testbit(L->compatmask, opt) >> opt;
        default:
            return 0;
    }
}

LUA_API void lua_setcompatopt (lua_State *L, int opt, int val) {
    switch (opt) {
        case LUA_COMPATSETFENV:
        case LUA_COMPATGCTAINT:
        case LUA_COMPATGCDEBUG:
        case LUA_COMPATINERRORHANDLER:
            L->compatmask = cast_byte((L->compatmask & ~bitmask(opt)) | ((val & 0x1) << opt));
            return;
        default:
            return;
    }
}

/* }====================================================================== */
