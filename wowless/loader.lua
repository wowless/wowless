local function loader(api)

  local path = require('path')
  local xml = require('wowless.xml')
  local util = require('wowless.util')
  local readFile, mixin = util.readfile, util.mixin

  local function parseTypedValue(type, value)
    if type == 'number' then
      return tonumber(value)
    elseif type == 'global' then
      return api.env[value]
    elseif type == 'boolean' then
      return (value == 'true')
    elseif type == 'string' or type == nil then
      return value
    else
      error('invalid keyvalue/attribute type ' .. type)
    end
  end

  local function loadLuaString(filename, str, ...)
    local args = {...}
    local fn = setfenv(assert(loadstring(str, path.basename(filename))), api.env)
    api.CallSafely(function() fn(unpack(args)) end)
  end

  local loadFile

  local function loadXml(filename, xmlstr)
    local dir = path.dirname(filename)

    local loadElement

    local function loadElements(t, parent, ignoreVirtual)
      for _, v in ipairs(t) do
        loadElement(v, parent, ignoreVirtual)
      end
    end

    local xmllang = {
      anchors = function(e, parent)
        for _, anchor in ipairs(e.anchor) do
          local point = anchor.point
          local relativeTo = api.ParentSub(anchor.relativeto, parent:GetParent())
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
        loadElements(e.groups, parent)
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
      frames = function(e, parent, ignoreVirtual)
        loadElements(e.frames, parent, ignoreVirtual)
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
      layers = function(e, parent, ignoreVirtual)
        for _, layer in ipairs(e.layers) do
          loadElements(layer.fontstrings, parent, ignoreVirtual)
          loadElements(layer.lines, parent, ignoreVirtual)
          loadElements(layer.textures, parent, ignoreVirtual)
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
        loadElements(e.kids, parent)
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
            fn = function(...)
              assert(api.env[fnattr], 'unknown script function ' .. fnattr)
              api.env[fnattr](...)
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
            local bindingType = 1
            if script.intrinsicorder == 'precall' then
              bindingType = 0
            elseif script.intrinsicorder == 'postcall' then
              bindingType = 2
            else
              assert(script.intrinsicorder == nil, 'invalid intrinsicOrder tag on script')
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
        obj:SetParent(api.env[value])
      end,
      parentarray = function(obj, value)
        api.log(3, 'attaching to array ' .. value)
        local p = obj:GetParent()
        p[value] = p[value] or {}
        table.insert(p[value], obj)
      end,
      parentkey = function(obj, value)
        api.log(3, 'attaching ' .. value)
        obj:GetParent()[value] = obj
      end,
    }

    local function mkInitAttrs(e)
      return function(obj)
        for _, inh in ipairs(e.attr.inherits or {}) do
          api.templates[string.lower(inh)].initAttrs(obj)
        end
        for _, m in ipairs(e.attr.mixin or {}) do
          mixin(obj, api.env[m])
        end
        for _, m in ipairs(e.attr.securemixin or {}) do
          mixin(obj, api.env[m])
        end
        for k, v in pairs(e.attr) do
          if xmlattrlang[k] then
            xmlattrlang[k](obj, v)
          end
        end
      end
    end

    local function mkInitKids(e)
      return function(obj)
        for _, inh in ipairs(e.attr.inherits or {}) do
          api.templates[string.lower(inh)].initKids(obj)
        end
        loadElements(e.kids, obj, true)
      end
    end

    function loadElement(e, parent, ignoreVirtual)
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
              initAttrs(self)
              initKids(self)
            end,
            inherits = { basetype },
            metatable = { __index = base.metatable.__index },
            name = e.attr.name,
          }
        elseif virtual and not ignoreVirtual then
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
        else
          local name = e.attr.name
          if virtual and ignoreVirtual then
            api.log(1, 'ignoring virtual on ' .. tostring(name))
          end
          local templates = {}
          for _, inh in ipairs(e.attr.inherits or {}) do
            local template = api.templates[string.lower(inh)]
            assert(template, 'unknown template ' .. inh)
            table.insert(templates, template)
          end
          table.insert(templates, {
            initAttrs = function(obj)
              for _, m in ipairs(e.attr.mixin or {}) do
                mixin(obj, api.env[m])
              end
              for _, m in ipairs(e.attr.securemixin or {}) do
                mixin(obj, api.env[m])
              end
              for k, v in pairs(e.attr) do
                if xmlattrlang[k] then
                  xmlattrlang[k](obj, v)
                end
              end
            end,
            initKids = function(obj)
              loadElements(e.kids, obj, true)
            end,
          })
          return api.CreateUIObject(e.type, name, parent, unpack(templates))
        end
      else
        local fn = xmllang[e.type]
        if fn then
          fn(e, parent, ignoreVirtual)
        else
          api.log(1, 'skipping ' .. filename .. ' ' .. e.type)
        end
      end
    end

    return api.CallSafely(function()
      local root = xml.validate(xmlstr)
      assert(root.type == 'ui')
      loadElements(root.kids)
    end)
  end

  function loadFile(filename, ...)
    api.log(2, 'loading file %s', filename)
    if filename:sub(-4) == '.lua' then
      loadLuaString(filename, readFile(filename), ...)
    elseif filename:sub(-4) == '.xml' then
      return loadXml(filename, readFile(filename))
    else
      error('unknown file type ' .. filename)
    end
  end

  local function parseToc(tocFile)
    local attrs = {}
    local files = {}
    local dir = path.dirname(tocFile)
    for line in io.lines(tocFile) do
      line = line:match('^%s*(.-)%s*$')
      if line:sub(1, 3) == '## ' then
        local key, value = line:match('(%w+): (%w+)', 4)
        if key then
          attrs[key] = value
        end
      elseif line ~= '' and line:sub(1, 1) ~= '#' then
        table.insert(files, path.join(dir, line))
      end
    end
    return {
      attrs = attrs,
      env = {},
      files = files,
      name = path.basename(tocFile),
    }
  end

  local function loadToc(toc, name, env)
    api.log(1, 'loading toc %s', toc)
    for _, file in ipairs(parseToc(toc).files) do
      loadFile(file, name, env)
    end
  end

  local function loadFrameXml()
    loadToc(require('datafile').path('wowui/classic/FrameXML/FrameXML.toc'))
    local tocFiles = {}
    local handle = io.popen([[bash -c 'find wowui/classic/AddOns -name "*.toc"']])
    for line in handle:lines() do
      table.insert(tocFiles, line)
    end
    handle:close()
    for _, tocFile in ipairs(tocFiles) do
      local toc = parseToc(tocFile)
      if not toc.attrs.LoadOnDemand then
        loadToc(tocFile, toc.name, toc.env)
      end
    end
  end

  return {
    loadFrameXml = loadFrameXml,
    loadToc = loadToc,
    loadXml = loadXml,
  }
end

return {
  loader = loader,
}
