describe('prettywrite', function()
  local prettywrite = require('tools.prettywrite')

  local cases = {
    { 'false', false, 'false' },
    { 'true', true, 'true' },
    { 'integer', 42, '42' },
    { 'negative integer', -7, '-7' },
    { 'large integer', 2147483648, '2147483648' },
    { 'float', 1.5, tostring(1.5) },
    { 'string', 'hello', '"hello"' },
    { 'string with quotes', 'say "hi"', '"say \\"hi\\""' },
    { 'empty table', {}, '{}' },
  }

  local inline_cases = {
    { 'array', { 1, 2, 3 }, '{1, 2, 3}' },
    { 'map', { a = 1, b = 2 }, '{a = 1, b = 2}' },
    { 'non-identifier key', { ['foo-bar'] = 1 }, '{["foo-bar"] = 1}' },
    { 'numeric non-array key', { [0] = 1 }, '{[0] = 1}' },
    { 'sorted keys', { c = 3, a = 1, b = 2 }, '{a = 1, b = 2, c = 3}' },
    { 'keyword key', { ['and'] = 1 }, '{["and"] = 1}' },
  }

  local multiline_cases = {
    { 'array', { 1, 2 }, '{\n  1,\n  2,\n}' },
    { 'map', { a = 1, b = 2 }, '{\n  a = 1,\n  b = 2,\n}' },
    { 'nested', { x = { y = 1 } }, '{\n  x = {\n    y = 1,\n  },\n}' },
  }

  for _, c in ipairs(cases) do
    it(c[1], function()
      assert.equal(c[3], prettywrite(c[2]))
    end)
  end

  describe('inline', function()
    for _, c in ipairs(inline_cases) do
      it(c[1], function()
        assert.equal(c[3], prettywrite(c[2], true))
      end)
    end
  end)

  describe('multiline', function()
    for _, c in ipairs(multiline_cases) do
      it(c[1], function()
        assert.equal(c[3], prettywrite(c[2]))
      end)
    end
  end)

  it('roundtrip', function()
    local t = { a = 1, b = { 2, 3 }, c = true }
    assert.same(t, assert(loadstring('return ' .. prettywrite(t)))())
  end)
end)
