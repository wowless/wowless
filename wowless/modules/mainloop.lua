return function(api, scripts, time, visibility)
  local Advance = time.Advance
  local frames = api.frames
  local IsVisible = visibility.IsVisible
  local RunScript = scripts.RunScript

  local function NextFrame(elapsed)
    Advance(elapsed)
    for frame in frames:entries() do
      if IsVisible(frame) then
        RunScript(frame, 'OnUpdate', 1)
      end
    end
    for frame in frames:entries() do
      if IsVisible(frame) then
        frame:GetRect() -- force recomputation if dirty
      end
    end
  end

  return {
    NextFrame = NextFrame,
  }
end
