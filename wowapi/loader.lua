local util = require('wowless.util')

local function loadSqls(sqlitedb, cursorSqls, lookupSqls)
  local function lookup(stmt, isTable)
    if isTable then
      for row in stmt:nrows() do -- luacheck: ignore 512
        return row
      end
    else
      for row in stmt:rows() do -- luacheck: ignore 512
        return unpack(row)
      end
    end
  end
  local function cursor(stmt, isTable)
    if isTable then
      return stmt:nrows()
    else
      return stmt:urows()
    end
  end
  local function prep(fn, sql, f)
    local stmt = sqlitedb:prepare(sql.sql)
    if not stmt then
      error('could not prepare ' .. fn .. ': ' .. sqlitedb:errmsg())
    end
    return function(...)
      stmt:reset()
      stmt:bind_values(...)
      return f(stmt, sql.table)
    end
  end
  local lookups = {}
  for k, v in pairs(lookupSqls) do
    lookups[k] = prep(k, v, lookup)
  end
  local cursors = {}
  for k, v in pairs(cursorSqls) do
    cursors[k] = prep(k, v, cursor)
  end
  return {
    cursors = cursors,
    lookups = lookups,
  }
end

local function loadFunctions(api, loader)
  api.log(1, 'loading functions')
  local datalua = api.datalua
  local apis = datalua.apis
  local sqls = loadSqls(loader.sqlitedb, datalua.sqlcursors, datalua.sqllookups)
  local impls = {}
  for k, v in pairs(datalua.impls) do
    impls[k] = loadstring(v, '@./data/impl/' .. k .. '.lua')
  end

  local frameworks = {
    api = api, -- TODO replace api framework with something finer grained
    datalua = api.datalua,
    env = api.env,
    loader = loader,
  }

  local typechecker = require('wowless.typecheck')(api)

  local function stubMixin(t, name)
    return util.mixin(t, api.env[name])
  end

  local function mkfn(fname, apicfg)
    local basefn
    if apicfg.stub then
      local text = ('local Mixin = ...; return function() %s end'):format(apicfg.stub)
      basefn = assert(loadstring(text))(stubMixin)
    elseif apicfg.impl then
      basefn = impls[apicfg.impl]
    else
      error(('invalid function %q'):format(fname))
    end

    local specials = {}
    for _, fw in ipairs(apicfg.frameworks or {}) do
      table.insert(specials, (assert(frameworks[fw], 'unknown framework ' .. fw)))
    end
    for _, st in ipairs(apicfg.states or {}) do
      table.insert(specials, api.states[st])
    end
    for _, sql in ipairs(apicfg.sqls or {}) do
      table.insert(specials, sql.lookup and sqls.lookups[sql.lookup] or sqls.cursors[sql.cursor])
    end
    local specialfn
    if not next(specials) then
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
          local v = select(i, ...)
          if i then
            t[nspecials + i] = v
          end
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
      local nouts = #apicfg.outputs
      local function doCheckOutputs(...)
        local n = select('#', ...)
        if n == 0 and apicfg.mayreturnnothing then
          return
        end
        if n > nouts then
          error('returned too many values from ' .. fname)
        end
        local rets = {}
        for i, out in ipairs(apicfg.outputs) do
          local v, errmsg = typechecker(out, (select(i, ...)), true)
          if errmsg then
            error(('output %d (%q) of %q %s'):format(i, tostring(out.name), fname, errmsg))
          end
          rets[i] = v
        end
        return unpack(rets, 1, nouts)
      end
      outfn = function(...)
        return doCheckOutputs(infn(...))
      end
    end

    if apicfg.nowrap then
      return outfn
    else
      edepth = edepth + 1
      return debug.newcfunction(outfn)
    end
  end

  local fns = {}
  require('runtime.' .. datalua.product .. '.capi')(fns)
  local aliases = {}
  for fn, apicfg in pairs(apis) do
    if fns[fn] == nil then
      if apicfg.alias then
        aliases[fn] = apicfg.alias
      elseif apicfg.stdlib then
        util.tset(fns, fn, assert(util.tget(_G, apicfg.stdlib)))
      else
        util.tset(fns, fn, mkfn(fn, apicfg))
      end
    end
  end
  for k, v in pairs(aliases) do
    util.tset(fns, k, util.tget(fns, v))
  end
  api.log(1, 'functions loaded')
  return fns
end

return {
  loadFunctions = loadFunctions,
}
