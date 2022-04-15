return (function(self, a1, a2, a3, a4, a5, a6, a7, a8)
  local ud = u(self)
  a1 = assert(tonumber(a1))
  a2 = assert(tonumber(a2))
  a3 = assert(tonumber(a3))
  a4 = assert(tonumber(a4))
  if tonumber(a5) then
    a5 = assert(tonumber(a5))
    a6 = assert(tonumber(a6))
    a7 = assert(tonumber(a7))
    a8 = assert(tonumber(a8))
    ud.tlx = a1
    ud.tly = a2
    ud.blx = a3
    ud.bly = a4
    ud.trx = a5
    ud.try = a6
    ud.brx = a7
    ud.bry = a8
  else
    ud.tlx = a1
    ud.tly = a3
    ud.blx = a1
    ud.bly = a4
    ud.trx = a2
    ud.try = a3
    ud.brx = a2
    ud.bry = a4
  end
end)(...)
