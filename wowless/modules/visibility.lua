return function(scripts)
  local RunScript = scripts.RunScript

  -- `visible` is a cached bit kept up to date by SetShown/SetParent below,
  -- rather than recomputed by walking the parent chain on every call.
  local function IsVisible(obj)
    return obj == nil or obj.visible
  end

  -- Every affected descendant's cached bit must be updated before any of
  -- their OnShow/OnHide scripts fire, so a handler on one branch always
  -- sees the final state of every other branch. So this runs as two
  -- passes: first refresh `visible` across the whole affected subtree,
  -- then fire scripts in the original per-node-recursive order.
  local function SetVisibleBits(obj, visible)
    obj.visible = visible
    if obj.children then
      for kid in obj.regions:entries() do
        if kid.shown then
          kid.visible = visible
        end
      end
      for kid in obj.children:entries() do
        if kid.shown then
          SetVisibleBits(kid, visible)
        end
      end
    end
  end

  -- Regions can't have their own children or regions, so their scripts
  -- fire directly rather than recursing; only frames recurse further.
  local function FireVisibleScripts(obj, script)
    if obj.children then
      for kid in obj.regions:entries() do
        if kid.shown then
          RunScript(kid, script)
        end
      end
      for kid in obj.children:entries() do
        if kid.shown then
          FireVisibleScripts(kid, script)
        end
      end
    end
    RunScript(obj, script)
  end

  local function UpdateVisible(obj, visible)
    SetVisibleBits(obj, visible)
    FireVisibleScripts(obj, visible and 'OnShow' or 'OnHide')
  end

  local function SetShown(obj, shown)
    if obj.shown ~= shown then
      obj.shown = shown
      local visible = shown and IsVisible(obj.parent)
      if visible ~= obj.visible then
        UpdateVisible(obj, visible)
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
