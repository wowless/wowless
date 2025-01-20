return function(typechecker)
  local function makeCheckOutputs(fname, apicfg)
    local mayreturnnothing = apicfg.mayreturnnothing
    local outs = apicfg.outputs
    local nouts = #outs
    return function(...)
      local n = select('#', ...)
      if n == 0 and mayreturnnothing then
        return
      end
      if n ~= nouts then
        error(('wrong number of return values to %q: want %d, got %d'):format(fname, nouts, n))
      end
      local rets = {}
      for i, out in ipairs(outs) do
        local v, errmsg = typechecker(out, (select(i, ...)), true)
        if errmsg then
          error(('output %d (%q) of %q %s'):format(i, tostring(out.name), fname, errmsg))
        end
        rets[i] = v
      end
      return unpack(rets, 1, nouts)
    end
  end
  return {
    makeCheckOutputs = makeCheckOutputs,
  }
end
