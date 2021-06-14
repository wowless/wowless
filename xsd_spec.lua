local xsd = dofile('xsd.lua')

describe('xsd.lua', function()
  local function run(s)
    return xsd.loadXmlString(s)
  end

  it('fails on empty string', function()
    assert.has_error(function() run('') end, 'missing root')
  end)
  it('fails on wrong root', function()
    assert.has_error(function() run('<nope>lol</nope>') end, 'wrong root')
  end)
  it('works on empty', function()
    assert.same({}, run('<xs:schema/>'))
  end)
end)
