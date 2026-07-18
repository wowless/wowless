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

  -- Regions can't have their own children or regions, so their scripts
  -- fire directly rather than recursing; only frames reach this function.
  local function DoUpdateVisible(frame, script)
    for kid in frame.regions:entries() do
      if kid.shown then
        RunScript(kid, script)
      end
    end
    for kid in frame.children:entries() do
      if kid.shown then
        DoUpdateVisible(kid, script)
      end
    end
    RunScript(frame, script)
  end

  local function UpdateVisible(obj, visible)
    local script = visible and 'OnShow' or 'OnHide'
    if obj.children then
      DoUpdateVisible(obj, script)
    else
      RunScript(obj, script)
    end
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
