local T, trim = ...
return {
  basic = function()
    return T.match(1, 'hello', trim('  hello  '))
  end,
  ['custom delimiter'] = function()
    return T.match(1, 'hello', trim('xxhelloxx', 'x'))
  end,
  ['default trims cr lf tab'] = function()
    return T.match(1, 'hello', trim('\r\n\thello\t\n\r'))
  end,
  ['empty string'] = function()
    return T.match(1, '', trim(''))
  end,
  ['all delimiters'] = function()
    return T.match(1, '', trim('   '))
  end,
  ['no trim needed'] = function()
    return T.match(1, 'hello', trim('hello'))
  end,
  ['no arg errors'] = function()
    return T.match(1, false, (pcall(trim)))
  end,
}
