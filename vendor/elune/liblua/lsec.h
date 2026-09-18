/* Licensed under the terms of the MIT License; see full copyright information
 * in the "LICENSE" file or at <http://www.lua.org/license.html> */

#ifndef lsec_h
#define lsec_h

#include "lobject.h"
#include "lstate.h"

enum TaintFlags {
    LUA_TAINTFLAG_RD = 0x1,
    LUA_TAINTFLAG_WR = 0x2,

    LUA_TAINTMASK_MODE = LUA_TAINTFLAG_RD | LUA_TAINTFLAG_WR,
};

struct TaintState {
    lu_byte mode;
    TString *stacktaint;
    TString *newgctaint;
    TString *newcltaint;
};

inline lu_byte luaR_gettaintmode (lua_State *L) {
    return (L->taintflags & LUA_TAINTMASK_MODE);
}

inline void luaR_settaintmode (lua_State *L, lu_byte mode) {
    L->taintflags = (mode & LUA_TAINTMASK_MODE) | (L->taintflags & ~LUA_TAINTMASK_MODE);
    L->writetaint = (L->taintflags & LUA_TAINTFLAG_WR) ? L->stacktaint : NULL;
}

inline void luaR_setstacktaint (lua_State *L, TString *taint) {
    L->stacktaint = taint;
    L->writetaint = (L->taintflags & LUA_TAINTFLAG_WR) ? taint : NULL;
}

inline void luaR_setnewgctaint (lua_State *L, TString *taint) {
    L->newgctaint = taint;
}

inline void luaR_setnewcltaint (lua_State *L, TString *taint) {
    L->newcltaint = taint;
}

inline void luaR_setobjecttaint (lua_State *L, GCObject *o, TString *taint) {
    lua_unused(L);
    o->gch.taint = taint;
}

inline void luaR_taintstack (lua_State *L, TString *taint) {
    if (taint != NULL && L->fixedtaint == NULL && (L->taintflags & LUA_TAINTFLAG_RD)) {
        luaR_setstacktaint(L, taint);
    }
}

inline void luaR_taintvalue (lua_State *L, TValue *o) {
    TString *taint = L->writetaint;

    if (taint != NULL) {
        o->taint = taint;
    }
}

inline void luaR_taintobject (lua_State *L, GCObject *o) {
    TString *taint = L->writetaint;

    if (taint != NULL) {
        luaR_setobjecttaint(L, o, taint);
    }
}

inline void luaR_taintalloc (lua_State *L, GCObject *o) {
    TString *taint = NULL;

    lua_assert(iscollectable(&o->gch));

    if (L->newgctaint != NULL) {
        taint = L->newgctaint;
    } else if (L->writetaint != NULL) {
        taint = L->writetaint;
    } else if (L->newcltaint != NULL && ttisfunction(&o->gch)) {
        taint = L->newcltaint;
    }

    o->gch.taint = taint;
}

inline void luaR_taintthread (lua_State *L, lua_State *from) {
    lua_assert(from->fixedtaint == NULL);
    lua_assert(L->fixedtaint == NULL);

    luaR_settaintmode(L, luaR_gettaintmode(from));
    luaR_setstacktaint(L, from->stacktaint);
    luaR_setnewgctaint(L, from->newgctaint);
    luaR_setnewcltaint(L, from->newcltaint);
}

inline void luaR_savetaint (lua_State *L, struct TaintState *ts) {
    ts->mode = luaR_gettaintmode(L);
    ts->stacktaint = L->stacktaint;
    ts->newgctaint = L->newgctaint;
    ts->newcltaint = L->newcltaint;
}

inline void luaR_loadtaint (lua_State *L, const struct TaintState *ts) {
    luaR_settaintmode(L, ts->mode);
    luaR_setstacktaint(L, ts->stacktaint);
    luaR_setnewgctaint(L, ts->newgctaint);
    luaR_setnewcltaint(L, ts->newcltaint);
}

#endif
