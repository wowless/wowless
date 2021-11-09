describe('addon #small', function()
  local versions = {
    'Vanilla',
    'TBC',
    'Mainline',
  }
  for _, version in ipairs(versions) do
    describe(version, function()
      it('loads successfully', function()
        local api = require('wowless.api').new(function(level, ...)
          if level == 0 then
            print(string.format(...))
          end
        end)
        local loader = require('wowless.loader').loader(api, {
          version = version,
        })
        require('wowless.env').init(api, loader)
        loader.loadToc(('addon/Wowless/Wowless_%s.toc'):format(version), 'Wowless')
        assert.same(0, api.GetErrorCount())
      end)
    end)
  end
end)
