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
local rockspec = {}
setfenv(loadfile(arg[1]), rockspec)()
local dir = arg[1]:sub(1, arg[1]:len() - arg[1]:reverse():find('/') + 1)
local modules = {}
for mk, mv in pairs(rockspec.build.modules) do
  if mv:sub(-4) == '.lua' then
    if mk:sub(-5) == '.init' then
      mk = mk:sub(1, -6)
    end
    assert(not modules[mk])
    modules[mk] = readfile(dir .. mv)
  end
end
local package = rockspec.package:gsub('-', '')
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
io.output(package .. '.c.deps')
io.write(package .. '.c: ' .. arg[1])
for _, mv in pairs(rockspec.build.modules) do
  if mv:sub(-4) == '.lua' then
    io.write(' ' .. dir .. mv)
  end
end
