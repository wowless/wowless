describe('uiobjects', function()
  for _, p in ipairs(require('build.data.products')) do
    local function protocheck(expected, actual)
      if expected.inputs then
        assert.same(#expected.inputs, #actual.inputs)
        for i, x in ipairs(expected.inputs) do
          local a = actual.inputs[i]
          assert.same(x.type, a.type)
          -- e.g. nilable field can have a non-nilable setter arg
          assert.True(not x.nilable or a.nilable)
        end
      end
      if expected.outputs then
        assert.same(#expected.outputs, #actual.outputs)
        for i, x in ipairs(expected.outputs) do
          local a = actual.outputs[i]
          assert.same(x.type, a.type)
          -- e.g. nilable getter arg can have a non-nilable field
          assert.True(not a.nilable or x.nilable)
        end
      end
      assert.same(expected.instride, actual.instride)
      assert.same(expected.mayreturnnothing, actual.mayreturnnothing)
      assert.same(expected.outstride, actual.outstride)
    end
    describe(p, function()
      local uiobjects = require('build.data.products.' .. p .. '.uiobjects')
      describe('hierarchy', function()
        local g = {}
        for k, v in pairs(uiobjects) do
          local t = {}
          for ik in pairs(v.inherits) do
            t[ik] = true
          end
          g[k] = t
        end
        local nr = {}
        for _, v in pairs(g) do
          for ik in pairs(v) do
            nr[ik] = (nr[ik] or 0) + 1
          end
        end
        -- Cycle- and diamond-freedom is enforced by the uiobjects schema's
        -- `hierarchy` construct; this walk only needs the ancestor set.
        local function ancestors(t, k)
          if not t[k] then
            t[k] = true
            for ik in pairs(g[k]) do
              ancestors(t, ik)
            end
          end
        end
        for k in pairs(g) do
          describe(k, function()
            local t = {}
            ancestors(t, k)
            if not nr[k] then
              it('is not virtual', function()
                assert.Nil(uiobjects[k].virtual)
              end)
              it('is a uiobject', function()
                assert.True(t.UIObject)
              end)
            else
              it('is virtual or uiobject', function()
                assert.True(uiobjects[k].virtual or t.UIObject)
              end)
              it('is used more than once if virtual', function()
                assert.True(not uiobjects[k].virtual or nr[k] > 1)
              end)
            end
          end)
        end
      end)
      local function getMember(k, m, f)
        local v = uiobjects[k]
        if v[m] and v[m][f] then
          return v[m][f]
        end
        for inh in pairs(v.inherits) do
          local x = getMember(inh, m, f)
          if x then
            return x
          end
        end
      end
      local function inheritsType(k, target)
        if k == target then
          return true
        end
        for inh in pairs(uiobjects[k].inherits) do
          if inheritsType(inh, target) then
            return true
          end
        end
        return false
      end
      local function collectChildFields(k, seen)
        seen = seen or {}
        if seen[k] then
          return {}
        end
        seen[k] = true
        local result = {}
        if uiobjects[k].childField then
          result[uiobjects[k].childField] = true
        end
        for inh in pairs(uiobjects[k].inherits) do
          for cf in pairs(collectChildFields(inh, seen)) do
            result[cf] = true
          end
        end
        return result
      end
      describe('childField values', function()
        local allValues = {}
        for k in pairs(uiobjects) do
          for cf in pairs(collectChildFields(k)) do
            allValues[cf] = true
          end
        end
        for cf in pairs(allValues) do
          it(cf .. ' is a real hlist field on some uiobject', function()
            local found = false
            for _, tv in pairs(uiobjects) do
              local f = tv.fields[cf]
              if f and f.type == 'hlist' then
                found = true
              end
            end
            assert.True(found)
          end)
        end
      end)
      for k, v in pairs(uiobjects) do
        describe(k, function()
          describe('childField', function()
            local names = {}
            for cf in pairs(collectChildFields(k)) do
              table.insert(names, cf)
            end
            it('has at most one value across the inheritance tree', function()
              assert.True(#names <= 1, ('%s has conflicting child fields: %s'):format(k, table.concat(names, ', ')))
            end)
            if names[1] == 'children' then
              it('is only used by frames', function()
                assert.True(inheritsType(k, 'Frame'))
              end)
            end
          end)
          describe('methods', function()
            for mk, mv in pairs(v.methods) do
              describe(mk, function()
                if mv.impl then
                  describe('impl', function()
                    if mv.impl.uiobjectimpl then
                      it('has declared inputs or manual inputs', function()
                        assert.truthy(mv.inputs or mv.manualinputs)
                      end)
                    else
                      it('has declared inputs', function()
                        assert.Not.Nil(mv.inputs)
                      end)
                    end
                    it('has declared outputs', function()
                      assert.Not.Nil(mv.outputs)
                    end)
                    if mv.impl.getter then
                      it('has the right prototype', function()
                        local outputs = {}
                        for i, f in ipairs(mv.impl.getter) do
                          outputs[i] = assert(getMember(k, 'fields', f.name))
                        end
                        protocheck(mv, {
                          inputs = {},
                          outputs = outputs,
                        })
                      end)
                    elseif mv.impl.setter then
                      it('has the right prototype', function()
                        local inputs = {}
                        for i, f in ipairs(mv.impl.setter) do
                          inputs[i] = assert(getMember(k, 'fields', f.name))
                        end
                        protocheck(mv, {
                          inputs = inputs,
                          outputs = {},
                        })
                      end)
                    elseif mv.impl.settexture then
                      local c = mv.impl.settexture
                      it('manipulates a declared texture', function()
                        local f = assert(getMember(k, 'fields', c.field))
                        assert.same({ uiobject = 'Texture' }, f.type)
                        assert.True(f.nilable)
                      end)
                      it('has the right prototype', function()
                        protocheck(mv, {
                          inputs = {
                            [1] = { type = 'TextureAsset' },
                            [2] = c.extra and {
                              nilable = true,
                              type = { stringenum = 'BlendMode' },
                            },
                          },
                          outputs = { c['return'] and { type = 'boolean' } },
                        })
                      end)
                    end
                  end)
                end
                describe('inputs', function()
                  for _, input in ipairs(mv.inputs or {}) do
                    describe(input.name, function()
                      if input.default ~= nil then
                        it('is not explicitly nilable', function()
                          assert.Nil(input.nilable)
                        end)
                      else
                        it('is not permissive', function()
                          assert.Nil(input.permissive)
                        end)
                      end
                    end)
                  end
                  it('are uniquely named', function()
                    local names = {}
                    for _, input in ipairs(mv.inputs or {}) do
                      assert.Nil(names[input.name])
                      names[input.name] = true
                    end
                  end)
                end)
                describe('instride', function()
                  it('is less than or equal to number of inputs', function()
                    assert(not mv.instride or mv.instride <= #mv.inputs)
                  end)
                end)
                if mv.manualinputs then
                  describe('manualinputs', function()
                    it('must be implemented in lua', function()
                      assert.Truthy(mv.impl and mv.impl.uiobjectimpl)
                    end)
                    it('must not have declared inputs', function()
                      assert.Nil(mv.inputs)
                    end)
                  end)
                end
                describe('outputs', function()
                  for _, output in ipairs(mv.outputs or {}) do
                    describe(output.name, function()
                      it('cannot be both stubnotnil and have a stub', function()
                        assert.True(not output.stubnotnil or output.stub == nil)
                      end)
                      it('must be nilable if stubnotnil', function()
                        assert.True(not output.stubnotnil or output.nilable)
                      end)
                      if mv.impl then
                        it('cannot specify return value', function()
                          assert.Nil(output.stub)
                        end)
                      end
                    end)
                  end
                  it('are uniquely named', function()
                    local names = {}
                    for _, output in ipairs(mv.outputs or {}) do
                      assert.Nil(names[output.name])
                      names[output.name] = true
                    end
                  end)
                end)
                describe('outstride', function()
                  it('is less than or equal to number of outputs', function()
                    assert(not mv.outstride or mv.outstride <= #mv.outputs)
                  end)
                end)
                describe('stuboutstrides', function()
                  it('is only set it outstride is set', function()
                    assert(not mv.stuboutstrides or mv.outstride)
                  end)
                  it('is either zero or greater than 1 if set', function()
                    local s = mv.stuboutstrides
                    assert(not s or s == 0 or s > 1)
                  end)
                end)
              end)
            end
          end)
        end)
      end
    end)
  end
end)
