describe('test', function()
  local luas = {}
  for _, f in ipairs(require('wowless.util').getfiles('data/test')) do
    luas[f] = assert(require('pl.file').read(f))
  end
  it('references exactly the files in data/test', function()
    local expected = {}
    for k in pairs(require('build.data.test')) do
      expected['data/test/' .. k .. '.lua'] = true
    end
    local actual = {}
    for f in pairs(luas) do
      actual[f] = true
    end
    assert.same(expected, actual)
  end)
  for filename, content in pairs(luas) do
    describe(filename, function()
      it('has the right preamble', function()
        local preamble = 'local T = ...\n'
        assert.same(preamble, content:sub(1, preamble:len()))
      end)
      it('loads', function()
        assert(loadstring(content, '@' .. filename))
      end)
    end)
  end
end)
