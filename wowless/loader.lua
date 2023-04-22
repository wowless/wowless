local function loader(api, cfg)
  local rootDir = cfg and cfg.rootDir
  local product = cfg and cfg.product
  assert(product, 'loader requires a product')
  local otherAddonDirs = cfg and cfg.otherAddonDirs or {}
  local datalua = require('build.products.' .. product .. '.data')

  local path = require('path')
  local parseXml = require('wowless.xml').newParser(product)
  local util = require('wowless.util')
  local mixin = util.mixin
  local intrinsics = {}
  local readFile = util.readfile

  local xmlimpls = (function()
    local tree = datalua.xml
    local newtree = {}
    for k, v in pairs(tree) do
      local attrs = mixin({}, v.attributes)
      local t = v
      while t.extends do
        t = tree[t.extends]
        mixin(attrs, t.attributes)
      end
      local aimpls = {}
      for n, a in pairs(attrs) do
        if a.impl then
          aimpls[n] = {
            impl = a.impl,
            name = n,
            phase = a.phase or 'middle',
          }
        end
      end
      local tag = v.impl
      if type(tag) == 'table' and tag.argument == 'self' then
        local arg = v.extends
        while tree[arg].virtual do
          arg = tree[arg].extends
        end
        tag.argument = arg:lower()
      end
      newtree[k:lower()] = {
        attrs = aimpls,
        phase = v.phase or 'middle',
        tag = tag,
      }
    end
    return newtree
  end)()

  local function parseTypedValue(type, value)
    type = type and string.lower(type) or nil
    if type == 'number' then
      return tonumber(value)
    elseif type == 'global' then
      local t = api.env
      for part in value:gmatch('[^.]+') do
        t = t[part]
      end
      return t
    elseif type == 'boolean' or type == 'bool' then
      return (value == 'true')
    elseif type == 'string' or type == nil then
      local n = tonumber(value)
      return n ~= nil and n or value
    else
      error('invalid keyvalue/attribute type ' .. type)
    end
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
    local pre = line and string.rep('\n', line - 1) or ''
    return assert(loadstring(pre .. str, '@' .. path.normalize(filename):gsub('/', '\\')))
  end

  local function getColor(e)
    local name = e.attr.name or e.attr.color
    if name then
      return assert(api.env[name], ('unknown color %q'):format(name)):GetRGBA()
    else
      return e.attr.r or 0, e.attr.g or 0, e.attr.b or 0, e.attr.a or 1
    end
  end

  local function loadLuaString(filename, str, line, closureTaint, ...)
    local before = api.env.ScrollingMessageFrameMixin
    local fn = setfenv(loadstr(str, filename, line), api.env)
    api.CallSafely(function(...)
      debug.setnewclosuretaint(closureTaint)
      fn(...)
    end, ...)
    debug.setnewclosuretaint(nil)
    -- Super hacky hack to hook ScrollingMessageFrameMixin.AddMessage
    local after = api.env.ScrollingMessageFrameMixin
    if after and not before then
      local f = after.AddMessage
      after.AddMessage = function(self, text, ...)
        api.log(1, '[%s] %s', self:GetDebugName(), tostring(text))
        f(self, text, ...)
      end
    end
  end

  local scriptCache = {}

  local function loadScript(script, obj, env, filename, intrinsic)
    local fn
    if script.attr['function'] then
      local fnattr = script.attr['function']
      fn = env[fnattr]
      if not fn then
        api.log(2, 'unknown script function %q on %q', fnattr, obj:GetDebugName())
      end
    elseif script.attr.method then
      local mattr = script.attr.method
      fn = obj[mattr]
      if not fn then
        api.log(2, 'unknown script method %q on %q', mattr, obj:GetDebugName())
      end
    elseif scriptCache[script] then
      fn = scriptCache[script]
    elseif script.text then
      local args = xmlimpls[string.lower(script.type)].tag.script.args or 'self, ...'
      local fnstr = 'return function(' .. args .. ') ' .. script.text .. ' end'
      fn = setfenv(loadstr(fnstr, filename, script.line), env)()
      scriptCache[script] = fn
    end
    if api.UserData(obj).scripts then
      local old = api.UserData(obj).scripts[1][script.type:lower()]
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
      api.SetScript(api.UserData(obj), script.type, bindingType, fn)
    end
  end

  local function navigate(obj, key)
    for _, p in ipairs({ strsplit('.', key) }) do
      if p == '$parent' or p == '$parentKey' then
        obj = obj:GetParent()
      else
        if not obj[p] then
          api.log(1, 'invalid relativeKey %q', key)
          return nil
        end
        obj = obj[p]
      end
    end
    return obj
  end

  local xmllang = {
    anchor = function(_, anchor, parent)
      local point = anchor.attr.point
      local relativeTo
      if anchor.attr.relativeto then
        local pp = api.UserData(parent).parent
        relativeTo = api.ParentSub(anchor.attr.relativeto, pp and api.UserData(pp))
      elseif anchor.attr.relativekey then
        relativeTo = navigate(parent, anchor.attr.relativekey)
      else
        relativeTo = api.UserData(parent).parent
      end
      local relativePoint = anchor.attr.relativepoint or point
      local offsetX, offsetY = getXY(anchor.kids[#anchor.kids])
      local x = anchor.attr.x or offsetX
      local y = anchor.attr.y or offsetY
      parent:SetPoint(point, relativeTo, relativePoint, x, y)
    end,
    attribute = function(_, e, parent)
      -- TODO share code with SetAttribute somehow
      local a = e.attr
      api.UserData(parent).attributes[a.name] = parseTypedValue(a.type, a.value)
    end,
    barcolor = function(_, e, parent)
      parent:SetStatusBarColor(getColor(e))
    end,
    color = function(ctx, e, parent)
      local r, g, b, a = getColor(e)
      local p = api.UserData(parent)
      if api.InheritsFrom(p.type, 'texturebase') then
        parent:SetColorTexture(r, g, b, a)
      elseif api.InheritsFrom(p.type, 'fontinstance') then
        if ctx.shadow then
          parent:SetShadowColor(r, g, b, a)
        else
          parent:SetTextColor(r, g, b, a)
        end
      else
        error('cannot apply color to ' .. p.type)
      end
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
        if parent.SetGradientAlpha then
          parent:SetGradientAlpha(e.attr.orientation, minR, minG, minB, minA, maxR, maxG, maxB, maxA)
        else
          local min = { r = minR, g = minG, b = minB, a = minA }
          local max = { r = maxR, g = maxG, b = maxB, a = maxA }
          parent:SetGradient(e.attr.orientation, min, max)
        end
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
      parent[a.key] = parseTypedValue(a.type, a.value)
    end,
    maskedtexture = function(_, e, parent)
      local t = navigate(parent:GetParent(), e.attr.childkey)
      if t then
        t:AddMaskTexture(parent)
      else
        api.log(1, 'cannot find maskedtexture childkey ' .. e.attr.childkey)
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
    modifiedclick = function(_, e)
      api.states.ModifiedClicks[e.attr.action] = e.attr.default
    end,
    offset = function(ctx, e, parent)
      assert(ctx.shadow, 'this should only run on shadow for now')
      parent:SetShadowOffset(getXY(e))
    end,
    origin = function(_, e, parent)
      parent:SetOrigin(e.attr.point, getXY(e.kids[#e.kids]))
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

  local function forAddon(addonName, addonEnv)
    local loadFile

    local xmlattrlang = {
      hidden = function(_, obj, value)
        api.UserData(obj).shown = not value
      end,
      mixin = function(ctx, obj, value)
        local env = ctx.useAddonEnv and addonEnv or api.env
        for _, m in ipairs(value) do
          mixin(obj, env[m])
        end
      end,
      parent = function(_, obj, value)
        local parent = api.env[value]
        api.SetParent(api.UserData(obj), parent and api.UserData(parent))
      end,
      parentarray = function(_, obj, value)
        local p = api.UserData(obj).parent
        if p then
          p[value] = p[value] or {}
          table.insert(p[value], obj)
        end
      end,
      parentkey = function(_, obj, value)
        local p = api.UserData(obj).parent
        if p then
          p[value] = obj
        end
      end,
      securemixin = function(ctx, obj, value)
        local env = ctx.useAddonEnv and addonEnv or api.env
        for _, m in ipairs(value) do
          mixin(obj, env[m])
        end
      end,
      setallpoints = function(_, obj, value)
        if value and not obj:IsObjectType('texturebase') then
          obj:SetAllPoints()
        end
      end,
    }

    local function loadXml(filename, xmlstr)
      local dir = path.dirname(filename)

      local function processAttr(ctx, attr, obj, v)
        if attr.impl == 'internal' then
          xmlattrlang[attr.name](ctx, obj, v)
        elseif attr.impl == 'loadfile' then
          loadFile(path.join(dir, v))
        elseif attr.impl.scope then
          return { [attr.impl.scope] = v }
        elseif attr.impl.method then
          local ud = api.UserData(obj)
          local fn = ud[attr.impl.method]
          assert(fn, ('missing method %q on object type %q'):format(attr.impl.method, api.UserData(obj).type))
          if type(v) == 'table' then -- stringlist
            fn(ud, unpack(v))
          else
            fn(ud, v)
          end
        elseif attr.impl.field then
          api.UserData(obj)[attr.impl.field] = v
        else
          error('invalid attribute impl for ' .. attr.name)
        end
      end

      local function processAttrs(ctx, e, obj, phase)
        local objty = api.UserData(obj).type
        local attrs = (xmlimpls[objty] or intrinsics[objty]).attrs
        for k, v in pairs(e.attr) do
          -- This assumes that uiobject types and xml types are the same "space" of strings.
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
          -- Implicit setallpoints hack for textures.
          if obj:IsObjectType('texture') and obj:GetNumPoints() == 0 then
            obj:SetAllPoints()
          end
        end,
      }

      local function mkInitPhase(ctx, phaseName, e)
        local phase = phases[phaseName]
        return function(obj)
          for _, inh in ipairs(e.attr.inherits or {}) do
            local t = assert(api.templates[string.lower(inh)], 'unknown template ' .. inh)
            t['init' .. phaseName](obj)
          end
          phase(ctx, e, obj)
        end
      end

      function loadElement(ctx, e, parent)
        if api.IsIntrinsicType(e.type) then
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
          if e.attr.intrinsic then
            assert(virtual ~= false, 'intrinsics cannot be explicitly non-virtual: ' .. e.type)
            assert(e.attr.name, 'cannot create anonymous intrinsic')
            local name = string.lower(e.attr.name)
            if api.uiobjectTypes[name] then
              api.log(1, 'overwriting intrinsic ' .. e.attr.name)
            end
            api.log(3, 'creating intrinsic ' .. e.attr.name)
            local basetype = string.lower(e.type)
            local base = api.uiobjectTypes[basetype]
            api.uiobjectTypes[name] = {
              constructor = base.constructor,
              hostMT = base.hostMT,
              isa = mixin({ [name] = true }, base.isa),
              name = base.name,
              sandboxMT = base.sandboxMT,
              template = template,
            }
            intrinsics[name] = xmlimpls[basetype]
          else
            local ltype = string.lower(e.type)
            if (ltype == 'font' and e.attr.name) or (virtual and not ctx.ignoreVirtual) then
              assert(e.attr.name, 'cannot create anonymous template')
              local name = string.lower(e.attr.name)
              if api.templates[name] then
                api.log(1, 'overwriting template ' .. e.attr.name)
              end
              api.log(3, 'creating template ' .. e.attr.name)
              api.templates[name] = template
            end
            if ltype == 'font' or (not virtual or ctx.ignoreVirtual) then
              local name = e.attr.name
              if virtual and ctx.ignoreVirtual then
                api.log(1, 'ignoring virtual on ' .. tostring(name))
              end
              return api.CreateUIObject(
                e.type,
                name,
                parent and api.UserData(parent),
                ctx.useAddonEnv and addonEnv or nil,
                { template }
              )
            end
          end
        else
          local impl = xmlimpls[e.type] and xmlimpls[e.type].tag or nil
          local fn = xmllang[e.type]
          if type(impl) == 'table' and impl.script then
            local env = ctx.useAddonEnv and addonEnv or api.env
            loadScript(e, parent, env, filename, ctx.intrinsic)
          elseif type(impl) == 'table' and impl.scope then
            loadElements(mixin({}, ctx, { [impl.scope] = true }), e.kids, parent)
          elseif type(impl) == 'table' then
            local elt = impl.argument == 'lastkid' and e.kids[#e.kids] or mixin({}, e, { type = impl.argument })
            local obj = loadElement(ctx, elt, parent)
            local up = api.UserData(parent)
            -- TODO find if this if needs to be broader to everything here including kids
            if up:IsObjectType(impl.parenttype) then
              up[impl.parentmethod](up, obj)
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
              loadLuaString(filename, e.text, e.line)
            end
          elseif e.type == 'binding' then -- TODO do this another way
            -- TODO interpret all binding attributes
            if not e.attr.debug then -- TODO support debug bindings
              local bfn = 'return function(keystate) ' .. e.text .. ' end'
              api.states.Bindings[e.attr.name] = setfenv(loadstr(bfn, filename, e.line), api.env)()
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

      return api.CallSafely(function()
        local root, warnings = parseXml(xmlstr)
        for _, warning in ipairs(warnings) do
          api.log(3, filename .. ': ' .. warning)
        end
        local ctx = {
          ignoreVirtual = false,
          intrinsic = false,
          useAddonEnv = false,
        }
        loadElement(ctx, root)
      end)
    end

    function loadFile(filename, closureTaint)
      filename = path.normalize(filename)
      api.CallSafely(function()
        api.log(2, 'loading file %s', filename)
        local loadFn
        if filename:sub(-4) == '.lua' then
          loadFn = loadLuaString
        elseif filename:sub(-4) == '.xml' then
          loadFn = loadXml
        else
          error('unknown file type ' .. filename)
        end
        local success, content = pcall(readFile, filename)
        if success then
          -- TODO only pass SecureCapsuleGet on signed addons
          loadFn(filename, content, nil, closureTaint, addonName, addonEnv, api.env.SecureCapsuleGet)
        else
          api.log(1, 'skipping missing file %s', filename)
        end
      end)
    end

    return loadFile
  end

  local build = datalua.build
  local flavors = require('build.flavors')

  local function parseToc(tocFile, content)
    local attrs = {}
    local files = {}
    local dir = path.dirname(tocFile)
    for line in content:gmatch('[^\r\n]+') do
      line = line:match('^%s*(.-)%s*$')
      if line:sub(1, 3) == '## ' then
        local key, value = line:match('([^:]+): (.*)', 4)
        if key then
          attrs[key] = value
        end
      elseif line ~= '' and line:sub(1, 1) ~= '#' then
        table.insert(files, path.join(dir, line))
      end
    end
    return { attrs = attrs, files = files }
  end

  local function resolveTocDir(tocDir)
    api.log(1, 'resolving %s', tocDir)
    local base = path.basename(tocDir)
    local flavor = build.flavor
    local toTry = {
      '_' .. flavor,
      '-' .. flavor,
      '_' .. flavors[flavor].alternate,
      '-' .. flavors[flavor].alternate,
      '',
    }
    for _, try in ipairs(toTry) do
      local tocFile = path.join(tocDir, base .. try .. '.toc')
      local success, content = pcall(readFile, tocFile)
      if success then
        api.log(1, 'using toc %s', tocFile)
        return parseToc(tocFile, content)
      end
    end
    api.log(1, 'no valid toc for %s', tocDir)
    return nil
  end

  do
    local time = assert(api.states.Time)
    time.timers = require('minheap'):new()
    time.timers:push(math.huge, function()
      error('fell off the end of time')
    end)

    local cancelled = setmetatable({}, { __mode = 'k' })
    local tickerMT = {
      __index = {
        Cancel = debug.newcfunction(function(self)
          cancelled[self] = true
        end),
        IsCancelled = debug.newcfunction(function(self)
          return cancelled[self]
        end),
      },
      __metatable = false,
    }
    time.newTicker = function(seconds, callback, iterations)
      local p = newproxy(true)
      mixin(getmetatable(p), tickerMT)
      cancelled[p] = false
      local count = 0
      local function cb()
        if not cancelled[p] and count < iterations then
          callback()
          count = count + 1
          time.timers:push(time.stamp + seconds, cb)
        end
      end
      time.timers:push(time.stamp + seconds, cb)
      return p
    end
  end

  api.states.CVars.portal = build.ptr and 'test' or ''

  local sqlitedb = (function()
    local dbfile = ('build/products/%s/%s.sqlite3'):format(product, rootDir and 'data' or 'schema')
    return require('lsqlite3').open(dbfile)
  end)()

  local addonData = assert(api.states.Addons)

  local function initAddons()
    local lfs = require('lfs')
    local function maybeAdd(dir, fdid)
      local name = path.basename(dir)
      if not addonData[name] then
        local addon = resolveTocDir(dir)
        if addon then
          addon.name = name
          addon.fdid = fdid
          addonData[name:lower()] = addon
          table.insert(addonData, addon)
        end
      end
    end
    local function isdir(d)
      return lfs.attributes(d, 'mode') == 'directory'
    end
    local function maybeAddAll(dir)
      if isdir(dir) then
        for d in lfs.dir(dir) do
          if d ~= '.' and d ~= '..' then
            local dd = path.join(dir, d)
            if isdir(dd) then
              maybeAdd(dd)
            end
          end
        end
      end
    end
    if rootDir then
      for filepath, fdid in sqlitedb:urows('SELECT FilePath, ID FROM ManifestInterfaceTOCData') do
        maybeAdd(path.join(rootDir, path.dirname(filepath)), fdid)
      end
    end
    for _, d in ipairs(otherAddonDirs) do
      local dir = path.dirname(d)
      maybeAddAll(dir == '' and '.' or dir)
    end
  end

  local depAttrs = {
    'RequiredDep',
    'RequiredDeps',
    'Dependencies',
  }

  local function doLoadAddon(addonName)
    local toc = addonData[addonName:lower()]
    if not toc then
      error('unknown addon ' .. addonName)
    end
    addonName = toc.name
    if not toc.loaded and toc.attrs.AllowLoad ~= 'Glue' then
      api.log(1, 'loading addon dependencies for %s', addonName)
      for _, attr in ipairs(depAttrs) do
        for dep in string.gmatch(toc.attrs[attr] or '', '[^, ]+') do
          doLoadAddon(dep)
        end
      end
      api.log(1, 'loading addon files for %s', addonName)
      local loadFile = forAddon(addonName, {})
      for _, file in ipairs(toc.files) do
        loadFile(file)
      end
      loadFile(('out/%s/SavedVariables/%s.lua'):format(product, addonName), toc.fdid and 'SavedVariables' or nil)
      toc.loaded = true
      api.log(1, 'done loading %s', addonName)
      api.SendEvent('ADDON_LOADED', addonName)
    end
  end

  local function loadAddon(addonName)
    local success, msg = pcall(doLoadAddon, addonName)
    if success then
      return true
    else
      api.log(1, 'loading %s failed: %s', addonName, tostring(msg))
      return false, 'LOAD_FAILED'
    end
  end

  local function loadFrameXml()
    local loadFile = forAddon()
    for tag, text in sqlitedb:urows('SELECT BaseTag, TagText_lang FROM GlobalStrings') do
      api.env[tag] = text
    end
    for _, file in ipairs(resolveTocDir(path.join(rootDir, 'Interface', 'FrameXML')).files) do
      loadFile(file)
    end
    loadFile(path.join(rootDir, flavors[build.flavor].dir, 'FrameXML', 'Bindings.xml'))
    local blizzardAddons = {}
    for name, toc in pairs(addonData) do
      if type(name) == 'string' and toc.fdid and toc.attrs.LoadOnDemand ~= '1' then
        table.insert(blizzardAddons, name)
      end
    end
    table.sort(blizzardAddons, function(a, b)
      return addonData[a].fdid < addonData[b].fdid
    end)
    for _, name in ipairs(blizzardAddons) do
      loadAddon(name)
    end
  end

  local function saveAllVariables()
    local w = require('pl.pretty').write
    for _, v in pairs(addonData) do
      if v.loaded then
        local t = {}
        for _, attr in ipairs({ 'SavedVariables', 'SavedVariablesPerCharacter' }) do
          for var in (v.attrs[attr] or ''):gmatch('[^, ]+') do
            local val = api.env[var]
            if val ~= nil then
              table.insert(t, var)
              table.insert(t, ' = ')
              table.insert(t, type(val) == 'table' and w(val, '  ', true) or tostring(val))
              table.insert(t, '\n')
            end
          end
        end
        if next(t) then
          local fn = ('out/%s/SavedVariables/%s.lua'):format(product, v.name)
          assert(require('pl.dir').makepath(path.dirname(fn)))
          assert(require('pl.file').write(fn, table.concat(t, '')))
        end
      end
    end
  end

  return {
    initAddons = initAddons,
    loadAddon = loadAddon,
    loadFrameXml = loadFrameXml,
    saveAllVariables = saveAllVariables,
    sqlitedb = sqlitedb,
  }
end

return {
  loader = loader,
}
