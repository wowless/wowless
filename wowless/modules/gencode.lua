local hlist = require('wowless.hlist')

return function(api, env, log, luaobjects, typecheck, uiobjects)
  local function Check(spec, v, isout)
    local vv, errmsg, iswarn = typecheck(spec, v, isout)
    if errmsg then
      local inout = isout and 'output' or 'input'
      local name = spec.name and (' %q'):format(spec.name) or ''
      local msg = ('%s%s %s'):format(inout, name, errmsg)
      if iswarn then
        log(1, 'warning: ' .. msg)
      else
        error(msg, 2)
      end
    end
    return vv
  end

  local function ToTexture(parent, tex, obj)
    if type(tex) == 'string' or type(tex) == 'number' then
      local t = obj or uiobjects.UserData(parent:CreateTexture())
      t:SetTexture(tex)
      return t
    else
      return tex and uiobjects.UserData(tex)
    end
  end

  return {
    Check = Check,
    CreateLuaObject = luaobjects.Create,
    CreateUIObject = api.CreateUIObject,
    hlist = hlist,
    Mixin = env.mixin,
    SetParent = api.SetParent,
    ToTexture = ToTexture,
  }
end
