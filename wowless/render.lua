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
        local prefix = '/product/' .. rootDir:sub(10)
        local fpath = prefix .. (tonumber(x) and '/fdid/' .. x or '/name/' .. x:gsub('\\', '/'))
        if fpath:sub(-4):lower() ~= '.blp' then
          fpath = fpath .. '.blp'
        end
        local content = conn(fpath)
        local success, png = pcall(function()
          return require('wowless.png').write(require('wowless.blp').read(content))
        end)
        local c = v.content.texture.coords
        if
          success
          and c.blx == 0
          and c.bly == 1
          and c.brx == 1
          and c.bry == 1
          and c.tlx == 0
          and c.tly == 0
          and c.trx == 1
          and c.try == 0
        then
          local twand = magick.new_magick_wand()
          assert(twand:read_image_blob(png))
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
