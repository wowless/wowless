local productList = {
  'wow',
  'wow_classic',
  'wow_classic_beta',
  'wow_classic_era',
  'wow_classic_era_ptr',
  'wow_classic_ptr',
  'wowt',
  'wowxptr',
}

local pools = {
  fetch_pool = 1,
  run_pool = 2,
}

local rules = {
  frame0 = {
    command = 'build/cmake/wowless run -p $product --frame0 > /dev/null',
    pool = 'run_pool',
  },
  mkninja = {
    command = 'lua tools/mkninja.lua',
    pool = 'console',
  },
  mktestout = {
    command = 'bash -c "set -o pipefail && build/cmake/runtests $in 2>&1 | tee $out"',
  },
  render = {
    command = 'build/cmake/render $in',
    pool = 'fetch_pool',
  },
  run = {
    command = table.concat({
      'build/cmake/wowless run ',
      '-p $product ',
      '-e5 ',
      '-a addon/Wowless ',
      '-a build/cmake/products/$product/WowlessData ',
      '> $out',
    }),
    pool = 'run_pool',
  },
}

local addonFiles = {
  'addon/Wowless/evenmoreintrinsic.xml',
  'addon/Wowless/framework.lua',
  'addon/Wowless/generated.lua',
  'addon/Wowless/init.lua',
  'addon/Wowless/statemachine.lua',
  'addon/Wowless/test.lua',
  'addon/Wowless/test.xml',
  'addon/Wowless/uiobjects.lua',
  'addon/Wowless/util.lua',
  'addon/Wowless/Wowless.toc',
}

local builds = {
  {
    ins = { 'test.out', 'outs', 'pngs' },
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

local schemadbs = {}
local runouts = {}
local pngs = {}
for _, p in ipairs(productList) do
  local runout = 'out/' .. p .. '/log.txt'
  table.insert(runouts, runout)
  local schemadb = 'build/cmake/' .. p .. '_schema.sqlite3'
  local datadb = 'build/cmake/' .. p .. '_data.sqlite3'
  table.insert(schemadbs, schemadb)
  local rundeps = {
    'build/cmake/wowless',
    addonFiles,
    datadb,
  }
  table.insert(builds, {
    args = { product = p },
    ins = { 'build/cmake/products/' .. p .. '/addon.txt', rundeps },
    outs = runout,
    rule = 'run',
  })
  table.insert(builds, {
    args = { product = p },
    ins = rundeps,
    outs_implicit = { 'out/' .. p .. '/frame0.yaml', 'out/' .. p .. '/frame1.yaml' },
    rule = 'frame0',
  })
  for i = 0, 1 do
    local prefix = 'out/' .. p .. '/frame' .. i
    table.insert(pngs, prefix .. '.png')
    table.insert(builds, {
      args = { product = p },
      ins = { prefix .. '.yaml' },
      ins_implicit = {
        'build/cmake/render',
        'data/products/' .. p .. '/build.yaml',
      },
      outs = { prefix .. '.png' },
      rule = 'render',
    })
  end
  table.insert(builds, {
    args = { product = p },
    ins = { datadb },
    outs = p,
    rule = 'phony',
  })
end

table.insert(builds, {
  ins = {
    'spec/addon/framework_spec.lua',
    'spec/addon/statemachine_spec.lua',
    'spec/addon/util_spec.lua',
    'spec/data/apis_spec.lua',
    'spec/data/config_spec.lua',
    'spec/data/docs_spec.lua',
    'spec/data/events_spec.lua',
    'spec/data/families_spec.lua',
    'spec/data/gametypes_spec.lua',
    'spec/data/globals_spec.lua',
    'spec/data/impl_spec.lua',
    'spec/data/sql_spec.lua',
    'spec/data/structures_spec.lua',
    'spec/data/test_spec.lua',
    'spec/data/uiobjectimpl_spec.lua',
    'spec/data/uiobjects_spec.lua',
    'spec/data/yaml_spec.lua',
    'spec/elune_spec.lua',
    'spec/tools/tedit_spec.lua',
    'spec/wowapi/schema_spec.lua',
    'spec/wowapi/yaml_spec.lua',
    'spec/wowless/addon_spec.lua',
    'spec/wowless/blp_spec.lua',
    'spec/wowless/bubblewrap_spec.lua',
    'spec/wowless/hlist_spec.lua',
    'spec/wowless/modules/funcheck_spec.lua',
    'spec/wowless/modules/typecheck_spec.lua',
    'spec/wowless/png_spec.lua',
    'spec/wowless/sqlite_spec.lua',
    'spec/wowless/toc_spec.lua',
    'spec/wowless/util_spec.lua',
  },
  ins_implicit = {
    'build/cmake/addons.txt',
    'build/cmake/runtests',
    'spec/wowless/green.png',
    'spec/wowless/temp.blp',
    'spec/wowless/temp.png',
    addonFiles,
    schemadbs,
  },
  outs = 'test.out',
  rule = 'mktestout',
})
table.insert(builds, {
  ins = runouts,
  outs = 'outs',
  rule = 'phony',
})
table.insert(builds, {
  ins = pngs,
  outs = 'pngs',
  rule = 'phony',
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
for p, n in pairs(pools) do
  table.insert(out, 'pool ' .. p)
  table.insert(out, '  depth = ' .. n)
end
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
table.insert(out, 'default test.out')
table.insert(out, 'subninja build/cmake/build.ninja')

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
