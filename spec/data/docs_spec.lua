local tedit = require('tools.tedit')
local function revedit(e)
  local ret = {}
  for k, v in pairs(e) do
    if k == '_add' then
      ret._remove = v
    elseif k == '_change' then
      ret._change = {
        from = v.to,
        to = v.from,
      }
    elseif k == '_remove' then
      ret._add = v
    else
      ret[k] = revedit(v)
    end
  end
  return ret
end
describe('docs', function()
  for _, p in ipairs(require('build.data.products')) do
    describe(p, function()
      local docs = require('build.data.products.' .. p .. '.docs')
      local apis = require('build.data.products.' .. p .. '.apis')
      local enums = require('build.data.products.' .. p .. '.globals').Enum
      local events = require('build.data.products.' .. p .. '.events')
      local uiobjects = require('build.data.products.' .. p .. '.uiobjects')
      describe('lies', function()
        local lies = docs.lies or {}
        describe('apis', function()
          for k, v in pairs(lies.apis or {}) do
            describe(k, function()
              it('applies to the global api in reverse', function()
                tedit(apis[k], revedit(v))
              end)
            end)
          end
        end)
        describe('extra_apis', function()
          for k in pairs(lies.extra_apis or {}) do
            describe(k, function()
              it('must not be a global api', function()
                assert.Nil(apis[k])
              end)
            end)
          end
        end)
        describe('enums', function()
          for k, v in pairs(lies.enums or {}) do
            describe(k, function()
              it('applies to the declared enum in reverse', function()
                tedit(enums[k], revedit(v))
              end)
            end)
          end
        end)
        describe('extra_enums', function()
          for k in pairs(lies.extra_enums or {}) do
            describe(k, function()
              it('must not be a declared enum', function()
                assert.Nil(enums[k])
              end)
            end)
          end
        end)
        describe('extra_events', function()
          for k in pairs(lies.extra_events or {}) do
            describe(k, function()
              it('must not be a declared event', function()
                assert.Nil(events[k])
              end)
            end)
          end
        end)
        describe('uiobjects', function()
          for k, v in pairs(lies.uiobjects or {}) do
            describe(k, function()
              for mk, mv in pairs(v) do
                describe(mk, function()
                  it('applies to the uiobject method in reverse', function()
                    tedit(uiobjects[k].methods[mk], revedit(mv))
                  end)
                end)
              end
            end)
          end
        end)
      end)
      describe('uiobject_method_reassignments', function()
        for k, v in pairs(docs.uiobject_method_reassignments or {}) do
          describe(k, function()
            for vk, vv in pairs(v) do
              describe(vk, function()
                it('does not exist in the source', function()
                  assert.Nil(uiobjects[k].methods[vk])
                end)
                it('exists in the target', function()
                  assert.Not.Nil(uiobjects[vv].methods[vk])
                end)
              end)
            end
          end)
        end
      end)
    end)
  end
end)
