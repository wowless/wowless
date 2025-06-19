return function(self, tex)
  self.colorTextureR = nil
  self.colorTextureG = nil
  self.colorTextureB = nil
  self.colorTextureA = nil
  self.atlas = nil
  self.texture = tonumber(tex) or tostring(tex)
end
