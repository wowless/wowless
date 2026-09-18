local T, scrub = ...
return {
  ['passes through supported types'] = function()
    return T.match(3, 1, 'a', true, scrub(1, 'a', true))
  end,
  ['scrubs unsupported types to nil'] = function()
    return T.match(3, nil, nil, nil, scrub({}, function() end, coroutine.create(function() end)))
  end,
  ['preserves argument count, order, and explicit nils'] = function()
    return T.match(5, 1, nil, 'a', nil, true, scrub(1, {}, 'a', nil, true))
  end,
  ['no args returns no values'] = function()
    return T.retn(0, scrub())
  end,
}
