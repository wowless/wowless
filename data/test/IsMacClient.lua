local T = ...
local v = T.retn(1, T.env.IsMacClient())
if T.wowless then
  T.assertEquals(T.wowless.platform == 'mac', v)
else
  T.assertEquals('boolean', type(v))
end
