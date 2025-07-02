local util = require('wowless.util')

local function loadSqls(sqlitedb, sqls)
  local types = {
    cursor = {
      [false] = function(stmt)
        return stmt:urows()
      end,
      [true] = function(stmt)
        return stmt:nrows()
      end,
    },
    lookup = {
      -- Manually pull out the first element of these iterators.
      [false] = function(stmt)
        local f, s = stmt:rows()
        local t = f(s)
        if t then
          return unpack(t)
        end
      end,
      [true] = function(stmt)
        local f, s = stmt:nrows()
        return f(s)
      end,
    },
  }
  local ret = {}
  for k, v in pairs(sqls) do
    local stmt = sqlitedb:prepare(v.sql)
    if not stmt then
      error('could not prepare ' .. k .. ': ' .. sqlitedb:errmsg())
    end
    local f = types[v.type][not not v.table]
    ret[k] = function(...)
      stmt:reset()
      stmt:bind_values(...)
      return f(stmt)
    end
  end
  return ret
end

local function loadFunctions(api, loader)
  api.log(1, 'loading functions')
  local datalua = api.datalua
  local apis = datalua.apis
  local sqls = loadSqls(loader.sqlitedb, datalua.sqls)

  local frameworks = {
    api = api, -- TODO replace api framework with something finer grained
    datalua = api.datalua,
    env = api.env,
    events = api.events,
    loader = loader,
  }

  local impls = {}
  for k, v in pairs(datalua.impls) do
    local specials = {}
    for _, fw in ipairs(v.frameworks or {}) do
      table.insert(specials, (assert(frameworks[fw], 'unknown framework ' .. fw)))
    end
    for _, sql in ipairs(v.sqls or {}) do
      table.insert(specials, sqls[sql])
    end
    impls[k] = setfenv(assert(loadstring_untainted(v.src, '@./data/impl/' .. k .. '.lua'), k), _G)(unpack(specials))
  end

  local bubblewrap = require('wowless.bubblewrap')
  local typechecker = require('wowless.typecheck')(api)
  local funchecker = require('wowless.funcheck')(typechecker, api.log)

  local function stubMixin(t, name)
    return util.mixin(t, api.env[name])
  end

  local function mkfn(fname, apicfg, nowrap)
    local incheck = apicfg.inputs and funchecker.makeCheckInputs(fname, apicfg)
    local basefn
    if apicfg.stub then
      local text = ('local api, Mixin = ...; return function() %s end'):format(apicfg.stub)
      basefn = assert(setfenv(loadstring_untainted(text), _G))(api, stubMixin)
    elseif apicfg.impl then
      basefn = impls[apicfg.impl]
    else
      error(('invalid function %q'):format(fname))
    end
    local outcheck = apicfg.impl and apicfg.outputs and funchecker.makeCheckOutputs(fname, apicfg)
    local outfn
    if not incheck and not outcheck then
      outfn = basefn
    elseif incheck and not outcheck then
      outfn = function(...)
        return basefn(incheck(...))
      end
    elseif not incheck and outcheck then
      outfn = function(...)
        return outcheck(basefn(...))
      end
    else
      outfn = function(...)
        return outcheck(basefn(incheck(...)))
      end
    end
    if nowrap then
      return outfn
    else
      return bubblewrap(outfn)
    end
  end

  local rawfns = {}
  local fns = {}
  for fn, apicfg in pairs(apis) do
    if apicfg.stdlib then
      local v = assert(util.tget(_G, fn))
      util.tset(fns, fn, v)
      util.tset(rawfns, fn, v)
    else
      util.tset(fns, fn, mkfn(fn, apicfg))
      util.tset(rawfns, fn, mkfn(fn, apicfg, true))
    end
  end
  api.log(1, 'functions loaded')
  return fns, rawfns
end

return {
  loadFunctions = loadFunctions,
}
