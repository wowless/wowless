describe('globals', function()
  for _, p in ipairs(require('build.data.products')) do
    describe(p, function()
      local globals = require('build.data.products.' .. p .. '.globals')
      describe('enums', function()
        local enums = globals.Enum
        describe('meta', function()
          for k in pairs(enums) do
            describe(k, function()
              if k:sub(-4) == 'Meta' then
                it('has a corresponding real enum', function()
                  assert(enums[k:sub(1, -5)])
                end)
              else
                local meta = assert(enums[k .. 'Meta'])
                -- issue #527
                local stringValuedEnums = { AccountStateLoadedFlags = true, CreateAllAccountData = true }
                if not stringValuedEnums[k] then
                  it('NumValues matches', function()
                    local count = 0
                    for _ in pairs(enums[k]) do
                      count = count + 1
                    end
                    assert.equal(count, meta.NumValues)
                  end)
                  it('MinValue matches', function()
                    local ek, min = next(enums[k])
                    for _, v in next, enums[k], ek do
                      if v < min then
                        min = v
                      end
                    end
                    assert.equal(min, meta.MinValue)
                  end)
                  it('MaxValue matches', function()
                    local ek, max = next(enums[k])
                    for _, v in next, enums[k], ek do
                      if v > max then
                        max = v
                      end
                    end
                    local expected = (p == 'wowt' or max < 2 ^ 31) and max or max - 2 ^ 32
                    assert.equal(expected, meta.MaxValue)
                  end)
                end
              end
            end)
          end
        end)
      end)
    end)
  end
end)
