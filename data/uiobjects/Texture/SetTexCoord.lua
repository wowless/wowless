return function(self, a1, a2, a3, a4, a5, a6, a7, a8)
  a1 = assert(tonumber(a1))
  a2 = assert(tonumber(a2))
  a3 = assert(tonumber(a3))
  a4 = assert(tonumber(a4))
  if tonumber(a5) then
    a5 = assert(tonumber(a5))
    a6 = assert(tonumber(a6))
    a7 = assert(tonumber(a7))
    a8 = assert(tonumber(a8))
    self.tlx = a1
    self.tly = a2
    self.blx = a3
    self.bly = a4
    self.trx = a5
    self.try = a6
    self.brx = a7
    self.bry = a8
  else
    self.tlx = a1
    self.tly = a3
    self.blx = a1
    self.bly = a4
    self.trx = a2
    self.try = a3
    self.brx = a2
    self.bry = a4
  end
end
