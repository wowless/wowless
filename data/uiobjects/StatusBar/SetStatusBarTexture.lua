return (function(self, tex)
  if type(tex) == 'number' then
    api.log(1, 'unimplemented call to SetStatusBarTexture')
    u(self).statusBarTexture = m(self, 'CreateTexture')
  else
    u(self).statusBarTexture = toTexture(self, tex)
  end
end)(...)
