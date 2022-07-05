local function render(data, screenWidth, screenHeight, authority, rootDir, outfile)
  local magick = require('luamagick')
  local function color(c)
    local pwand = magick.new_pixel_wand()
    pwand:set_color(c)
    return pwand
  end
  local red, blue = color('red'), color('blue')
  local dwand = magick.new_drawing_wand()
  dwand:set_fill_opacity(0)
  local conn = authority and require('wowless.http').connect(authority)
  local mwand = magick.new_magick_wand()
  assert(mwand:new_image(screenWidth, screenHeight, color('none')))
  for _, v in pairs(data) do
    if v.content.texture then
      local r = v.rect
      local left, top, right, bottom = r.left, screenHeight - r.top, r.right, screenHeight - r.bottom
      local x = v.content.texture.path
      if conn and x then
        local fpath
        if tonumber(x) then
          fpath = '/fdid/' .. x
        else
          fpath = '/name/' .. x:gsub('\\', '/')
          if fpath:sub(-4):lower() ~= '.blp' then
            fpath = fpath .. '.blp'
          end
        end
        fpath = '/product/' .. rootDir:sub(10) .. fpath
        local content = fpath:find(' ') and '' or conn(fpath)
        local success, width, height, png = pcall(function()
          local width, height, rgba = require('wowless.blp').read(content)
          return width, height, require('wowless.png').write(width, height, rgba)
        end)
        local c = v.content.texture.coords
        if success then
          local twand = magick.new_magick_wand()
          assert(twand:read_image_blob(png))
          assert(twand:distort_image(magick.DistortImageMethod.BilinearDistortion, {
            -- Top left
            0,
            0,
            c.tlx * width,
            c.tly * height,
            -- Top right
            width,
            0,
            c.trx * width,
            c.try * height,
            -- Bottom right
            width,
            height,
            c.brx * width,
            c.bry * height,
            -- Bottom left
            0,
            height,
            c.blx * width,
            c.bly * height,
          }))
          assert(mwand:composite_image(twand, magick.CompositeOperator.OverCompositeOp, left, top))
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
  assert(mwand:draw_image(dwand))
  assert(mwand:write_image(outfile))
end

return {
  render = render,
}
