return (function(self, ...)
  local ud = u(self)
  util.twipe(ud.registeredClicks)
  for _, type in ipairs({...}) do
    ud.registeredClicks[type] = true
  end
end)(...)
