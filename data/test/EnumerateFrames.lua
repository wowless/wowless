local t = ...
local function collect()
  local tt = {}
  local f = t.env.EnumerateFrames()
  while f ~= nil do
    table.insert(tt, f)
    f = t.env.EnumerateFrames(f)
  end
  return tt
end
local c1 = collect()
local f1 = t.env.CreateFrame('Frame')
local c2 = collect()
local f2 = t.env.CreateFrame('Frame')
local c3 = collect()
return {
  c2 = function()
    t.assertEquals(#c1 + 1, #c2)
  end,
  c3 = function()
    t.assertEquals(#c2 + 1, #c3)
  end,
  f1 = function()
    t.assertEquals(f1, c2[#c2])
  end,
  f2 = function()
    t.assertEquals(f2, c3[#c3])
  end,
}
