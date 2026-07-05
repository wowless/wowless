return function(
  api,
  datalua,
  envmodule,
  events,
  log,
  loglevel,
  points,
  scripts,
  security,
  templates,
  uiobjects,
  uiobjecttypes
)
  local genv = envmodule.genv
  local secureenv = envmodule.secureenv
  local SendEvent = events.SendEvent

  local product = datalua.product
  assert(product, 'loader requires a product')

  local path = require('path')
  local parseXml = require('wowless.xml').newParser(product)
  local util = require('wowless.util')
  local mixin = util.mixin
  local intrinsics = {}
  local readFile = util.readfile
  local bindings = {}
  local securemixins = {}

  local xmlimpls = datalua.xmlimpls

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

  local function loadScript(script, obj, env, filename, intrinsic)
    if not scripts.HasScript(obj, script.type) then
      local fmt = 'Frame %s: Unknown script element %s'
      SendEvent('LUA_WARNING', fmt:format(uiobjecttypes.GetObjectType(obj), script.name))
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
      if not fn then
        log(2, 'unknown script method %q on %q', mattr, obj:GetDebugName())
      end
    elseif scriptCache[env] and scriptCache[env][script] then
      fn = scriptCache[env][script]
    elseif script.text then
      local args = xmlimpls[string.lower(script.type)].tag.script.args or 'self, ...'
      local fnstr = 'return function(' .. args .. ') ' .. script.text .. ' end'
      local outfn = loadstr(fnstr, filename, script.line)
      local success, ret = security.CallSandbox(outfn)
      assert(success)
      fn = setfenv(ret, env)
      scriptCache[env] = scriptCache[env] or {}
      scriptCache[env][script] = fn
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

  local xmllang = {
    anchor = function(_, anchor, parent)
      local point = anchor.attr.point or 'TOPLEFT'
      local relativeTo
      if anchor.attr.relativeto then
        relativeTo = genv[api.ParentSub(anchor.attr.relativeto, parent.parent)]
        relativeTo = relativeTo and uiobjects.UserData(relativeTo)
        if not relativeTo or relativeTo == parent then
          return
        end
      elseif anchor.attr.relativekey then
        if not anchor.attr.relativekey:match(parentMatch) then
          return
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
    color = function(ctx, e, parent)
      local r, g, b, a = getColor(e)
      if uiobjecttypes.InheritsFrom(parent.type, 'texturebase') then
        parent:SetColorTexture(r, g, b, a)
      elseif uiobjecttypes.InheritsFrom(parent.type, 'fontinstance') then
        if ctx.shadow then
          parent:SetShadowColor(r, g, b, a)
        else
          parent:SetTextColor(r, g, b, a)
        end
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
    keyvalue = function(_, e, parent)
      local a = e.attr
      parent.luarep[a.key] = parseTypedValue(a.type, a.value)
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
    modifiedclick = function()
      -- TODO support modified clicks
    end,
    offset = function(ctx, e, parent)
      assert(ctx.shadow, 'this should only run on shadow for now')
      parent:SetShadowOffset(getXY(e))
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
      api.SetParent(obj, parent and uiobjects.UserData(parent))
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

  local function forAddon(addonName, addonEnv, addonRoot, useSecureEnv, skipObjects)
    local loadFile

    local function loadXml(filename, xmlstr)
      local dir = path.dirname(filename)

      local function processAttr(ctx, attr, obj, v)
        if attr.impl == 'internal' then
          xmlattrlang[attr.name](ctx, obj, v)
        elseif attr.impl == 'loadfile' then
          loadFile(path.join(dir, v), nil, path.join(addonRoot, v))
        elseif attr.impl.scope then
          return { [attr.impl.scope] = v }
        elseif attr.impl.method then
          local fn = obj[attr.impl.method]
          if not fn then
            error(('missing method %q on object type %q'):format(attr.impl.method, obj.type))
          elseif type(v) == 'table' then -- stringlist
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
        local attrs = (xmlimpls[objty] or intrinsics[objty]).attrs
        for k, v in pairs(e.attr) do
          local attr = attrs[k]
          if attr and phase == attr.phase then
            processAttr(ctx, attr, obj, v)
          end
        end
      end

      local loadElement

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

      local phases = {
        EarlyAttrs = function(ctx, e, obj)
          if ctx.layer and obj.SetDrawLayer then
            obj:SetDrawLayer(ctx.layer)
          end
          processAttrs(ctx, e, obj, 'early')
        end,
        Attrs = function(ctx, e, obj)
          processAttrs(ctx, e, obj, 'middle')
          processKids(ctx, e, obj, 'middle')
        end,
        Kids = function(ctx, e, obj)
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
        end,
      }

      local function mkInitPhase(ctx, phaseName, e)
        local phase = phases[phaseName]
        return function(obj)
          for _, inh in ipairs(e.attr.inherits or {}) do
            local t = templates.GetTemplateOrThrow(inh)
            t['init' .. phaseName](obj)
          end
          phase(ctx, e, obj)
        end
      end

      function loadElement(ctx, e, parent)
        -- This assumes that uiobject types and xml types are the same "space" of strings.
        if uiobjecttypes.IsIntrinsicType(e.type) or e.type == 'worldframe' then
          ctx = not e.attr.intrinsic and ctx or mixin({}, ctx, { intrinsic = true })
          local template = {
            inherits = e.attr.inherits,
            initEarlyAttrs = mkInitPhase(ctx, 'EarlyAttrs', e),
            initAttrs = mkInitPhase(ctx, 'Attrs', e),
            initKids = mkInitPhase(ctx, 'Kids', e),
            name = e.attr.name,
            type = e.type,
          }
          local virtual = e.attr.virtual
          if ctx.skipObjects then
            return
          elseif e.attr.intrinsic then
            assert(virtual ~= false, 'intrinsics cannot be explicitly non-virtual: ' .. e.type)
            assert(e.attr.name, 'cannot create anonymous intrinsic')
            local name = string.lower(e.attr.name)
            if uiobjecttypes.Has(name) then
              log(1, 'overwriting intrinsic %s', e.attr.name)
            end
            log(3, 'creating intrinsic %s', e.attr.name)
            local basetype = string.lower(e.type)
            local base = uiobjecttypes.GetOrThrow(basetype)
            uiobjecttypes.Add(name, {
              constructor = base.constructor,
              ctype = base.ctype,
              hostMT = base.hostMT,
              isa = base.isa,
              name = base.name,
              sandboxMT = base.sandboxMT,
              scripts = base.scripts,
              template = template,
            })
            intrinsics[name] = xmlimpls[basetype]
          else
            local ltype = string.lower(e.type)
            if (ltype == 'font' and e.attr.name) or (virtual and not ctx.ignoreVirtual) then
              assert(e.attr.name, 'cannot create anonymous template')
              templates.SetTemplate(e.attr.name, template)
            end
            if ltype == 'font' or (not virtual or ctx.ignoreVirtual) then
              local name = e.attr.name
              if virtual and ctx.ignoreVirtual then
                log(1, 'ignoring virtual on %s', tostring(name))
              end
              local ety = e.type == 'worldframe' and 'frame' or e.type
              local env = ctx.useAddonEnv and addonEnv or ctx.useSecureEnv and secureenv or genv
              return api.CreateUIObject(ety, name, parent, env, { template })
            end
          end
        else
          local impl = xmlimpls[e.type] and xmlimpls[e.type].tag or nil
          local fn = xmllang[e.type]
          if type(impl) == 'table' and impl.script then
            local env = ctx.useAddonEnv and addonEnv or ctx.useSecureEnv and secureenv or genv
            loadScript(e, parent, env, filename, ctx.intrinsic)
          elseif type(impl) == 'table' and impl.scope then
            loadElements(mixin({}, ctx, { [impl.scope] = true }), e.kids, parent)
          elseif type(impl) == 'table' and impl.call then
            local elt = impl.call.argument == 'lastkid' and e.kids[#e.kids]
              or mixin({}, e, { type = impl.call.argument })
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
              loadLuaString(filename, e.text, e.line, ctx.useSecureEnv)
            end
          elseif e.type == 'binding' then -- TODO do this another way
            -- TODO interpret all binding attributes
            if not e.attr.debug then -- TODO support debug bindings
              local bfn = 'return function(keystate) ' .. e.text .. ' end'
              bindings[e.attr.name] = loadstr(bfn, filename, e.line)()
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

      security.CallSafely(function()
        local root, warnings = parseXml(xmlstr)
        if loglevel >= 3 then
          for _, warning in ipairs(warnings) do
            log(3, filename .. ': ' .. warning)
          end
        end
        local ctx = {
          addonEnv = addonEnv,
          ignoreVirtual = false,
          intrinsic = false,
          skipObjects = skipObjects,
          useAddonEnv = false,
          useSecureEnv = useSecureEnv,
        }
        loadElement(ctx, root)
      end)
    end

    function loadFile(filename, closureTaint, secondaryFileName)
      filename = path.normalize(filename)
      security.CallSafely(function()
        log(2, 'loading file %s', filename)
        local loadFn
        if filename:sub(-4) == '.lua' then
          loadFn = loadLuaString
        elseif filename:sub(-4) == '.xml' then
          loadFn = loadXml
        else
          error('unknown file type ' .. filename)
        end
        local success, content = pcall(readFile, filename)
        if not success and secondaryFileName then
          success, content = pcall(readFile, secondaryFileName)
        end
        if success then
          loadFn(filename, content, nil, useSecureEnv, closureTaint, addonName, addonEnv)
        else
          log(1, 'skipping missing file %s', filename)
        end
      end)
    end

    return loadFile
  end

  return {
    bindings = bindings,
    forAddon = forAddon,
  }
end
