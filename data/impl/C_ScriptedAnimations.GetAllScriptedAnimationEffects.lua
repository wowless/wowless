local uiscriptedanimationeffect = ...
local t = {}
for row in uiscriptedanimationeffect() do
  table.insert(t, {
    alpha = row.Alpha,
    animation = row.Animation,
    animationSpeed = row.AnimationSpeed,
    animationStartOffset = row.AnimationStartOffset,
    duration = row.Duration,
    endAlphaFade = row.EndAlphaFade,
    endAlphaFadeDuration = row.EndAlphaFadeDuration,
    finishBehavior = row.FinishBehavior,
    finishEffectID = row.FinishEffectID,
    finishSoundKitID = row.FinishSoundKitID,
    id = row.ID,
    loopingSoundKitID = row.LoopingSoundKitID,
    offsetX = row.OffsetX,
    offsetY = row.OffsetY,
    offsetZ = row.OffsetZ,
    particleOverrideScale = row.ParticleOverrideScale,
    pitchRadians = row.PitchRadians,
    rollRadians = row.RollRadians,
    startAlphaFade = row.StartAlphaFade,
    startAlphaFadeDuration = row.StartAlphaFadeDuration,
    startBehavior = row.StartBehavior,
    startSoundKitID = row.StartSoundKitID,
    trajectory = row.Trajectory,
    useTargetAsSource = bit.band(row.Flags or 0, 0x1) ~= 0,
    visual = row.Visual,
    visualScale = row.VisualScale,
    yawRadians = row.YawRadians,
  })
end
table.sort(t, function(a, b)
  return a.id < b.id
end)
return t
