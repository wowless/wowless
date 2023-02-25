return (function(self, button, down)
  if self.enabled and not self.beingClicked then
    self.beingClicked = true
    local b = button or 'LeftButton'
    api.RunScript(self, 'PreClick', b, down)
    api.RunScript(self, 'OnClick', b, down)
    api.RunScript(self, 'PostClick', b, down)
    self.beingClicked = false
  end
end)(...)
