local dbcrows = require('dbc').rows

local function colsig(f)
  local ty = f.type
  if ty == 'string' then
    return 's'
  elseif ty == 'float' then
    return '.' -- luadbc is sometimes broken on floats :(
  elseif ty == 'int' then
    assert(f.size <= 32, 'wide ints not supported')
    return f.unsigned and 'u' or 'i'
  else
    error('invalid column type ' .. ty)
  end
end

local function rows(content, dbdef)
  if content:sub(1, 4) == 'WDC4' then
    content = 'WDC3' .. content:sub(5)
  end
  -- TODO remove sig arg support
  if type(dbdef) == 'string' then
    return dbcrows(content, dbdef)
  end
  local sig = ''
  local fieldindices = {}
  local idx = 1
  local n = #dbdef
  for i = 1, n do
    local f = dbdef[i]
    if not f.noninline then
      local cs = colsig(f)
      sig = sig .. cs
      if f.length then
        sig = sig .. string.rep('.', f.length - 1)
      end
      if cs ~= '.' then
        fieldindices[i] = idx
        idx = idx + 1
      end
    elseif f.relation then
      assert(f.type == 'int')
      sig = sig .. 'F'
      fieldindices[i] = idx
      idx = idx + 1
    elseif f.id then
      fieldindices[i] = 0
    else
      error('invalid column')
    end
  end
  local iterfn, iterdata = dbcrows(content, '{' .. sig .. '}')
  local function wrapfn(...)
    local row = iterfn(...)
    if row then
      local t = {}
      for i = 1, n do
        local k = fieldindices[i]
        t[i] = k and row[k]
      end
      return t
    end
  end
  return wrapfn, iterdata
end

return {
  rows = rows,
}
