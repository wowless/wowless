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
  table.sort(t)
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
  table.sort(t)
  return table.concat(t, ' ')
end)()

local out = {
  'rule mkaddon',
  '  command = ' .. taintedLua .. ' tools/gentest.lua',
  'rule mktaintedlua',
  '  command = cd tainted-lua && rm -rf build && cmake --preset linux && cmake --build --preset linux',
  'rule mktestout',
  '  command = bash -c "set -o pipefail && busted 2>&1 | tee test.out"',
  'rule mkwowlessext',
  '  command = luarocks build --no-install',
  'build | ' .. addonGeneratedFiles .. ': mkaddon | ' .. taintedLua .. ' ' .. wowlessFiles,
  'build | ' .. taintedLua .. ': mktaintedlua | ' .. (function()
    local f = io.popen('find tainted-lua -type f -not -path \'tainted-lua/build/*\'')
    local deps = f:read('*a')
    f:close()
    return deps:gsub('\n', ' ')
  end)(),
  'build | test.out: mktestout | .busted wowless/ext.so '
    .. addonGeneratedFiles
    .. ' '
    .. taintedLua
    .. ' '
    .. wowlessFiles,
  'build | wowless/ext.so wowless/ext.o: mkwowlessext | wowless-scm-0.rockspec wowless/ext.c',
}

local f = io.open('build.ninja', 'w')
f:write(table.concat(out, '\n'))
f:write('\n')
f:close()
