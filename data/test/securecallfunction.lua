local T, securecallfunction = ...

local function callWithHandler(...)
  local oldhandler = T.env.geterrorhandler()
  local errors = {}
  T.env.seterrorhandler(function(err)
    table.insert(errors, err)
  end)
  local function pack(...)
    return select('#', ...), ...
  end
  local results = { pack(pcall(securecallfunction, ...)) }
  T.env.seterrorhandler(oldhandler)
  return errors, unpack(results)
end

return {
  ['no args'] = function()
    local errors, n = callWithHandler()
    T.assertEquals(1, n)
    T.assertEquals(1, #errors)
  end,
  ['nil arg'] = function()
    local errors, n = callWithHandler(nil)
    T.assertEquals(1, n)
    T.assertEquals(1, #errors)
  end,
  ['noop function'] = function()
    local errors, n, r1 = callWithHandler(function() end)
    T.assertEquals(1, n)
    T.assertEquals(true, r1)
    T.assertEquals(0, #errors)
  end,
  ['error with message'] = function()
    local errors, n, r1 = callWithHandler(T.env.error, 'oops')
    T.assertEquals(1, n)
    T.assertEquals(true, r1)
    T.assertEquals(1, #errors)
    T.assertEquals('oops', errors[1])
  end,
  ['passes args and returns values'] = function()
    local errors, n, r1, r2, r3 = callWithHandler(function(a, b, c)
      return a + 1, b + c
    end, 10, 20, 30)
    T.assertEquals(3, n)
    T.assertEquals(true, r1)
    T.assertEquals(11, r2)
    T.assertEquals(50, r3)
    T.assertEquals(0, #errors)
  end,
}
