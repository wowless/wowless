local T, error, geterrorhandler, securecallfunction, seterrorhandler = ...

local function callWithHandler(...)
  local oldhandler = geterrorhandler()
  local err
  seterrorhandler(function(e)
    err = e
  end)
  local results = { pcall(securecallfunction, ...) }
  seterrorhandler(oldhandler)
  T.assertEquals(true, results[1])
  return err, unpack(results, 2)
end

return {
  ['no args'] = function()
    return T.match(1, 'attempt to call a nil value', callWithHandler())
  end,
  ['nil arg'] = function()
    return T.match(1, 'attempt to call a nil value', callWithHandler(nil))
  end,
  ['noop function'] = function()
    return T.match(1, nil, callWithHandler(function() end))
  end,
  ['error with message'] = function()
    return T.match(1, 'oops', callWithHandler(error, 'oops'))
  end,
  ['passes args and returns values'] = function()
    return T.match(
      3,
      nil,
      11,
      50,
      callWithHandler(function(a, b, c)
        return a + 1, b + c
      end, 10, 20, 30)
    )
  end,
}
