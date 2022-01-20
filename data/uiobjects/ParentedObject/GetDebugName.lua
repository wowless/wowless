return (function(self)
  local frame = self
  local ud = u(frame)
  local name = ud.name
  if name ~= nil then
    return name
  end
  name = ""
  local parent = ud.parent
  local pud
  while parent do
    pud = u(parent)
    local found = false
    for k,v in pairs(parent) do
      if v == frame then
        name = k .. (name == "" and "" or ("." .. name))
        found = true
      end
    end
    if not found then
      name = string.match(tostring(frame), "^table: 0x0*(.*)$"):lower() .. (name == "" and "" or ("." .. name))
    end

    local parentName = pud.name
    if parentName == "UIParent" then
      break
    elseif parentName and parentName ~= "" then
      name = parentName .. "." .. name
      break
    end

    frame = parent
    parent = pud.parent
  end

  return name
end)(...)
