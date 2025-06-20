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
      file = file or line
      local function allow()
        if not filter or filter == 'AllowLoad' and fdata == 'Game' then
          return true
        end
        if filter == 'AllowLoadGameType' then
          for gt in fdata:gmatch('[^, ]+') do
            if gts[gt] then
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
