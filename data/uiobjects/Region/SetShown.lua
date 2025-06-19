local api = ...
return function(self, shown)
  api.UpdateVisible(self, function()
    self.shown = not not shown
  end)
end
