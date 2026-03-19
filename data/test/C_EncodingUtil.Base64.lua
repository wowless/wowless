local T, DecodeBase64, EncodeBase64 = ...

-- \251\255\000 exercises positions 62 and 63 in the alphabet.
local encode = {
  empty = { arg = '', ret = '' },
  one = { arg = 'f', ret = 'Zg==' },
  two = { arg = 'fo', ret = 'Zm8=' },
  three = { arg = 'foo', ret = 'Zm9v' },
  six = { arg = 'foobar', ret = 'Zm9vYmFy' },
  standard = { arg = '\251\255\000', ret = '+/8A' },
}

local encodeurl = {
  urlsafe = { arg = '\251\255\000', ret = '-_8A' },
}

local decode = {
  empty = { arg = '', ret = '' },
  one = { arg = 'Zg==', ret = 'f' },
  two = { arg = 'Zm8=', ret = 'fo' },
  three = { arg = 'Zm9v', ret = 'foo' },
  six = { arg = 'Zm9vYmFy', ret = 'foobar' },
  invalid = { arg = '!!!!', ret = '' },
}

local decodeurl = {
  urlsafe = { arg = '-_8A', ret = '\251\255\000' },
  urlsafe_no_pad = { arg = 'Zg', ret = '' },
}

local function make_tests(cases, fn, variant)
  local tests = {}
  for name, c in pairs(cases) do
    tests[name] = function()
      return T.match(1, c.ret, fn(c.arg, variant))
    end
  end
  return tests
end

return {
  encode = function()
    return make_tests(encode, EncodeBase64, 0)
  end,
  encodeurl = function()
    return make_tests(encodeurl, EncodeBase64, 1)
  end,
  decode = function()
    return make_tests(decode, DecodeBase64, 0)
  end,
  decodeurl = function()
    return make_tests(decodeurl, DecodeBase64, 1)
  end,
  variant = function()
    return {
      unspecified = function()
        return T.match(1, 'Zg==', EncodeBase64('f'))
      end,
      string_one = function()
        return T.match(1, '-_8A', EncodeBase64('\251\255\000', '1'))
      end,
      bad_variant = function()
        return T.match(1, false, (pcall(EncodeBase64, 'f', 2)))
      end,
    }
  end,
  roundtrip = function()
    local all = {}
    for i = 0, 255 do
      all[i + 1] = string.char(i)
    end
    local allbytes = table.concat(all)
    return T.match(1, allbytes, DecodeBase64(EncodeBase64(allbytes)))
  end,
}
