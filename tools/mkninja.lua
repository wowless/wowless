local function find(spec)
  local f = io.popen('find ' .. spec .. ' -type f')
  local deps = f:read('*a')
  f:close()
  local t = {}
  for k in deps:gmatch('[^\n]+') do
    table.insert(t, k)
  end
  return t
end

-- TODO get this from gentest.lua
local addonGeneratedTypes = {
  builds = { 'data/builds.yaml' },
  cvars = { 'data/cvars.yaml' },
  global_wow = { 'data/globals/wow.yaml' },
  global_wow_beta = { 'data/globals/wow_beta.yaml' },
  global_wow_classic = { 'data/globals/wow_classic.yaml' },
  global_wow_classic_beta = { 'data/globals/wow_classic_beta.yaml' },
  global_wow_classic_era = { 'data/globals/wow_classic_era.yaml' },
  global_wow_classic_era_ptr = { 'data/globals/wow_classic_era_ptr.yaml' },
  global_wow_classic_ptr = { 'data/globals/wow_classic_ptr.yaml' },
  global_wowt = { 'data/globals/wowt.yaml' },
  globalapis = { 'build/api.stamp' },
  namespaceapis = { 'build/api.stamp' },
  uiobjectapis = find('data/uiobjects -name \'*.yaml\''),
}

local addonGeneratedFiles = {}
for k in pairs(addonGeneratedTypes) do
  table.insert(addonGeneratedFiles, 'addon/universal/Wowless/' .. k .. '.lua')
end

local taintedLua = 'tainted-lua/build/linux/bin/Release/lua5.1'

local pools = {
  fetch_pool = 1,
  run_pool = 2,
}

local rules = {
  fetch = {
    command = 'lua tools/fetch.lua $product && touch $out',
    pool = 'fetch_pool',
  },
  mkaddon = {
    command = taintedLua .. ' tools/gentest.lua -f $type',
  },
  mktaintedlua = {
    command = 'cd tainted-lua && rm -rf build && cmake --preset linux && cmake --build --preset linux',
  },
  mktestout = {
    command = 'bash -c "set -o pipefail && busted 2>&1 | tee $out"',
  },
  mkwowlessext = {
    command = 'luarocks build --no-install',
  },
  run = {
    command = taintedLua .. ' wowless.lua -p $product -e1 > $out || true',
    pool = 'run_pool',
  },
  stamp = {
    command = 'touch $out',
  },
}

local builds = {
  {
    ins = { 'test.out', 'outs' },
    outs = 'all',
    rule = 'phony',
  },
  {
    ins = addonGeneratedFiles,
    outs = 'addon',
    rule = 'phony',
  },
  {
    ins = find('tainted-lua -not -path \'tainted-lua/build/*\''),
    outs_implicit = taintedLua,
    rule = 'mktaintedlua',
  },
  {
    ins = find('data/api'),
    outs = 'build/api.stamp',
    rule = 'stamp',
  },
  {
    ins = {
      'build/api.stamp',
      (function()
        local skip = {
          ['tools/mkninja.lua'] = true,
          ['wowless/ext.o'] = true,
          ['wowless/ext.so'] = true,
        }
        for _, k in ipairs(addonGeneratedFiles) do
          skip[k] = true
        end
        local t = {}
        for _, k in ipairs(find('addon data spec tools wowapi wowless -not -path \'data/api/*\'')) do
          if not skip[k] then
            table.insert(t, k)
          end
        end
        return t
      end)(),
    },
    outs = 'build/wowless.stamp',
    rule = 'stamp',
  },
  {
    ins = { '.busted', 'wowless/ext.so', 'build/wowless.stamp', addonGeneratedFiles, taintedLua },
    outs = 'test.out',
    rule = 'mktestout',
  },
  {
    ins = { 'wowless-scm-0.rockspec', 'wowless/ext.c' },
    outs_implicit = { 'wowless/ext.o', 'wowless/ext.so' },
    rule = 'mkwowlessext',
  },
}

for k, v in pairs(addonGeneratedTypes) do
  table.insert(builds, {
    args = { ['type'] = k },
    ins = { taintedLua, v },
    outs_implicit = 'addon/universal/Wowless/' .. k .. '.lua',
    rule = 'mkaddon',
  })
end

local runouts = {}
for _, p in ipairs(require('wowless.util').productList()) do
  local stamp = 'build/extracts/' .. p .. '.stamp'
  table.insert(builds, {
    args = { product = p },
    ins = { 'data/builds.yaml', 'tools/fetch.lua' },
    outs = stamp,
    rule = 'fetch',
  })
  local runout = 'out/' .. p .. '.txt'
  table.insert(runouts, runout)
  table.insert(builds, {
    args = { product = p },
    ins = { 'wowless/ext.so', 'build/wowless.stamp', stamp, taintedLua },
    outs = runout,
    rule = 'run',
  })
end

table.insert(builds, {
  ins = runouts,
  rule = 'phony',
  outs = 'outs',
})

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

local rulenames = {}
for k in pairs(rules) do
  table.insert(rulenames, k)
end
table.sort(rulenames)

local out = {}
for p, n in pairs(pools) do
  table.insert(out, 'pool ' .. p)
  table.insert(out, '  depth = ' .. n)
end
for _, k in ipairs(rulenames) do
  table.insert(out, 'rule ' .. k)
  for rk, rv in pairs(rules[k]) do
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
  table.insert(bb, '|')
  table.insert(bb, flatten(b.ins))
  table.insert(out, table.concat(bb, ' '))
  for k, v in pairs(b.args or {}) do
    table.insert(out, '  ' .. k .. ' = ' .. v)
  end
end
table.insert(out, 'default test.out')

local f = io.open('build.ninja', 'w')
f:write(table.concat(out, '\n'))
f:write('\n')
f:close()
