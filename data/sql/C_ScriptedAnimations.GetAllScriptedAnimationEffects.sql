SELECT
  Alpha AS alpha,
  Animation AS animation,
  AnimationSpeed AS animationSpeed,
  AnimationStartOffset AS animationStartOffset,
  Duration AS duration,
  EndAlphaFade AS endAlphaFade,
  EndAlphaFadeDuration AS endAlphaFadeDuration,
  FinishBehavior AS finishBehavior,
  FinishEffectID AS finishEffectID,
  FinishSoundKitID AS finishSoundKitID,
  ID AS id,
  LoopingSoundKitID AS loopingSoundKitID,
  OffsetX AS offsetX,
  OffsetY AS offsetY,
  OffsetZ AS offsetZ,
  ParticleOverrideScale AS particleOverrideScale,
  PitchRadians AS pitchRadians,
  RollRadians AS rollRadians,
  StartAlphaFade AS startAlphaFade,
  StartAlphaFadeDuration AS startAlphaFadeDuration,
  StartBehavior AS startBehavior,
  StartSoundKitID AS startSoundKitID,
  Trajectory AS trajectory,
  Flags & 0x1 != 0 AS useTargetAsSource,
  Visual AS visual,
  VisualScale AS visualScale,
  YawRadians AS yawRadians
FROM
  UIScriptedAnimationEffect
ORDER BY
  ID;
