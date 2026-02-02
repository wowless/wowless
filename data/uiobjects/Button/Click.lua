local scripts = ...
return function(self, button, down)
  if self.enabled and not self.beingClicked then
    self.beingClicked = true
    scripts.RunScript(self, 'PreClick', button, down)
    scripts.RunScript(self, 'OnClick', button, down)
    scripts.RunScript(self, 'PostClick', button, down)
    self.beingClicked = false
  end
end
