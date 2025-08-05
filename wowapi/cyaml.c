#include "lauxlib.h"
#include "lua.h"
#include "yaml.h"

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
  eat(L, parser, token, YAML_DOCUMENT_START_TOKEN);
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

static void printstring(lua_State *L, yaml_emitter_t *emitter,
                        yaml_event_t *event, int idx) {
  size_t z;
  const unsigned char *s = (const unsigned char *)lua_tolstring(L, idx, &z);
  x(L, yaml_scalar_event_initialize(event, 0, 0, s, z, 1, 1, 0));
  x(L, yaml_emitter_emit(emitter, event));
}

static void printscalar(lua_State *L, yaml_emitter_t *emitter,
                        yaml_event_t *event, int idx) {
  int type = lua_type(L, idx);
  switch (type) {
    case LUA_TBOOLEAN: {
      if (lua_toboolean(L, idx)) {
        x(L, yaml_scalar_event_initialize(event, 0, 0, "true", 4, 1, 1, 0));
      } else {
        x(L, yaml_scalar_event_initialize(event, 0, 0, "false", 5, 1, 1, 0));
      }
      x(L, yaml_emitter_emit(emitter, event));
      break;
    }
    case LUA_TNUMBER: {
      lua_pushvalue(L, idx);
      printstring(L, emitter, event, -1);
      lua_pop(L, 1);
      break;
    }
    case LUA_TSTRING: {
      printstring(L, emitter, event, idx);
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
        lua_pushnil(L);
        while (lua_next(L, -3)) {
          printscalar(L, emitter, event, -2);
          printvalue(L, emitter, event);
          lua_pop(L, 1);
        }
        x(L, yaml_mapping_end_event_initialize(event));
        x(L, yaml_emitter_emit(emitter, event));
      }
      lua_pop(L, 1);
    }
  } else {
    printscalar(L, emitter, event, -1);
  }
}

static int dopprint(lua_State *L) {
  lua_settop(L, 3);
  luaL_checkstack(L, 100, "yaml");
  yaml_emitter_t *emitter = lua_touserdata(L, 2);
  yaml_event_t event;
  x(L, yaml_stream_start_event_initialize(&event, YAML_UTF8_ENCODING));
  x(L, yaml_emitter_emit(emitter, &event));
  x(L, yaml_document_start_event_initialize(&event, 0, 0, 0, 0));
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
