local assert = require('luassert')

local function apiName(n)
  if n.tag == 'Id' then
    return n[1]
  elseif n.tag == 'Index' then
    assert.same(2, #n)
    assert.same('Id', n[1].tag)
    assert.same('String', n[2].tag)
    return n[1][1] .. '.' .. n[2][1]
  else
    error('unexpected tag ' .. n.tag)
  end
end

local function proto2api(s)
  local ast = require('metalua.compiler').new():src_to_ast(s)
  assert.same(1, #ast)
  assert.same('Call', ast[1].tag)
  assert.same(1, #ast[1])
  local name = apiName(ast[1][1])
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
