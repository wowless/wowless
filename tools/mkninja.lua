local productList = {
  'wow',
  'wow_classic',
  'wow_classic_era',
  'wow_classic_era_ptr',
  'wow_classic_ptr',
  'wowt',
  'wowxptr',
}

-- TODO get this from gentest.lua
local perProductAddonGeneratedTypes = {
  build = function(p)
    return { 'build/cmake/runtime/products/' .. p .. '/build.lua' }
  end,
  config = function(p)
    return { 'build/cmake/runtime/products/' .. p .. '/config.lua' }
  end,
  cvars = function(p)
    return { 'build/cmake/runtime/products/' .. p .. '/cvars.lua' }
  end,
  events = function()
    local t = {}
    for _, p in ipairs(productList) do
      table.insert(t, 'build/cmake/runtime/products/' .. p .. '/events.lua')
    end
    return t
  end,
  globalapis = function(p)
    return {
      'build/cmake/runtime/products/' .. p .. '/apis.lua',
      'build/cmake/runtime/products/' .. p .. '/config.lua',
    }
  end,
  globals = function(p)
    return { 'build/cmake/runtime/products/' .. p .. '/globals.lua' }
  end,
  impltests = function(p)
    return {
      'build/cmake/runtime/products/' .. p .. '/apis.lua',
      'build/cmake/runtime/test.lua',
    }
  end,
  namespaceapis = function(p)
    return {
      'build/cmake/runtime/products/' .. p .. '/apis.lua',
      'build/cmake/runtime/products/' .. p .. '/config.lua',
    }
  end,
  product = function()
    return {}
  end,
  uiobjectapis = function()
    local t = {}
    for _, p in ipairs(productList) do
      table.insert(t, 'build/cmake/runtime/products/' .. p .. '/uiobjects.lua')
    end
    return t
  end,
}

local perProductAddonGeneratedFiles = {}
local addonGeneratedFiles = {}
for _, p in ipairs(productList) do
  local pp = {}
  local prefix = 'build/products/' .. p .. '/WowlessData/'
  table.insert(pp, prefix .. 'WowlessData.toc')
  for k in pairs(perProductAddonGeneratedTypes) do
    table.insert(pp, prefix .. k .. '.lua')
  end
  for _, file in ipairs(pp) do
    table.insert(addonGeneratedFiles, file)
  end
  perProductAddonGeneratedFiles[p] = pp
end

local pools = {
  fetch_pool = 1,
  run_pool = 2,
}

local rules = {
  dbdata = {
    command = 'build/cmake/sqlite -f $product',
  },
  dbdefs = {
    command = 'build/cmake/dbdefs $product',
    depfile = '$out.d',
    deps = 'gcc',
  },
  dblist = {
    command = 'build/cmake/dblist $product',
    depfile = '$out.d',
    deps = 'gcc',
  },
  dbschema = {
    command = 'build/cmake/sqlite $product',
  },
  fetch = {
    command = 'build/cmake/fetch $product && touch $out',
    pool = 'fetch_pool',
  },
  frame0 = {
    command = 'build/cmake/wowless run -p $product --frame0 > /dev/null',
    pool = 'run_pool',
  },
  mkaddon = {
    command = 'build/cmake/gentest -f $type -p $product',
    depfile = '$out.d',
    deps = 'gcc',
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
    command = 'build/cmake/wowless run -p $product -e5 -a addon/Wowless -a build/products/$product/WowlessData > $out',
    pool = 'run_pool',
  },
}

local addonFiles = {
  'addon/Wowless/api.lua',
  'addon/Wowless/evenmoreintrinsic.xml',
  'addon/Wowless/framework.lua',
  'addon/Wowless/generated.lua',
  'addon/Wowless/init.lua',
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
    ins = addonGeneratedFiles,
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

for _, p in ipairs(productList) do
  local prefix = 'build/products/' .. p .. '/WowlessData/'
  table.insert(builds, {
    args = { product = p, ['type'] = 'toc' },
    ins = 'build/cmake/gentest',
    ins_implicit = 'build/cmake/runtime/products.lua',
    outs_implicit = prefix .. 'WowlessData.toc',
    rule = 'mkaddon',
  })
  for k, v in pairs(perProductAddonGeneratedTypes) do
    table.insert(builds, {
      args = { product = p, ['type'] = k },
      ins = { v(p), 'build/cmake/gentest' },
      ins_implicit = 'build/cmake/runtime/products.lua',
      outs = prefix .. k .. '.lua',
      rule = 'mkaddon',
    })
  end
end

local schemadbs = {}
local runouts = {}
local pngs = {}
for _, p in ipairs(productList) do
  local dblist = 'build/products/' .. p .. '/dblist.lua'
  table.insert(builds, {
    args = {
      product = p,
      restat = 1,
    },
    ins_implicit = {
      'build/cmake/dblist',
      'build/cmake/runtime/impl.lua',
      'build/cmake/runtime/products/' .. p .. '/apis.lua',
    },
    outs = dblist,
    rule = 'dblist',
  })
  local dbdefs = 'build/products/' .. p .. '/dbdefs.lua'
  table.insert(builds, {
    args = {
      product = p,
      restat = 1,
    },
    ins_implicit = {
      dblist,
      'build/cmake/dbdefs',
      'build/cmake/runtime/products/' .. p .. '/build.lua',
    },
    outs = dbdefs,
    rule = 'dbdefs',
  })
  local fetchStamp = 'build/products/' .. p .. '/fetch.stamp'
  table.insert(builds, {
    args = { product = p },
    ins = {
      dblist,
      'build/cmake/fetch',
      'build/cmake/runtime/flavors.lua',
      'build/cmake/runtime/products/' .. p .. '/build.lua',
    },
    outs = fetchStamp,
    rule = 'fetch',
  })
  local runout = 'out/' .. p .. '/log.txt'
  table.insert(runouts, runout)
  local schemadb = 'build/products/' .. p .. '/schema.sqlite3'
  local datadb = 'build/products/' .. p .. '/data.sqlite3'
  table.insert(schemadbs, schemadb)
  local rundeps = {
    'build/cmake/wowless',
    addonFiles,
    datadb,
  }
  table.insert(builds, {
    args = { product = p },
    ins = { perProductAddonGeneratedFiles[p], rundeps },
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
    ins_implicit = {
      dbdefs,
      'build/cmake/sqlite',
    },
    outs = schemadb,
    rule = 'dbschema',
  })
  table.insert(builds, {
    args = { product = p },
    ins_implicit = {
      dbdefs,
      fetchStamp,
      'build/cmake/sqlite',
    },
    outs = datadb,
    rule = 'dbdata',
  })
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
    'spec/addon/util_spec.lua',
    'spec/data/apis_spec.lua',
    'spec/data/config_spec.lua',
    'spec/data/docs_spec.lua',
    'spec/data/events_spec.lua',
    'spec/data/flavors_spec.lua',
    'spec/data/globals_spec.lua',
    'spec/data/impl_spec.lua',
    'spec/data/structures_spec.lua',
    'spec/data/test_spec.lua',
    'spec/data/uiobjectimpl_spec.lua',
    'spec/data/uiobjects_spec.lua',
    'spec/data/yaml_spec.lua',
    'spec/elune_spec.lua',
    'spec/wowapi/schema_spec.lua',
    'spec/wowapi/yaml_spec.lua',
    'spec/wowless/addon_spec.lua',
    'spec/wowless/blp_spec.lua',
    'spec/wowless/hlist_spec.lua',
    'spec/wowless/png_spec.lua',
    'spec/wowless/toc_spec.lua',
    'spec/wowless/typecheck_spec.lua',
    'spec/wowless/util_spec.lua',
  },
  ins_implicit = {
    'build/cmake/runtests',
    'spec/wowless/green.png',
    'spec/wowless/temp.blp',
    'spec/wowless/temp.png',
    addonFiles,
    addonGeneratedFiles,
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
