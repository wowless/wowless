return function(self, arg1, arg2, ...)
  local attrs = self.attributes
  if arg1 and not arg2 then
    return attrs[arg1]
  elseif not arg2 or select('#', ...) == 0 then
    local taint = _G.THETAINT and '\nLua Taint: ' .. _G.THETAINT or ''
    error('Arguments: ("name")' .. taint, 0)
  else
    arg1 = arg1 or ''
    local arg3 = (...) or ''
    local keys = {
      arg1 .. arg2 .. arg3,
      '*' .. arg2 .. arg3,
      arg1 .. arg2 .. '*',
      '*' .. arg2 .. '*',
      arg2,
    }
    for _, k in ipairs(keys) do
      if attrs[k] then
        return attrs[k]
      end
    end
    return nil
  end
end
