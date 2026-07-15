describe('xmlcontainment', function()
  local xmlcontainment = require('tools.xmlcontainment')

  it('finds a direct child', function()
    local xml = {
      Frame = { contents = { tags = { Leaf = true } } },
      Leaf = {},
    }
    local chains, ambiguous = xmlcontainment.chains(xml, 'Frame')
    assert.same({ 'Frame', 'Leaf' }, chains.Leaf)
    assert.same({}, ambiguous)
  end)

  it('walks through wrapper tags to find the shortest chain', function()
    local xml = {
      Frame = { contents = { tags = { Wrap = true } } },
      Wrap = { contents = { tags = { Leaf = true } } },
      Leaf = {},
    }
    local chains = xmlcontainment.chains(xml, 'Frame')
    assert.same({ 'Frame', 'Wrap', 'Leaf' }, chains.Leaf)
  end)

  it('matches a tag reachable only via its extends chain', function()
    local xml = {
      Base = {},
      Frame = { contents = { tags = { Base = true } } },
      Sub = { extends = 'Base' },
    }
    local chains = xmlcontainment.chains(xml, 'Frame')
    assert.same({ 'Frame', 'Base' }, chains.Base)
    assert.same({ 'Frame', 'Sub' }, chains.Sub)
  end)

  it('does not mark a tag reachable if nothing accepts it', function()
    local xml = {
      Frame = { contents = { tags = {} } },
      Orphan = {},
    }
    local chains = xmlcontainment.chains(xml, 'Frame')
    assert.is_nil(chains.Orphan)
  end)

  it('sealed stops extends-chain climbing for containment purposes', function()
    local xml = {
      Base = {},
      Frame = { contents = { tags = { Base = true } } },
      Sub = { extends = 'Base', sealed = true },
    }
    local chains = xmlcontainment.chains(xml, 'Frame')
    assert.same({ 'Frame', 'Base' }, chains.Base)
    assert.is_nil(chains.Sub)
  end)

  it('sealed does not affect a tag reachable via its own declared contents', function()
    local xml = {
      Base = {},
      Frame = { contents = { tags = { Sub = true } } },
      Sub = { extends = 'Base', sealed = true },
    }
    local chains = xmlcontainment.chains(xml, 'Frame')
    assert.same({ 'Frame', 'Sub' }, chains.Sub)
  end)

  it('marks a tag ambiguous when two equally-shallow parents both accept it', function()
    local xml = {
      A = { contents = { tags = { Leaf = true } } },
      B = { contents = { tags = { Leaf = true } } },
      Frame = { contents = { tags = { A = true, B = true } } },
      Leaf = {},
    }
    local chains, ambiguous = xmlcontainment.chains(xml, 'Frame')
    assert.is_true(ambiguous.Leaf)
    assert.is_not_nil(chains.Leaf)
  end)

  it('does not mark a tag ambiguous when a second route is strictly deeper', function()
    local xml = {
      A = { contents = { tags = { Leaf = true } } },
      B = { contents = { tags = { Leaf = true } } },
      C = { contents = { tags = { B = true } } },
      Frame = { contents = { tags = { A = true, C = true } } },
      Leaf = {},
    }
    local chains, ambiguous = xmlcontainment.chains(xml, 'Frame')
    assert.same({ 'Frame', 'A', 'Leaf' }, chains.Leaf)
    assert.is_nil(ambiguous.Leaf)
  end)

  it('preferParent resolves a tie without marking it ambiguous', function()
    local xml = {
      A = { contents = { tags = { Leaf = true } } },
      B = { contents = { tags = { Leaf = true } } },
      Frame = { contents = { tags = { A = true, B = true } } },
      Leaf = {},
    }
    local chains, ambiguous = xmlcontainment.chains(xml, 'Frame', 'B')
    assert.same({ 'Frame', 'B', 'Leaf' }, chains.Leaf)
    assert.is_nil(ambiguous.Leaf)
  end)

  it('preferParent does not affect tags with only one candidate', function()
    local xml = {
      A = { contents = { tags = { Leaf = true } } },
      Frame = { contents = { tags = { A = true } } },
      Leaf = {},
    }
    local chains = xmlcontainment.chains(xml, 'Frame', 'NeverAppears')
    assert.same({ 'Frame', 'A', 'Leaf' }, chains.Leaf)
  end)

  it('rediscovers the root tag as an ordinary two-hop descendant of itself', function()
    local xml = {
      Frame = { contents = { tags = { Wrap = true } } },
      Wrap = { contents = { tags = { Frame = true } } },
    }
    local chains = xmlcontainment.chains(xml, 'Frame')
    assert.same({ 'Frame', 'Wrap', 'Frame' }, chains.Frame)
  end)
end)
