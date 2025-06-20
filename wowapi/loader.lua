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
  local impls = {}
  for k, v in pairs(datalua.impls) do
    impls[k] = setfenv(loadstring(v, '@./data/impl/' .. k .. '.lua'), _G)
  end

  local frameworks = {
    api = api, -- TODO replace api framework with something finer grained
    datalua = api.datalua,
    env = api.env,
    events = api.events,
    loader = loader,
  }

  local bubblewrap = require('wowless.bubblewrap')
  local typechecker = require('wowless.typecheck')(api)
  local funchecker = require('wowless.funcheck')(typechecker)

  local function stubMixin(t, name)
    return util.mixin(t, api.env[name])
  end

  local function mkfn(fname, apicfg, nowrap)
    local basefn
    if apicfg.stub then
      local text = ('local api, Mixin = ...; return function() %s end'):format(apicfg.stub)
      basefn = assert(setfenv(loadstring(text), _G))(api, stubMixin)
    elseif apicfg.impl then
      basefn = impls[apicfg.impl]
    else
      error(('invalid function %q'):format(fname))
    end

    local specials = {}
    for _, fw in ipairs(apicfg.frameworks or {}) do
      table.insert(specials, (assert(frameworks[fw], 'unknown framework ' .. fw)))
    end
    for _, sql in ipairs(apicfg.sqls or {}) do
      table.insert(specials, sqls[sql])
    end
    local specialfn
    if apicfg.closure then
      specialfn = basefn(unpack(specials))
    elseif not next(specials) then
      specialfn = basefn
    else
      local nspecials = #specials
      specialfn = function(...)
        local t = {}
        for _, v in ipairs(specials) do
          table.insert(t, v)
        end
        local n = select('#', ...)
        for i = 1, n do
          t[nspecials + i] = select(i, ...)
        end
        return basefn(unpack(t, 1, nspecials + n))
      end
    end

    local edepth = 2
    local infn
    if not apicfg.inputs then
      infn = specialfn
    else
      local sig = apicfg.inputs
      local nsig = #apicfg.inputs
      infn = function(...)
        local args = {}
        for i, param in ipairs(sig) do
          local v, errmsg, iswarn = typechecker(param, (select(i, ...)))
          if not errmsg then
            args[i] = v
          else
            local msg = ('arg %d (%q) of %q %s'):format(i, tostring(param.name), fname, errmsg)
            if iswarn then
              api.log(1, 'warning: ' .. msg)
            else
              error(msg)
            end
          end
        end
        if select('#', ...) > nsig then
          local d = debug.getinfo(edepth)
          api.log(1, 'warning: too many arguments passed to %s at %s:%d', fname, d.source:sub(2), d.currentline)
        end
        return specialfn(unpack(args, 1, nsig))
      end
    end

    local outfn
    if not apicfg.impl or not apicfg.outputs then
      outfn = infn
    else
      edepth = edepth + 1
      local doCheckOutputs = funchecker.makeCheckOutputs(fname, apicfg)
      outfn = function(...)
        return doCheckOutputs(infn(...))
      end
    end

    if nowrap then
      return outfn
    else
      edepth = edepth + 2
      return debug.newcfunction(bubblewrap(outfn))
    end
  end

  local rawfns = {}
  local fns = {}
  local aliases = {}
  for fn, apicfg in pairs(apis) do
    if apicfg.alias then
      aliases[fn] = apicfg.alias
    elseif apicfg.stdlib then
      local v = assert(util.tget(_G, fn))
      util.tset(fns, fn, v)
      util.tset(rawfns, fn, v)
    else
      util.tset(fns, fn, mkfn(fn, apicfg))
      util.tset(rawfns, fn, mkfn(fn, apicfg, true))
    end
  end
  for k, v in pairs(aliases) do
    util.tset(fns, k, util.tget(fns, v))
    util.tset(rawfns, k, util.tget(rawfns, v))
  end
  api.log(1, 'functions loaded')
  return fns, rawfns
end

return {
  loadFunctions = loadFunctions,
}
