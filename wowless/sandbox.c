#include <lauxlib.h>

/* TODO proper elune header inclusion */
extern void luaL_openlibsx(lua_State *, int);
extern int lua_absindex(lua_State *, int);

static const char sandbox_metatable_name[] = "wowless sandbox";
static const char tableproxy_metatable_name[] = "wowless tableproxy";

typedef struct {
  lua_State *S;
  int index;
} tableproxy;

static void copy_or_proxy_value(lua_State *L, lua_State *S, int i) {
  int ty = lua_type(S, i);
  switch (ty) {
    case LUA_TNIL:
      lua_pushnil(L);
      break;
    case LUA_TBOOLEAN:
      lua_pushboolean(L, lua_toboolean(S, i));
      break;
    case LUA_TNUMBER:
      lua_pushnumber(L, lua_tonumber(S, i));
      break;
    case LUA_TSTRING:
      lua_pushstring(L, lua_tostring(S, i));
      break;
    case LUA_TTABLE: {
      tableproxy *tp = lua_newuserdata(L, sizeof(tableproxy));
      luaL_getmetatable(L, tableproxy_metatable_name);
      lua_setmetatable(L, -2);
      tp->S = S;
      tp->index = lua_absindex(S, i);
      break;
    }
    default:
      lua_pushstring(L, "invalid type: ");
      lua_pushstring(L, lua_typename(S, ty));
      lua_concat(L, 2);
      lua_error(L);
  }
}

static void copy_value(lua_State *L, lua_State *S, int i) {
  int ty = lua_type(S, i);
  switch (ty) {
    case LUA_TNIL:
      lua_pushnil(L);
      break;
    case LUA_TBOOLEAN:
      lua_pushboolean(L, lua_toboolean(S, i));
      break;
    case LUA_TNUMBER:
      lua_pushnumber(L, lua_tonumber(S, i));
      break;
    case LUA_TSTRING:
      lua_pushstring(L, lua_tostring(S, i));
      break;
    case LUA_TTABLE:
      lua_newtable(L);
      lua_pushvalue(S, i);
      lua_pushnil(S);
      while (lua_next(S, -2) != 0) {
        copy_value(L, S, -2);
        copy_value(L, S, -1);
        lua_rawset(L, -3);
        lua_pop(S, 1);
      }
      lua_pop(S, 1);
      break;
    default:
      lua_pushstring(L, "invalid type: ");
      lua_pushstring(L, lua_typename(S, ty));
      lua_concat(L, 2);
      lua_error(L);
  }
}

static tableproxy *check_tableproxy(lua_State *L, int index) {
  return (tableproxy *)luaL_checkudata(L, index, tableproxy_metatable_name);
}

static int wowless_tableproxy_get(lua_State *L) {
  tableproxy *tp = check_tableproxy(L, 1);
  lua_State *S = tp->S;
  luaL_checkany(L, 2);
  copy_value(S, L, 2);
  lua_gettable(S, tp->index);
  copy_or_proxy_value(L, S, -1);
  lua_pop(S, 1);
  return 1;
}

static int wowless_tableproxy_rawget(lua_State *L) {
  tableproxy *tp = check_tableproxy(L, 1);
  lua_State *S = tp->S;
  luaL_checkany(L, 2);
  copy_value(S, L, 2);
  lua_rawget(S, tp->index);
  copy_or_proxy_value(L, S, -1);
  lua_pop(S, 1);
  return 1;
}

static struct luaL_Reg tableproxy_index[] = {
  {"get", wowless_tableproxy_get},
  {"rawget", wowless_tableproxy_rawget},
  {NULL, NULL},
};

static int sandboxapply(lua_State *S) {
  const char *str = luaL_checkstring(S, 1);
  lua_State *L = (lua_State *)lua_touserdata(S, lua_upvalueindex(1));
  int old_host_top = lua_gettop(L);
  lua_getglobal(L, str);
  int sandbox_top = lua_gettop(S);
  for (int i = 2; i <= sandbox_top; ++i) {
    copy_or_proxy_value(L, S, i);
  }
  if (lua_pcall(L, sandbox_top - 1, LUA_MULTRET, 0) != 0) {
    lua_pushstring(S, "apply error: ");
    copy_value(S, L, -1);
    lua_concat(S, 2);
    lua_error(S);
  }
  int host_top = lua_gettop(L);
  for (int i = old_host_top + 1; i <= host_top; ++i) {
    copy_value(S, L, i);
  }
  return host_top - old_host_top;
}

static int wowless_sandbox_create(lua_State *L) {
  lua_State **p = lua_newuserdata(L, sizeof(*p));
  luaL_getmetatable(L, sandbox_metatable_name);
  lua_setmetatable(L, -2);
  *p = luaL_newstate();
  luaL_openlibsx(*p, 1); /* elune libs only */
  lua_pushlightuserdata(*p, L);
  lua_pushcclosure(*p, sandboxapply, 1);
  lua_setglobal(*p, "apply");
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
    copy_value(L, S, -1);
    lua_concat(L, 2);
    lua_error(L);
  }
  int n = lua_gettop(S);
  for (int i = 1; i <= n; ++i) {
    copy_value(L, S, i);
  }
  return n;
}

static struct luaL_Reg sandbox_index[] = {
  {"eval", wowless_sandbox_eval},
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
