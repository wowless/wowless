return function(self, text)
  if type(text) == 'number' then
    text = tostring(text)
  end
  self.text = type(text) == 'string' and text or nil
end
