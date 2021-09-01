local function flatdump(top)
  local refs = {}
  local refidx = {}
  local stack = {}
  local function newref(x, t)
    local tt = {}
    table.insert(refs, tt)
    table.insert(stack, { x, tt })
    local rx = t .. #refs
    refidx[x] = rx
    return rx
  end
  local function process(x)
    if x == nil then
      return nil
    end
    local rx, tx = refidx[x], type(x)
    if rx then
      return rx
    elseif tx == 'string' then
      return 's' .. x
    elseif tx == 'number' then
      return 'n' .. tostring(x)
    elseif tx == 'boolean' then
      return 'b' .. tostring(x)
    elseif tx == 'userdata' then
      return newref(x, 'u')
    elseif tx == 'function' then
      return newref(x, 'f')
    elseif tx == 'table' then
      return newref(x, 't')
    else
      error('unknown type ' .. tx)
    end
  end
  process(top)
  while #stack > 0 do
    local x, tt = unpack(table.remove(stack))
    local tx = type(x)
    if tx == 'table' then
      for k, v in pairs(x) do
        tt[process(k)] = process(v)
      end
      tt.m = process(getmetatable(x))
    elseif tx == 'userdata' then
      tt.m = process(getmetatable(x))
    elseif tx == 'function' then
      tt.e = process(getfenv(x))
    else
      error('invalid type ' .. tx)
    end
  end
  return refs
end

local buildinfo = { _G.GetBuildInfo() }
local data = flatdump(_G)

do
  local frame = _G.CreateFrame('Frame')
  frame:RegisterEvent('PLAYER_LOGOUT')
  frame:SetScript('OnEvent', function()
    _G.WowlessSaverBuildInfo = buildinfo
    _G.WowlessSaverData = data
  end)
end
