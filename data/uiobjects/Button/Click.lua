local api = ...
return function(self, button, down)
  if self.enabled and not self.beingClicked then
    self.beingClicked = true
    api.RunScript(self, 'PreClick', button, down)
    api.RunScript(self, 'OnClick', button, down)
    api.RunScript(self, 'PostClick', button, down)
    self.beingClicked = false
  end
end
