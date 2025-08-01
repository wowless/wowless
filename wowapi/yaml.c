#include "lua.h"
#include "lauxlib.h"
#include "yaml.h"

static void x(lua_State *L, int err) {
  if (err == 0) {
    luaL_error(L, "yaml: internal error");
  }
}

static void eat(lua_State *L, yaml_parser_t *parser, int type) {
  yaml_event_t event;
  x(L, yaml_parser_parse(parser, &event));
  
}

static int doparse(lua_State *L) {
  size_t size;
  const char *str = luaL_checklstring(L, 1, &size);
  yaml_parser_t *parser = lua_touserdata(L, 2);
  lua_settop(L, 0);
  yaml_parser_set_input_string(parser, str, size);
  yaml_event_t event;
  x(L, yaml_parser_parse(parser, &event));
  if (event.type != YAML_STREAM_START_EVENT) {
    {{}}
  }
  int done = 0;
  while (!done) {
    switch (event.type) {
      case YAML_STREAM_END_EVENT:
        done = 1;
        break;
      default:
        int ty = event.type;
        yaml_event_delete(&event);
        luaL_error(L, "yaml: unexpected event %d", ty);
    }
    yaml_event_delete(&event);
  }
  return 1;
}

static int wowapi_yaml_parse(lua_State *L) {
  lua_settop(L, 1);
  lua_pushvalue(L, lua_upvalueindex(1));
  lua_insert(L, 1);
  yaml_parser_t parser;
  yaml_parser_initialize(&parser);
  lua_pushlightuserdata(L, &parser);
  int err = lua_pcall(L, 2, 1, 0);
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

static void emit_scalar(lua_State *L, int idx, yaml_emitter_t *emitter) {
  int type = lua_type(L, idx);
  switch (type) {
    case LUA_TSTRING: {
      yaml_event_t event;
      size_t z;
      const char *s = lua_tolstring(L, idx, &z);
      x(L, yaml_scalar_event_initialize(&event, 0, 0, s, z, 1, 1, 0));
      x(L, yaml_emitter_emit(emitter, &event));
      break;
    }
    case LUA_TTABLE:
      luaL_error(L, "yaml: want scalar, got table");
    default:
      luaL_error(L, "yaml: unsupported type %s", lua_typename(L, type));
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
  x(L, yaml_document_start_event_initialize(&event, 0, 0, 0, 1));
  x(L, yaml_emitter_emit(emitter, &event));
  lua_settop(L, 1);
  while (lua_gettop(L) != 0) {
    if (lua_istable(L, -1)) {
      x(L, yaml_mapping_start_event_initialize(&event, 0, 0, 1, 0));
      x(L, yaml_emitter_emit(emitter, &event));
      lua_pushnil(L);
      while (lua_next(L, -2)) {
        emit_scalar(L, -2, emitter);
        emit_scalar(L, -1, emitter);
        lua_pop(L, 1);
      }
      x(L, yaml_mapping_end_event_initialize(&event));
      x(L, yaml_emitter_emit(emitter, &event));
    } else {
      emit_scalar(L, -1, emitter);
    }
    lua_pop(L, 1);
  }
  x(L, yaml_document_end_event_initialize(&event, 1));
  x(L, yaml_emitter_emit(emitter, &event));
  x(L, yaml_stream_end_event_initialize(&event));
  x(L, yaml_emitter_emit(emitter, &event));
  lua_pushlstring(L, buf.p, buf.z);
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
