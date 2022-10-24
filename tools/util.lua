local function returntable(t)
  return 'return ' .. require('pl.pretty').write(t) .. '\n'
end

local function writeifchanged(f, c)
  local lib = require('pl.file')
  if lib.read(f) ~= c then
    lib.write(f, c)
  end
end

return {
  returntable = returntable,
  writeifchanged = writeifchanged,
}
