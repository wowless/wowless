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
      -- "or nil" allows table-returning directsql to satisfy a nilable output
      return f(s) or nil
    end,
  },
}

return function(datalua, sqlitedb)
  local ret = {}
  for k, v in pairs(datalua.sqls) do
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
