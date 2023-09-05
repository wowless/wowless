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
local package = arg[1]
local modules = {}
for i = 2, #arg do
  local p = arg[i]:find('=')
  local mk = arg[i]:sub(1, p - 1)
  local mv = arg[i]:sub(p + 1)
  assert(not modules[mk])
  modules[mk] = readfile(mv)
end
io.output(package .. '.c')
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
io.write('};\n')
io.write(('void preload_%s(lua_State *L) {'):format(package))
io.write([[
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
