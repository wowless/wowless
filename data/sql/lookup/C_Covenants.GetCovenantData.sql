SELECT
  Covenant.ID AS ID,
  Covenant.Name_lang AS name,
  UiTextureKit.KitPrefix AS textureKit,
  UiCovenantDisplayInfo.AnimaChannelActiveSoundKitID AS animaChannelActiveSoundKit,
  UiCovenantDisplayInfo.AnimaChannelSelectSoundKitID AS animaChannelSelectSoundKit,
  UiCovenantDisplayInfo.AnimaGemsFullSoundKitID AS animaGemsFullSoundKit,
  UiCovenantDisplayInfo.AnimaNewGemSoundKitID AS animaNewGemSoundKit,
  UiCovenantDisplayInfo.AnimaReinforceSelectSoundKitID AS animaReinforceSelectSoundKit,
  UiCovenantDisplayInfo.BeginResearchSoundKitID AS beginResearchSoundKitID,
  UiCovenantDisplayInfo.CelebrationSoundKitID AS celebrationSoundKit,
  UiCovenantDisplayInfo.RenownFanfareSoundKitID AS renownFanfareSoundKitID,
  UiCovenantDisplayInfo.ReservoirFullSoundKitID AS reservoirFullSoundKitID,
  UiCovenantDisplayInfo.UpgradeTabSelectSoundKitID AS upgradeTabSelectSoundKitID
FROM
  Covenant
  JOIN UiCovenantDisplayInfo ON Covenant.ID = UiCovenantDisplayInfo.CovenantID
  JOIN UiTextureKit ON UiCovenantDisplayInfo.UiTextureKitID = UiTextureKit.ID
WHERE
  Covenant.ID = ?1;
