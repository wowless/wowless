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
    lua_pushlstring(L, s, z);
    lua_Number n = lua_tonumber(L, -1);
    if (n != 0) {
      lua_pop(L, 1);
      lua_pushnumber(L, n);
    } else if (z == 1 && *s == '0') {
      lua_pop(L, 1);
      lua_pushnumber(L, 0);
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
  size_t size;
  const unsigned char *str =
      (const unsigned char *)luaL_checklstring(L, 1, &size);
  yaml_parser_t *parser = lua_touserdata(L, 2);
  yaml_token_t *token = lua_touserdata(L, 3);
  yaml_parser_set_input_string(parser, str, size);
  eat(L, parser, token, YAML_STREAM_START_TOKEN);
  eat(L, parser, token, YAML_DOCUMENT_START_TOKEN);
  advance(L, parser, token);
  parsevalue(L, parser, token);
  checktype(L, token, YAML_STREAM_END_TOKEN);
  return 1;
}

static int wowapi_yaml_parse(lua_State *L) {
  lua_settop(L, 1);
  lua_pushvalue(L, lua_upvalueindex(1));
  lua_insert(L, 1);
  yaml_parser_t parser;
  x(L, yaml_parser_initialize(&parser));
  lua_pushlightuserdata(L, &parser);
  yaml_token_t token;
  memset(&token, 0, sizeof(token));
  lua_pushlightuserdata(L, &token);
  int err = lua_pcall(L, 3, 1, 0);
  yaml_token_delete(&token);
  yaml_parser_delete(&parser);
  return err ? lua_error(L) : 1;
}

int luaopen_wowapi_cyaml(lua_State *L) {
  lua_createtable(L, 0, 1);
  lua_pushcfunction(L, doparse);
  lua_pushcclosure(L, wowapi_yaml_parse, 1);
  lua_setfield(L, -2, "parse");
  return 1;
}
