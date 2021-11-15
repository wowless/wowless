return (function(self, button, down)
  local ud = u(self)
  if ud.enabled and not ud.beingClicked then
    ud.beingClicked = true
    local b = button or 'LeftButton'
    api.RunScript(self, 'PreClick', b, down)
    api.RunScript(self, 'OnClick', b, down)
    api.RunScript(self, 'PostClick', b, down)
    ud.beingClicked = false
  end
end)(...)
