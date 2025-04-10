describe('wowless.toc', function()
  local wowlesstoc = require('wowless.toc')
  local flavors = require('runtime.flavors')
  describe('parse', function()
    local parse = wowlesstoc.parse
    for flavor in pairs(flavors) do
      describe(flavor, function()
        it('handles empty content', function()
          local attrs, files = parse(flavor, '')
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
          local attrs, files = parse(flavor, table.concat(lines, '\n'))
          assert.same({ Key = 'Value' }, attrs)
          assert.same({ 'aaa', 'bbb', 'ccc' }, files)
        end)
        it('does flavor substitution', function()
          local lines = {
            '# [Family] comment blah blah',
            '## A[Family]Key: B[Family]Value[Family]',
            '',
            'a[Family]b',
          }
          local attrs, files = parse(flavor, table.concat(lines, '\n'))
          assert.same({ ['A' .. flavor .. 'Key'] = 'B' .. flavor .. 'Value' .. flavor }, attrs)
          assert.same({ 'a' .. flavor .. 'b' }, files)
        end)
        it('does AllowLoad filtering', function()
          local lines = {
            'algame [AllowLoad Game]',
            'alglue [AllowLoad Glue]',
          }
          local _, files = parse(flavor, table.concat(lines, '\n'))
          assert.same({ 'algame' }, files)
        end)
        it('does AllowLoadGameType filtering', function()
          local lines = {
            'aaa [AllowLoadGameType mainline]',
            'bbb [AllowLoadGameType vanilla, cata]',
            'ccc [AllowLoadGameType classic]',
          }
          local _, files = parse(flavor, table.concat(lines, '\n'))
          local expected = {
            Cata = { 'bbb', 'ccc' },
            Mainline = { 'aaa' },
            Vanilla = { 'bbb', 'ccc' },
          }
          assert.same(assert(expected[flavor]), files)
        end)
      end)
    end
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
