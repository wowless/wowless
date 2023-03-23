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
local perProductAddonGeneratedTypes = {
  build = function(p)
    return { 'data/products/' .. p .. '/build.yaml' }
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

local elune = 'build/elune/lua/lua5.1'

local pools = {
  fetch_pool = 1,
  run_pool = 2,
}

local rules = {
  dbdata = {
    command = 'lua tools/sqlite.lua -f $product',
    depfile = '$out.d',
    deps = 'gcc',
  },
  dblist = {
    command = 'lua tools/dblist.lua $product',
  },
  dbschema = {
    command = 'lua tools/sqlite.lua $product',
    depfile = '$out.d',
    deps = 'gcc',
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
    command = 'bash -c "set -o pipefail && busted 2>&1 | tee $out"',
  },
  mkwowlessext = {
    command = 'luarocks build --no-install',
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
    ins = { 'tools/addons.yaml', 'tools/mkninja.lua', 'vendor/elune/CMakeLists.txt' },
    outs = 'build.ninja',
    rule = 'mkninja',
  },
  {
    ins = {
      elune,
      'build/flavors.lua',
      'build/wowless.stamp',
      'wowless/ext.so',
    },
    outs = 'build/runtime.stamp',
    rule = 'stamp',
  },
  {
    ins = find('data/sql'),
    outs = 'build/sql.stamp',
    rule = 'stamp',
  },
  {
    ins = {
      (function()
        local skip = {
          ['tools/mkninja.lua'] = true,
          ['wowless/ext.o'] = true,
          ['wowless/ext.so'] = true,
        }
        for _, k in ipairs(addonGeneratedFiles) do
          skip[k] = true
        end
        local globaldirs = {
          'addon',
          'data/schemas',
          'spec',
          'tools',
          'wowapi',
          'wowless',
        }
        local t = {}
        for _, k in ipairs(find(table.concat(globaldirs, ' '))) do
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
    ins = { 'wowless-scm-0.rockspec', 'wowless/ext.c' },
    outs_implicit = { 'wowless/ext.o', 'wowless/ext.so' },
    rule = 'mkwowlessext',
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
  {
    ins = 'data/flavors.yaml',
    outs = 'build/flavors.lua',
    rule = 'yaml2lua',
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
    ins = {
      'build/sql.stamp',
      'data/products/' .. p .. '/apis.yaml',
      'data/impl.yaml',
      'tools/dblist.lua',
      'tools/util.lua',
    },
    outs = dblist,
    rule = 'dblist',
  })
  local fetchStamp = 'build/products/' .. p .. '/fetch.stamp'
  table.insert(builds, {
    args = { product = p },
    ins = {
      dblist,
      'build/listfile.lua',
      'build/tactkeys.lua',
      'data/products/' .. p .. '/build.yaml',
      'tools/fetch.lua',
    },
    outs = fetchStamp,
    rule = 'fetch',
  })
  local runout = 'out/' .. p .. '/log.txt'
  table.insert(runouts, runout)
  local schemadb = 'build/products/' .. p .. '/schema.db'
  local datadb = 'build/products/' .. p .. '/data.db'
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
      dblist,
      'data/products/' .. p .. '/build.yaml',
      'tools/sqlite.lua',
    },
    outs = schemadb,
    rule = 'dbschema',
  })
  table.insert(builds, {
    args = { product = p },
    ins_implicit = {
      dblist,
      fetchStamp,
      'data/products/' .. p .. '/build.yaml',
      'tools/sqlite.lua',
    },
    outs = datadb,
    rule = 'dbdata',
  })
  table.insert(runtimes, datalua)
  table.insert(builds, {
    args = { product = p },
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

table.insert(builds, {
  ins = {
    '.busted',
    'build/runtime.stamp',
    addonGeneratedFiles,
    runtimes,
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
table.insert(out, 'subninja build/elune/build.ninja')

local f = io.open('build.ninja', 'w')
f:write(table.concat(out, '\n'))
f:write('\n')
f:close()

os.execute([[
  cmake \
  -S vendor/elune \
  -B build/elune \
  -G Ninja \
  -DCMAKE_C_FLAGS="-DNDEBUG -D_GNU_SOURCE -O3 -flto" \
  -DCMAKE_NINJA_OUTPUT_PATH_PREFIX=build/elune/ \
  > /dev/null \
]])
