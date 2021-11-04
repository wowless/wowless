local function yamlquote(s)
  if type(s) ~= 'string' or s:match('^[a-zA-Z][a-zA-Z0-9_.-]*$') then
    return tostring(s)
  else
    return '\'' .. s .. '\''
  end
end

local fieldOrder = {
  'name',
  'status',
  'comment',
  'versions',
  'inputs',
  'outputs',
  'mixin',
  'protected',
  'returns',
  'module',
  'api',
}

local function isarray(t)
  local i = 0
  for _ in pairs(t) do
    i = i + 1
    if t[i] == nil then
      return false
    end
  end
  return true
end

local function table2yaml(t, indent)
  local strs = {}
  local prefix = string.rep(' ', indent)
  if not next(t) then
    table.insert(strs, ' {}\n')
  elseif isarray(t) then
    table.insert(strs, '\n')
    for _, value in ipairs(t) do
      if value == require('lyaml').null then
        table.insert(strs, ('%s- null\n'):format(prefix))
      elseif type(value) == 'table' then
        table.insert(strs, ('%s-'):format(prefix))
        table.insert(strs, table2yaml(value, indent+2))
      else
        table.insert(strs, ('%s- %s\n'):format(prefix, yamlquote(value)))
      end
    end
  else
    table.insert(strs, '\n')
    local sortedKeys = {}
    for name in pairs(t) do
      table.insert(sortedKeys, name)
    end
    table.sort(sortedKeys)
    local names = {}
    for _, name in ipairs(indent == 0 and fieldOrder or {}) do
      table.insert(names, name)
    end
    for _, name in ipairs(sortedKeys) do
      table.insert(names, name)
    end
    local handled = {}
    for _, name in ipairs(names) do
      local value = t[name]
      if value and not handled[name] then
        handled[name] = true
        if type(value) == 'table' then
          table.insert(strs, ('%s%s:'):format(prefix, name))
          table.insert(strs, table2yaml(value, indent+2))
        else
          table.insert(strs, ('%s%s: %s\n'):format(prefix, name, yamlquote(value)))
        end
      end
    end
  end
  return table.concat(strs, '')
end

local parse = require('lyaml').load

return {
  parse = parse,
  parseFile = function(f)
    local file = io.open(f, 'r')
    local str = file:read('*all')
    file:close()
    return parse(str)
  end,
  pprint = function(t)
    return '---' .. table2yaml(t, 0)
  end,
}
