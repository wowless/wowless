describe('xmlcontainment', function()
  local xmlcontainment = require('tools.xmlcontainment')

  describe('frameChains', function()
    it('finds a direct child', function()
      local xml = {
        Frame = { contents = { tags = { Leaf = true } } },
        Leaf = {},
      }
      local chains, ambiguous = xmlcontainment.frameChains(xml, 'Frame')
      assert.same({ 'Frame', 'Leaf' }, chains.Leaf)
      assert.same({}, ambiguous)
    end)

    it('walks through wrapper tags to find the shortest chain', function()
      local xml = {
        Frame = { contents = { tags = { Wrap = true } } },
        Wrap = { contents = { tags = { Leaf = true } } },
        Leaf = {},
      }
      local chains = xmlcontainment.frameChains(xml, 'Frame')
      assert.same({ 'Frame', 'Wrap', 'Leaf' }, chains.Leaf)
    end)

    it('matches a tag reachable only via its extends chain', function()
      local xml = {
        Base = {},
        Frame = { contents = { tags = { Base = true } } },
        Sub = { extends = 'Base' },
      }
      local chains = xmlcontainment.frameChains(xml, 'Frame')
      assert.same({ 'Frame', 'Base' }, chains.Base)
      assert.same({ 'Frame', 'Sub' }, chains.Sub)
    end)

    it('does not mark a tag reachable if nothing accepts it', function()
      local xml = {
        Frame = { contents = { tags = {} } },
        Orphan = {},
      }
      local chains = xmlcontainment.frameChains(xml, 'Frame')
      assert.is_nil(chains.Orphan)
    end)

    it('sealed stops extends-chain climbing for containment purposes', function()
      local xml = {
        Base = {},
        Frame = { contents = { tags = { Base = true } } },
        Sub = { extends = 'Base', sealed = true },
      }
      local chains = xmlcontainment.frameChains(xml, 'Frame')
      assert.same({ 'Frame', 'Base' }, chains.Base)
      assert.is_nil(chains.Sub)
    end)

    it('sealed does not affect a tag reachable via its own declared contents', function()
      local xml = {
        Base = {},
        Frame = { contents = { tags = { Sub = true } } },
        Sub = { extends = 'Base', sealed = true },
      }
      local chains = xmlcontainment.frameChains(xml, 'Frame')
      assert.same({ 'Frame', 'Sub' }, chains.Sub)
    end)

    it('marks a tag ambiguous when two equally-shallow parents both accept it', function()
      local xml = {
        A = { contents = { tags = { Leaf = true } } },
        B = { contents = { tags = { Leaf = true } } },
        Frame = { contents = { tags = { A = true, B = true } } },
        Leaf = {},
      }
      local chains, ambiguous = xmlcontainment.frameChains(xml, 'Frame')
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
      local chains, ambiguous = xmlcontainment.frameChains(xml, 'Frame')
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
      local chains, ambiguous = xmlcontainment.frameChains(xml, 'Frame', 'B')
      assert.same({ 'Frame', 'B', 'Leaf' }, chains.Leaf)
      assert.is_nil(ambiguous.Leaf)
    end)

    it('preferParent does not affect tags with only one candidate', function()
      local xml = {
        A = { contents = { tags = { Leaf = true } } },
        Frame = { contents = { tags = { A = true } } },
        Leaf = {},
      }
      local chains = xmlcontainment.frameChains(xml, 'Frame', 'NeverAppears')
      assert.same({ 'Frame', 'A', 'Leaf' }, chains.Leaf)
    end)

    it('rediscovers the root tag as an ordinary two-hop descendant of itself', function()
      local xml = {
        Frame = { contents = { tags = { Wrap = true } } },
        Wrap = { contents = { tags = { Frame = true } } },
      }
      local chains = xmlcontainment.frameChains(xml, 'Frame')
      assert.same({ 'Frame', 'Wrap', 'Frame' }, chains.Frame)
    end)
  end)

  describe('identityHops', function()
    it('finds no hops when nothing in the chain has identity', function()
      local hasIdentity = {}
      assert.same({}, xmlcontainment.identityHops(hasIdentity, { 'Frame', 'Wrap', 'Leaf' }))
    end)

    it('finds every identity-bearing position after the root', function()
      local hasIdentity = { B = true, D = true }
      local chain = { 'Frame', 'Wrap', 'B', 'Wrap2', 'D' }
      assert.same({ 3, 5 }, xmlcontainment.identityHops(hasIdentity, chain))
    end)

    it('ignores the root even if it has identity', function()
      local hasIdentity = { Frame = true, Leaf = true }
      assert.same({ 3 }, xmlcontainment.identityHops(hasIdentity, { 'Frame', 'Wrap', 'Leaf' }))
    end)
  end)

  describe('hopKey', function()
    it('uses the plain key for the last hop', function()
      assert.equal('foo', xmlcontainment.hopKey('foo', 2, 2))
      assert.equal('foo', xmlcontainment.hopKey('foo', 1, 1))
    end)

    it('suffixes earlier hops', function()
      assert.equal('foo_1', xmlcontainment.hopKey('foo', 1, 2))
      assert.equal('foo_2', xmlcontainment.hopKey('foo', 2, 3))
    end)
  end)

  describe('objectPath', function()
    it('is empty when the chain has no identity hops', function()
      local hasIdentity = {}
      assert.same({}, xmlcontainment.objectPath(hasIdentity, { 'Frame', 'Wrap', 'Leaf' }, 'key'))
    end)

    it('is a single hop when only the leaf has identity', function()
      local hasIdentity = { Slider = true }
      assert.same({ 'key' }, xmlcontainment.objectPath(hasIdentity, { 'Frame', 'Frames', 'Slider' }, 'key'))
    end)

    it('suffixes scaffolding hops and keeps the plain key for the leaf', function()
      local hasIdentity = { AnimationGroup = true, Animation = true }
      local chain = { 'Frame', 'Animations', 'AnimationGroup', 'Animation' }
      assert.same({ 'key_1', 'key' }, xmlcontainment.objectPath(hasIdentity, chain, 'key'))
    end)
  end)

  describe('templateElement', function()
    it('renders a single-hop leaf with its attribute', function()
      local hasIdentity = { Slider = true }
      local chain = { 'Frame', 'Frames', 'Slider' }
      local element = xmlcontainment.templateElement(hasIdentity, chain, 'orientation', 'key', 'VERTICAL')
      assert.same({
        tag = 'Frames',
        { orientation = 'VERTICAL', parentKey = 'key', tag = 'Slider' },
      }, element)
    end)

    it('renders scaffolding hops with their own parentKey, nested down to the leaf', function()
      local hasIdentity = { AnimationGroup = true, Animation = true }
      local chain = { 'Frame', 'Animations', 'AnimationGroup', 'Animation' }
      local element = xmlcontainment.templateElement(hasIdentity, chain, 'smoothing', 'key', 'NONE')
      assert.same({
        tag = 'Animations',
        {
          parentKey = 'key_1',
          tag = 'AnimationGroup',
          { parentKey = 'key', smoothing = 'NONE', tag = 'Animation' },
        },
      }, element)
    end)

    it('renders a wrapper-only chain with no parentKey', function()
      local hasIdentity = {}
      local chain = { 'Frame', 'Layers', 'Layer' }
      local element = xmlcontainment.templateElement(hasIdentity, chain, 'level', 'key', 'ARTWORK')
      assert.same({
        tag = 'Layers',
        { level = 'ARTWORK', tag = 'Layer' },
      }, element)
    end)
  end)
end)
