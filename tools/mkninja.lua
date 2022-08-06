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

local apifiles = find('data/api')

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
  globalapis = apifiles,
  namespaceapis = apifiles,
  uiobjectapis = find('data/uiobjects -name \'*.yaml\''),
}

local addonGeneratedFiles = {}
for k in pairs(addonGeneratedTypes) do
  table.insert(addonGeneratedFiles, 'addon/universal/Wowless/' .. k .. '.lua')
end

local taintedLua = 'tainted-lua/build/linux/bin/Release/lua5.1'

local wowlessFiles = (function()
  local skip = {
    ['tools/mkninja.lua'] = true,
    ['wowless/ext.o'] = true,
    ['wowless/ext.so'] = true,
  }
  for _, k in ipairs(addonGeneratedFiles) do
    skip[k] = true
  end
  local t = {}
  for _, k in ipairs(find('addon data tools wowapi wowless')) do
    if not skip[k] then
      table.insert(t, k)
    end
  end
  return t
end)()

local rules = {
  mkaddon = taintedLua .. ' tools/gentest.lua -f $type',
  mktaintedlua = 'cd tainted-lua && rm -rf build && cmake --preset linux && cmake --build --preset linux',
  mktestout = 'bash -c "set -o pipefail && busted 2>&1 | tee test.out"',
  mkwowlessext = 'luarocks build --no-install',
}

local builds = {
  {
    ins = find('tainted-lua -not -path \'tainted-lua/build/*\''),
    rule = 'mktaintedlua',
    outs = taintedLua,
  },
  {
    ins = { '.busted', 'wowless/ext.so', addonGeneratedFiles, taintedLua, wowlessFiles },
    rule = 'mktestout',
    outs = 'test.out',
  },
  {
    ins = { 'wowless-scm-0.rockspec', 'wowless/ext.c' },
    rule = 'mkwowlessext',
    outs = { 'wowless/ext.o', 'wowless/ext.so' },
  },
}

for k, v in pairs(addonGeneratedTypes) do
  table.insert(builds, {
    args = { ['type'] = k },
    ins = { taintedLua, v },
    rule = 'mkaddon',
    outs = 'addon/universal/Wowless/' .. k .. '.lua',
  })
end

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
for _, k in ipairs(rulenames) do
  table.insert(out, 'rule ' .. k)
  table.insert(out, '  command = ' .. rules[k])
end
for _, b in ipairs(builds) do
  local ins = flatten(b.ins)
  local outs = flatten(b.outs)
  table.insert(out, 'build | ' .. outs .. ': ' .. b.rule .. ' | ' .. ins)
  for k, v in pairs(b.args or {}) do
    table.insert(out, '  ' .. k .. ' = ' .. v)
  end
end

local f = io.open('build.ninja', 'w')
f:write(table.concat(out, '\n'))
f:write('\n')
f:close()
