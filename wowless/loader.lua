local function loader(api, skipscripts, log, sink)

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

    local function loadKids(e, parent)
      for _, v in ipairs(e.kids) do
        loadElement(v, parent)
      end
    end

    local function loadLuaKids(e)
      for _, s in ipairs(e.kids) do
        loadLuaString(filename, s)
      end
    end

    local xmllang = {
      fontfamily = function(e)
        assert(e.attr, 'invalid font family without attributes')
        local name = e.attr.name
        assert(name, 'invalid font family without name')
        assert(e.attr.virtual, 'invalid non-virtual font family')
        assert(#e.kids > 0, 'invalid font family ' .. name .. ' without members')
        for _, kid in ipairs(e.kids) do
          assert(kid.name == 'member', 'invalid font family ' .. name)
          assert(#kid.kids == 1 and kid.kids[1].name == 'font', 'invalid font family member in ' .. name)
        end
        local font = e.kids[1].kids[1]
        return loadElement({
          name = font.name,
          attr = mixin(font.attr, { virtual = true, name = name }),
          kids = font.kids,
        })
      end,
      frames = function(e, parent)
        loadKids(e, parent)
      end,
      include = function(e)
        assert(e.attr.file and #e.kids == 0)
        loadFile(path.join(dir, e.attr.file))
      end,
      layer = function(e, parent)
        loadKids(e, parent)
      end,
      layers = function(e, parent)
        loadKids(e, parent)
      end,
      scopedmodifier = function(e, parent)
        loadKids(e, parent)
      end,
      script = function(e)
        if not skipscripts then
          if e.attr.file then
            assert(#e.kids == 0)
            loadFile(path.join(dir, e.attr.file))
          else
            loadLuaKids(e)
          end
        end
      end,
      scripts = function()
        -- handled by loadElement
      end,
    }

    function loadElement(e, parent)
      if api:IsIntrinsicType(e.name) then
        local inherits = {e.name}
        for _, inh in ipairs(e.attr.inherits or {}) do
          table.insert(inherits, string.lower(inh))
        end
        local mix = {}
        for _, m in ipairs(e.attr.mixin or {}) do
          mixin(mix, api.env[m])
        end
        local virtual = e.attr.virtual
        if e.attr.intrinsic then
          assert(virtual ~= false, 'intrinsics cannot be explicitly non-virtual: ' .. e.name)
          virtual = true
        end
        local function constructor(obj)
          if e.attr.parentkey then
            log(3, 'attaching ' .. e.attr.parentkey)
            obj:GetParent()[e.attr.parentkey] = obj
          end
          loadKids(e, obj)
          if not skipscripts then
            for _, kid in ipairs(e.kids) do
              if kid.name == 'scripts' then
                obj.__scripts = obj.__scripts or {}
                for _, script in ipairs(kid.kids) do
                  local fnattr = script.attr['function']
                  local fn
                  if fnattr then
                    fn = function()
                      log(3, 'begin calling script function %s from %s on %s', fnattr, e.name, tostring(obj:GetName()))
                      api.env[fnattr](obj)
                      log(3, 'end calling script function %s from %s on %s', fnattr, e.name, tostring(obj:GetName()))
                    end
                  else
                    local fnstr = 'return function(self, ...)\n' .. table.concat(script.kids, '\n') .. '\nend'
                    local sfn = setfenv(assert(loadstring(fnstr, path.basename(filename)))(), api.env)
                    fn = function()
                      log(3, 'begin calling inline script from %s on %s', e.name, tostring(obj:GetName()))
                      sfn(obj)
                      log(3, 'end calling inline script from %s on %s', e.name, tostring(obj:GetName()))
                    end
                  end
                  local inh = script.attr.inherit
                  local old = obj.__scripts[script.name]
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
                  obj.__scripts[script.name] = wfn
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
          local obj = api:CreateUIObject(e.name, name, parent, inherits)
          mixin(obj, mix)
          constructor(obj)
          if obj.__scripts and obj.__scripts.onload then
            log(4, 'begin onload for ' .. tostring(obj:GetName()))
            sink(obj.__scripts.onload)
            log(4, 'end onload for ' .. tostring(obj:GetName()))
          end
        end
      else
        local fn = xmllang[e.name]
        if fn then
          fn(e, parent)
        else
          log(1, 'skipping ' .. filename .. ' ' .. e.name)
        end
      end
    end

    local root = xml.validate(filename)
    assert(root.name == 'ui')
    loadKids(root)
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

local function run(loglevel, skipscripts)
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
  loader(api, skipscripts, log, sink)(toc)
  return env, errors
end

return {
  run = run,
}
