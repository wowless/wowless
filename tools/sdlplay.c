#include <stdio.h>
#include <stdlib.h>

#include "SDL3/SDL.h"

int main(int argc, char **argv) {
  if (argc != 2) {
    fputs("usage: sdlplay file.bmp\n", stderr);
    return EXIT_FAILURE;
  }
  if (!SDL_Init(SDL_INIT_VIDEO)) {
    SDL_LogCritical(SDL_LOG_CATEGORY_APPLICATION,
                    "could not initialize SDL: %s", SDL_GetError());
    return EXIT_FAILURE;
  }
  SDL_Surface *bmp = SDL_LoadBMP(argv[1]);
  if (!bmp) {
    SDL_LogCritical(SDL_LOG_CATEGORY_APPLICATION, "could not load bitmap: %s",
                    SDL_GetError());
    return EXIT_FAILURE;
  }
  SDL_Window *win = SDL_CreateWindow("moo", 640, 480, 0);
  if (!win) {
    SDL_LogCritical(SDL_LOG_CATEGORY_APPLICATION,
                    "could not create SDL window: %s", SDL_GetError());
    SDL_DestroySurface(bmp);
    SDL_Quit();
    return EXIT_FAILURE;
  }
  for (int i = 0; i < SDL_GetNumRenderDrivers(); ++i) {
    SDL_LogInfo(SDL_LOG_CATEGORY_RENDER, "render driver %d = %s", i,
                SDL_GetRenderDriver(i));
  }
  SDL_Renderer *ren = SDL_CreateRenderer(win, 0);
  if (!ren) {
    SDL_LogCritical(SDL_LOG_CATEGORY_APPLICATION,
                    "could not create SDL renderer: %s", SDL_GetError());
    SDL_DestroyWindow(win);
    SDL_DestroySurface(bmp);
    SDL_Quit();
    return EXIT_FAILURE;
  }
  SDL_Texture *tex = SDL_CreateTextureFromSurface(ren, bmp);
  SDL_DestroySurface(bmp);
  if (!tex) {
    SDL_LogCritical(SDL_LOG_CATEGORY_APPLICATION,
                    "could not load texture from surface: %s", SDL_GetError());
    SDL_DestroyRenderer(ren);
    SDL_DestroyWindow(win);
    SDL_Quit();
    return EXIT_FAILURE;
  }
  SDL_RenderTexture(ren, tex, 0, 0);
  SDL_RenderPresent(ren);
  SDL_Event e;
  while (SDL_WaitEvent(&e) && e.type != SDL_EVENT_QUIT) {
  }
  SDL_DestroyTexture(tex);
  SDL_DestroyRenderer(ren);
  SDL_DestroyWindow(win);
  SDL_Quit();
  return EXIT_SUCCESS;
}
