local t = ...
local v = t.retn(1, t.env.IsMacClient())
if t.wowless then
  t.assertEquals(t.wowless.platform == 'mac', v)
else
  t.assertEquals('boolean', type(v))
end
