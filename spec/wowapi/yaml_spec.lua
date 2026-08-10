describe('yaml', function()
  local yaml = require('wowapi.yaml')
  local ystr = [[
bool: true
boolstr: 'true'
empty_string: ''
number: 42
numstr: '42'
record:
  baz: quux
  frob: nicate
sequence:
- 99
- bar
string: foo
]]
  local ytab = {
    bool = true,
    boolstr = 'true',
    empty_string = '',
    number = 42,
    numstr = '42',
    record = { baz = 'quux', frob = 'nicate' },
    sequence = { 99, 'bar' },
    string = 'foo',
  }
  describe('parse', function()
    it('works on empty', function()
      assert.same({}, yaml.parse('\n'))
    end)
    it('works on all types', function()
      assert.same(ytab, yaml.parse(ystr))
    end)
  end)
  describe('pprint', function()
    it('works on empty', function()
      assert.same('\n', yaml.pprint({}))
    end)
    it('works on all types', function()
      assert.same(ystr, yaml.pprint(ytab))
    end)
  end)
end)
