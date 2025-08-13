local bubblewrap = require('wowless.bubblewrap')
local util = require('wowless.util')

return function(datalua, funcheck, gencode, log, sqls)
  return function(modules)
    log(1, 'loading functions')

    local impls = {}
    for k, v in pairs(datalua.impls) do
      local specials = {}
      for _, m in ipairs(v.modules or {}) do
        table.insert(specials, (assert(modules[m], 'unknown module ' .. m)))
      end
      for _, sql in ipairs(v.sqls or {}) do
        table.insert(specials, sqls[sql])
      end
      impls[k] = setfenv(assert(loadstring_untainted(v.src, '@./data/impl/' .. k .. '.lua'), k), _G)(unpack(specials))
    end

    local function mkfn(fname, apicfg)
      local incheck = apicfg.inputs and funcheck.makeCheckInputs(fname, apicfg)
      local basefn
      if apicfg.stub then
        local text = ('local gencode = ...; return function() %s end'):format(apicfg.stub)
        basefn = assert(setfenv(loadstring_untainted(text), _G))(gencode)
      elseif apicfg.impl then
        basefn = impls[apicfg.impl]
      else
        error(('invalid function %q'):format(fname))
      end
      local outcheck = apicfg.impl and apicfg.outputs and funcheck.makeCheckOutputs(fname, apicfg)
      if not incheck and not outcheck then
        return basefn
      elseif incheck and not outcheck then
        return function(...)
          return basefn(incheck(...))
        end
      elseif not incheck and outcheck then
        return function(...)
          return outcheck(basefn(...))
        end
      else
        return function(...)
          return outcheck(basefn(incheck(...)))
        end
      end
    end

    local rawfns = {}
    local fns = {}
    for fn, apicfg in pairs(datalua.apis) do
      if apicfg.stdlib then
        local v = assert(util.tget(_G, fn))
        util.tset(fns, fn, v)
        util.tset(rawfns, fn, v)
      else
        local v = mkfn(fn, apicfg)
        util.tset(fns, fn, bubblewrap(v))
        util.tset(rawfns, fn, v)
      end
    end
    log(1, 'functions loaded')
    return fns, rawfns
  end
end
