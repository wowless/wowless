local bubblewrap = require('wowless.bubblewrap')
local util = require('wowless.util')

return function(datalua, funcheck, log, sqls)
  return function(modules)
    log(1, 'loading functions')

    local function mkfn(fname, apicfg)
      local incheck = apicfg.inputs and funcheck.makeCheckInputs(fname, apicfg)
      local specials = {}
      for _, m in ipairs(apicfg.modules or {}) do
        table.insert(specials, (assert(modules[m], 'unknown module ' .. m)))
      end
      for _, sql in ipairs(apicfg.sqls or {}) do
        table.insert(specials, sqls[sql])
      end
      local basefn = setfenv(assert(loadstring_untainted(apicfg.src, '@./data/impl/' .. fname .. '.lua'), fname), _G)(
        unpack(specials)
      )
      local outcheck = apicfg.outputs and funcheck.makeCheckOutputs(fname, apicfg)
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
