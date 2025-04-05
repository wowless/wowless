local T = ...
local v = T.retn(1, T.env.IsWindowsClient())
if T.wowless then
  T.assertEquals(T.wowless.platform == 'windows', v)
else
  T.assertEquals('boolean', type(v))
end
