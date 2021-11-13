return {
  inherits = {'LayeredRegion', 'ParentedObject'},
  mixin = {
    AddMaskTexture = UNIMPLEMENTED,
    GetAtlas = UNIMPLEMENTED,
    GetTexCoord = function()
      return 0, 0, 0, 0, 0, 0, 0, 0  -- UNIMPLEMENTED
    end,
    GetTexture = UNIMPLEMENTED,
    GetVertexColor = UNIMPLEMENTED,
    IsDesaturated = UNIMPLEMENTED,
    SetAtlas = UNIMPLEMENTED,
    SetBlendMode = UNIMPLEMENTED,
    SetColorTexture = UNIMPLEMENTED,
    SetDesaturated = UNIMPLEMENTED,
    SetDesaturation = UNIMPLEMENTED,
    SetGradient = UNIMPLEMENTED,
    SetGradientAlpha = UNIMPLEMENTED,
    SetHorizTile = UNIMPLEMENTED,
    SetRotation = UNIMPLEMENTED,
    SetSnapToPixelGrid = UNIMPLEMENTED,
    SetTexCoord = UNIMPLEMENTED,
    SetTexelSnappingBias = UNIMPLEMENTED,
    SetTexture = UNIMPLEMENTED,
    SetVertTile = UNIMPLEMENTED,
  },
}
