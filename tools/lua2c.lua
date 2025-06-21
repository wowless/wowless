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
local function numentries(t)
  local n = 0
  for _ in pairs(t) do
    n = n + 1
  end
  return n
end
local package = arg[1]
local modules = {}
local cmodules = {}
local preloads = {}
for i = 2, #arg do
  local p = arg[i]:find('=')
  local mk = arg[i]:sub(1, p - 1)
  local mv = arg[i]:sub(p + 1)
  assert(not modules[mk] and not cmodules[mk])
  if mv == 'p' then
    preloads[mk] = mk
  elseif mv == 'c' then
    cmodules[mk] = mk:gsub('%.', '_')
  else
    modules[mk] = readfile(mv)
  end
end
io.output(package .. '.c')
io.write('#include "lualib.h"\n')
io.write('#include "tools/lua2c.h"\n')
if next(preloads) then
  for k in sorted(preloads) do
    io.write(('extern const struct preload preload_%s;\n'):format(k))
  end
  io.write('static const struct preload *preloads[] = {\n')
  for k in sorted(preloads) do
    io.write(('  &preload_%s,\n'):format(k))
  end
  io.write('};\n')
end
if next(modules) then
  for k in sorted(modules) do
    io.write(('extern const struct module lua2c_%s;\n'):format(k:gsub('%.', '_')))
  end
  io.write('static const struct module *modules[] = {\n')
  for k in sorted(modules) do
    io.write(('  &lua2c_%s,\n'):format(k:gsub('%.', '_')))
  end
  io.write('};\n')
end
if next(cmodules) then
  for _, v in sorted(cmodules) do
    io.write('extern int luaopen_' .. v .. '(lua_State *);\n')
  end
  io.write('static const struct cmodule cmodules[] = {\n')
  for k, v in sorted(cmodules) do
    io.write(('  {"%s", luaopen_%s},\n'):format(k, v))
  end
  io.write('};\n')
end
io.write(('const struct preload preload_%s = {\n'):format(package))
io.write(('  .preloads = %s,\n'):format(next(preloads) and 'preloads' or 0))
io.write(('  .npreloads = %d,\n'):format(numentries(preloads)))
io.write(('  .modules = %s,\n'):format(next(modules) and 'modules' or 0))
io.write(('  .nmodules = %d,\n'):format(numentries(modules)))
io.write(('  .cmodules = %s,\n'):format(next(cmodules) and 'cmodules' or 0))
io.write(('  .ncmodules = %d,\n'):format(numentries(cmodules)))
io.write('};\n')
