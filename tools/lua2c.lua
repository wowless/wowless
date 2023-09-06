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
local cmodules = {}
for i = 2, #arg do
  local p = arg[i]:find('=')
  local mk = arg[i]:sub(1, p - 1)
  local mv = arg[i]:sub(p + 1)
  assert(not modules[mk] and not cmodules[mk])
  if mv == 'c' then
    cmodules[mk] = mk:gsub('%.', '_')
  else
    modules[mk] = readfile(mv)
  end
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
io.write([[};
struct cmodule {
  const char *name;
  lua_CFunction func;
};
]])
for _, v in sorted(cmodules) do
  io.write('extern int luaopen_' .. v .. '(lua_State *);\n')
end
io.write('static const struct cmodule cmodules[] = {\n')
for k, v in sorted(cmodules) do
  io.write(('  {"%s", luaopen_%s},\n'):format(k, v))
end
io.write([[};
void preload_]] .. package .. [[(lua_State *L) {
  lua_getglobal(L, "package");
  lua_getfield(L, -1, "preload");
  for (size_t i = 0; i < sizeof(modules) / sizeof(struct module); ++i) {
    const struct module *m = &modules[i];
    luaL_loadstring(L, m->code);
    lua_setfield(L, -2, m->name);
  }
  for (size_t i = 0; i < sizeof(cmodules) / sizeof(struct cmodule); ++i) {
    const struct cmodule *m = &cmodules[i];
    lua_pushcfunction(L, m->func);
    lua_setfield(L, -2, m->name);
  }
  lua_pop(L, 2);
}
]])
