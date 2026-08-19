describe('prettywrite', function()
  local prettywrite = require('tools.prettywrite')

  local cases = {
    ['false'] = { input = false, expected = 'false' },
    ['true'] = { input = true, expected = 'true' },
    integer = { input = 42, expected = '42' },
    ['negative integer'] = { input = -7, expected = '-7' },
    ['large integer'] = { input = 2147483648, expected = '2147483648' },
    float = { input = 1.5, expected = tostring(1.5) },
    string = { input = 'hello', expected = '"hello"' },
    ['string with quotes'] = { input = 'say "hi"', expected = '"say \\"hi\\""' },
    ['empty table'] = { input = {}, expected = '{}' },
  }

  local inline_cases = {
    array = { input = { 1, 2, 3 }, expected = '{1, 2, 3}' },
    map = { input = { a = 1, b = 2 }, expected = '{a = 1, b = 2}' },
    ['non-identifier key'] = { input = { ['foo-bar'] = 1 }, expected = '{["foo-bar"] = 1}' },
    ['numeric non-array key'] = { input = { [0] = 1 }, expected = '{[0] = 1}' },
    ['sorted keys'] = { input = { c = 3, a = 1, b = 2 }, expected = '{a = 1, b = 2, c = 3}' },
    ['keyword key'] = { input = { ['and'] = 1 }, expected = '{["and"] = 1}' },
  }

  local multiline_cases = {
    array = { input = { 1, 2 }, expected = '{\n  1,\n  2,\n}' },
    map = { input = { a = 1, b = 2 }, expected = '{\n  a = 1,\n  b = 2,\n}' },
    nested = { input = { x = { y = 1 } }, expected = '{\n  x = {\n    y = 1,\n  },\n}' },
  }

  for name, c in pairs(cases) do
    it(name, function()
      assert.equal(c.expected, prettywrite(c.input))
    end)
  end

  describe('inline', function()
    for name, c in pairs(inline_cases) do
      it(name, function()
        assert.equal(c.expected, prettywrite(c.input, true))
      end)
    end
  end)

  describe('multiline', function()
    for name, c in pairs(multiline_cases) do
      it(name, function()
        assert.equal(c.expected, prettywrite(c.input))
      end)
    end
  end)

  it('roundtrip', function()
    local t = { a = 1, b = { 2, 3 }, c = true }
    assert.same(t, assert(loadstring('return ' .. prettywrite(t)))())
  end)
end)
