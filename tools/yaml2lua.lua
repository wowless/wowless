-- pl.pretty uses string.format('%d') for integers, which overflows 32-bit
-- long on Windows (LLP64 ABI). Patch it to use '%.0f' instead, which uses
-- double arithmetic and handles values up to 2^53 correctly on all platforms.
local _fmt = string.format
string.format = function(s, ...) -- luacheck: ignore
  if s == '%d' then
    local v = select(1, ...)
    if type(v) == 'number' and (v >= 2 ^ 31 or v < -(2 ^ 31)) then
      return _fmt('%.0f', v)
    end
  end
  return _fmt(s, ...)
end
local t = assert(require('wowapi.yaml').parseFile(arg[1]))
local s = 'return ' .. require('pl.pretty').write(t)
string.format = _fmt -- luacheck: ignore
assert(require('pl.dir').makepath(require('pl.path').dirname(arg[2])))
assert(require('pl.file').write(arg[2], s))
