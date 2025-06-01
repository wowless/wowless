local function flatten(p)
  local out = {}
  local stack = { { '', p } }
  local sn = 1
  repeat
    local s, t = unpack(stack[sn])
    sn = sn - 1
    if type(t.calls) == 'number' then
      out[s] = t
    else
      for k, v in pairs(t) do
        sn = sn + 1
        stack[sn] = { s .. '.' .. k, v }
      end
    end
  until sn == 0
  return out
end

local function capture(x)
  local mark = {}
  local function getfuncstats(t)
    local tt = {}
    for k, v in pairs(t) do
      if type(k) == 'string' and not mark[v] then
        mark[v] = true
        if type(v) == 'function' then
          tt[k] = debug.getfunctionstats(v)
        elseif type(v) == 'table' then
          local tv = getfuncstats(v)
          if tv and next(tv) then
            tt[k] = tv
          end
        end
      end
    end
    return tt
  end
  return getfuncstats(x)
end

local function write(tt)
  local f = assert(io.open('profile.' .. tt.product .. '.txt', 'w'))
  for k, v in pairs(flatten(capture(tt))) do
    f:write(('%s\t%d\t%d\t%d\n'):format(k, v.calls, v.ownticks, v.subticks))
  end
  f:close()
end

return {
  write = write,
}
