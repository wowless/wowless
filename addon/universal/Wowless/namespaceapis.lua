local _, G = ...
G.NamespaceApis = {
  C_AccountInfo = {
    methods = {
      GetIDFromBattleNetAccountGUID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsGUIDBattleNetAccountType = true,
      IsGUIDRelatedToLocalAccount = true,
    },
  },
  C_AchievementInfo = {
    methods = {
      GetRewardItemID = true,
      GetSupercedingAchievements = true,
      IsGuildAchievement = {
        products = {
          wow_beta = true,
        },
      },
      IsValidAchievement = true,
      SetPortraitTexture = true,
    },
  },
  C_ActionBar = {
    methods = {
      FindFlyoutActionButtons = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      FindPetActionButtons = true,
      FindSpellActionButtons = true,
      GetBonusBarIndexForSlot = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetItemActionOnEquipSpellID = {
        products = {
          wow_beta = true,
        },
      },
      GetPetActionPetBarIndices = true,
      HasFlyoutActionButtons = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      HasPetActionButtons = true,
      HasPetActionPetBarIndices = true,
      HasSpellActionButtons = true,
      IsAutoCastPetAction = true,
      IsEnabledAutoCastPetAction = true,
      IsHarmfulAction = true,
      IsHelpfulAction = true,
      IsOnBarOrSpecialBar = true,
      PutActionInSlot = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ShouldOverrideBarShowHealthBar = {
        products = {
          wow = true,
          wow_beta = true,
          wow_classic_beta = true,
          wow_classic_ptr = true,
          wowt = true,
        },
      },
      ShouldOverrideBarShowManaBar = {
        products = {
          wow = true,
          wow_beta = true,
          wow_classic_beta = true,
          wow_classic_ptr = true,
          wowt = true,
        },
      },
      ToggleAutoCastPetAction = true,
    },
  },
  C_AdventureJournal = {
    methods = {
      ActivateEntry = true,
      CanBeShown = true,
      GetNumAvailableSuggestions = true,
      GetPrimaryOffset = true,
      GetReward = true,
      GetSuggestions = true,
      SetPrimaryOffset = true,
      UpdateSuggestions = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_AdventureMap = {
    methods = {
      Close = true,
      GetMapID = true,
      GetMapInsetDetailTileInfo = true,
      GetMapInsetInfo = true,
      GetNumMapInsets = true,
      GetNumQuestOffers = true,
      GetNumZoneChoices = true,
      GetQuestInfo = true,
      GetQuestOfferInfo = true,
      GetZoneChoiceInfo = true,
      StartQuest = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_AlliedRaces = {
    methods = {
      ClearAlliedRaceDetailsGiver = true,
      GetAllRacialAbilitiesFromID = true,
      GetRaceInfoByID = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_AnimaDiversion = {
    methods = {
      CloseUI = true,
      GetAnimaDiversionNodes = true,
      GetOriginPosition = true,
      GetReinforceProgress = true,
      GetTextureKit = true,
      OpenAnimaDiversionUI = true,
      SelectAnimaNode = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_ArdenwealdGardening = {
    methods = {
      GetGardenData = true,
      IsGardenAccessible = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_AreaPoiInfo = {
    methods = {
      GetAreaPOIForMap = true,
      GetAreaPOIInfo = true,
      GetAreaPOISecondsLeft = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAreaPOITimeLeft = {
        products = {
          wow_classic = true,
          wow_classic_beta = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
          wow_classic_ptr = true,
        },
      },
      IsAreaPOITimed = true,
    },
  },
  C_ArtifactUI = {
    methods = {
      AddPower = true,
      ApplyCursorRelicToSlot = true,
      CanApplyArtifactRelic = true,
      CanApplyCursorRelicToSlot = true,
      CanApplyRelicItemIDToEquippedArtifactSlot = true,
      CanApplyRelicItemIDToSlot = true,
      CheckRespecNPC = true,
      Clear = true,
      ClearForgeCamera = true,
      ConfirmRespec = true,
      DoesEquippedArtifactHaveAnyRelicsSlotted = true,
      GetAppearanceInfo = true,
      GetAppearanceInfoByID = true,
      GetAppearanceSetInfo = true,
      GetArtifactArtInfo = true,
      GetArtifactInfo = true,
      GetArtifactItemID = true,
      GetArtifactTier = true,
      GetArtifactXPRewardTargetInfo = true,
      GetCostForPointAtRank = true,
      GetEquippedArtifactArtInfo = true,
      GetEquippedArtifactInfo = true,
      GetEquippedArtifactItemID = true,
      GetEquippedArtifactNumRelicSlots = true,
      GetEquippedArtifactRelicInfo = true,
      GetEquippedRelicLockedReason = true,
      GetForgeRotation = true,
      GetItemLevelIncreaseProvidedByRelic = true,
      GetMetaPowerInfo = true,
      GetNumAppearanceSets = true,
      GetNumObtainedArtifacts = true,
      GetNumRelicSlots = true,
      GetPointsRemaining = true,
      GetPowerHyperlink = true,
      GetPowerInfo = true,
      GetPowerLinks = true,
      GetPowers = true,
      GetPowersAffectedByRelic = true,
      GetPowersAffectedByRelicItemLink = true,
      GetPreviewAppearance = true,
      GetRelicInfo = true,
      GetRelicInfoByItemID = true,
      GetRelicLockedReason = true,
      GetRelicSlotType = true,
      GetRespecArtifactArtInfo = true,
      GetRespecArtifactInfo = true,
      GetRespecCost = true,
      GetTotalPowerCost = true,
      GetTotalPurchasedRanks = true,
      IsArtifactDisabled = true,
      IsAtForge = true,
      IsEquippedArtifactDisabled = true,
      IsEquippedArtifactMaxed = true,
      IsMaxedByRulesOrEffect = true,
      IsPowerKnown = true,
      IsViewedArtifactEquipped = true,
      SetAppearance = true,
      SetForgeCamera = true,
      SetForgeRotation = true,
      SetPreviewAppearance = true,
      ShouldSuppressForgeRotation = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_AuctionHouse = {
    methods = {
      CalculateCommodityDeposit = true,
      CalculateItemDeposit = true,
      CanCancelAuction = true,
      CancelAuction = true,
      CancelCommoditiesPurchase = true,
      CancelSell = true,
      CloseAuctionHouse = true,
      ConfirmCommoditiesPurchase = true,
      ConfirmPostCommodity = true,
      ConfirmPostItem = true,
      FavoritesAreAvailable = true,
      GetAuctionInfoByID = true,
      GetAuctionItemSubClasses = true,
      GetAvailablePostCount = true,
      GetBidInfo = true,
      GetBidType = true,
      GetBids = true,
      GetBrowseResults = true,
      GetCancelCost = true,
      GetCommoditySearchResultInfo = true,
      GetCommoditySearchResultsQuantity = true,
      GetExtraBrowseInfo = true,
      GetFilterGroups = true,
      GetItemCommodityStatus = true,
      GetItemKeyFromItem = true,
      GetItemKeyInfo = true,
      GetItemKeyRequiredLevel = true,
      GetItemSearchResultInfo = true,
      GetItemSearchResultsQuantity = true,
      GetMaxBidItemBid = true,
      GetMaxBidItemBuyout = true,
      GetMaxCommoditySearchResultPrice = true,
      GetMaxItemSearchResultBid = true,
      GetMaxItemSearchResultBuyout = true,
      GetMaxOwnedAuctionBid = true,
      GetMaxOwnedAuctionBuyout = true,
      GetNumBidTypes = true,
      GetNumBids = true,
      GetNumCommoditySearchResults = true,
      GetNumItemSearchResults = true,
      GetNumOwnedAuctionTypes = true,
      GetNumOwnedAuctions = true,
      GetNumReplicateItems = true,
      GetOwnedAuctionInfo = true,
      GetOwnedAuctionType = true,
      GetOwnedAuctions = true,
      GetQuoteDurationRemaining = true,
      GetReplicateItemBattlePetInfo = true,
      GetReplicateItemInfo = true,
      GetReplicateItemLink = true,
      GetReplicateItemTimeLeft = true,
      GetTimeLeftBandInfo = true,
      HasFavorites = true,
      HasFullBidResults = true,
      HasFullBrowseResults = true,
      HasFullCommoditySearchResults = true,
      HasFullItemSearchResults = true,
      HasFullOwnedAuctionResults = true,
      HasMaxFavorites = true,
      HasSearchResults = true,
      IsFavoriteItem = true,
      IsSellItemValid = true,
      IsThrottledMessageSystemReady = true,
      MakeItemKey = true,
      PlaceBid = true,
      PostCommodity = true,
      PostItem = true,
      QueryBids = true,
      QueryOwnedAuctions = true,
      RefreshCommoditySearchResults = true,
      RefreshItemSearchResults = true,
      ReplicateItems = true,
      RequestFavorites = true,
      RequestMoreBrowseResults = true,
      RequestMoreCommoditySearchResults = true,
      RequestMoreItemSearchResults = true,
      RequestOwnedAuctionBidderInfo = true,
      SearchForFavorites = true,
      SearchForItemKeys = true,
      SendBrowseQuery = true,
      SendSearchQuery = true,
      SendSellSearchQuery = true,
      SetFavoriteItem = true,
      StartCommoditiesPurchase = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_AzeriteEmpoweredItem = {
    methods = {
      CanSelectPower = true,
      CloseAzeriteEmpoweredItemRespec = true,
      ConfirmAzeriteEmpoweredItemRespec = true,
      GetAllTierInfo = true,
      GetAllTierInfoByItemID = true,
      GetAzeriteEmpoweredItemRespecCost = true,
      GetPowerInfo = true,
      GetPowerText = true,
      GetSpecsForPower = true,
      HasAnyUnselectedPowers = true,
      HasBeenViewed = true,
      IsAzeriteEmpoweredItem = true,
      IsAzeriteEmpoweredItemByID = true,
      IsAzeritePreviewSourceDisplayable = true,
      IsHeartOfAzerothEquipped = true,
      IsPowerAvailableForSpec = true,
      IsPowerSelected = true,
      SelectPower = true,
      SetHasBeenViewed = true,
    },
  },
  C_AzeriteEssence = {
    methods = {
      ActivateEssence = true,
      CanActivateEssence = true,
      CanDeactivateEssence = true,
      CanOpenUI = true,
      ClearPendingActivationEssence = true,
      CloseForge = true,
      GetEssenceHyperlink = true,
      GetEssenceInfo = true,
      GetEssences = true,
      GetMilestoneEssence = true,
      GetMilestoneInfo = true,
      GetMilestoneSpell = true,
      GetMilestones = true,
      GetNumUnlockedEssences = true,
      GetNumUsableEssences = true,
      GetPendingActivationEssence = true,
      HasNeverActivatedAnyEssences = true,
      HasPendingActivationEssence = true,
      IsAtForge = true,
      SetPendingActivationEssence = true,
      UnlockMilestone = true,
    },
  },
  C_AzeriteItem = {
    methods = {
      FindActiveAzeriteItem = true,
      GetAzeriteItemXPInfo = true,
      GetPowerLevel = true,
      GetUnlimitedPowerLevel = true,
      HasActiveAzeriteItem = true,
      IsAzeriteItem = true,
      IsAzeriteItemAtMaxLevel = true,
      IsAzeriteItemByID = true,
      IsAzeriteItemEnabled = true,
    },
  },
  C_BarberShop = {
    methods = {
      ApplyCustomizationChoices = true,
      Cancel = true,
      ClearPreviewChoices = true,
      CycleCharCustomization = {
        products = {
          wow_classic_beta = true,
          wow_classic_ptr = true,
        },
      },
      GetAvailableCustomizations = true,
      GetBarbersChoiceCost = {
        products = {
          wow_classic_beta = true,
          wow_classic_ptr = true,
        },
      },
      GetCurrentCameraZoom = true,
      GetCurrentCharacterData = true,
      GetCurrentCost = true,
      GetCustomizationTypeInfo = {
        products = {
          wow_classic_beta = true,
          wow_classic_ptr = true,
        },
      },
      HasAnyChanges = true,
      IsValidCustomizationType = {
        products = {
          wow_classic_beta = true,
          wow_classic_ptr = true,
        },
      },
      IsViewingAlteredForm = true,
      IsViewingNativeSex = {
        products = {
          wow_classic_beta = true,
          wow_classic_ptr = true,
        },
      },
      IsViewingVisibleSex = {
        products = {
          wow_classic_beta = true,
          wow_classic_ptr = true,
        },
      },
      MarkCustomizationChoiceAsSeen = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      MarkCustomizationOptionAsSeen = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      PreviewCustomizationChoice = true,
      RandomizeCustomizationChoices = true,
      ResetCameraRotation = true,
      ResetCustomizationChoices = true,
      RotateCamera = true,
      SaveSeenChoices = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetCameraDistanceOffset = true,
      SetCameraZoomLevel = true,
      SetCustomizationChoice = true,
      SetModelDressState = true,
      SetSelectedSex = true,
      SetViewingAlteredForm = true,
      SetViewingChrModel = {
        products = {
          wow_beta = true,
        },
      },
      SetViewingShapeshiftForm = true,
      ZoomCamera = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wow_classic_beta = true,
      wow_classic_ptr = true,
      wowt = true,
    },
  },
  C_BattleNet = {
    methods = {
      GetAccountInfoByGUID = true,
      GetAccountInfoByID = true,
      GetFriendAccountInfo = true,
      GetFriendGameAccountInfo = true,
      GetFriendNumGameAccounts = true,
      GetGameAccountInfoByGUID = true,
      GetGameAccountInfoByID = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_BehavioralMessaging = {
    methods = {
      SendNotificationReceipt = true,
    },
  },
  C_BlackMarket = {
    methods = {
      Close = true,
      GetHotItem = true,
      GetItemInfoByID = true,
      GetItemInfoByIndex = true,
      GetNumItems = true,
      IsViewOnly = true,
      ItemPlaceBid = true,
      RequestItems = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_CVar = {
    methods = {
      GetCVar = true,
      GetCVarBitfield = true,
      GetCVarBool = true,
      GetCVarDefault = true,
      RegisterCVar = true,
      ResetTestCVars = true,
      SetCVar = true,
      SetCVarBitfield = true,
    },
  },
  C_Calendar = {
    methods = {
      AddEvent = true,
      AreNamesReady = true,
      CanAddEvent = true,
      CanSendInvite = true,
      CloseEvent = true,
      ContextMenuEventCanComplain = true,
      ContextMenuEventCanEdit = true,
      ContextMenuEventCanRemove = true,
      ContextMenuEventClipboard = true,
      ContextMenuEventComplain = {
        products = {
          wow_classic = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
        },
      },
      ContextMenuEventCopy = true,
      ContextMenuEventGetCalendarType = true,
      ContextMenuEventPaste = true,
      ContextMenuEventRemove = true,
      ContextMenuEventSignUp = true,
      ContextMenuGetEventIndex = true,
      ContextMenuInviteAvailable = true,
      ContextMenuInviteDecline = true,
      ContextMenuInviteRemove = true,
      ContextMenuInviteTentative = true,
      ContextMenuSelectEvent = true,
      CreateCommunitySignUpEvent = true,
      CreateGuildAnnouncementEvent = true,
      CreateGuildSignUpEvent = true,
      CreatePlayerEvent = true,
      EventAvailable = true,
      EventCanEdit = true,
      EventClearAutoApprove = true,
      EventClearLocked = true,
      EventClearModerator = true,
      EventDecline = true,
      EventGetCalendarType = true,
      EventGetClubId = true,
      EventGetInvite = true,
      EventGetInviteResponseTime = true,
      EventGetInviteSortCriterion = true,
      EventGetSelectedInvite = true,
      EventGetStatusOptions = true,
      EventGetTextures = true,
      EventGetTypes = true,
      EventGetTypesDisplayOrdered = true,
      EventHasPendingInvite = true,
      EventHaveSettingsChanged = true,
      EventInvite = true,
      EventRemoveInvite = true,
      EventRemoveInviteByGuid = true,
      EventSelectInvite = true,
      EventSetAutoApprove = true,
      EventSetClubId = true,
      EventSetDate = true,
      EventSetDescription = true,
      EventSetInviteStatus = true,
      EventSetLocked = true,
      EventSetModerator = true,
      EventSetTextureID = true,
      EventSetTime = true,
      EventSetTitle = true,
      EventSetType = true,
      EventSignUp = true,
      EventSortInvites = true,
      EventTentative = true,
      GetClubCalendarEvents = true,
      GetDayEvent = true,
      GetDefaultGuildFilter = true,
      GetEventIndex = true,
      GetEventIndexInfo = true,
      GetEventInfo = true,
      GetFirstPendingInvite = true,
      GetGuildEventInfo = true,
      GetGuildEventSelectionInfo = true,
      GetHolidayInfo = true,
      GetMaxCreateDate = true,
      GetMinDate = true,
      GetMonthInfo = true,
      GetNextClubId = true,
      GetNumDayEvents = true,
      GetNumGuildEvents = true,
      GetNumInvites = true,
      GetNumPendingInvites = true,
      GetRaidInfo = true,
      IsActionPending = true,
      IsEventOpen = true,
      MassInviteCommunity = true,
      MassInviteGuild = true,
      OpenCalendar = true,
      OpenEvent = true,
      RemoveEvent = true,
      SetAbsMonth = true,
      SetMonth = true,
      SetNextClubId = true,
      UpdateEvent = true,
    },
  },
  C_CameraDefaults = {
    methods = {
      GetCameraFOVDefaults = true,
    },
    products = {
      wow_beta = true,
    },
  },
  C_CampaignInfo = {
    methods = {
      GetAvailableCampaigns = true,
      GetCampaignChapterInfo = true,
      GetCampaignID = true,
      GetCampaignInfo = true,
      GetChapterIDs = true,
      GetCurrentChapterID = true,
      GetFailureReason = true,
      GetState = true,
      IsCampaignQuest = true,
      UsesNormalQuestIcons = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_ChallengeMode = {
    methods = {
      CanUseKeystoneInCurrentMap = true,
      ClearKeystone = true,
      CloseKeystoneFrame = true,
      GetActiveChallengeMapID = true,
      GetActiveKeystoneInfo = true,
      GetAffixInfo = true,
      GetCompletionInfo = true,
      GetDeathCount = true,
      GetDungeonScoreRarityColor = true,
      GetGuildLeaders = true,
      GetKeystoneLevelRarityColor = true,
      GetMapScoreInfo = true,
      GetMapTable = true,
      GetMapUIInfo = true,
      GetOverallDungeonScore = true,
      GetPowerLevelDamageHealthMod = true,
      GetSlottedKeystoneInfo = true,
      GetSpecificDungeonOverallScoreRarityColor = true,
      GetSpecificDungeonScoreRarityColor = true,
      HasSlottedKeystone = true,
      IsChallengeModeActive = true,
      RemoveKeystone = true,
      RequestLeaders = true,
      Reset = true,
      SetKeystoneTooltip = true,
      SlotKeystone = true,
      StartChallengeMode = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_CharacterServices = {
    methods = {
      AssignPCTDistribution = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      AssignPFCDistribution = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      AssignUpgradeDistribution = true,
      GetActiveCharacterUpgradeBoostType = true,
      GetActiveClassTrialBoostType = true,
      GetAutomaticBoost = true,
      GetAutomaticBoostCharacter = true,
      GetCharacterServiceDisplayData = true,
      GetCharacterServiceDisplayDataByVASType = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCharacterServiceDisplayInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCharacterServiceDisplayOrder = {
        products = {
          wow_classic = true,
          wow_classic_beta = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
          wow_classic_ptr = true,
        },
      },
      GetVASDistributions = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      HasRequiredBoostForClassTrial = true,
      HasRequiredBoostForUnrevoke = true,
      SetAutomaticBoost = true,
      SetAutomaticBoostCharacter = true,
    },
  },
  C_CharacterServicesPublic = {
    methods = {
      ShouldSeeControlPopup = true,
    },
  },
  C_ChatBubbles = {
    methods = {
      GetAllChatBubbles = true,
    },
  },
  C_ChatInfo = {
    methods = {
      CanReportPlayer = {
        products = {
          wow_classic = true,
          wow_classic_beta = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
          wow_classic_ptr = true,
        },
      },
      GetChannelInfoFromIdentifier = true,
      GetChannelRosterInfo = true,
      GetChannelRuleset = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetChannelRulesetForChannelID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetChannelShortcut = true,
      GetChannelShortcutForChannelID = true,
      GetChatTypeName = true,
      GetClubStreamIDs = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetGeneralChannelID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetGeneralChannelLocalID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMentorChannelID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumActiveChannels = true,
      GetNumReservedChatWindows = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRegisteredAddonMessagePrefixes = true,
      IsAddonMessagePrefixRegistered = true,
      IsChannelRegional = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsChannelRegionalForChannelID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsPartyChannelType = true,
      IsRegionalServiceAvailable = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsValidChatLine = true,
      RegisterAddonMessagePrefix = true,
      ReplaceIconAndGroupExpressions = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ReportPlayer = {
        products = {
          wow_classic = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
        },
      },
      ReportServerLag = {
        products = {
          wow_classic = true,
          wow_classic_beta = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
          wow_classic_ptr = true,
        },
      },
      ResetDefaultZoneChannels = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SendAddonMessage = true,
      SendAddonMessageLogged = true,
      SwapChatChannelsByChannelIndex = true,
    },
  },
  C_ChromieTime = {
    methods = {
      CloseUI = true,
      GetChromieTimeExpansionOption = true,
      GetChromieTimeExpansionOptions = true,
      SelectChromieTimeOption = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_ClassColor = {
    methods = {
      GetClassColor = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_ClassTalents = {
    methods = {
      CanChangeTalents = true,
      CommitConfig = true,
      GetActiveConfigID = true,
      GetConfigIDsBySpecID = true,
      LoadConfig = true,
      RequestNewConfig = true,
      SaveConfig = true,
    },
    products = {
      wow_beta = true,
    },
  },
  C_ClassTrial = {
    methods = {
      GetClassTrialLogoutTimeSeconds = true,
      IsClassTrialCharacter = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_ClickBindings = {
    methods = {
      CanSpellBeClickBound = true,
      ExecuteBinding = true,
      GetBindingType = true,
      GetEffectiveInteractionButton = true,
      GetProfileInfo = true,
      GetStringFromModifiers = true,
      GetTutorialShown = true,
      MakeModifiers = true,
      ResetCurrentProfile = true,
      SetProfileByInfo = true,
      SetTutorialShown = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_Club = {
    methods = {
      AcceptInvitation = true,
      AddClubStreamChatChannel = true,
      AdvanceStreamViewMarker = true,
      AssignMemberRole = true,
      CanResolvePlayerLocationFromClubMessageData = true,
      ClearAutoAdvanceStreamViewMarker = true,
      ClearClubPresenceSubscription = true,
      CompareBattleNetDisplayName = true,
      CreateClub = true,
      CreateStream = true,
      CreateTicket = true,
      DeclineInvitation = true,
      DestroyClub = true,
      DestroyMessage = true,
      DestroyStream = true,
      DestroyTicket = true,
      DoesCommunityHaveMembersOfTheOppositeFaction = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      EditClub = true,
      EditMessage = true,
      EditStream = true,
      Flush = true,
      FocusCommunityStreams = true,
      FocusStream = true,
      GetAssignableRoles = true,
      GetAvatarIdList = true,
      GetClubCapacity = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetClubInfo = true,
      GetClubLimits = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetClubMembers = true,
      GetClubPrivileges = true,
      GetClubStreamNotificationSettings = true,
      GetCommunityNameResultText = true,
      GetGuildClubId = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetInfoFromLastCommunityChatLine = true,
      GetInvitationCandidates = true,
      GetInvitationInfo = true,
      GetInvitationsForClub = true,
      GetInvitationsForSelf = true,
      GetLastTicketResponse = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMemberInfo = true,
      GetMemberInfoForSelf = true,
      GetMessageInfo = true,
      GetMessageRanges = true,
      GetMessagesBefore = true,
      GetMessagesInRange = true,
      GetStreamInfo = true,
      GetStreamViewMarker = true,
      GetStreams = true,
      GetSubscribedClubs = true,
      GetTickets = true,
      IsAccountMuted = true,
      IsBeginningOfStream = true,
      IsEnabled = true,
      IsRestricted = true,
      IsSubscribedToStream = true,
      KickMember = true,
      LeaveClub = true,
      RedeemTicket = true,
      RequestInvitationsForClub = true,
      RequestMoreMessagesBefore = true,
      RequestTicket = true,
      RequestTickets = true,
      RevokeInvitation = true,
      SendBattleTagFriendRequest = true,
      SendCharacterInvitation = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SendInvitation = true,
      SendMessage = true,
      SetAutoAdvanceStreamViewMarker = true,
      SetAvatarTexture = true,
      SetClubMemberNote = true,
      SetClubPresenceSubscription = true,
      SetClubStreamNotificationSettings = true,
      SetCommunityID = {
        products = {
          wow_classic = true,
          wow_classic_beta = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
          wow_classic_ptr = true,
        },
      },
      SetFavorite = true,
      SetSocialQueueingEnabled = true,
      ShouldAllowClubType = true,
      UnfocusAllStreams = true,
      UnfocusStream = true,
      ValidateText = true,
    },
  },
  C_ClubFinder = {
    methods = {
      ApplicantAcceptClubInvite = true,
      ApplicantDeclineClubInvite = true,
      CancelMembershipRequest = true,
      CheckAllPlayerApplicantSettings = true,
      ClearAllFinderCache = true,
      ClearClubApplicantsCache = true,
      ClearClubFinderPostingsCache = true,
      DoesPlayerBelongToClubFromClubGUID = true,
      GetClubFinderDisableReason = true,
      GetClubRecruitmentSettings = true,
      GetClubTypeFromFinderGUID = true,
      GetFocusIndexFromFlag = true,
      GetPlayerApplicantLocaleFlags = true,
      GetPlayerApplicantSettings = true,
      GetPlayerClubApplicationStatus = true,
      GetPlayerSettingsFocusFlagsSelectedCount = true,
      GetPostingIDFromClubFinderGUID = true,
      GetRecruitingClubInfoFromClubID = true,
      GetRecruitingClubInfoFromFinderGUID = true,
      GetStatusOfPostingFromClubId = true,
      GetTotalMatchingCommunityListSize = true,
      GetTotalMatchingGuildListSize = true,
      HasAlreadyAppliedToLinkedPosting = true,
      HasPostingBeenDelisted = true,
      IsEnabled = true,
      IsListingEnabledFromFlags = true,
      IsPostingBanned = true,
      LookupClubPostingFromClubFinderGUID = true,
      PlayerGetClubInvitationList = true,
      PlayerRequestPendingClubsList = true,
      PlayerReturnPendingCommunitiesList = true,
      PlayerReturnPendingGuildsList = true,
      PostClub = true,
      RequestApplicantList = true,
      RequestClubsList = true,
      RequestMembershipToClub = true,
      RequestNextCommunityPage = true,
      RequestNextGuildPage = true,
      RequestPostingInformationFromClubId = true,
      RequestSubscribedClubPostingIDs = true,
      ResetClubPostingMapCache = true,
      RespondToApplicant = true,
      ReturnClubApplicantList = true,
      ReturnMatchingCommunityList = true,
      ReturnMatchingGuildList = true,
      ReturnPendingClubApplicantList = true,
      SendChatWhisper = true,
      SetAllRecruitmentSettings = true,
      SetPlayerApplicantLocaleFlags = true,
      SetPlayerApplicantSettings = true,
      SetRecruitmentLocale = true,
      SetRecruitmentSettings = true,
      ShouldShowClubFinder = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_Commentator = {
    methods = {
      AddPlayerOverrideName = true,
      AddTrackedDefensiveAuras = true,
      AddTrackedOffensiveAuras = true,
      AreTeamsSwapped = true,
      AssignPlayerToTeam = true,
      AssignPlayersToTeam = true,
      AssignPlayersToTeamInCurrentInstance = true,
      CanUseCommentatorCheats = true,
      ClearCameraTarget = true,
      ClearFollowTarget = true,
      ClearLookAtTarget = true,
      EnterInstance = true,
      ExitInstance = true,
      FindSpectatedUnit = true,
      FindTeamNameInCurrentInstance = true,
      FindTeamNameInDirectory = true,
      FlushCommentatorHistory = true,
      FollowPlayer = true,
      FollowUnit = true,
      ForceFollowTransition = true,
      GetAdditionalCameraWeight = true,
      GetAdditionalCameraWeightByToken = true,
      GetAllPlayerOverrideNames = true,
      GetCamera = true,
      GetCameraCollision = true,
      GetCameraPosition = true,
      GetCommentatorHistory = true,
      GetCurrentMapID = true,
      GetDampeningPercent = true,
      GetDistanceBeforeForcedHorizontalConvergence = true,
      GetDurationToForceHorizontalConvergence = true,
      GetExcludeDistance = true,
      GetHardlockWeight = true,
      GetHorizontalAngleThresholdToSmooth = true,
      GetIndirectSpellID = true,
      GetInstanceInfo = true,
      GetLookAtLerpAmount = true,
      GetMapInfo = true,
      GetMatchDuration = true,
      GetMaxNumPlayersPerTeam = true,
      GetMaxNumTeams = true,
      GetMode = true,
      GetMsToHoldForHorizontalMovement = true,
      GetMsToHoldForVerticalMovement = true,
      GetMsToSmoothHorizontalChange = true,
      GetMsToSmoothVerticalChange = true,
      GetNumMaps = true,
      GetNumPlayers = true,
      GetOrCreateSeries = true,
      GetPlayerAuraInfo = true,
      GetPlayerAuraInfoByUnit = true,
      GetPlayerCooldownInfo = true,
      GetPlayerCooldownInfoByUnit = true,
      GetPlayerCrowdControlInfo = true,
      GetPlayerCrowdControlInfoByUnit = true,
      GetPlayerData = true,
      GetPlayerFlagInfo = true,
      GetPlayerFlagInfoByUnit = true,
      GetPlayerOverrideName = true,
      GetPlayerSpellCharges = true,
      GetPlayerSpellChargesByUnit = true,
      GetPositionLerpAmount = true,
      GetSmoothFollowTransitioning = true,
      GetSoftlockWeight = true,
      GetSpeedFactor = true,
      GetStartLocation = true,
      GetTeamColor = true,
      GetTeamColorByUnit = true,
      GetTimeLeftInMatch = true,
      GetTrackedSpellID = true,
      GetTrackedSpells = true,
      GetTrackedSpellsByUnit = true,
      GetUnitData = true,
      GetWargameInfo = true,
      HasTrackedAuras = true,
      IsSmartCameraLocked = true,
      IsSpectating = true,
      IsTrackedDefensiveAura = true,
      IsTrackedOffensiveAura = true,
      IsTrackedSpell = true,
      IsTrackedSpellByUnit = true,
      IsUsingSmartCamera = true,
      LookAtPlayer = true,
      RemoveAllOverrideNames = true,
      RemovePlayerOverrideName = true,
      RequestPlayerCooldownInfo = true,
      ResetFoVTarget = true,
      ResetSeriesScores = true,
      ResetSettings = true,
      ResetTrackedAuras = true,
      SetAdditionalCameraWeight = true,
      SetAdditionalCameraWeightByToken = true,
      SetBlocklistedAuras = true,
      SetBlocklistedCooldowns = true,
      SetCamera = true,
      SetCameraCollision = true,
      SetCameraPosition = true,
      SetCheatsEnabled = true,
      SetCommentatorHistory = true,
      SetDistanceBeforeForcedHorizontalConvergence = true,
      SetDurationToForceHorizontalConvergence = true,
      SetExcludeDistance = true,
      SetFollowCameraSpeeds = true,
      SetHardlockWeight = true,
      SetHorizontalAngleThresholdToSmooth = true,
      SetLookAtLerpAmount = true,
      SetMapAndInstanceIndex = true,
      SetMouseDisabled = true,
      SetMoveSpeed = true,
      SetMsToHoldForHorizontalMovement = true,
      SetMsToHoldForVerticalMovement = true,
      SetMsToSmoothHorizontalChange = true,
      SetMsToSmoothVerticalChange = true,
      SetPositionLerpAmount = true,
      SetRequestedDebuffCooldowns = true,
      SetRequestedDefensiveCooldowns = true,
      SetRequestedOffensiveCooldowns = true,
      SetSeriesScore = true,
      SetSeriesScores = true,
      SetSmartCameraLocked = true,
      SetSmoothFollowTransitioning = true,
      SetSoftlockWeight = true,
      SetSpeedFactor = true,
      SetTargetHeightOffset = true,
      SetUseSmartCamera = true,
      SnapCameraLookAtPoint = true,
      StartWargame = true,
      SwapTeamSides = true,
      ToggleCheats = true,
      UpdateMapInfo = true,
      UpdatePlayerInfo = true,
      ZoomIn = true,
      ZoomOut = true,
    },
  },
  C_Console = {
    methods = {
      GetAllCommands = true,
      GetColorFromType = true,
      GetFontHeight = true,
      PrintAllMatchingCommands = true,
      SetFontHeight = true,
    },
  },
  C_Container = {
    methods = {
      GetBagSlotFlag = true,
      SetBagSlotFlag = true,
    },
    products = {
      wow_beta = true,
    },
  },
  C_ContributionCollector = {
    methods = {
      Close = true,
      Contribute = true,
      GetActive = true,
      GetAtlases = true,
      GetBuffs = true,
      GetContributionAppearance = true,
      GetContributionCollectorsForMap = true,
      GetContributionResult = true,
      GetDescription = true,
      GetManagedContributionsForCreatureID = true,
      GetName = true,
      GetOrderIndex = true,
      GetRequiredContributionCurrency = true,
      GetRequiredContributionItem = true,
      GetRewardQuestID = true,
      GetState = true,
      HasPendingContribution = true,
      IsAwaitingRewardQuestData = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_CovenantCallings = {
    methods = {
      AreCallingsUnlocked = true,
      RequestCallings = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_CovenantPreview = {
    methods = {
      CloseFromUI = true,
      GetCovenantInfoForPlayerChoiceResponseID = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_CovenantSanctumUI = {
    methods = {
      CanAccessReservoir = true,
      CanDepositAnima = true,
      DepositAnima = true,
      EndInteraction = true,
      GetAnimaInfo = true,
      GetCurrentTalentTreeID = true,
      GetFeatures = true,
      GetRenownLevel = true,
      GetRenownLevels = true,
      GetRenownRewardsForLevel = true,
      GetSanctumType = true,
      GetSoulCurrencies = true,
      HasMaximumRenown = true,
      IsPlayerInRenownCatchUpMode = true,
      IsWeeklyRenownCapped = true,
      RequestCatchUpState = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_Covenants = {
    methods = {
      GetActiveCovenantID = true,
      GetCovenantData = true,
      GetCovenantIDs = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_CraftingOrders = {
    methods = {
      CloseCustomerCraftingOrders = true,
      GetCustomerCategories = true,
      GetCustomerOptions = true,
      ParseCustomerOptions = true,
      TEST_SignalHideCrafter = true,
      TEST_SignalHideCustomer = true,
      TEST_SignalShowCrafter = true,
      TEST_SignalShowCustomer = true,
    },
    products = {
      wow_beta = true,
    },
  },
  C_CreatureInfo = {
    methods = {
      GetClassInfo = true,
      GetFactionInfo = true,
      GetRaceInfo = true,
    },
  },
  C_CurrencyInfo = {
    methods = {
      DoesWarModeBonusApply = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ExpandCurrencyList = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAzeriteCurrencyID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBackpackCurrencyInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBasicCurrencyInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wow_classic_beta = true,
          wow_classic_ptr = true,
          wowt = true,
        },
      },
      GetCurrencyContainerInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wow_classic_beta = true,
          wow_classic_ptr = true,
          wowt = true,
        },
      },
      GetCurrencyIDFromLink = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCurrencyInfo = true,
      GetCurrencyInfoFromLink = true,
      GetCurrencyLink = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCurrencyListInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCurrencyListLink = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCurrencyListSize = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFactionGrantedByCurrency = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetWarResourcesCurrencyID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsCurrencyContainer = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      PickupCurrency = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetCurrencyBackpack = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetCurrencyUnused = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
  },
  C_Cursor = {
    methods = {
      DropCursorCommunitiesStream = {
        products = {
          wow_classic = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
        },
      },
      GetCursorCommunitiesStream = {
        products = {
          wow_classic = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
        },
      },
      GetCursorItem = true,
      SetCursorCommunitiesStream = {
        products = {
          wow_classic = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
        },
      },
    },
  },
  C_DateAndTime = {
    methods = {
      AdjustTimeByDays = true,
      AdjustTimeByMinutes = true,
      CompareCalendarTime = true,
      GetCalendarTimeFromEpoch = true,
      GetCurrentCalendarTime = true,
      GetSecondsUntilDailyReset = true,
      GetSecondsUntilWeeklyReset = true,
      GetServerTimeLocal = true,
    },
  },
  C_DeathInfo = {
    methods = {
      GetCorpseMapPosition = true,
      GetDeathReleasePosition = true,
      GetGraveyardsForMap = true,
      GetSelfResurrectOptions = true,
      UseSelfResurrectOption = true,
    },
  },
  C_EditMode = {
    methods = {
      ConvertLayoutInfoToHyperlink = true,
      ConvertLayoutInfoToString = true,
      ConvertStringToLayoutInfo = true,
      GetAccountSettings = true,
      GetEditModeInfo = true,
      GetLayouts = true,
      OnLayoutAdded = true,
      OnLayoutDeleted = true,
      SaveEditModeInfo = true,
      SaveLayouts = true,
      SetAccountSetting = true,
      SetActiveLayout = true,
    },
    products = {
      wow_beta = true,
    },
  },
  C_EncounterJournal = {
    methods = {
      GetDungeonEntrancesForMap = true,
      GetEncountersOnMap = true,
      GetLootInfo = true,
      GetLootInfoByIndex = true,
      GetSectionIconFlags = true,
      GetSectionInfo = true,
      GetSlotFilter = true,
      InstanceHasLoot = true,
      IsEncounterComplete = true,
      ResetSlotFilter = true,
      SetPreviewMythicPlusLevel = true,
      SetPreviewPvpTier = true,
      SetSlotFilter = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_EquipmentSet = {
    methods = {
      AssignSpecToEquipmentSet = true,
      CanUseEquipmentSets = true,
      ClearIgnoredSlotsForSave = true,
      CreateEquipmentSet = true,
      DeleteEquipmentSet = true,
      EquipmentSetContainsLockedItems = true,
      GetEquipmentSetAssignedSpec = true,
      GetEquipmentSetForSpec = true,
      GetEquipmentSetID = true,
      GetEquipmentSetIDs = true,
      GetEquipmentSetInfo = true,
      GetIgnoredSlots = true,
      GetItemIDs = true,
      GetItemLocations = true,
      GetNumEquipmentSets = true,
      IgnoreSlotForSave = true,
      IsSlotIgnoredForSave = true,
      ModifyEquipmentSet = true,
      PickupEquipmentSet = true,
      SaveEquipmentSet = true,
      UnassignEquipmentSetSpec = true,
      UnignoreSlotForSave = true,
      UseEquipmentSet = true,
    },
  },
  C_EventToastManager = {
    methods = {
      GetLevelUpDisplayToastsFromLevel = true,
      GetNextToastToDisplay = true,
      RemoveCurrentToast = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_EventUtils = {
    methods = {
      IsEventValid = true,
      NotifySettingsLoaded = true,
    },
    products = {
      wow_beta = true,
    },
  },
  C_FogOfWar = {
    methods = {
      GetFogOfWarForMap = true,
      GetFogOfWarInfo = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_FrameManager = {
    methods = {
      GetFrameVisibilityState = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_FriendList = {
    methods = {
      AddFriend = true,
      AddIgnore = true,
      AddOrDelIgnore = true,
      AddOrRemoveFriend = true,
      DelIgnore = true,
      DelIgnoreByIndex = true,
      GetFriendInfo = true,
      GetFriendInfoByIndex = true,
      GetIgnoreName = true,
      GetNumFriends = true,
      GetNumIgnores = true,
      GetNumOnlineFriends = true,
      GetNumWhoResults = true,
      GetSelectedFriend = true,
      GetSelectedIgnore = true,
      GetWhoInfo = true,
      IsFriend = true,
      IsIgnored = true,
      IsIgnoredByGuid = true,
      IsOnIgnoredList = {
        products = {
          wow = true,
          wow_beta = true,
          wow_classic_beta = true,
          wow_classic_ptr = true,
          wowt = true,
        },
      },
      RemoveFriend = true,
      RemoveFriendByIndex = true,
      SendWho = true,
      SetFriendNotes = true,
      SetFriendNotesByIndex = true,
      SetSelectedFriend = true,
      SetSelectedIgnore = true,
      SetWhoToUi = true,
      ShowFriends = true,
      SortWho = true,
    },
  },
  C_GamePad = {
    methods = {
      AddSDLMapping = true,
      ApplyConfigs = true,
      AxisIndexToConfigName = true,
      ButtonBindingToIndex = true,
      ButtonIndexToBinding = true,
      ButtonIndexToConfigName = true,
      ClearLedColor = true,
      DeleteConfig = true,
      GetActiveDeviceID = true,
      GetAllConfigIDs = true,
      GetAllDeviceIDs = true,
      GetCombinedDeviceID = true,
      GetConfig = true,
      GetDeviceMappedState = true,
      GetDeviceRawState = true,
      GetLedColor = true,
      GetPowerLevel = {
        products = {
          wow = true,
          wow_beta = true,
          wow_classic_beta = true,
          wow_classic_ptr = true,
          wowt = true,
        },
      },
      IsEnabled = true,
      SetConfig = true,
      SetLedColor = true,
      SetVibration = true,
      StickIndexToConfigName = true,
      StopVibration = true,
    },
  },
  C_Garrison = {
    methods = {
      AddFollowerToMission = true,
      AllowMissionStartAboveSoftCap = true,
      AreMissionFollowerRequirementsMet = true,
      AssignFollowerToBuilding = true,
      CanGenerateRecruits = true,
      CanOpenMissionChest = true,
      CanSetRecruitmentPreference = true,
      CanSpellTargetFollowerIDWithAddAbility = true,
      CanUpgradeGarrison = true,
      CancelConstruction = true,
      CastItemSpellOnFollowerAbility = true,
      CastSpellOnFollower = true,
      CastSpellOnFollowerAbility = true,
      CastSpellOnMission = true,
      ClearCompleteTalent = true,
      CloseArchitect = true,
      CloseGarrisonTradeskillNPC = true,
      CloseMissionNPC = true,
      CloseRecruitmentNPC = true,
      CloseTalentNPC = true,
      CloseTradeskillCrafter = true,
      GenerateRecruits = true,
      GetAllBonusAbilityEffects = true,
      GetAllEncounterThreats = true,
      GetAutoCombatDamageClassValues = true,
      GetAutoMissionBoardState = true,
      GetAutoMissionEnvironmentEffect = true,
      GetAutoMissionTargetingInfo = true,
      GetAutoMissionTargetingInfoForSpell = true,
      GetAutoTroops = true,
      GetAvailableMissions = true,
      GetAvailableRecruits = true,
      GetBasicMissionInfo = true,
      GetBuffedFollowersForMission = true,
      GetBuildingInfo = true,
      GetBuildingLockInfo = true,
      GetBuildingSizes = true,
      GetBuildingSpecInfo = true,
      GetBuildingTimeRemaining = true,
      GetBuildingTooltip = true,
      GetBuildingUpgradeInfo = true,
      GetBuildings = true,
      GetBuildingsForPlot = true,
      GetBuildingsForSize = true,
      GetClassSpecCategoryInfo = true,
      GetCombatAllyMission = true,
      GetCombatLogSpellInfo = true,
      GetCompleteMissions = true,
      GetCompleteTalent = true,
      GetCurrencyTypes = true,
      GetCurrentCypherEquipmentLevel = true,
      GetCurrentGarrTalentTreeFriendshipFactionID = true,
      GetCurrentGarrTalentTreeID = true,
      GetCyphersToNextEquipmentLevel = true,
      GetFollowerAbilities = true,
      GetFollowerAbilityAtIndex = true,
      GetFollowerAbilityAtIndexByID = true,
      GetFollowerAbilityCounterMechanicInfo = true,
      GetFollowerAbilityCountersForMechanicTypes = true,
      GetFollowerAbilityDescription = true,
      GetFollowerAbilityIcon = true,
      GetFollowerAbilityInfo = true,
      GetFollowerAbilityIsTrait = true,
      GetFollowerAbilityLink = true,
      GetFollowerAbilityName = true,
      GetFollowerActivationCost = true,
      GetFollowerAutoCombatSpells = true,
      GetFollowerAutoCombatStats = true,
      GetFollowerBiasForMission = true,
      GetFollowerClassSpec = true,
      GetFollowerClassSpecAtlas = true,
      GetFollowerClassSpecByID = true,
      GetFollowerClassSpecName = true,
      GetFollowerDisplayID = true,
      GetFollowerInfo = true,
      GetFollowerInfoForBuilding = true,
      GetFollowerIsTroop = true,
      GetFollowerItemLevelAverage = true,
      GetFollowerItems = true,
      GetFollowerLevel = true,
      GetFollowerLevelXP = true,
      GetFollowerLink = true,
      GetFollowerLinkByID = true,
      GetFollowerMissionCompleteInfo = true,
      GetFollowerMissionTimeLeft = true,
      GetFollowerMissionTimeLeftSeconds = true,
      GetFollowerModelItems = true,
      GetFollowerName = true,
      GetFollowerNameByID = true,
      GetFollowerPortraitIconID = true,
      GetFollowerPortraitIconIDByID = true,
      GetFollowerQuality = true,
      GetFollowerQualityTable = true,
      GetFollowerRecentlyGainedAbilityIDs = true,
      GetFollowerRecentlyGainedTraitIDs = true,
      GetFollowerShipments = true,
      GetFollowerSoftCap = true,
      GetFollowerSourceTextByID = true,
      GetFollowerSpecializationAtIndex = true,
      GetFollowerStatus = true,
      GetFollowerTraitAtIndex = true,
      GetFollowerTraitAtIndexByID = true,
      GetFollowerTypeByID = true,
      GetFollowerTypeByMissionID = true,
      GetFollowerUnderBiasReason = true,
      GetFollowerXP = true,
      GetFollowerXPTable = true,
      GetFollowerZoneSupportAbilities = true,
      GetFollowers = true,
      GetFollowersSpellsForMission = true,
      GetFollowersTraitsForMission = true,
      GetGarrisonInfo = true,
      GetGarrisonPlotsInstancesForMap = true,
      GetGarrisonTalentTreeCurrencyTypes = true,
      GetGarrisonTalentTreeType = true,
      GetGarrisonUpgradeCost = true,
      GetInProgressMissions = true,
      GetLandingPageGarrisonType = true,
      GetLandingPageItems = true,
      GetLandingPageShipmentCount = true,
      GetLandingPageShipmentInfo = true,
      GetLandingPageShipmentInfoByContainerID = true,
      GetLooseShipments = true,
      GetMaxCypherEquipmentLevel = true,
      GetMissionBonusAbilityEffects = true,
      GetMissionCompleteEncounters = true,
      GetMissionCost = true,
      GetMissionDeploymentInfo = true,
      GetMissionDisplayIDs = true,
      GetMissionEncounterIconInfo = true,
      GetMissionLink = true,
      GetMissionMaxFollowers = true,
      GetMissionName = true,
      GetMissionRewardInfo = true,
      GetMissionSuccessChance = true,
      GetMissionTexture = true,
      GetMissionTimes = true,
      GetMissionUncounteredMechanics = true,
      GetNumActiveFollowers = true,
      GetNumFollowerActivationsRemaining = true,
      GetNumFollowerDailyActivations = true,
      GetNumFollowers = true,
      GetNumFollowersForMechanic = true,
      GetNumFollowersOnMission = true,
      GetNumPendingShipments = true,
      GetNumShipmentCurrencies = true,
      GetNumShipmentReagents = true,
      GetOwnedBuildingInfo = true,
      GetOwnedBuildingInfoAbbrev = true,
      GetPartyBuffs = true,
      GetPartyMentorLevels = true,
      GetPartyMissionInfo = true,
      GetPendingShipmentInfo = true,
      GetPlots = true,
      GetPlotsForBuilding = true,
      GetPossibleFollowersForBuilding = true,
      GetRecruitAbilities = true,
      GetRecruiterAbilityCategories = true,
      GetRecruiterAbilityList = true,
      GetRecruitmentPreferences = true,
      GetShipDeathAnimInfo = true,
      GetShipmentContainerInfo = true,
      GetShipmentItemInfo = true,
      GetShipmentReagentCurrencyInfo = true,
      GetShipmentReagentInfo = true,
      GetShipmentReagentItemLink = true,
      GetSpecChangeCost = true,
      GetTabForPlot = true,
      GetTalentInfo = true,
      GetTalentPointsSpentInTalentTree = true,
      GetTalentTreeIDsByClassID = true,
      GetTalentTreeInfo = true,
      GetTalentTreeResetInfo = true,
      GetTalentTreeTalentPointResearchInfo = true,
      GetTalentUnlockWorldQuest = true,
      HasAdventures = true,
      HasGarrison = true,
      HasShipyard = true,
      IsAboveFollowerSoftCap = true,
      IsAtGarrisonMissionNPC = true,
      IsEnvironmentCountered = true,
      IsFollowerCollected = true,
      IsFollowerOnCompletedMission = true,
      IsInvasionAvailable = true,
      IsMechanicFullyCountered = true,
      IsOnGarrisonMap = true,
      IsOnShipmentQuestForNPC = true,
      IsOnShipyardMap = true,
      IsPlayerInGarrison = true,
      IsTalentConditionMet = true,
      IsUsingPartyGarrison = true,
      IsVisitGarrisonAvailable = true,
      MarkMissionComplete = true,
      MissionBonusRoll = true,
      PlaceBuilding = true,
      RecruitFollower = true,
      RegenerateCombatLog = true,
      RemoveFollower = true,
      RemoveFollowerFromBuilding = true,
      RemoveFollowerFromMission = true,
      RenameFollower = true,
      RequestClassSpecCategoryInfo = true,
      RequestGarrisonUpgradeable = true,
      RequestLandingPageShipmentInfo = true,
      RequestShipmentCreation = true,
      RequestShipmentInfo = true,
      ResearchTalent = true,
      RushHealAllFollowers = true,
      RushHealFollower = true,
      SearchForFollower = true,
      SetAutoCombatSpellFastForward = true,
      SetBuildingActive = true,
      SetBuildingSpecialization = true,
      SetFollowerFavorite = true,
      SetFollowerInactive = true,
      SetRecruitmentPreferences = true,
      SetUsingPartyGarrison = true,
      ShouldShowMapTab = true,
      ShowFollowerNameInErrorMessage = true,
      StartMission = true,
      SwapBuildings = true,
      TargetSpellHasFollowerItemLevelUpgrade = true,
      TargetSpellHasFollowerReroll = true,
      TargetSpellHasFollowerTemporaryAbility = true,
      UpgradeBuilding = true,
      UpgradeGarrison = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_GossipInfo = {
    methods = {
      CloseGossip = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ForceGossip = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetActiveQuests = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAvailableQuests = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCompletedOptionDescriptionString = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCustomGossipDescriptionString = true,
      GetNumActiveQuests = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumAvailableQuests = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumOptions = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetOptions = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPoiForUiMapID = true,
      GetPoiInfo = true,
      GetText = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RefreshOptions = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SelectActiveQuest = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SelectAvailableQuest = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SelectOption = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
  },
  C_GuildInfo = {
    methods = {
      CanEditOfficerNote = true,
      CanSpeakInGuildChat = true,
      CanViewOfficerNote = true,
      GetGuildNewsInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetGuildRankOrder = true,
      GetGuildTabardInfo = true,
      GuildControlGetRankFlags = true,
      GuildRoster = true,
      IsGuildOfficer = true,
      IsGuildRankAssignmentAllowed = true,
      QueryGuildMemberRecipes = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      QueryGuildMembersForRecipe = true,
      RemoveFromGuild = true,
      SetGuildRankOrder = true,
      SetNote = true,
    },
  },
  C_Heirloom = {
    methods = {
      CanHeirloomUpgradeFromPending = true,
      CreateHeirloom = true,
      GetClassAndSpecFilters = true,
      GetCollectedHeirloomFilter = true,
      GetHeirloomInfo = true,
      GetHeirloomItemIDFromDisplayedIndex = true,
      GetHeirloomItemIDs = true,
      GetHeirloomLink = true,
      GetHeirloomMaxUpgradeLevel = true,
      GetHeirloomSourceFilter = true,
      GetNumDisplayedHeirlooms = true,
      GetNumHeirlooms = true,
      GetNumKnownHeirlooms = true,
      GetUncollectedHeirloomFilter = true,
      IsItemHeirloom = true,
      IsPendingHeirloomUpgrade = true,
      PlayerHasHeirloom = true,
      SetClassAndSpecFilters = true,
      SetCollectedHeirloomFilter = true,
      SetHeirloomSourceFilter = true,
      SetSearch = true,
      SetUncollectedHeirloomFilter = true,
      ShouldShowHeirloomHelp = true,
      UpgradeHeirloom = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_HeirloomInfo = {
    methods = {
      AreAllCollectionFiltersChecked = true,
      AreAllSourceFiltersChecked = true,
      IsHeirloomSourceValid = true,
      IsUsingDefaultFilters = true,
      SetAllCollectionFilters = true,
      SetAllSourceFilters = true,
      SetDefaultFilters = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_IncomingSummon = {
    methods = {
      HasIncomingSummon = true,
      IncomingSummonStatus = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_InvasionInfo = {
    methods = {
      AreInvasionsAvailable = true,
      GetInvasionForUiMapID = true,
      GetInvasionInfo = true,
      GetInvasionTimeLeft = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_IslandsQueue = {
    methods = {
      CloseIslandsQueueScreen = true,
      GetIslandDifficultyInfo = true,
      GetIslandsMaxGroupSize = true,
      GetIslandsWeeklyQuestID = true,
      QueueForIsland = true,
      RequestPreloadRewardData = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_Item = {
    methods = {
      CanItemTransmogAppearance = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanScrapItem = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanViewItemPowers = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      DoesItemExist = true,
      DoesItemExistByID = true,
      DoesItemMatchBonusTreeReplacement = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAppliedItemTransmogInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBaseItemTransmogInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCurrentItemLevel = true,
      GetCurrentItemTransmogInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetItemConversionOutputIcon = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetItemGUID = true,
      GetItemID = true,
      GetItemIcon = true,
      GetItemIconByID = true,
      GetItemInventoryType = true,
      GetItemInventoryTypeByID = true,
      GetItemLink = true,
      GetItemMaxStackSize = {
        products = {
          wow_beta = true,
        },
      },
      GetItemMaxStackSizeByID = {
        products = {
          wow_beta = true,
        },
      },
      GetItemName = true,
      GetItemNameByID = true,
      GetItemQuality = true,
      GetItemQualityByID = true,
      GetItemUniquenessByID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetLimitedCurrencyItemInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetStackCount = true,
      IsAnimaItemByID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsBound = true,
      IsDressableItemByID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsItemConduit = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsItemConvertibleAndValidForPlayer = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsItemCorrupted = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsItemCorruptionRelated = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsItemCorruptionResistant = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsItemDataCached = true,
      IsItemDataCachedByID = true,
      IsItemKeystoneByID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsItemSpecificToPlayerClass = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsLocked = true,
      LockItem = true,
      LockItemByGUID = true,
      RequestLoadItemData = true,
      RequestLoadItemDataByID = true,
      UnlockItem = true,
      UnlockItemByGUID = true,
    },
  },
  C_ItemInteraction = {
    methods = {
      ClearPendingItem = true,
      CloseUI = true,
      GetChargeInfo = true,
      GetItemConversionCurrencyCost = true,
      GetItemInteractionInfo = true,
      GetItemInteractionSpellId = true,
      InitializeFrame = true,
      PerformItemInteraction = true,
      Reset = true,
      SetCorruptionReforgerItemTooltip = true,
      SetItemConversionOutputTooltip = true,
      SetPendingItem = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_ItemSocketInfo = {
    methods = {
      CompleteSocketing = true,
    },
  },
  C_ItemUpgrade = {
    methods = {
      CanUpgradeItem = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ClearItemUpgrade = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CloseItemUpgrade = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetItemHyperlink = true,
      GetItemUpgradeCurrentLevel = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetItemUpgradeEffect = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetItemUpgradeItemInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetItemUpgradePvpItemLevelDeltaValues = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumItemUpgradeEffects = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetItemUpgradeFromCursorItem = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetItemUpgradeFromLocation = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      UpgradeItem = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
  },
  C_KeyBindings = {
    methods = {
      GetCustomBindingType = true,
    },
  },
  C_LFGInfo = {
    methods = {
      CanPlayerUseGroupFinder = true,
      CanPlayerUseLFD = true,
      CanPlayerUseLFR = true,
      CanPlayerUsePVP = true,
      CanPlayerUsePremadeGroup = true,
      ConfirmLfgExpandSearch = true,
      GetAllEntriesForCategory = true,
      GetDungeonInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetLFDLockStates = true,
      GetRoleCheckDifficultyDetails = true,
      HideNameFromUI = true,
    },
  },
  C_LFGList = {
    methods = {
      AcceptInvite = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ApplyToGroup = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanActiveEntryUseAutoAccept = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanCreateQuestGroup = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CancelApplication = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ClearApplicationTextFields = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ClearCreationTextFields = true,
      ClearSearchResults = true,
      ClearSearchTextFields = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CopyActiveEntryInfoToCreationFields = true,
      CreateListing = true,
      DeclineApplicant = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      DeclineInvite = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      DoesEntryTitleMatchPrebuiltTitle = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetActiveEntryInfo = true,
      GetActivityFullName = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetActivityGroupInfo = true,
      GetActivityIDForQuestID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetActivityInfo = {
        products = {
          wow_classic = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
        },
      },
      GetActivityInfoExpensive = true,
      GetActivityInfoTable = {
        products = {
          wow = true,
          wow_beta = true,
          wow_classic_beta = true,
          wow_classic_ptr = true,
          wowt = true,
        },
      },
      GetApplicantDungeonScoreForListing = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetApplicantInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetApplicantMemberInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetApplicantMemberStats = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetApplicantPvpRatingInfoForListing = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetApplicants = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetApplicationInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetApplications = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAvailableActivities = true,
      GetAvailableActivityGroups = true,
      GetAvailableCategories = true,
      GetAvailableLanguageSearchFilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAvailableRoles = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCategoryInfo = {
        products = {
          wow_classic = true,
          wow_classic_beta = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
          wow_classic_ptr = true,
        },
      },
      GetDefaultLanguageSearchFilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFilteredSearchResults = true,
      GetKeystoneForActivity = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetLanguageSearchFilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetLfgCategoryInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumApplicants = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumApplications = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumInvitedApplicantMembers = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumPendingApplicantMembers = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetOwnedKeystoneActivityAndGroupAndLevel = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPlaystyleString = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRoleCheckInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRoles = {
        products = {
          wow_classic_beta = true,
          wow_classic_ptr = true,
        },
      },
      GetSearchResultEncounterInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSearchResultFriends = true,
      GetSearchResultInfo = true,
      GetSearchResultLeaderInfo = {
        products = {
          wow_classic = true,
          wow_classic_beta = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
          wow_classic_ptr = true,
        },
      },
      GetSearchResultMemberCounts = true,
      GetSearchResultMemberInfo = true,
      GetSearchResults = true,
      HasActiveEntryInfo = true,
      HasActivityList = true,
      HasSearchResultInfo = true,
      InviteApplicant = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsCurrentlyApplying = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsLookingForGroupEnabled = {
        products = {
          wow_classic = true,
          wow_classic_beta = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
          wow_classic_ptr = true,
        },
      },
      IsPlayerAuthenticatedForLFG = {
        products = {
          wow = true,
          wow_beta = true,
          wow_classic_beta = true,
          wow_classic_ptr = true,
          wowt = true,
        },
      },
      RefreshApplicants = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RemoveApplicant = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RemoveListing = true,
      ReportSearchResult = {
        products = {
          wow_classic = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
        },
      },
      RequestAvailableActivities = true,
      RequestInvite = {
        products = {
          wow_classic_beta = true,
          wow_classic_ptr = true,
        },
      },
      SaveLanguageSearchFilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      Search = true,
      SetApplicantMemberRole = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetEntryTitle = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetRoles = {
        products = {
          wow_classic_beta = true,
          wow_classic_ptr = true,
        },
      },
      SetSearchToActivity = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetSearchToQuestID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      UpdateListing = true,
      ValidateRequiredDungeonScore = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ValidateRequiredPvpRatingForActivity = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
  },
  C_LegendaryCrafting = {
    methods = {
      CloseRuneforgeInteraction = true,
      CraftRuneforgeLegendary = true,
      GetRuneforgeItemPreviewInfo = true,
      GetRuneforgeLegendaryComponentInfo = true,
      GetRuneforgeLegendaryCost = true,
      GetRuneforgeLegendaryCraftSpellID = true,
      GetRuneforgeLegendaryCurrencies = true,
      GetRuneforgeLegendaryUpgradeCost = true,
      GetRuneforgeModifierInfo = true,
      GetRuneforgeModifiers = true,
      GetRuneforgePowerInfo = true,
      GetRuneforgePowerSlots = true,
      GetRuneforgePowers = true,
      GetRuneforgePowersByClassSpecAndCovenant = true,
      IsRuneforgeLegendary = true,
      IsRuneforgeLegendaryMaxLevel = true,
      IsUpgradeItemValidForRuneforgeLegendary = true,
      IsValidRuneforgeBaseItem = true,
      MakeRuneforgeCraftDescription = true,
      UpgradeRuneforgeLegendary = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_LevelLink = {
    methods = {
      IsActionLocked = true,
      IsSpellLocked = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_LevelSquish = {
    methods = {
      ConvertFollowerLevel = true,
      ConvertPlayerLevel = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_Loot = {
    methods = {
      IsLegacyLootModeEnabled = true,
    },
  },
  C_LootHistory = {
    methods = {
      CanMasterLoot = true,
      GetExpiration = true,
      GetItem = true,
      GetNumItems = true,
      GetPlayerInfo = true,
      GiveMasterLoot = true,
      SetExpiration = true,
    },
  },
  C_LootJournal = {
    methods = {
      GetItemSetItems = true,
      GetItemSets = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_LoreText = {
    methods = {
      RequestLoreTextForCampaignID = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_LossOfControl = {
    methods = {
      GetActiveLossOfControlData = true,
      GetActiveLossOfControlDataByUnit = true,
      GetActiveLossOfControlDataCount = true,
      GetActiveLossOfControlDataCountByUnit = true,
    },
  },
  C_Mail = {
    methods = {
      CanCheckInbox = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      HasInboxMoney = true,
      IsCommandPending = true,
    },
  },
  C_Map = {
    methods = {
      CanSetUserWaypointOnMap = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ClearUserWaypoint = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CloseWorldMapInteraction = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAreaInfo = true,
      GetBestMapForUnit = true,
      GetBountySetIDForMap = {
        products = {
          wow_classic = true,
          wow_classic_beta = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
          wow_classic_ptr = true,
        },
      },
      GetBountySetMaps = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFallbackWorldMapID = true,
      GetMapArtBackgroundAtlas = true,
      GetMapArtHelpTextPosition = true,
      GetMapArtID = true,
      GetMapArtLayerTextures = true,
      GetMapArtLayers = true,
      GetMapBannersForMap = true,
      GetMapChildrenInfo = true,
      GetMapDisplayInfo = true,
      GetMapGroupID = true,
      GetMapGroupMembersInfo = true,
      GetMapHighlightInfoAtPosition = true,
      GetMapInfo = true,
      GetMapInfoAtPosition = true,
      GetMapLevels = true,
      GetMapLinksForMap = true,
      GetMapPosFromWorldPos = true,
      GetMapRectOnMap = true,
      GetMapWorldSize = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPlayerMapPosition = true,
      GetUserWaypoint = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetUserWaypointFromHyperlink = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetUserWaypointHyperlink = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetUserWaypointPositionForMap = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetWorldPosFromMapPos = true,
      HasUserWaypoint = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsMapValidForNavBarDropDown = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      MapHasArt = true,
      RequestPreloadMap = true,
      SetUserWaypoint = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
  },
  C_MapExplorationInfo = {
    methods = {
      GetExploredAreaIDsAtPosition = true,
      GetExploredMapTextures = true,
    },
  },
  C_MerchantFrame = {
    methods = {
      GetBuybackItemID = true,
      IsMerchantItemRefundable = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
  },
  C_Minimap = {
    methods = {
      CanTrackBattlePets = {
        products = {
          wow_beta = true,
        },
      },
      ClearAllTracking = {
        products = {
          wow_beta = true,
        },
      },
      GetDrawGroundTextures = true,
      GetNumQuestPOIWorldEffects = {
        products = {
          wow_beta = true,
        },
      },
      GetNumTrackingTypes = {
        products = {
          wow_beta = true,
        },
      },
      GetObjectIconTextureCoords = {
        products = {
          wow_beta = true,
        },
      },
      GetPOITextureCoords = {
        products = {
          wow_beta = true,
        },
      },
      GetTrackingFilter = {
        products = {
          wow_beta = true,
        },
      },
      GetTrackingInfo = {
        products = {
          wow_beta = true,
        },
      },
      GetUiMapID = true,
      GetViewRadius = true,
      IsFilteredOut = {
        products = {
          wow_beta = true,
        },
      },
      IsRotateMinimapIgnored = true,
      IsTrackingBattlePets = {
        products = {
          wow_beta = true,
        },
      },
      IsTrackingHiddenQuests = {
        products = {
          wow_beta = true,
        },
      },
      SetDrawGroundTextures = true,
      SetIgnoreRotateMinimap = true,
      SetTracking = {
        products = {
          wow_beta = true,
        },
      },
      ShouldUseHybridMinimap = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_ModelInfo = {
    methods = {
      AddActiveModelScene = true,
      AddActiveModelSceneActor = true,
      ClearActiveModelScene = true,
      ClearActiveModelSceneActor = true,
      GetModelSceneActorDisplayInfoByID = true,
      GetModelSceneActorInfoByID = true,
      GetModelSceneCameraInfoByID = true,
      GetModelSceneInfoByID = true,
    },
  },
  C_ModifiedInstance = {
    methods = {
      GetModifiedInstanceInfoFromMapID = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_MountJournal = {
    methods = {
      ApplyMountEquipment = true,
      AreMountEquipmentEffectsSuppressed = true,
      ClearFanfare = true,
      ClearRecentFanfares = true,
      Dismiss = true,
      GetAppliedMountEquipmentID = true,
      GetCollectedDragonridingMounts = {
        products = {
          wow_beta = true,
        },
      },
      GetCollectedFilterSetting = true,
      GetDisplayedMountAllCreatureDisplayInfo = true,
      GetDisplayedMountID = {
        products = {
          wow_beta = true,
        },
      },
      GetDisplayedMountInfo = true,
      GetDisplayedMountInfoExtra = true,
      GetIsFavorite = true,
      GetMountAllCreatureDisplayInfoByID = true,
      GetMountEquipmentUnlockLevel = true,
      GetMountFromItem = true,
      GetMountFromSpell = true,
      GetMountIDs = true,
      GetMountInfoByID = true,
      GetMountInfoExtraByID = true,
      GetMountUsabilityByID = true,
      GetNumDisplayedMounts = true,
      GetNumMounts = true,
      GetNumMountsNeedingFanfare = true,
      IsItemMountEquipment = true,
      IsMountEquipmentApplied = true,
      IsSourceChecked = true,
      IsTypeChecked = true,
      IsUsingDefaultFilters = true,
      IsValidSourceFilter = true,
      IsValidTypeFilter = true,
      NeedsFanfare = true,
      Pickup = true,
      SetAllSourceFilters = true,
      SetAllTypeFilters = true,
      SetCollectedFilterSetting = true,
      SetDefaultFilters = true,
      SetIsFavorite = true,
      SetSearch = true,
      SetSourceFilter = true,
      SetTypeFilter = true,
      SummonByID = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_MythicPlus = {
    methods = {
      GetCurrentAffixes = true,
      GetCurrentSeason = true,
      GetCurrentSeasonValues = true,
      GetCurrentUIDisplaySeason = {
        products = {
          wow_beta = true,
        },
      },
      GetLastWeeklyBestInformation = true,
      GetOwnedKeystoneChallengeMapID = true,
      GetOwnedKeystoneLevel = true,
      GetOwnedKeystoneMapID = true,
      GetRewardLevelForDifficultyLevel = true,
      GetRewardLevelFromKeystoneLevel = true,
      GetRunHistory = true,
      GetSeasonBestAffixScoreInfoForMap = true,
      GetSeasonBestForMap = true,
      GetSeasonBestMythicRatingFromThisExpansion = true,
      GetWeeklyBestForMap = true,
      GetWeeklyChestRewardLevel = true,
      IsMythicPlusActive = true,
      IsWeeklyRewardAvailable = true,
      RequestCurrentAffixes = true,
      RequestMapInfo = true,
      RequestRewards = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_NamePlate = {
    methods = {
      GetNamePlateEnemyClickThrough = true,
      GetNamePlateEnemyPreferredClickInsets = true,
      GetNamePlateEnemySize = true,
      GetNamePlateForUnit = true,
      GetNamePlateFriendlyClickThrough = true,
      GetNamePlateFriendlyPreferredClickInsets = true,
      GetNamePlateFriendlySize = true,
      GetNamePlateSelfClickThrough = true,
      GetNamePlateSelfPreferredClickInsets = true,
      GetNamePlateSelfSize = true,
      GetNamePlates = true,
      GetNumNamePlateMotionTypes = true,
      GetTargetClampingInsets = true,
      SetNamePlateEnemyClickThrough = true,
      SetNamePlateEnemyPreferredClickInsets = true,
      SetNamePlateEnemySize = true,
      SetNamePlateFriendlyClickThrough = true,
      SetNamePlateFriendlyPreferredClickInsets = true,
      SetNamePlateFriendlySize = true,
      SetNamePlateSelfClickThrough = true,
      SetNamePlateSelfPreferredClickInsets = true,
      SetNamePlateSelfSize = true,
      SetTargetClampingInsets = true,
    },
  },
  C_Navigation = {
    methods = {
      GetDistance = true,
      GetFrame = true,
      GetTargetState = true,
      HasValidScreenPosition = true,
      WasClampedToScreen = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_NewItems = {
    methods = {
      ClearAll = true,
      IsNewItem = true,
      RemoveNewItem = true,
    },
  },
  C_PaperDollInfo = {
    methods = {
      GetArmorEffectiveness = true,
      GetArmorEffectivenessAgainstTarget = true,
      GetInspectAzeriteItemEmpoweredChoices = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetInspectItemLevel = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMinItemLevel = true,
      GetStaggerPercentage = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      OffhandHasShield = true,
      OffhandHasWeapon = true,
    },
  },
  C_PartyInfo = {
    methods = {
      AllowedToDoPartyConversion = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanFormCrossFactionParties = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanInvite = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ConfirmConvertToRaid = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ConfirmInviteTravelPass = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ConfirmInviteUnit = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ConfirmLeaveParty = true,
      ConfirmRequestInviteFromUnit = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ConvertToParty = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ConvertToRaid = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      DoCountdown = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetActiveCategories = true,
      GetInviteConfirmationInvalidQueues = true,
      GetInviteReferralInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMinLevel = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      InviteUnit = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsCrossFactionParty = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsPartyFull = {
        products = {
          wow = true,
          wow_beta = true,
          wow_classic_beta = true,
          wow_classic_ptr = true,
          wowt = true,
        },
      },
      IsPartyInJailersTower = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      LeaveParty = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RequestInviteFromUnit = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
  },
  C_PartyPose = {
    methods = {
      GetPartyPoseInfoByMapID = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_PetBattles = {
    methods = {
      AcceptPVPDuel = true,
      AcceptQueuedPVPMatch = true,
      CanAcceptQueuedPVPMatch = true,
      CanActivePetSwapOut = true,
      CanPetSwapIn = true,
      CancelPVPDuel = true,
      ChangePet = true,
      DeclineQueuedPVPMatch = true,
      ForfeitGame = true,
      GetAbilityEffectInfo = true,
      GetAbilityInfo = true,
      GetAbilityInfoByID = true,
      GetAbilityProcTurnIndex = true,
      GetAbilityState = true,
      GetAbilityStateModification = true,
      GetActivePet = true,
      GetAllEffectNames = true,
      GetAllStates = true,
      GetAttackModifier = true,
      GetAuraInfo = true,
      GetBattleState = true,
      GetBreedQuality = true,
      GetDisplayID = true,
      GetForfeitPenalty = true,
      GetHealth = true,
      GetIcon = true,
      GetLevel = true,
      GetMaxHealth = true,
      GetName = true,
      GetNumAuras = true,
      GetNumPets = true,
      GetPVPMatchmakingInfo = true,
      GetPetSpeciesID = true,
      GetPetType = true,
      GetPlayerTrapAbility = true,
      GetPower = true,
      GetSelectedAction = true,
      GetSpeed = true,
      GetStateValue = true,
      GetTurnTimeInfo = true,
      GetXP = true,
      IsInBattle = true,
      IsPlayerNPC = true,
      IsSkipAvailable = true,
      IsTrapAvailable = true,
      IsWaitingOnOpponent = true,
      IsWildBattle = true,
      SetPendingReportBattlePetTarget = true,
      SetPendingReportTargetFromUnit = true,
      ShouldShowPetSelect = true,
      SkipTurn = true,
      StartPVPDuel = true,
      StartPVPMatchmaking = true,
      StopPVPMatchmaking = true,
      UseAbility = true,
      UseTrap = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_PetInfo = {
    methods = {
      GetPetTamersForMap = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_PetJournal = {
    methods = {
      CagePetByID = true,
      ClearFanfare = true,
      ClearRecentFanfares = true,
      ClearSearchFilter = true,
      FindPetIDByName = true,
      GetBattlePetLink = true,
      GetDisplayIDByIndex = true,
      GetDisplayProbabilityByIndex = true,
      GetNumCollectedInfo = true,
      GetNumDisplays = true,
      GetNumPetSources = true,
      GetNumPetTypes = true,
      GetNumPets = true,
      GetNumPetsNeedingFanfare = true,
      GetOwnedBattlePetString = true,
      GetPetAbilityInfo = true,
      GetPetAbilityList = true,
      GetPetAbilityListTable = true,
      GetPetCooldownByGUID = true,
      GetPetInfoByIndex = true,
      GetPetInfoByItemID = true,
      GetPetInfoByPetID = true,
      GetPetInfoBySpeciesID = true,
      GetPetInfoTableByPetID = true,
      GetPetLoadOutInfo = true,
      GetPetModelSceneInfoBySpeciesID = true,
      GetPetSortParameter = true,
      GetPetStats = true,
      GetPetSummonInfo = true,
      GetPetTeamAverageLevel = true,
      GetSummonBattlePetCooldown = true,
      GetSummonRandomFavoritePetGUID = true,
      GetSummonedPetGUID = true,
      HasFavoritePets = {
        products = {
          wow_beta = true,
        },
      },
      IsFilterChecked = true,
      IsFindBattleEnabled = true,
      IsJournalReadOnly = true,
      IsJournalUnlocked = true,
      IsPetSourceChecked = true,
      IsPetTypeChecked = true,
      IsUsingDefaultFilters = true,
      PetCanBeReleased = true,
      PetIsCapturable = true,
      PetIsFavorite = true,
      PetIsHurt = true,
      PetIsLockedForConvert = true,
      PetIsRevoked = true,
      PetIsSlotted = true,
      PetIsSummonable = true,
      PetIsTradable = true,
      PetIsUsable = true,
      PetNeedsFanfare = true,
      PetUsesRandomDisplay = true,
      PickupPet = true,
      PickupSummonRandomPet = true,
      ReleasePetByID = true,
      SetAbility = true,
      SetAllPetSourcesChecked = true,
      SetAllPetTypesChecked = true,
      SetCustomName = true,
      SetDefaultFilters = true,
      SetFavorite = true,
      SetFilterChecked = true,
      SetPetLoadOutInfo = true,
      SetPetSortParameter = true,
      SetPetSourceChecked = true,
      SetPetTypeFilter = true,
      SetSearchFilter = true,
      SpellTargetBattlePet = {
        products = {
          wow_beta = true,
        },
      },
      SummonPetByGUID = true,
      SummonRandomPet = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_PlayerChoice = {
    methods = {
      GetCurrentPlayerChoiceInfo = true,
      GetNumRerolls = true,
      GetRemainingTime = true,
      IsWaitingForPlayerChoiceResponse = true,
      OnUIClosed = true,
      RequestRerollPlayerChoice = true,
      SendPlayerChoiceResponse = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_PlayerInfo = {
    methods = {
      CanPlayerEnterChromieTime = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanPlayerUseAreaLoot = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanPlayerUseMountEquipment = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GUIDIsPlayer = true,
      GetAlternateFormInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wow_classic_beta = true,
          wow_classic_ptr = true,
          wowt = true,
        },
      },
      GetClass = true,
      GetContentDifficultyCreatureForPlayer = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetContentDifficultyQuestForPlayer = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetInstancesUnlockedAtLevel = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetName = true,
      GetPlayerMythicPlusRatingSummary = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRace = true,
      GetSex = true,
      IsConnected = true,
      IsPlayerEligibleForNPE = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsPlayerEligibleForNPEv2 = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsPlayerInChromieTime = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsPlayerInGuildFromGUID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsPlayerNPERestricted = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      UnitIsSameServer = true,
    },
  },
  C_PlayerMentorship = {
    methods = {
      GetMentorLevelRequirement = true,
      GetMentorRequirements = true,
      GetMentorshipStatus = true,
      IsActivePlayerConsideredNewcomer = true,
      IsMentorRestricted = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_ProductChoice = {
    methods = {
      GetChoices = true,
      GetNumSuppressed = true,
      GetProducts = true,
      MakeSelection = true,
    },
    products = {
      wow_classic = true,
      wow_classic_beta = true,
      wow_classic_era = true,
      wow_classic_era_ptr = true,
      wow_classic_ptr = true,
    },
  },
  C_ProfSpecs = {
    methods = {
      CanRefundPath = true,
      CanUnlockTab = true,
      GetChildrenForPath = true,
      GetConfigIDForSkillLine = true,
      GetDefaultSpecSkillLine = true,
      GetDescriptionForPath = true,
      GetDescriptionForPerk = true,
      GetEntryIDForPerk = true,
      GetPerksForPath = true,
      GetRootPathForTab = true,
      GetSourceTextForPath = true,
      GetSpecTabIDsForSkillLine = true,
      GetSpecTabInfo = true,
      GetSpendCurrencyForPath = true,
      GetSpendEntryForPath = true,
      GetStateForPath = true,
      GetStateForTab = true,
      GetTabInfo = true,
      GetUnlockEntryForPath = true,
      GetUnlockRankForPerk = true,
      GetUnspentPointsForSkillLine = true,
      PerkIsEarned = true,
      ShouldShowSpecForSkillLine = true,
      ShouldShowSpecTab = true,
      SkillLineHasSpecialization = true,
    },
    products = {
      wow_beta = true,
    },
  },
  C_PvP = {
    methods = {
      CanDisplayDamage = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanDisplayDeaths = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanDisplayHealing = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanDisplayHonorableKills = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanDisplayKillingBlows = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanPlayerUseRatedPVPUI = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanToggleWarMode = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanToggleWarModeInArea = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      DoesMatchOutcomeAffectRating = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetActiveBrawlInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetActiveMatchBracket = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetActiveMatchDuration = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetActiveMatchState = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetActiveMatchWinner = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetArenaCrowdControlInfo = true,
      GetArenaRewards = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetArenaSkirmishRewards = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAvailableBrawlInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBattlefieldFlagPosition = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBattlefieldVehicleInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBattlefieldVehicles = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBrawlRewards = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCustomVictoryStatID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetGlobalPvpScalingInfoForSpecID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetHonorRewardInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetLevelUpBattlegrounds = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMatchPVPStatColumn = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMatchPVPStatColumns = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNextHonorLevelForReward = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetOutdoorPvPWaitTime = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPVPActiveMatchPersonalRatedInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPVPSeasonRewardAchievementID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPostMatchCurrencyRewards = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPostMatchItemRewards = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPvpTierID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPvpTierInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRandomBGInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRandomBGLossRewards = {
        products = {
          wow_classic_beta = true,
          wow_classic_ptr = true,
        },
      },
      GetRandomBGRewards = {
        products = {
          wow = true,
          wow_beta = true,
          wow_classic_beta = true,
          wow_classic_ptr = true,
          wowt = true,
        },
      },
      GetRandomEpicBGInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRandomEpicBGRewards = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRatedBGRewards = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRatedSoloShuffleMinItemLevel = {
        products = {
          wow_beta = true,
        },
      },
      GetRewardItemLevelsByTierEnum = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetScoreInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetScoreInfoByPlayerGuid = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSeasonBestInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSkirmishInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSpecialEventBrawlInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetTeamInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetWarModeRewardBonus = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetWarModeRewardBonusDefault = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetWeeklyChestInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      HasArenaSkirmishWinToday = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsActiveBattlefield = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsActiveMatchRegistered = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsArena = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsBattleground = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsBattlegroundEnlistmentBonusActive = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsInBrawl = true,
      IsMatchConsideredArena = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsMatchFactional = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsPVPMap = true,
      IsRatedArena = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsRatedBattleground = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsRatedMap = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsSoloShuffle = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsWarModeActive = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsWarModeDesired = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsWarModeFeatureEnabled = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      JoinBrawl = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RequestCrowdControlSpell = true,
      SetWarModeDesired = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ToggleWarMode = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
  },
  C_QuestItemUse = {
    methods = {
      CanUseQuestItemOnObject = true,
    },
    products = {
      wow_beta = true,
    },
  },
  C_QuestLine = {
    methods = {
      GetAvailableQuestLines = true,
      GetQuestLineInfo = true,
      GetQuestLineQuests = true,
      IsComplete = true,
      RequestQuestLinesForMap = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_QuestLog = {
    methods = {
      AbandonQuest = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      AddQuestWatch = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      AddWorldQuestWatch = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanAbandonQuest = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAbandonQuest = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAbandonQuestItems = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetActiveThreatMaps = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAllCompletedQuestIDs = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBountiesForMapID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBountySetInfoForMapID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetDistanceSqToQuest = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetLogIndexForQuestID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMapForQuestPOIs = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMaxNumQuests = true,
      GetMaxNumQuestsCanAccept = true,
      GetNextWaypoint = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNextWaypointForMap = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNextWaypointText = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumQuestLogEntries = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumQuestObjectives = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumQuestWatches = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumWorldQuestWatches = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetQuestAdditionalHighlights = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetQuestDetailsTheme = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetQuestDifficultyLevel = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetQuestIDForLogIndex = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetQuestIDForQuestWatchIndex = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetQuestIDForWorldQuestWatchIndex = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetQuestInfo = {
        products = {
          wow_classic = true,
          wow_classic_beta = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
          wow_classic_ptr = true,
        },
      },
      GetQuestLogPortraitGiver = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetQuestObjectives = true,
      GetQuestTagInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetQuestType = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetQuestWatchType = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetQuestsOnMap = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRequiredMoney = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSelectedQuest = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSuggestedGroupSize = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetTimeAllowed = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetTitleForLogIndex = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetTitleForQuestID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetZoneStoryInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      HasActiveThreats = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsAccountQuest = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsComplete = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsFailed = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsLegendaryQuest = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsOnMap = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsOnQuest = true,
      IsPushableQuest = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsQuestBounty = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsQuestCalling = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsQuestCriteriaForBounty = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsQuestDisabledForSession = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsQuestFlaggedCompleted = true,
      IsQuestInvasion = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsQuestReplayable = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsQuestReplayedRecently = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsQuestTask = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsQuestTrivial = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsRepeatableQuest = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsThreatQuest = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsUnitOnQuest = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsWorldQuest = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      QuestCanHaveWarModeBonus = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      QuestHasQuestSessionBonus = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      QuestHasWarModeBonus = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ReadyForTurnIn = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RemoveQuestWatch = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RemoveWorldQuestWatch = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RequestLoadQuestByID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetAbandonQuest = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetMapForQuestPOIs = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetSelectedQuest = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ShouldDisplayTimeRemaining = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ShouldShowQuestRewards = true,
      SortQuestWatches = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      UnitIsRelatedToActiveQuest = {
        products = {
          wow_beta = true,
        },
      },
    },
  },
  C_QuestOffer = {
    methods = {
      GetHideRequiredItemsOnTurnIn = true,
    },
    products = {
      wow_beta = true,
    },
  },
  C_QuestSession = {
    methods = {
      CanStart = true,
      CanStop = true,
      Exists = true,
      GetAvailableSessionCommand = true,
      GetPendingCommand = true,
      GetProposedMaxLevelForSession = true,
      GetSessionBeginDetails = true,
      GetSuperTrackedQuest = true,
      HasJoined = true,
      HasPendingCommand = true,
      RequestSessionStart = true,
      RequestSessionStop = true,
      SendSessionBeginResponse = true,
      SetQuestIsSuperTracked = true,
    },
  },
  C_RaidLocks = {
    methods = {
      IsEncounterComplete = true,
    },
  },
  C_RecruitAFriend = {
    methods = {
      ClaimActivityReward = true,
      ClaimNextReward = true,
      GenerateRecruitmentLink = true,
      GetRAFInfo = true,
      GetRAFSystemInfo = true,
      GetRecruitActivityRequirementsText = true,
      GetRecruitInfo = true,
      IsEnabled = true,
      IsRecruitingEnabled = true,
      RemoveRAFRecruit = true,
      RequestUpdatedRecruitmentInfo = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_ReportSystem = {
    methods = {
      CanReportPlayer = true,
      CanReportPlayerForLanguage = true,
      GetMajorCategoriesForReportType = {
        products = {
          wow = true,
          wow_beta = true,
          wow_classic_beta = true,
          wow_classic_ptr = true,
          wowt = true,
        },
      },
      GetMajorCategoryString = {
        products = {
          wow = true,
          wow_beta = true,
          wow_classic_beta = true,
          wow_classic_ptr = true,
          wowt = true,
        },
      },
      GetMinorCategoriesForReportTypeAndMajorCategory = {
        products = {
          wow = true,
          wow_beta = true,
          wow_classic_beta = true,
          wow_classic_ptr = true,
          wowt = true,
        },
      },
      GetMinorCategoryString = {
        products = {
          wow = true,
          wow_beta = true,
          wow_classic_beta = true,
          wow_classic_ptr = true,
          wowt = true,
        },
      },
      InitiateReportPlayer = {
        products = {
          wow_classic = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
        },
      },
      OpenReportPlayerDialog = {
        products = {
          wow_classic = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
        },
      },
      ReportServerLag = true,
      ReportStuckInCombat = true,
      SendReport = {
        products = {
          wow = true,
          wow_beta = true,
          wow_classic_beta = true,
          wow_classic_ptr = true,
          wowt = true,
        },
      },
      SendReportPlayer = {
        products = {
          wow_classic = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
        },
      },
      SetPendingReportPetTarget = {
        products = {
          wow_classic = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
        },
      },
      SetPendingReportTarget = {
        products = {
          wow_classic = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
        },
      },
      SetPendingReportTargetByGuid = {
        products = {
          wow_classic = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
        },
      },
    },
  },
  C_Reputation = {
    methods = {
      GetFactionParagonInfo = true,
      IsFactionParagon = true,
      RequestFactionParagonPreloadRewardData = true,
    },
  },
  C_ResearchInfo = {
    methods = {
      GetDigSitesForMap = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_Scenario = {
    methods = {
      GetBonusStepRewardQuestID = true,
      GetBonusSteps = true,
      GetCriteriaInfo = true,
      GetCriteriaInfoByStep = true,
      GetInfo = true,
      GetProvingGroundsInfo = true,
      GetScenarioIconInfo = true,
      GetStepInfo = true,
      GetSupersededObjectives = true,
      IsInScenario = true,
      ShouldShowCriteria = true,
      TreatScenarioAsDungeon = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_ScenarioInfo = {
    methods = {
      GetJailersTowerTypeString = true,
      GetScenarioInfo = true,
      GetScenarioStepInfo = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_ScrappingMachineUI = {
    methods = {
      CloseScrappingMachine = true,
      DropPendingScrapItemFromCursor = true,
      GetCurrentPendingScrapItemLocationByIndex = true,
      GetScrapSpellID = true,
      GetScrappingMachineName = true,
      HasScrappableItems = true,
      RemoveAllScrapItems = true,
      RemoveCurrentScrappingItem = true,
      RemoveItemToScrap = true,
      ScrapItems = true,
      SetScrappingMachine = true,
      ValidateScrappingList = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_ScriptedAnimations = {
    methods = {
      GetAllScriptedAnimationEffects = true,
    },
  },
  C_Seasons = {
    methods = {
      GetActiveSeason = true,
      HasActiveSeason = true,
    },
    products = {
      wow_classic = true,
      wow_classic_beta = true,
      wow_classic_era = true,
      wow_classic_era_ptr = true,
      wow_classic_ptr = true,
    },
  },
  C_Social = {
    methods = {
      GetLastAchievement = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetLastItem = true,
      GetLastScreenshot = {
        products = {
          wow_classic = true,
          wow_classic_beta = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
          wow_classic_ptr = true,
        },
      },
      GetLastScreenshotIndex = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMaxTweetLength = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumCharactersPerMedia = {
        products = {
          wow_classic = true,
          wow_classic_beta = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
          wow_classic_ptr = true,
        },
      },
      GetScreenshotByIndex = {
        products = {
          wow_classic = true,
          wow_classic_beta = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
          wow_classic_ptr = true,
        },
      },
      GetScreenshotInfoByIndex = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetTweetLength = true,
      IsSocialEnabled = true,
      RegisterSocialBrowser = true,
      SetTextureToScreenshot = true,
      TwitterCheckStatus = true,
      TwitterConnect = true,
      TwitterDisconnect = true,
      TwitterGetMSTillCanPost = true,
      TwitterPostAchievement = true,
      TwitterPostItem = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      TwitterPostMessage = true,
      TwitterPostScreenshot = true,
    },
  },
  C_SocialQueue = {
    methods = {
      GetAllGroups = true,
      GetConfig = true,
      GetGroupForPlayer = true,
      GetGroupInfo = true,
      GetGroupMembers = true,
      GetGroupQueues = true,
      RequestToJoin = true,
      SignalToastDisplayed = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_SocialRestrictions = {
    methods = {
      AcknowledgeRegionalChatDisabled = true,
      IsChatDisabled = true,
      IsMuted = true,
      IsSilenced = true,
      IsSquelched = true,
      SetChatDisabled = true,
    },
  },
  C_Soulbinds = {
    methods = {
      ActivateSoulbind = true,
      CanActivateSoulbind = true,
      CanModifySoulbind = true,
      CanResetConduitsInSoulbind = true,
      CanSwitchActiveSoulbindTreeBranch = true,
      CloseUI = true,
      CommitPendingConduitsInSoulbind = true,
      FindNodeIDActuallyInstalled = true,
      FindNodeIDAppearingInstalled = true,
      FindNodeIDPendingInstall = true,
      FindNodeIDPendingUninstall = true,
      GetActiveSoulbindID = true,
      GetConduitCollection = true,
      GetConduitCollectionCount = true,
      GetConduitCollectionData = true,
      GetConduitCollectionDataAtCursor = true,
      GetConduitCollectionDataByVirtualID = true,
      GetConduitDisplayed = true,
      GetConduitHyperlink = true,
      GetConduitIDPendingInstall = true,
      GetConduitQuality = true,
      GetConduitRank = true,
      GetConduitSpellID = true,
      GetInstalledConduitID = true,
      GetNode = true,
      GetSoulbindData = true,
      GetSpecsAssignedToSoulbind = true,
      GetTree = true,
      HasAnyInstalledConduitInSoulbind = true,
      HasAnyPendingConduits = true,
      HasPendingConduitsInSoulbind = true,
      IsConduitInstalled = true,
      IsConduitInstalledInSoulbind = true,
      IsItemConduitByItemInfo = true,
      IsNodePendingModify = true,
      IsUnselectedConduitPendingInSoulbind = true,
      ModifyNode = true,
      SelectNode = true,
      UnmodifyNode = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_Sound = {
    methods = {
      GetSoundScaledVolume = true,
      IsPlaying = true,
    },
    products = {
      wow_beta = true,
    },
  },
  C_SpecializationInfo = {
    methods = {
      CanPlayerUsePVPTalentUI = true,
      CanPlayerUseTalentSpecUI = true,
      CanPlayerUseTalentUI = true,
      GetAllSelectedPvpTalentIDs = true,
      GetInspectSelectedPvpTalent = true,
      GetPvpTalentAlertStatus = true,
      GetPvpTalentSlotInfo = true,
      GetPvpTalentSlotUnlockLevel = true,
      GetPvpTalentUnlockLevel = true,
      GetSpecIDs = true,
      GetSpellsDisplay = true,
      IsInitialized = true,
      IsPvpTalentLocked = true,
      MatchesCurrentSpecSet = true,
      SetPvpTalentLocked = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_Spell = {
    methods = {
      DoesSpellExist = true,
      GetMawPowerBorderAtlasBySpellID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsSpellDataCached = true,
      RequestLoadSpellData = true,
    },
  },
  C_SpellBook = {
    methods = {
      ContainsAnyDisenchantSpell = true,
      GetCurrentLevelSpells = true,
      GetDeadlyDebuffInfo = {
        products = {
          wow_beta = true,
        },
      },
      GetOverrideSpell = {
        products = {
          wow_beta = true,
        },
      },
      GetSkillLineIndexByID = true,
      GetSpellInfo = true,
      GetSpellLinkFromSpellID = true,
      GetTrackedNameplateSpells = {
        products = {
          wow_beta = true,
        },
      },
      IsSpellDisabled = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_SplashScreen = {
    methods = {
      AcknowledgeSplash = true,
      CanViewSplashScreen = true,
      RequestLatestSplashScreen = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_StableInfo = {
    methods = {
      GetNumActivePets = true,
      GetNumStablePets = true,
    },
  },
  C_StorePublic = {
    methods = {
      DoesGroupHavePurchaseableProducts = true,
      HasPurchaseableProducts = {
        products = {
          wow_classic = true,
          wow_classic_beta = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
          wow_classic_ptr = true,
        },
      },
      IsDisabledByParentalControls = true,
      IsEnabled = true,
    },
  },
  C_SummonInfo = {
    methods = {
      CancelSummon = true,
      ConfirmSummon = true,
      GetSummonConfirmAreaName = true,
      GetSummonConfirmSummoner = true,
      GetSummonConfirmTimeLeft = true,
      GetSummonReason = true,
      IsSummonSkippingStartExperience = true,
    },
  },
  C_SuperTrack = {
    methods = {
      GetHighestPrioritySuperTrackingType = true,
      GetSuperTrackedQuestID = true,
      IsSuperTrackingAnything = true,
      IsSuperTrackingCorpse = true,
      IsSuperTrackingQuest = true,
      IsSuperTrackingUserWaypoint = true,
      SetSuperTrackedQuestID = true,
      SetSuperTrackedUserWaypoint = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_System = {
    methods = {
      GetFrameStack = true,
    },
  },
  C_TTSSettings = {
    methods = {
      GetChannelEnabled = true,
      GetCharacterSettingsSaved = true,
      GetChatTypeEnabled = true,
      GetSetting = true,
      GetSpeechRate = true,
      GetSpeechVolume = true,
      GetVoiceOptionID = true,
      GetVoiceOptionName = true,
      MarkCharacterSettingsSaved = true,
      SetChannelEnabled = true,
      SetChannelKeyEnabled = true,
      SetChatTypeEnabled = true,
      SetDefaultSettings = true,
      SetSetting = true,
      SetSpeechRate = true,
      SetSpeechVolume = true,
      SetVoiceOption = true,
      SetVoiceOptionName = true,
      ShouldOverrideMessage = true,
    },
  },
  C_TaskQuest = {
    methods = {
      DoesMapShowTaskQuestObjectives = true,
      GetQuestInfoByQuestID = true,
      GetQuestLocation = true,
      GetQuestProgressBarInfo = true,
      GetQuestTimeLeftMinutes = true,
      GetQuestTimeLeftSeconds = true,
      GetQuestZoneID = true,
      GetQuestsForPlayerByMapID = true,
      GetThreatQuests = true,
      GetUIWidgetSetIDFromQuestID = true,
      IsActive = true,
      RequestPreloadRewardData = true,
    },
  },
  C_TaxiMap = {
    methods = {
      GetAllTaxiNodes = true,
      GetTaxiNodesForMap = true,
      ShouldMapShowTaxiNodes = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
  },
  C_Texture = {
    methods = {
      GetAtlasInfo = true,
      GetFilenameFromFileDataID = {
        products = {
          wow_beta = true,
        },
      },
    },
  },
  C_Timer = {
    methods = {
      After = true,
      NewTicker = {
        products = {
          wow_beta = true,
        },
      },
      NewTimer = {
        products = {
          wow_beta = true,
        },
      },
    },
  },
  C_ToyBox = {
    methods = {
      ForceToyRefilter = true,
      GetCollectedShown = true,
      GetIsFavorite = true,
      GetNumFilteredToys = true,
      GetNumLearnedDisplayedToys = true,
      GetNumTotalDisplayedToys = true,
      GetNumToys = true,
      GetToyFromIndex = true,
      GetToyInfo = true,
      GetToyLink = true,
      GetUncollectedShown = true,
      GetUnusableShown = true,
      HasFavorites = true,
      IsExpansionTypeFilterChecked = true,
      IsSourceTypeFilterChecked = true,
      IsToyUsable = true,
      PickupToyBoxItem = true,
      SetAllExpansionTypeFilters = true,
      SetAllSourceTypeFilters = true,
      SetCollectedShown = true,
      SetExpansionTypeFilter = true,
      SetFilterString = true,
      SetIsFavorite = true,
      SetSourceTypeFilter = true,
      SetUncollectedShown = true,
      SetUnusableShown = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_ToyBoxInfo = {
    methods = {
      ClearFanfare = true,
      IsToySourceValid = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsUsingDefaultFilters = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      NeedsFanfare = true,
      SetDefaultFilters = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
  },
  C_TradeSkillUI = {
    methods = {
      AnyRecipeCategoriesFiltered = true,
      AreAnyInventorySlotsFiltered = true,
      CanObliterateCursorItem = true,
      CanTradeSkillListLink = true,
      ClearInventorySlotFilter = true,
      ClearPendingObliterateItem = true,
      ClearRecipeCategoryFilter = true,
      ClearRecipeSourceTypeFilter = true,
      CloseCraftingOrders = {
        products = {
          wow_beta = true,
        },
      },
      CloseCustomerOrders = {
        products = {
          wow_beta = true,
        },
      },
      CloseObliterumForge = true,
      CloseTradeSkill = true,
      ContinueRecast = {
        products = {
          wow_beta = true,
        },
      },
      CraftRecipe = true,
      CraftSalvage = {
        products = {
          wow_beta = true,
        },
      },
      DropPendingObliterateItemFromCursor = true,
      GetAllFilterableInventorySlots = true,
      GetAllProfessionTradeSkillLines = true,
      GetAllRecipeIDs = true,
      GetBaseProfessionInfo = {
        products = {
          wow_beta = true,
        },
      },
      GetCategories = true,
      GetCategoryInfo = true,
      GetChildProfessionInfo = {
        products = {
          wow_beta = true,
        },
      },
      GetChildProfessionInfos = {
        products = {
          wow_beta = true,
        },
      },
      GetCraftingOperationInfo = {
        products = {
          wow_beta = true,
        },
      },
      GetCraftingReagentBonusText = {
        products = {
          wow_beta = true,
        },
      },
      GetFactionSpecificOutputItem = {
        products = {
          wow_beta = true,
        },
      },
      GetFilterableInventorySlots = true,
      GetFilteredRecipeIDs = true,
      GetItemReagentQualityByItemInfo = {
        products = {
          wow_beta = true,
        },
      },
      GetObliterateSpellID = true,
      GetOnlyShowLearnedRecipes = true,
      GetOnlyShowMakeableRecipes = true,
      GetOnlyShowSkillUpRecipes = true,
      GetOnlyShowUnlearnedRecipes = true,
      GetOptionalReagentBonusText = true,
      GetOptionalReagentInfo = true,
      GetPendingObliterateItemID = true,
      GetPendingObliterateItemLink = true,
      GetProfessionChildSkillLineID = {
        products = {
          wow_beta = true,
        },
      },
      GetProfessionGearShown = {
        products = {
          wow_beta = true,
        },
      },
      GetProfessionInfoBySkillLineID = {
        products = {
          wow_beta = true,
        },
      },
      GetProfessionSkillLineID = {
        products = {
          wow_beta = true,
        },
      },
      GetProfessionSlots = {
        products = {
          wow_beta = true,
        },
      },
      GetProfessionSpells = {
        products = {
          wow_beta = true,
        },
      },
      GetReagentDifficultyText = {
        products = {
          wow_beta = true,
        },
      },
      GetReagentSlotStatus = {
        products = {
          wow_beta = true,
        },
      },
      GetRecipeCooldown = true,
      GetRecipeDescription = true,
      GetRecipeFixedReagentItemLink = {
        products = {
          wow_beta = true,
        },
      },
      GetRecipeInfo = true,
      GetRecipeItemLevelFilter = true,
      GetRecipeItemLink = true,
      GetRecipeItemNameFilter = true,
      GetRecipeLink = true,
      GetRecipeNumItemsProduced = true,
      GetRecipeNumReagents = true,
      GetRecipeOutputItemData = {
        products = {
          wow_beta = true,
        },
      },
      GetRecipeQualityReagentItemLink = {
        products = {
          wow_beta = true,
        },
      },
      GetRecipeReagentInfo = true,
      GetRecipeReagentItemLink = true,
      GetRecipeRepeatCount = true,
      GetRecipeSchematic = {
        products = {
          wow_beta = true,
        },
      },
      GetRecipeSourceText = true,
      GetRecipeTools = true,
      GetRecipesTracked = {
        products = {
          wow_beta = true,
        },
      },
      GetSalvagableItemIDs = {
        products = {
          wow_beta = true,
        },
      },
      GetSubCategories = true,
      GetTradeSkillDisplayName = true,
      GetTradeSkillLine = true,
      GetTradeSkillLineForRecipe = true,
      GetTradeSkillLineInfoByID = true,
      GetTradeSkillListLink = true,
      GetTradeSkillTexture = true,
      HasRecipesTracked = {
        products = {
          wow_beta = true,
        },
      },
      IsAnyRecipeFromSource = true,
      IsDataSourceChanging = true,
      IsEmptySkillLineCategory = true,
      IsInventorySlotFiltered = true,
      IsNPCCrafting = true,
      IsRecipeCategoryFiltered = true,
      IsRecipeFavorite = true,
      IsRecipeInSkillLine = {
        products = {
          wow_beta = true,
        },
      },
      IsRecipeProfessionLearned = {
        products = {
          wow_beta = true,
        },
      },
      IsRecipeRepeating = true,
      IsRecipeSearchInProgress = true,
      IsRecipeSourceTypeFiltered = true,
      IsRecipeTracked = {
        products = {
          wow_beta = true,
        },
      },
      IsRuneforging = {
        products = {
          wow_beta = true,
        },
      },
      IsTradeSkillGuild = true,
      IsTradeSkillGuildMember = true,
      IsTradeSkillLinked = true,
      IsTradeSkillReady = true,
      ObliterateItem = true,
      OpenRecipe = {
        products = {
          wow_beta = true,
        },
      },
      OpenTradeSkill = true,
      SetInventorySlotFilter = true,
      SetOnlyShowLearnedRecipes = true,
      SetOnlyShowMakeableRecipes = true,
      SetOnlyShowSkillUpRecipes = true,
      SetOnlyShowUnlearnedRecipes = true,
      SetProfessionChildSkillLineID = {
        products = {
          wow_beta = true,
        },
      },
      SetProfessionGearShown = {
        products = {
          wow_beta = true,
        },
      },
      SetRecipeCategoryFilter = true,
      SetRecipeFavorite = true,
      SetRecipeItemLevelFilter = true,
      SetRecipeItemNameFilter = true,
      SetRecipeRepeatCount = true,
      SetRecipeSourceTypeFilter = true,
      SetRecipeTracked = {
        products = {
          wow_beta = true,
        },
      },
      StopRecipeRepeat = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_Traits = {
    methods = {
      CanPurchaseRank = true,
      CanRefundRank = true,
      CloseTraitSystemInteraction = true,
      CommitConfig = true,
      ConfigHasStagedChanges = true,
      GetConditionInfo = true,
      GetConfigIDBySystemID = true,
      GetConfigInfo = true,
      GetConfigsByType = true,
      GetDefinitionInfo = true,
      GetEntryInfo = true,
      GetNodeCost = true,
      GetNodeInfo = true,
      GetStagedChangesCost = true,
      GetTraitCurrencyInfo = true,
      GetTraitDescription = true,
      GetTreeCurrencyInfo = true,
      GetTreeInfo = true,
      GetTreeNodes = true,
      PurchaseRank = true,
      RefundAllRanks = true,
      RefundRank = true,
      ResetTree = true,
      RollbackConfig = true,
      SetSelection = true,
      StageConfig = true,
      TalentTestUnlearnSpells = true,
    },
    products = {
      wow_beta = true,
    },
  },
  C_Transmog = {
    methods = {
      ApplyAllPending = true,
      CanHaveSecondaryAppearanceForSlotID = true,
      CanTransmogItem = true,
      CanTransmogItemWithItem = true,
      ClearAllPending = true,
      ClearPending = true,
      Close = true,
      ExtractTransmogIDList = true,
      GetApplyCost = true,
      GetApplyWarnings = true,
      GetBaseCategory = true,
      GetCreatureDisplayIDForSource = true,
      GetItemIDForSource = true,
      GetPending = true,
      GetSlotEffectiveCategory = true,
      GetSlotForInventoryType = true,
      GetSlotInfo = true,
      GetSlotUseError = true,
      GetSlotVisualInfo = true,
      IsAtTransmogNPC = true,
      IsSlotBeingCollapsed = true,
      LoadOutfit = true,
      SetPending = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_TransmogCollection = {
    methods = {
      AccountCanCollectSource = true,
      AreAllCollectionTypeFiltersChecked = true,
      AreAllSourceTypeFiltersChecked = true,
      CanAppearanceHaveIllusion = true,
      ClearNewAppearance = true,
      ClearSearch = true,
      DeleteOutfit = true,
      EndSearch = true,
      GetAllAppearanceSources = true,
      GetAppearanceCameraID = true,
      GetAppearanceCameraIDBySource = true,
      GetAppearanceInfoBySource = true,
      GetAppearanceSourceDrops = true,
      GetAppearanceSourceInfo = true,
      GetAppearanceSources = true,
      GetArtifactAppearanceStrings = true,
      GetCategoryAppearances = true,
      GetCategoryCollectedCount = true,
      GetCategoryForItem = true,
      GetCategoryInfo = true,
      GetCategoryTotal = true,
      GetCollectedShown = true,
      GetFallbackWeaponAppearance = true,
      GetIllusionInfo = true,
      GetIllusionStrings = true,
      GetIllusions = true,
      GetInspectItemTransmogInfoList = true,
      GetIsAppearanceFavorite = true,
      GetItemInfo = true,
      GetItemTransmogInfoListFromOutfitHyperlink = true,
      GetLatestAppearance = true,
      GetNumMaxOutfits = true,
      GetNumTransmogSources = true,
      GetOutfitHyperlinkFromItemTransmogInfoList = true,
      GetOutfitInfo = true,
      GetOutfitItemTransmogInfoList = true,
      GetOutfits = true,
      GetPairedArtifactAppearance = true,
      GetSourceIcon = true,
      GetSourceInfo = true,
      GetSourceItemID = true,
      GetSourceRequiredHoliday = true,
      GetUncollectedShown = true,
      HasFavorites = true,
      IsAppearanceHiddenVisual = true,
      IsCategoryValidForItem = true,
      IsNewAppearance = true,
      IsSearchDBLoading = true,
      IsSearchInProgress = true,
      IsSourceTypeFilterChecked = true,
      IsUsingDefaultFilters = true,
      ModifyOutfit = true,
      NewOutfit = true,
      PlayerCanCollectSource = true,
      PlayerHasTransmog = true,
      PlayerHasTransmogByItemInfo = true,
      PlayerHasTransmogItemModifiedAppearance = true,
      PlayerKnowsSource = true,
      RenameOutfit = true,
      SearchProgress = true,
      SearchSize = true,
      SetAllCollectionTypeFilters = true,
      SetAllSourceTypeFilters = true,
      SetCollectedShown = true,
      SetDefaultFilters = true,
      SetIsAppearanceFavorite = true,
      SetSearch = true,
      SetSearchAndFilterCategory = true,
      SetSourceTypeFilter = true,
      SetUncollectedShown = true,
      UpdateUsableAppearances = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_TransmogSets = {
    methods = {
      ClearLatestSource = true,
      ClearNewSource = true,
      ClearSetNewSourcesForSlot = true,
      GetAllSets = true,
      GetAllSourceIDs = true,
      GetBaseSetID = true,
      GetBaseSets = true,
      GetBaseSetsCounts = true,
      GetBaseSetsFilter = true,
      GetCameraIDs = true,
      GetIsFavorite = true,
      GetLatestSource = true,
      GetSetInfo = true,
      GetSetNewSources = true,
      GetSetPrimaryAppearances = true,
      GetSetsContainingSourceID = true,
      GetSourceIDsForSlot = true,
      GetSourcesForSlot = true,
      GetUsableSets = true,
      GetVariantSets = true,
      HasUsableSets = true,
      IsBaseSetCollected = true,
      IsNewSource = true,
      IsSetVisible = true,
      IsUsingDefaultBaseSetsFilters = true,
      SetBaseSetsFilter = true,
      SetDefaultBaseSetsFilters = true,
      SetHasNewSources = true,
      SetHasNewSourcesForSlot = true,
      SetIsFavorite = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_Trophy = {
    methods = {
      MonumentChangeAppearanceToTrophyID = true,
      MonumentCloseMonumentUI = true,
      MonumentGetCount = true,
      MonumentGetSelectedTrophyID = true,
      MonumentGetTrophyInfoByIndex = true,
      MonumentLoadList = true,
      MonumentLoadSelectedTrophyID = true,
      MonumentRevertAppearanceToSaved = true,
      MonumentSaveSelection = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_Tutorial = {
    methods = {
      AbandonTutorialArea = true,
      ReturnToTutorialArea = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_UI = {
    methods = {
      DoesAnyDisplayHaveNotch = true,
      GetTopLeftNotchSafeRegion = true,
      GetTopRightNotchSafeRegion = true,
      Reload = true,
      ShouldUIParentAvoidNotch = true,
    },
  },
  C_UIColor = {
    methods = {
      GetColors = true,
    },
    products = {
      wow_beta = true,
    },
  },
  C_UIWidgetManager = {
    methods = {
      GetAllWidgetsBySetID = true,
      GetBelowMinimapWidgetSetID = true,
      GetBulletTextListWidgetVisualizationInfo = true,
      GetCaptureBarWidgetVisualizationInfo = true,
      GetCaptureZoneVisualizationInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetDiscreteProgressStepsVisualizationInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetDoubleIconAndTextWidgetVisualizationInfo = true,
      GetDoubleStateIconRowVisualizationInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetDoubleStatusBarWidgetVisualizationInfo = true,
      GetHorizontalCurrenciesWidgetVisualizationInfo = true,
      GetIconAndTextWidgetVisualizationInfo = true,
      GetIconTextAndBackgroundWidgetVisualizationInfo = true,
      GetIconTextAndCurrenciesWidgetVisualizationInfo = true,
      GetObjectiveTrackerWidgetSetID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPowerBarWidgetSetID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetScenarioHeaderCurrenciesAndBackgroundWidgetVisualizationInfo = true,
      GetScenarioHeaderTimerWidgetVisualizationInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSpacerVisualizationInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSpellDisplayVisualizationInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetStackedResourceTrackerWidgetVisualizationInfo = true,
      GetStatusBarWidgetVisualizationInfo = true,
      GetTextColumnRowVisualizationInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetTextWithStateWidgetVisualizationInfo = true,
      GetTextureAndTextRowVisualizationInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetTextureAndTextVisualizationInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetTextureWithAnimationVisualizationInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetTextureWithStateVisualizationInfo = {
        products = {
          wow_classic = true,
          wow_classic_beta = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
          wow_classic_ptr = true,
        },
      },
      GetTopCenterWidgetSetID = true,
      GetUnitPowerBarWidgetVisualizationInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetWidgetSetInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetZoneControlVisualizationInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RegisterUnitForWidgetUpdates = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetProcessingUnit = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetProcessingUnitGuid = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      UnregisterUnitForWidgetUpdates = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
  },
  C_UnitAuras = {
    methods = {
      GetAuraDataByAuraInstanceID = true,
      GetAuraDataBySlot = true,
      GetCooldownAuraBySpellID = true,
      GetPlayerAuraBySpellID = true,
      IsAuraFilteredOutByInstanceID = true,
    },
    products = {
      wow_beta = true,
    },
  },
  C_UserFeedback = {
    methods = {
      SubmitBug = true,
      SubmitSuggestion = true,
    },
  },
  C_VideoOptions = {
    methods = {
      GetCurrentGameWindowSize = {
        products = {
          wow_beta = true,
        },
      },
      GetDefaultGameWindowSize = {
        products = {
          wow_beta = true,
        },
      },
      GetGameWindowSizes = {
        products = {
          wow_beta = true,
        },
      },
      GetGxAdapterInfo = true,
      SetGameWindowSize = {
        products = {
          wow_beta = true,
        },
      },
    },
  },
  C_VignetteInfo = {
    methods = {
      FindBestUniqueVignette = true,
      GetVignetteInfo = true,
      GetVignettePosition = true,
      GetVignettes = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_VoiceChat = {
    methods = {
      ActivateChannel = true,
      ActivateChannelTranscription = true,
      BeginLocalCapture = true,
      CanPlayerUseVoiceChat = true,
      CreateChannel = true,
      DeactivateChannel = true,
      DeactivateChannelTranscription = true,
      EndLocalCapture = true,
      GetActiveChannelID = true,
      GetActiveChannelType = true,
      GetAvailableInputDevices = true,
      GetAvailableOutputDevices = true,
      GetChannel = true,
      GetChannelForChannelType = true,
      GetChannelForCommunityStream = true,
      GetCommunicationMode = true,
      GetCurrentVoiceChatConnectionStatusCode = true,
      GetInputVolume = true,
      GetJoinClubVoiceChannelError = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetLocalPlayerActiveChannelMemberInfo = true,
      GetLocalPlayerMemberID = true,
      GetMasterVolumeScale = true,
      GetMemberGUID = true,
      GetMemberID = true,
      GetMemberInfo = true,
      GetMemberName = true,
      GetMemberVolume = true,
      GetOutputVolume = true,
      GetPTTButtonPressedState = true,
      GetProcesses = true,
      GetPushToTalkBinding = true,
      GetRemoteTtsVoices = true,
      GetTtsVoices = true,
      GetVADSensitivity = true,
      IsChannelJoinPending = true,
      IsDeafened = true,
      IsEnabled = true,
      IsLoggedIn = true,
      IsMemberLocalPlayer = true,
      IsMemberMuted = true,
      IsMemberMutedForAll = true,
      IsMemberSilenced = true,
      IsMuted = true,
      IsParentalDisabled = true,
      IsParentalMuted = true,
      IsPlayerUsingVoice = true,
      IsSilenced = true,
      IsSpeakForMeActive = true,
      IsSpeakForMeAllowed = true,
      IsTranscriptionAllowed = true,
      IsVoiceChatConnected = {
        products = {
          wow_beta = true,
        },
      },
      LeaveChannel = true,
      Login = true,
      Logout = true,
      MarkChannelsDiscovered = true,
      RequestJoinAndActivateCommunityStreamChannel = true,
      RequestJoinChannelByChannelType = true,
      SetCommunicationMode = true,
      SetDeafened = true,
      SetInputDevice = true,
      SetInputVolume = true,
      SetMasterVolumeScale = true,
      SetMemberMuted = true,
      SetMemberVolume = true,
      SetMuted = true,
      SetOutputDevice = true,
      SetOutputVolume = true,
      SetPortraitTexture = true,
      SetPushToTalkBinding = true,
      SetVADSensitivity = true,
      ShouldDiscoverChannels = true,
      SpeakRemoteTextSample = true,
      SpeakText = true,
      StopSpeakingText = true,
      ToggleDeafened = true,
      ToggleMemberMuted = true,
      ToggleMuted = true,
    },
  },
  C_WeeklyRewards = {
    methods = {
      AreRewardsForCurrentRewardPeriod = true,
      CanClaimRewards = true,
      ClaimReward = true,
      CloseInteraction = true,
      GetActivities = true,
      GetActivityEncounterInfo = true,
      GetConquestWeeklyProgress = true,
      GetExampleRewardItemHyperlinks = true,
      GetItemHyperlink = true,
      GetNextMythicPlusIncrease = true,
      HasAvailableRewards = true,
      HasGeneratedRewards = true,
      HasInteraction = true,
      OnUIInteract = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_Widget = {
    methods = {
      IsFrameWidget = true,
      IsRenderableWidget = true,
      IsWidget = true,
    },
  },
  C_WowTokenPublic = {
    methods = {
      BuyToken = true,
      GetCommerceSystemStatus = true,
      GetCurrentMarketPrice = true,
      GetGuaranteedPrice = true,
      GetListedAuctionableTokenInfo = true,
      GetNumListedAuctionableTokens = true,
      IsAuctionableWowToken = true,
      IsConsumableWowToken = true,
      SellToken = {
        products = {
          wow_classic = true,
          wow_classic_beta = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
          wow_classic_ptr = true,
        },
      },
      UpdateListedAuctionableTokens = true,
      UpdateMarketPrice = true,
      UpdateTokenCount = true,
    },
  },
  C_WowTokenUI = {
    methods = {
      StartTokenSell = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_XMLUtil = {
    methods = {
      GetTemplateInfo = true,
      GetTemplates = true,
    },
    products = {
      wow_beta = true,
    },
  },
  C_ZoneAbility = {
    methods = {
      GetActiveAbilities = true,
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  Kiosk = {
    methods = {
      GetCharacterTemplateSetIndex = true,
      IsEnabled = true,
      ShutdownSession = true,
      StartSession = true,
    },
  },
  bit = {
    methods = {
      arshift = {
        stdlib = 'bit.arshift',
      },
      band = {
        stdlib = 'bit.band',
      },
      bnot = {
        stdlib = 'bit.bnot',
      },
      bor = {
        stdlib = 'bit.bor',
      },
      bxor = {
        stdlib = 'bit.bxor',
      },
      lshift = {
        stdlib = 'bit.lshift',
      },
      mod = {
        stdlib = 'bit.mod',
      },
      rshift = {
        stdlib = 'bit.rshift',
      },
    },
  },
  coroutine = {
    methods = {
      create = {
        stdlib = 'coroutine.create',
      },
      resume = {
        stdlib = 'coroutine.resume',
      },
      running = {
        stdlib = 'coroutine.running',
      },
      status = {
        stdlib = 'coroutine.status',
      },
      wrap = {
        stdlib = 'coroutine.wrap',
      },
      yield = {
        stdlib = 'coroutine.yield',
      },
    },
  },
  math = {
    methods = {
      abs = {
        stdlib = 'math.abs',
      },
      acos = {
        stdlib = 'math.acos',
      },
      asin = {
        stdlib = 'math.asin',
      },
      atan = {
        stdlib = 'math.atan',
      },
      atan2 = {
        stdlib = 'math.atan2',
      },
      ceil = {
        stdlib = 'math.ceil',
      },
      cos = {
        stdlib = 'math.cos',
      },
      cosh = {
        stdlib = 'math.cosh',
      },
      deg = {
        stdlib = 'math.deg',
      },
      exp = {
        stdlib = 'math.exp',
      },
      floor = {
        stdlib = 'math.floor',
      },
      fmod = {
        stdlib = 'math.fmod',
      },
      frexp = {
        stdlib = 'math.frexp',
      },
      huge = {
        stdlib = 'math.huge',
      },
      ldexp = {
        stdlib = 'math.ldexp',
      },
      log = {
        stdlib = 'math.log',
      },
      log10 = {
        stdlib = 'math.log10',
      },
      max = {
        stdlib = 'math.max',
      },
      min = {
        stdlib = 'math.min',
      },
      modf = {
        stdlib = 'math.modf',
      },
      pi = {
        stdlib = 'math.pi',
      },
      pow = {
        stdlib = 'math.pow',
      },
      rad = {
        stdlib = 'math.rad',
      },
      random = {
        stdlib = 'math.random',
      },
      sin = {
        stdlib = 'math.sin',
      },
      sinh = {
        stdlib = 'math.sinh',
      },
      sqrt = {
        stdlib = 'math.sqrt',
      },
      tan = {
        stdlib = 'math.tan',
      },
      tanh = {
        stdlib = 'math.tanh',
      },
    },
  },
  string = {
    methods = {
      byte = {
        stdlib = 'string.byte',
      },
      char = {
        stdlib = 'string.char',
      },
      find = {
        stdlib = 'string.find',
      },
      format = {
        stdlib = 'string.format',
      },
      gfind = {
        stdlib = 'string.gfind',
      },
      gmatch = {
        stdlib = 'string.gmatch',
      },
      gsub = {
        stdlib = 'string.gsub',
      },
      join = {
        stdlib = 'strjoin',
      },
      len = {
        stdlib = 'string.len',
      },
      lower = {
        stdlib = 'string.lower',
      },
      match = {
        stdlib = 'string.match',
      },
      rep = {
        stdlib = 'string.rep',
      },
      reverse = {
        stdlib = 'string.reverse',
      },
      split = {
        stdlib = 'strsplit',
      },
      sub = {
        stdlib = 'string.sub',
      },
      trim = {
        stdlib = 'strtrim',
      },
      upper = {
        stdlib = 'string.upper',
      },
    },
  },
  table = {
    methods = {
      concat = {
        stdlib = 'table.concat',
      },
      foreach = {
        stdlib = 'table.foreach',
      },
      foreachi = {
        stdlib = 'table.foreachi',
      },
      getn = {
        stdlib = 'table.getn',
      },
      insert = {
        stdlib = 'table.insert',
      },
      maxn = {
        stdlib = 'table.maxn',
      },
      remove = {
        stdlib = 'table.remove',
      },
      removemulti = {
        stdlib = 'table.removemulti',
      },
      setn = {
        stdlib = 'table.setn',
      },
      sort = {
        stdlib = 'table.sort',
      },
      wipe = {
        stdlib = 'table.wipe',
      },
    },
  },
}
