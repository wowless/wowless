local function mixin(t, ...)
  for _, kv in ipairs({...}) do
    for k, v in pairs(kv) do
      t[k] = v
    end
  end
  return t
end

local function recursiveMixin(t, u, failOnOverwrite)
  for k, v in pairs(u) do
    local tv = t[k]
    if tv == nil or type(tv) ~= 'table' or type(v) ~= 'table' then
      assert(tv == nil or not failOnOverwrite, ("overwriting %q"):format(k))
      t[k] = v
    else
      recursiveMixin(tv, v, failOnOverwrite)
    end
  end
  return t
end

local function readfile(filename)
  local f = assert(io.open(filename:gsub('\\', '/'), 'rb'))
  local content = f:read('*all')
  f:close()
  if content:sub(1, 3) == '\239\187\191' then
    content = content:sub(4)
  end
  return content
end

local function strjoin(sep, ...)
  return table.concat({...}, sep)
end

local function strsplit(sep, s, n)
  assert(string.len(sep) == 1)
  assert(n == nil)
  local result = {}
  while true do
    local pos = string.find(s, '%' .. sep)
    if not pos then
      table.insert(result, s)
      return unpack(result)
    end
    table.insert(result, s:sub(0, pos - 1))
    s = s:sub(pos + 1)
  end
end

local function strtrim(s)
  local ret = s:gsub('^%s*', ''):gsub('%s*$', '')
  return ret
end

local function tappend(t, t2)
  for _, v in ipairs(t2) do
    table.insert(t, v)
  end
  return t
end

local function twipe(t)
  for k in pairs(t) do
    t[k] = nil
  end
  return t
end

return {
  mixin = mixin,
  readfile = readfile,
  recursiveMixin = recursiveMixin,
  strjoin = strjoin,
  strsplit = strsplit,
  strtrim = strtrim,
  tappend = tappend,
  twipe = twipe,
}
