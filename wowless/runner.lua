local function run(cfg)
  _G.loadstring = _G.loadstring_untainted or _G.loadstring -- tainted-lua rewrite hack
  local loglevel = cfg.loglevel or 0
  local time0 = os.clock()
  local function log(level, fmt, ...)
    if level <= loglevel then
      print(string.format('[%.3f] ' .. fmt, os.clock() - time0, ...))
    end
  end
  local api = require('wowless.api').new(log, cfg.maxErrors)
  local loader = require('wowless.loader').loader(api, {
    cascproxy = cfg.cascproxy,
    otherAddonDirs = cfg.otherAddonDirs,
    rootDir = cfg.dir,
    version = cfg.version,
  })
  require('wowless.env').init(api, loader, cfg.taint)
  loader.initAddons()
  if cfg.dir then
    loader.loadFrameXml()
  end
  for _, d in ipairs(cfg.otherAddonDirs or {}) do
    assert(loader.loadAddon(require('path').basename(d)))
  end
  api.states.System.isLoggedIn = true
  api.SendEvent('PLAYER_LOGIN')
  api.SendEvent('UPDATE_CHAT_WINDOWS')
  api.SendEvent('VARIABLES_LOADED')
  api.SendEvent('PLAYER_ENTERING_WORLD', true, false)
  api.SendEvent('TRIAL_STATUS_UPDATE')
  api.SendEvent('DISPLAY_SIZE_CHANGED')
  api.SendEvent('SPELLS_CHANGED')
  if cfg.frame0 then
    local tt = require('resty.tsort').new()
    local function addPoints(r)
      for i = 1, r:GetNumPoints() do
        local relativeTo = select(2, r:GetPoint(i))
        if relativeTo ~= nil and relativeTo ~= r then
          tt:add(relativeTo, r)
        end
      end
    end
    for _, frame in ipairs(api.frames) do
      addPoints(frame)
      for _, r in ipairs({ frame:GetRegions() }) do
        addPoints(r)
      end
    end
    local screenWidth = 1024
    local screenHeight = 768
    local rects = {
      ['<screen>'] = {
        bottom = 0,
        left = 0,
        right = screenWidth,
        top = screenHeight,
      },
    }
    local function p2c(r, i)
      local p, rt, rp, px, py = r:GetPoint(i)
      local pr = assert(rects[rt == nil and '<screen>' or rt], 'moo ' .. r:GetDebugName()) -- relies on tsort
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
      if r:GetNumPoints() == 1 and r:GetPoint(1) == 'CENTER' then
        local _, x, y = p2c(r, 1)
        local w, h = r:GetSize()
        rects[r] = {
          bottom = y and y - (h / 2),
          left = x and x - (w / 2),
          right = x and x + (w / 2),
          top = y and y + (h / 2),
        }
      else
        for i = 1, r:GetNumPoints() do
          local p, x, y = p2c(r, i)
          points[p] = { x = x, y = y }
        end
        local pts = {
          bottom = points.BOTTOMLEFT or points.BOTTOM or points.BOTTOMRIGHT,
          left = points.TOPLEFT or points.LEFT or points.BOTTOMLEFT,
          midx = points.TOP or points.BOTTOM,
          midy = points.LEFT or points.RIGHT,
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
    end
    rects['<screen>'] = nil
    local ret = {}
    for r, rect in pairs(rects) do
      if next(rect) and r:IsVisible() then
        local content = {
          string = r:IsObjectType('FontString') and r:GetText() or nil,
          texture = (function()
            local t = r:IsObjectType('Texture') and r
              or r:IsObjectType('Button') and r:GetNormalTexture()
              or r:IsObjectType('StatusBar') and r:GetStatusBarTexture()
              or nil
            return t
              and {
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
                horizTile = t:GetHorizTile(),
                path = t:GetTexture(),
                vertTile = t:GetVertTile(),
              }
          end)(),
        }
        if next(content) then
          ret[r:GetDebugName()] = {
            content = content,
            rect = rect,
          }
        end
      end
    end
    require('pl.file').write('frame0.yaml', require('wowapi.yaml').pprint(ret))
    local magick = require('luamagick')
    local function color(c)
      local pwand = magick.new_pixel_wand()
      pwand:set_color(c)
      return pwand
    end
    local dwand = magick.new_drawing_wand()
    dwand:set_fill_opacity(0)
    dwand:set_stroke_color(color('blue'))
    for _, v in pairs(ret) do
      if v.content.texture then
        local r = v.rect
        dwand:rectangle(r.left, screenHeight - r.top, r.right, screenHeight - r.bottom)
      end
    end
    local mwand = magick.new_magick_wand()
    assert(mwand:new_image(screenWidth, screenHeight, color('none')))
    mwand:draw_image(dwand)
    assert(mwand:write_image('frame0.png'))
    os.exit(0)
  end
  local clickBlacklist = {
    PVPReadyDialogEnterBattleButton = true,
  }
  for _, frame in ipairs(api.frames) do
    if
      api.InheritsFrom(api.UserData(frame).type, 'button')
      and frame:IsVisible()
      and not clickBlacklist[frame:GetName() or '']
    then
      api.log(2, 'clicking %s', api.GetDebugName(frame))
      api.CallSafely(function()
        frame:Click()
      end)
    end
  end
  api.NextFrame()
  api.SendEvent('PLAYER_REGEN_DISABLED')
  api.NextFrame()
  api.SendEvent('PLAYER_REGEN_ENABLED')
  for i = 1, 12 do
    api.NextFrame(math.pow(2, i))
  end
  for _, frame in ipairs(api.frames) do
    if frame:IsVisible() then
      api.log(2, 'enter/leave %s', api.GetDebugName(frame))
      api.RunScript(frame, 'OnEnter', true)
      api.RunScript(frame, 'OnLeave', true)
    end
  end
  api.SendEvent('LOOT_READY', false)
  api.SendEvent('LOOT_OPENED', false, false)
  api.SendEvent('LOOT_CLOSED')
  do
    local b = api.env.ActionButton1
    if b then
      b:SetAttribute('type', 'macro')
      b:SetAttribute('macrotext', '/startattack')
      b:Click()
      b:SetAttribute('macrotext', '/stopattack')
      b:Click()
      b:SetAttribute('macrotext', '/startattack\n/stopattack')
      b:Click()
    end
  end
  api.SendEvent('CRAFT_SHOW')
  api.SendEvent('CRAFT_UPDATE')
  api.SendEvent('CRAFT_CLOSE')
  api.SendEvent('TRADE_SKILL_SHOW')
  api.SendEvent('TRADE_SKILL_UPDATE')
  api.SendEvent('TRADE_SKILL_CLOSE')
  api.SendEvent('GOSSIP_SHOW')
  api.SendEvent('GOSSIP_CLOSE')
  api.SendEvent('QUEST_GREETING')
  api.SendEvent('QUEST_PROGRESS')
  api.SendEvent('QUEST_FINISHED')
  do
    local names = {}
    for name in pairs(api.states.Bindings) do
      table.insert(names, name)
    end
    table.sort(names)
    for _, name in ipairs(names) do
      local fn = api.states.Bindings[name]
      api.log(2, 'firing binding ' .. name)
      api.CallSafely(function()
        fn('down')
      end)
      api.CallSafely(function()
        fn('up')
      end)
    end
  end
  do
    local cmdBlacklist = { -- TODO remove this; these require a better SecureCmdOptionParse
      BENCHMARK = true,
      CASTRANDOM = true,
      LOOT_MASTER = true, -- broken
      PTRFEEDBACK = true, -- this just seems broken with an empty string
      USERANDOM = true,
    }
    local cmds = {}
    for k, v in pairs(api.env) do
      local cmd = k:match('^SLASH_(.+)1$')
      if cmd and not cmdBlacklist[cmd] then
        cmds[cmd] = v
      end
    end
    for k, v in require('pl.tablex').sort(cmds) do
      api.log(2, 'firing chat command ' .. k .. ' via ' .. v)
      api.SendEvent('EXECUTE_CHAT_LINE', v)
    end
  end
  if cfg.allevents or cfg.version ~= 'Mainline' then
    local eventBlacklist = {
      BARBER_SHOP_OPEN = true, -- issue #111
      INSPECT_HONOR_UPDATE = true, -- INSPECTED_UNIT shenanigans
      INSTANCE_LOCK_START = true,
      INSTANCE_LOCK_WARNING = true,
      MAIL_INBOX_UPDATE = true, -- InboxFrame.openMailID not set when it should be
      OPEN_MASTER_LOOT_LIST = true,
      PLAYER_LOGIN = true,
      PLAYER_LOGOUT = true,
      UPDATE_MASTER_LOOT_LIST = true,
      VARIABLES_LOADED = true,
    }
    local keys = {}
    for k, v in pairs(require('wowapi.data').events) do
      local flavors = {}
      for _, flavor in ipairs(v.flavors or {}) do
        flavors[flavor] = true
      end
      if not eventBlacklist[k] and not next(v.payload) and (not v.flavors or flavors[cfg.version]) then
        table.insert(keys, k)
      end
    end
    table.sort(keys)
    for _, k in ipairs(keys) do
      api.SendEvent(k)
    end
  end
  if api.states.Addons.KethoDoc then
    api.env.KethoDoc:DumpWidgetAPI()
    print(api.env.KethoEditBox.EditBox:GetText())
  end
  api.SendEvent('PLAYER_LOGOUT')
  loader.saveAllVariables()
  return api
end

return {
  run = run,
}
