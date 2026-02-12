return function()
  local function SetDirty(r)
    if not r.dirty then
      r.dirty = true
      for dep in pairs(r.anchoredBy) do
        SetDirty(dep)
      end
    end
  end

  return {
    SetDirty = SetDirty,
  }
end
