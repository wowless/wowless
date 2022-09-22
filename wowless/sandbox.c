#include <lauxlib.h>

/* TODO proper elune header inclusion */
extern void luaL_openlibsx(lua_State *, int);
extern int lua_absindex(lua_State *, int);

static const char sandbox_metatable_name[] = "wowless sandbox";
static const char tableproxy_metatable_name[] = "wowless tableproxy";

static void copy_scalar(lua_State *err, lua_State *to, lua_State *from, int index) {
  int ty = lua_type(from, index);
  switch (ty) {
    case LUA_TNIL:
      lua_pushnil(to);
      break;
    case LUA_TBOOLEAN:
      lua_pushboolean(to, lua_toboolean(from, index));
      break;
    case LUA_TNUMBER:
      lua_pushnumber(to, lua_tonumber(from, index));
      break;
    case LUA_TSTRING:
      lua_pushstring(to, lua_tostring(from, index));
      break;
    default:
      lua_pushstring(err, "invalid type: ");
      lua_pushstring(err, lua_typename(from, ty));
      lua_concat(err, 2);
      lua_error(err);
  }
}

typedef struct {
  lua_State *state;
  int index;
} tableproxy;

static void proxy_value(lua_State *err, lua_State *to, lua_State *from, int index) {
  if (lua_type(from, index) == LUA_TTABLE) {
    tableproxy *tp = lua_newuserdata(to, sizeof(tableproxy));
    luaL_getmetatable(to, tableproxy_metatable_name);
    lua_setmetatable(to, -2);
    tp->state = from;
    tp->index = lua_absindex(from, index);
  } else {
    copy_scalar(err, to, from, index);
  }
}

static void copy_value(lua_State *err, lua_State *to, lua_State *from, int index) {
  if (lua_type(from, index) == LUA_TTABLE) {
    lua_newtable(to);
    lua_pushvalue(from, index);
    lua_pushnil(from);
    while (lua_next(from, -2) != 0) {
      copy_value(err, to, from, -2);
      copy_value(err, to, from, -1);
      lua_rawset(to, -3);
      lua_pop(from, 1);
    }
    lua_pop(from, 1);
  } else {
    copy_scalar(err, to, from, index);
  }
}

static tableproxy *check_tableproxy(lua_State *L, int index) {
  return (tableproxy *)luaL_checkudata(L, index, tableproxy_metatable_name);
}

static int wowless_tableproxy_get(lua_State *L) {
  tableproxy *tp = check_tableproxy(L, 1);
  luaL_checkany(L, 2);
  lua_State *S = tp->state;
  copy_value(L, S, L, 2);
  lua_gettable(S, tp->index);
  proxy_value(L, L, S, -1);
  lua_pop(S, 1);
  return 1;
}

static int wowless_tableproxy_set(lua_State *L) {
  tableproxy *tp = check_tableproxy(L, 1);
  luaL_checkany(L, 2);
  luaL_checkany(L, 3);
  lua_State *S = tp->state;
  copy_value(L, S, L, 2);
  copy_value(L, S, L, 3);
  lua_settable(S, tp->index);
  return 0;
}

static int wowless_tableproxy_rawget(lua_State *L) {
  tableproxy *tp = check_tableproxy(L, 1);
  luaL_checkany(L, 2);
  lua_State *S = tp->state;
  copy_value(L, S, L, 2);
  lua_rawget(S, tp->index);
  proxy_value(L, L, S, -1);
  lua_pop(S, 1);
  return 1;
}

static int wowless_tableproxy_rawset(lua_State *L) {
  tableproxy *tp = check_tableproxy(L, 1);
  luaL_checkany(L, 2);
  luaL_checkany(L, 3);
  lua_State *S = tp->state;
  copy_value(L, S, L, 2);
  copy_value(L, S, L, 3);
  lua_rawset(S, tp->index);
  return 0;
}

static struct luaL_Reg tableproxy_index[] = {
  {"get", wowless_tableproxy_get},
  {"set", wowless_tableproxy_set},
  {"rawget", wowless_tableproxy_rawget},
  {"rawset", wowless_tableproxy_rawset},
  {NULL, NULL},
};

static int wowless_sandbox_create(lua_State *L) {
  lua_State **p = lua_newuserdata(L, sizeof(*p));
  luaL_getmetatable(L, sandbox_metatable_name);
  lua_setmetatable(L, -2);
  *p = luaL_newstate();
  luaL_openlibsx(*p, 1); /* elune libs only */
  return 1;
}

static lua_State *check_sandbox(lua_State *L, int index) {
  return *(lua_State **)luaL_checkudata(L, index, sandbox_metatable_name);
}

static int wowless_sandbox_gc(lua_State *L) {
  lua_State *S = check_sandbox(L, 1);
  lua_close(S);
  return 0;
}

static int wowless_sandbox_eval(lua_State *L) {
  lua_State *S = check_sandbox(L, 1);
  const char *str = luaL_checkstring(L, 2);
  lua_settop(S, 0);
  if (luaL_dostring(S, str) != 0) {
    lua_pushstring(L, "eval error: ");
    copy_value(L, L, S, -1);
    lua_concat(L, 2);
    lua_error(L);
  }
  int n = lua_gettop(S);
  for (int i = 1; i <= n; ++i) {
    copy_value(L, L, S, i);
  }
  return n;
}

static int invokefromregistry(lua_State *S) {
  lua_State *L = (lua_State *)lua_touserdata(S, lua_upvalueindex(1));
  int old_host_top = lua_gettop(L);
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_tonumber(S, lua_upvalueindex(2)));
  int sandbox_top = lua_gettop(S);
  for (int i = 1; i <= sandbox_top; ++i) {
    proxy_value(L, L, S, i);
  }
  if (lua_pcall(L, sandbox_top, LUA_MULTRET, 0) != 0) {
    copy_value(L, S, L, -1);
    lua_error(S);
  }
  int host_top = lua_gettop(L);
  for (int i = old_host_top + 1; i <= host_top; ++i) {
    copy_value(L, S, L, i);
  }
  return host_top - old_host_top;
}

static int wowless_sandbox_register(lua_State *L) {
  lua_State *S = check_sandbox(L, 1);
  const char *name = luaL_checkstring(L, 2);
  luaL_checktype(L, 3, LUA_TFUNCTION);
  lua_pushlightuserdata(S, L);
  lua_pushnumber(S, luaL_ref(L, LUA_REGISTRYINDEX));
  lua_pushcclosure(S, invokefromregistry, 2);
  lua_setglobal(S, name);
  return 0;
}

static struct luaL_Reg sandbox_index[] = {
  {"eval", wowless_sandbox_eval},
  {"register", wowless_sandbox_register},
  {NULL, NULL},
};

static struct luaL_Reg module_index[] = {
  {"create", wowless_sandbox_create},
  {NULL, NULL},
};

int luaopen_wowless_sandbox(lua_State *L) {
  if (luaL_newmetatable(L, sandbox_metatable_name)) {
    lua_pushstring(L, "__index");
    lua_newtable(L);
    luaL_register(L, NULL, sandbox_index);
    lua_settable(L, -3);
    lua_pushstring(L, "__gc");
    lua_pushcfunction(L, wowless_sandbox_gc);
    lua_settable(L, -3);
    lua_pushstring(L, "__metatable");
    lua_pushstring(L, sandbox_metatable_name);
    lua_settable(L, -3);
  }
  lua_pop(L, 1);
  if (luaL_newmetatable(L, tableproxy_metatable_name)) {
    lua_pushstring(L, "__index");
    lua_newtable(L);
    luaL_register(L, NULL, tableproxy_index);
    lua_settable(L, -3);
    lua_pushstring(L, "__metatable");
    lua_pushstring(L, tableproxy_metatable_name);
    lua_settable(L, -3);
  }
  lua_pop(L, 1);
  lua_newtable(L);
  luaL_register(L, NULL, module_index);
  return 1;
}
