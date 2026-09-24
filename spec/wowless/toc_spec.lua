describe('wowless.toc', function()
  local wowlesstoc = require('wowless.toc')
  describe('parse', function()
    local parse = wowlesstoc.parse
    local gametype = 'Sometype'
    local family = 'Somefamily'
    it('handles empty content', function()
      local toc = parse(gametype, family, '', {})
      assert.same({}, toc.attrs)
      assert.same({}, toc.deps)
      assert.same({}, toc.files)
      assert.same({}, toc.optionaldeps)
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
      local toc = parse(gametype, family, table.concat(lines, '\n'), {})
      assert.same({ Key = 'Value' }, toc.attrs)
      assert.same({ { name = 'aaa' }, { name = 'bbb' }, { name = 'ccc' } }, toc.files)
    end)
    it('handles SavedVariables field', function()
      local lines = {
        '## SavedVariables: Foo, Bar Baz',
        '## Key: Value',
      }
      local toc = parse(gametype, family, table.concat(lines, '\n'), {})
      assert.same({ 'Foo', 'Bar', 'Baz' }, toc.savedvariables)
      assert.same({ Key = 'Value' }, toc.attrs)
      assert.Nil(toc.attrs.SavedVariables)
    end)
    local depkeys = { 'Dep', 'Deps', 'Dependencies', 'RequiredDep', 'RequiredDeps', 'RequiredDependencies' }
    for _, key in ipairs(depkeys) do
      it('handles ' .. key .. ' field', function()
        local toc = parse(gametype, family, '## ' .. key .. ': Foo, Bar Baz', {})
        assert.same({ 'Foo', 'Bar', 'Baz' }, toc.deps)
        assert.Nil(toc.attrs[key])
      end)
    end
    for _, key in ipairs({ 'OptionalDep', 'OptionalDeps', 'OptionalDependencies' }) do
      it('handles ' .. key .. ' field', function()
        local toc = parse(gametype, family, '## ' .. key .. ': Foo, Bar Baz', {})
        assert.same({ 'Foo', 'Bar', 'Baz' }, toc.optionaldeps)
        assert.Nil(toc.attrs[key])
      end)
    end
    it('merges multiple dep fields', function()
      local lines = {
        '## RequiredDep: Foo',
        '## RequiredDeps: Bar',
      }
      local toc = parse(gametype, family, table.concat(lines, '\n'), {})
      assert.same({ 'Foo', 'Bar' }, toc.deps)
    end)
    it('handles filters on dep fields', function()
      local lines = {
        '## Dep: Foo',
        '## Dep: Bar [AllowLoad glue]',
        '## Dep: Baz [AllowLoad game]',
      }
      local toc = parse(gametype, family, table.concat(lines, '\n'), {})
      assert.same({ 'Foo', 'Baz' }, toc.deps)
    end)
    it('merges multiple optionaldep fields', function()
      local lines = {
        '## OptionalDep: Foo',
        '## OptionalDeps: Bar',
      }
      local toc = parse(gametype, family, table.concat(lines, '\n'), {})
      assert.same({ 'Foo', 'Bar' }, toc.optionaldeps)
    end)
    it('handles Interface field', function()
      local lines = {
        '## Interface: 120001',
        '## Key: Value',
      }
      local toc = parse(gametype, family, table.concat(lines, '\n'), {})
      assert.same({ 120001 }, toc.interface)
      assert.same({ Key = 'Value' }, toc.attrs)
      assert.Nil(toc.attrs.Interface)
    end)
    it('handles multiple Interface values', function()
      local toc = parse(gametype, family, '## Interface: 120001, 40400, 11507', {})
      assert.same({ 120001, 40400, 11507 }, toc.interface)
    end)
    it('does family substitution', function()
      local lines = {
        '# [Family] comment blah blah',
        '## A[Family]Key: B[Family]Value[Family]',
        '',
        'a[Family]b',
      }
      local toc = parse(gametype, family, table.concat(lines, '\n'), {})
      assert.same({ ['A' .. family .. 'Key'] = 'B' .. family .. 'Value' .. family }, toc.attrs)
      assert.same({ { name = 'a' .. family .. 'b' } }, toc.files)
    end)
    it('does game substitution', function()
      local lines = {
        '# [Game] comment blah blah',
        '## A[Game]Key: B[Game]Value[Game]',
        '',
        'a[Game]b',
      }
      local toc = parse(gametype, family, table.concat(lines, '\n'), {})
      assert.same({ ['A' .. gametype .. 'Key'] = 'B' .. gametype .. 'Value' .. gametype }, toc.attrs)
      assert.same({ { name = 'a' .. gametype .. 'b' } }, toc.files)
    end)
    it('does AllowLoad filtering', function()
      local lines = {
        'algame [AllowLoad Game]',
        'alglue [AllowLoad Glue]',
      }
      local files = parse(gametype, family, table.concat(lines, '\n'), {}).files
      assert.same({ { name = 'algame' } }, files)
    end)
    it('never excludes via AllowLoadGameType when the value is unknown', function()
      local lines = {
        'aaa [AllowLoadGameType ' .. gametype .. ']',
        'bbb [AllowLoadGameType ' .. family .. ']',
        'ccc [AllowLoadGameType nomatch]',
      }
      local files = parse(gametype, family, table.concat(lines, '\n'), {}).files
      assert.same({ { name = 'aaa' }, { name = 'bbb' }, { name = 'ccc' } }, files)
    end)
    it('excludes via AllowLoadGameType when the value is known but different', function()
      local lines = {
        'aaa [AllowLoadGameType ' .. gametype .. ']',
        'bbb [AllowLoadGameType otherfamily]',
        'ccc [AllowLoadGameType othergametype]',
        'ddd [AllowLoadGameType nomatch]',
      }
      local excluded = { otherfamily = true, othergametype = true }
      local files = parse(gametype, family, table.concat(lines, '\n'), excluded).files
      assert.same({ { name = 'aaa' }, { name = 'ddd' } }, files)
    end)
    it('flips ExcludeLoadGameType relative to AllowLoadGameType, except when nothing is recognized', function()
      local lines = {
        'aaa [ExcludeLoadGameType ' .. gametype .. ']',
        'bbb [ExcludeLoadGameType otherfamily]',
        'ccc [ExcludeLoadGameType othergametype]',
        'ddd [ExcludeLoadGameType nomatch]',
      }
      local excluded = { otherfamily = true, othergametype = true }
      local files = parse(gametype, family, table.concat(lines, '\n'), excluded).files
      -- aaa (own) and bbb/ccc (known but different) flip relative to
      -- AllowLoadGameType's result for the same lines; ddd (nothing
      -- recognized) is a no-op for either directive, so it loads for both
      assert.same({ { name = 'bbb' }, { name = 'ccc' }, { name = 'ddd' } }, files)
    end)
    it('does not let an unrecognized token rescue a known-different-only list', function()
      local lines = {
        'aaa [AllowLoadGameType otherfamily, nomatch]',
        'bbb [ExcludeLoadGameType otherfamily, nomatch]',
      }
      local excluded = { otherfamily = true }
      local files = parse(gametype, family, table.concat(lines, '\n'), excluded).files
      assert.same({ { name = 'bbb' } }, files)
    end)
    it('handles multiple filters', function()
      local line = 'aaa [AllowLoadGameType ' .. gametype .. '] [AllowLoadEnvironment Global] [Bootstrap]'
      local files = parse(gametype, family, line, {}).files
      assert.same({ { AllowLoadEnvironment = 'global', Bootstrap = true, name = 'aaa' } }, files)
    end)
  end)
  describe('suffixes', function()
    local suffixes = wowlesstoc.suffixes('Sometype', 'Somefamily')
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
end)
