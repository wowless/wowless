local function loader(api, cfg)
  local rootDir = cfg and cfg.rootDir
  local version = cfg and cfg.version
  local otherAddonDirs = cfg and cfg.otherAddonDirs or {}

  local lfs = require('lfs')
  local path = require('path')
  local xml = require('wowless.xml')
  local util = require('wowless.util')
  local readFile, mixin = util.readfile, util.mixin

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

  local function forAddon(addonName, addonEnv)

    local function loadstr(str, filename)
      return assert(loadstring(str, '@' .. path.normalize(filename):gsub('/', '\\')))
    end

    local function loadLuaString(filename, str)
      local fn = setfenv(loadstr(str, filename), api.env)
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
            for _, anchor in ipairs(e.kids) do
              local point = anchor.attr.point
              local relativeTo
              if anchor.attr.relativeto then
                relativeTo = api.ParentSub(anchor.attr.relativeto, parent:GetParent())
              elseif anchor.attr.relativekey then
                local parts = {util.strsplit('.', anchor.attr.relativekey)}
                if #parts == 1 then
                  relativeTo = api.ParentSub(anchor.attr.relativekey, parent:GetParent())
                else
                  local obj = parent
                  for i = 1, #parts do
                    local p = parts[i]
                    if p == '$parent' then
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
              local relativePoint = anchor.attr.relativepoint or 'CENTER'
              local offsetX, offsetY = getXY(anchor.kids[#anchor.kids])
              local x = anchor.attr.x or offsetX
              local y = anchor.attr.y or offsetY
              parent:SetPoint(point, relativeTo, relativePoint, x, y)
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
            for _, a in ipairs(e.kids) do
              attrs[a.attr.name] = parseTypedValue(a.attr.type, a.attr.value)
            end
          end,
          bartexture = function(e, parent)
            parent:SetStatusBarTexture(loadElement(mixin({}, e, { type = 'texture' }), parent))
          end,
          blingtexture = function(e, parent)
            parent:SetBlingTexture(loadElement(mixin({}, e, { type = 'texture' }), parent))
          end,
          buttontext = function(e, parent)
            parent:SetFontString(loadElement(mixin({}, e, { type = 'fontstring' }), parent))
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
              attr = mixin({}, font.attr, { virtual = true, name = e.name }),
              kids = font.kids,
              type = font.type,
            })
          end,
          frames = function(e, parent)
            loadElements(e.kids, parent)
          end,
          highlightfont = function(e, parent)
            parent:SetHighlightFontObject(loadElement(mixin({}, e, { type = 'font' }), parent))
          end,
          highlighttexture = function(e, parent)
            parent:SetHighlightTexture(loadElement(mixin({}, e, { type = 'texture' }), parent))
          end,
          include = function(e)
            loadFile(path.join(dir, e.attr.file))
          end,
          keyvalues = function(e, parent)
            for _, kv in ipairs(e.kids) do
              parent[kv.attr.key] = parseTypedValue(kv.attr.type, kv.attr.value)
            end
          end,
          layers = function(e, parent)
            for _, layer in ipairs(e.kids) do
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
                fn = setfenv(loadstr(string.rep('\n', script.line - 2) .. fnstr, filename)(), api.env)
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
            local x, y = getXY(e)
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
            -- TODO this list is incomplete
            buttontext = true,
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
          local text = e.attr.text
          if text and framesFlag then
            getmetatable(obj).__index.SetText(obj, api.env[text] or text)
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

  local alternateVersionNames = {
    Vanilla = 'Classic',
    TBC = 'BCC',
    Mainline = 'Mainline',
  }

  local function resolveTocDir(tocDir)
    api.log(1, 'resolving %s', tocDir)
    local base = path.basename(tocDir)
    local toTry = not version and {''} or {
      '_' .. version,
      '-' .. version,
      '_' .. alternateVersionNames[version],
      '-' .. alternateVersionNames[version],
      '',
    }
    for _, try in ipairs(toTry) do
      local tocFile = path.join(tocDir, base .. try .. '.toc')
      if path.isfile(tocFile) then
        api.log(1, 'using toc %s', tocFile)
        return tocFile
      end
    end
    api.log(1, 'no valid toc for %s', tocDir)
    return nil
  end

  local function parseToc(tocFile)
    local attrs = {}
    local files = {}
    local dir = path.dirname(tocFile)
    for line in util.readfile(tocFile):gmatch('[^\r\n]+') do
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

  local addonData = assert(api.states.Addons)
  do
    local function maybeAdd(dir)
      local name = path.basename(dir)
      if not addonData[name] then
        local tocFile = resolveTocDir(dir)
        if tocFile then
          local addon = parseToc(tocFile)
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
    for _, d in ipairs(otherAddonDirs) do
      maybeAddAll(path.dirname(d))
    end
    if rootDir then
      maybeAddAll(path.join(rootDir, 'Interface', 'AddOns'))
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
      toc.loaded = true
      api.log(1, 'done loading %s', addonName)
      api.SendEvent('ADDON_LOADED', addonName)
    end
  end

  local function loadAddon(addonName)
    return pcall(function() doLoadAddon(addonName) end)
  end

  local function db2rows(name)
    local dbd = require('luadbd').dbds[name]
    local db2 = path.join(rootDir, 'db2', name .. '.db2')
    local v, b = api.env.GetBuildInfo()
    return dbd:rows(v .. '.' .. b, require('pl.file').read(db2))
  end

  local function loadFrameXml()
    local context = forAddon()
    context.loadFile(path.join(rootDir, 'Interface', 'GlobalEnvironment.lua'))
    for row in db2rows('globalstrings') do
      api.env[row.BaseTag] = row.TagText_lang
    end
    for _, file in ipairs(parseToc(resolveTocDir(path.join(rootDir, 'Interface', 'FrameXML'))).files) do
      context.loadFile(file)
    end
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

  return {
    loadAddon = loadAddon,
    loadFrameXml = loadFrameXml,
    loadXml = forAddon().loadXml,
    version = version,
  }
end

return {
  loader = loader,
}
