local function loader(api, log, sink)

  local path = require('path')
  local xml = require('wowless.xml')
  local util = require('wowless.util')
  local readFile, mixin = util.readfile, util.mixin

  local function loadLuaString(filename, str)
    sink(assert(loadstring(str, path.basename(filename))))
  end

  local loadFile

  local function loadXml(filename)
    local dir = path.dirname(filename)

    local loadElement

    local function loadElements(t, parent, ignoreVirtual)
      for _, v in ipairs(t) do
        loadElement(v, parent, ignoreVirtual)
      end
    end

    local xmllang = {
      buttontext = function(e, parent)
        return loadElement(mixin({}, e, { type = 'fontstring' }), parent)
      end,
      disabledtexture = function(e, parent)
        parent:SetDisabledTexture(loadElement(mixin({}, e, { type = 'texture' }), parent))
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
      highlighttexture = function(e, parent)
        parent:SetHighlightTexture(loadElement(mixin({}, e, { type = 'texture' }), parent))
      end,
      include = function(e)
        loadFile(path.join(dir, e.file))
      end,
      layers = function(e, parent, ignoreVirtual)
        for _, layer in ipairs(e.layers) do
          loadElements(layer.fontstrings, parent, ignoreVirtual)
          loadElements(layer.lines, parent, ignoreVirtual)
          loadElements(layer.textures, parent, ignoreVirtual)
        end
      end,
      normaltext = function(e, parent)
        loadElement(mixin({}, e, { type = 'fontstring' }), parent)
      end,
      normaltexture = function(e, parent)
        parent:SetNormalTexture(loadElement(mixin({}, e, { type = 'texture' }), parent))
      end,
      pushedtexture = function(e, parent)
        parent:SetPushedTexture(loadElement(mixin({}, e, { type = 'texture' }), parent))
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
      scripts = function()
        -- handled by loadElement
      end,
      scrollchild = function(e, parent)
        loadElement(e.frame, parent)
      end,
    }

    function loadElement(e, parent, ignoreVirtual)
      if api:IsIntrinsicType(e.type) then
        local inherits = {e.type}
        for _, inh in ipairs(e.attr.inherits or {}) do
          table.insert(inherits, string.lower(inh))
        end
        local mix = {}
        for _, m in ipairs(e.attr.mixin or {}) do
          mixin(mix, api.env[m])
        end
        for _, m in ipairs(e.attr.securemixin or {}) do
          mixin(mix, api.env[m])
        end
        local virtual = e.attr.virtual
        if e.attr.intrinsic then
          assert(virtual ~= false, 'intrinsics cannot be explicitly non-virtual: ' .. e.type)
          virtual = true
        end
        local function constructor(obj)
          if e.attr.parentkey then
            log(3, 'attaching ' .. e.attr.parentkey)
            obj:GetParent()[e.attr.parentkey] = obj
          end
          loadElements(e.kids, obj, true)
          for _, kid in ipairs(e.kids) do
            if kid.type == 'scripts' then
              for _, script in ipairs(kid.kids) do
                local fn
                if script.func then
                  local fnattr = script.func
                  fn = function()
                    assert(api.env[fnattr], 'unknown script function ' .. fnattr)
                    api.env[fnattr](obj)
                  end
                elseif script.method then
                  local mattr = script.method
                  fn = function()
                    assert(obj[mattr], 'unknown script method ' .. mattr)
                    obj[mattr](obj)
                  end
                elseif script.text then
                  local fnstr = 'return function(self, ...)\n' .. script.text .. '\nend'
                  local sfn = setfenv(assert(loadstring(fnstr, path.basename(filename)))(), api.env)
                  fn = function()
                    sfn(obj)
                  end
                end
                if fn then
                  local old = obj:GetScript(script.type)
                  if old and script.inherit then
                    local bfn = fn
                    if script.inherit == 'prepend' then
                      fn = function() bfn() old(obj) end
                    elseif script.inherit == 'append' then
                      fn = function() old(obj) bfn() end
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
                  obj:__SetScript(script.type, bindingType, fn)
                end
              end
            end
          end
        end
        if virtual and not ignoreVirtual then
          assert(e.attr.name, 'cannot create anonymous virtual uiobject')
          local name = string.lower(e.attr.name)
          if api.uiobjectTypes[name] then
            api.log(1, 'overwriting uiobject type ' .. e.attr.name)
          end
          api.uiobjectTypes[name] = {
            constructor = constructor,
            inherits = inherits,
            intrinsic = e.attr.intrinsic,
            mixin = mix,
            name = e.attr.name,
          }
        else
          local name = e.attr.name
          if name and string.match(name, '$parent') then
            local p = parent
            while p ~= nil and not p:GetName() do
              p = p:GetParent()
            end
            assert(p, '$parent substitution requires a parent name: ' .. name)
            name = string.gsub(name, '$parent', p:GetName())
          end
          if virtual and ignoreVirtual then
            api.log(1, 'ignoring virtual on ' .. tostring(name))
          end
          local obj = api:CreateUIObject(e.type, name, parent, inherits)
          mixin(obj, mix)
          constructor(obj)
          if obj.__RunScript then
            sink(function() obj:__RunScript('OnLoad') end)
          end
          return obj
        end
      else
        local fn = xmllang[e.type]
        if fn then
          fn(e, parent, ignoreVirtual)
        else
          log(1, 'skipping ' .. filename .. ' ' .. e.type)
        end
      end
    end

    local root = xml.validate(filename)
    assert(root.type == 'ui')
    loadElements(root.kids)
  end

  function loadFile(filename)
    log(2, 'loading file %s', filename)
    if filename:sub(-4) == '.lua' then
      loadLuaString(filename, readFile(filename))
    elseif filename:sub(-4) == '.xml' then
      return loadXml(filename)
    else
      error('unknown file type ' .. filename)
    end
  end

  local function loadToc(toc)
    local dir = path.dirname(toc)
    for line in io.lines(toc) do
      line = line:match('^%s*(.-)%s*$')
      if line ~= '' and line:sub(1, 1) ~= '#' then
        loadFile(path.join(dir, line))
      end
    end
  end

  return loadToc
end

local function run(loglevel)
  local function log(level, fmt, ...)
    if level <= loglevel then
      print(string.format(fmt, ...))
    end
  end
  local env, api = require('wowless.env').new(log)
  local errors = {}
  local sink = function(lua)
    xpcall(setfenv(lua, env), function(err)
      table.insert(errors, err)
      if loglevel > 0 then
        print('error: ' .. err)
        print(debug.traceback())
      end
    end)
  end
  local toc = require('datafile').path('wowui/classic/FrameXML/FrameXML.toc')
  loader(api, log, sink)(toc)
  return env, errors
end

return {
  run = run,
}
