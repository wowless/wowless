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

    local function loadElements(t, parent)
      for _, v in ipairs(t) do
        loadElement(v, parent)
      end
    end

    local xmllang = {
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
      include = function(e)
        loadFile(path.join(dir, e.file))
      end,
      layers = function(e, parent)
        for _, layer in ipairs(e.layers) do
          loadElements(layer.fontstrings, parent)
          loadElements(layer.lines, parent)
          loadElements(layer.textures, parent)
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
      scripts = function()
        -- handled by loadElement
      end,
    }

    function loadElement(e, parent)
      if api:IsIntrinsicType(e.type) then
        local inherits = {e.type}
        for _, inh in ipairs(e.attr.inherits or {}) do
          table.insert(inherits, string.lower(inh))
        end
        local mix = {}
        for _, m in ipairs(e.attr.mixin or {}) do
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
          loadElements(e.kids, obj)
          for _, kid in ipairs(e.kids) do
            if kid.type == 'scripts' then
              obj.__scripts = obj.__scripts or {}
              for _, script in ipairs(kid.kids) do
                local fn
                if script.func then
                  local fnattr = script.func
                  fn = function()
                    log(3, 'begin calling script function %s from %s on %s', fnattr, e.type, tostring(obj:GetName()))
                    api.env[fnattr](obj)
                    log(3, 'end calling script function %s from %s on %s', fnattr, e.type, tostring(obj:GetName()))
                  end
                elseif script.method then
                  local mattr = script.method
                  fn = function()
                    log(3, 'begin calling script method %s from %s on %s', mattr, e.type, tostring(obj:GetName()))
                    obj[mattr](obj)
                    log(3, 'end calling script method %s from %s on %s', mattr, e.type, tostring(obj:GetName()))
                  end
                elseif script.text then
                  local fnstr = 'return function(self, ...)\n' .. script.text .. '\nend'
                  local sfn = setfenv(assert(loadstring(fnstr, path.basename(filename)))(), api.env)
                  fn = function()
                    log(3, 'begin calling inline script from %s on %s', e.type, tostring(obj:GetName()))
                    sfn(obj)
                    log(3, 'end calling inline script from %s on %s', e.type, tostring(obj:GetName()))
                  end
                end
                if fn then
                  local inh = script.inherit
                  local old = obj.__scripts[script.type]
                  local wfn = fn
                  if inh == 'prepend' then
                    if old then
                      wfn = function() fn() old(obj) end
                    end
                  elseif inh == 'append' then
                    if old then
                      wfn = function() old(obj) fn() end
                    end
                  else
                    assert(inh == nil, 'invalid inherit tag on script')
                  end
                  obj.__scripts[script.type] = wfn
                end
              end
            end
          end
        end
        if virtual then
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
          local obj = api:CreateUIObject(e.type, name, parent, inherits)
          mixin(obj, mix)
          constructor(obj)
          if obj.__scripts and obj.__scripts.onload then
            log(4, 'begin onload for ' .. tostring(obj:GetName()))
            sink(obj.__scripts.onload)
            log(4, 'end onload for ' .. tostring(obj:GetName()))
          end
        end
      else
        local fn = xmllang[e.type]
        if fn then
          fn(e, parent)
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
