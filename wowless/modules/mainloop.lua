return function(api, eventqueue, region, scripts, time, visibility)
  local Advance = time.Advance
  local DrainEvents = eventqueue.DrainEvents
  local frames = api.frames
  local GetRect = region.GetRect
  local IsVisible = visibility.IsVisible
  local RunScript = scripts.RunScript

  local function NextFrame(elapsed)
    DrainEvents()
    Advance(elapsed)
    for frame in frames:entries() do
      if IsVisible(frame) then
        RunScript(frame, 'OnUpdate', elapsed)
      end
    end
    for frame in frames:entries() do
      if IsVisible(frame) then
        GetRect(frame) -- force recomputation if dirty
      end
    end
  end

  return {
    NextFrame = NextFrame,
  }
end
