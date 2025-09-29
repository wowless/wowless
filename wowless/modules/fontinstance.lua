return function()
  local function GetFontObject(fi)
    return fi.fontObject
  end

  local function SetFontObject(fi, obj)
    local p = obj
    while p do
      if fi == p then
        error(fi.name .. ':SetFontObject(): Can\'t create a font object loop', 0)
      end
      p = p.fontObject
    end
    fi.fontObject = obj
  end

  return {
    GetFontObject = GetFontObject,
    SetFontObject = SetFontObject,
  }
end
