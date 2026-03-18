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
        local impl = filename:match('([^/]+)%.lua$')
        local implfns = require('build.data.test')[impl]
        local vars = {}
        for k in pairs(implfns) do
          table.insert(vars, k:match('[^.]+$'))
        end
        table.sort(vars)
        local preamble = 'local T, ' .. table.concat(vars, ', ') .. ' = ...\n'
        assert.same(preamble, content:sub(1, preamble:len()))
      end)
      it('loads', function()
        assert(loadstring(content, '@' .. filename))
      end)
    end)
  end
end)
