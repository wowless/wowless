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
    return { 'data/products/' .. p .. '/events.yaml', 'build/events.stamp' }
  end,
  globalapis = function(p)
    return { 'data/products/' .. p .. '/apis.yaml', 'build/api.stamp' }
  end,
  globals = function(p)
    return { 'data/products/' .. p .. '/globals.yaml' }
  end,
  namespaceapis = function(p)
    return { 'data/products/' .. p .. '/apis.yaml', 'build/api.stamp' }
  end,
  product = function()
    return {}
  end,
  uiobjectapis = function()
    return find('data/uiobjects -name \'*.yaml\'')
  end,
}

local addonGeneratedFiles = {}
for _, p in ipairs(productList) do
  local prefix = 'build/products/' .. p .. '/WowlessData/'
  table.insert(addonGeneratedFiles, prefix .. 'WowlessData.toc')
  for k in pairs(perProductAddonGeneratedTypes) do
    table.insert(addonGeneratedFiles, prefix .. k .. '.lua')
  end
end

local elune = 'vendor/elune/build/linux/bin/Release/lua5.1'

local pools = {
  fetch_pool = 1,
  run_pool = 2,
}

local rules = {
  dbdata = {
    command = 'lua tools/sqlite.lua -f $product',
  },
  dblist = {
    command = 'lua tools/dblist.lua $product',
  },
  dbschema = {
    command = 'lua tools/sqlite.lua $product',
  },
  fetch = {
    command = 'lua tools/fetch.lua $product && touch $out',
    pool = 'fetch_pool',
  },
  frame0 = {
    command = elune .. ' wowless.lua -p $product -e5 --frame0 > $out || true',
    pool = 'run_pool',
  },
  mkaddon = {
    command = elune .. ' tools/gentest.lua -f $type -p $product',
  },
  mkelune = {
    command = 'cd vendor/elune && rm -rf build && cmake --preset linux && cmake --build --preset linux',
  },
  mklistfile = {
    command = 'lua tools/listfile.lua',
  },
  mktestout = {
    command = 'bash -c "set -o pipefail && busted 2>&1 | tee $out"',
  },
  mkwowlessext = {
    command = 'luarocks build --no-install',
  },
  prep = {
    command = 'lua tools/prep.lua $product',
  },
  render = {
    command = 'lua tools/render.lua $in',
  },
  run = {
    command = elune .. ' wowless.lua -p $product -e5 > $out || true',
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
    ins = find('vendor/elune -not -path \'vendor/elune/build/*\''),
    outs_implicit = elune,
    rule = 'mkelune',
  },
  {
    ins = find('data/api'),
    outs = 'build/api.stamp',
    rule = 'stamp',
  },
  {
    ins = find('vendor/dbdefs/definitions'),
    outs = 'build/dbdefs.stamp',
    rule = 'stamp',
  },
  {
    ins = find('data/events'),
    outs = 'build/events.stamp',
    rule = 'stamp',
  },
  {
    ins = find('data/impl'),
    outs = 'build/impl.stamp',
    rule = 'stamp',
  },
  {
    ins = find('data/sql'),
    outs = 'build/sql.stamp',
    rule = 'stamp',
  },
  {
    ins = find('data/state'),
    outs = 'build/state.stamp',
    rule = 'stamp',
  },
  {
    ins = find('data/structures'),
    outs = 'build/structures.stamp',
    rule = 'stamp',
  },
  {
    ins = find('data/uiobjects'),
    outs = 'build/uiobjects.stamp',
    rule = 'stamp',
  },
  {
    args = { product = 'structures' },
    ins_implicit = { find('data/structures'), 'tools/prep.lua' },
    outs_implicit = 'build/structures.lua',
    rule = 'prep',
  },
  {
    args = { product = 'xml' },
    ins_implicit = { find('data/xml'), 'tools/prep.lua' },
    outs_implicit = 'build/xml.lua',
    rule = 'prep',
  },
  {
    ins = {
      'build/api.stamp',
      'build/events.stamp',
      'build/state.stamp',
      'build/structures.lua',
      'build/structures.stamp',
      'build/uiobjects.stamp',
      'build/xml.lua',
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
}

for _, p in ipairs(productList) do
  local prefix = 'build/products/' .. p .. '/WowlessData/'
  table.insert(builds, {
    args = { product = p, ['type'] = 'toc' },
    ins = { elune, 'tools/gentest.lua' },
    outs_implicit = prefix .. 'WowlessData.toc',
    rule = 'mkaddon',
  })
  for k, v in pairs(perProductAddonGeneratedTypes) do
    table.insert(builds, {
      args = { product = p, ['type'] = k },
      ins = { elune, v(p), 'tools/gentest.lua' },
      outs_implicit = prefix .. k .. '.lua',
      rule = 'mkaddon',
    })
  end
end

local runtimes = {}
local runouts = {}
for _, p in ipairs(productList) do
  local dblist = 'build/products/' .. p .. '/dblist.lua'
  table.insert(builds, {
    args = {
      product = p,
      restat = 1,
    },
    ins = {
      'build/api.stamp',
      'build/sql.stamp',
      'data/products/' .. p .. '/apis.yaml',
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
      'data/products/' .. p .. '/build.yaml',
      'tools/fetch.lua',
      'vendor/tactkeys/WoW.txt',
    },
    outs = fetchStamp,
    rule = 'fetch',
  })
  local dataStamp = 'build/products/' .. p .. '/data.stamp'
  table.insert(builds, {
    ins = find('data/products/' .. p),
    outs = dataStamp,
    rule = 'stamp',
  })
  local runout = 'out/' .. p .. '/log.txt'
  table.insert(runouts, runout)
  local schemadb = 'build/products/' .. p .. '/schema.db'
  local datadb = 'build/products/' .. p .. '/data.db'
  local datalua = 'build/products/' .. p .. '/data.lua'
  table.insert(runtimes, schemadb)
  table.insert(builds, {
    args = { product = p },
    ins = { 'wowless/ext.so', 'build/wowless.stamp', dataStamp, fetchStamp, elune, datadb, datalua },
    outs = runout,
    rule = 'run',
  })
  table.insert(builds, {
    args = { product = p },
    ins = { 'wowless/ext.so', 'build/wowless.stamp', dataStamp, fetchStamp, elune, datadb, datalua },
    outs = 'out/' .. p .. '/frame0log.txt',
    outs_implicit = { 'out/' .. p .. '/frame0.yaml', 'out/' .. p .. '/frame1.yaml' },
    rule = 'frame0',
  })
  for i = 0, 1 do
    local prefix = 'out/' .. p .. '/frame' .. i
    table.insert(builds, {
      args = { product = p },
      ins = { prefix .. '.yaml' },
      ins_implicit = { 'tools/render.lua', 'wowless/render.lua' },
      outs = { prefix .. '.png' },
      rule = 'render',
    })
  end
  table.insert(builds, {
    args = { product = p },
    ins_implicit = {
      dblist,
      'build/dbdefs.stamp',
      'data/products/' .. p .. '/build.yaml',
      'tools/sqlite.lua',
    },
    outs_implicit = schemadb,
    rule = 'dbschema',
  })
  table.insert(builds, {
    args = { product = p },
    ins_implicit = {
      dblist,
      fetchStamp,
      'build/dbdefs.stamp',
      'data/products/' .. p .. '/build.yaml',
      'tools/sqlite.lua',
    },
    outs_implicit = datadb,
    rule = 'dbdata',
  })
  table.insert(runtimes, datalua)
  table.insert(builds, {
    args = { product = p },
    ins_implicit = {
      'tools/prep.lua',
      'build/api.stamp',
      'build/events.stamp',
      'build/impl.stamp',
      'build/sql.stamp',
      'build/state.stamp',
      'build/structures.stamp',
      'build/uiobjects.stamp',
      dataStamp,
    },
    outs_implicit = datalua,
    rule = 'prep',
  })
  table.insert(builds, {
    args = { product = p },
    ins = { datadb, datalua, 'build/structures.lua', 'build/xml.lua' },
    outs = p,
    rule = 'phony',
  })
end

table.insert(builds, {
  ins = { '.busted', 'wowless/ext.so', 'build/wowless.stamp', addonGeneratedFiles, elune, runtimes },
  outs = 'test.out',
  rule = 'mktestout',
})
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

local f = io.open('build.ninja', 'w')
f:write(table.concat(out, '\n'))
f:write('\n')
f:close()
