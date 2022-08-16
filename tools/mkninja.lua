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

local productList = require('wowless.util').productList()

-- TODO get this from gentest.lua
local addonGeneratedTypes = {
  builds = { 'data/builds.yaml' },
  cvars = { 'data/cvars.yaml' },
  globalapis = { 'build/api.stamp' },
  namespaceapis = { 'build/api.stamp' },
  uiobjectapis = find('data/uiobjects -name \'*.yaml\''),
}
local perProductAddonGeneratedTypes = {
  globals = function(p)
    return { 'data/globals/' .. p .. '.yaml' }
  end,
  product = function()
    return {}
  end,
}

local addonGeneratedFiles = {}
for k in pairs(addonGeneratedTypes) do
  table.insert(addonGeneratedFiles, 'addon/universal/Wowless/' .. k .. '.lua')
end
for k in pairs(perProductAddonGeneratedTypes) do
  for _, p in ipairs(productList) do
    table.insert(addonGeneratedFiles, 'addon/' .. p .. '/WowlessData/' .. k .. '.lua')
  end
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
    command = taintedLua .. ' tools/gentest.lua -f $type $productarg',
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
    ins = { taintedLua, v, 'tools/gentest.lua' },
    outs_implicit = 'addon/universal/Wowless/' .. k .. '.lua',
    rule = 'mkaddon',
  })
end
for k, v in pairs(perProductAddonGeneratedTypes) do
  for _, p in ipairs(productList) do
    table.insert(builds, {
      args = { productarg = '-p ' .. p, ['type'] = k },
      ins = { taintedLua, v(p), 'tools/gentest.lua' },
      outs_implicit = 'addon/' .. p .. '/WowlessData/' .. k .. '.lua',
      rule = 'mkaddon',
    })
  end
end

local runouts = {}
for _, p in ipairs(productList) do
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
