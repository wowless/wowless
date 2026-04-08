describe('wowless.toc', function()
  local wowlesstoc = require('wowless.toc')
  local gametypes = require('runtime.gametypes')
  describe('parse', function()
    local parse = wowlesstoc.parse
    for gametype, gt in pairs(gametypes) do
      local family = gt.family
      describe(gametype, function()
        it('handles empty content', function()
          local toc = parse(gametype, '')
          local attrs, files = toc.attrs, toc.files
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
          local toc = parse(gametype, table.concat(lines, '\n'))
          assert.same({ Key = 'Value' }, toc.attrs)
          assert.same({ 'aaa', 'bbb', 'ccc' }, toc.files)
        end)
        it('handles SavedVariables field', function()
          local lines = {
            '## SavedVariables: Foo, Bar Baz',
            '## Key: Value',
          }
          local toc = parse(gametype, table.concat(lines, '\n'))
          assert.same({ 'Foo', 'Bar', 'Baz' }, toc.savedvariables)
          assert.same({ Key = 'Value' }, toc.attrs)
          assert.Nil(toc.attrs.SavedVariables)
        end)
        it('handles Interface field', function()
          local lines = {
            '## Interface: 120001',
            '## Key: Value',
          }
          local toc = parse(gametype, table.concat(lines, '\n'))
          assert.same(120001, toc.interface)
          assert.same({ Key = 'Value' }, toc.attrs)
          assert.Nil(toc.attrs.Interface)
        end)
        it('does family substitution', function()
          local lines = {
            '# [Family] comment blah blah',
            '## A[Family]Key: B[Family]Value[Family]',
            '',
            'a[Family]b',
          }
          local toc = parse(gametype, table.concat(lines, '\n'))
          assert.same({ ['A' .. family .. 'Key'] = 'B' .. family .. 'Value' .. family }, toc.attrs)
          assert.same({ 'a' .. family .. 'b' }, toc.files)
        end)
        it('does AllowLoad filtering', function()
          local lines = {
            'algame [AllowLoad Game]',
            'alglue [AllowLoad Glue]',
          }
          local files = parse(gametype, table.concat(lines, '\n')).files
          assert.same({ 'algame' }, files)
        end)
        it('does AllowLoadGameType filtering', function()
          local lines = {
            'aaa [AllowLoadGameType mainline]',
            'bbb [AllowLoadGameType vanilla]',
            'ccc [AllowLoadGameType classic]',
            'ddd [AllowLoadGameType mists]',
            'eee [AllowLoadGameType tbc]',
          }
          local files = parse(gametype, table.concat(lines, '\n')).files
          local expected = {
            Mists = { 'ccc', 'ddd' },
            Standard = { 'aaa' },
            TBC = { 'ccc', 'eee' },
            Vanilla = { 'bbb', 'ccc' },
          }
          assert.same(assert(expected[gametype]), files)
        end)
      end)
    end
    it('handles multiple filters', function()
      local line = 'aaa [AllowLoadGameType standard] [AllowLoadEnvironment Global]'
      local files = parse('Standard', line).files
      assert.same({ 'aaa' }, files)
    end)
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
