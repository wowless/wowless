local t = ...
local v = t.retn(1, t.env.IsWindowsClient())
if t.wowless then
  t.assertEquals(t.wowless.platform == 'windows', v)
else
  t.assertEquals('boolean', type(v))
end
