local function prettywrite(v, inline)
  local function isid(s)
    return type(s) == 'string'
      and s:match('^[%a_][%w_]*$')
      and not ({
        ['and'] = 1,
        ['break'] = 1,
        ['do'] = 1,
        ['else'] = 1,
        ['elseif'] = 1,
        ['end'] = 1,
        ['false'] = 1,
        ['for'] = 1,
        ['function'] = 1,
        ['goto'] = 1,
        ['if'] = 1,
        ['in'] = 1,
        ['local'] = 1,
        ['nil'] = 1,
        ['not'] = 1,
        ['or'] = 1,
        ['repeat'] = 1,
        ['return'] = 1,
        ['then'] = 1,
        ['true'] = 1,
        ['until'] = 1,
        ['while'] = 1,
      })[s]
  end
  local function numstr(n)
    if n == math.floor(n) and math.abs(n) < 2 ^ 53 then
      return string.format('%.0f', n)
    end
    return tostring(n)
  end
  local function rec(x, depth)
    local t = type(x)
    if t == 'boolean' then
      return tostring(x)
    elseif t == 'number' then
      return numstr(x)
    elseif t == 'string' then
      return string.format('%q', x)
    elseif t == 'table' then
      local parts = {}
      local n = 0
      for i = 1, math.huge do
        if x[i] == nil then
          break
        end
        n = i
        table.insert(parts, rec(x[i], depth + 1))
      end
      local keys = {}
      for k in pairs(x) do
        if not (type(k) == 'number' and k >= 1 and k <= n and k == math.floor(k)) then
          table.insert(keys, k)
        end
      end
      table.sort(keys, function(a, b)
        return tostring(a) < tostring(b)
      end)
      for _, k in ipairs(keys) do
        local kstr
        if isid(k) then
          kstr = k .. ' = ' .. rec(x[k], depth + 1)
        else
          kstr = '[' .. rec(k, depth + 1) .. '] = ' .. rec(x[k], depth + 1)
        end
        table.insert(parts, kstr)
      end
      if #parts == 0 then
        return '{}'
      end
      if inline then
        return '{' .. table.concat(parts, ', ') .. '}'
      else
        local indent = string.rep('  ', depth + 1)
        local closing = string.rep('  ', depth)
        return '{\n' .. indent .. table.concat(parts, ',\n' .. indent) .. ',\n' .. closing .. '}'
      end
    else
      error('unsupported type ' .. t)
    end
  end
  return rec(v, 0)
end

return prettywrite
