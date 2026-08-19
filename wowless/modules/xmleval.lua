local hlist = require('wowless.hlist')
local path = require('path')
local util = require('wowless.util')
local mixin = util.mixin
local readFile = util.readfile

return function(
  bindingsmodule,
  cstubs,
  datalua,
  envmodule,
  eventqueue,
  intrinsics,
  log,
  loglevel,
  points,
  scripts,
  security,
  templates,
  uiobjects,
  uiobjecttypes,
  visibility,
  xml
)
  local genv = envmodule.genv
  local secureenv = envmodule.secureenv
  local QueueEvent = eventqueue.QueueEvent
  local parseXml = xml
  local bindings = bindingsmodule.bindings
  local securemixins = {}
  local xmlimpls = datalua.xmlimpls

  local ParentSub = uiobjects.ParentSub
  local SetParent = uiobjects.SetParent
  local DoSetParent = uiobjects.DoSetParent
  local GetDebugName = uiobjects.GetDebugName
  local userdata = uiobjects.userdata
  local InheritsFrom = uiobjecttypes.InheritsFrom
  local IsVisible = visibility.IsVisible
  local RunScript = scripts.RunScript
  local new = cstubs.new
  local frames = hlist()
  local nextid = (function()
    local n = 0
    return function()
      n = n + 1
      return n
    end
  end)()

  -- Assigned below, once the phase functions they run exist; forward-declared
  -- here since CreateUIObject needs to call them and is defined first.
  local initEarlyAttrs, initAttrs, initScriptBindings, initKids

  local function CreateUIObject(typename, objnamearg, parent, addonEnv, tmplsarg, id, layer, sublevel)
    local objtype = uiobjecttypes.GetOrThrow(typename)
    local regid = nextid()
    local objp = new(regid, objtype.ctype)
    local obj = setmetatable({ [0] = objp }, objtype.sandboxMT)
    local ud = objtype.constructor()
    ud[1] = objp
    ud.luarep = obj
    ud.forbiddenrep = setmetatable({ [0] = objp }, objtype.sandboxMT)
    ud.type = typename
    userdata[regid] = ud
    setmetatable(ud, objtype.hostMT)
    DoSetParent(ud, parent)
    if InheritsFrom(typename, 'frame') then
      frames:insert(ud)
    end
    local tmpls = {}
    if tmplsarg then
      for _, tmpl in ipairs(tmplsarg) do
        table.insert(tmpls, tmpl)
      end
    end
    for _, template in ipairs(tmpls) do
      initEarlyAttrs(template, ud)
    end
    if (layer or sublevel) and ud.SetDrawLayer then
      ud:SetDrawLayer(layer or ud.layer, sublevel or ud.sublevel)
    end
    -- Resolved against the object's final parent, since an early `parent=`
    -- attr (processed above) can reassign it before $parent substitution runs.
    local objname
    if type(objnamearg) == 'string' then
      objname = ParentSub(objnamearg, ud.parent)
    elseif type(objnamearg) == 'number' then
      objname = tostring(objnamearg)
    end
    log(3, 'creating %s%s', objtype.name, objname and (' named ' .. objname) or '')
    if objname then
      ud.name = objname
      if genv[objname] then
        log(3, 'overwriting global ' .. objname)
      end
      genv[objname] = obj
      secureenv[objname] = obj
      if addonEnv then
        addonEnv[objname] = obj
      end
    end
    for _, template in ipairs(tmpls) do
      initAttrs(template, ud)
    end
    for _, template in ipairs(tmpls) do
      initScriptBindings(template, ud)
    end
    for _, template in ipairs(tmpls) do
      initKids(template, ud)
    end
    if id then
      ud:SetID(id)
    end
    if loglevel >= 3 then
      log(3, 'running load scripts on %s named %s', objtype.name, GetDebugName(ud))
    end
    RunScript(ud, 'OnLoad')
    if IsVisible(ud) then
      RunScript(ud, 'OnShow')
    end
    return ud
  end

  local function parseTypedValue(ty, value)
    ty = ty and string.lower(ty) or nil
    if ty == 'number' then
      return tonumber(value) or 0
    end
    if ty == 'global' then
      local t = genv
      for part in value:gmatch('[^.]+') do
        if type(t) ~= 'table' then
          log(1, 'warning: cannot find %q in _G', value)
          return nil
        end
        t = t[part]
      end
      return t
    end
    if ty == 'boolean' then
      if value == 'true' then
        return true
      end
      local n = tonumber(value)
      return n ~= nil and n ~= 0
    end
    if ty and ty ~= 'string' then
      log(1, 'warning: bogus keyvalue/attribute type %q', ty)
    end
    return value
  end

  local function getXY(e)
    if e then
      local dim = e.kids[#e.kids]
      local x = e.attr.x or (dim and dim.attr.x) or nil
      local y = e.attr.y or (dim and dim.attr.y) or nil
      return x, y
    end
  end

  local function getInsets(e)
    local kid = e.kids[#e.kids]
    local function v(k)
      return e.attr[k] or (kid and kid.attr[k])
    end
    return v('left'), v('right'), v('top'), v('bottom')
  end

  local function loadstr(str, filename, line)
    local function doload()
      local pre = line and string.rep('\n', line - 1) or ''
      return loadstring_untainted(pre .. str, '@' .. path.normalize(filename):gsub('/', '\\'))
    end
    if filename:find('Wowless') then
      debug.setstacktaint('Wowless')
      debug.settaintmode('rw')
      local fn = doload()
      debug.settaintmode('disabled')
      debug.setstacktaint(nil)
      return assert(fn)
    else
      return assert(doload())
    end
  end

  local function getColor(e)
    local name = e.attr.name or e.attr.color
    if not name then
      return e.attr.r or 0, e.attr.g or 0, e.attr.b or 0, e.attr.a or 1
    end
    local color = genv[name]
    if color then
      return color.r, color.g, color.b, color.a
    end
    log(1, 'unknown color %q', name) -- issue #303 for why we warn instead of error
    return 0, 0, 0, 1
  end

  local function loadLuaString(filename, str, line, useSecureEnv, closureTaint, ...)
    local before = genv.ScrollingMessageFrameMixin
    local fn = loadstr(str, filename, line)
    if useSecureEnv then
      setfenv(fn, secureenv)
    end
    debug.setnewclosuretaint(closureTaint)
    security.CallSandbox(fn, ...)
    debug.setnewclosuretaint(nil)
    -- Super hacky hack to hook ScrollingMessageFrameMixin.AddMessage
    local after = genv.ScrollingMessageFrameMixin
    if after and not before then
      local f = after.AddMessage
      after.AddMessage = function(self, text, ...)
        log(1, '[%s] %s', self:GetDebugName(), tostring(text))
        f(self, text, ...)
      end
    end
  end

  local scriptCache = {}

  local function precacheScriptText(script, obj, env, filename)
    if not scripts.HasScript(obj, script.type) then
      return
    end
    if script.attr['function'] or script.attr.method then
      return
    end
    scriptCache[env] = scriptCache[env] or {}
    if scriptCache[env][script] ~= nil then
      return
    end
    local fn
    if script.text then
      local args = xmlimpls[string.lower(script.type)].tag.script.args or 'self, ...'
      local fnstr = 'return function(' .. args .. ') ' .. script.text .. ' end'
      local outfn = loadstr(fnstr, filename, script.line)
      local success, ret = security.CallSandbox(outfn)
      assert(success)
      fn = setfenv(ret, env)
    end
    -- false, not nil, distinguishes "precached, no function" from "never precached".
    scriptCache[env][script] = fn or false
  end

  local function bindScript(script, obj, env, intrinsic)
    if not scripts.HasScript(obj, script.type) then
      local prefix = datalua.config.runtime.bareScriptWarning and '' or 'Frame '
      local fmt = prefix .. '%s: Unknown script element %s'
      QueueEvent('LUA_WARNING', fmt:format(uiobjecttypes.GetObjectType(obj), script.name))
      return
    end
    local fn
    if script.attr['function'] then
      local fnattr = script.attr['function']
      fn = env[fnattr]
      if not fn then
        log(2, 'unknown script function %q on %q', fnattr, obj:GetDebugName())
      end
    elseif script.attr.method then
      local mattr = script.attr.method
      fn = obj.luarep[mattr]
      if not fn and obj.forbiddenrep[mattr] then
        local ffn = obj.forbiddenrep[mattr]
        fn = function(_, ...)
          return ffn(obj.forbiddenrep, ...)
        end
        setfenv(fn, env)
      end
      if not fn then
        log(2, 'unknown script method %q on %q', mattr, obj:GetDebugName())
      end
    else
      local cached = scriptCache[env] and scriptCache[env][script]
      assert(cached ~= nil, 'wowless bug: script text not precached')
      fn = cached or nil
    end
    local old = obj.scripts[1][script.type:lower()]
    if old and fn and script.attr.inherit then
      local bfn = fn
      if script.attr.inherit == 'prepend' then
        fn = function(...)
          old(...)
          bfn(...)
        end
      elseif script.attr.inherit == 'append' then
        fn = function(...)
          bfn(...)
          old(...)
        end
      else
        error('invalid inherit tag on script')
      end
      setfenv(fn, env)
    end
    assert(not script.attr.intrinsicorder or intrinsic, 'intrinsicOrder on non-intrinsic')
    local bindingType = 1
    if script.attr.intrinsicorder == 'precall' then
      bindingType = 0
    elseif script.attr.intrinsicorder == 'postcall' then
      bindingType = 2
    elseif script.attr.intrinsicorder then
      error('invalid intrinsicOrder tag on script')
    elseif intrinsic then
      bindingType = 0
    end
    scripts.SetScriptWithBindingType(obj, script.type, bindingType, fn)
  end

  local parentMatch = '^$[pP][aA][rR][eE][nN][tT]'

  local function navigate(obj, key)
    local orig = obj
    for p in key:gmatch('([^.]+)') do
      if p:match(parentMatch) then
        obj = obj.parent
      else
        local v = obj.luarep[p]
        obj = v and uiobjects.UserData(v)
      end
      if not obj or obj == orig then
        log(1, 'invalid relativeKey %q', key)
        return nil
      end
    end
    return obj
  end

  -- A real client only prefixes this with a file:line when the
  -- enableSourceLocationLookup cvar is on. The addon forces it off
  -- (init.lua) so both sides can just compare bare messages.
  local function anchorWarning(parent, reason, value)
    QueueEvent('LUA_WARNING', ('%s: %s: %s'):format(parent.name or 'Unknown', reason, value))
  end

  local xmllang = {
    anchor = function(_, anchor, parent)
      local point = anchor.attr.point or 'TOPLEFT'
      local relativeTo
      if anchor.attr.relativeto then
        relativeTo = genv[ParentSub(anchor.attr.relativeto, parent.parent)]
        relativeTo = relativeTo and uiobjects.UserData(relativeTo)
        if not relativeTo then
          return anchorWarning(parent, 'Couldn\'t find relative frame', anchor.attr.relativeto)
        elseif relativeTo == parent then
          return anchorWarning(parent, 'anchored to itself', anchor.attr.relativeto)
        end
      elseif anchor.attr.relativekey then
        if not anchor.attr.relativekey:match(parentMatch) then
          return anchorWarning(parent, 'anchored to itself', anchor.attr.relativekey)
        end
        relativeTo = navigate(parent, anchor.attr.relativekey)
        if not relativeTo or relativeTo == parent then
          relativeTo = parent.parent
        end
      else
        relativeTo = parent.parent
      end
      local relativePoint = anchor.attr.relativepoint or point
      local offsetX, offsetY = getXY(anchor.kids[#anchor.kids])
      local x = anchor.attr.x or offsetX or 0
      local y = anchor.attr.y or offsetY or 0
      points.SetPointInternal(parent, point:upper(), relativeTo, relativePoint:upper(), x, y)
    end,
    attribute = function(_, e, parent)
      -- TODO share code with SetAttribute somehow
      local a = e.attr
      parent.attributes[a.name] = parseTypedValue(a.type, a.value)
    end,
    barcolor = function(_, e, parent)
      parent:SetStatusBarColor(getColor(e))
    end,
    blingtexture = function(_, e, parent)
      parent:SetBlingTexture(e.attr.file or '', getColor(e))
    end,
    color = function(_, e, parent)
      local r, g, b, a = getColor(e)
      if uiobjecttypes.InheritsFrom(parent.type, 'texturebase') then
        parent:SetColorTexture(r, g, b, a)
      elseif uiobjecttypes.InheritsFrom(parent.type, 'fontinstance') then
        parent:SetTextColor(r, g, b, a)
      elseif uiobjecttypes.InheritsFrom(parent.type, 'statusbar') then
        parent:SetStatusBarColor(r, g, b, a)
      else
        error('cannot apply color to ' .. parent.type)
      end
    end,
    edgetexture = function(_, e, parent)
      parent:SetEdgeTexture(e.attr.file or '', getColor(e))
    end,
    fontheight = function(_, e, parent)
      local name, _, flags = parent:GetFont()
      parent:SetFont(name, e.kids[#e.kids].attr.val, flags)
    end,
    -- TODO wire up AddForbiddenAspects once something depends on it; for
    -- now this just keeps the tag from being flagged as unrecognized.
    forbiddenaspects = function() end,
    gradient = function(_, e, parent)
      local minColor, maxColor
      for _, kid in ipairs(e.kids) do
        if kid.type == 'mincolor' then
          minColor = kid
        elseif kid.type == 'maxcolor' then
          maxColor = kid
        end
      end
      if minColor and maxColor then
        local minR, minG, minB, minA = getColor(minColor)
        local maxR, maxG, maxB, maxA = getColor(maxColor)
        local min = { r = minR, g = minG, b = minB, a = minA }
        local max = { r = maxR, g = maxG, b = maxB, a = maxA }
        parent:SetGradient(e.attr.orientation, min, max)
      end
    end,
    highlightcolor = function(_, e, parent)
      parent:SetHighlightColor(getColor(e))
    end,
    hitrectinsets = function(_, e, parent)
      parent:SetHitRectInsets(getInsets(e))
    end,
    keyvalue = function(ctx, e, parent)
      local obj = ctx.useForbiddenObjectTable and parent.forbiddenrep or parent.luarep
      local a = e.attr
      obj[a.key] = parseTypedValue(a.type, a.value)
    end,
    maskedtexture = function(_, e, parent)
      local t = navigate(parent.parent, e.attr.childkey)
      if t then
        t:AddMaskTexture(parent)
      else
        log(1, 'cannot find maskedtexture childkey %s', e.attr.childkey)
      end
    end,
    maxresize = function(_, e, parent)
      -- TODO fix for dragonflight
      if parent.SetMaxResize then
        parent:SetMaxResize(getXY(e.kids[#e.kids]))
      end
    end,
    minresize = function(_, e, parent)
      -- TODO fix for dragonflight
      if parent.SetMinResize then
        parent:SetMinResize(getXY(e.kids[#e.kids]))
      end
    end,
    mixin = function(ctx, e, parent)
      assert(ctx.useForbiddenObjectTable)
      assert(e.attr.source == 'secure', e.attr.source)
      local f = parent.forbiddenrep
      local m = assert(secureenv[e.attr.key], e.attr.key)
      if not e.attr.securedelegates then
        mixin(f, m)
      else
        assert(e.attr.targetpartition == 'public', e.attr.targetpartition)
        assert(e.attr.inboundpartition == 'forbidden', e.attr.inboundpartition)
        for k, v in pairs(m) do
          parent.luarep[k] = debug.newsecurefunction(function(_, ...)
            return v(f, ...)
          end)
        end
      end
    end,
    modifiedclick = function()
      -- TODO support modified clicks
    end,
    origin = function(_, e, parent)
      if e.attr.point then
        local x, y = getXY(e)
        parent:SetOrigin(e.attr.point, x or 0, y or 0)
      end
    end,
    pushedtextoffset = function(_, e, parent)
      parent:SetPushedTextOffset(getXY(e))
    end,
    shadow = function(_, e, parent)
      local color, offset
      for _, kid in ipairs(e.kids) do
        if kid.type == 'color' then
          color = kid
        elseif kid.type == 'offset' then
          offset = kid
        end
      end
      if color then
        parent:SetShadowColor(getColor(color))
      end
      if offset then
        parent:SetShadowOffset(getXY(offset))
      end
    end,
    size = function(_, e, parent)
      local x, y = getXY(e)
      if x then
        parent:SetWidth(x)
      end
      if y then
        parent:SetHeight(y)
      end
    end,
    swipetexture = function(_, e, parent)
      parent:SetSwipeTexture(e.attr.file or '', getColor(e))
    end,
    texcoords = function(_, e, parent)
      local rect = e.kids[#e.kids]
      if rect then
        local x = rect.attr
        parent:SetTexCoord(
          x.ulx or 0,
          x.uly or 0,
          x.llx or 0,
          x.lly or 1,
          x.urx or 1,
          x.ury or 0,
          x.lrx or 1,
          x.lry or 1
        )
      else
        local x = e.attr
        parent:SetTexCoord(x.left or 0, x.right or 1, x.top or 0, x.bottom or 1)
      end
    end,
    textinsets = function(_, e, parent)
      parent:SetTextInsets(getInsets(e))
    end,
    viewinsets = function(_, e, parent)
      parent:SetViewInsets(getInsets(e))
    end,
  }

  local xmlattrlang = {
    hidden = function(_, obj, value)
      obj.shown = not value
    end,
    mixin = function(ctx, obj, value)
      local env = ctx.useAddonEnv and ctx.addonEnv or ctx.useSecureEnv and secureenv or genv
      for _, m in ipairs(value) do
        mixin(obj.luarep, env[m])
      end
    end,
    parent = function(ctx, obj, value)
      local env = ctx.useAddonEnv and ctx.addonEnv or ctx.useSecureEnv and secureenv or genv
      local parent = env[value]
      SetParent(obj, parent and uiobjects.UserData(parent))
    end,
    parentarray = function(_, obj, value)
      local p = obj.parent
      if p then
        p = p.luarep
        p[value] = p[value] or {}
        table.insert(p[value], obj.luarep)
      end
    end,
    parentkey = function(_, obj, value)
      local p = obj.parent
      if p then
        p.luarep[value] = obj.luarep
      end
    end,
    securemixin = function(ctx, obj, value)
      local env = ctx.useAddonEnv and ctx.addonEnv or ctx.useSecureEnv and secureenv or genv
      for _, m in ipairs(value) do
        local mv = env[m]
        local sm = securemixins[mv]
        if not sm then
          local vv = {}
          for k, v in pairs(mv) do
            vv[k] = v
            mv[k] = nil
          end
          setmetatable(mv, {
            __index = vv,
            __metatable = 0,
          })
          sm = {}
          for k, v in pairs(vv) do
            sm[k] = type(v) == 'function' and debug.newsecurefunction(v) or v
          end
          securemixins[mv] = sm
        end
        mixin(obj.luarep, sm)
      end
    end,
    setallpoints = function(_, obj, value)
      if value and not obj:IsObjectType('texturebase') then
        points.SetAllPointsInternal(obj, obj.parent)
      end
    end,
  }

  local loadElement
  local LoadFile

  local function processAttr(ctx, attr, obj, v)
    if attr.impl == 'internal' then
      xmlattrlang[attr.name](ctx, obj, v)
    elseif attr.impl == 'loadfile' then
      LoadFile(
        ctx.addonName,
        ctx.addonEnv,
        ctx.addonRoot,
        ctx.useSecureEnv,
        path.join(ctx.dir, v),
        nil,
        path.join(ctx.addonRoot, v)
      )
    elseif attr.impl.scope then
      return { [attr.impl.scope] = v }
    elseif attr.impl.method then
      local fn = assert(obj[attr.impl.method], attr.impl.method)
      if type(v) == 'table' then -- stringlist
        fn(obj, unpack(v))
      else
        fn(obj, v)
      end
    elseif attr.impl.field then
      obj[attr.impl.field] = v
    else
      error('invalid attribute impl for ' .. attr.name)
    end
  end

  local function processAttrs(ctx, e, obj, phase)
    local objty = obj.type
    local attrs = xmlimpls[objty].attrs
    for k, v in pairs(e.attr) do
      local attr = attrs[k]
      if attr and phase == attr.phase then
        processAttr(ctx, attr, obj, v)
      end
    end
  end

  local function implUiobjectType(e)
    local entry = xmlimpls[e.type] and xmlimpls[e.type].tag
    return type(entry) == 'table' and entry.uiobject and string.lower(entry.uiobject) or nil
  end

  local function implUnknownType(e)
    return xmlimpls[e.type] and xmlimpls[e.type].tag == 'unknowntype'
  end

  local function loadElements(ctx, t, parent)
    for _, v in ipairs(t) do
      loadElement(ctx, v, parent)
    end
  end

  local function processKids(ctx, e, obj, phase)
    ctx = ctx.ignoreVirtual and ctx or mixin({}, ctx, { ignoreVirtual = true })
    for _, kid in ipairs(e.kids) do
      if xmlimpls[string.lower(kid.type)].phase == phase then
        loadElement(ctx, kid, obj)
      end
    end
  end

  -- A template is data (ctx + elem); these are the shared, stateless
  -- functions that interpret it against a concrete object at creation time,
  -- walking the inherits= chain first. Same four function values are used
  -- by every template, so building a template never allocates a closure.
  local function makePhaseRunner(phase)
    local runner
    runner = function(template, obj)
      for _, inh in ipairs(template.inherits or {}) do
        runner(templates.GetTemplateOrThrow(inh), obj)
      end
      phase(template.ctx, template.elem, obj)
    end
    return runner
  end

  initEarlyAttrs = makePhaseRunner(function(ctx, e, obj)
    processAttrs(ctx, e, obj, 'early')
  end)

  initAttrs = makePhaseRunner(function(ctx, e, obj)
    processAttrs(ctx, e, obj, 'middle')
    processKids(ctx, e, obj, 'middle')
  end)

  -- Runs after every template in the inherits= chain has finished Attrs, so
  -- method= resolves against fully-composed fields.
  initScriptBindings = makePhaseRunner(function(ctx, e, obj)
    local env = ctx.useAddonEnv and ctx.addonEnv or ctx.useSecureEnv and secureenv or genv
    for _, kid in ipairs(e.kids) do
      if string.lower(kid.type) == 'scripts' then
        for _, script in ipairs(kid.kids) do
          bindScript(script, obj, env, ctx.intrinsic)
        end
      end
    end
  end)

  initKids = makePhaseRunner(function(ctx, e, obj)
    processKids(ctx, e, obj, 'late')
    processAttrs(ctx, e, obj, 'late')
    -- Implicit setpoint hack for fontstrings.
    if obj:IsObjectType('fontstring') and obj:GetNumPoints() == 0 then
      -- Conveniently the JustifyHorizontal names match FramePoint.
      points.SetPointInternal(obj, obj.justifyh, obj.parent, obj.justifyh, 0, 0)
    end
    -- Implicit setallpoints hack for textures.
    if obj:IsObjectType('texture') and obj:GetNumPoints() == 0 then
      points.SetAllPointsInternal(obj, obj.parent)
    end
  end)

  function loadElement(ctx, e, parent)
    local ltype = string.lower(e.type)
    local intrinsicEntry = intrinsics.Get(ltype)
    local implBasetype = implUiobjectType(e)
    local unknownType = implUnknownType(e)
    -- e.type dispatches to either a declared uiobject-creating tag (impl.uiobject
    -- in xml.yaml) or a previously-registered intrinsic (same name namespace).
    if implBasetype or intrinsicEntry or unknownType then
      ctx = not e.attr.intrinsic and ctx or mixin({}, ctx, { intrinsic = true })
      local template = {
        ctx = ctx,
        elem = e,
        inherits = e.attr.inherits,
        name = e.attr.name,
        type = e.type,
      }
      local virtual = e.attr.virtual
      if e.attr.intrinsic then
        assert(virtual ~= false, 'intrinsics cannot be explicitly non-virtual: ' .. e.type)
        assert(e.attr.name, 'cannot create anonymous intrinsic')
        local basetype = intrinsicEntry and intrinsicEntry.basetype or implBasetype
        uiobjecttypes.GetOrThrow(basetype) -- validate basetype exists
        intrinsics.Add(e.attr.name, basetype, template, intrinsicEntry ~= nil)
      else
        if (ltype == 'font' and e.attr.name) or (virtual and not ctx.ignoreVirtual) then
          assert(e.attr.name, 'cannot create anonymous template')
          templates.SetTemplate(e.attr.name, template)
        end
        if ltype == 'font' or (not virtual or ctx.ignoreVirtual) then
          -- issue #116: a real client parses a tag for an intrinsic of an
          -- intrinsic fine, but refuses to instantiate it, the same way it
          -- warns on an unknown frame type.
          if intrinsicEntry and intrinsicEntry.nested then
            QueueEvent('LUA_WARNING', 'Unknown frame type: ' .. intrinsicEntry.displayName)
            return nil
          end
          -- issue #863: this tag parses (structurally valid per xml.yaml)
          -- but has no genuine backing uiobject on this product; a real
          -- client refuses to instantiate it, the same way it does an
          -- unknown frame type passed to CreateFrame.
          if unknownType then
            QueueEvent('LUA_WARNING', 'Unknown frame type: ' .. e.name)
            return nil
          end
          local name = e.attr.name
          if virtual and ctx.ignoreVirtual then
            log(1, 'ignoring virtual on %s', tostring(name))
          end
          local basetype = intrinsicEntry and intrinsicEntry.basetype or implBasetype
          local env = ctx.useAddonEnv and ctx.addonEnv or ctx.useSecureEnv and secureenv or genv
          local tmpls = intrinsicEntry and { intrinsicEntry.template, template } or { template }
          local objParent = uiobjecttypes.InheritsFrom(basetype, 'parentedobjectbase') and parent or nil
          local obj = CreateUIObject(basetype, name, objParent, env, tmpls, nil, ctx.layer, ctx.sublevel)
          if ltype == 'worldframe' then
            -- WORLD is a real frameStrata value, but only WorldFrame has it,
            -- confirmed against a real client; it isn't reachable through
            -- SetFrameStrata.
            obj.frameStrata = 'WORLD'
          end
          return obj
        end
      end
    else
      local impl = xmlimpls[e.type] and xmlimpls[e.type].tag or nil
      local fn = xmllang[e.type]
      if type(impl) == 'table' and impl.script then
        local env = ctx.useAddonEnv and ctx.addonEnv or ctx.useSecureEnv and secureenv or genv
        precacheScriptText(e, parent, env, ctx.filename)
      elseif type(impl) == 'table' and impl.call then
        local elt = impl.call.argument == 'lastkid' and e.kids[#e.kids] or mixin({}, e, { type = impl.call.argument })
        local obj = loadElement(ctx, elt, parent)
        -- TODO find if this if needs to be broader to everything here including kids
        if parent:IsObjectType(impl.call.parenttype) then
          parent[impl.call.parentmethod](parent, obj)
        end
      elseif impl == 'transparent' or impl == 'loadstring' then
        local ctxmix = mixin({}, ctx)
        for k, v in pairs(e.attr) do
          local attr = xmlimpls[e.type].attrs[k]
          if attr then
            mixin(ctxmix, processAttr(ctx, attr, nil, v))
          end
        end
        loadElements(ctxmix, e.kids, parent)
        if impl == 'loadstring' and e.text then
          loadLuaString(ctx.filename, e.text, e.line, ctx.useSecureEnv)
        end
      elseif e.type == 'binding' then -- TODO do this another way
        -- TODO interpret all binding attributes
        if not e.attr.debug then -- TODO support debug bindings
          local bfn = 'return function(keystate) ' .. e.text .. ' end'
          bindings[e.attr.name] = loadstr(bfn, ctx.filename, e.line)()
        end
      elseif e.type == 'fontfamily' then -- TODO do this another way
        local font = e.kids[1].kids[1]
        loadElement(ctx, {
          attr = mixin({}, font.attr, { virtual = true, name = e.attr.name }),
          kids = font.kids,
          type = font.type,
        })
      elseif fn then
        fn(ctx, e, parent)
      else
        error('unimplemented xml tag ' .. e.type)
      end
    end
  end

  local function loadXml(addonName, addonEnv, addonRoot, useSecureEnv, filename, xmlstr)
    local dir = path.dirname(filename)
    security.CallSafely(function()
      local ctx = {
        addonEnv = addonEnv,
        addonName = addonName,
        addonRoot = addonRoot,
        dir = dir,
        filename = filename,
        ignoreVirtual = false,
        intrinsic = false,
        useAddonEnv = false,
        useSecureEnv = useSecureEnv,
      }
      local root, warnings = parseXml(xmlstr)
      if loglevel >= 3 then
        for _, warning in ipairs(warnings) do
          log(3, filename .. ': ' .. warning)
        end
      end
      loadElement(ctx, root)
    end)
  end

  function LoadFile(addonName, addonEnv, addonRoot, useSecureEnv, filename, closureTaint, secondaryFileName)
    filename = path.normalize(filename)
    security.CallSafely(function()
      log(2, 'loading file %s', filename)
      local isXml
      if filename:sub(-4) == '.lua' then
        isXml = false
      elseif filename:sub(-4) == '.xml' then
        isXml = true
      else
        error('unknown file type ' .. filename)
      end
      local success, content = pcall(readFile, filename)
      if not success and secondaryFileName then
        success, content = pcall(readFile, secondaryFileName)
      end
      if success then
        if isXml then
          loadXml(addonName, addonEnv, addonRoot, useSecureEnv, filename, content)
        else
          loadLuaString(filename, content, nil, useSecureEnv, closureTaint, addonName, addonEnv)
        end
      else
        log(1, 'skipping missing file %s', filename)
      end
    end)
  end

  return {
    CreateUIObject = CreateUIObject,
    frames = frames,
    LoadFile = LoadFile,
  }
end
