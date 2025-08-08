local function returntable(t)
  return 'return ' .. require('pl.pretty').write(t) .. '\n'
end

local function writeifchanged(f, c)
  local lib = require('pl.file')
  if lib.read(f) ~= c then
    lib.write(f, c)
  end
end

local abs = require('pl.path').abspath

local function writedeps(f, deps)
  local t = { f, ':' }
  for dep in require('pl.tablex').sort(deps) do
    table.insert(t, ' \\\n ')
    table.insert(t, abs(dep))
  end
  table.insert(t, '\n\n')
  require('pl.file').write(f .. '.d', table.concat(t))
end

return {
  returntable = returntable,
  writedeps = writedeps,
  writeifchanged = writeifchanged,
}
