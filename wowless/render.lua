local function render(data, screenWidth, screenHeight, authority, rootDir, outfile)
  local magick = require('luamagick')
  local function color(c)
    local pwand = magick.new_pixel_wand()
    pwand:set_color(c)
    return pwand
  end
  local red, green, blue = color('red'), color('green'), color('blue')
  local dwand = magick.new_drawing_wand()
  dwand:set_fill_opacity(0)
  local conn = authority and require('wowless.http').connect(authority)
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
        if content then
          dwand:set_stroke_color(green)
          dwand:rectangle(left, top, right, bottom)
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
  local mwand = magick.new_magick_wand()
  assert(mwand:new_image(screenWidth, screenHeight, color('none')))
  mwand:draw_image(dwand)
  assert(mwand:write_image(outfile))
end

return {
  render = render,
}
