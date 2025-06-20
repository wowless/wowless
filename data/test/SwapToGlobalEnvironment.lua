local T = ...
if T.wowless then
  -- This has to be done without a pcall since the implementation uses
  -- stack indices. All we're testing here is that the call works. In a
  -- real client it only works in secure code, but wowless doesn't
  -- support taint yet.
  T.env.SwapToGlobalEnvironment()
else
  local msg = 'cannot modify function environment from a tainted context'
  return T.match(2, false, msg, pcall(T.env.SwapToGlobalEnvironment))
end
