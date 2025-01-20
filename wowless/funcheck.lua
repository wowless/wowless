return function(typechecker)
  local function makeCheckOutputs(fname, apicfg)
    local mayreturnnothing = apicfg.mayreturnnothing
    local outs = apicfg.outputs
    local nouts = #outs
    local outstride = apicfg.outstride
    local nfixed = nouts - (outstride or 0)
    return function(...)
      local n = select('#', ...)
      if n == 0 and mayreturnnothing then
        return
      end
      if outstride then
        if n < nfixed then
          error(('wrong number of return values to %q: want at least %d, got %d'):format(fname, nfixed, n))
        end
        local rem = mod(n - nfixed, outstride)
        if rem ~= 0 then
          error(('wrong number of return values to %q: want stride %d, got %d'):format(fname, outstride, rem))
        end
      elseif n ~= nouts then
        error(('wrong number of return values to %q: want %d, got %d'):format(fname, nouts, n))
      end
      local rets = {}
      for i = 1, nfixed do
        local out = outs[i]
        local v, errmsg = typechecker(out, (select(i, ...)), true)
        if errmsg then
          error(('output %d (%q) of %q %s'):format(i, tostring(out.name), fname, errmsg))
        end
        rets[i] = v
      end
      for i = nfixed + 1, n do
        local out = outs[mod(i - 1, outstride) + 1]
        local v, errmsg = typechecker(out, (select(i, ...)), true)
        if errmsg then
          error(('output %d (%q) of %q %s'):format(i, tostring(out.name), fname, errmsg))
        end
        rets[i] = v
      end
      return unpack(rets, 1, n)
    end
  end
  return {
    makeCheckOutputs = makeCheckOutputs,
  }
end
