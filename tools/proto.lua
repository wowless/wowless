local args = (function()
  local parser = require('argparse')()
  parser:option('-t --type', 'default type', 'string')
  return parser:parse()
end)()

local assert = require('luassert')

local function ident(n)
  if n.tag == 'Id' then
    return n[1]
  elseif n.tag == 'Index' then
    assert.same(2, #n)
    assert.same('Id', n[1].tag)
    assert.same('String', n[2].tag)
    return n[1][1] .. '.' .. n[2][1]
  elseif n.tag == 'Invoke' then
    assert.same(2, #n)
    assert.same('Id', n[1].tag)
    assert.same('String', n[2].tag)
    return n[1][1] .. '.' .. n[2][1]
  else
    error('unexpected tag ' .. tostring(n.tag))
  end
end

local function call(n)
  assert.same('Call', n.tag)
  local inputs = {}
  for i = 2, #n do
    table.insert(inputs, {
      name = ident(n[i]),
      type = args.type,
    })
  end
  return ident(n[1]), inputs
end

local function proto2api(s)
  local ast = require('metalua.compiler').new():src_to_ast(s)
  assert.same(1, #ast)
  local n = ast[1]
  local inputs, name
  local outputs = {}
  if n.tag == 'Call' then
    name, inputs = call(n)
  elseif n.tag == 'Local' or n.tag == 'Set' then
    assert.same(2, #n)
    for _, id in ipairs(n[1]) do
      table.insert(outputs, {
        name = ident(id),
        type = args.type,
      })
    end
    assert.same(1, #n[2])
    name, inputs = call(n[2][1])
  else
    error('unexpected tag ' .. n.tag)
  end
  return {
    name = name,
    status = 'unimplemented',
    inputs = { inputs },
    outputs = outputs,
  }
end

local api = proto2api(io.read('*a'))
local filename = ('data/api/%s.yaml'):format(api.name)
do
  local success, existingApi = pcall(function()
    return require('wowapi.yaml').parseFile(filename)
  end)
  api.products = success and existingApi.products or nil
end
require('pl.file').write(filename, require('wowapi.yaml').pprint(api))
print(filename)
