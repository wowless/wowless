local args = (function()
  local parser = require('argparse')()
  parser:argument('product', 'product to process')
  return parser:parse()
end)()

local lfs = require('lfs')
local writeFile = require('pl.file').write
local parseYaml = require('wowapi.yaml').parseFile
local pprintYaml = require('wowapi.yaml').pprint
local product = args.product

local function deref(t, ...)
  for i = 1, select('#', ...) do
    assert(type(t) == 'table')
    local k = select(i, ...)
    t = t[k]
    if t == nil then
      return nil
    end
  end
  return t
end

local docs = {}
do
  local mixmt = {
    __index = function()
      return function() end
    end,
  }
  local nummt = {
    __index = function()
      return 42
    end,
  }
  local nsmt = {
    __index = function()
      return setmetatable({}, nummt)
    end,
  }
  local schema = require('wowapi.yaml').parseFile('data/schemas/docs.yaml').type
  local function processDocDir(docdir)
    if lfs.attributes(docdir) then
      for f in lfs.dir(docdir) do
        if f:sub(-4) == '.lua' then
          local success, err = pcall(setfenv(loadfile(docdir .. '/' .. f), {
            APIDocumentation = {
              AddDocumentationTable = function(_, t)
                require('wowapi.schema').validate(product, schema, t)
                docs[f] = t
              end,
            },
            Constants = setmetatable({}, nsmt),
            CreateFromMixins = function()
              return setmetatable({}, mixmt)
            end,
            Enum = setmetatable({}, nsmt),
          }))
          if not success then
            print(('error loading %s: %s'):format(f, err))
          end
        end
      end
    end
  end
  local prefix = 'extracts/' .. product .. '/Interface/AddOns/'
  processDocDir(prefix .. 'Blizzard_APIDocumentation')
  processDocDir(prefix .. 'Blizzard_APIDocumentationGenerated')
end

local config = parseYaml('data/products/' .. product .. '/config.yaml').docs
local enum = parseYaml('data/products/' .. product .. '/globals.yaml').Enum

local tabs, funcs, events = {}, {}, {}
for _, t in pairs(docs) do
  if not t.Type or t.Type == 'System' then
    for _, tab in ipairs(t.Tables or {}) do
      local name = (t.Namespace and (t.Namespace .. '.') or '') .. tab.Name
      assert(not tabs[name])
      tabs[name] = tab
    end
    for _, func in ipairs(t.Functions or {}) do
      local name = (t.Namespace and (t.Namespace .. '.') or '') .. func.Name
      assert(not funcs[name])
      funcs[name] = func
    end
    for _, event in ipairs(t.Events or {}) do
      local name = (t.Namespace and (t.Namespace .. '.') or '') .. event.Name
      assert(not events[name])
      events[name] = event
    end
  end
end

local types = {
  BigInteger = 'number',
  BigUInteger = 'number',
  bool = 'boolean',
  CalendarEventID = 'string',
  ChatBubbleFrame = 'table',
  ClubId = 'string',
  ClubInvitationId = 'string',
  ClubStreamId = 'string',
  cstring = 'string',
  fileID = 'number',
  FramePoint = 'string', -- hack, yes
  GarrisonFollower = 'string',
  HTMLTextType = 'string',
  InventorySlots = 'number',
  ItemInfo = 'string',
  kstringClubMessage = 'string',
  kstringLfgListApplicant = 'string',
  kstringLfgListChat = 'string',
  kstringLfgListSearch = 'string',
  luaIndex = 'number',
  ModelSceneFrame = 'table',
  ModelSceneFrameActor = 'table',
  NamePlateFrame = 'table',
  NotificationDbId = 'string',
  number = 'number',
  RecruitAcceptanceID = 'string',
  ScriptRegion = 'table',
  SimpleFrame = 'table',
  SimpleTexture = 'table',
  string = 'string',
  table = 'table',
  TBFStyleFlags = 'string',
  textureAtlas = 'string',
  textureKit = 'string',
  time_t = 'number',
  TooltipComparisonItem = 'table',
  uiAddon = 'uiAddon',
  UiMapPoint = 'table',
  uiUnit = 'number',
  UnitToken = 'unit',
  WeeklyRewardItemDBID = 'string',
  WOWGUID = 'string',
  WOWMONEY = 'number',
}
local tys = {}
for name, tab in pairs(tabs) do
  tys[name] = tab.Type
end
for k in pairs(parseYaml('data/products/' .. product .. '/structures.yaml')) do
  if tys[k] and tys[k] ~= 'Structure' then
    error(('%s is a wowless structure but is a %s in docs'):format(k, tys[k]))
  else
    tys[k] = 'Structure'
  end
end
for k in pairs(enum) do
  if tys[k] and tys[k] ~= 'Enumeration' then
    error(('%s is a wowless enum but is a %s in docs'):format(k, tys[k]))
  else
    tys[k] = 'Enumeration'
  end
end
local knownMixinStructs = {
  ColorMixin = 'colorRGBA',
  ItemLocationMixin = 'ItemLocation',
  ItemTransmogInfoMixin = 'ItemTransmogInfo',
  PlayerLocationMixin = 'PlayerLocation',
  ReportInfoMixin = 'ReportInfo',
  TransmogLocationMixin = 'TransmogLocation',
  TransmogPendingInfoMixin = 'TransmogPendingInfo',
  Vector2DMixin = 'vector2',
  Vector3DMixin = 'vector3',
}
local structRewrites = {
  AzeriteEmpoweredItemLocation = 'ItemLocation',
  AzeriteItemLocation = 'ItemLocation',
  EmptiableItemLocation = 'ItemLocation',
}
local function t2nty(field, ns)
  local t = field.Type
  if field.InnerType then
    assert(t == 'table')
    return { arrayof = t2nty({ Type = field.InnerType }, ns) }
  elseif t == 'table' and field.Mixin then
    local mst = assert(knownMixinStructs[field.Mixin], 'no struct for mixin ' .. field.Mixin)
    return { mixin = field.Mixin, structure = mst }
  elseif types[t] then
    return types[t]
  end
  local n = ns and tys[ns .. '.' .. t] and (ns .. '.' .. t) or t
  n = structRewrites[n] or n
  local ty = tys[n]
  assert(ty, 'wtf ' .. n)
  if ty == 'Constants' then
    return 'number'
  elseif ty == 'Enumeration' then
    return { enum = t }
  elseif ty == 'Structure' then
    return { mixin = field.Mixin, structure = n }
  elseif ty == 'CallbackType' then
    return 'function'
  else
    error(('%s has unexpected type %s'):format(n, ty))
  end
end

local function split(name)
  local dotpos = name:find('%.')
  if not dotpos then
    return nil, name
  else
    return name:sub(1, dotpos - 1), name:sub(dotpos + 1)
  end
end

local function rewriteApis()
  local function insig(fn, ns)
    local t = {}
    for _, a in ipairs(fn.Arguments or {}) do
      table.insert(t, {
        default = a.Default,
        name = a.Name,
        nilable = a.Nilable or nil,
        type = t2nty(a, ns),
      })
    end
    return t
  end
  local function outsig(fn, ns)
    local outputs = {}
    for _, r in ipairs(fn.Returns or {}) do
      table.insert(outputs, {
        default = enum[r.Type] and enum[r.Type][r.Default] or r.Default,
        name = r.Name,
        nilable = r.Nilable or nil,
        type = t2nty(r, ns),
      })
    end
    return outputs
  end
  local cfgskip = deref(config, 'apis', 'skip_namespaces') or {}
  local function skip(apis, name)
    local ns = split(name)
    if ns and cfgskip[ns] then
      return true
    end
    local api = apis[name]
    if not api then
      return false
    end
    if api.impl then
      return true
    end
    for _, out in ipairs(api.outputs or {}) do
      if out.stub then
        return true
      end
    end
    return false
  end
  local y = require('wowapi.yaml')
  local f = 'data/products/' .. product .. '/apis.yaml'
  local apis = y.parseFile(f)
  local nss = {}
  for name, fn in pairs(funcs) do
    nss[split(name) or ''] = true
    if not skip(apis, name) then
      local ns = split(name)
      apis[name] = {
        inputs = { insig(fn, ns) },
        outputs = outsig(fn, ns),
      }
    end
  end
  for k in pairs(cfgskip) do
    assert(nss[k], k .. ' in skip_namespaces but not in docs')
  end
  require('pl.file').write(f, y.pprint(apis))
  return apis
end

local function rewriteEvents()
  local filename = ('data/products/%s/events.yaml'):format(product)
  local neversent = deref(config, 'events', 'never_sent') or {}
  local out = require('wowapi.yaml').parseFile(filename)
  local seen = {}
  for name, ev in pairs(events) do
    seen[ev.LiteralName] = true
    local ns = split(name)
    out[ev.LiteralName] = {
      payload = (function()
        if neversent[ev.LiteralName] then
          return nil
        end
        local t = {}
        for _, arg in ipairs(ev.Payload or {}) do
          table.insert(t, {
            name = arg.Name,
            nilable = arg.Nilable or nil,
            type = t2nty(arg, ns),
          })
        end
        return t
      end)(),
    }
  end
  for k in pairs(neversent) do
    assert(seen[k], k .. ' is marked never_sent but not present in docs')
  end
  writeFile(filename, pprintYaml(out))
  return out
end

local function rewriteStructures(outApis, outEvents)
  local stubs = {
    FramePoint = 'CENTER',
  }
  local filename = ('data/products/%s/structures.yaml'):format(product)
  local structures = require('wowapi.yaml').parseFile(filename)
  for name, tab in pairs(tabs) do
    if tab.Type == 'Structure' then
      local ns = split(name)
      structures[name] = (function()
        local ret = {}
        for _, f in ipairs(tab.Fields) do
          ret[f.Name] = {
            default = enum[f.Type] and enum[f.Type][f.Default] or f.Default,
            nilable = f.Nilable or nil,
            stub = deref(structures, name, f.Name, 'stub') or stubs[f.Type],
            type = t2nty(f, ns),
          }
        end
        return ret
      end)()
    end
  end
  local out = {}
  -- Only write transitive closure of referenced structures.
  local function processType(ty)
    if ty.structure and not out[ty.structure] then
      out[ty.structure] = structures[ty.structure]
      for _, v in pairs(structures[ty.structure]) do
        processType(v.type)
      end
    elseif ty.arrayof then
      processType(ty.arrayof)
    end
  end
  local function processList(xs)
    for _, x in ipairs(xs or {}) do
      processType(x.type)
    end
  end
  for _, api in pairs(outApis) do
    for _, ilist in ipairs(api.inputs or {}) do
      processList(ilist)
    end
    processList(api.outputs)
  end
  for _, event in pairs(outEvents) do
    processList(event.payload)
  end
  writeFile(filename, pprintYaml(out))
end

local outApis = rewriteApis()
local outEvents = rewriteEvents()
rewriteStructures(outApis, outEvents)
