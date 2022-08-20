local xmlimpls = (function()
  local mixin = require('wowless.util').mixin
  local tree = require('wowapi.data').xml
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

local function loader(api, cfg)
  local rootDir = cfg and cfg.rootDir
  local product = cfg and cfg.product
  assert(product, 'loader requires a product')
  local otherAddonDirs = cfg and cfg.otherAddonDirs or {}

  local lfs = require('lfs')
  local path = require('path')
  local parseXml = require('wowless.xml').newParser()
  local util = require('wowless.util')
  local mixin = util.mixin
  local intrinsics = {}
  local readFile = (function()
    if cfg and cfg.cascproxy and cfg.rootDir then
      local conn = require('wowless.http').connect(cfg.cascproxy)
      local skip = cfg.rootDir:len() + 2
      local prefix = '/product/' .. cfg.rootDir:sub(10)
      return function(f)
        if type(f) == 'string' and f:sub(1, cfg.rootDir:len()) ~= cfg.rootDir then
          return util.readfile(f)
        end
        local fpath = prefix .. (type(f) == 'number' and '/fdid/' .. f or '/name/' .. f:sub(skip):gsub('\\', '/'))
        api.log(2, 'fetching cascproxy %s', fpath)
        local data = conn(fpath)
        if not data then
          return util.readfile(f)
        end
        api.log(2, 'successfully fetched cascproxy %s', fpath)
        if data:sub(1, 3) == '\239\187\191' then
          data = data:sub(4)
        end
        return data
      end
    else
      return util.readfile
    end
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

  local function forAddon(addonName, addonEnv)
    local function loadstr(str, filename, line)
      local pre = line and string.rep('\n', line - 1) or ''
      return assert(loadstring(pre .. str, '@' .. path.normalize(filename):gsub('/', '\\')))
    end

    local function loadLuaString(filename, str, line)
      local before = api.env.ScrollingMessageFrameMixin
      local fn = setfenv(loadstr(str, filename, line), api.env)
      api.CallSafely(function()
        fn(addonName, addonEnv)
      end)
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

    local loadFile

    local function loadXml(filename, xmlstr)
      local dir = path.dirname(filename)

      local function usingContext(ctx)
        local function withContext(update)
          return usingContext(mixin({}, ctx, update))
        end

        local loadElement

        local function loadElements(t, parent)
          for _, v in ipairs(t) do
            loadElement(v, parent)
          end
        end

        local function loadScript(script, obj)
          local fn
          if script.attr['function'] then
            local fnattr = script.attr['function']
            local env = ctx.useAddonEnv and addonEnv or api.env
            fn = function(...)
              assert(env[fnattr], 'unknown script function ' .. fnattr)
              env[fnattr](...)
            end
          elseif script.attr.method then
            local mattr = script.attr.method
            fn = function(x, ...)
              assert(x[mattr], 'unknown script method ' .. mattr)
              x[mattr](x, ...)
            end
          elseif script.text then
            local args = xmlimpls[string.lower(script.type)].tag.script.args or 'self, ...'
            local fnstr = 'return function(' .. args .. ') ' .. script.text .. ' end'
            local env = ctx.useAddonEnv and addonEnv or api.env
            fn = setfenv(loadstr(fnstr, filename, script.line), env)()
          end
          if fn then
            local old = obj:GetScript(script.type)
            if old and script.attr.inherit then
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
            assert(not script.attr.intrinsicorder or ctx.intrinsic, 'intrinsicOrder on non-intrinsic')
            local bindingType = 1
            if script.attr.intrinsicorder == 'precall' then
              bindingType = 0
            elseif script.attr.intrinsicorder == 'postcall' then
              bindingType = 2
            elseif script.attr.intrinsicorder then
              error('invalid intrinsicOrder tag on script')
            elseif ctx.intrinsic then
              bindingType = 0
            end
            api.SetScript(obj, script.type, bindingType, fn)
          end
        end

        local function getColor(e)
          local name = e.attr.name or e.attr.color
          if name then
            return assert(api.env[name], ('unknown color %q'):format(name)):GetRGBA()
          else
            return e.attr.r or 0, e.attr.g or 0, e.attr.b or 0, e.attr.a or 1
          end
        end

        local xmllang = {
          anchor = function(anchor, parent)
            local point = anchor.attr.point
            local relativeTo
            if anchor.attr.relativeto then
              relativeTo = api.ParentSub(anchor.attr.relativeto, parent:GetParent())
            elseif anchor.attr.relativekey then
              local parts = { strsplit('.', anchor.attr.relativekey) }
              if #parts == 1 then
                relativeTo = api.ParentSub(anchor.attr.relativekey, parent:GetParent())
              else
                local obj = parent
                for i = 1, #parts do
                  local p = parts[i]
                  if p == '$parent' or p == '$parentKey' then
                    obj = obj:GetParent()
                  else
                    if not obj[p] then
                      api.log(1, 'invalid relativeKey %q', anchor.attr.relativekey)
                      obj = nil
                      break
                    end
                    obj = obj[p]
                  end
                end
                relativeTo = obj
              end
            else
              relativeTo = api.UserData(parent).parent
            end
            local relativePoint = anchor.attr.relativepoint or point
            local offsetX, offsetY = getXY(anchor.kids[#anchor.kids])
            local x = anchor.attr.x or offsetX
            local y = anchor.attr.y or offsetY
            parent:SetPoint(point, relativeTo, relativePoint, x, y)
          end,
          attribute = function(e, parent)
            -- TODO share code with SetAttribute somehow
            local a = e.attr
            api.UserData(parent).attributes[a.name] = parseTypedValue(a.type, a.value)
          end,
          barcolor = function(e, parent)
            parent:SetStatusBarColor(getColor(e))
          end,
          binding = function(e)
            -- TODO interpret all binding attributes
            if not e.attr.debug then -- TODO support debug bindings
              local fn = 'return function(keystate) ' .. e.text .. ' end'
              api.states.Bindings[e.attr.name] = setfenv(loadstr(fn, filename, e.line), api.env)()
            end
          end,
          color = function(e, parent)
            local r, g, b, a = getColor(e)
            local p = api.UserData(parent)
            if api.InheritsFrom(p.type, 'texture') then
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
          fontfamily = function(e)
            local font = e.kids[1].kids[1]
            return loadElement({
              attr = mixin({}, font.attr, { virtual = true, name = e.attr.name }),
              kids = font.kids,
              type = font.type,
            })
          end,
          fontheight = function(e, parent)
            local name, _, flags = parent:GetFont()
            parent:SetFont(name, e.kids[#e.kids].attr.val, flags)
          end,
          gradient = function(e, parent)
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
              parent:SetGradientAlpha(e.attr.orientation, minR, minG, minB, minA, maxR, maxG, maxB, maxA)
            end
          end,
          highlightcolor = function(e, parent)
            parent:SetHighlightColor(getColor(e))
          end,
          hitrectinsets = function(e, parent)
            parent:SetHitRectInsets(getInsets(e))
          end,
          keyvalue = function(e, parent)
            local a = e.attr
            parent[a.key] = parseTypedValue(a.type, a.value)
          end,
          maskedtexture = function(e, parent)
            parent:GetParent()[e.attr.childkey]:AddMaskTexture(parent)
          end,
          maxresize = function(e, parent)
            parent:SetMaxResize(getXY(e.kids[#e.kids]))
          end,
          minresize = function(e, parent)
            parent:SetMinResize(getXY(e.kids[#e.kids]))
          end,
          modifiedclick = function(e)
            api.states.ModifiedClicks[e.attr.action] = e.attr.default
          end,
          offset = function(e, parent)
            assert(ctx.shadow, 'this should only run on shadow for now')
            parent:SetShadowOffset(getXY(e))
          end,
          origin = function(e, parent)
            parent:SetOrigin(e.attr.point, getXY(e.kids[#e.kids]))
          end,
          pushedtextoffset = function(e, parent)
            parent:SetPushedTextOffset(getXY(e))
          end,
          size = function(e, parent)
            local x, y = getXY(e)
            if x then
              parent:SetWidth(x)
            end
            if y then
              parent:SetHeight(y)
            end
          end,
          texcoords = function(e, parent)
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
          textinsets = function(e, parent)
            parent:SetTextInsets(getInsets(e))
          end,
          viewinsets = function(e, parent)
            parent:SetViewInsets(getInsets(e))
          end,
        }

        local xmlattrlang = {
          hidden = function(obj, value)
            api.UserData(obj).shown = not value
          end,
          mixin = function(obj, value)
            local env = ctx.useAddonEnv and addonEnv or api.env
            for _, m in ipairs(value) do
              mixin(obj, env[m])
            end
          end,
          parent = function(obj, value)
            api.SetParent(obj, api.env[value])
          end,
          parentarray = function(obj, value)
            local p = api.UserData(obj).parent
            if p then
              p[value] = p[value] or {}
              table.insert(p[value], obj)
            end
          end,
          parentkey = function(obj, value)
            local p = api.UserData(obj).parent
            if p then
              p[value] = obj
            end
          end,
          securemixin = function(obj, value)
            local env = ctx.useAddonEnv and addonEnv or api.env
            for _, m in ipairs(value) do
              mixin(obj, env[m])
            end
          end,
          setallpoints = function(obj, value)
            if value and not obj:IsObjectType('texture') then
              obj:SetAllPoints()
            end
          end,
        }

        local function processAttr(attr, obj, v)
          if attr.impl == 'internal' then
            xmlattrlang[attr.name](obj, v)
          elseif attr.impl == 'loadfile' then
            loadFile(path.join(dir, v))
          elseif attr.impl.scope then
            return { [attr.impl.scope] = v }
          elseif attr.impl.method then
            local fn = api.uiobjectTypes[api.UserData(obj).type].metatable.__index[attr.impl.method]
            if type(v) == 'table' then -- stringlist
              fn(obj, unpack(v))
            else
              fn(obj, v)
            end
          elseif attr.impl.field then
            api.UserData(obj)[attr.impl.field] = v
          else
            error('invalid attribute impl for ' .. attr.name)
          end
        end

        local function processAttrs(e, obj, phase)
          local objty = api.UserData(obj).type
          local attrs = (xmlimpls[objty] or intrinsics[objty]).attrs
          for k, v in pairs(e.attr) do
            -- This assumes that uiobject types and xml types are the same "space" of strings.
            local attr = attrs[k]
            if attr and phase == attr.phase then
              processAttr(attr, obj, v)
            end
          end
        end

        local function processKids(e, obj, phase)
          local newctx = withContext({ ignoreVirtual = true })
          for _, kid in ipairs(e.kids) do
            if xmlimpls[string.lower(kid.type)].phase == phase then
              newctx.loadElement(kid, obj)
            end
          end
        end

        local phases = {
          EarlyAttrs = function(e, obj)
            if ctx.layer and obj.SetDrawLayer then
              obj:SetDrawLayer(ctx.layer)
            end
            processAttrs(e, obj, 'early')
          end,
          Attrs = function(e, obj)
            processAttrs(e, obj, 'middle')
            processKids(e, obj, 'middle')
          end,
          Kids = function(e, obj)
            processKids(e, obj, 'late')
            processAttrs(e, obj, 'late')
            -- Implicit setallpoints hack for textures.
            if obj:IsObjectType('texture') and obj:GetNumPoints() == 0 then
              obj:SetAllPoints()
            end
          end,
        }

        local function mkInitPhase(phaseName, e)
          local phase = phases[phaseName]
          return function(obj)
            for _, inh in ipairs(e.attr.inherits or {}) do
              local t = assert(api.templates[string.lower(inh)], 'unknown template ' .. inh)
              t['init' .. phaseName](obj)
            end
            phase(e, obj)
          end
        end

        function loadElement(e, parent)
          if api.IsIntrinsicType(e.type) then
            local newctx = withContext({ intrinsic = not not e.attr.intrinsic })
            local template = {
              initEarlyAttrs = newctx.mkInitPhase('EarlyAttrs', e),
              initAttrs = newctx.mkInitPhase('Attrs', e),
              initKids = newctx.mkInitPhase('Kids', e),
              name = e.attr.name,
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
                inherits = { basetype },
                metatable = { __index = base.metatable.__index },
                name = base.name,
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
                return api.CreateUIObject(e.type, name, parent, ctx.useAddonEnv and addonEnv or nil, { template })
              end
            end
          else
            local impl = xmlimpls[e.type] and xmlimpls[e.type].tag or nil
            local fn = xmllang[e.type]
            if type(impl) == 'table' and impl.script then
              loadScript(e, parent)
            elseif type(impl) == 'table' and impl.scope then
              withContext({ [impl.scope] = true }).loadElements(e.kids, parent)
            elseif type(impl) == 'table' then
              local elt = impl.argument == 'lastkid' and e.kids[#e.kids] or mixin({}, e, { type = impl.argument })
              local obj = loadElement(elt, parent)
              -- TODO find if this if needs to be broader to everything here including kids
              if api.InheritsFrom(api.UserData(parent).type, impl.parenttype:lower()) then
                api.uiobjectTypes[impl.parenttype:lower()].metatable.__index[impl.parentmethod](parent, obj)
              end
            elseif impl == 'transparent' or impl == 'loadstring' then
              local ctxmix = {}
              for k, v in pairs(e.attr) do
                local attr = xmlimpls[e.type].attrs[k]
                if attr then
                  mixin(ctxmix, processAttr(attr, nil, v))
                end
              end
              withContext(ctxmix).loadElements(e.kids, parent)
              if impl == 'loadstring' and e.text then
                loadLuaString(filename, e.text, e.line)
              end
            elseif fn then
              fn(e, parent)
            else
              error('unimplemented xml tag ' .. e.type)
            end
          end
        end

        return {
          loadElement = loadElement,
          loadElements = loadElements,
          mkInitPhase = mkInitPhase,
        }
      end

      return api.CallSafely(function()
        local root = parseXml(xmlstr)
        local ctx = {
          ignoreVirtual = false,
          intrinsic = false,
          useAddonEnv = false,
        }
        usingContext(ctx).loadElement(root)
      end)
    end

    function loadFile(filename)
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
        local success, content = pcall(function()
          return readFile(filename)
        end)
        if success then
          loadFn(filename, content)
        else
          api.log(1, 'skipping missing file %s', filename)
        end
      end)
    end

    return {
      loadFile = loadFile,
      loadXml = loadXml,
    }
  end

  local productToFlavor = (function()
    local t = {}
    for k, v in pairs(require('wowapi.data').builds) do
      t[k] = v.flavor
    end
    return t
  end)()

  local alternateVersionNames = {
    Mainline = 'Mainline',
    TBC = 'BCC',
    Vanilla = 'Classic',
    Wrath = 'WOTLKC',
  }

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
    local version = productToFlavor[product]
    local toTry = {
      '_' .. version,
      '-' .. version,
      '_' .. alternateVersionNames[version],
      '-' .. alternateVersionNames[version],
      '',
    }
    for _, try in ipairs(toTry) do
      local tocFile = path.join(tocDir, base .. try .. '.toc')
      local success, content = pcall(function()
        return readFile(tocFile)
      end)
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
  end

  api.states.CVars.portal = require('wowapi.data').builds[product].ptr and 'test' or ''

  local wdb = require('wowless.db')

  local function db2rows(name)
    local data = readFile(cfg.cascproxy and wdb.fdid(name) or path.join(rootDir, 'db2', name .. '.db2'))
    return wdb.rows(product, name, data)
  end

  local addonData = assert(api.states.Addons)

  local function initAddons()
    local function maybeAdd(dir)
      local name = path.basename(dir)
      if not addonData[name] then
        local addon = resolveTocDir(dir)
        if addon then
          addon.name = name
          addonData[name] = addon
          table.insert(addonData, addon)
        end
      end
    end
    local function maybeAddAll(dir)
      local attrs = lfs.attributes(dir)
      if attrs and attrs.mode == 'directory' then
        for d in lfs.dir(dir) do
          if d ~= '.' and d ~= '..' then
            maybeAdd(path.join(dir, d))
          end
        end
      end
    end
    if rootDir then
      for row in db2rows('ManifestInterfaceTOCData') do
        maybeAdd(path.join(rootDir, path.dirname(row.FilePath)))
      end
    end
    for _, d in ipairs(otherAddonDirs) do
      maybeAddAll(path.dirname(d))
    end
  end

  local depAttrs = {
    'RequiredDep',
    'RequiredDeps',
    'Dependencies',
  }

  local function doLoadAddon(addonName)
    local toc = addonData[addonName]
    if not toc then
      error('unknown addon ' .. addonName)
    end
    if not toc.loaded and toc.attrs.AllowLoad ~= 'Glue' then
      api.log(1, 'loading addon dependencies for %s', addonName)
      for _, attr in ipairs(depAttrs) do
        for dep in string.gmatch(toc.attrs[attr] or '', '[^, ]+') do
          doLoadAddon(dep)
        end
      end
      api.log(1, 'loading addon files for %s', addonName)
      local context = forAddon(addonName, {})
      for _, file in ipairs(toc.files) do
        context.loadFile(file)
      end
      context.loadFile(('out/%s/SavedVariables/%s.lua'):format(product, addonName))
      toc.loaded = true
      api.log(1, 'done loading %s', addonName)
      api.SendEvent('ADDON_LOADED', addonName)
    end
  end

  local function loadAddon(addonName)
    local success = pcall(function()
      doLoadAddon(addonName)
    end)
    if success then
      return true
    else
      return false, 'LOAD_FAILED'
    end
  end

  local function loadFrameXml()
    local context = forAddon()
    for row in db2rows('GlobalStrings') do
      api.env[row.BaseTag] = row.TagText_lang
    end
    for _, file in ipairs(resolveTocDir(path.join(rootDir, 'Interface', 'FrameXML')).files) do
      context.loadFile(file)
    end
    local frameXmlBindingsDirMap = {
      Mainline = 'Interface',
      TBC = 'Interface_TBC',
      Vanilla = 'Interface_Vanilla',
      Wrath = 'Interface_Wrath',
    }
    context.loadFile(path.join(rootDir, frameXmlBindingsDirMap[productToFlavor[product]], 'FrameXML', 'Bindings.xml'))
    local blizzardAddons = {}
    for name, toc in pairs(addonData) do
      if type(name) == 'string' and name:sub(1, 9) == 'Blizzard_' and toc.attrs.LoadOnDemand ~= '1' then
        table.insert(blizzardAddons, name)
      end
    end
    table.sort(blizzardAddons)
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
              table.insert(t, type(val) == 'table' and w(val) or tostring(val))
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
    db2rows = db2rows,
    initAddons = initAddons,
    loadAddon = loadAddon,
    loadFrameXml = loadFrameXml,
    loadXml = forAddon().loadXml,
    product = product,
    saveAllVariables = saveAllVariables,
  }
end

return {
  loader = loader,
}
