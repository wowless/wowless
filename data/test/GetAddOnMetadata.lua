local T, GetAddOnMetadata = ...
local kv = {
  Notes = 'WoW client unit tests',
  Title = 'Wowless',
}
local knil = {
  Dependencies = false,
  Interface = true,
  SavedVariables = false,
  WowlessNonsense = true,
}
local tests = {}
for k, v in pairs(kv) do
  tests[k] = function()
    return T.match(1, v, GetAddOnMetadata(T.addonName, k))
  end
end
for k, v in pairs(knil) do
  assert(not tests[k])
  tests[k] = function()
    if v or not T.wowless then
      return T.match(1, nil, GetAddOnMetadata(T.addonName, k))
    else
      assert(T.retn(1, GetAddOnMetadata(T.addonName, k) ~= nil)) -- issue #581
    end
  end
end
return tests
