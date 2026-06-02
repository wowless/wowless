local T, GetSpecializationInfoByID = ...
local checks = {
  nothing = {},
  number = { 3 },
  string = { 'rofl' },
}
local tests = {}
for k, v in pairs(checks) do
  tests[k] = function()
    return T.match(0, GetSpecializationInfoByID(0, unpack(v)))
  end
end
return tests
