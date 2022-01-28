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
      aimpls[n] = a.impl
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
      tag = tag,
    }
  end
  return newtree
end)()

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
          anchor = function(anchor, parent)
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
          end,
          attribute = function(e, parent)
            -- TODO share code with SetAttribute somehow
            local a = e.attr
            api.UserData(parent).attributes[a.name] = parseTypedValue(a.type, a.value)
          end,
          color = function(e, parent)
            local r, g, b, a
            if e.attr.name then
              r, g, b, a = _G[e.attr.name]:GetRGBA()
            else
              r, g, b, a = e.attr.r, e.attr.g, e.attr.b, e.attr.a
            end
            local p = api.UserData(parent)
            if api.InheritsFrom(p.type, 'texture') then
              parent:SetColorTexture(r, g, b, a)
            elseif api.InheritsFrom(p.type, 'fontinstance') then
              parent:SetTextColor(r, g, b, a)
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
          include = function(e)
            loadFile(path.join(dir, e.attr.file))
          end,
          keyvalue = function(e, parent)
            local a = e.attr
            parent[a.key] = parseTypedValue(a.type, a.value)
          end,
          scopedmodifier = function(e, parent)
            withContext({ useAddonEnv = e.attr.scriptsusegivenenv }).loadElements(e.kids, parent)
          end,
          script = function(e)
            if e.attr.file then
              assert(not e.text)
              loadFile(path.join(dir, e.attr.file))
            else
              assert(e.text)
              loadLuaString(filename, e.text)
            end
          end,
          scripts = function(e, parent)
            local obj = parent
            for _, script in ipairs(e.kids) do
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
                local impl = xmlimpls[string.lower(script.type)].tag
                local args = impl and impl.args or 'self, ...'
                local fnstr = 'return function(' .. args .. ') ' .. script.text .. ' end'
                local env = ctx.useAddonEnv and addonEnv or api.env
                fn = setfenv(loadstr(string.rep('\n', script.line - 1) .. fnstr, filename), env)()
              end
              if fn then
                local old = obj:GetScript(script.type)
                if old and script.attr.inherit then
                  local bfn = fn
                  if script.attr.inherit == 'prepend' then
                    fn = function(...) bfn(...) old(...) end
                  elseif script.attr.inherit == 'append' then
                    fn = function(...) old(...) bfn(...) end
                  else
                    error('invalid inherit tag on script')
                  end
                end
                assert(not script.attr.intrinsicorder or parent.__intrinsicHack, 'intrinsicOrder on non-intrinsic')
                local bindingType = 1
                if script.attr.intrinsicorder == 'precall' then
                  bindingType = 0
                elseif script.attr.intrinsicorder == 'postcall' then
                  bindingType = 2
                elseif script.attr.intrinsicorder then
                  error('invalid intrinsicOrder tag on script')
                elseif parent.__intrinsicHack then
                  bindingType = 0
                end
                api.SetScript(obj, script.type, bindingType, fn)
              end
            end
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
              parent:SetTexCoord(x.ulx, x.uly, x.llx, x.lly, x.urx, x.ury, x.lrx, x.lry)
            else
              local x = e.attr
              parent:SetTexCoord(x.left, x.right, x.top, x.bottom)
            end
          end,
        }

        local xmlattrlang = {
          hidden = function(obj, value)
            api.log(3, 'setting hidden=%s on %s', tostring(value), api.GetDebugName(obj))
            local ud = api.UserData(obj)
            ud.shown = not value
            ud.visible = ud.shown and (not ud.parent or api.UserData(ud.parent).visible)
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
            if p then
              p[value] = p[value] or {}
              table.insert(p[value], obj)
            end
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
            local early = {
              'parent',
              'parentkey',
              'parentarray',
            }
            local earlymap = {}
            for _, ek in ipairs(early) do
              earlymap[ek] = true
              for k, v in pairs(e.attr) do
                if k == ek then
                  xmlattrlang[k](obj, v)
                end
              end
            end
            local attrimpls = xmlimpls[e.type].attrs
            for k, v in pairs(e.attr) do
              if not earlymap[k] then
                local methodName = attrimpls[k]
                local fn = xmlattrlang[k]
                if methodName then
                  api.uiobjectTypes[e.type].metatable.__index[methodName](obj, v)
                elseif fn then
                  xmlattrlang[k](obj, v)
                end
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
            local impl = xmlimpls[e.type] and xmlimpls[e.type].tag or nil
            local fn = xmllang[e.type]
            if type(impl) == 'table' then
              local elt = impl.argument == 'lastkid' and e.kids[#e.kids] or mixin({}, e, { type = impl.argument })
              local obj = loadElement(elt, parent)
              api.uiobjectTypes[impl.parenttype:lower()].metatable.__index[impl.parentmethod](parent, obj)
            elseif impl == 'transparent' then
              loadElements(e.kids, parent)
            elseif fn then
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
        local ctx = {
          ignoreVirtual = false,
          useAddonEnv = false,
        }
        usingContext(ctx).loadElement(root)
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
    local bversion = v .. '.' .. b
    local build = assert(dbd:build(bversion), ('cannot load %s in %s'):format(name, bversion))
    return build:rows(require('pl.file').read(db2))
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
