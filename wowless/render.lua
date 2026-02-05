local function kidregions(r)
  return coroutine.wrap(function()
    for kid in r.children:entries() do
      if kid:IsObjectType('layeredregion') then
        coroutine.yield(kid)
      end
    end
  end)
end

local function frames2rects(hframes, product, screenWidth, screenHeight)
  local frames = {}
  for frame in hframes:entries() do
    local regions = {}
    for r in kidregions(frame) do
      local l, b, w, h = r:GetRect()
      if l and r:IsVisible() then
        local content = {
          string = r:IsObjectType('FontString') and r:GetText() or nil,
          texture = (function()
            local t = r:IsObjectType('Texture') and r or nil
            return t
              and (function()
                local drawLayer, drawSubLayer = t:GetDrawLayer()
                return {
                  alpha = t:GetAlpha() * frame:GetEffectiveAlpha(),
                  blendMode = t:GetBlendMode(),
                  color = t.colorTextureR and {
                    alpha = t.colorTextureA,
                    blue = t.colorTextureB,
                    green = t.colorTextureG,
                    red = t.colorTextureR,
                  },
                  coords = (function()
                    local tlx, tly, blx, bly, trx, try, brx, bry = t:GetTexCoord()
                    return {
                      blx = blx,
                      bly = bly,
                      brx = brx,
                      bry = bry,
                      tlx = tlx,
                      tly = tly,
                      trx = trx,
                      try = try,
                    }
                  end)(),
                  drawLayer = drawLayer,
                  drawSubLayer = drawSubLayer,
                  horizTile = t:GetHorizTile(),
                  maskPath = t.maskName,
                  path = t:GetTexture(),
                  scale = t:GetEffectiveScale(),
                  vertexColor = t.vertexColorR and {
                    blue = t.vertexColorB,
                    green = t.vertexColorG,
                    red = t.vertexColorR,
                  },
                  vertTile = t:GetVertTile(),
                }
              end)()
          end)(),
        }
        if next(content) then
          table.insert(regions, {
            content = content,
            name = r:GetDebugName(),
            rect = {
              bottom = b,
              left = l,
              right = l + w,
              top = b + h,
            },
          })
        end
      end
    end
    if next(regions) then
      table.insert(frames, {
        name = frame:GetDebugName(),
        regions = regions,
        strata = frame:GetFrameStrata(),
        strataLevel = frame:GetFrameLevel(),
      })
    end
  end
  return {
    frames = frames,
    product = product,
    screenHeight = screenHeight,
    screenWidth = screenWidth,
  }
end

return {
  frames2rects = frames2rects,
}
