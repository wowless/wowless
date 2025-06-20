local T = ...
local format = string.format
return {
  ['format missing numbers'] = function()
    return T.match(1, '0', format('%d'))
  end,
  ['format nil numbers'] = function()
    return T.match(1, '0', format('%d', nil))
  end,
  ['does not format missing strings'] = function()
    return T.match(2, false, 'bad argument #2 to \'?\' (string expected, got no value)', pcall(format, '%s'))
  end,
  ['does not format nil strings'] = function()
    return T.match(2, false, 'bad argument #2 to \'?\' (string expected, got nil)', pcall(format, '%s', nil))
  end,
  ['format handles indexed substitution'] = function()
    return T.match(1, ' 7   moo', format('%2$2d %1$5s', 'moo', 7))
  end,
  ['format handles up to index 99 substitution'] = function()
    local arr = {}
    for i = 1, 100 do
      arr[i] = i
    end
    local t = {}
    for i = 1, 99 do
      local s = tostring(i)
      t[s] = function()
        return T.match(1, s, format('%' .. s .. '$d', unpack(arr)))
      end
    end
    t['100'] = function()
      return T.match(2, false, 'invalid format (width or precision too long)', pcall(format, '%100$d', unpack(arr)))
    end
    return t
  end,
  ['format handles %f'] = function()
    return T.match(1, 'inf', format('%f', math.huge):sub(-3))
  end,
  ['format handles %F'] = function()
    return T.match(1, 'inf', format('%F', math.huge):sub(-3))
  end,
}
