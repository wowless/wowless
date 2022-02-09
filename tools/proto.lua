local assert = require('luassert')
local function proto2api(s)
  local ast = require('metalua.compiler').new():src_to_ast(s)
  assert.same(1, #ast)
  assert.same('Call', ast[1].tag)
  assert.same(1, #ast[1])
  local name
  if ast[1][1].tag == 'Id' then
    assert.same(1, #ast[1][1])
    name = ast[1][1][1]
  elseif ast[1][1].tag == 'Index' then
    assert.same(2, #ast[1][1])
    assert.same('Id', ast[1][1][1].tag)
    assert.same(1, #ast[1][1][1])
    assert.same('String', ast[1][1][2].tag)
    assert.same(1, #ast[1][1][2])
    name = ast[1][1][1][1] .. '.' .. ast[1][1][2][1]
  else
    error('unexpected tag ' .. ast[1][1].tag)
  end
  return {
    name = name,
    status = 'unimplemented',
    flavors = { 'Mainline' },
    inputs = { {} },
    outputs = {},
  }
end

local api = proto2api(io.read('*a'))
local filename = ('data/api/%s.yaml'):format(api.name)
require('pl.file').write(filename, require('wowapi.yaml').pprint(api))
print(filename)
