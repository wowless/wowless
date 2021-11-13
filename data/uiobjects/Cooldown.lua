return {
  inherits = {'Frame'},
  mixin = {
    Clear = UNIMPLEMENTED,
    Pause = UNIMPLEMENTED,
    SetBlingTexture = function(self, tex)
      u(self).blingTexture = toTexture(self, tex)
    end,
    SetCooldown = UNIMPLEMENTED,
    SetDrawBling = UNIMPLEMENTED,
    SetDrawEdge = UNIMPLEMENTED,
    SetDrawSwipe = UNIMPLEMENTED,
    SetEdgeTexture = function(self, tex)
      u(self).edgeTexture = toTexture(self, tex)
    end,
    SetHideCountdownNumbers = UNIMPLEMENTED,
    SetReverse = UNIMPLEMENTED,
    SetSwipeColor = UNIMPLEMENTED,
    SetSwipeTexture = function(self, tex)
      u(self).swipeTexture = toTexture(self, tex)
    end,
  },
}
