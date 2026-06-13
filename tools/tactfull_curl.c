/*
 * libcurl HTTP client for tactfull.
 * Exports a table with:
 *   get(url) -> string|nil
 *   health(url) -> bool
 *   sleep_ms(ms)
 */

#include <curl/curl.h>
#include <stdlib.h>
#include <string.h>

#ifdef _WIN32
#include <windows.h>
#else
#include <time.h>
#endif

#include "lauxlib.h"
#include "lua.h"

struct buf {
  char *data;
  size_t size;
  size_t cap;
};

static size_t write_cb(char *ptr, size_t size, size_t nmemb, void *ud) {
  struct buf *b = ud;
  size_t n = size * nmemb;
  if (b->size + n > b->cap) {
    b->cap = (b->size + n) * 2 + 4096;
    b->data = realloc(b->data, b->cap);
    if (!b->data) {
      return 0;
    }
  }
  memcpy(b->data + b->size, ptr, n);
  b->size += n;
  return n;
}

static int do_get(lua_State *L, const char *url, long timeout_ms,
                  int discard_body) {
  CURL *c = curl_easy_init();
  if (!c) {
    return luaL_error(L, "curl_easy_init failed");
  }

  struct buf b = {NULL, 0, 0};

  curl_easy_setopt(c, CURLOPT_URL, url);
  curl_easy_setopt(c, CURLOPT_TIMEOUT_MS, timeout_ms);
  if (discard_body) {
    curl_easy_setopt(c, CURLOPT_NOBODY, 1L);
  } else {
    curl_easy_setopt(c, CURLOPT_WRITEFUNCTION, write_cb);
    curl_easy_setopt(c, CURLOPT_WRITEDATA, &b);
  }

  CURLcode res = curl_easy_perform(c);
  long code = 0;
  if (res == CURLE_OK) {
    curl_easy_getinfo(c, CURLINFO_RESPONSE_CODE, &code);
  }
  curl_easy_cleanup(c);

  if (discard_body) {
    lua_pushboolean(L, res == CURLE_OK && code == 200);
    return 1;
  }

  if (res != CURLE_OK || code != 200) {
    free(b.data);
    lua_pushnil(L);
    return 1;
  }

  lua_pushlstring(L, b.data ? b.data : "", b.size);
  free(b.data);
  return 1;
}

static int tactfull_get(lua_State *L) {
  return do_get(L, luaL_checkstring(L, 1), 30000L, 0);
}

static int tactfull_health(lua_State *L) {
  return do_get(L, luaL_checkstring(L, 1), 500L, 1);
}

static int tactfull_sleep_ms(lua_State *L) {
  long ms = luaL_checkinteger(L, 1);
#ifdef _WIN32
  Sleep((DWORD)ms);
#else
  struct timespec ts = {ms / 1000, (ms % 1000) * 1000000L};
  nanosleep(&ts, NULL);
#endif
  return 0;
}

int luaopen_tools_tactfull_curl(lua_State *L) {
  lua_newtable(L);
  lua_pushcfunction(L, tactfull_get);
  lua_setfield(L, -2, "get");
  lua_pushcfunction(L, tactfull_health);
  lua_setfield(L, -2, "health");
  lua_pushcfunction(L, tactfull_sleep_ms);
  lua_setfield(L, -2, "sleep_ms");
  return 1;
}
