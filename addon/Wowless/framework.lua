local _, G = ...

local function process(success, ...)
  local n = select('#', ...)
  local arg = ...
  if success then
    if n == 1 and type(arg) == 'table' then
      for k, v in pairs(arg) do
        assert(type(k) == 'string' and k ~= '', 'invalid test: bad return key')
        assert(type(v) == 'function', 'invalid test: bad return value')
      end
      return arg
    else
      assert(n == 0, 'invalid test: bad return')
    end
  else
    return tostring(arg)
  end
end

local function nexttest(state)
  local scope, stack = unpack(state)
  local top = table.remove(stack)
  while type(top) == 'string' do
    if top == '' then
      table.remove(scope)
    else
      table.insert(scope, top)
    end
    top = table.remove(stack)
  end
  if not top then
    return
  end
  local arg = process(pcall(top))
  if type(arg) == 'table' then
    local keys = {}
    for k in pairs(arg) do
      table.insert(keys, k)
    end
    table.sort(keys)
    for i = #keys, 1, -1 do
      local k = keys[i]
      table.insert(stack, '')
      table.insert(stack, arg[k])
      table.insert(stack, k)
    end
    return scope, nil
  else
    return scope, arg
  end
end

local function tests(fn, ...)
  assert(type(fn) == 'function', 'usage: test(fn)')
  assert(select('#', ...) == 0, 'usage: test(fn)')
  return nexttest, { {}, { fn } }
end

G.tests = tests
