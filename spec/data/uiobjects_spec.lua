describe('uiobjects', function()
  for _, p in ipairs(require('build.data.products')) do
    local api = require('wowless.api').new(function() end, 0, p, 0)
    local typechecker = require('wowless.typecheck')(api)
    local function typecheck(spec, val)
      local value, errmsg = typechecker(spec, val, true)
      assert.Nil(errmsg)
      assert.same(value, val)
    end
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
          -- assert.True(not a.nilable or x.nilable) issue #434
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
        local function process(t, root, k)
          assert(not t[k], ('multiple paths from %s to %s'):format(root, k))
          t[k] = true
          for ik in pairs(g[k]) do
            process(t, root, ik)
          end
        end
        for k in pairs(g) do
          describe(k, function()
            local t = {}
            it('is a tree', function()
              process(t, k, k)
            end)
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
      local function hasMember(k, m, f)
        return getMember(k, m, f) ~= nil
      end
      for k, v in pairs(uiobjects) do
        describe(k, function()
          describe('fields', function()
            for fk, fv in pairs(v.fields) do
              describe(fk, function()
                it('is not defined up inheritance tree', function()
                  for inh in pairs(v.inherits) do
                    assert.False(hasMember(inh, 'fields', fk))
                  end
                end)
                it('has initial value of the right type', function()
                  if fv.type ~= 'hlist' then
                    typecheck(fv, fv.init)
                  end
                end)
              end)
            end
          end)
          describe('methods', function()
            for mk, mv in pairs(v.methods) do
              describe(mk, function()
                if mv.override then
                  it('is defined up inheritance tree', function()
                    local found = false
                    for inh in pairs(v.inherits) do
                      found = found or hasMember(inh, 'methods', mk)
                    end
                    assert.True(found)
                  end)
                else
                  it('is not defined up inheritance tree', function()
                    for inh in pairs(v.inherits) do
                      assert.False(hasMember(inh, 'methods', mk))
                    end
                  end)
                end
                if mv.impl then
                  describe('impl', function()
                    if mv.impl.uiobjectimpl then
                      it('has both inputs and outputs, or neither', function()
                        assert.same(not not (mv.inputs or mv.manualinputs), not not mv.outputs)
                      end)
                    else
                      it('has declared inputs', function()
                        assert.Not.Nil(mv.inputs)
                      end)
                      it('has declared outputs', function()
                        assert.Not.Nil(mv.outputs)
                      end)
                    end
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
                        it('has default of the right type', function()
                          typecheck(input, input.default)
                        end)
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
                  for i, output in ipairs(mv.outputs or {}) do
                    describe(output.name or i, function()
                      if output.stub ~= nil then
                        it('has stub of the right type', function()
                          typecheck(output, output.stub)
                        end)
                      end
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
                  it('either all have names or none have names', function()
                    local named = 0
                    for _, output in ipairs(mv.outputs or {}) do
                      named = named + (output.name and 1 or 0)
                    end
                    assert.True(named == 0 or named == #mv.outputs)
                  end)
                  it('are uniquely named', function()
                    local names = {}
                    for _, output in ipairs(mv.outputs or {}) do
                      if output.name then
                        assert.Nil(names[output.name])
                        names[output.name] = true
                      end
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
