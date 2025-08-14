#include "lauxlib.h"
#include "lua.h"
#include "luaconf.h"
#include "lualib.h"

#ifndef ELUNE_VERSION
#error Must be compiled against Elune headers.
#endif

/* Lightly modified from ldblib.c. */

static lua_State *getthread(lua_State *L, int *arg) {
  if (lua_isthread(L, 1)) {
    *arg = 1;
    return lua_tothread(L, 1);
  } else {
    *arg = 0;
    return L;
  }
}

static const char *get_source(const lua_Debug *ar) {
  if (ar->source[0] == '@') {
    return ar->source + 1;
  } else {
    return ar->short_src;
  }
}

#define LEVELS1 120 /* size of the first part of the stack */
#define LEVELS2 10  /* size of the second part of the stack */

static int wowless_ext_traceback(lua_State *L) {
  int level;
  int firstpart = 1; /* still before eventual `...' */
  int arg;
  lua_State *L1 = getthread(L, &arg);
  lua_Debug ar;
  if (lua_isnumber(L, arg + 2)) {
    level = (int)lua_tointeger(L, arg + 2);
    lua_pop(L, 1);
  } else
    level = (L == L1) ? 1 : 0; /* level 0 may be this own function */
  if (lua_gettop(L) == arg)
    lua_pushliteral(L, "");
  else if (!lua_isstring(L, arg + 1))
    return 1; /* message is not a string */
  else
    lua_pushliteral(L, "\n");
  lua_pushliteral(L, "stack traceback:");
  while (lua_getstack(L1, level++, &ar)) {
    if (level > LEVELS1 && firstpart) {
      /* no more than `LEVELS2' more levels? */
      if (!lua_getstack(L1, level + LEVELS2, &ar))
        level--; /* keep going */
      else {
        lua_pushliteral(L, "\n\t...");                 /* too many levels */
        while (lua_getstack(L1, level + LEVELS2, &ar)) /* find last levels */
          level++;
      }
      firstpart = 0;
      continue;
    }
    lua_pushliteral(L, "\n\t");
    lua_getinfo(L1, "Snl", &ar);
    lua_pushfstring(L, "%s:", get_source(&ar));
    if (ar.currentline > 0) lua_pushfstring(L, "%d:", ar.currentline);
    if (*ar.namewhat != '\0') /* is there a name? */
      lua_pushfstring(L, " in function " LUA_QS, ar.name);
    else {
      if (*ar.what == 'm') /* main? */
        lua_pushfstring(L, " in main chunk");
      else if (*ar.what == 'C' || *ar.what == 't')
        lua_pushliteral(L, " ?"); /* C function or tail call */
      else
        lua_pushfstring(L, " in function <%s:%d>", get_source(&ar),
                        ar.linedefined);
    }
    lua_concat(L, lua_gettop(L) - arg);
  }
  lua_concat(L, lua_gettop(L) - arg);
  return 1;
}

static int wowless_ext_getglobaltable(lua_State *L) {
  lua_settop(L, 0);
  lua_pushvalue(L, LUA_GLOBALSINDEX);
  return 1;
}

static int wowless_ext_setglobaltable(lua_State *L) {
  luaL_checktype(L, 1, LUA_TTABLE);
  lua_settop(L, 1);
  lua_pushvalue(L, LUA_GLOBALSINDEX);
  lua_insert(L, 1);
  lua_replace(L, LUA_GLOBALSINDEX);
  return 1;
}

static struct luaL_Reg extlib[] = {
    {"getglobaltable", wowless_ext_getglobaltable},
    {"setglobaltable", wowless_ext_setglobaltable},
    {"traceback",      wowless_ext_traceback     },
    {NULL,             NULL                      }
};

int luaopen_wowless_ext(lua_State *L) {
  lua_newtable(L);
  luaL_register(L, NULL, extlib);
  return 1;
}
