/* Licensed under the terms of the MIT License; see full copyright information
 * in the "LICENSE" file or at <http://www.lua.org/license.html> */

#define lmanip_c
#define LUA_CORE

#include "lmanip.h"

extern void setnilvalue (lua_State *L, TValue *dst);
extern void setnvalue (lua_State *L, TValue *dst, lua_Number n);
extern void setpvalue (lua_State *L, TValue *dst, void *p);
extern void setbvalue (lua_State *L, TValue *dst, int b);
extern void setsvalue (lua_State *L, TValue *dst, TString *s);
extern void setuvalue (lua_State *L, TValue *dst, Udata *u);
extern void setthvalue (lua_State *L, TValue *dst, lua_State *th);
extern void setclvalue (lua_State *L, TValue *dst, Closure *cl);
extern void sethvalue (lua_State *L, TValue *dst, Table *h);
extern void setptvalue (lua_State *L, TValue *dst, Proto *pt);
extern void setobj (lua_State *L, TValue *dst, const TValue *src);
extern void setobj2s (lua_State *L, StkId dst, const TValue *src);
extern void setobj2n (lua_State *L, TValue *dst, const TValue *src);
extern void setobj2t (lua_State *L, const TValue *tbl, const TValue *key, TValue *dst, const TValue *src);
extern void setobj2uv (lua_State *L, const TValue *func, TValue *dst, const TValue *src);
extern void setobjt2s (lua_State *L, const TValue *tbl, const TValue *key, TValue *dst, const TValue *src);
extern void setobjuv2s (lua_State *L, const TValue *func, TValue *dst, const TValue *src);
extern void setobjs2s (lua_State *L, StkId dst, const TValue *src);
extern void setobjt2t (lua_State *L, TValue *dst, const TValue *src);
extern void sethvalue2s (lua_State *L, StkId dst, Table *src);
extern void setptvalue2s (lua_State *L, StkId dst, Proto *src);
extern void setsvalue2n (lua_State *L, TValue *dst, TString *src);
extern void setsvalue2s (lua_State *L, StkId dst, TString *src);
extern void rawsetnilvalue (TValue *dst);
extern void rawsetnvalue (TValue *dst, lua_Number n);
extern void rawsetobj (lua_State *L, TValue *dst, const TValue *src);
