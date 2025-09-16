SELECT
  ButtonText_lang AS buttonText,
  CloseSoundKitID AS closeSoundKitID,
  ConfirmationQuestion_lang AS confirmationDescription,
  Cost AS cost,
  CurrencyTypeID AS currencyTypeId,
  Description_lang AS description,
  DropInSlotSoundKitID AS dropInSlotSoundKitId,
  Field_8_3_0_32414_012 AS interactionType, -- TODO fix dbdef
  Field_9_1_5_40196_004_lang AS buttonTooltip,
  ItemInteractionFrameType AS flags, -- TODO fix dbdef
  OpenSoundKitID AS openSoundKitID,
  TitleText_lang AS titleText,
  TutorialText_lang AS tutorialText,
  UiTextureKitID AS textureKit
FROM
  UiItemInteraction
WHERE
  ID = ?1;
