-- TODO deduplicate with wowless.util
local productList = {
  'wow',
  'wow_classic',
  'wow_classic_era',
  'wow_classic_era_ptr',
  'wow_classic_ptr',
  'wowt',
}

-- TODO get this from gentest.lua
local perProductAddonGeneratedTypes = {
  build = function(p)
    return { 'data/products/' .. p .. '/build.yaml' }
  end,
  config = function(p)
    return { 'data/products/' .. p .. '/config.yaml' }
  end,
  cvars = function(p)
    return { 'data/products/' .. p .. '/cvars.yaml' }
  end,
  events = function(p)
    return { 'data/products/' .. p .. '/events.yaml' }
  end,
  globalapis = function(p)
    return { 'data/products/' .. p .. '/apis.yaml' }
  end,
  globals = function(p)
    return { 'data/products/' .. p .. '/globals.yaml' }
  end,
  namespaceapis = function(p)
    return { 'data/products/' .. p .. '/apis.yaml' }
  end,
  product = function()
    return {}
  end,
  uiobjectapis = function(p)
    return { 'data/products/' .. p .. '/uiobjects.yaml' }
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

local elune = 'build/cmake/wowless'

local pools = {
  fetch_pool = 1,
  run_pool = 2,
}

local rules = {
  dbdata = {
    command = 'lua tools/sqlite.lua -f $product',
  },
  dbdefs = {
    command = 'lua tools/dbdefs.lua $product',
    depfile = '$out.d',
    deps = 'gcc',
  },
  dblist = {
    command = 'lua tools/dblist.lua $product',
    depfile = '$out.d',
    deps = 'gcc',
  },
  dbschema = {
    command = 'lua tools/sqlite.lua $product',
  },
  downloadrelease = {
    command = 'sh bin/downloadaddon.sh $owner $repo $tag $out',
  },
  fetch = {
    command = 'lua tools/fetch.lua $product && touch $out',
    pool = 'fetch_pool',
  },
  frame0 = {
    command = elune .. ' wowless.lua -p $product --frame0 > /dev/null',
    pool = 'run_pool',
  },
  mkaddon = {
    command = 'lua tools/gentest.lua -f $type -p $product',
  },
  mklistfile = {
    command = 'lua tools/listfile.lua',
  },
  mkninja = {
    command = 'lua tools/mkninja.lua',
  },
  mktactkeys = {
    command = 'lua tools/tactkeys.lua',
  },
  mktestout = {
    command = 'bash -c "set -o pipefail && ' .. elune .. ' tools/runtests.lua $in 2>&1 | tee $out"',
  },
  prep = {
    command = 'lua tools/prep.lua $product',
    depfile = '$out.d',
    deps = 'gcc',
  },
  render = {
    command = 'lua tools/render.lua $in',
    pool = 'fetch_pool',
  },
  run = {
    command = elune .. ' wowless.lua -p $product -e5 -a addon/Wowless -a build/products/$product/WowlessData > $out',
    pool = 'run_pool',
  },
  runaddon = {
    command = elune .. ' wowless.lua -p $product -e5 -a extracts/addons/$addon > $out',
    pool = 'run_pool',
  },
  stamp = {
    command = 'touch $out',
  },
  yaml2lua = {
    command = 'lua tools/yaml2lua.lua $in > $out',
  },
}

local builds = {
  {
    ins = { 'test.out', 'outs', 'pngs', 'addonouts' },
    outs = 'all',
    rule = 'phony',
  },
  {
    ins = addonGeneratedFiles,
    outs = 'addon',
    rule = 'phony',
  },
  {
    ins = 'build/runtime.stamp',
    outs = 'runtime',
    rule = 'phony',
  },
  {
    ins = {
      'CMakeLists.txt',
      'tools/addons.yaml',
      'tools/mkninja.lua',
      'wowapi/yaml.lua',
    },
    outs = 'build.ninja',
    rule = 'mkninja',
  },
  {
    ins = {
      'build/cmake/wowless',
      'build/data/flavors.lua',
      'build/wowless.stamp',
    },
    outs = 'build/runtime.stamp',
    rule = 'stamp',
  },
  {
    -- Someday this shouldn't need to be explicit.
    -- However, today is not that day.
    ins = {
      'addon/Wowless/api.lua',
      'addon/Wowless/evenmoreintrinsic.xml',
      'addon/Wowless/framework.lua',
      'addon/Wowless/generated.lua',
      'addon/Wowless/init.lua',
      'addon/Wowless/test.lua',
      'addon/Wowless/test.xml',
      'addon/Wowless/util.lua',
      'addon/Wowless/Wowless.toc',
      'addon/WowlessTracker/tracker.lua',
      'addon/WowlessTracker/WowlessTracker.toc',
      'data/schemas/addons.yaml',
      'data/schemas/any.yaml',
      'data/schemas/apis.yaml',
      'data/schemas/build.yaml',
      'data/schemas/config.yaml',
      'data/schemas/cvars.yaml',
      'data/schemas/docs.yaml',
      'data/schemas/events.yaml',
      'data/schemas/flavors.yaml',
      'data/schemas/globals.yaml',
      'data/schemas/impl.yaml',
      'data/schemas/schema.yaml',
      'data/schemas/schematype.yaml',
      'data/schemas/state.yaml',
      'data/schemas/structures.yaml',
      'data/schemas/type.yaml',
      'data/schemas/uiobjectimpl.yaml',
      'data/schemas/uiobjects.yaml',
      'data/schemas/xml.yaml',
      'tools/addons.yaml',
      'tools/bump.lua',
      'tools/bumpaddons.lua',
      'tools/dbdefs.lua',
      'tools/dblist.lua',
      'tools/docs.lua',
      'tools/errsv.lua',
      'tools/fetch.lua',
      'tools/gentest.lua',
      'tools/listfile.lua',
      'tools/prep.lua',
      'tools/proto.lua',
      'tools/render.lua',
      'tools/rewrite.lua',
      'tools/sqlite.lua',
      'tools/tactkeys.lua',
      'tools/util.lua',
      'tools/yaml2lua.lua',
      'tools/yamlfmt.lua',
      'wowapi/data.lua',
      'wowapi/loader.lua',
      'wowapi/schema.lua',
      'wowapi/uiobjects.lua',
      'wowapi/yaml.lua',
      'wowless/api.lua',
      'wowless/blp.lua',
      'wowless/env.lua',
      'wowless/ext.c',
      'wowless/hlist.lua',
      'wowless/loader.lua',
      'wowless/png.lua',
      'wowless/render.lua',
      'wowless/runner.lua',
      'wowless/util.lua',
      'wowless/xml.lua',
      'wowless.lua',
    },
    outs = 'build/wowless.stamp',
    rule = 'stamp',
  },
  {
    args = {
      restat = 1,
    },
    ins_implicit = {
      'tools/listfile.lua',
      'tools/util.lua',
      'vendor/listfile/community-listfile.csv',
    },
    outs_implicit = 'build/listfile.lua',
    rule = 'mklistfile',
  },
  {
    args = {
      restat = 1,
    },
    ins_implicit = {
      'tools/tactkeys.lua',
      'tools/util.lua',
      'vendor/tactkeys/WoW.txt',
    },
    outs_implicit = 'build/tactkeys.lua',
    rule = 'mktactkeys',
  },
}

for _, p in ipairs(productList) do
  local prefix = 'build/products/' .. p .. '/WowlessData/'
  table.insert(builds, {
    args = { product = p, ['type'] = 'toc' },
    ins = 'tools/gentest.lua',
    outs_implicit = prefix .. 'WowlessData.toc',
    rule = 'mkaddon',
  })
  for k, v in pairs(perProductAddonGeneratedTypes) do
    table.insert(builds, {
      args = { product = p, ['type'] = k },
      ins = { v(p), 'tools/gentest.lua' },
      outs_implicit = prefix .. k .. '.lua',
      rule = 'mkaddon',
    })
  end
end

local runtimes = {}
local runouts = {}
local pngs = {}
local addonouts = {}
for _, p in ipairs(productList) do
  local dblist = 'build/products/' .. p .. '/dblist.lua'
  table.insert(builds, {
    args = {
      product = p,
      restat = 1,
    },
    ins_implicit = {
      'tools/dblist.lua',
      'tools/util.lua',
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
      'data/products/' .. p .. '/build.yaml',
      'tools/dbdefs.lua',
      'tools/util.lua',
    },
    outs = dbdefs,
    rule = 'dbdefs',
  })
  local fetchStamp = 'build/products/' .. p .. '/fetch.stamp'
  table.insert(builds, {
    args = { product = p },
    ins = {
      dblist,
      'build/data/products/' .. p .. '/build.lua',
      'build/listfile.lua',
      'build/tactkeys.lua',
      'tools/fetch.lua',
    },
    outs = fetchStamp,
    rule = 'fetch',
  })
  local runout = 'out/' .. p .. '/log.txt'
  table.insert(runouts, runout)
  local schemadb = 'build/products/' .. p .. '/schema.sqlite3'
  local datadb = 'build/products/' .. p .. '/data.sqlite3'
  local datalua = 'build/products/' .. p .. '/data.lua'
  table.insert(runtimes, schemadb)
  local rundeps = {
    'build/runtime.stamp',
    datadb,
    datalua,
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
        'build/tactkeys.lua',
        'data/products/' .. p .. '/build.yaml',
        'tools/render.lua',
        'wowless/render.lua',
      },
      outs = { prefix .. '.png' },
      rule = 'render',
    })
  end
  table.insert(builds, {
    args = { product = p },
    ins_implicit = {
      dbdefs,
      'tools/sqlite.lua',
    },
    outs = schemadb,
    rule = 'dbschema',
  })
  table.insert(builds, {
    args = { product = p },
    ins_implicit = {
      dbdefs,
      fetchStamp,
      'tools/sqlite.lua',
    },
    outs = datadb,
    rule = 'dbdata',
  })
  table.insert(runtimes, datalua)
  table.insert(builds, {
    args = {
      product = p,
      restat = 1,
    },
    ins_implicit = {
      'tools/prep.lua',
      'tools/util.lua',
    },
    outs = datalua,
    rule = 'prep',
  })
  table.insert(builds, {
    args = { product = p },
    ins = { datadb, datalua },
    outs = p,
    rule = 'phony',
  })
  local b = require('wowapi.yaml').parseFile('data/products/' .. p .. '/build.yaml')
  for k, v in pairs(require('wowapi.yaml').parseFile('tools/addons.yaml')) do
    local found = v.flavors == nil
    if not found then
      for _, f in ipairs(v.flavors) do
        found = found or f == b.flavor
      end
    end
    if found then
      local addonout = 'out/' .. p .. '/addons/' .. k .. '.txt'
      table.insert(addonouts, addonout)
      table.insert(builds, {
        args = {
          addon = k,
          product = p,
        },
        ins = { rundeps, 'build/addonreleases/' .. k .. '.zip' },
        outs = addonout,
        rule = 'runaddon',
      })
    end
  end
end

for k, v in pairs(require('wowapi.yaml').parseFile('tools/addons.yaml')) do
  table.insert(builds, {
    args = {
      owner = v.owner,
      repo = v.repo,
      tag = v.tag,
    },
    ins_implicit = {
      'bin/downloadaddon.sh',
      'tools/addons.yaml',
    },
    outs = 'build/addonreleases/' .. k .. '.zip',
    rule = 'downloadrelease',
  })
end

local yamls = {
  'data/flavors.yaml',
  'data/impl.yaml',
  'data/products/wow/apis.yaml',
  'data/products/wow/build.yaml',
  'data/products/wow/config.yaml',
  'data/products/wow/cvars.yaml',
  'data/products/wow/events.yaml',
  'data/products/wow/globals.yaml',
  'data/products/wow/structures.yaml',
  'data/products/wow/uiobjects.yaml',
  'data/products/wow/xml.yaml',
  'data/products/wow_classic/apis.yaml',
  'data/products/wow_classic/build.yaml',
  'data/products/wow_classic/config.yaml',
  'data/products/wow_classic/cvars.yaml',
  'data/products/wow_classic/events.yaml',
  'data/products/wow_classic/globals.yaml',
  'data/products/wow_classic/structures.yaml',
  'data/products/wow_classic/uiobjects.yaml',
  'data/products/wow_classic/xml.yaml',
  'data/products/wow_classic_era/apis.yaml',
  'data/products/wow_classic_era/build.yaml',
  'data/products/wow_classic_era/config.yaml',
  'data/products/wow_classic_era/cvars.yaml',
  'data/products/wow_classic_era/events.yaml',
  'data/products/wow_classic_era/globals.yaml',
  'data/products/wow_classic_era/structures.yaml',
  'data/products/wow_classic_era/uiobjects.yaml',
  'data/products/wow_classic_era/xml.yaml',
  'data/products/wow_classic_era_ptr/apis.yaml',
  'data/products/wow_classic_era_ptr/build.yaml',
  'data/products/wow_classic_era_ptr/config.yaml',
  'data/products/wow_classic_era_ptr/cvars.yaml',
  'data/products/wow_classic_era_ptr/events.yaml',
  'data/products/wow_classic_era_ptr/globals.yaml',
  'data/products/wow_classic_era_ptr/structures.yaml',
  'data/products/wow_classic_era_ptr/uiobjects.yaml',
  'data/products/wow_classic_era_ptr/xml.yaml',
  'data/products/wow_classic_ptr/apis.yaml',
  'data/products/wow_classic_ptr/build.yaml',
  'data/products/wow_classic_ptr/config.yaml',
  'data/products/wow_classic_ptr/cvars.yaml',
  'data/products/wow_classic_ptr/events.yaml',
  'data/products/wow_classic_ptr/globals.yaml',
  'data/products/wow_classic_ptr/structures.yaml',
  'data/products/wow_classic_ptr/uiobjects.yaml',
  'data/products/wow_classic_ptr/xml.yaml',
  'data/products/wowt/apis.yaml',
  'data/products/wowt/build.yaml',
  'data/products/wowt/config.yaml',
  'data/products/wowt/cvars.yaml',
  'data/products/wowt/events.yaml',
  'data/products/wowt/globals.yaml',
  'data/products/wowt/structures.yaml',
  'data/products/wowt/uiobjects.yaml',
  'data/products/wowt/xml.yaml',
  'data/schemas/addons.yaml',
  'data/schemas/any.yaml',
  'data/schemas/apis.yaml',
  'data/schemas/build.yaml',
  'data/schemas/config.yaml',
  'data/schemas/cvars.yaml',
  'data/schemas/docs.yaml',
  'data/schemas/events.yaml',
  'data/schemas/flavors.yaml',
  'data/schemas/globals.yaml',
  'data/schemas/impl.yaml',
  'data/schemas/schema.yaml',
  'data/schemas/schematype.yaml',
  'data/schemas/state.yaml',
  'data/schemas/structures.yaml',
  'data/schemas/type.yaml',
  'data/schemas/uiobjectimpl.yaml',
  'data/schemas/uiobjects.yaml',
  'data/schemas/xml.yaml',
  'data/state/Addons.yaml',
  'data/state/Bindings.yaml',
  'data/state/CVars.yaml',
  'data/state/Calendar.yaml',
  'data/state/ModifiedClicks.yaml',
  'data/state/System.yaml',
  'data/state/Talents.yaml',
  'data/state/Time.yaml',
  'data/state/Units.yaml',
  'data/uiobjectimpl.yaml',
}
local yamlluas = {}
for _, yaml in ipairs(yamls) do
  local yamllua = 'build/' .. yaml:sub(1, -5) .. 'lua'
  table.insert(yamlluas, yamllua)
  table.insert(builds, {
    ins = yaml,
    outs = yamllua,
    rule = 'yaml2lua',
  })
end

table.insert(builds, {
  ins = {
    'spec/addon/framework_spec.lua',
    'spec/addon/util_spec.lua',
    'spec/data/apis_spec.lua',
    'spec/data/config_spec.lua',
    'spec/data/impl_spec.lua',
    'spec/data/impl/C_DateAndTime.AdjustTimeByDays_spec.lua',
    'spec/data/impl/C_DateAndTime.AdjustTimeByMinutes_spec.lua',
    'spec/data/impl/C_DateAndTime.CompareCalendarTime_spec.lua',
    'spec/data/impl/EnumerateFrames_spec.lua',
    'spec/data/impl/hooksecurefunc_spec.lua',
    'spec/data/structures_spec.lua',
    'spec/data/uiobjectimpl_spec.lua',
    'spec/data/uiobjects_spec.lua',
    'spec/data/yaml_spec.lua',
    'spec/elune_spec.lua',
    'spec/wowapi/schema_spec.lua',
    'spec/wowapi/yaml_spec.lua',
    'spec/wowless/addon_spec.lua',
    'spec/wowless/blp_spec.lua',
    'spec/wowless/frame_spec.lua',
    'spec/wowless/hlist_spec.lua',
    'spec/wowless/png_spec.lua',
    'spec/wowless/util_spec.lua',
  },
  ins_implicit = {
    'build/runtime.stamp',
    'spec/wowless/green.png',
    'spec/wowless/temp.blp',
    'spec/wowless/temp.png',
    'tools/runtests.lua',
    addonGeneratedFiles,
    runtimes,
    yamlluas,
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
table.insert(builds, {
  ins = addonouts,
  outs = 'addonouts',
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

local sorted = require('pl.tablex').sort

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
]])
