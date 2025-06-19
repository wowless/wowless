local anchorTypes = {
  ANCHOR_BOTTOM = true,
  ANCHOR_BOTTOMLEFT = true,
  ANCHOR_BOTTOMRIGHT = true,
  ANCHOR_CURSOR = true,
  ANCHOR_LEFT = true,
  ANCHOR_NONE = true,
  ANCHOR_PRESERVE = true,
  ANCHOR_RIGHT = true,
  ANCHOR_TOP = true,
  ANCHOR_TOPLEFT = true,
  ANCHOR_TOPRIGHT = true,
}
return function(self, owner, anchorType)
  self.tooltipOwner = owner
  self.tooltipAnchorType = anchorTypes[anchorType] and anchorType or 'ANCHOR_LEFT'
end
