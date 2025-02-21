local T = ...
local v = T.retn(1, T.env.IsLinuxClient())
if T.wowless then
  T.assertEquals(T.wowless.platform == 'linux', v)
else
  T.assertEquals('boolean', type(v))
end
