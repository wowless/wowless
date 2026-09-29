describe('hierarchy', function()
  local hierarchy = require('wowless.hierarchy')

  local spec = {
    fields = {
      inherits = { required = true },
      methods = { required = true },
      scripts = {},
      virtual = {},
    },
    parent = 'inherits',
    unique = { methods = {} },
  }

  -- Root(v) --+-- A --+-- A1
  --           |       +-- A2(v) -- A2x
  --           +-- B ------ B1
  -- M(v) -----+----------- B1
  --           +-- Mx
  local function fixture(members)
    local nodes = {
      A = { inherits = { Root = {} }, methods = {} },
      A1 = { inherits = { A = {} }, methods = {} },
      A2 = { inherits = { A = {} }, methods = {}, virtual = true },
      A2x = { inherits = { A2 = {} }, methods = {} },
      B = { inherits = { Root = {} }, methods = {} },
      B1 = { inherits = { B = {}, M = {} }, methods = {} },
      M = { inherits = {}, methods = {}, virtual = true },
      Mx = { inherits = { M = {} }, methods = {} },
      Root = { inherits = {}, methods = {}, virtual = true },
    }
    for k, fs in pairs(members or {}) do
      for f, v in pairs(fs) do
        nodes[k][f] = v
      end
    end
    return nodes
  end

  local function concrete(nodes)
    return function(k)
      return not nodes[k].virtual
    end
  end

  describe('structure', function()
    local cases = {
      ['parents of a multi-parent node, sorted'] = {
        fn = 'parents',
        k = 'B1',
        expected = { 'B', 'M' },
      },
      ['parents of a root'] = {
        fn = 'parents',
        k = 'Root',
        expected = {},
      },
      ['children'] = {
        fn = 'children',
        k = 'Root',
        expected = { A = true, B = true },
      },
      ['children of a leaf'] = {
        fn = 'children',
        k = 'A1',
        expected = {},
      },
      ['ancestors'] = {
        fn = 'ancestors',
        k = 'A2x',
        expected = { A = true, A2 = true, Root = true },
      },
      ['ancestors through both parents'] = {
        fn = 'ancestors',
        k = 'B1',
        expected = { B = true, M = true, Root = true },
      },
      ['descendants'] = {
        fn = 'descendants',
        k = 'A',
        expected = { A1 = true, A2 = true, A2x = true },
      },
      ['descendants of a mixin-like root'] = {
        fn = 'descendants',
        k = 'M',
        expected = { B1 = true, Mx = true },
      },
    }
    for name, case in pairs(cases) do
      it(name, function()
        assert.same(case.expected, hierarchy.new(fixture(), spec)[case.fn](case.k))
      end)
    end

    it('handles a single-name parent field', function()
      local h = hierarchy.new({
        Base = {},
        Mid = { extends = 'Base' },
        Leaf = { extends = 'Mid' },
      }, { fields = { extends = {} }, parent = 'extends', unique = {} })
      assert.same({
        ancestors = { Base = true, Mid = true },
        children = { Mid = true },
        parents = { 'Mid' },
      }, {
        ancestors = h.ancestors('Leaf'),
        children = h.children('Base'),
        parents = h.parents('Leaf'),
      })
    end)

    it('errors on an unknown node', function()
      assert.has_error(function()
        hierarchy.new(fixture(), spec).ancestors('Nope')
      end, 'unknown node Nope')
    end)
  end)

  describe('flatten', function()
    local cases = {
      ['merges ancestors, own declarations winning'] = {
        members = {
          A = { scripts = { s2 = {} } },
          A1 = { scripts = { s1 = { own = true } } },
          Root = { scripts = { s1 = {} } },
        },
        k = 'A1',
        expected = {
          from = { s1 = 'A1', s2 = 'A' },
          members = { s1 = { own = true }, s2 = {} },
        },
      },
      ['inherits through a declaration-free intermediate'] = {
        members = {
          A = { scripts = { s2 = {} } },
          Root = { scripts = { s1 = {} } },
        },
        k = 'A2x',
        expected = {
          from = { s1 = 'Root', s2 = 'A' },
          members = { s1 = {}, s2 = {} },
        },
      },
      ['merges both parents'] = {
        members = {
          B = { scripts = { b = {} } },
          M = { scripts = { m = {} } },
        },
        k = 'B1',
        expected = {
          from = { b = 'B', m = 'M' },
          members = { b = {}, m = {} },
        },
      },
      ['a node redeclaring a member both parents provide resolves it'] = {
        members = {
          B = { scripts = { x = {} } },
          B1 = { scripts = { x = {} } },
          M = { scripts = { x = {} } },
        },
        k = 'B1',
        expected = {
          from = { x = 'B1' },
          members = { x = {} },
        },
      },
      ['nothing declared'] = {
        k = 'A2x',
        expected = { from = {}, members = {} },
      },
    }
    for name, case in pairs(cases) do
      it(name, function()
        local members, from = hierarchy.new(fixture(case.members), spec).flatten(case.k, 'scripts')
        assert.same(case.expected, { from = from, members = members })
      end)
    end

    local errcases = {
      ['a member inherited from two different declarations'] = {
        members = {
          B = { scripts = { x = {} } },
          M = { scripts = { x = {} } },
        },
        field = 'scripts',
        err = 'B1.scripts.x is inherited from both B and M',
      },
      ['an unknown field'] = {
        field = 'nope',
        err = 'unknown field nope',
      },
      ['the parent field'] = {
        field = 'inherits',
        err = 'cannot use the parent field as a member field',
      },
    }
    for name, case in pairs(errcases) do
      it('errors on ' .. name, function()
        assert.has_error(function()
          hierarchy.new(fixture(case.members), spec).flatten('B1', case.field)
        end, case.err)
      end)
    end
  end)

  describe('declarer', function()
    local members = {
      A = { scripts = { s = {} } },
    }
    local cases = {
      ['finds the declaring ancestor'] = { k = 'A2x', value = 'A' },
      ['finds the node itself'] = { k = 'A', value = 'A' },
      ['nil when not had'] = { k = 'B1', value = nil },
    }
    for name, case in pairs(cases) do
      it(name, function()
        assert.same({ value = case.value }, {
          value = hierarchy.new(fixture(members), spec).declarer(case.k, 'scripts', 's'),
        })
      end)
    end
  end)

  describe('cover', function()
    local cases = {
      ['climbs to the highest node whose eligible subtree is in the set'] = {
        set = { A = true, A1 = true, A2x = true },
        expected = { A = true },
      },
      ['climbs through a virtual root'] = {
        set = { A = true, A1 = true, A2x = true, B = true, B1 = true },
        expected = { Root = true },
      },
      ['uses a virtual intermediate'] = {
        set = { A2x = true },
        expected = { A2 = true },
      },
      ['uses a mixin-like parent when it is the only full one'] = {
        set = { B1 = true, Mx = true },
        expected = { M = true },
      },
      ['drops a candidate whose subtree is already covered'] = {
        set = { A1 = true, B = true, B1 = true },
        expected = { A1 = true, B = true },
      },
      ['splits an overlapping candidate into its children'] = {
        set = { B = true, B1 = true, Mx = true },
        expected = { B = true, Mx = true },
      },
      ['empty set'] = {
        set = {},
        expected = {},
      },
      ['every node eligible by default'] = {
        set = { A2 = true, A2x = true },
        alleligible = true,
        expected = { A2 = true },
      },
    }
    for name, case in pairs(cases) do
      it(name, function()
        local nodes = fixture()
        local eligible = not case.alleligible and concrete(nodes) or nil
        assert.same(case.expected, hierarchy.new(nodes, spec).cover(case.set, eligible))
      end)
    end

    local errcases = {
      ['a node whose eligible descendant is outside the set'] = {
        set = { A = true },
        err = 'no placement gives exactly the requested set; cannot cover: A',
      },
      ['an ineligible node in the set'] = {
        set = { A2 = true },
        err = 'A2 is not eligible',
      },
    }
    for name, case in pairs(errcases) do
      it('errors on ' .. name, function()
        local nodes = fixture()
        assert.has_error(function()
          hierarchy.new(nodes, spec).cover(case.set, concrete(nodes))
        end, case.err)
      end)
    end
  end)

  describe('assign', function()
    local cases = {
      ['hoists scattered declarations to their cover'] = {
        members = {
          A1 = { scripts = { k = {} } },
          A2x = { scripts = { k = {}, other = {} } },
        },
        want = { A = true, A1 = true, A2x = true },
        expected = {
          decl = { A = true },
          scripts = { A = { k = {} }, A2x = { other = {} } },
        },
      },
      ['pushes a declaration down to what still has it'] = {
        members = {
          Root = { scripts = { k = {} } },
        },
        want = { A = true, A1 = true, A2x = true, B1 = true, Mx = true },
        expected = {
          decl = { A = true, M = true },
          scripts = { A = { k = {} }, M = { k = {} } },
        },
      },
      ['removes every declaration for an empty set'] = {
        members = {
          A = { scripts = { k = {} } },
          B = { scripts = { k = {} } },
        },
        want = {},
        expected = {
          decl = {},
          scripts = {},
        },
      },
    }
    for name, case in pairs(cases) do
      it(name, function()
        local nodes = fixture(case.members)
        local decl = hierarchy.new(nodes, spec).assign('scripts', 'k', case.want, concrete(nodes), {})
        local scripts = {}
        for k, v in pairs(nodes) do
          scripts[k] = v.scripts
        end
        assert.same(case.expected, { decl = decl, scripts = scripts })
      end)
    end

    it('keeps a required field when emptying it', function()
      local nodes = fixture({ A1 = { methods = { k = 1 } } })
      hierarchy.new(nodes, spec).assign('methods', 'k', {}, concrete(nodes), 1)
      assert.same({}, nodes.A1.methods)
    end)

    it('declares a separate copy of the value on each node', function()
      local nodes = fixture()
      local value = { impl = { x = 1 } }
      hierarchy.new(nodes, spec).assign('scripts', 'k', { A1 = true, B = true, B1 = true }, concrete(nodes), value)
      assert.same({ value, value }, { nodes.A1.scripts.k, nodes.B.scripts.k })
      assert.are_not.equal(value, nodes.A1.scripts.k)
      assert.are_not.equal(nodes.A1.scripts.k, nodes.B.scripts.k)
    end)

    it('updates flatten results', function()
      local nodes = fixture({ Root = { scripts = { k = {} } } })
      local h = hierarchy.new(nodes, spec)
      assert.same('Root', h.declarer('A1', 'scripts', 'k'))
      h.assign('scripts', 'k', { A1 = true }, concrete(nodes), {})
      assert.same({ a1 = 'A1', b1 = nil }, {
        a1 = h.declarer('A1', 'scripts', 'k'),
        b1 = h.declarer('B1', 'scripts', 'k'),
      })
    end)

    it('changes nothing when the set is not achievable', function()
      local nodes = fixture({ A1 = { scripts = { k = {} } } })
      assert.has_error(function()
        hierarchy.new(nodes, spec).assign('scripts', 'k', { A = true }, concrete(nodes), {})
      end, 'no placement gives exactly the requested set; cannot cover: A')
      assert.same(fixture({ A1 = { scripts = { k = {} } } }), nodes)
    end)
  end)

  describe('real data', function()
    local wdata = require('wowapi.data')
    for name, schema in pairs(wdata.schemas) do
      local hs = schema.type.hierarchy
      if hs then
        local memberfields = {}
        for f, fs in pairs(hs.fields) do
          local ty = fs.type
          if f ~= hs.parent and type(ty) == 'table' and (ty.setof or ty.mapof) then
            table.insert(memberfields, f)
          end
        end
        table.sort(memberfields)
        for p, nodes in pairs(wdata[name]) do
          it(name .. ' ' .. p .. ' flattens to declarations on the node or its ancestors', function()
            local h = hierarchy.new(nodes, hs)
            local bad = {}
            for k in pairs(nodes) do
              local anc = h.ancestors(k)
              for _, f in ipairs(memberfields) do
                local members, from = h.flatten(k, f)
                for mk, mv in pairs(members) do
                  local d = from[mk]
                  if not (d == k or anc[d]) or nodes[d][f][mk] ~= mv then
                    table.insert(bad, ('%s.%s.%s'):format(k, f, mk))
                  end
                end
              end
            end
            assert.same({}, bad)
          end)
        end
      end
    end
  end)
end)
