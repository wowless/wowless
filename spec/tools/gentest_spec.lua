describe('gentest', function()
  local filemap = loadfile('tools/gentest.lua')('-n')
  for k, v in pairs(filemap) do
    it(k .. ' is consistent', function()
      local addon = require('pl.file').read(k)
      assert(v == addon)
    end)
  end
end)
