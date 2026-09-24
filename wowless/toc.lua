local function suffixes(gametype, family)
  return {
    '_' .. gametype,
    '-' .. gametype,
    '_' .. family,
    '-' .. family,
    '',
  }
end

local function countMatches(s, state)
  local positives, negatives = 0, 0
  for gt in s:lower():gmatch('[^, ]+') do
    local st = state[gt]
    if st == true then
      positives = positives + 1
    elseif st == false then
      negatives = negatives + 1
    end
  end
  return positives, negatives
end

local filters = {
  AllowLoad = function(s)
    return s:lower() == 'game'
  end,
  AllowLoadEnvironment = function(s)
    assert(s:lower() == 'global', s)
    return true, s:lower()
  end,
  AllowLoadGameType = function(s, state)
    local positives, negatives = countMatches(s, state)
    return positives > 0 or negatives == 0
  end,
  AllowLoadTextLocale = function()
    -- TODO implement
  end,
  Bootstrap = function()
    return true, true
  end,
  ExcludeLoadGameType = function(s, state)
    local positives = countMatches(s, state)
    return positives == 0
  end,
  LoadIntoEnvironment = function(s)
    assert(s == 'global' or s == 'secure', s)
    return true, s
  end,
}

local function parse(gametype, family, content, excluded)
  local state = {}
  for k in pairs(excluded) do
    state[k] = false
  end
  state[gametype:lower()] = true
  state[family:lower()] = true
  content = content:gsub('%[Game%]', gametype)
  content = content:gsub('%[Family%]', family)
  local toc = { attrs = {}, deps = {}, files = {}, optionaldeps = {} }
  for line in content:gmatch('[^\r\n]+') do
    local allok = true
    local tags = {}
    line = line:match('^%s*(.-)%s*$'):gsub('%[([^:%]%s]*):?%s*([^%]]-)%]', function(filter, fdata)
      local ok, tag = assert(filters[filter], filter)(fdata, state)
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
