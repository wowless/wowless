return function()
  -- TODO make a proper API out of this
  return {
    -- strictly speaking should be spec specific (nil if no spec selected)
    activeConfigID = 12345,
    pendingViewLoadoutLevel = nil, -- currently unused
    pendingViewLoadoutSpecID = nil,
    -- true after ViewLoadout is called, reset on InitializeViewLoadout
    -- currently used to generate warnings for bad usage. This deviates from how the
    -- real client handles it!
    viewLoadoutDataImported = false,
    viewLoadoutSpecID = nil,
  }
end
