#include "yaml.h"

#include "lauxlib.h"
#include "lua.h"

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
  lua_pushlstring(L, (const char *)token->data.scalar.value,
                  token->data.scalar.length);
}

static void parsevalue(lua_State *L, yaml_parser_t *parser,
                       yaml_token_t *token) {
  switch (token->type) {
    case YAML_BLOCK_MAPPING_START_TOKEN: {
      lua_newtable(L);
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
    default: {
      lua_newtable(L);
      break;
    }
  }
}

static int doparse(lua_State *L) {
  size_t size;
  const unsigned char *str =
      (const unsigned char *)luaL_checklstring(L, 1, &size);
  yaml_parser_t *parser = lua_touserdata(L, 2);
  yaml_token_t *token = lua_touserdata(L, 3);
  yaml_parser_set_input_string(parser, str, size);
#if 0
  for (;;) {
    yaml_token_t token;
    x(L, yaml_parser_scan(parser, &token));
    int ty = token.type;
    printf("%d\n", ty);
    yaml_token_delete(&token);
    if (ty == YAML_STREAM_END_TOKEN) {
      break;
    }
  }
  lua_newtable(L);
#else
  eat(L, parser, token, YAML_STREAM_START_TOKEN);
  eat(L, parser, token, YAML_DOCUMENT_START_TOKEN);
  advance(L, parser, token);
  parsevalue(L, parser, token);
  checktype(L, token, YAML_STREAM_END_TOKEN);
#endif
  return 1;
}

static int wowapi_yaml_parse(lua_State *L) {
  lua_settop(L, 1);
  lua_pushvalue(L, lua_upvalueindex(1));
  lua_insert(L, 1);
  yaml_parser_t parser;
  yaml_parser_initialize(&parser);
  lua_pushlightuserdata(L, &parser);
  yaml_token_t token;
  memset(&token, 0, sizeof(token));
  lua_pushlightuserdata(L, &token);
  int err = lua_pcall(L, 3, 1, 0);
  yaml_token_delete(&token);
  yaml_parser_delete(&parser);
  return err ? lua_error(L) : 1;
}

struct buf {
  unsigned char *p;
  size_t a;
  size_t z;
};

static int dooutput(void *data, unsigned char *buffer, size_t size) {
  struct buf *buf = data;
  if (size > buf->a - buf->z) {
    size_t aa = buf->a * 2;
    if (aa <= buf->a) {
      return 0;
    }
    buf->p = realloc(buf->p, aa);
    if (!buf->p) {
      return 0;
    }
    buf->a = aa;
  }
  memcpy(buf->p + buf->z, buffer, size);
  buf->z += size;
  return 1;
}

static void printscalar(lua_State *L, yaml_emitter_t *emitter,
                        yaml_event_t *event, int idx) {
  int type = lua_type(L, idx);
  switch (type) {
    case LUA_TSTRING: {
      size_t z;
      const unsigned char *s = (const unsigned char *)lua_tolstring(L, idx, &z);
      x(L, yaml_scalar_event_initialize(event, 0, 0, s, z, 1, 1, 0));
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
      x(L, yaml_mapping_start_event_initialize(event, 0, 0, 1, 0));
      x(L, yaml_emitter_emit(emitter, event));
      do {
        printscalar(L, emitter, event, -2);
        printvalue(L, emitter, event);
        lua_pop(L, 1);
      } while (lua_next(L, -2));
      x(L, yaml_mapping_end_event_initialize(event));
      x(L, yaml_emitter_emit(emitter, event));
    }
  } else {
    printscalar(L, emitter, event, -1);
  }
}

static int dopprint(lua_State *L) {
  struct buf buf;
  buf.a = 4096;
  buf.p = malloc(buf.a);
  buf.z = 0;
  x(L, buf.p != 0);
  yaml_emitter_t *emitter = lua_touserdata(L, 2);
  yaml_emitter_set_output(emitter, &dooutput, &buf);
  yaml_event_t event;
  x(L, yaml_stream_start_event_initialize(&event, YAML_UTF8_ENCODING));
  x(L, yaml_emitter_emit(emitter, &event));
  x(L, yaml_document_start_event_initialize(&event, 0, 0, 0, 0));
  x(L, yaml_emitter_emit(emitter, &event));
  lua_settop(L, 1);
  printvalue(L, emitter, &event);
  x(L, yaml_document_end_event_initialize(&event, 1));
  x(L, yaml_emitter_emit(emitter, &event));
  x(L, yaml_stream_end_event_initialize(&event));
  x(L, yaml_emitter_emit(emitter, &event));
  lua_pushlstring(L, (const char *)buf.p, buf.z);
  return 1;
}

static int wowapi_yaml_pprint(lua_State *L) {
  lua_settop(L, 1);
  lua_pushvalue(L, lua_upvalueindex(1));
  lua_insert(L, 1);
  yaml_emitter_t emitter;
  yaml_emitter_initialize(&emitter);
  lua_pushlightuserdata(L, &emitter);
  int err = lua_pcall(L, 2, 1, 0);
  yaml_emitter_delete(&emitter);
  return err ? lua_error(L) : 1;
}

int luaopen_wowapi_yaml(lua_State *L) {
  lua_newtable(L);
  lua_pushcfunction(L, doparse);
  lua_pushcclosure(L, wowapi_yaml_parse, 1);
  lua_setfield(L, -2, "parse");
  lua_pushcfunction(L, dopprint);
  lua_pushcclosure(L, wowapi_yaml_pprint, 1);
  lua_setfield(L, -2, "pprint");
  return 1;
}
