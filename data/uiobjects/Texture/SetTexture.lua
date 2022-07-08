return (function(self, tex)
  local ud = u(self)
  ud.colorTextureR = nil
  ud.colorTextureG = nil
  ud.colorTextureB = nil
  ud.colorTextureA = nil
  ud.texture = tonumber(tex) or tostring(tex)
end)(...)
