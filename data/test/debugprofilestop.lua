local T, debugprofilestart, debugprofilestop = ...
return {
  ['returns a number'] = function()
    return T.match(1, 'number', type(debugprofilestop()))
  end,
  ['ignores extra arguments'] = function()
    return T.match(1, 'number', type(debugprofilestop(1, 2, 3)))
  end,
  ['measures elapsed time since debugprofilestart'] = function()
    debugprofilestart()
    local elapsed = debugprofilestop()
    assert(type(elapsed) == 'number')
    assert(elapsed >= 0)
  end,
  ['does not reset between consecutive calls'] = function()
    debugprofilestart()
    local first = debugprofilestop()
    local second = debugprofilestop()
    assert(second >= first)
  end,
}
