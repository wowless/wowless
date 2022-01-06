describe('impl', function()
  for filename in require('lfs').dir('data/impl') do
    if filename ~= '.' and filename ~= '..' then
      describe(filename, function()
        assert(filename:sub(-4) == '.lua', 'invalid file ' .. filename)
        assert(loadfile('data/impl/' .. filename))
      end)
    end
  end
end)
