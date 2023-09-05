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
    local text = readfile(dir .. mv)
    local code = string.dump(loadstring(text, mv))
    local escaped = {}
    for i = 1, code:len() do
      table.insert(escaped, string.format('\\%03o', code:byte(i)))
    end
    modules[mk] = table.concat(escaped, '')
  end
end
local package = rockspec.package:gsub('-', '')
io.output(package .. '.c')
io.write([[#include "lauxlib.h"
#include "lualib.h"
struct module {
  const char *name;
  const char *code;
  size_t size;
};
static const struct module modules[] = {
]])
for k, v in sorted(modules) do
  io.write(('  {"%s", "%s", %d},\n'):format(k, v, v:len()))
end
io.write('};\n')
io.write(('void preload_%s(lua_State *L) {'):format(package))
io.write([[
  lua_getglobal(L, "package");
  lua_getfield(L, -1, "preload");
  for (size_t i = 0; i < sizeof(modules) / sizeof(struct module); ++i) {
    const struct module *m = &modules[i];
    luaL_loadbufferx(L, m->code, m->size, m->name, "b");
    lua_setfield(L, -2, m->name);
  }
  lua_pop(L, 2);
}
]])
