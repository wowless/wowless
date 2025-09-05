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
  local tt = require('resty.tsort').new()
  local function addPoints(r)
    for _, pt in ipairs(r.points) do
      local relativeTo = pt[2]
      if relativeTo ~= nil and relativeTo ~= r then
        tt:add(relativeTo, r)
      end
    end
  end
  for frame in hframes:entries() do
    addPoints(frame)
    for r in kidregions(frame) do
      addPoints(r)
    end
  end
  local screen = {
    bottom = 0,
    left = 0,
    right = screenWidth,
    top = screenHeight,
  }
  local rects = {}
  local function p2c(r, i)
    local p, rt, rp, px, py = unpack(r.points[i])
    local pr = rt == nil and screen or assert(rects[rt], 'moo ' .. r:GetDebugName()) -- relies on tsort
    local x = (function()
      if rp == 'TOPLEFT' or rp == 'LEFT' or rp == 'BOTTOMLEFT' then
        return pr.left
      elseif rp == 'TOPRIGHT' or rp == 'RIGHT' or rp == 'BOTTOMRIGHT' then
        return pr.right
      else
        return pr.left and pr.right and (pr.left + pr.right) / 2 or nil
      end
    end)()
    local y = (function()
      if rp == 'TOPLEFT' or rp == 'TOP' or rp == 'TOPRIGHT' then
        return pr.top
      elseif rp == 'BOTTOMLEFT' or rp == 'BOTTOM' or rp == 'BOTTOMRIGHT' then
        return pr.bottom
      else
        return pr.top and pr.bottom and (pr.top + pr.bottom) / 2 or nil
      end
    end)()
    return p, x and x + px, y and y + py
  end
  for _, r in ipairs(assert(tt:sort())) do
    local points = {}
    for i = 1, #r.points do
      local p, x, y = p2c(r, i)
      points[p] = { x = x, y = y }
    end
    local pts = {
      bottom = points.BOTTOMLEFT or points.BOTTOM or points.BOTTOMRIGHT,
      left = points.TOPLEFT or points.LEFT or points.BOTTOMLEFT,
      midx = points.TOP or points.CENTER or points.BOTTOM,
      midy = points.LEFT or points.CENTER or points.RIGHT,
      right = points.TOPRIGHT or points.RIGHT or points.BOTTOMRIGHT,
      top = points.TOPLEFT or points.TOP or points.TOPRIGHT,
    }
    local w, h = r:GetSize()
    rects[r] = {
      bottom = pts.bottom and pts.bottom.y
        or pts.top and pts.top.y and pts.top.y - h
        or pts.midy and pts.midy.y and pts.midy.y - h / 2,
      left = pts.left and pts.left.x
        or pts.right and pts.right.x and pts.right.x - w
        or pts.midx and pts.midx.x and pts.midx.x - w / 2,
      right = pts.right and pts.right.x
        or pts.left and pts.left.x and pts.left.x + w
        or pts.midx and pts.midx.x and pts.midx.x + w / 2,
      top = pts.top and pts.top.y
        or pts.bottom and pts.bottom.y and pts.bottom.y + h
        or pts.midy and pts.midy.y and pts.midy.y + h / 2,
    }
  end
  local frames = {}
  for frame in hframes:entries() do
    local regions = {}
    for r in kidregions(frame) do
      local rect = rects[r]
      if rect and next(rect) and r:IsVisible() then
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
            rect = rect,
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
