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
                it('has a corresponding meta enum', function()
                  assert(enums[k .. 'Meta'])
                end)
                local meta = enums[k .. 'Meta']
                if meta then
                  it('MinValue matches', function()
                    local min_v = math.huge
                    for _, v in pairs(enums[k]) do
                      local n = tonumber(v)
                      if n and n < min_v then
                        min_v = n
                      end
                    end
                    assert.equal(meta.MinValue, min_v)
                  end)
                  it('MaxValue matches', function()
                    -- MaxValue uses WoW's uint32 semantics: take max of values in
                    -- the uint32 range [0, 2^32-1], then store as signed int32.
                    local max_u32 = -1
                    for _, v in pairs(enums[k]) do
                      local n = tonumber(v)
                      if n and n >= 0 and n <= 2 ^ 32 - 1 and n > max_u32 then
                        max_u32 = n
                      end
                    end
                    if max_u32 >= 0 then
                      if max_u32 >= 2 ^ 31 then
                        max_u32 = max_u32 - 2 ^ 32
                      end
                      assert.equal(meta.MaxValue, max_u32)
                    end
                  end)
                  it('NumValues matches', function()
                    local count = 0
                    for _ in pairs(enums[k]) do
                      count = count + 1
                    end
                    assert.equal(meta.NumValues, count)
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
