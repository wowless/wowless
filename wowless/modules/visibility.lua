return function(scripts)
  local RunScript = scripts.RunScript

  local function IsVisible(obj)
    while obj do
      if not obj.shown then
        return false
      end
      obj = obj.parent
    end
    return true
  end

  local function DoUpdateVisible(obj, script)
    for kid in obj.children:entries() do
      if kid.shown then
        DoUpdateVisible(kid, script)
      end
    end
    RunScript(obj, script)
  end

  local function UpdateVisible(obj, visible)
    DoUpdateVisible(obj, visible and 'OnShow' or 'OnHide')
  end

  local function SetShown(obj, shown)
    if obj.shown ~= shown then
      obj.shown = shown
      if IsVisible(obj.parent) then
        UpdateVisible(obj, shown)
      end
    end
  end

  local function Hide(obj)
    return SetShown(obj, false)
  end

  local function Show(obj)
    return SetShown(obj, true)
  end

  return {
    Hide = Hide,
    IsVisible = IsVisible,
    SetShown = SetShown,
    Show = Show,
    UpdateVisible = UpdateVisible,
  }
end
