local rules = {
  mkninja = {
    command = 'lua tools/mkninja.lua',
    pool = 'console',
  },
}

local builds = {
  {
    ins = { 'build/cmake/test', 'build/cmake/outs', 'build/cmake/pngs' },
    outs = 'all',
    rule = 'phony',
  },
  {
    ins = 'build/cmake/addons.txt',
    outs = 'addon',
    rule = 'phony',
  },
  {
    ins = {
      'CMakeLists.txt',
      'tools/mkninja.lua',
    },
    outs = 'build.ninja',
    rule = 'mkninja',
  },
}

local function flatten(x)
  local t = {}
  local function doit(y)
    if type(y) == 'string' then
      table.insert(t, y)
    else
      for _, z in ipairs(y) do
        doit(z)
      end
    end
  end
  doit(x)
  table.sort(t)
  return table.concat(t, ' ')
end

local usedrules = {}
for _, b in ipairs(builds) do
  assert(b.rule == 'phony' or rules[b.rule], 'unknown rule ' .. b.rule)
  usedrules[b.rule] = true
end
for k in pairs(rules) do
  assert(usedrules[k], 'unused rule ' .. k)
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

local out = {}
for k, v in sorted(rules) do
  table.insert(out, 'rule ' .. k)
  for rk, rv in sorted(v) do
    table.insert(out, '  ' .. rk .. ' = ' .. rv)
  end
end
for _, b in ipairs(builds) do
  local bb = { 'build' }
  if b.outs then
    table.insert(bb, flatten(b.outs))
  end
  if b.outs_implicit then
    table.insert(bb, '|')
    table.insert(bb, flatten(b.outs_implicit))
  end
  table.insert(bb, ':')
  table.insert(bb, b.rule)
  if b.ins then
    table.insert(bb, flatten(b.ins))
  end
  if b.ins_implicit then
    table.insert(bb, '|')
    table.insert(bb, flatten(b.ins_implicit))
  end
  table.insert(out, table.concat(bb, ' '))
  for k, v in sorted(b.args or {}) do
    table.insert(out, '  ' .. k .. ' = ' .. v)
  end
end
table.insert(out, 'subninja build/cmake/build.ninja')
table.insert(out, 'default build/cmake/test')

local f = io.open('build.ninja', 'w')
f:write(table.concat(out, '\n'))
f:write('\n')
f:close()

os.execute([[
  cmake \
  -B build/cmake \
  -G Ninja \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
  -DCMAKE_NINJA_OUTPUT_PATH_PREFIX=build/cmake/ \
  -DCMAKE_C_FLAGS="-D_GNU_SOURCE -DNDEBUG -ffast-math -O3" \
]])
