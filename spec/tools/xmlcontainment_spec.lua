describe('xmlcontainment', function()
  local xmlcontainment = require('tools.xmlcontainment')

  describe('chains', function()
    local cases = {
      ['finds a direct child'] = {
        xml = { Frame = { contents = { tags = { Leaf = true } } }, Leaf = {} },
        chains = { Frame = { 'Frame' }, Leaf = { 'Frame', 'Leaf' } },
      },
      ['walks through wrapper tags to find the shortest chain'] = {
        xml = {
          Frame = { contents = { tags = { Wrap = true } } },
          Wrap = { contents = { tags = { Leaf = true } } },
          Leaf = {},
        },
        chains = {
          Frame = { 'Frame' },
          Wrap = { 'Frame', 'Wrap' },
          Leaf = { 'Frame', 'Wrap', 'Leaf' },
        },
      },
      ['matches a tag reachable only via its extends chain'] = {
        xml = {
          Base = {},
          Frame = { contents = { tags = { Base = true } } },
          Sub = { extends = 'Base' },
        },
        chains = {
          Frame = { 'Frame' },
          Base = { 'Frame', 'Base' },
          Sub = { 'Frame', 'Sub' },
        },
      },
      ['does not mark a tag reachable if nothing accepts it'] = {
        xml = { Frame = { contents = { tags = {} } }, Orphan = {} },
        chains = { Frame = { 'Frame' } },
      },
      ['sealed stops extends-chain climbing for containment purposes'] = {
        xml = {
          Base = {},
          Frame = { contents = { tags = { Base = true } } },
          Sub = { extends = 'Base', sealed = true },
        },
        chains = { Frame = { 'Frame' }, Base = { 'Frame', 'Base' } },
      },
      ['sealed does not affect a tag reachable via its own declared contents'] = {
        xml = {
          Base = {},
          Frame = { contents = { tags = { Sub = true } } },
          Sub = { extends = 'Base', sealed = true },
        },
        chains = { Frame = { 'Frame' }, Sub = { 'Frame', 'Sub' } },
      },
      ['does not mark a tag ambiguous when a second route is strictly deeper'] = {
        xml = {
          A = { contents = { tags = { Leaf = true } } },
          B = { contents = { tags = { Leaf = true } } },
          C = { contents = { tags = { B = true } } },
          Frame = { contents = { tags = { A = true, C = true } } },
          Leaf = {},
        },
        chains = {
          Frame = { 'Frame' },
          A = { 'Frame', 'A' },
          C = { 'Frame', 'C' },
          B = { 'Frame', 'C', 'B' },
          Leaf = { 'Frame', 'A', 'Leaf' },
        },
      },
      ['preferParent resolves a tie without marking it ambiguous'] = {
        xml = {
          A = { contents = { tags = { Leaf = true } } },
          B = { contents = { tags = { Leaf = true } } },
          Frame = { contents = { tags = { A = true, B = true } } },
          Leaf = {},
        },
        preferParent = 'B',
        chains = {
          Frame = { 'Frame' },
          A = { 'Frame', 'A' },
          B = { 'Frame', 'B' },
          Leaf = { 'Frame', 'B', 'Leaf' },
        },
      },
      ['preferParent does not affect tags with only one candidate'] = {
        xml = {
          A = { contents = { tags = { Leaf = true } } },
          Frame = { contents = { tags = { A = true } } },
          Leaf = {},
        },
        preferParent = 'NeverAppears',
        chains = {
          Frame = { 'Frame' },
          A = { 'Frame', 'A' },
          Leaf = { 'Frame', 'A', 'Leaf' },
        },
      },
      ['rediscovers the root tag as an ordinary two-hop descendant of itself'] = {
        xml = {
          Frame = { contents = { tags = { Wrap = true } } },
          Wrap = { contents = { tags = { Frame = true } } },
        },
        chains = { Frame = { 'Frame', 'Wrap', 'Frame' }, Wrap = { 'Frame', 'Wrap' } },
      },
    }

    for name, case in pairs(cases) do
      it(name, function()
        local chains, ambiguous = xmlcontainment.chains(case.xml, 'Frame', case.preferParent)
        assert.same(case.chains, chains)
        assert.same({}, ambiguous)
      end)
    end

    -- Not table-driven like the cases above: when two parents are equally
    -- shallow and no preferParent breaks the tie, xmlcontainment.chains()
    -- documents that either candidate may be recorded as the winner (Lua's
    -- table iteration order decides which). The exact winner isn't part of
    -- the contract, so this asserts the real return value is one of the two
    -- legitimate answers instead of a fixed one.
    it('marks a tag ambiguous when two equally-shallow parents both accept it', function()
      local xml = {
        A = { contents = { tags = { Leaf = true } } },
        B = { contents = { tags = { Leaf = true } } },
        Frame = { contents = { tags = { A = true, B = true } } },
        Leaf = {},
      }
      local chains, ambiguous = xmlcontainment.chains(xml, 'Frame')
      assert.same({ Leaf = true }, ambiguous)
      local actual = table.concat(chains.Leaf, '/')
      assert.same(true, actual == 'Frame/A/Leaf' or actual == 'Frame/B/Leaf')
    end)
  end)

  describe('roots', function()
    -- roots() has none of chains()'s BFS/shortest-path/tie-breaking
    -- machinery -- it's a plain per-tag "is this ever a legal child of
    -- anything" predicate, so it needs far fewer cases to cover: direct
    -- containment, extends-based substitution, sealed truncating that
    -- substitution, virtual overriding reachability, and the everything-
    -- nests-in-everything-else edge case where no tag is a root at all.
    local cases = {
      ['finds a tag nothing else ever admits as a child'] = {
        xml = { Frame = { contents = { tags = { Leaf = true } } }, Leaf = {} },
        roots = { Frame = true },
      },
      ['excludes a tag reachable only via its extends chain'] = {
        xml = {
          Base = {},
          Frame = { contents = { tags = { Base = true } } },
          Sub = { extends = 'Base' },
        },
        roots = { Frame = true },
      },
      ['sealed keeps a tag a root despite its base being accepted elsewhere'] = {
        xml = {
          Base = {},
          Frame = { contents = { tags = { Base = true } } },
          Sub = { extends = 'Base', sealed = true },
        },
        roots = { Frame = true, Sub = true },
      },
      ['excludes a virtual tag even though nothing names it as a child'] = {
        xml = {
          Abstract = { virtual = true },
          Frame = { contents = { tags = { Leaf = true } } },
          Leaf = {},
        },
        roots = { Frame = true },
      },
      ['has no roots when every tag is only ever legal nested in another'] = {
        xml = {
          Frame = { contents = { tags = { Wrap = true } } },
          Wrap = { contents = { tags = { Frame = true } } },
        },
        roots = {},
      },
    }

    for name, case in pairs(cases) do
      it(name, function()
        assert.same(case.roots, xmlcontainment.roots(case.xml))
      end)
    end
  end)

  describe('legalChildren', function()
    it('accepts a directly declared child', function()
      local xml = {
        Frame = { contents = { tags = { Leaf = true } } },
        Leaf = {},
        Other = {},
      }
      local legal = xmlcontainment.legalChildren(xml, 'Frame')
      assert.is_true(legal.Leaf)
      assert.is_nil(legal.Other)
    end)

    it('accepts a tag reachable only via its extends chain', function()
      local xml = {
        Base = {},
        Frame = { contents = { tags = { Base = true } } },
        Sub = { extends = 'Base' },
      }
      assert.is_true(xmlcontainment.legalChildren(xml, 'Frame').Sub)
    end)

    it('sealed stops extends-chain climbing', function()
      local xml = {
        Base = {},
        Frame = { contents = { tags = { Base = true } } },
        Sub = { extends = 'Base', sealed = true },
      }
      assert.is_nil(xmlcontainment.legalChildren(xml, 'Frame').Sub)
    end)

    it('doesn\'t require any path from a root to `parent` itself', function()
      local xml = {
        Frame = { contents = { tags = { Leaf = true } } },
        Leaf = {},
        Unreachable = { contents = { tags = { Leaf = true } } },
      }
      assert.is_true(xmlcontainment.legalChildren(xml, 'Unreachable').Leaf)
    end)
  end)
end)
