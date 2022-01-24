describe('uiobjects', function()
  local fn = require('wowapi.uiobjects')
  it('runs', function()
    local api = {
      frames = {},
      GetDebugName = function() return "" end,
      UserData = function() return {} end,
    }
    local loader = {}
    local t = assert(fn(api, loader))
    for k, v in pairs(t) do
      local success, msg = pcall(function() v.constructor({}) end)
      assert(success, 'failed on ' .. k .. ': ' .. tostring(msg))
    end
  end)
end)
