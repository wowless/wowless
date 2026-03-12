#include "lauxlib.h"
#include "lua.h"
#include "luaconf.h"
#include "lualib.h"

static const char *get_source(const lua_Debug *ar) {
  if (ar->source[0] == '@') {
    return ar->source + 1;
  } else {
    return ar->short_src;
  }
}

/* Lightly edited from db_stack in ldblib.c in elune. */
static int wowless_debug_debugstack(lua_State *L) {
  lua_State *L1 = L;
  int level = 1;
  int ntop = 120;
  int nbase = 10;
  int firstpart = 1;
  int startlevel;
  lua_Debug ar;

  if (lua_type(L, 1) == LUA_TTHREAD) {
    L1 = lua_tothread(L, 1);
    lua_remove(L, 1);
  }

  if (!lua_ishookallowed(L1) && !lua_getcompatopt(L1, LUA_COMPATGCDEBUG)) {
    return 0; /* '__gc' metamethod is executing. */
  }

  if (lua_isnumber(L, 1)) {
    level = (int)lua_tonumber(L, 1);
    lua_remove(L, 1);
  }

  if (lua_isnumber(L, 1)) {
    ntop = (int)lua_tonumber(L, 1);
    lua_remove(L, 1);
  }

  if (lua_isnumber(L, 1)) {
    nbase = (int)lua_tonumber(L, 1);
    lua_remove(L, 1);
  }

  if (lua_gettop(L) == 0) {
    lua_pushliteral(L, "");
  } else if (!lua_isstring(L, 1)) {
    return 1;
  }

  startlevel = level;

  while (lua_getstack(L1, level++, &ar)) {
    if ((ntop + startlevel) < level && firstpart) {
      if (!lua_getstack(L1, level + nbase, &ar)) {
        level--;
      } else {
        lua_pushliteral(L, "...\n");
        while (lua_getstack(L1, level + nbase, &ar)) {
          level++;
        }
      }

      firstpart = 0;
      continue;
    }

    lua_getinfo(L1, "Snl", &ar);
    lua_pushfstring(L, "%s:", get_source(&ar));

    if (ar.currentline > 0) {
      lua_pushfstring(L, "%d:", ar.currentline);
    }

    switch (*ar.namewhat) {
      case 'g':
      case 'l':
      case 'f':
      case 'm':
        lua_pushfstring(L, " in function `%s'", ar.name);
        break;
      default: {
        if (*ar.what == 'm') {
          lua_pushfstring(L, " in main chunk");
        } else if (*ar.what == 'C' || *ar.what == 't') {
          lua_pushliteral(L, " ?");
        } else {
          lua_pushfstring(L, " in function <%s:%d>", get_source(&ar),
                          ar.linedefined);
        }
      }
    }

    lua_pushliteral(L, "\n");
    lua_concat(L, lua_gettop(L));
  }

  lua_concat(L, lua_gettop(L));
  return 1;
}

static struct luaL_Reg debuglib[] = {
    {"debugstack", wowless_debug_debugstack},
    {NULL,         NULL                    }
};

int luaopen_wowless_debug(lua_State *L) {
  lua_newtable(L);
  luaL_register(L, NULL, debuglib);
  return 1;
}
