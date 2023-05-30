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
    local function base()
      if apicfg.stub then
        local text = ('local Mixin = ...; return function() %s end'):format(apicfg.stub)
        return assert(loadstring(text))(stubMixin)
      elseif apicfg.impl then
        return impls[apicfg.impl]
      else
        error(('invalid function %q'):format(fname))
      end
    end

    local function checkInputs(fn)
      if not apicfg.inputs then
        return fn
      end
      local sig = apicfg.inputs
      local nsig = #apicfg.inputs
      return function(...)
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
        return fn(unpack(args, 1, nsig))
      end
    end

    local function addSpecialArgs(fn)
      local args = {}
      for _, fw in ipairs(apicfg.frameworks or {}) do
        table.insert(args, (assert(frameworks[fw], 'unknown framework ' .. fw)))
      end
      for _, st in ipairs(apicfg.states or {}) do
        table.insert(args, api.states[st])
      end
      for _, sql in ipairs(apicfg.sqls or {}) do
        table.insert(args, sql.lookup and sqls.lookups[sql.lookup] or sqls.cursors[sql.cursor])
      end
      if not next(args) then
        return fn
      end
      return function(...)
        local t = {}
        for _, v in ipairs(args) do
          table.insert(t, v)
        end
        local n = select('#', ...)
        for i = 1, n do
          local v = select(i, ...)
          if i then
            t[#args + i] = v
          end
        end
        return fn(unpack(t, 1, #args + n))
      end
    end

    local function checkOutputs(fn)
      if not apicfg.outputs then
        return fn
      end
      local function doCheckOutputs(...)
        local n = select('#', ...)
        if n == 0 and apicfg.mayreturnnothing then
          return
        end
        if n > #apicfg.outputs then
          error('returned too many values from ' .. fname)
        end
        for i, out in ipairs(apicfg.outputs) do
          local _, errmsg = typechecker(out, (select(i, ...)))
          if errmsg then
            error(('output %d (%q) of %q %s'):format(i, tostring(out.name), fname, errmsg))
          end
        end
        return ...
      end
      return function(...)
        return doCheckOutputs(fn(...))
      end
    end

    local function maybeCWrap(fn)
      return apicfg.nowrap and fn or debug.newcfunction(fn)
    end

    return maybeCWrap(checkOutputs(checkInputs(addSpecialArgs(base()))))
  end

  local fns = {}
  local aliases = {}
  for fn, apicfg in pairs(apis) do
    if apicfg.alias then
      aliases[fn] = apicfg.alias
    elseif apicfg.stdlib then
      util.tset(fns, fn, assert(util.tget(_G, apicfg.stdlib)))
    else
      util.tset(fns, fn, mkfn(fn, apicfg))
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
