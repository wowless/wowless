local assert = require('luassert')

local function call2name(n)
  assert.same('Call', n.tag)
  assert.same(1, #n)
  n = n[1]
  if n.tag == 'Id' then
    return n[1]
  elseif n.tag == 'Index' then
    assert.same(2, #n)
    assert.same('Id', n[1].tag)
    assert.same('String', n[2].tag)
    return n[1][1] .. '.' .. n[2][1]
  else
    error('unexpected tag ' .. tostring(n.tag))
  end
end

local function proto2api(s)
  local ast = require('metalua.compiler').new():src_to_ast(s)
  assert.same(1, #ast)
  local n = ast[1]
  local outputs = {}
  local name
  if n.tag == 'Call' then
    name = call2name(n)
  elseif n.tag == 'Local' then
    assert.same(2, #n)
    for _, id in ipairs(n[1]) do
      assert.same('Id', id.tag)
      table.insert(outputs, {
        name = id[1],
        type = 'number',
      })
    end
    assert.same(1, #n[2])
    name = call2name(n[2][1])
  else
    error('unexpected tag ' .. n.tag)
  end
  return {
    name = name,
    status = 'unimplemented',
    inputs = { {} },
    outputs = outputs,
  }
end

local api = proto2api(io.read('*a'))
local filename = ('data/api/%s.yaml'):format(api.name)
require('pl.file').write(filename, require('wowapi.yaml').pprint(api))
print(filename)
