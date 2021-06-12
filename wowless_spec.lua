describe('wowless', function()
  it('loads', function()
    -- busted gets confused if require fails, so we manually print errors
    local ret, err = pcall(function() require('wowless') end)
    if not ret then
      print(err)
      assert(false)
    end
  end)
end)
