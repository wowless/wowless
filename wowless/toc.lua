local flavors = require('runtime.flavors')

local suffixes = {}
for k, v in pairs(flavors) do
  local t = {
    '_' .. k,
    '-' .. k,
  }
  for _, alt in ipairs(v.alternates) do
    table.insert(t, '_' .. alt)
    table.insert(t, '-' .. alt)
  end
  table.insert(t, '_Standard')
  table.insert(t, '-Standard')
  table.insert(t, '')
  suffixes[k] = t
end

local function parse(flavor, content)
  assert(flavors[flavor])
  content = content:gsub('%[Family%]', flavor)
  local attrs = {}
  local files = {}
  for line in content:gmatch('[^\r\n]+') do
    line = line:match('^%s*(.-)%s*$')
    if line:sub(1, 3) == '## ' then
      local key, value = line:match('([^:]+): (.*)', 4)
      if key then
        attrs[key] = value
      end
    elseif line ~= '' and line:sub(1, 1) ~= '#' then
      table.insert(files, line)
    end
  end
  return attrs, files
end

return {
  parse = parse,
  suffixes = suffixes,
}
