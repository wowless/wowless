return function(self, lw, lh, hw, hh)
  lw = assert(tonumber(lw))
  lh = assert(tonumber(lh))
  hw = tonumber(hw) or 0
  hh = tonumber(hh) or 0
  self.minResizeWidth = lw
  self.minResizeHeight = lh
  self.maxResizeWidth = hw
  self.maxResizeHeight = hh
end
