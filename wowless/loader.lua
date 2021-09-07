local function loader(api, cfg)
  local rootDir = cfg and cfg.rootDir
  local version = cfg and cfg.version
  local otherAddonDirs = cfg and cfg.otherAddonDirs or {}

  local path = require('path')
  local xml = require('wowless.xml')
  local util = require('wowless.util')
  local readFile, mixin = util.readfile, util.mixin

  local function parseTypedValue(type, value)
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

  local function forAddon(addonName, addonEnv)

    local function loadLuaString(filename, str)
      local fn = setfenv(assert(loadstring(str, path.basename(filename))), api.env)
      api.CallSafely(function() fn(addonName, addonEnv) end)
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

        local xmllang = {
          anchors = function(e, parent)
            for _, anchor in ipairs(e.anchor) do
              local point = anchor.point
              local relativeTo
              if anchor.relativeto then
                relativeTo = api.ParentSub(anchor.relativeto, parent:GetParent())
              elseif anchor.relativekey then
                local parts = {util.strsplit('.', anchor.relativekey)}
                if #parts == 1 then
                  relativeTo = api.ParentSub(anchor.relativekey, parent:GetParent())
                else
                  local obj = parent
                  for i = 1, #parts do
                    local p = parts[i]
                    if p == '$parent' then
                      obj = obj:GetParent()
                    else
                      if not obj[p] then
                        api.log(1, 'invalid relativeKey %q', anchor.relativekey)
                        obj = nil
                        break
                      end
                      obj = obj[p]
                    end
                  end
                  relativeTo = obj
                end
              end
              local relativePoint = anchor.relativepoint
              local x = anchor.x or (anchor.offset and anchor.offset.x) or nil
              local y = anchor.y or (anchor.offset and anchor.offset.y) or nil
              if not relativeTo and not relativePoint then
                parent:SetPoint(point, x, y)
              else
                parent:SetPoint(point, relativeTo, relativePoint, x, y)
              end
            end
          end,
          animations = function(e, parent)
            local groups = api.UserData(parent).animationGroups
            for _, g in ipairs(e.groups) do
              -- Put all the actual animations in a separate element.
              -- This way we can attach them to the group later.
              local animset = {
                anims = {},
                type = 'animset',
              }
              local newkids = { animset }
              for _, k in ipairs(g.kids) do
                table.insert(k.type == 'scripts' and newkids or animset.anims, k)
              end
              local gg = {
                attr = g.attr,
                kids = newkids,
                type = 'animationgroup',
              }
              table.insert(groups, loadElement(gg, parent))
            end
          end,
          animset = function(e, parent)
            local anims = api.UserData(parent).animations
            for _, anim in ipairs(e.anims) do
              table.insert(anims, loadElement(anim, parent))
            end
          end,
          attributes = function(e, parent)
            -- TODO share code with SetAttribute somehow
            local attrs = api.UserData(parent).attributes
            for _, attr in ipairs(e.entries) do
              attrs[attr.name] = parseTypedValue(attr.luatype, attr.value)
            end
          end,
          bartexture = function(e, parent)
            parent:SetStatusBarTexture(loadElement(mixin({}, e, { type = 'texture' }), parent))
          end,
          blingtexture = function(e, parent)
            parent:SetBlingTexture(loadElement(mixin({}, e, { type = 'texture' }), parent))
          end,
          buttontext = function(e, parent)
            return loadElement(mixin({}, e, { type = 'fontstring' }), parent)
          end,
          checkedtexture = function(e, parent)
            -- TODO generalize to all of these
            if parent.SetCheckedTexture then
              parent:SetCheckedTexture(loadElement(mixin({}, e, { type = 'texture' }), parent))
            end
          end,
          disabledcheckedtexture = function(e, parent)
            parent:SetDisabledCheckedTexture(loadElement(mixin({}, e, { type = 'texture' }), parent))
          end,
          disabledfont = function(e, parent)
            parent:SetDisabledFontObject(loadElement(mixin({}, e, { type = 'font' }), parent))
          end,
          disabledtexture = function(e, parent)
            parent:SetDisabledTexture(loadElement(mixin({}, e, { type = 'texture' }), parent))
          end,
          edgetexture = function(e, parent)
            parent:SetEdgeTexture(loadElement(mixin({}, e, { type = 'texture' }), parent))
          end,
          fontfamily = function(e)
            local font = e.members[1].font
            return loadElement({
              attr = mixin(font.attr, { virtual = true, name = e.name }),
              kids = font.kids,
              type = font.type,
            })
          end,
          frames = function(e, parent)
            loadElements(e.frames, parent)
          end,
          highlightfont = function(e, parent)
            parent:SetHighlightFontObject(loadElement(mixin({}, e, { type = 'font' }), parent))
          end,
          highlighttexture = function(e, parent)
            parent:SetHighlightTexture(loadElement(mixin({}, e, { type = 'texture' }), parent))
          end,
          include = function(e)
            loadFile(path.join(dir, e.file))
          end,
          keyvalues = function(e, parent)
            for _, kv in ipairs(e.entries) do
              parent[kv.key] = parseTypedValue(kv.luatype, kv.value)
            end
          end,
          layers = function(e, parent)
            for _, layer in ipairs(e.layers) do
              loadElements(layer.kids, parent)
            end
          end,
          normalfont = function(e, parent)
            parent:SetNormalFontObject(loadElement(mixin({}, e, { type = 'font' }), parent))
          end,
          normaltext = function(e, parent)
            loadElement(mixin({}, e, { type = 'fontstring' }), parent)
          end,
          normaltexture = function(e, parent)
            if parent.SetNormalTexture then
              parent:SetNormalTexture(loadElement(mixin({}, e, { type = 'texture' }), parent))
            end
          end,
          pushedtexture = function(e, parent)
            if parent.SetPushedTexture then
              parent:SetPushedTexture(loadElement(mixin({}, e, { type = 'texture' }), parent))
            end
          end,
          scopedmodifier = function(e, parent)
            withContext({ useAddonEnv = e.attr.scriptsusegivenenv }).loadElements(e.kids, parent)
          end,
          script = function(e)
            if e.file then
              assert(not e.text)
              loadFile(path.join(dir, e.file))
            else
              assert(e.text)
              loadLuaString(filename, e.text)
            end
          end,
          scripts = function(e, parent)
            local obj = parent
            for _, script in ipairs(e.kids) do
              local fn
              if script.func then
                local fnattr = script.func
                local env = ctx.useAddonEnv and addonEnv or api.env
                fn = function(...)
                  assert(env[fnattr], 'unknown script function ' .. fnattr)
                  env[fnattr](...)
                end
              elseif script.method then
                local mattr = script.method
                fn = function(x, ...)
                  assert(x[mattr], 'unknown script method ' .. mattr)
                  x[mattr](x, ...)
                end
              elseif script.text then
                local argTable = {
                  onattributechanged = 'self, name, value',
                  onclick = 'self, button, down',
                  onenter = 'self, motion',
                  onevent = 'self, event, ...',
                  onleave = 'self, motion',
                  onupdate = 'self, elapsed',
                  postclick = 'self, button, down',
                  preclick = 'self, button, down',
                }
                local args = argTable[string.lower(script.type)] or 'self, ...'
                local fnstr = 'return function(' .. args .. ')\n' .. script.text .. '\nend'
                fn = setfenv(assert(loadstring(fnstr, path.basename(filename)))(), api.env)
              end
              if fn then
                local old = obj:GetScript(script.type)
                if old and script.inherit then
                  local bfn = fn
                  if script.inherit == 'prepend' then
                    fn = function(...) bfn(...) old(...) end
                  elseif script.inherit == 'append' then
                    fn = function(...) old(...) bfn(...) end
                  else
                    error('invalid inherit tag on script')
                  end
                end
                assert(not script.intrinsicorder or parent.__intrinsicHack, 'intrinsicOrder on non-intrinsic')
                local bindingType = 1
                if script.intrinsicorder == 'precall' then
                  bindingType = 0
                elseif script.intrinsicorder == 'postcall' then
                  bindingType = 2
                elseif script.intrinsicorder then
                  error('invalid intrinsicOrder tag on script')
                elseif parent.__intrinsicHack then
                  bindingType = 0
                end
                api.SetScript(obj, script.type, bindingType, fn)
              end
            end
          end,
          scrollchild = function(e, parent)
            parent:SetScrollChild(loadElement(e.frame, parent))
          end,
          size = function(e, parent)
            local x = e.x or (e.dim and e.dim.x) or nil
            local y = e.y or (e.dim and e.dim.y) or nil
            if x then
              parent:SetWidth(x)
            end
            if y then
              parent:SetHeight(y)
            end
          end,
          swipetexture = function(e, parent)
            parent:SetSwipeTexture(loadElement(mixin({}, e, { type = 'texture' }), parent))
          end,
          thumbtexture = function(e, parent)
            parent:SetThumbTexture(loadElement(mixin({}, e, { type = 'texture' }), parent))
          end,
        }

        local xmlattrlang = {
          checked = function(obj, value)
            obj:SetChecked(value)
          end,
          hidden = function(obj, value)
            local ud = api.UserData(obj)
            ud.shown = not value
            ud.visible = ud.shown and (not ud.parent or api.UserData(ud.parent).visible)
          end,
          id = function(obj, value)
            obj:SetID(value)
          end,
          parent = function(obj, value)
            api.log(3, 'setting parent to ' .. value)
            api.SetParent(obj, api.env[value])
            local ud = api.UserData(obj)
            ud.visible = ud.shown and (not ud.parent or api.UserData(ud.parent).visible)
          end,
          parentarray = function(obj, value)
            api.log(3, 'attaching to array ' .. value)
            local p = obj:GetParent()
            p[value] = p[value] or {}
            table.insert(p[value], obj)
          end,
          parentkey = function(obj, value)
            api.log(3, 'attaching ' .. value)
            local parent = obj:GetParent()
            if parent then
              parent[value] = obj
            end
          end,
          protected = function(obj, value)
            local ud = api.UserData(obj)
            ud.explicitlyProtected = value
            ud.protected = value
          end,
        }

        local function initKidsMaybeFrames(e, obj, framesFlag)
          local frameykids = {
            frames = true,
            highlighttexture = true,
            layers = true,
          }
          local newctx = withContext({ ignoreVirtual = true })
          for _, kid in ipairs(e.kids) do
            if not not frameykids[string.lower(kid.type)] == framesFlag then
              newctx.loadElement(kid, obj)
            end
          end
        end

        local function mkInitAttrsNotRecursive(e)
          return function(obj)
            local env = ctx.useAddonEnv and addonEnv or api.env
            for _, m in ipairs(e.attr.mixin or {}) do
              mixin(obj, env[m])
            end
            for _, m in ipairs(e.attr.securemixin or {}) do
              mixin(obj, env[m])
            end
            for k, v in pairs(e.attr) do
              if xmlattrlang[k] then
                xmlattrlang[k](obj, v)
              end
            end
            initKidsMaybeFrames(e, obj, false)
          end
        end

        local function mkInitAttrs(e)
          local notRecursive = mkInitAttrsNotRecursive(e)
          return function(obj)
            for _, inh in ipairs(e.attr.inherits or {}) do
              api.templates[string.lower(inh)].initAttrs(obj)
            end
            notRecursive(obj)
          end
        end

        local function mkInitKidsNotRecursive(e)
          return function(obj)
            initKidsMaybeFrames(e, obj, true)
          end
        end

        local function mkInitKids(e)
          local notRecursive = mkInitKidsNotRecursive(e)
          return function(obj)
            for _, inh in ipairs(e.attr.inherits or {}) do
              api.templates[string.lower(inh)].initKids(obj)
            end
            notRecursive(obj)
          end
        end

        function loadElement(e, parent)
          if api.IsIntrinsicType(e.type) then
            local initAttrs = mkInitAttrs(e)
            local initKids = mkInitKids(e)
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
                constructor = function(self, xmlattr)
                  base.constructor(self, xmlattr)
                  self.__intrinsicHack = true
                  initAttrs(self)
                  initKids(self)
                  self.__intrinsicHack = nil
                end,
                inherits = { basetype },
                metatable = { __index = base.metatable.__index },
                name = e.attr.name,
              }
            else
              local ltype = string.lower(e.type)
              if (ltype == 'font' and e.attr.name) or (virtual and not ctx.ignoreVirtual) then
                assert(e.attr.name, 'cannot create anonymous template')
                local name = string.lower(e.attr.name)
                if api.templates[name] then
                  api.log(1, 'overwriting template ' .. e.attr.name)
                end
                api.log(3, 'creating template ' .. e.attr.name)
                api.templates[name] = {
                  initAttrs = initAttrs,
                  initKids = initKids,
                  name = e.attr.name,
                }
              end
              if ltype == 'font' or (not virtual or ctx.ignoreVirtual) then
                local name = e.attr.name
                if virtual and ctx.ignoreVirtual then
                  api.log(1, 'ignoring virtual on ' .. tostring(name))
                end
                local templates = {}
                for _, inh in ipairs(e.attr.inherits or {}) do
                  local template = api.templates[string.lower(inh)]
                  assert(template, 'unknown template ' .. inh)
                  table.insert(templates, template)
                end
                table.insert(templates, {
                  initAttrs = mkInitAttrsNotRecursive(e),
                  initKids = mkInitKidsNotRecursive(e),
                })
                return api.CreateUIObject(e.type, name, parent, ctx.useAddonEnv and addonEnv or nil, unpack(templates))
              end
            end
          else
            local fn = xmllang[e.type]
            if fn then
              fn(e, parent)
            else
              api.log(2, 'skipping ' .. filename .. ' ' .. e.type)
            end
          end
        end

        return {
          loadElement = loadElement,
          loadElements = loadElements,
        }
      end

      return api.CallSafely(function()
        local root = xml.validate(xmlstr)
        assert(root.type == 'ui' or root.type == 'bindings')
        local ctx = {
          ignoreVirtual = false,
          useAddonEnv = false,
        }
        usingContext(ctx).loadElements(root.kids)
      end)
    end

    function loadFile(filename)
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
        local success, content = pcall(function() return readFile(filename) end)
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

  local function resolveToc(tocFile)
    api.log(1, 'resolving %s', tocFile)
    local tocVersion = tocFile:match('_(%a+).toc')
    if tocVersion == version then
      api.log(1, '%s already has a version', tocFile)
      return tocFile
    end
    local versionSpecific = tocFile:sub(1, -5) .. '_' .. version .. '.toc'
    if path.isfile(versionSpecific) then
      api.log(1, 'using version specific %s', versionSpecific)
      return versionSpecific
    end
    if path.isfile(tocFile) then
      api.log(1, 'falling back to %s', tocFile)
      return tocFile
    end
    api.log(1, 'no valid toc for %s', tocFile)
    return nil
  end

  local function parseToc(tocFile)
    local attrs = {}
    local files = {}
    local dir = path.dirname(tocFile)
    for line in io.lines(tocFile) do
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

  local function loadToc(tocFile, addonName)
    api.log(1, 'loading toc %s', tocFile)
    local isAddon = addonName and true or tocFile:find('/AddOns/')
    local tocBase = addonName or tocFile:match('/AddOns/([^/]+)/')
    local addon = isAddon and forAddon(tocBase, {}) or forAddon()
    for _, file in ipairs(parseToc(tocFile).files) do
      addon.loadFile(file)
    end
    if isAddon then
      api.SendEvent('ADDON_LOADED', tocBase)
    end
  end

  local loaded = {}
  local function doLoad(tocFile, addonName)
    if not loaded[tocFile] then
      local toc = parseToc(tocFile)
      if toc.attrs.AllowLoad ~= 'Glue' then
        for dep in string.gmatch(toc.attrs.RequiredDep or '', '[^, ]+') do
          doLoad(resolveToc(string.format('%s/AddOns/%s/%s.toc', rootDir, dep, dep)))
        end
        loadToc(tocFile, addonName)
        loaded[tocFile] = true
      end
    end
  end

  local function loadFrameXml()
    forAddon().loadFile(path.join(rootDir, 'GlobalEnvironment.lua'))
    -- Special hack to avoid loops in map resolution code.
    api.env.Enum.UIMapType.Continent = 0
    api.env.Enum.UIMapType.Cosmic = 0
    api.env.Enum.UIMapType.World = 0
    -- End special hack.
    forAddon().loadFile(path.join(rootDir, 'FrameXML/GlobalStrings.lua'))
    loadToc(resolveToc(path.join(rootDir, 'FrameXML/FrameXML.toc')))
    local tocFiles = {}
    local addonDir = path.join(rootDir, 'AddOns')
    -- TODO don't force load the rest of the tocs
    local badAddons = {
      Blizzard_FlightMap = true,
      Blizzard_GMChatUI = true,
      Blizzard_SocialUI = true,
    }
    for dir in path.each(addonDir .. '/*', 'n', { skipfiles = true }) do
      local toc = resolveToc(path.join(addonDir, dir, dir .. '.toc'))
      if toc and not badAddons[dir] then
        table.insert(tocFiles, toc)
      end
    end
    table.sort(tocFiles)
    for _, tocFile in ipairs(tocFiles) do
      local toc = parseToc(tocFile)
      if toc.attrs.LoadOnDemand ~= '1' then
        doLoad(tocFile)
      end
    end
    for _, tocFile in ipairs(tocFiles) do
      doLoad(tocFile)
    end
  end

  local otherAddons = {}
  for _, d in ipairs(otherAddonDirs) do
    otherAddons[path.basename(d)] = d
  end

  local function loadAddon(addonName)
    local dir = otherAddons[addonName] or path.join(rootDir, 'AddOns', addonName)
    doLoad(resolveToc(path.join(dir, addonName .. '.toc')), addonName)
  end

  return {
    loadAddon = loadAddon,
    loadFrameXml = loadFrameXml,
    loadToc = loadToc,
    loadXml = forAddon().loadXml,
    version = version,
  }
end

return {
  loader = loader,
}
