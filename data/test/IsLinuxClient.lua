local t = ...
local v = t.retn(1, t.env.IsLinuxClient())
if t.wowless then
  t.assertEquals(t.wowless.platform == 'linux', v)
else
  t.assertEquals('boolean', type(v))
end
