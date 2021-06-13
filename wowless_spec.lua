describe('wowless', function()
  it('loads', function()
    -- busted gets confused if dofile fails, so we manually print errors
    local ret, err = pcall(function() dofile('wowless.lua') end)
    if not ret then
      print(err)
      assert(false)
    end
  end)
end)
