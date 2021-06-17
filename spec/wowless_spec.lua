describe('wowless', function()
  it('loads', function()
    local ret, err = pcall(function() dofile('wowless.lua') end)
    if not ret then
      print(err)
      assert(false)
    end
  end)
end)
