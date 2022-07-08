return (function(self, r, g, b, a)
  local ud = u(self)
  ud.colorTextureR = assert(tonumber(r))
  ud.colorTextureG = assert(tonumber(g))
  ud.colorTextureB = assert(tonumber(b))
  ud.colorTextureA = tonumber(a) or 1
  ud.texture = nil
end)(...)
