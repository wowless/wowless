local T, DecodeBase64, EncodeBase64 = ...

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
    -- \251\255\000 exercises positions 62 and 63 in the alphabet.
    return {
      standard = function()
        return make_tests({
          empty = { arg = '', ret = '' },
          one = { arg = 'f', ret = 'Zg==' },
          two = { arg = 'fo', ret = 'Zm8=' },
          three = { arg = 'foo', ret = 'Zm9v' },
          six = { arg = 'foobar', ret = 'Zm9vYmFy' },
          binary = { arg = '\251\255\000', ret = '+/8A' },
        }, EncodeBase64, 0)
      end,
      url = function()
        return make_tests({
          binary = { arg = '\251\255\000', ret = '-_8A' },
        }, EncodeBase64, 1)
      end,
      unspecified = function()
        return T.match(1, 'Zg==', EncodeBase64('f'))
      end,
      number = function()
        return T.match(1, 'NDI=', EncodeBase64(42))
      end,
      string_variant = function()
        return T.match(1, '-_8A', EncodeBase64('\251\255\000', '1'))
      end,
      no_args = function()
        return T.match(
          2,
          false,
          'bad argument #1 to \'?\' (Usage: local output = C_EncodingUtil.EncodeBase64(source [, variant]))',
          pcall(EncodeBase64)
        )
      end,
      bad_variant = function()
        return T.match(
          2,
          false,
          'bad argument #2 to \'?\' (Usage: local output = C_EncodingUtil.EncodeBase64(source [, variant]))',
          pcall(EncodeBase64, 'f', 2)
        )
      end,
    }
  end,
  decode = function()
    return {
      standard = function()
        return make_tests({
          empty = { arg = '', ret = '' },
          one = { arg = 'Zg==', ret = 'f' },
          two = { arg = 'Zm8=', ret = 'fo' },
          three = { arg = 'Zm9v', ret = 'foo' },
          six = { arg = 'Zm9vYmFy', ret = 'foobar' },
          invalid = { arg = '!!!!', ret = '' },
        }, DecodeBase64, 0)
      end,
      url = function()
        return make_tests({
          binary = { arg = '-_8A', ret = '\251\255\000' },
          no_pad = { arg = 'Zg', ret = '' },
        }, DecodeBase64, 1)
      end,
      unspecified = function()
        return T.match(1, 'f', DecodeBase64('Zg=='))
      end,
      string_variant = function()
        return T.match(1, '\251\255\000', DecodeBase64('-_8A', '1'))
      end,
      no_args = function()
        return T.match(
          2,
          false,
          'bad argument #1 to \'?\' (Usage: local output = C_EncodingUtil.DecodeBase64(source [, variant]))',
          pcall(DecodeBase64)
        )
      end,
      bad_variant = function()
        return T.match(
          2,
          false,
          'bad argument #2 to \'?\' (Usage: local output = C_EncodingUtil.DecodeBase64(source [, variant]))',
          pcall(DecodeBase64, 'Zg==', 2)
        )
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
