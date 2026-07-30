local hlist = require('wowless.hlist')

return function(api)
  local function ToTexture(parent, tex, obj)
    if type(tex) == 'string' or type(tex) == 'number' then
      local t = obj or parent:CreateTexture()
      t:SetTexture(tex)
      return t
    else
      return tex
    end
  end

  return {
    CreateUIObject = api.CreateUIObject,
    hlist = hlist,
    SetParent = api.SetParent,
    ToTexture = ToTexture,
  }
end
