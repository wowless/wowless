#include "SDL3/SDL.h"

#include <stdlib.h>

#include "lauxlib.h"
#include "lua.h"

typedef struct {
  SDL_Surface *sdl;
  void *pixels;
} surface;

static int surfaceGC(lua_State *L) {
  surface *sur = luaL_checkudata(L, 1, "tools.sdl.surface");
  SDL_DestroySurface(sur->sdl);
  free(sur->pixels);
  return 0;
}

static int createSurfaceFromRGBA(lua_State *L) {
  int w = luaL_checknumber(L, 1);
  int h = luaL_checknumber(L, 2);
  size_t sz;
  const char *rgba = luaL_checklstring(L, 3, &sz);
  surface *sur = lua_newuserdata(L, sizeof(*sur));
  memset(sur, 0, sizeof(*sur));
  luaL_getmetatable(L, "tools.sdl.surface");
  lua_setmetatable(L, -2);
  sur->pixels = malloc(sz);
  if (!sur->pixels) {
    return luaL_error(L, "out of memory");
  }
  memcpy(sur->pixels, rgba, sz);
  sur->sdl =
      SDL_CreateSurfaceFrom(w, h, SDL_PIXELFORMAT_RGBA32, sur->pixels, 4 * w);
  if (!sur->sdl) {
    return luaL_error(L, "SDL error: %s", SDL_GetError());
  }
  return 1;
}

static int surfaceHeight(lua_State *L) {
  surface *sur = luaL_checkudata(L, 1, "tools.sdl.surface");
  lua_pushnumber(L, sur->sdl->h);
  return 1;
}

static int surfaceSaveBMP(lua_State *L) {
  surface *sur = luaL_checkudata(L, 1, "tools.sdl.surface");
  const char *file = luaL_checkstring(L, 2);
  if (!SDL_SaveBMP(sur->sdl, file)) {
    return luaL_error(L, "SDL error: %s", SDL_GetError());
  }
  return 0;
}

static int surfaceWidth(lua_State *L) {
  surface *sur = luaL_checkudata(L, 1, "tools.sdl.surface");
  lua_pushnumber(L, sur->sdl->w);
  return 1;
}

int luaopen_tools_sdl(lua_State *L) {
  SDL_Init(SDL_INIT_VIDEO);
  atexit(SDL_Quit);
  if (luaL_newmetatable(L, "tools.sdl.surface")) {
    lua_newtable(L);
    lua_pushcfunction(L, surfaceHeight);
    lua_setfield(L, -2, "height");
    lua_pushcfunction(L, surfaceSaveBMP);
    lua_setfield(L, -2, "SaveBMP");
    lua_pushcfunction(L, surfaceWidth);
    lua_setfield(L, -2, "width");
    lua_setfield(L, -2, "__index");
    lua_pushcfunction(L, surfaceGC);
    lua_setfield(L, -2, "__gc");
  }
  lua_pop(L, 1);
  lua_newtable(L);
  lua_pushcfunction(L, createSurfaceFromRGBA);
  lua_setfield(L, -2, "CreateSurfaceFromRGBA");
  return 1;
}
