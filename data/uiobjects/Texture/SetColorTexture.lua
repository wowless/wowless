return function(self, r, g, b, a)
  self.colorTextureR = assert(tonumber(r))
  self.colorTextureG = assert(tonumber(g))
  self.colorTextureB = assert(tonumber(b))
  self.colorTextureA = tonumber(a) or 1
  self.texture = nil
  self.atlas = nil
end
