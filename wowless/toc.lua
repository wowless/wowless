local gametypes = require('runtime.gametypes')

local allgttokens = {
  classic = true,
  mainline = true,
  wrath = true,
  cata = true,
  plunderstorm = true,
  wowhack = true,
  wowlabs = true,
}
for k in pairs(gametypes) do
  allgttokens[k:lower()] = true
end

local function suffixes(gametype, family)
  return {
    '_' .. gametype,
    '-' .. gametype,
    '_' .. family,
    '-' .. family,
    '',
  }
end

local filters = {
  AllowLoad = function(s)
    return s:lower() == 'game'
  end,
  AllowLoadEnvironment = function(s)
    assert(s:lower() == 'global', s)
    return true, s:lower()
  end,
  AllowLoadGameType = function(s, gts)
    for gt in s:lower():gmatch('[^, ]+') do
      assert(allgttokens[gt], gt)
      if gts[gt] then
        return true
      end
    end
  end,
  AllowLoadTextLocale = function()
    -- TODO implement
  end,
  Bootstrap = function()
    return true, true
  end,
  ExcludeLoadGameType = function(s, gts)
    for gt in s:lower():gmatch('[^, ]+') do
      assert(allgttokens[gt], gt)
      if gts[gt] then
        return
      end
    end
    return true
  end,
  LoadIntoEnvironment = function(s)
    assert(s == 'global' or s == 'secure', s)
    return true, s
  end,
}

local function parse(gametype, family, content)
  local gts = {
    [gametype:lower()] = true,
    [family:lower()] = true,
  }
  content = content:gsub('%[Game%]', gametype)
  content = content:gsub('%[Family%]', family)
  local toc = { attrs = {}, deps = {}, files = {}, optionaldeps = {} }
  for line in content:gmatch('[^\r\n]+') do
    local allok = true
    local tags = {}
    line = line:match('^%s*(.-)%s*$'):gsub('%[([^:%]%s]*):?%s*([^%]]-)%]', function(filter, fdata)
      local ok, tag = assert(filters[filter], filter)(fdata, gts)
      allok = allok and ok
      tags[filter] = tag
      return ''
    end)
    if allok and line:sub(1, 3) == '## ' then
      local key, value = line:match('([^:]+): (.*)', 4)
      if key then
        if key == 'Interface' then
          local arr = {}
          for v in value:gmatch('[^, ]+') do
            table.insert(arr, tonumber(v))
          end
          toc.interface = arr
        elseif key == 'SavedVariables' or key == 'SavedVariablesPerCharacter' then
          local arr = {}
          for var in value:gmatch('[^, ]+') do
            table.insert(arr, var)
          end
          toc[key:lower()] = arr
        elseif key:match('^OptionalDep') then
          for dep in value:gmatch('[^, ]+') do
            table.insert(toc.optionaldeps, dep)
          end
        elseif key:match('^Dep') or key:match('^RequiredDep') then
          for dep in value:gmatch('[^, ]+') do
            table.insert(toc.deps, dep)
          end
        else
          toc.attrs[key] = value
        end
      end
    elseif allok and line ~= '' and line:sub(1, 1) ~= '#' then
      tags.name = line:match('^([^%s]+)')
      table.insert(toc.files, tags)
    end
  end
  return toc
end

return {
  parse = parse,
  suffixes = suffixes,
}
