local hlist = require('wowless.hlist')

return function(uiobjects, xmleval)
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
    CreateUIObject = xmleval.CreateUIObject,
    hlist = hlist,
    SetParent = uiobjects.SetParent,
    ToTexture = ToTexture,
  }
end
