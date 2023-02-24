return (function(self, shown)
  UpdateVisible(u(self), function()
    u(self).shown = not not shown
  end)
end)(...)
