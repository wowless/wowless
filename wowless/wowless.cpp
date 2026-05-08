extern "C" {
#include "wowless/uiobject.h"

#include <stdlib.h>

#include "lauxlib.h"
#include "lua.h"
}

#include <deque>

struct Wowless {
  std::deque<wowless_uiobject> uiobjects;
};

static void *wowless_lua_alloc(void * /*ud*/, void *ptr, size_t /*osize*/,
                               size_t nsize) {
  if (nsize == 0) {
    free(ptr);
    return nullptr;
  }
  return realloc(ptr, nsize);
}

static int wowless_gc(lua_State *L) {
  delete *static_cast<Wowless **>(lua_touserdata(L, 1));
  return 0;
}

static const char wowless_sentinel_key = 0;

extern "C" void wowless_uiobject_alloc(lua_State *L, uint16_t type_id) {
  void *ud;
  lua_Alloc f = lua_getallocf(L, &ud);
  Wowless *w = static_cast<Wowless *>(ud);
  if (!w) {
    w = new Wowless();
    lua_setallocf(L, f, w);

    /* Anchor a sentinel full userdata with __gc so the Wowless pool is freed
     * when the lua_State closes. Stored in the registry under a unique key. */
    Wowless **pw = static_cast<Wowless **>(
        lua_newuserdata(L, sizeof(Wowless *)));
    *pw = w;
    lua_newtable(L);
    lua_pushcfunction(L, wowless_gc);
    lua_setfield(L, -2, "__gc");
    lua_setmetatable(L, -2);
    lua_pushlightuserdata(L, (void *)&wowless_sentinel_key);
    lua_insert(L, -2);
    lua_rawset(L, LUA_REGISTRYINDEX);
  }
  w->uiobjects.push_back({WOWLESS_UIOBJECT_MAGIC, type_id, 0});
  lua_pushlightuserdata(L, &w->uiobjects.back());
}
