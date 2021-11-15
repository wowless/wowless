return (function(self, text)
  u(self).fontstring = u(self).fontstring or m(self, 'CreateFontString')
  m(u(self).fontstring, 'SetText', text)
end)(...)
