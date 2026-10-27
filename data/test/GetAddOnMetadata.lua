local T, GetAddOnMetadata = ...
local toccfg = T.data.config.toc
local kv = {
  Notes = 'WoW client unit tests',
  Title = 'Wowless',
}
local knil = {
  'Dependencies',
  'Interface',
  'SavedVariables',
  'WowlessNonsense',
}
if toccfg.filenameonlysubstitution then
  table.insert(knil, 'X-Family')
  table.insert(knil, 'X-GameType')
else
  kv['X-Family'] = toccfg.family
  kv['X-GameType'] = toccfg.gametype
end
local tests = {}
for k, v in pairs(kv) do
  tests[k] = function()
    return T.match(1, v, GetAddOnMetadata(T.addonName, k))
  end
end
for _, k in ipairs(knil) do
  assert(not tests[k])
  tests[k] = function()
    return T.match(1, nil, GetAddOnMetadata(T.addonName, k))
  end
end
return tests
