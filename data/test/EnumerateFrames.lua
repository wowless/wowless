local T = ...
local function collect()
  local t = {}
  local f = T.env.EnumerateFrames()
  while f ~= nil do
    table.insert(t, f)
    f = T.env.EnumerateFrames(f)
  end
  return t
end
local c1 = collect()
local f1 = T.env.CreateFrame('Frame')
local c2 = collect()
local f2 = T.env.CreateFrame('Frame')
local c3 = collect()
return {
  c2 = function()
    T.assertEquals(#c1 + 1, #c2)
  end,
  c3 = function()
    T.assertEquals(#c2 + 1, #c3)
  end,
  f1 = function()
    T.assertEquals(f1, c2[#c2])
  end,
  f2 = function()
    T.assertEquals(f2, c3[#c3])
  end,
}
