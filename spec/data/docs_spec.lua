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
    end)
  end
end)
