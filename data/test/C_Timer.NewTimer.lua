local T = ...
local assertEquals = T.assertEquals
local cbargs
local function capture(...)
  cbargs = { ... }
end
local t = T.retn(1, T.env.C_Timer.NewTimer(0, capture))
assertEquals('userdata', type(t))
assertEquals(t, t)
local mt = getmetatable(t)
assertEquals('boolean', type(mt))
assertEquals(false, mt)
local readonly = {
  __eq = 'nil',
  __index = 'nil',
  __metatable = 'nil',
  __newindex = 'nil',
  Cancel = 'function',
  Invoke = 'function',
  IsCancelled = 'function',
}
for k, v in pairs(readonly) do
  assertEquals(v, type(t[k]))
  local success, msg = pcall(function()
    t[k] = nil
  end)
  assertEquals(false, success, k)
  assertEquals('Attempted to assign to read-only key ' .. k, msg:sub(-37 - k:len()))
end
assertEquals(nil, t.WowlessStuff)
t.WowlessStuff = 'wowless'
assertEquals('wowless', t.WowlessStuff)
local t2 = T.retn(1, T.env.C_Timer.NewTimer(0, function() end))
assertEquals(false, t == t2)
assertEquals(t.Cancel, t2.Cancel)
assertEquals(t.IsCancelled, t2.IsCancelled)
assertEquals(nil, t2.WowlessStuff)
assertEquals(nil, cbargs)
t:Invoke(42)
assertEquals('table', type(cbargs))
assertEquals(1, #cbargs)
assertEquals(42, cbargs[1])
