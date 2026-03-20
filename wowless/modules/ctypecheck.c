#include "lauxlib.h"
#include "lua.h"
#include "wowless/stubs.h"
#include "wowless/typecheck.h"

/*
 * Simple check wrappers: no upvalue needed, value at stack index 1.
 */
#define SIMPLE_CHECKER(name, call)             \
  static int ctypecheck_##name(lua_State *L) { \
    call(L, 1);                                \
    return 0;                                  \
  }

SIMPLE_CHECKER(stubchecknumber, wowless_stubchecknumber)
SIMPLE_CHECKER(stubchecknilablenumber, wowless_stubchecknilablenumber)
SIMPLE_CHECKER(stubcheckboolean, wowless_stubcheckboolean)
SIMPLE_CHECKER(stubchecknilableboolean, wowless_stubchecknilableboolean)
SIMPLE_CHECKER(stubcheckstring, wowless_stubcheckstring)
SIMPLE_CHECKER(stubchecknilablestring, wowless_stubchecknilablestring)
SIMPLE_CHECKER(stubcheckfileasset, wowless_stubcheckfileasset)
SIMPLE_CHECKER(stubchecknilablefileasset, wowless_stubchecknilablefileasset)
SIMPLE_CHECKER(stubcheckfunction, wowless_stubcheckfunction)
SIMPLE_CHECKER(stubchecknilablefunction, wowless_stubchecknilablefunction)
SIMPLE_CHECKER(stubchecktable, wowless_stubchecktable)
SIMPLE_CHECKER(stubchecknilabletable, wowless_stubchecknilabletable)
SIMPLE_CHECKER(stubcheckunit, wowless_stubcheckunit)
SIMPLE_CHECKER(stubchecknilableunit, wowless_stubchecknilableunit)
SIMPLE_CHECKER(stubcheckenum, wowless_stubcheckenum)
SIMPLE_CHECKER(stubchecknilableenum, wowless_stubchecknilableenum)
SIMPLE_CHECKER(stubcheckunknown, wowless_stubcheckunknown)
SIMPLE_CHECKER(stubchecknilableunknown, wowless_stubchecknilableunknown)
SIMPLE_CHECKER(stubchecknil, wowless_stubchecknil)
SIMPLE_CHECKER(stubchecknilablenil, wowless_stubchecknilablenil)
SIMPLE_CHECKER(implchecknil, wowless_implchecknil)
SIMPLE_CHECKER(implchecknilablenil, wowless_implchecknilablenil)
SIMPLE_CHECKER(imploutputnil, wowless_imploutputnil)
SIMPLE_CHECKER(imploutputnilablenil, wowless_imploutputnilablenil)
SIMPLE_CHECKER(implchecknumber, wowless_implchecknumber)
SIMPLE_CHECKER(implchecknilablenumber, wowless_implchecknilablenumber)
SIMPLE_CHECKER(implcheckboolean, wowless_implcheckboolean)
SIMPLE_CHECKER(implchecknilableboolean, wowless_implchecknilableboolean)
SIMPLE_CHECKER(implcheckstring, wowless_implcheckstring)
SIMPLE_CHECKER(implchecknilablestring, wowless_implchecknilablestring)
SIMPLE_CHECKER(implcheckfileasset, wowless_implcheckfileasset)
SIMPLE_CHECKER(implchecknilablefileasset, wowless_implchecknilablefileasset)
SIMPLE_CHECKER(implcheckfunction, wowless_implcheckfunction)
SIMPLE_CHECKER(implchecknilablefunction, wowless_implchecknilablefunction)
SIMPLE_CHECKER(implchecktable, wowless_implchecktable)
SIMPLE_CHECKER(implchecknilabletable, wowless_implchecknilabletable)
SIMPLE_CHECKER(implcheckunknown, wowless_implcheckunknown)
SIMPLE_CHECKER(implchecknilableunknown, wowless_implchecknilableunknown)
SIMPLE_CHECKER(imploutputboolean, wowless_imploutputboolean)
SIMPLE_CHECKER(imploutputnilableboolean, wowless_imploutputnilableboolean)
SIMPLE_CHECKER(imploutputnumber, wowless_imploutputnumber)
SIMPLE_CHECKER(imploutputnilablenumber, wowless_imploutputnilablenumber)
SIMPLE_CHECKER(imploutputstring, wowless_imploutputstring)
SIMPLE_CHECKER(imploutputnilablestring, wowless_imploutputnilablestring)
SIMPLE_CHECKER(imploutputfileasset, wowless_imploutputfileasset)
SIMPLE_CHECKER(imploutputnilablefileasset, wowless_imploutputnilablefileasset)
SIMPLE_CHECKER(imploutputfunction, wowless_imploutputfunction)
SIMPLE_CHECKER(imploutputnilablefunction, wowless_imploutputnilablefunction)
SIMPLE_CHECKER(imploutputtable, wowless_imploutputtable)
SIMPLE_CHECKER(imploutputnilabletable, wowless_imploutputnilabletable)
SIMPLE_CHECKER(imploutputunknown, wowless_imploutputunknown)
SIMPLE_CHECKER(imploutputnilableunknown, wowless_imploutputnilableunknown)

/*
 * Typed check wrappers: cgencode at lua_upvalueindex(1) (matching the
 * convention in typecheck.h), value at stack index 1, typename at index 2.
 * This works directly because wowless_stubcheck* already reads upvalue 1 as
 * cgencode.
 */
#define TYPED_CHECKER(name, call)                      \
  static int ctypecheck_##name(lua_State *L) {         \
    size_t len;                                        \
    const char *tname = luaL_checklstring(L, 2, &len); \
    call(L, 1, tname, len);                            \
    return 0;                                          \
  }

TYPED_CHECKER(stubcheckstringenum, wowless_stubcheckstringenum)
TYPED_CHECKER(stubchecknilablestringenum, wowless_stubchecknilablestringenum)
TYPED_CHECKER(stubcheckluaobject, wowless_stubcheckluaobject)
TYPED_CHECKER(stubchecknilableluaobject, wowless_stubchecknilableluaobject)
TYPED_CHECKER(stubcheckuiobject, wowless_stubcheckuiobject)
TYPED_CHECKER(stubchecknilableuiobject, wowless_stubchecknilableuiobject)

#define SET_SIMPLE(L, name)                \
  lua_pushcfunction(L, ctypecheck_##name); \
  lua_setfield(L, -2, #name)

#define SET_TYPED(L, name)                   \
  lua_pushvalue(L, 1);                       \
  lua_pushcclosure(L, ctypecheck_##name, 1); \
  lua_setfield(L, -2, #name)

static int make_module(lua_State *L) {
  /* L[1] = cgencode */
  lua_newtable(L);
  SET_SIMPLE(L, stubchecknumber);
  SET_SIMPLE(L, stubchecknilablenumber);
  SET_SIMPLE(L, stubcheckboolean);
  SET_SIMPLE(L, stubchecknilableboolean);
  SET_SIMPLE(L, stubcheckstring);
  SET_SIMPLE(L, stubchecknilablestring);
  SET_SIMPLE(L, stubcheckfileasset);
  SET_SIMPLE(L, stubchecknilablefileasset);
  SET_SIMPLE(L, stubcheckfunction);
  SET_SIMPLE(L, stubchecknilablefunction);
  SET_SIMPLE(L, stubchecktable);
  SET_SIMPLE(L, stubchecknilabletable);
  SET_SIMPLE(L, stubcheckunit);
  SET_SIMPLE(L, stubchecknilableunit);
  SET_SIMPLE(L, stubcheckenum);
  SET_SIMPLE(L, stubchecknilableenum);
  SET_SIMPLE(L, stubcheckunknown);
  SET_SIMPLE(L, stubchecknilableunknown);
  SET_SIMPLE(L, stubchecknil);
  SET_SIMPLE(L, stubchecknilablenil);
  SET_SIMPLE(L, implchecknil);
  SET_SIMPLE(L, implchecknilablenil);
  SET_SIMPLE(L, imploutputnil);
  SET_SIMPLE(L, imploutputnilablenil);
  SET_SIMPLE(L, implchecknumber);
  SET_SIMPLE(L, implchecknilablenumber);
  SET_SIMPLE(L, implcheckboolean);
  SET_SIMPLE(L, implchecknilableboolean);
  SET_SIMPLE(L, implcheckstring);
  SET_SIMPLE(L, implchecknilablestring);
  SET_SIMPLE(L, implcheckfileasset);
  SET_SIMPLE(L, implchecknilablefileasset);
  SET_SIMPLE(L, implcheckfunction);
  SET_SIMPLE(L, implchecknilablefunction);
  SET_SIMPLE(L, implchecktable);
  SET_SIMPLE(L, implchecknilabletable);
  SET_SIMPLE(L, implcheckunknown);
  SET_SIMPLE(L, implchecknilableunknown);
  SET_SIMPLE(L, imploutputboolean);
  SET_SIMPLE(L, imploutputnilableboolean);
  SET_SIMPLE(L, imploutputnumber);
  SET_SIMPLE(L, imploutputnilablenumber);
  SET_SIMPLE(L, imploutputstring);
  SET_SIMPLE(L, imploutputnilablestring);
  SET_SIMPLE(L, imploutputfileasset);
  SET_SIMPLE(L, imploutputnilablefileasset);
  SET_SIMPLE(L, imploutputfunction);
  SET_SIMPLE(L, imploutputnilablefunction);
  SET_SIMPLE(L, imploutputtable);
  SET_SIMPLE(L, imploutputnilabletable);
  SET_SIMPLE(L, imploutputunknown);
  SET_SIMPLE(L, imploutputnilableunknown);
  SET_TYPED(L, stubcheckstringenum);
  SET_TYPED(L, stubchecknilablestringenum);
  SET_TYPED(L, stubcheckluaobject);
  SET_TYPED(L, stubchecknilableluaobject);
  SET_TYPED(L, stubcheckuiobject);
  SET_TYPED(L, stubchecknilableuiobject);
  return 1;
}

int luaopen_wowless_modules_ctypecheck(lua_State *L) {
  lua_pushcfunction(L, make_module);
  return 1;
}
