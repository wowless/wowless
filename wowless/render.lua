local function kidregions(r)
  return coroutine.wrap(function()
    for kid in r.children:entries() do
      if kid:IsObjectType('layeredregion') then
        coroutine.yield(kid)
      end
    end
  end)
end

local function frames2rects(api, product, screenWidth, screenHeight)
  local tt = require('resty.tsort').new()
  local function addPoints(r)
    for _, pt in ipairs(r.points) do
      local relativeTo = pt[2]
      if relativeTo ~= nil and relativeTo ~= r then
        tt:add(relativeTo, r)
      end
    end
  end
  for frame in api.frames:entries() do
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
  for frame in api.frames:entries() do
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

local strata = {
  WORLD = 1,
  BACKGROUND = 2,
  LOW = 3,
  MEDIUM = 4,
  HIGH = 5,
  DIALOG = 6,
  FULLSCREEN = 7,
  FULLSCREEN_DIALOG = 8,
  TOOLTIP = 9,
}

local layers = {
  BACKGROUND = 1,
  BORDER = 2,
  ARTWORK = 3,
  OVERLAY = 4,
  HIGHLIGHT = 5,
}

local function rects2png(data, fetch, outfile)
  local magick = require('luamagick')
  local function color(c)
    local pwand = magick.new_pixel_wand()
    pwand:set_color(c)
    return pwand
  end
  local red, blue = color('red'), color('blue')
  local dwand = magick.new_drawing_wand()
  dwand:set_fill_opacity(0)
  local mwand = magick.new_magick_wand()
  assert(mwand:new_image(data.screenWidth, data.screenHeight, color('none')))

  local blobs = {}
  local function getblob(path)
    local fpath
    if tonumber(path) then
      fpath = tonumber(path)
    else
      fpath = path:lower():gsub('\\', '/')
      if fpath:sub(-4) ~= '.blp' then
        fpath = fpath .. '.blp'
      end
    end
    local prev = blobs[fpath]
    if prev then
      return prev.width, prev.height, prev.png
    end
    local content = fetch(fpath)
    local success, width, height, png = pcall(function()
      local width, height, rgba = require('wowless.blp').read(content)
      return width, height, require('wowless.png').write(width, height, rgba)
    end)
    if success then
      blobs[fpath] = {
        height = height,
        png = png,
        width = width,
      }
      return width, height, png
    end
  end

  table.sort(data.frames, function(a, b)
    local sa = strata[a.strata] or 0
    local sb = strata[b.strata] or 0
    return sa < sb or sa == sb and (a.strataLevel or 0) < (b.strataLevel or 0)
  end)
  for _, f in ipairs(data.frames) do
    table.sort(f.regions, function(a, b)
      local aa = a.content.texture or {}
      local bb = b.content.texture or {}
      local la = layers[aa.drawLayer] or 0
      local lb = layers[bb.drawLayer] or 0
      return la < lb or la == lb and (aa.drawSubLayer or 0) < (bb.drawSubLayer or 0)
    end)
    for _, v in ipairs(f.regions) do
      if v.content.texture and v.content.texture.drawLayer ~= 'HIGHLIGHT' then
        local r = v.rect
        local left, top, right, bottom = r.left, data.screenHeight - r.top, r.right, data.screenHeight - r.bottom
        local x = v.content.texture.path
        x = x ~= 'FileData ID 0' and x or nil
        if x and left < right and top < bottom then
          local width, height, png = getblob(x)
          local c = v.content.texture.coords
          if png then
            local twand = magick.new_magick_wand()
            assert(twand:read_image_blob(png))
            if v.content.texture.maskPath then
              local mwidth, mheight, mpng = getblob(v.content.texture.maskPath)
              if mpng then
                local maskwand = magick.new_magick_wand()
                assert(maskwand:read_image_blob(mpng))
                assert(maskwand:distort_image(magick.DistortImageMethod.BilinearDistortion, {
                  -- Top left
                  mwidth,
                  mheight,
                  0,
                  0,
                  -- Top right
                  mwidth,
                  0,
                  width,
                  0,
                  -- Bottom right
                  mwidth,
                  mheight,
                  width,
                  height,
                  -- Bottom left
                  0,
                  mheight,
                  0,
                  height,
                }))
                assert(twand:composite_image(maskwand, magick.CompositeOperator.DstInCompositeOp, 0, 0))
              end
            end
            -- This is not consistent with the client, but avoids very weird effects.
            for ck, cv in pairs(c) do
              c[ck] = cv > 1.0 and 1.0 or cv < 0.0 and 0.0 or cv
            end
            assert(twand:set_image_extent(math.max(width, right - left), math.max(height, bottom - top)))
            assert(twand:distort_image(magick.DistortImageMethod.BilinearDistortion, {
              -- Top left
              c.tlx * width,
              c.tly * height,
              0,
              0,
              -- Top right
              c.trx * width,
              c.try * height,
              right - left,
              0,
              -- Bottom right
              c.brx * width,
              c.bry * height,
              right - left,
              bottom - top,
              -- Bottom left
              c.blx * width,
              c.bly * height,
              0,
              bottom - top,
            }))
            assert(twand:crop_image(right - left, bottom - top, 0, 0))
            local op
            if v.content.texture.blendMode == 'ADD' then
              op = magick.CompositeOperator.PlusCompositeOp
            else
              op = magick.CompositeOperator.OverCompositeOp
            end
            if v.content.texture.alpha > 0 then
              assert(mwand:composite_image(twand, op, left, top))
            end
          else
            dwand:set_stroke_color(red)
            dwand:rectangle(left, top, right, bottom)
          end
        else
          dwand:set_stroke_color(blue)
          dwand:rectangle(left, top, right, bottom)
        end
      end
    end
  end
  assert(mwand:draw_image(dwand))
  assert(mwand:write_image(outfile))
end

return {
  frames2rects = frames2rects,
  rects2png = rects2png,
}
