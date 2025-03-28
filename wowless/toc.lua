local flavors = require('runtime.flavors')

local gametypes = {}
for k, v in pairs(flavors) do
  local t = {}
  for _, gt in ipairs(v.gametypes) do
    t[gt] = true
  end
  gametypes[k] = t
end

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
  local gts = assert(gametypes[flavor])
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
      local file, filter, fdata = line:match('^(.-)%s*%[(.-)%s+(.-)%]$')
      file = file or line
      local function allow()
        if not filter or filter == 'AllowLoad' and fdata == 'Game' then
          return true
        end
        if filter == 'AllowLoadGameType' then
          for gametype in fdata:gmatch('[^, ]+') do
            if gts[gametype] then
              return true
            end
          end
        end
      end
      if allow() then
        table.insert(files, file)
      end
    end
  end
  return attrs, files
end

return {
  parse = parse,
  suffixes = suffixes,
}
