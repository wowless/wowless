local util = require('wowless.util')
local Mixin = util.mixin

return function(cstubs, datalua, gencode)
  local function flatten(types)
    local result = {}
    local function flattenOne(k)
      local lk = string.lower(k)
      if not result[lk] then
        local ty = types[k]
        local isa = { [lk] = true }
        local scripts = Mixin({}, ty.scripts or {})
        local hostindex = {}
        local sandboxindex = {}
        for inh in pairs(ty.inherits) do
          flattenOne(inh)
          local r = result[string.lower(inh)]
          Mixin(isa, r.isa)
          Mixin(scripts, r.scripts)
          Mixin(hostindex, r.hostindex)
          Mixin(sandboxindex, r.sandboxindex)
        end
        Mixin(hostindex, ty.hostindex) -- do this last in case of overrides
        Mixin(sandboxindex, ty.sandboxindex)
        result[lk] = {
          constructor = ty.constructor,
          ctype = ty.cfg.uitype_bit,
          hostindex = hostindex,
          isa = isa,
          name = ty.cfg.objectType or k,
          sandboxindex = sandboxindex,
          scripts = scripts,
        }
      end
    end
    for k in pairs(types) do
      flattenOne(k)
    end
    local t = {}
    for k, v in pairs(result) do
      local sandboxMTindex = {}
      for n, factory in pairs(v.sandboxindex) do
        sandboxMTindex[n] = factory()
      end
      t[k] = {
        constructor = v.constructor,
        ctype = v.ctype,
        hostMT = { __index = v.hostindex }, -- issue #657
        isa = v.isa,
        name = v.name,
        sandboxMT = { __index = sandboxMTindex },
        scripts = v.scripts,
      }
    end
    return t
  end
  return function(modules)
    local uiobjectmethodstubs, uiobjecthostimpls = cstubs.loaduiobjectmethods(modules)
    local uiobjects = {}
    for name, cfg in pairs(datalua.uiobjects) do
      local constructor = assert(loadstring_untainted(cfg.constructor, name))(gencode)
      if cfg.singleton then
        local orig = constructor
        local called = false
        constructor = function()
          assert(not called, name .. ' can only be created once')
          called = true
          return orig()
        end
      end
      local hostindex = {}
      local sandboxindex = {}
      for mname, _ in pairs(cfg.methods) do
        local fname = name .. ':' .. mname
        hostindex[mname] = uiobjecthostimpls[fname]
        sandboxindex[mname] = uiobjectmethodstubs[fname]
      end
      uiobjects[name] = {
        cfg = cfg,
        constructor = constructor,
        hostindex = hostindex,
        inherits = cfg.inherits,
        sandboxindex = sandboxindex,
        scripts = cfg.scripts,
      }
    end
    return flatten(uiobjects)
  end
end
