local addonGeneratedFiles = (function()
  -- TODO get this from gentest.lua itself
  local t = {
    'builds',
    'cvars',
    'global_wow',
    'global_wow_beta',
    'global_wow_classic',
    'global_wow_classic_beta',
    'global_wow_classic_era',
    'global_wow_classic_era_ptr',
    'global_wow_classic_ptr',
    'global_wowt',
    'globalapis',
    'namespaceapis',
    'uiobjectapis',
  }
  for i, v in ipairs(t) do
    t[i] = 'addon/Wowless/' .. v .. '.lua'
  end
  return table.concat(t, ' ')
end)()

local taintedLua = 'tainted-lua/build/linux/bin/Release/lua5.1'

local wowlessFiles = (function()
  local f = io.popen('find addon data tools wowapi wowless -type f')
  local deps = f:read('*a')
  f:close()
  local t = {}
  for k in deps:gmatch('[^\n]+') do
    if not addonGeneratedFiles:find(k) and k ~= 'wowless/ext.o' and k ~= 'wowless/ext.so' then
      table.insert(t, k)
    end
  end
  return table.concat(t, ' ')
end)()

local rules = {
  mkaddon = taintedLua .. ' tools/gentest.lua',
  mktaintedlua = 'cd tainted-lua && rm -rf build && cmake --preset linux && cmake --build --preset linux',
  mktestout = 'bash -c "set -o pipefail && busted 2>&1 | tee test.out"',
  mkwowlessext = 'luarocks build --no-install',
}

local builds = {
  {
    ins = { taintedLua, wowlessFiles },
    rule = 'mkaddon',
    outs = addonGeneratedFiles,
  },
  {
    ins = (function()
      local f = io.popen('find tainted-lua -type f -not -path \'tainted-lua/build/*\'')
      local deps = f:read('*a')
      f:close()
      return deps:gsub('\n', ' ')
    end)(),
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
end

local f = io.open('build.ninja', 'w')
f:write(table.concat(out, '\n'))
f:write('\n')
f:close()
