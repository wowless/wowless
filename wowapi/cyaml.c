#include <ctype.h>

#include "lauxlib.h"
#include "lua.h"
#include "yaml.h"

/** START adapted from ltablib.c from elune. */

static void set2(lua_State *L, int idx, int i, int j) {
  lua_rawseti(L, idx, i);
  lua_rawseti(L, idx, j);
}

static int sort_comp(lua_State *L, int a, int b) {
  int ta = lua_type(L, a);
  int tb = lua_type(L, b);
  if (ta < tb) {
    return 1;
  }
  if (ta > tb) {
    return 0;
  }
  if (ta == LUA_TNUMBER) {
    return lua_tonumber(L, a) < lua_tonumber(L, b);
  }
  size_t na;
  size_t nb;
  const char *sa = lua_tolstring(L, a, &na);
  const char *sb = lua_tolstring(L, b, &nb);
  size_t nx = na < nb ? na : nb;
  for (size_t i = 0; i < nx; ++i) {
    int la = tolower(sa[i]);
    int lb = tolower(sb[i]);
    if (la < lb) {
      return 1;
    }
    if (la > lb) {
      return 0;
    }
  }
  return na < nb || na == nb && memcmp(sa, sb, nx) < 0;
}

static void auxsort(lua_State *L, int idx, int l, int u) {
  while (l < u) { /* for tail recursion */
    int i;
    int j;
    /* sort elements a[l], a[(l+u)/2] and a[u] */
    lua_rawgeti(L, idx, l);
    lua_rawgeti(L, idx, u);
    if (sort_comp(L, -1, -2)) { /* a[u] < a[l]? */
      set2(L, idx, l, u);       /* swap a[l] - a[u] */
    } else {
      lua_pop(L, 2);
    }
    if (u - l == 1) {
      break; /* only 2 elements */
    }
    i = (l + u) / 2;
    lua_rawgeti(L, idx, i);
    lua_rawgeti(L, idx, l);
    if (sort_comp(L, -2, -1)) { /* a[i]<a[l]? */
      set2(L, idx, i, l);
    } else {
      lua_pop(L, 1); /* remove a[l] */
      lua_rawgeti(L, idx, u);
      if (sort_comp(L, -1, -2)) { /* a[u]<a[i]? */
        set2(L, idx, i, u);
      } else {
        lua_pop(L, 2);
      }
    }
    if (u - l == 2) {
      break; /* only 3 elements */
    }
    lua_rawgeti(L, idx, i); /* Pivot */
    lua_pushvalue(L, -1);
    lua_rawgeti(L, idx, u - 1);
    set2(L, idx, i, u - 1);
    /* a[l] <= P == a[u-1] <= a[u], only need to sort from l+1 to u-2 */
    i = l;
    j = u - 1;
    for (;;) { /* invariant: a[l..i] <= P <= a[j..u] */
      /* repeat ++i until a[i] >= P */
      while (lua_rawgeti(L, idx, ++i), sort_comp(L, -1, -2)) {
        if (i > u) {
          luaL_error(L, "invalid order function for sorting");
        }
        lua_pop(L, 1); /* remove a[i] */
      }
      /* repeat --j until a[j] <= P */
      while (lua_rawgeti(L, idx, --j), sort_comp(L, -3, -1)) {
        if (j < l) {
          luaL_error(L, "invalid order function for sorting");
        }
        lua_pop(L, 1); /* remove a[j] */
      }
      if (j < i) {
        lua_pop(L, 3); /* pop pivot, a[i], a[j] */
        break;
      }
      set2(L, idx, i, j);
    }
    lua_rawgeti(L, idx, u - 1);
    lua_rawgeti(L, idx, i);
    set2(L, idx, u - 1, i); /* swap pivot (a[u-1]) with a[i] */
    /* a[l..i-1] <= a[i] == P <= a[i+1..u] */
    /* adjust so that smaller half is in [j..i] and larger one in [l..u] */
    if (i - l < u - i) {
      j = l;
      i = i - 1;
      l = i + 2;
    } else {
      j = i + 1;
      i = u;
      u = j - 2;
    }
    auxsort(L, idx, j, i); /* call recursively the smaller one */
  } /* repeat the routine for the larger one */
}

/** END adapted from ltablib.c from elune. */

static void x(lua_State *L, int err) {
  if (err == 0) {
    luaL_error(L, "yaml: internal error");
  }
}

static void advance(lua_State *L, yaml_parser_t *parser, yaml_token_t *token) {
  yaml_token_delete(token);
  x(L, yaml_parser_scan(parser, token));
}

static void checktype(lua_State *L, yaml_token_t *token,
                      yaml_token_type_t type) {
  if (token->type != type) {
    luaL_error(L, "yaml: want %d, got %d", type, token->type);
  }
}

static void eat(lua_State *L, yaml_parser_t *parser, yaml_token_t *token,
                yaml_token_type_t type) {
  advance(L, parser, token);
  checktype(L, token, type);
}

static void parsescalar(lua_State *L, yaml_token_t *token) {
  checktype(L, token, YAML_SCALAR_TOKEN);
  const char *s = (const char *)token->data.scalar.value;
  size_t z = token->data.scalar.length;
  yaml_scalar_style_t y = token->data.scalar.style;
  if (y != YAML_PLAIN_SCALAR_STYLE) {
    lua_pushlstring(L, s, z);
  } else if (z == 4 && !memcmp("true", s, z)) {
    lua_pushboolean(L, 1);
  } else if (z == 5 && !memcmp("false", s, z)) {
    lua_pushboolean(L, 0);
  } else {
    char *end;
    double d = strtod(s, &end);
    if (end == s + z) {
      lua_pushnumber(L, d);
    } else {
      lua_pushlstring(L, s, z);
    }
  }
}

static void parsevalue(lua_State *L, yaml_parser_t *parser,
                       yaml_token_t *token) {
  switch (token->type) {
    case YAML_BLOCK_MAPPING_START_TOKEN: {
      lua_createtable(L, 0, 1);
      advance(L, parser, token);
      while (token->type != YAML_BLOCK_END_TOKEN) {
        checktype(L, token, YAML_KEY_TOKEN);
        advance(L, parser, token);
        parsescalar(L, token);
        eat(L, parser, token, YAML_VALUE_TOKEN);
        advance(L, parser, token);
        parsevalue(L, parser, token);
        lua_rawset(L, -3);
      }
      advance(L, parser, token);
      break;
    }
    case YAML_BLOCK_ENTRY_TOKEN: {
      lua_createtable(L, 1, 0);
      int i = 1;
      do {
        advance(L, parser, token);
        parsevalue(L, parser, token);
        lua_rawseti(L, -2, i++);
      } while (token->type == YAML_BLOCK_ENTRY_TOKEN);
      break;
    }
    case YAML_BLOCK_SEQUENCE_START_TOKEN: {
      eat(L, parser, token, YAML_BLOCK_ENTRY_TOKEN);
      parsevalue(L, parser, token);
      checktype(L, token, YAML_BLOCK_END_TOKEN);
      advance(L, parser, token);
      break;
    }
    case YAML_SCALAR_TOKEN: {
      parsescalar(L, token);
      advance(L, parser, token);
      break;
    }
    default: {
      lua_createtable(L, 0, 0);
      break;
    }
  }
}

static int doparse(lua_State *L) {
  yaml_parser_t *parser = lua_touserdata(L, 1);
  yaml_token_t *token = lua_touserdata(L, 2);
  eat(L, parser, token, YAML_STREAM_START_TOKEN);
  advance(L, parser, token);
  parsevalue(L, parser, token);
  checktype(L, token, YAML_STREAM_END_TOKEN);
  return 1;
}

static int wowapi_yaml_parse(lua_State *L) {
  lua_settop(L, 1);
  size_t size;
  const unsigned char *str =
      (const unsigned char *)luaL_checklstring(L, 1, &size);
  lua_pushvalue(L, lua_upvalueindex(1));
  yaml_parser_t parser;
  x(L, yaml_parser_initialize(&parser));
  yaml_parser_set_input_string(&parser, str, size);
  lua_pushlightuserdata(L, &parser);
  yaml_token_t token;
  memset(&token, 0, sizeof(token));
  lua_pushlightuserdata(L, &token);
  int err = lua_pcall(L, 2, 1, 0);
  yaml_token_delete(&token);
  yaml_parser_delete(&parser);
  return err ? lua_error(L) : 1;
}

static int dooutput(void *data, unsigned char *buffer, size_t size) {
  lua_State *L = data;
  lua_pushlstring(L, (const char *)buffer, size);
  lua_rawseti(L, 1, lua_objlen(L, 1) + 1);
  return 1;
}

static void printscalar(lua_State *L, yaml_emitter_t *emitter,
                        yaml_event_t *event) {
  int type = lua_type(L, -1);
  switch (type) {
    case LUA_TBOOLEAN: {
      if (lua_toboolean(L, -1)) {
        x(L, yaml_scalar_event_initialize(event, 0, 0, "true", 4, 1, 1, 0));
      } else {
        x(L, yaml_scalar_event_initialize(event, 0, 0, "false", 5, 1, 1, 0));
      }
      x(L, yaml_emitter_emit(emitter, event));
      break;
    }
    case LUA_TNUMBER: {
      lua_pushvalue(L, -1);
      size_t z;
      const unsigned char *s = (const unsigned char *)lua_tolstring(L, -1, &z);
      x(L, yaml_scalar_event_initialize(event, 0, 0, s, z, 1, 1, 1));
      x(L, yaml_emitter_emit(emitter, event));
      lua_pop(L, 1);
      break;
    }
    case LUA_TSTRING: {
      size_t z;
      const unsigned char *s = (const unsigned char *)lua_tolstring(L, -1, &z);
      int q = (!z || lua_isnumber(L, -1)) ? YAML_SINGLE_QUOTED_SCALAR_STYLE : 0;
      x(L, yaml_scalar_event_initialize(event, 0, 0, s, z, 1, 1, q));
      x(L, yaml_emitter_emit(emitter, event));
      break;
    }
    default:
      luaL_error(L, "yaml: unsupported type %s", lua_typename(L, type));
  }
}

static void printvalue(lua_State *L, yaml_emitter_t *emitter,
                       yaml_event_t *event) {
  if (lua_istable(L, -1)) {
    lua_pushnil(L);
    if (!lua_next(L, -2)) {
      unsigned char nil;
      x(L, yaml_scalar_event_initialize(event, 0, 0, &nil, 0, 1, 1, 0));
      x(L, yaml_emitter_emit(emitter, event));
    } else {
      lua_pop(L, 1);
      lua_createtable(L, 1, 0);
      lua_insert(L, -2);
      lua_pushvalue(L, -1);
      lua_rawseti(L, -3, 1);
      int n = 1;
      while (lua_next(L, -3)) {
        ++n;
        lua_pop(L, 1);
        lua_pushvalue(L, -1);
        lua_rawseti(L, -3, n);
      }
      int isarray = 1;
      for (int i = 1; isarray && i <= n; ++i) {
        lua_rawgeti(L, -2, i);
        isarray = !lua_isnil(L, -1);
        lua_pop(L, 1);
      }
      if (isarray) {
        x(L, yaml_sequence_start_event_initialize(event, 0, 0, 1, 0));
        x(L, yaml_emitter_emit(emitter, event));
        for (int i = 1; i <= n; ++i) {
          lua_rawgeti(L, -2, i);
          printvalue(L, emitter, event);
          lua_pop(L, 1);
        }
        x(L, yaml_sequence_end_event_initialize(event));
        x(L, yaml_emitter_emit(emitter, event));
      } else {
        x(L, yaml_mapping_start_event_initialize(event, 0, 0, 1, 0));
        x(L, yaml_emitter_emit(emitter, event));
        auxsort(L, lua_gettop(L), 1, lua_objlen(L, -1));
        for (int i = 1; i <= n; ++i) {
          lua_rawgeti(L, -1, i);
          printscalar(L, emitter, event);
          lua_rawget(L, -3);
          printvalue(L, emitter, event);
          lua_pop(L, 1);
        }
        x(L, yaml_mapping_end_event_initialize(event));
        x(L, yaml_emitter_emit(emitter, event));
      }
      lua_pop(L, 1);
    }
  } else {
    printscalar(L, emitter, event);
  }
}

static int dopprint(lua_State *L) {
  lua_settop(L, 3);
  luaL_checkstack(L, 100, "yaml");
  yaml_emitter_t *emitter = lua_touserdata(L, 2);
  yaml_event_t event;
  x(L, yaml_stream_start_event_initialize(&event, YAML_UTF8_ENCODING));
  x(L, yaml_emitter_emit(emitter, &event));
  x(L, yaml_document_start_event_initialize(&event, 0, 0, 0, 1));
  x(L, yaml_emitter_emit(emitter, &event));
  printvalue(L, emitter, &event);
  x(L, yaml_document_end_event_initialize(&event, 1));
  x(L, yaml_emitter_emit(emitter, &event));
  x(L, yaml_stream_end_event_initialize(&event));
  x(L, yaml_emitter_emit(emitter, &event));
  return 1;
}

static int wowapi_yaml_pprint(lua_State *L) {
  lua_settop(L, 1);
  lua_createtable(L, 1, 0);
  lua_pushvalue(L, lua_upvalueindex(1));
  lua_pushvalue(L, 2);
  yaml_emitter_t emitter;
  x(L, yaml_emitter_initialize(&emitter));
  yaml_emitter_set_output(&emitter, &dooutput, L);
  lua_pushlightuserdata(L, &emitter);
  lua_pushvalue(L, 1);
  int err = lua_pcall(L, 3, 1, 0);
  yaml_emitter_delete(&emitter);
  if (err) {
    return lua_error(L);
  }
  luaL_Buffer buf;
  luaL_buffinit(L, &buf);
  int n = lua_objlen(L, 2);
  for (int i = 1; i <= n; ++i) {
    lua_rawgeti(L, 2, i);
    luaL_addvalue(&buf);
  }
  luaL_pushresult(&buf);
  return 1;
}

int luaopen_wowapi_cyaml(lua_State *L) {
  lua_createtable(L, 0, 1);
  lua_pushcfunction(L, doparse);
  lua_pushcclosure(L, wowapi_yaml_parse, 1);
  lua_setfield(L, -2, "parse");
  lua_pushcfunction(L, dopprint);
  lua_pushcclosure(L, wowapi_yaml_pprint, 1);
  lua_setfield(L, -2, "pprint");
  return 1;
}
