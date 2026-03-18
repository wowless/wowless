local T, IsLinuxClient = ...
local v = T.retn(1, IsLinuxClient())
if T.wowless then
  T.assertEquals(T.wowless.platform == 'linux', v)
else
  T.assertEquals('boolean', type(v))
end
