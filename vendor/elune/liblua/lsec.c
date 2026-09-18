/* Licensed under the terms of the MIT License; see full copyright information
 * in the "LICENSE" file or at <http://www.lua.org/license.html> */

#define lsec_c
#define LUA_CORE

#include "lsec.h"

extern lu_byte luaR_gettaintmode (lua_State *L);
extern void luaR_settaintmode (lua_State *L, lu_byte mode);
extern void luaR_setstacktaint (lua_State *L, TString *taint);
extern void luaR_setnewgctaint (lua_State *L, TString *taint);
extern void luaR_setnewcltaint (lua_State *L, TString *taint);
extern void luaR_setobjecttaint (lua_State *L, GCObject *o, TString *taint);
extern void luaR_taintstack (lua_State *L, TString *taint);
extern void luaR_taintvalue (lua_State *L, TValue *o);
extern void luaR_taintobject (lua_State *L, GCObject *o);
extern void luaR_taintalloc (lua_State *L, GCObject *o);
extern void luaR_taintthread (lua_State *L, lua_State *from);
extern void luaR_savetaint (lua_State *L, struct TaintState *ts);
extern void luaR_loadtaint (lua_State *L, const struct TaintState *ts);
