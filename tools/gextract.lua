local recursiveMixin = require('wowless.util').recursiveMixin
local sub = string.sub

local function luaEnums(data, r)
  local result = {}
  for k, v in data:tpairs(r) do
    if sub(k, 1, 4) == 'sLE_' or sub(k, 1, 8) == 'sNUM_LE_' then
      result[sub(k, 2)] = data:resolve(v)
    end
  end
  return result
end

local function otherConstants(data)
  local keys = {
    'BINDING_HEADER_MOVEMENT',
    'ITEM_QUALITY0_DESC',
    'ITEM_QUALITY1_DESC',
    'ITEM_QUALITY2_DESC',
    'ITEM_QUALITY3_DESC',
    'ITEM_QUALITY4_DESC',
    'ITEM_QUALITY5_DESC',
    'ITEM_QUALITY6_DESC',
    'ITEM_QUALITY7_DESC',
    'ITEM_QUALITY8_DESC',
    'ITEM_QUALITY9_DESC',
    'UK_AADC_POPUP_TEXT',
  }
  local result = {}
  for _, k in ipairs(keys) do
    result[k] = data:resolve(data:global('s' .. k))
  end
  return result
end

do
  local scrape = require('tools.scrapelib')(arg[1])
  print(string.format('function GetBuildInfo()\n  return %q, %q, %q, %d\nend', unpack(scrape.BuildInfo)))
  local data = scrape.Data

  local result = {}
  recursiveMixin(result, { Constants = data:resolve(data:global('sConstants')) })
  recursiveMixin(result, { Constants = data:resolve(data:capsule('sConstants')) })
  recursiveMixin(result, { Enum = data:resolve(data:global('sEnum')) })
  recursiveMixin(result, { Enum = data:resolve(data:capsule('sEnum')) })
  recursiveMixin(result, luaEnums(data, data:global()))
  recursiveMixin(result, luaEnums(data, data:capsule()))
  recursiveMixin(result, otherConstants(data))

  local keys = {}
  for k in pairs(result) do
    table.insert(keys, k)
  end
  table.sort(keys)
  local pretty = require('pl.pretty').write
  for _, k in ipairs(keys) do
    print(k .. ' = ' .. pretty(result[k]))
  end
end
