describe('yaml', function()
  local yaml = require('wowapi.yaml')
  describe('parse', function()
    it('works on empty', function()
      assert.same({}, yaml.parse('\n'))
    end)
    it('works on all types', function()
      local input = [[
bool: true
number: 42
string: foo
empty_string: ''
sequence:
- 99
- bar
record:
  baz: quux
  frob: nicate
]]
      local expected = {
        bool = true,
        number = 42,
        string = 'foo',
        empty_string = '',
        sequence = { 99, 'bar' },
        record = { baz = 'quux', frob = 'nicate' },
      }
      assert.same(expected, yaml.parse(input))
    end)
  end)
  describe('pprint', function()
    it('works on empty', function()
      assert.same('\n', yaml.pprint({}))
    end)
  end)
end)
