local function readfile(filename)
  local f = assert(io.open(filename, 'r'))
  local content = assert(f:read('*a'))
  f:close()
  return content
end
local function sorted(t)
  local ks = {}
  for k in pairs(t) do
    table.insert(ks, k)
  end
  table.sort(ks)
  return coroutine.wrap(function()
    for _, k in ipairs(ks) do
      coroutine.yield(k, t[k])
    end
  end)
end
local manifest = {}
setfenv(loadfile('luarocks/lib/luarocks/rocks-5.1/manifest'), manifest)()
local modules = {}
for _, rv in pairs(manifest.repository) do
  local _, mvs = next(rv)
  for mk, mv in pairs(mvs[1].modules) do
    if mv:sub(-4) == '.lua' then
      if mk:sub(-5) == '.init' then
        mk = mk:sub(1, -6)
      end
      assert(not modules[mk])
      modules[mk] = readfile('luarocks/share/lua/5.1/' .. mv)
    end
  end
end
io.output('rocks.c')
io.write([[#include "lauxlib.h"
#include "lualib.h"
struct module {
  const char *name;
  const char *code;
};
static const struct module modules[] = {
]])
for k, v in sorted(modules) do
  v = v:gsub('\\', '\\\\'):gsub('\n', '\\n\\\n'):gsub('"', '\\"')
  io.write(('  {"%s", "%s"},\n'):format(k, v))
end
io.write([[};
void preload_luarocks(lua_State *L) {
  lua_getglobal(L, "package");
  lua_getfield(L, -1, "preload");
  for (size_t i = 0; i < sizeof(modules) / sizeof(struct module); ++i) {
    const struct module *m = &modules[i];
    luaL_loadstring(L, m->code);
    lua_setfield(L, -2, m->name);
  }
  lua_pop(L, 2);
}
]])
