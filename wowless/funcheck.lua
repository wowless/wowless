return function(typechecker, log)
  local function makeCheckInputs(fname, apicfg)
    local ins = apicfg.inputs
    local nins = #apicfg.inputs
    local instride = apicfg.instride or 0
    local nfixed = nins - instride
    return function(...)
      local args = {}
      for i = 1, nfixed do
        local param = ins[i]
        local v, errmsg, iswarn = typechecker(param, (select(i, ...)))
        if not errmsg then
          args[i] = v
        else
          local msg = ('arg %d (%q) of %q %s'):format(i, tostring(param.name), fname, errmsg)
          if iswarn then
            log(1, 'warning: ' .. msg)
          else
            error(msg)
          end
        end
      end
      local argn = nfixed
      local n = select('#', ...)
      if instride > 0 then
        for i = nfixed, n - 1, instride do
          for j = 1, instride do
            local param = ins[nfixed + j]
            local v, errmsg, iswarn = typechecker(param, (select(i + j, ...)))
            if not errmsg then
              args[i + j] = v
            else
              local msg = ('arg %d (%q) of %q %s'):format(i + j, tostring(param.name), fname, errmsg)
              if iswarn then
                log(1, 'warning: ' .. msg)
              else
                error(msg)
              end
            end
          end
          argn = argn + instride
        end
      elseif n > nins then
        local d = debug.getinfo(4)
        log(1, 'warning: too many arguments passed to %s at %s:%d', fname, d.source:sub(2), d.currentline)
      end
      return unpack(args, 1, argn)
    end
  end
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
        local out = outs[mod(i - nfixed - 1, outstride) + nfixed + 1]
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
    makeCheckInputs = makeCheckInputs,
    makeCheckOutputs = makeCheckOutputs,
  }
end
