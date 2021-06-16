describe('xml.lua', function()
  local module = dofile('xml.lua')
  local handle = io.popen('find wowui/classic/{SharedXML,FrameXML,AddOns} -name "*.xml"')
  for line in handle:lines() do
    it('handles ' .. line, function()
      module.validate(line)
    end)
  end
  handle:close()
end)
