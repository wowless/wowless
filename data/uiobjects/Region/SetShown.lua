return (function(self, shown)
  UpdateVisible(self, function()
    u(self).shown = not not shown
  end)
end)(...)
