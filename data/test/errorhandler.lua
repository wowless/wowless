local T, error, geterrorhandler, securecallfunction, seterrorhandler = ...

local tests = {
  ['get returns set function'] = function()
    local fn = function() end
    seterrorhandler(fn)
    T.check1(fn, geterrorhandler())
  end,
  ['round trip'] = function()
    local saved = geterrorhandler()
    local fn = function() end
    seterrorhandler(fn)
    seterrorhandler(saved)
    T.check1(saved, geterrorhandler())
  end,
  ['second set replaces first'] = function()
    local fn1 = function() end
    local fn2 = function() end
    seterrorhandler(fn1)
    seterrorhandler(fn2)
    T.check1(fn2, geterrorhandler())
  end,
  ['set nil throws'] = function()
    T.check2(false, 'Usage: seterrorhandler(errfunc)', pcall(seterrorhandler, nil))
  end,
  ['set returns nothing'] = function()
    T.check0(seterrorhandler(function() end))
  end,
  ['string error delivered to handler'] = function()
    local received
    seterrorhandler(function(e)
      received = e
    end)
    securecallfunction(error, 'hello')
    T.assertEquals('hello', received)
  end,
  ['table error delivered to handler'] = function()
    local received
    seterrorhandler(function(e)
      received = e
    end)
    local t = { key = 'value' }
    securecallfunction(error, t)
    T.assertEquals('UNKNOWN ERROR', received)
  end,
}

local ret = {}
for k, v in pairs(tests) do
  ret[k] = function()
    local old = geterrorhandler()
    local ok, err = pcall(v)
    seterrorhandler(old)
    if not ok then
      error(err, 2)
    end
  end
end
return ret
