return function(self, r, g, b, a)
  self.vertexColorR = r
  self.vertexColorG = g
  self.vertexColorB = b
  self.alpha = a or self.alpha
end
