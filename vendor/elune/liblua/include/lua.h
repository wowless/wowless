/**
 * Lua - An Extensible Extension Language
 *
 * Licensed under the terms of the MIT License; see full copyright information
 * in the "LICENSE" file or at <http://www.lua.org/license.html>
 */

#ifndef lua_h
#define lua_h

#include "luaconf.h"

#include <stdarg.h>
#include <stddef.h>

/* Lua version number; defined here for luarocks compat. */
#define LUA_VERSION_NUM 501

/* mark for precompiled code (`<esc>Lua') */
#define LUA_SIGNATURE "\033Lua"

/* option for multiple returns in `lua_pcall' and `lua_call' */
#define LUA_MULTRET (-1)

/* Pseudo-indices accepted by most C APIs. */
enum lua_PseudoIndex {
    LUA_ERRORHANDLERINDEX = -9999,
    LUA_REGISTRYINDEX = -10000,
    LUA_ENVIRONINDEX = -10001,
    LUA_GLOBALSINDEX = -10002,
};

#define lua_upvalueindex(i) (LUA_GLOBALSINDEX - (i))

/* Thread status values; 0 is OK. */
enum lua_Status {
    LUA_OK = 0,
    LUA_YIELD = 1,
    LUA_ERRRUN = 2,
    LUA_ERRSYNTAX = 3,
    LUA_ERRMEM = 4,
    LUA_ERRERR = 5,
};

typedef struct lua_State lua_State;

typedef int (*lua_CFunction)(lua_State *L);

/*
** functions that read/write blocks when loading/dumping Lua chunks
*/
typedef const char *(*lua_Reader)(lua_State *L, void *ud, size_t *sz);

typedef int (*lua_Writer)(lua_State *L, const void *p, size_t sz, void *ud);

/*
** prototype for memory-allocation functions
*/
typedef void *(*lua_Alloc)(void *ud, void *ptr, size_t osize, size_t nsize);

/* Basic Lua types */
enum lua_Type {
    LUA_TNONE = -1,
    LUA_TNIL = 0,
    LUA_TBOOLEAN = 1,
    LUA_TLIGHTUSERDATA = 2,
    LUA_TNUMBER = 3,
    LUA_TSTRING = 4,
    LUA_TTABLE = 5,
    LUA_TFUNCTION = 6,
    LUA_TUSERDATA = 7,
    LUA_TTHREAD = 8,
};

/* Predefined values in the registry. */
enum lua_RegistryIndex {
    LUA_NOREF = -2,
    LUA_REFNIL = -1,
    LUA_RIDX_MAINTHREAD = 1,
    LUA_RIDX_INERRORHANDLER = 2,
    LUA_RIDX_LAST = LUA_RIDX_MAINTHREAD,
};

/*
** generic extra include file
*/
#if defined(LUA_USER_H)
#include LUA_USER_H
#endif

/* Type of numbers in Lua. */
typedef LUA_NUMBER lua_Number;

/* Type for integer functions. */
typedef LUA_INTEGER lua_Integer;

/*
** state manipulation
*/
LUA_API lua_State *lua_newstate (lua_Alloc f, void *ud);
LUA_API void lua_close (lua_State *L);
LUA_API lua_State *lua_newthread (lua_State *L);

LUA_API lua_CFunction lua_atpanic (lua_State *L, lua_CFunction panicf);

/*
** basic stack manipulation
*/
LUA_API int lua_gettop (lua_State *L);
LUA_API void lua_settop (lua_State *L, int idx);
LUA_API void lua_pushvalue (lua_State *L, int idx);
LUA_API void lua_remove (lua_State *L, int idx);
LUA_API void lua_insert (lua_State *L, int idx);
LUA_API void lua_replace (lua_State *L, int idx);
LUA_API int lua_checkstack (lua_State *L, int sz);

LUA_API void lua_xmove (lua_State *from, lua_State *to, int n);

/*
** access functions (stack -> C)
*/

LUA_API int lua_isnumber (lua_State *L, int idx);
LUA_API int lua_isstring (lua_State *L, int idx);
LUA_API int lua_iscfunction (lua_State *L, int idx);
LUA_API int lua_isuserdata (lua_State *L, int idx);
LUA_API int lua_type (lua_State *L, int idx);
LUA_API const char *lua_typename (lua_State *L, int tp);

LUA_API int lua_equal (lua_State *L, int idx1, int idx2);
LUA_API int lua_rawequal (lua_State *L, int idx1, int idx2);
LUA_API int lua_lessthan (lua_State *L, int idx1, int idx2);

LUA_API lua_Number lua_tonumber (lua_State *L, int idx);
LUA_API lua_Integer lua_tointeger (lua_State *L, int idx);
LUA_API int lua_toboolean (lua_State *L, int idx);
LUA_API const char *lua_tolstring (lua_State *L, int idx, size_t *len);
LUA_API size_t lua_objlen (lua_State *L, int idx);
LUA_API lua_CFunction lua_tocfunction (lua_State *L, int idx);
LUA_API void *lua_touserdata (lua_State *L, int idx);
LUA_API lua_State *lua_tothread (lua_State *L, int idx);
LUA_API const void *lua_topointer (lua_State *L, int idx);

/*
** push functions (C -> stack)
*/
LUA_API void lua_pushnil (lua_State *L);
LUA_API void lua_pushnumber (lua_State *L, lua_Number n);
LUA_API void lua_pushinteger (lua_State *L, lua_Integer n);
LUA_API void lua_pushlstring (lua_State *L, const char *s, size_t l);
LUA_API void lua_pushstring (lua_State *L, const char *s);
LUA_API const char *lua_pushvfstring (lua_State *L, const char *fmt, va_list argp);
LUA_API const char *lua_pushfstring (lua_State *L, const char *fmt, ...);
LUA_API void lua_pushcclosure (lua_State *L, lua_CFunction fn, int n);
LUA_API void lua_pushboolean (lua_State *L, int b);
LUA_API void lua_pushlightuserdata (lua_State *L, void *p);
LUA_API int lua_pushthread (lua_State *L);

/*
** get functions (Lua -> stack)
*/
LUA_API void lua_gettable (lua_State *L, int idx);
LUA_API void lua_getfield (lua_State *L, int idx, const char *k);
LUA_API void lua_rawget (lua_State *L, int idx);
LUA_API void lua_rawgeti (lua_State *L, int idx, int n);
LUA_API void lua_createtable (lua_State *L, int narr, int nrec);
LUA_API void *lua_newuserdata (lua_State *L, size_t sz);
LUA_API int lua_getmetatable (lua_State *L, int objindex);
LUA_API void lua_getfenv (lua_State *L, int idx);

/*
** set functions (stack -> Lua)
*/
LUA_API void lua_settable (lua_State *L, int idx);
LUA_API void lua_setfield (lua_State *L, int idx, const char *k);
LUA_API void lua_rawset (lua_State *L, int idx);
LUA_API void lua_rawseti (lua_State *L, int idx, int n);
LUA_API int lua_setmetatable (lua_State *L, int objindex);
LUA_API int lua_setfenv (lua_State *L, int idx);

/*
** `load' and `call' functions (load and run Lua code)
*/
LUA_API void lua_call (lua_State *L, int nargs, int nresults);
LUA_API int lua_pcall (lua_State *L, int nargs, int nresults, int errfunc);
LUA_API int lua_cpcall (lua_State *L, lua_CFunction func, void *ud);
LUA_API int lua_load (lua_State *L, lua_Reader reader, void *dt, const char *chunkname);

LUA_API int lua_dump (lua_State *L, lua_Writer writer, void *data);

/*
** coroutine functions
*/
LUA_API int lua_yield (lua_State *L, int nresults);
LUA_API int lua_resume (lua_State *L, int nargs);
LUA_API int lua_status (lua_State *L);

/*
** garbage-collection function and options
*/

enum lua_GCOption {
    LUA_GCSTOP = 0,
    LUA_GCRESTART = 1,
    LUA_GCCOLLECT = 2,
    LUA_GCCOUNT = 3,
    LUA_GCCOUNTB = 4,
    LUA_GCSTEP = 5,
    LUA_GCSETPAUSE = 6,
    LUA_GCSETSTEPMUL = 7,
};

LUA_API int lua_gc (lua_State *L, int what, int dat);

/*
** miscellaneous functions
*/

LUA_API int lua_error (lua_State *L);

LUA_API int lua_next (lua_State *L, int idx);

LUA_API void lua_concat (lua_State *L, int n);

LUA_API lua_Alloc lua_getallocf (lua_State *L, void **ud);
LUA_API void lua_setallocf (lua_State *L, lua_Alloc f, void *ud);

/*
** ===============================================================
** some useful macros
** ===============================================================
*/

#define lua_pop(L, n) lua_settop(L, -(n) -1)

#define lua_newtable(L) lua_createtable(L, 0, 0)

#define lua_register(L, n, f) (lua_pushcfunction(L, (f)), lua_setglobal(L, (n)))

#define lua_pushcfunction(L, f) lua_pushcclosure(L, (f), 0)

#define lua_strlen(L, i) lua_objlen(L, (i))

#define lua_isfunction(L, n) (lua_type(L, (n)) == LUA_TFUNCTION)
#define lua_istable(L, n) (lua_type(L, (n)) == LUA_TTABLE)
#define lua_islightuserdata(L, n) (lua_type(L, (n)) == LUA_TLIGHTUSERDATA)
#define lua_isnil(L, n) (lua_type(L, (n)) == LUA_TNIL)
#define lua_isboolean(L, n) (lua_type(L, (n)) == LUA_TBOOLEAN)
#define lua_isthread(L, n) (lua_type(L, (n)) == LUA_TTHREAD)
#define lua_isnone(L, n) (lua_type(L, (n)) == LUA_TNONE)
#define lua_isnoneornil(L, n) (lua_type(L, (n)) <= 0)

#define lua_pushliteral(L, s) lua_pushlstring(L, "" s, (sizeof(s) / sizeof(char)) - 1)

#define lua_setglobal(L, s) lua_setfield(L, LUA_GLOBALSINDEX, (s))
#define lua_getglobal(L, s) lua_getfield(L, LUA_GLOBALSINDEX, (s))

#define lua_tostring(L, i) lua_tolstring(L, (i), NULL)

/*
** compatibility macros and functions
*/

#define lua_open() luaL_newstate()

#define lua_getregistry(L) lua_pushvalue(L, LUA_REGISTRYINDEX)

#define lua_getgccount(L) lua_gc(L, LUA_GCCOUNT, 0)

#define lua_Chunkreader lua_Reader
#define lua_Chunkwriter lua_Writer

/* hack */
LUA_API void lua_setlevel (lua_State *from, lua_State *to);

/*
** {======================================================================
** Debug API
** =======================================================================
*/

/*
** Event codes
*/
enum lua_HookEvent {
    LUA_HOOKCALL = 0,
    LUA_HOOKRET = 1,
    LUA_HOOKLINE = 2,
    LUA_HOOKCOUNT = 3,
    LUA_HOOKTAILRET = 4,
};

/*
** Event masks
*/
enum lua_HookMask {
    LUA_MASKCALL = (1 << LUA_HOOKCALL),
    LUA_MASKRET = (1 << LUA_HOOKRET),
    LUA_MASKLINE = (1 << LUA_HOOKLINE),
    LUA_MASKCOUNT = (1 << LUA_HOOKCOUNT),
};

typedef struct lua_Debug lua_Debug; /* activation record */

/* Functions to be called by the debuger in specific events */
typedef void (*lua_Hook)(lua_State *L, lua_Debug *ar);

LUA_API int lua_getstack (lua_State *L, int level, lua_Debug *ar);
LUA_API int lua_getinfo (lua_State *L, const char *what, lua_Debug *ar);
LUA_API const char *lua_getlocal (lua_State *L, const lua_Debug *ar, int n);
LUA_API const char *lua_setlocal (lua_State *L, const lua_Debug *ar, int n);
LUA_API const char *lua_getupvalue (lua_State *L, int funcindex, int n);
LUA_API const char *lua_setupvalue (lua_State *L, int funcindex, int n);

LUA_API int lua_sethook (lua_State *L, lua_Hook func, int mask, int count);
LUA_API lua_Hook lua_gethook (lua_State *L);
LUA_API int lua_gethookmask (lua_State *L);
LUA_API int lua_gethookcount (lua_State *L);

struct lua_Debug {
    int event;
    const char *name; /* (n) */
    const char *namewhat; /* (n) `global', `local', `field', `method' */
    const char *what; /* (S) `Lua', `C', `main', `tail' */
    const char *source; /* (S) */
    int currentline; /* (l) */
    int nups; /* (u) number of upvalues */
    int linedefined; /* (S) */
    int lastlinedefined; /* (S) */
    char short_src[LUA_IDSIZE]; /* (S) */
    /* private part */
    int i_ci; /* active function */
};

/* }====================================================================== */

/*
** {======================================================================
** Lua Core Extension APIs
** =======================================================================
*/

LUA_API int lua_absindex (lua_State *L, int idx);
LUA_API void lua_copy (lua_State *L, int fromidx, int toidx);
LUA_API size_t lua_objsize (lua_State *L, int idx);
LUA_API int lua_resumefrom (lua_State *L, lua_State *from, int nargs);
LUA_API int lua_toint (lua_State *L, int idx);
LUA_API long lua_tolong (lua_State *L, int idx);
LUA_API void *lua_upvalueid (lua_State *L, int fidx, int n);
LUA_API void lua_upvaluejoin (lua_State *L, int fidx1, int n1, int fidx2, int n2);

/**
 * Security APIs
 */

typedef void (*lua_PFunction)(lua_State *L, void *ud);

enum lua_TaintMode {
    LUA_TAINTDISABLED, /* Disable all propagation of taint. */
    LUA_TAINTRDONLY, /* Propagate taint to stack on reads only. */
    LUA_TAINTWRONLY, /* Propagate taint to values on writes only. */
    LUA_TAINTRDRW, /* Propagate taint on all reads and writes. */
};

typedef struct lua_TaintState {
    int mode;
    const char *stacktaint;
    const char *newobjecttaint;
    const char *newclosuretaint;
} lua_TaintState;

LUA_API int lua_gettaintmode (lua_State *L);
LUA_API void lua_settaintmode (lua_State *L, int mode);

LUA_API void lua_taintstack (lua_State *L, const char *name);
LUA_API void lua_taintvalue (lua_State *L, int idx);
LUA_API void lua_taintobject (lua_State *L, int idx);
LUA_API void lua_tainttop (lua_State *L, int n);

LUA_API const char *lua_getstacktaint (lua_State *L);
LUA_API const char *lua_getvaluetaint (lua_State *L, int idx);
LUA_API const char *lua_getobjecttaint (lua_State *L, int idx);
LUA_API const char *lua_getnewobjecttaint (lua_State *L);
LUA_API const char *lua_getnewclosuretaint (lua_State *L);
LUA_API const char *lua_getcalltaint (lua_State *L, const lua_Debug *ar);

LUA_API void lua_setstacktaint (lua_State *L, const char *name);
LUA_API void lua_setvaluetaint (lua_State *L, int idx, const char *name);
LUA_API void lua_setobjecttaint (lua_State *L, int idx, const char *name);
LUA_API void lua_settoptaint (lua_State *L, int n, const char *name);
LUA_API void lua_setnewobjecttaint (lua_State *L, const char *name);
LUA_API void lua_setnewclosuretaint (lua_State *L, const char *name);

LUA_API void lua_copytaint (lua_State *from, lua_State *to);
LUA_API void lua_savetaint (lua_State *L, lua_TaintState *ts);
LUA_API void lua_restoretaint (lua_State *L, const lua_TaintState *ts);
LUA_API void lua_exchangetaint (lua_State *L, lua_TaintState *ts);
LUA_API void lua_protecttaint (lua_State *L, lua_PFunction func, void *ud);
LUA_API void lua_cleartaint (lua_State *L, int n);
LUA_API void lua_resettaint (lua_State *L);

/**
 * Profiling and Statistics APIs
 */

typedef int64_t lua_Clock;

typedef struct lua_GlobalStats {
    size_t bytesused; /* total number of bytes in use */
    size_t bytesallocated; /* total number of bytes allocated */
} lua_GlobalStats;

typedef struct lua_SourceStats {
    lua_Clock execticks; /* ticks spent executing owned functions */
    size_t bytesowned; /* total byte size owned objects */
} lua_SourceStats;

typedef struct lua_FunctionStats {
    int calls; /* number of calls */
    lua_Clock ownticks; /* ticks spent executing this function */
    lua_Clock subticks; /* as above but including calls to subroutines */
} lua_FunctionStats;

LUA_API lua_Clock lua_clocktime (lua_State *L);
LUA_API lua_Clock lua_clockrate (lua_State *L);

LUA_API int lua_isprofilingenabled (lua_State *L);
LUA_API void lua_setprofilingenabled (lua_State *L, int enable);

LUA_API void lua_collectstats (lua_State *L);
LUA_API void lua_resetstats (lua_State *L);

LUA_API void lua_getglobalstats (lua_State *L, lua_GlobalStats *stats);
LUA_API void lua_getsourcestats (lua_State *L, const char *source, lua_SourceStats *stats);
LUA_API void lua_getfunctionstats (lua_State *L, int funcindex, lua_FunctionStats *stats);

/**
 * Debugging and Exception APIs
 */

enum lua_ExceptMask {
    LUA_EXCEPTFPECOERCE = (1 << 0),
    LUA_EXCEPTFPESTRICT = (1 << 1),
    LUA_EXCEPTOVERFLOW = (1 << 2),
};

typedef struct lua_ScriptTimeout {
    lua_Clock ticks; /* how long to allow execution before timing out? */
    int instructions; /* how many instructions between each check? */
} lua_ScriptTimeout;

LUA_API int lua_getexceptmask (lua_State *L);
LUA_API void lua_setexceptmask (lua_State *L, int mask);

LUA_API void lua_getscripttimeout (lua_State *L, lua_ScriptTimeout *timeout);
LUA_API void lua_setscripttimeout (lua_State *L, const lua_ScriptTimeout *timeout);

LUA_API int lua_ishookallowed (lua_State *L);

/**
 * Runtime Compatibility Options APIs
 */

enum lua_CompatOption {
    LUA_COMPATSETFENV, /* Allow replacement of protected function environments? (boolean) */
    LUA_COMPATGCTAINT, /* Invoke '__gc' metamethods without a taint barrier? (boolean) */
    LUA_COMPATGCDEBUG, /* Allow collection of debug info from '__gc' metamethods? (boolean) */
    LUA_COMPATINERRORHANDLER, /* Disable 'debuglocals' if called outside an error handler? (boolean) */
};

LUA_API int lua_getcompatopt (lua_State *L, int opt);
LUA_API void lua_setcompatopt (lua_State *L, int opt, int val);

/* }====================================================================== */

/******************************************************************************
 * Copyright (C) 1994-2012 Lua.org, PUC-Rio.  All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 ******************************************************************************/

#endif
