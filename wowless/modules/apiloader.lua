local bubblewrap = require('wowless.bubblewrap')
local util = require('wowless.util')

return function(datalua, funcheck, log, sqls)
  local cstubs = require('build.products.' .. datalua.product .. '.stubs')
  return function(modules)
    log(1, 'loading functions')

    local function mkfn(fname, apicfg)
      local incheck = apicfg.inputs and funcheck.makeCheckInputs(fname, apicfg)
      local outcheck = apicfg.outputs and funcheck.makeCheckOutputs(fname, apicfg)
      local src = apicfg.src or fname
      local mkbasefn = setfenv(assert(loadstring_untainted(apicfg.impl, src), fname), _G)
      local args = {}
      for _, m in ipairs(apicfg.modules or {}) do
        table.insert(args, (assert(modules[m], 'unknown module ' .. m)))
      end
      for _, sql in ipairs(apicfg.sqls or {}) do
        table.insert(args, sqls[sql])
      end
      local basefn = mkbasefn(unpack(args))
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

    local fns, securefns = {}, {}
    for fn, apicfg in pairs(datalua.apis) do
      local v
      if apicfg.stdlib then
        v = assert(util.tget(_G, fn))
      elseif apicfg.cstub then
        v = bubblewrap(assert(cstubs[fn], 'missing C stub for ' .. fn))
      else
        v = bubblewrap(mkfn(fn, apicfg))
      end
      util.tset(securefns, fn, v)
      if not apicfg.secureonly then
        util.tset(fns, fn, v)
      end
    end
    log(1, 'functions loaded')
    return fns, securefns
  end
end
