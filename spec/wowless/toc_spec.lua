describe('wowless.toc', function()
  local wowlesstoc = require('wowless.toc')
  local gametypes = require('runtime.gametypes')
  describe('parse', function()
    local parse = wowlesstoc.parse
    for gametype, gt in pairs(gametypes) do
      local family = gt.family
      describe(gametype, function()
        it('handles empty content', function()
          local attrs, files = parse(gametype, '')
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
          local attrs, files = parse(gametype, table.concat(lines, '\n'))
          assert.same({ Key = 'Value' }, attrs)
          assert.same({ 'aaa', 'bbb', 'ccc' }, files)
        end)
        it('does family substitution', function()
          local lines = {
            '# [Family] comment blah blah',
            '## A[Family]Key: B[Family]Value[Family]',
            '',
            'a[Family]b',
          }
          local attrs, files = parse(gametype, table.concat(lines, '\n'))
          assert.same({ ['A' .. family .. 'Key'] = 'B' .. family .. 'Value' .. family }, attrs)
          assert.same({ 'a' .. family .. 'b' }, files)
        end)
        it('does AllowLoad filtering', function()
          local lines = {
            'algame [AllowLoad Game]',
            'alglue [AllowLoad Glue]',
          }
          local _, files = parse(gametype, table.concat(lines, '\n'))
          assert.same({ 'algame' }, files)
        end)
        it('does AllowLoadGameType filtering', function()
          local lines = {
            'aaa [AllowLoadGameType mainline]',
            'bbb [AllowLoadGameType vanilla, cata]',
            'ccc [AllowLoadGameType classic]',
          }
          local _, files = parse(gametype, table.concat(lines, '\n'))
          local expected = {
            Cata = { 'bbb', 'ccc' },
            Mists = { 'ccc' },
            Standard = { 'aaa' },
            Vanilla = { 'bbb', 'ccc' },
          }
          assert.same(assert(expected[gametype]), files)
        end)
      end)
    end
  end)
  describe('suffixes', function()
    local allsuffixes = wowlesstoc.suffixes
    it('are keyed by gametype', function()
      for k in pairs(allsuffixes) do
        assert.Not.Nil(gametypes[k])
      end
    end)
    for gametype in pairs(gametypes) do
      describe(gametype, function()
        local suffixes = allsuffixes[gametype]
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
