describe('wowless.toc', function()
  local wowlesstoc = require('wowless.toc')
  local flavors = require('runtime.flavors')
  describe('parse', function()
    local parse = wowlesstoc.parse
    it('handles empty content', function()
      local attrs, files = parse('')
      assert.same({}, attrs)
      assert.same({}, files)
    end)
    it('does basic parsing', function()
      local lines = {
        '# This is a comment',
        '## Key: Value',
        '',
        'aaa ',
        ' bbb ',
        'ccc',
      }
      local attrs, files = parse(table.concat(lines, '\n'))
      assert.same({ Key = 'Value' }, attrs)
      assert.same({ 'aaa', 'bbb', 'ccc' }, files)
    end)
  end)
  describe('suffixes', function()
    local allsuffixes = wowlesstoc.suffixes
    it('are keyed by flavor', function()
      for k in pairs(allsuffixes) do
        assert.Not.Nil(flavors[k])
      end
    end)
    for flavor in pairs(flavors) do
      describe(flavor, function()
        local suffixes = allsuffixes[flavor]
        it('are unique', function()
          local t = {}
          for _, v in ipairs(suffixes) do
            assert.Nil(t[v])
            t[v] = true
          end
        end)
        it('have the empty string as the last member', function()
          assert.same('', suffixes[#suffixes])
        end)
      end)
    end
  end)
end)
