local _, G = ...

local function test(fn, ...)
  assert(type(fn) == 'function', 'usage: test(fn)')
  assert(select('#', ...) == 0, 'usage: test(fn)')
  local function process(success, ...)
    local n = select('#', ...)
    local arg = ...
    if success then
      if n == 1 and type(arg) == 'table' then
        local failures = {}
        for k, v in pairs(arg) do
          assert(type(k) == 'string', 'invalid test: bad return key')
          assert(type(v) == 'function', 'invalid test: bad return value')
          failures[k] = process(pcall(v))
        end
        return next(failures) and failures or nil
      else
        assert(n == 0, 'invalid test: bad return')
      end
    else
      return tostring(arg)
    end
  end
  return process(pcall(fn))
end

G.test = test
