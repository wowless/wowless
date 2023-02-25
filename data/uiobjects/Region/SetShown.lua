return (function(self, shown)
  UpdateVisible(self, function()
    self.shown = not not shown
  end)
end)(...)
