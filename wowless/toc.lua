local gametypes = require('runtime.gametypes')

local gttokens = {}
for k, v in pairs(gametypes) do
  gttokens[k] = {
    [k:lower()] = true,
    [v.family:lower()] = true,
  }
end

local suffixes = {}
for k, v in pairs(gametypes) do
  suffixes[k] = {
    '_' .. k,
    '-' .. k,
    '_' .. v.family,
    '-' .. v.family,
    '',
  }
end

local filters = {
  AllowLoad = function(s)
    return s:lower() == 'game'
  end,
  AllowLoadEnvironment = function(s)
    assert(s == 'Global', s)
    return true
  end,
  AllowLoadGameType = function(s, gts)
    for gt in s:gmatch('[^, ]+') do
      if gts[gt] then
        return true
      end
    end
  end,
  LoadIntoEnvironment = function(s)
    assert(s == 'secure', s)
    return true
  end,
}

local function parse(gametype, content)
  local gts = assert(gttokens[gametype])
  content = content:gsub('%[Game%]', gametype)
  content = content:gsub('%[Family%]', gametypes[gametype].family)
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
      local file, filter, fdata = line:match('^(.-)%s*%[(.-):?%s+(.-)%]$')
      if not filter or assert(filters[filter], filter)(fdata, gts) then
        table.insert(files, file or line)
      end
    end
  end
  return attrs, files
end

return {
  parse = parse,
  suffixes = suffixes,
}
