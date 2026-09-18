/* Licensed under the terms of the MIT License; see full copyright information
 * in the "LICENSE" file or at <http://www.lua.org/license.html> */

#ifndef lstate_h
#define lstate_h

#include "lua.h"

#include "lobject.h"
#include "ltm.h"
#include "lzio.h"

struct lua_longjmp; /* defined in ldo.c */

/* table of globals */
#define gt(L) (&L->l_gt)

/* registry */
#define registry(L) (&G(L)->l_registry)

/* extra stack space to handle TM calls and some other extras */
#define EXTRA_STACK 5

#define BASIC_CI_SIZE 8

#define BASIC_STACK_SIZE (2 * LUA_MINSTACK)

typedef struct stringtable {
    GCObject **hash;
    uint_least32_t nuse; /* number of elements */
    int size;
} stringtable;

/*
** informations about a call
*/
typedef struct CallInfo {
    StkId base; /* base for this function */
    StkId func; /* function index in the stack */
    StkId top; /* top for this function */
    const Instruction *savedpc;
    TString *savedtaint; /* saved taint for this call; informational only */
    lua_Clock entryticks; /* tick count on first initial entry or resumption of this call */
    lua_Clock startticks; /* tick count on last reentry of this function */
    int nresults; /* expected number of results from this function */
    int tailcalls; /* number of tail calls lost under this entry */
} CallInfo;

#define curr_func(L) (clvalue(L->ci->func))
#define ci_func(ci) (clvalue((ci)->func))
#define f_isLua(ci) (!ci_func(ci)->c.isC)
#define isLua(ci) (ttisfunction((ci)->func) && f_isLua(ci))

/*
** Profiling Stats
*/
typedef struct SourceStats {
    TString *owner;
    lua_Clock execticks; /* ticks spent executing owned functions */
    size_t bytesowned; /* total size of owned allocations */
    struct SourceStats *next;
} SourceStats;

/*
** `global state', shared by all threads of this state
*/
typedef struct global_State {
    stringtable strt; /* hash table for strings */
    lua_Alloc frealloc; /* function to reallocate memory */
    void *ud; /* auxiliary data to `frealloc' */
    lu_byte enablestats;
    lu_byte currentwhite;
    lu_byte gcstate; /* state of garbage collector */
    int sweepstrgc; /* position of sweep in `strt' */
    GCObject *rootgc; /* list of all collectable objects */
    GCObject **sweepgc; /* position of sweep in `rootgc' */
    GCObject *gray; /* list of gray objects */
    GCObject *grayagain; /* list of objects to be traversed atomically */
    GCObject *weak; /* list of weak tables (to be cleared) */
    GCObject *tmudata; /* last element of list of userdata to be GC */
    Mbuffer buff; /* temporary buffer for string concatentation */
    size_t GCthreshold;
    size_t totalbytes; /* number of bytes currently allocated */
    size_t estimate; /* an estimate of number of bytes actually in use */
    size_t gcdept; /* how much GC is `behind schedule' */
    int gcpause; /* size of pause between successive GCs */
    int gcstepmul; /* GC `granularity' */
    lua_Clock startticks; /* tick count at startup */
    lua_Clock tickfreq; /* tick frequency; cached on startup */
    size_t bytesallocated; /* total number of bytes allocated */
    SourceStats *sourcestats; /* list of source-specific statistics */
    lua_CFunction panic; /* to be called in unprotected errors */
    TValue l_registry;
    TValue l_errfunc; /* global error handler */
    struct lua_State *mainthread;
    UpVal uvhead; /* head of double-linked list of all open upvalues */
    struct Table *mt[NUM_TAGS]; /* metatables for basic types */
    TString *tmname[TM_N]; /* array with tag-method names */
} global_State;

/*
** `per thread' state
*/
struct lua_State {
    CommonHeader;
    lu_byte status;
    lu_byte taintflags; /* user-controlled taint propagation mode flags */
    TString *stacktaint; /* current stack taint */
    TString *writetaint; /* taint applied to values on stack writes */
    TString *fixedtaint; /* taint applied from currently executing Lua closure */
    TString *newgctaint; /* taint applied to newly allocated objects */
    TString *newcltaint; /* taint applied to newly allocated closures */
    StkId top; /* first free slot in the stack */
    StkId base; /* base of current function */
    global_State *l_G;
    CallInfo *ci; /* call info for current function */
    const Instruction *savedpc; /* `savedpc' of current function */
    StkId stack_last; /* last free slot in the stack */
    StkId stack; /* stack base */
    CallInfo *end_ci; /* points after end of ci array*/
    CallInfo *base_ci; /* array of CallInfo's */
    int stacksize;
    int size_ci; /* size of array `base_ci' */
    unsigned short nCcalls; /* number of nested C calls */
    unsigned short baseCcalls; /* nested C calls when resuming coroutine */
    lu_byte compatmask;
    lu_byte exceptmask;
    lu_byte hookmask;
    lu_byte allowhook;
    int basehookcount;
    int hookcount;
    lua_Clock baseexeclimit;
    int baseexeccount;
    int execcount;
    lua_Hook hook;
    TValue l_gt; /* table of globals */
    TValue env; /* temporary place for environments */
    GCObject *openupval; /* list of open upvalues in this stack */
    GCObject *gclist;
    struct lua_longjmp *errorJmp; /* current error recover point */
    ptrdiff_t errfunc; /* current error handling function (stack index) */
};

#define G(L) (L->l_G)

/*
** Union of all collectable objects
*/
union GCObject {
    GCheader gch;
    union TString ts;
    union Udata u;
    union Closure cl;
    struct Table h;
    struct Proto p;
    struct UpVal uv;
    struct lua_State th; /* thread */
};

/* macros to convert a GCObject into a specific value */
#define rawgco2ts(o) check_exp((o)->gch.tt == LUA_TSTRING, &((o)->ts))
#define gco2ts(o) (&rawgco2ts(o)->tsv)
#define rawgco2u(o) check_exp((o)->gch.tt == LUA_TUSERDATA, &((o)->u))
#define gco2u(o) (&rawgco2u(o)->uv)
#define gco2cl(o) check_exp((o)->gch.tt == LUA_TFUNCTION, &((o)->cl))
#define gco2h(o) check_exp((o)->gch.tt == LUA_TTABLE, &((o)->h))
#define gco2p(o) check_exp((o)->gch.tt == LUA_TPROTO, &((o)->p))
#define gco2uv(o) check_exp((o)->gch.tt == LUA_TUPVAL, &((o)->uv))
#define ngcotouv(o) check_exp((o) == NULL || (o)->gch.tt == LUA_TUPVAL, &((o)->uv))
#define gco2th(o) check_exp((o)->gch.tt == LUA_TTHREAD, &((o)->th))

/* macro to convert any Lua object into a GCObject */
#define obj2gco(v) (cast(GCObject *, (v)))

LUAI_FUNC lua_State *luaE_newthread (lua_State *L);
LUAI_FUNC void luaE_freethread (lua_State *L, lua_State *L1);

#endif
