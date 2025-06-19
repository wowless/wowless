return function(self, arg1, arg2, arg3)
  local attrs = self.attributes
  if arg3 then
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
  else
    return attrs[arg1]
  end
end
