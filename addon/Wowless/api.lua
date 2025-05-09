local _, G = ...
G.testsuite.api = function()
  return {
    C_AreaPoiInfo = function()
      return {
        GetAreaPOIInfo = function()
          -- TODO a real test; this just asserts it is callable
          _G.C_AreaPoiInfo.GetAreaPOIInfo(1, 1)
        end,
      }
    end,
    Is64BitClient = function()
      local v = G.retn(1, _G.Is64BitClient())
      assert(v == true or v == false)
    end,
    IsGMClient = function()
      G.check1(false, _G.IsGMClient())
    end,
    loadstring = function()
      return {
        globalenv = function()
          local _G = _G
          setfenv(1, {})
          _G.assertEquals(_G, _G.getfenv(_G.loadstring('')))
        end,
      }
    end,
  }
end
