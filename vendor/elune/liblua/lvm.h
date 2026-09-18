/* Licensed under the terms of the MIT License; see full copyright information
 * in the "LICENSE" file or at <http://www.lua.org/license.html> */

#ifndef lvm_h
#define lvm_h

#include "ldo.h"
#include "lobject.h"
#include "ltm.h"

#define tostring(L, o) ((ttype(o) == LUA_TSTRING) || (luaV_tostring(L, o)))

#define tonumber(L, o, n) (ttype(o) == LUA_TNUMBER || (((o) = luaV_tonumber(L, o, n)) != NULL))

#define equalobj(L, o1, o2) (ttype(o1) == ttype(o2) && luaV_equalval(L, o1, o2))

LUAI_FUNC int luaV_lessthan (lua_State *L, const TValue *l, const TValue *r);
LUAI_FUNC int luaV_equalval (lua_State *L, const TValue *t1, const TValue *t2);
LUAI_FUNC const TValue *luaV_tonumber (lua_State *L, const TValue *obj, TValue *n);
LUAI_FUNC int luaV_tostring (lua_State *L, StkId obj);
LUAI_FUNC void luaV_gettable (lua_State *L, const TValue *t, TValue *key, StkId val);
LUAI_FUNC void luaV_settable (lua_State *L, const TValue *t, TValue *key, StkId val);
LUAI_FUNC void luaV_execute (lua_State *L, int nexeccalls);
LUAI_FUNC void luaV_concat (lua_State *L, int total, int last);

#endif
