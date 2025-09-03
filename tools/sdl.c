#include "SDL3/SDL.h"

#include <stdlib.h>

#include "lauxlib.h"
#include "lua.h"

static int rendererCreateTextureFromSurface(lua_State *L) {
  SDL_Renderer **ren = luaL_checkudata(L, 1, "tools.sdl.renderer");
  SDL_Surface **sur = luaL_checkudata(L, 2, "tools.sdl.surface");
  SDL_Texture **tex = lua_newuserdata(L, sizeof(*tex));
  *tex = 0;
  luaL_getmetatable(L, "tools.sdl.texture");
  lua_setmetatable(L, -2);
  *tex = SDL_CreateTextureFromSurface(*ren, *sur);
  if (!*tex) {
    return luaL_error(L, "SDL error: %s", SDL_GetError());
  }
  return 1;
}

static int rendererRenderClear(lua_State *L) {
  SDL_Renderer **ren = luaL_checkudata(L, 1, "tools.sdl.renderer");
  if (!SDL_RenderClear(*ren)) {
    return luaL_error(L, "SDL error: %s", SDL_GetError());
  }
  return 0;
}

static lua_Number optnum(lua_State *L, int idx, const char *f, lua_Number def) {
  lua_getfield(L, idx, f);
  lua_Number ret = lua_isnumber(L, -1) ? lua_tonumber(L, -1) : def;
  lua_pop(L, 1);
  return ret;
}

static int rendererRenderGeometry(lua_State *L) {
  SDL_Renderer **ren = luaL_checkudata(L, 1, "tools.sdl.renderer");
  SDL_Texture **tex = luaL_checkudata(L, 2, "tools.sdl.texture");
  luaL_checktype(L, 3, LUA_TTABLE);
  luaL_checktype(L, 4, LUA_TTABLE);
  lua_settop(L, 4);
  int nv = lua_objlen(L, 3);
  int ni = lua_objlen(L, 4);
  SDL_Vertex *vertices = malloc(nv * sizeof(*vertices));
  int *indices = malloc(ni * sizeof(*indices));
  if (!vertices || !indices) {
    free(vertices);
    free(indices);
    return luaL_error(L, "out of memory");
  }
  for (int i = 1; i <= nv; ++i) {
    lua_rawgeti(L, 3, i);
    vertices[i - 1] = (SDL_Vertex){
        .color =
            {
                    .r = optnum(L, 5, "r", 1),
                    .g = optnum(L, 5, "g", 1),
                    .b = optnum(L, 5, "b", 1),
                    .a = optnum(L, 5, "a", 1),
                    },
        .position =
            {
                    .x = optnum(L, 5, "px", 0),
                    .y = optnum(L, 5, "py", 0),
                    },
        .tex_coord =
            {
                    .x = optnum(L, 5, "tx", 0),
                    .y = optnum(L, 5, "ty", 0),
                    },
    };
    lua_pop(L, 1);
  }
  for (int i = 1; i <= ni; ++i) {
    lua_rawgeti(L, 4, i);
    indices[i - 1] = lua_tonumber(L, -1) - 1;
    lua_pop(L, 1);
  }
  bool okay = SDL_RenderGeometry(*ren, *tex, vertices, nv, indices, ni);
  free(vertices);
  free(indices);
  if (!okay) {
    return luaL_error(L, "SDL error: %s", SDL_GetError());
  }
  return 0;
}

static int rendererRenderPresent(lua_State *L) {
  SDL_Renderer **ren = luaL_checkudata(L, 1, "tools.sdl.renderer");
  if (!SDL_RenderPresent(*ren)) {
    return luaL_error(L, "SDL error: %s", SDL_GetError());
  }
  return 0;
}

static int rendererRenderTexture(lua_State *L) {
  SDL_Renderer **ren = luaL_checkudata(L, 1, "tools.sdl.renderer");
  SDL_Texture **tex = luaL_checkudata(L, 2, "tools.sdl.texture");
  if (!SDL_RenderTexture(*ren, *tex, 0, 0)) {
    return luaL_error(L, "SDL error: %s", SDL_GetError());
  }
  return 0;
}

static int surfaceGC(lua_State *L) {
  SDL_Surface **sur = luaL_checkudata(L, 1, "tools.sdl.surface");
  if (*sur) {
    SDL_DestroySurface(*sur);
  }
  return 0;
}

static int rendererGC(lua_State *L) {
  SDL_Renderer **ren = luaL_checkudata(L, 1, "tools.sdl.renderer");
  if (*ren) {
    SDL_DestroyRenderer(*ren);
  }
  return 0;
}

static int surfaceCreateSoftwareRenderer(lua_State *L) {
  SDL_Surface **sur = luaL_checkudata(L, 1, "tools.sdl.surface");
  SDL_Renderer **ren = lua_newuserdata(L, sizeof(*ren));
  *ren = 0;
  luaL_getmetatable(L, "tools.sdl.renderer");
  lua_setmetatable(L, -2);
  *ren = SDL_CreateSoftwareRenderer(*sur);
  if (!*ren) {
    return luaL_error(L, "SDL error: %s", SDL_GetError());
  }
  return 1;
}

static int surfaceHeight(lua_State *L) {
  SDL_Surface **sur = luaL_checkudata(L, 1, "tools.sdl.surface");
  lua_pushnumber(L, (*sur)->h);
  return 1;
}

static int surfaceSaveBMP(lua_State *L) {
  SDL_Surface **sur = luaL_checkudata(L, 1, "tools.sdl.surface");
  const char *file = luaL_checkstring(L, 2);
  if (!SDL_SaveBMP(*sur, file)) {
    return luaL_error(L, "SDL error: %s", SDL_GetError());
  }
  return 0;
}

static int surfaceWidth(lua_State *L) {
  SDL_Surface **sur = luaL_checkudata(L, 1, "tools.sdl.surface");
  lua_pushnumber(L, (*sur)->w);
  return 1;
}

static int textureGC(lua_State *L) {
  SDL_Texture **tex = luaL_checkudata(L, 1, "tools.sdl.texture");
  if (*tex) {
    SDL_DestroyTexture(*tex);
  }
  return 0;
}

static int textureHeight(lua_State *L) {
  SDL_Texture **tex = luaL_checkudata(L, 1, "tools.sdl.texture");
  lua_pushnumber(L, (*tex)->h);
  return 1;
}

static int blendmodes[] = {SDL_BLENDMODE_ADD, SDL_BLENDMODE_BLEND,
                           SDL_BLENDMODE_MOD, SDL_BLENDMODE_MUL,
                           SDL_BLENDMODE_NONE};
static const char *blendmodeopt[] = {"add", "blend", "mod", "mul", "none", 0};

static int textureSetTextureBlendMode(lua_State *L) {
  SDL_Texture **tex = luaL_checkudata(L, 1, "tools.sdl.texture");
  int mode = luaL_checkoption(L, 2, 0, blendmodeopt);
  if (!SDL_SetTextureBlendMode(*tex, blendmodes[mode])) {
    return luaL_error(L, "SDL error: %s", SDL_GetError());
  }
  return 0;
}

static int textureWidth(lua_State *L) {
  SDL_Texture **tex = luaL_checkudata(L, 1, "tools.sdl.texture");
  lua_pushnumber(L, (*tex)->w);
  return 1;
}

static int topCreateSurface(lua_State *L) {
  int w = luaL_checknumber(L, 1);
  int h = luaL_checknumber(L, 2);
  size_t sz;
  const char *rgba = luaL_optlstring(L, 3, 0, &sz);
  if (rgba && sz != w * h * 4) {
    return luaL_error(L, "dimensions do not match pixel data size");
  }
  SDL_Surface **sur = lua_newuserdata(L, sizeof(*sur));
  *sur = 0;
  luaL_getmetatable(L, "tools.sdl.surface");
  lua_setmetatable(L, -2);
  *sur = SDL_CreateSurface(w, h, SDL_PIXELFORMAT_RGBA32);
  if (!*sur) {
    return luaL_error(L, "SDL error: %s", SDL_GetError());
  }
  SDL_memcpy((*sur)->pixels, rgba, sz);
  return 1;
}

int luaopen_tools_sdl(lua_State *L) {
  SDL_Init(SDL_INIT_VIDEO);
  atexit(SDL_Quit);
  if (luaL_newmetatable(L, "tools.sdl.renderer")) {
    lua_newtable(L);
    lua_pushcfunction(L, rendererCreateTextureFromSurface);
    lua_setfield(L, -2, "CreateTextureFromSurface");
    lua_pushcfunction(L, rendererRenderClear);
    lua_setfield(L, -2, "RenderClear");
    lua_pushcfunction(L, rendererRenderGeometry);
    lua_setfield(L, -2, "RenderGeometry");
    lua_pushcfunction(L, rendererRenderPresent);
    lua_setfield(L, -2, "RenderPresent");
    lua_pushcfunction(L, rendererRenderTexture);
    lua_setfield(L, -2, "RenderTexture");
    lua_setfield(L, -2, "__index");
    lua_pushcfunction(L, rendererGC);
    lua_setfield(L, -2, "__gc");
  }
  lua_pop(L, 1);
  if (luaL_newmetatable(L, "tools.sdl.surface")) {
    lua_newtable(L);
    lua_pushcfunction(L, surfaceCreateSoftwareRenderer);
    lua_setfield(L, -2, "CreateSoftwareRenderer");
    lua_pushcfunction(L, surfaceHeight);
    lua_setfield(L, -2, "Height");
    lua_pushcfunction(L, surfaceSaveBMP);
    lua_setfield(L, -2, "SaveBMP");
    lua_pushcfunction(L, surfaceWidth);
    lua_setfield(L, -2, "Width");
    lua_setfield(L, -2, "__index");
    lua_pushcfunction(L, surfaceGC);
    lua_setfield(L, -2, "__gc");
  }
  lua_pop(L, 1);
  if (luaL_newmetatable(L, "tools.sdl.texture")) {
    lua_newtable(L);
    lua_pushcfunction(L, textureHeight);
    lua_setfield(L, -2, "Height");
    lua_pushcfunction(L, textureSetTextureBlendMode);
    lua_setfield(L, -2, "SetTextureBlendMode");
    lua_pushcfunction(L, textureWidth);
    lua_setfield(L, -2, "Width");
    lua_setfield(L, -2, "__index");
    lua_pushcfunction(L, textureGC);
    lua_setfield(L, -2, "__gc");
  }
  lua_pop(L, 1);
  lua_newtable(L);
  lua_pushcfunction(L, topCreateSurface);
  lua_setfield(L, -2, "CreateSurface");
  return 1;
}
