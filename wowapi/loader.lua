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

local function resolveUnit(units, unit)
  -- TODO complete unit resolution
  local guid = units.aliases[unit:lower()]
  return guid and units.guids[guid] or nil
end

local function loadFunctions(api, loader)
  api.log(1, 'loading functions')
  local datalua = api.datalua
  local apis = datalua.apis
  local sqls = loadSqls(loader.sqlitedb, datalua.sqlcursors, datalua.sqllookups)
  local impls = {}
  for k, v in pairs(datalua.impls) do
    impls[k] = loadstring(v)
  end

  local enumrev = {}
  for k, v in pairs(datalua.globals.Enum) do
    local t = {}
    for vk, vv in pairs(v) do
      t[vv] = vk
    end
    enumrev[k] = t
  end

  local frameworks = {
    api = api, -- TODO replace api framework with something finer grained
    datalua = api.datalua,
    env = api.env,
    loader = loader,
  }
  local nilableTypes = {
    ['nil'] = true,
    oneornil = true,
    unknown = true,
  }
  local supportedTypes = {
    boolean = true,
    number = true,
    string = true,
  }

  local stubenv = setmetatable({}, {
    __index = function(_, k)
      return k == 'Mixin' and util.mixin or api.env[k]
    end,
    __metatable = 'stub metatable',
    __newindex = function()
      error('cannot modify _G from a stub')
    end,
  })

  local function typestr(ty)
    if type(ty) == 'string' then
      return ty
    end
    if ty.structure then
      return ty.structure
    end
    if ty.arrayof then
      return typestr(ty.arrayof) .. ' array'
    end
    if ty.enum then
      return ty.enum
    end
    error('unable to typestr')
  end

  local function mkfn(fname, apicfg)
    local function base()
      if apicfg.stub then
        return setfenv(assert(loadstring(apicfg.stub)), stubenv)
      elseif apicfg.impl then
        return impls[apicfg.impl]
      else
        error(('invalid function %q'):format(fname))
      end
    end

    local function checkArg(i, param, arg)
      if arg == nil then
        if not param.nilable and param.default == nil then
          error(('arg %d (%q) of %q is not nilable, but nil was passed'):format(i, tostring(param.name), fname))
        end
        return nil
      end
      local function checkarg(val, ty)
        if type(val) ~= ty then
          local fmt = 'arg %d (%q) of %q is of type %q, but %q was passed'
          error(fmt:format(i, tostring(param.name), fname, typestr(param.type), type(arg)))
        end
        return val
      end
      if param.type == 'number' then
        -- luaL_checknumber
        return checkarg(type(arg) == 'string' and tonumber(arg) or arg, 'number')
      elseif param.type == 'string' then
        -- luaL_checkstring
        return checkarg(type(arg) == 'number' and tostring(arg) or arg, 'string')
      elseif param.type == 'unit' then
        checkarg(arg, 'string')
        return resolveUnit(api.states.Units, arg)
      elseif param.type == 'uiAddon' then
        return api.states.Addons[tonumber(arg) or tostring(arg):lower()]
      elseif param.type == 'unknown' then
        return arg
      elseif param.type == 'function' or param.type == 'table' or param.type == 'boolean' then
        return checkarg(arg, param.type)
      elseif param.type.enum then
        local v = checkarg(type(arg) == 'string' and tonumber(arg) or arg, 'number')
        if not enumrev[param.type.enum][v] then
          local fmt = 'warning: arg %d (%q) of %q is of enum type %q, which does not have value %d'
          api.log(1, fmt, i, tostring(param.name), fname, param.type.enum, v)
        end
        return v
      elseif param.type.structure then
        -- TODO better structure checking
        return checkarg(arg, 'table')
      elseif param.type.arrayof then
        -- TODO better array checking
        return checkarg(arg, 'table')
      else
        error(('internal error: arg %d (%q) of %q has an invalid type'):format(i, tostring(param.name), fname))
      end
    end

    local function doCheckInputs(sig, ...)
      local args = {}
      for i, param in ipairs(sig) do
        args[i] = checkArg(i, param, (select(i, ...)))
      end
      return unpack(args, 1, select('#', ...))
    end

    local function checkInputs(fn)
      if not apicfg.inputs then
        return fn
      elseif #apicfg.inputs == 1 then
        return function(...)
          return fn(doCheckInputs(apicfg.inputs[1], ...))
        end
      else
        return function(...)
          local t = { ... }
          local n = select('#', ...)
          for _, sig in ipairs(apicfg.inputs) do
            local result = {
              pcall(function()
                return doCheckInputs(sig, unpack(t, 1, n))
              end),
            }
            if result[1] then
              return fn(unpack(result, 2, n + 1))
            end
          end
          error('args matched no input signature of ' .. fname)
        end
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

    local function addMixins(fn)
      local mixins = {}
      for idx, out in ipairs(apicfg.outputs or {}) do
        mixins[idx] = out.mixin
      end
      if not next(mixins) then
        return fn
      end
      local function doAddMixins(...)
        for idx, mixin in pairs(mixins) do
          local t = select(idx, ...)
          if t then
            util.mixin(t, api.env[mixin])
          end
        end
        return ...
      end
      return function(...)
        return doAddMixins(fn(...))
      end
    end

    local function checkOutputs(fn)
      if not apicfg.outputs then
        return fn
      end
      local function doCheckOutputs(...)
        if select('#', ...) == 0 and apicfg.mayreturnnothing then
          return
        end
        for i, out in ipairs(apicfg.outputs) do
          local arg = select(i, ...)
          if arg == nil then
            if not out.nilable and not nilableTypes[out.type] then
              error(('output %d (%q) of %q is not nilable, but nil was returned'):format(i, tostring(out.name), fname))
            end
          elseif supportedTypes[out.type] then
            local ty = type(arg)
            if ty ~= out.type then
              error(
                ('output %d (%q) of %q is of type %q, but %q was returned'):format(
                  i,
                  tostring(out.name),
                  fname,
                  out.type,
                  ty
                )
              )
            end
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

    return maybeCWrap(addMixins(checkOutputs(checkInputs(addSpecialArgs(base())))))
  end

  local fns = {}
  local aliases = {}
  for fn, apicfg in pairs(apis) do
    if apicfg.alias then
      aliases[fn] = apicfg.alias
    elseif apicfg.stdlib then
      util.tset(fns, fn, util.tget(_G, apicfg.stdlib))
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
