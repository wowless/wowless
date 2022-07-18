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
          wowt = true,
        },
      },
      ShouldOverrideBarShowManaBar = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ToggleAutoCastPetAction = true,
    },
  },
  C_AdventureJournal = {
    methods = {
      ActivateEntry = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanBeShown = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumAvailableSuggestions = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPrimaryOffset = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetReward = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSuggestions = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetPrimaryOffset = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      UpdateSuggestions = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_AdventureMap = {
    methods = {
      Close = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMapID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMapInsetDetailTileInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMapInsetInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumMapInsets = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumQuestOffers = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumZoneChoices = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetQuestInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetQuestOfferInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetZoneChoiceInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      StartQuest = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_AlliedRaces = {
    methods = {
      ClearAlliedRaceDetailsGiver = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAllRacialAbilitiesFromID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRaceInfoByID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_AnimaDiversion = {
    methods = {
      CloseUI = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAnimaDiversionNodes = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetOriginPosition = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetReinforceProgress = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetTextureKit = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      OpenAnimaDiversionUI = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SelectAnimaNode = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_ArdenwealdGardening = {
    methods = {
      GetGardenData = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsGardenAccessible = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
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
      AddPower = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ApplyCursorRelicToSlot = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanApplyArtifactRelic = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanApplyCursorRelicToSlot = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanApplyRelicItemIDToEquippedArtifactSlot = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanApplyRelicItemIDToSlot = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CheckRespecNPC = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      Clear = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ClearForgeCamera = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ConfirmRespec = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      DoesEquippedArtifactHaveAnyRelicsSlotted = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAppearanceInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAppearanceInfoByID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAppearanceSetInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetArtifactArtInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetArtifactInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetArtifactItemID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetArtifactTier = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetArtifactXPRewardTargetInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCostForPointAtRank = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetEquippedArtifactArtInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetEquippedArtifactInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetEquippedArtifactItemID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetEquippedArtifactNumRelicSlots = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetEquippedArtifactRelicInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetEquippedRelicLockedReason = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetForgeRotation = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetItemLevelIncreaseProvidedByRelic = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMetaPowerInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumAppearanceSets = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumObtainedArtifacts = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumRelicSlots = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPointsRemaining = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPowerHyperlink = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPowerInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPowerLinks = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPowers = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPowersAffectedByRelic = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPowersAffectedByRelicItemLink = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPreviewAppearance = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRelicInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRelicInfoByItemID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRelicLockedReason = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRelicSlotType = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRespecArtifactArtInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRespecArtifactInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRespecCost = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetTotalPowerCost = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetTotalPurchasedRanks = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsArtifactDisabled = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsAtForge = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsEquippedArtifactDisabled = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsEquippedArtifactMaxed = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsMaxedByRulesOrEffect = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsPowerKnown = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsViewedArtifactEquipped = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetAppearance = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetForgeCamera = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetForgeRotation = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetPreviewAppearance = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ShouldSuppressForgeRotation = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_AuctionHouse = {
    methods = {
      CalculateCommodityDeposit = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CalculateItemDeposit = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanCancelAuction = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CancelAuction = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CancelCommoditiesPurchase = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CancelSell = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CloseAuctionHouse = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ConfirmCommoditiesPurchase = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      FavoritesAreAvailable = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAuctionInfoByID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAuctionItemSubClasses = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAvailablePostCount = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBidInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBidType = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBids = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBrowseResults = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCancelCost = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCommoditySearchResultInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCommoditySearchResultsQuantity = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetExtraBrowseInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFilterGroups = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetItemCommodityStatus = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetItemKeyFromItem = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetItemKeyInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetItemKeyRequiredLevel = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetItemSearchResultInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetItemSearchResultsQuantity = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMaxBidItemBid = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMaxBidItemBuyout = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMaxCommoditySearchResultPrice = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMaxItemSearchResultBid = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMaxItemSearchResultBuyout = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMaxOwnedAuctionBid = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMaxOwnedAuctionBuyout = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumBidTypes = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumBids = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumCommoditySearchResults = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumItemSearchResults = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumOwnedAuctionTypes = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumOwnedAuctions = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumReplicateItems = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetOwnedAuctionInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetOwnedAuctionType = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetOwnedAuctions = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetQuoteDurationRemaining = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetReplicateItemBattlePetInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetReplicateItemInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetReplicateItemLink = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetReplicateItemTimeLeft = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetTimeLeftBandInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      HasFavorites = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      HasFullBidResults = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      HasFullBrowseResults = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      HasFullCommoditySearchResults = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      HasFullItemSearchResults = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      HasFullOwnedAuctionResults = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      HasMaxFavorites = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      HasSearchResults = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsFavoriteItem = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsSellItemValid = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsThrottledMessageSystemReady = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      MakeItemKey = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      PlaceBid = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      PostCommodity = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      PostItem = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      QueryBids = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      QueryOwnedAuctions = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RefreshCommoditySearchResults = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RefreshItemSearchResults = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ReplicateItems = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RequestFavorites = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RequestMoreBrowseResults = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RequestMoreCommoditySearchResults = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RequestMoreItemSearchResults = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RequestOwnedAuctionBidderInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SearchForFavorites = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SearchForItemKeys = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SendBrowseQuery = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SendSearchQuery = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SendSellSearchQuery = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetFavoriteItem = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      StartCommoditiesPurchase = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
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
      ApplyCustomizationChoices = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      Cancel = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ClearPreviewChoices = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAvailableCustomizations = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCurrentCameraZoom = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCurrentCharacterData = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCurrentCost = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      HasAnyChanges = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsViewingAlteredForm = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
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
      PreviewCustomizationChoice = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RandomizeCustomizationChoices = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ResetCameraRotation = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ResetCustomizationChoices = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RotateCamera = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SaveSeenChoices = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetCameraDistanceOffset = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetCameraZoomLevel = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetCustomizationChoice = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetModelDressState = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetSelectedSex = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetViewingAlteredForm = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetViewingShapeshiftForm = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ZoomCamera = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_BattleNet = {
    methods = {
      GetAccountInfoByGUID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAccountInfoByID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFriendAccountInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFriendGameAccountInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFriendNumGameAccounts = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetGameAccountInfoByGUID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetGameAccountInfoByID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
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
      Close = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetHotItem = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetItemInfoByID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetItemInfoByIndex = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumItems = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsViewOnly = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ItemPlaceBid = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RequestItems = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
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
          wow_classic_beta = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
          wow_classic_ptr = true,
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
  C_CampaignInfo = {
    methods = {
      GetAvailableCampaigns = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCampaignChapterInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCampaignID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCampaignInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetChapterIDs = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCurrentChapterID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFailureReason = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetState = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsCampaignQuest = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      UsesNormalQuestIcons = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_ChallengeMode = {
    methods = {
      CanUseKeystoneInCurrentMap = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ClearKeystone = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CloseKeystoneFrame = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetActiveChallengeMapID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetActiveKeystoneInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAffixInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCompletionInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetDeathCount = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetDungeonScoreRarityColor = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetGuildLeaders = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetKeystoneLevelRarityColor = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMapScoreInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMapTable = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMapUIInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetOverallDungeonScore = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPowerLevelDamageHealthMod = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSlottedKeystoneInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSpecificDungeonOverallScoreRarityColor = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSpecificDungeonScoreRarityColor = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      HasSlottedKeystone = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsChallengeModeActive = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RemoveKeystone = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RequestLeaders = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      Reset = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetKeystoneTooltip = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SlotKeystone = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      StartChallengeMode = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
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
          wow_classic_beta = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
          wow_classic_ptr = true,
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
      CloseUI = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetChromieTimeExpansionOption = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetChromieTimeExpansionOptions = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SelectChromieTimeOption = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_ClassColor = {
    methods = {
      GetClassColor = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_ClassTrial = {
    methods = {
      GetClassTrialLogoutTimeSeconds = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsClassTrialCharacter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_ClickBindings = {
    methods = {
      CanSpellBeClickBound = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ExecuteBinding = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBindingType = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetEffectiveInteractionButton = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetProfileInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetStringFromModifiers = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetTutorialShown = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      MakeModifiers = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ResetCurrentProfile = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetProfileByInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetTutorialShown = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
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
      ApplicantAcceptClubInvite = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ApplicantDeclineClubInvite = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CancelMembershipRequest = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CheckAllPlayerApplicantSettings = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ClearAllFinderCache = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ClearClubApplicantsCache = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ClearClubFinderPostingsCache = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      DoesPlayerBelongToClubFromClubGUID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetClubFinderDisableReason = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetClubRecruitmentSettings = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetClubTypeFromFinderGUID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFocusIndexFromFlag = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPlayerApplicantLocaleFlags = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPlayerApplicantSettings = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPlayerClubApplicationStatus = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPlayerSettingsFocusFlagsSelectedCount = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPostingIDFromClubFinderGUID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRecruitingClubInfoFromClubID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRecruitingClubInfoFromFinderGUID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetStatusOfPostingFromClubId = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetTotalMatchingCommunityListSize = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetTotalMatchingGuildListSize = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      HasAlreadyAppliedToLinkedPosting = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      HasPostingBeenDelisted = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsEnabled = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsListingEnabledFromFlags = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsPostingBanned = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      LookupClubPostingFromClubFinderGUID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      PlayerGetClubInvitationList = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      PlayerRequestPendingClubsList = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      PlayerReturnPendingCommunitiesList = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      PlayerReturnPendingGuildsList = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      PostClub = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RequestApplicantList = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RequestClubsList = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RequestMembershipToClub = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RequestNextCommunityPage = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RequestNextGuildPage = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RequestPostingInformationFromClubId = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RequestSubscribedClubPostingIDs = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ResetClubPostingMapCache = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RespondToApplicant = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ReturnClubApplicantList = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ReturnMatchingCommunityList = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ReturnMatchingGuildList = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ReturnPendingClubApplicantList = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SendChatWhisper = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetAllRecruitmentSettings = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetPlayerApplicantLocaleFlags = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetPlayerApplicantSettings = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetRecruitmentLocale = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetRecruitmentSettings = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ShouldShowClubFinder = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
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
  C_ContributionCollector = {
    methods = {
      Close = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      Contribute = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetActive = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAtlases = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBuffs = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetContributionAppearance = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetContributionCollectorsForMap = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetContributionResult = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetDescription = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetManagedContributionsForCreatureID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetName = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetOrderIndex = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRequiredContributionCurrency = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRequiredContributionItem = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRewardQuestID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetState = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      HasPendingContribution = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsAwaitingRewardQuestData = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_CovenantCallings = {
    methods = {
      AreCallingsUnlocked = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RequestCallings = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_CovenantPreview = {
    methods = {
      CloseFromUI = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCovenantInfoForPlayerChoiceResponseID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_CovenantSanctumUI = {
    methods = {
      CanAccessReservoir = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanDepositAnima = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      DepositAnima = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      EndInteraction = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAnimaInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCurrentTalentTreeID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFeatures = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRenownLevel = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRenownLevels = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRenownRewardsForLevel = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSanctumType = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSoulCurrencies = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      HasMaximumRenown = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsPlayerInRenownCatchUpMode = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsWeeklyRenownCapped = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RequestCatchUpState = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_Covenants = {
    methods = {
      GetActiveCovenantID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCovenantData = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCovenantIDs = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
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
          wowt = true,
        },
      },
      GetCurrencyContainerInfo = {
        products = {
          wow = true,
          wow_beta = true,
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
          wow_classic_beta = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
          wow_classic_ptr = true,
        },
      },
      GetCursorCommunitiesStream = {
        products = {
          wow_classic = true,
          wow_classic_beta = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
          wow_classic_ptr = true,
        },
      },
      GetCursorItem = true,
      SetCursorCommunitiesStream = {
        products = {
          wow_classic = true,
          wow_classic_beta = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
          wow_classic_ptr = true,
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
  C_EncounterJournal = {
    methods = {
      GetDungeonEntrancesForMap = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetEncountersOnMap = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetLootInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetLootInfoByIndex = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSectionIconFlags = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSectionInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSlotFilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      InstanceHasLoot = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsEncounterComplete = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ResetSlotFilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetPreviewMythicPlusLevel = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetPreviewPvpTier = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetSlotFilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
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
      GetLevelUpDisplayToastsFromLevel = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNextToastToDisplay = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RemoveCurrentToast = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_FogOfWar = {
    methods = {
      GetFogOfWarForMap = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFogOfWarInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_FrameManager = {
    methods = {
      GetFrameVisibilityState = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
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
      AddFollowerToMission = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      AllowMissionStartAboveSoftCap = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      AreMissionFollowerRequirementsMet = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      AssignFollowerToBuilding = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanGenerateRecruits = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanOpenMissionChest = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanSetRecruitmentPreference = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanSpellTargetFollowerIDWithAddAbility = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanUpgradeGarrison = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CancelConstruction = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CastItemSpellOnFollowerAbility = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CastSpellOnFollower = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CastSpellOnFollowerAbility = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CastSpellOnMission = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ClearCompleteTalent = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CloseArchitect = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CloseGarrisonTradeskillNPC = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CloseMissionNPC = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CloseRecruitmentNPC = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CloseTalentNPC = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CloseTradeskillCrafter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GenerateRecruits = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAllBonusAbilityEffects = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAllEncounterThreats = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAutoCombatDamageClassValues = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAutoMissionBoardState = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAutoMissionEnvironmentEffect = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAutoMissionTargetingInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAutoMissionTargetingInfoForSpell = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAutoTroops = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAvailableMissions = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAvailableRecruits = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBasicMissionInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBuffedFollowersForMission = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBuildingInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBuildingLockInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBuildingSizes = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBuildingSpecInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBuildingTimeRemaining = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBuildingTooltip = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBuildingUpgradeInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBuildings = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBuildingsForPlot = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBuildingsForSize = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetClassSpecCategoryInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCombatAllyMission = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCombatLogSpellInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCompleteMissions = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCompleteTalent = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCurrencyTypes = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCurrentCypherEquipmentLevel = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCurrentGarrTalentTreeFriendshipFactionID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCurrentGarrTalentTreeID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCyphersToNextEquipmentLevel = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerAbilities = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerAbilityAtIndex = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerAbilityAtIndexByID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerAbilityCounterMechanicInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerAbilityCountersForMechanicTypes = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerAbilityDescription = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerAbilityIcon = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerAbilityInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerAbilityIsTrait = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerAbilityLink = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerAbilityName = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerActivationCost = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerAutoCombatSpells = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerAutoCombatStats = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerBiasForMission = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerClassSpec = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerClassSpecAtlas = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerClassSpecByID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerClassSpecName = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerDisplayID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerInfoForBuilding = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerIsTroop = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerItemLevelAverage = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerItems = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerLevel = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerLevelXP = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerLink = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerLinkByID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerMissionCompleteInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerMissionTimeLeft = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerMissionTimeLeftSeconds = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerModelItems = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerName = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerNameByID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerPortraitIconID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerPortraitIconIDByID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerQuality = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerQualityTable = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerRecentlyGainedAbilityIDs = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerRecentlyGainedTraitIDs = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerShipments = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerSoftCap = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerSourceTextByID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerSpecializationAtIndex = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerStatus = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerTraitAtIndex = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerTraitAtIndexByID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerTypeByID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerTypeByMissionID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerUnderBiasReason = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerXP = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerXPTable = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowerZoneSupportAbilities = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowers = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowersSpellsForMission = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFollowersTraitsForMission = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetGarrisonInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetGarrisonPlotsInstancesForMap = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetGarrisonTalentTreeCurrencyTypes = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetGarrisonTalentTreeType = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetGarrisonUpgradeCost = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetInProgressMissions = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetLandingPageGarrisonType = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetLandingPageItems = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetLandingPageShipmentCount = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetLandingPageShipmentInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetLandingPageShipmentInfoByContainerID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetLooseShipments = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMaxCypherEquipmentLevel = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMissionBonusAbilityEffects = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMissionCompleteEncounters = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMissionCost = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMissionDeploymentInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMissionDisplayIDs = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMissionEncounterIconInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMissionLink = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMissionMaxFollowers = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMissionName = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMissionRewardInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMissionSuccessChance = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMissionTexture = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMissionTimes = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMissionUncounteredMechanics = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumActiveFollowers = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumFollowerActivationsRemaining = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumFollowerDailyActivations = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumFollowers = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumFollowersForMechanic = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumFollowersOnMission = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumPendingShipments = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumShipmentCurrencies = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumShipmentReagents = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetOwnedBuildingInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetOwnedBuildingInfoAbbrev = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPartyBuffs = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPartyMentorLevels = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPartyMissionInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPendingShipmentInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPlots = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPlotsForBuilding = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPossibleFollowersForBuilding = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRecruitAbilities = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRecruiterAbilityCategories = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRecruiterAbilityList = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRecruitmentPreferences = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetShipDeathAnimInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetShipmentContainerInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetShipmentItemInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetShipmentReagentCurrencyInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetShipmentReagentInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetShipmentReagentItemLink = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSpecChangeCost = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetTabForPlot = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetTalentInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetTalentPointsSpentInTalentTree = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetTalentTreeIDsByClassID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetTalentTreeInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetTalentTreeResetInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetTalentTreeTalentPointResearchInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetTalentUnlockWorldQuest = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      HasAdventures = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      HasGarrison = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      HasShipyard = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsAboveFollowerSoftCap = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsAtGarrisonMissionNPC = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsEnvironmentCountered = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsFollowerCollected = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsFollowerOnCompletedMission = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsInvasionAvailable = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsMechanicFullyCountered = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsOnGarrisonMap = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsOnShipmentQuestForNPC = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsOnShipyardMap = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsPlayerInGarrison = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsTalentConditionMet = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsUsingPartyGarrison = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsVisitGarrisonAvailable = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      MarkMissionComplete = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      MissionBonusRoll = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      PlaceBuilding = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RecruitFollower = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RegenerateCombatLog = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RemoveFollower = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RemoveFollowerFromBuilding = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RemoveFollowerFromMission = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RenameFollower = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RequestClassSpecCategoryInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RequestGarrisonUpgradeable = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RequestLandingPageShipmentInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RequestShipmentCreation = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RequestShipmentInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ResearchTalent = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RushHealAllFollowers = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RushHealFollower = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SearchForFollower = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetAutoCombatSpellFastForward = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetBuildingActive = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetBuildingSpecialization = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetFollowerFavorite = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetFollowerInactive = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetRecruitmentPreferences = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetUsingPartyGarrison = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ShouldShowMapTab = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ShowFollowerNameInErrorMessage = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      StartMission = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SwapBuildings = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      TargetSpellHasFollowerItemLevelUpgrade = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      TargetSpellHasFollowerReroll = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      TargetSpellHasFollowerTemporaryAbility = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      UpgradeBuilding = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      UpgradeGarrison = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
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
      CanHeirloomUpgradeFromPending = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CreateHeirloom = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetClassAndSpecFilters = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCollectedHeirloomFilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetHeirloomInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetHeirloomItemIDFromDisplayedIndex = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetHeirloomItemIDs = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetHeirloomLink = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetHeirloomMaxUpgradeLevel = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetHeirloomSourceFilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumDisplayedHeirlooms = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumHeirlooms = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumKnownHeirlooms = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetUncollectedHeirloomFilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsItemHeirloom = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsPendingHeirloomUpgrade = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      PlayerHasHeirloom = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetClassAndSpecFilters = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetCollectedHeirloomFilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetHeirloomSourceFilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetSearch = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetUncollectedHeirloomFilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ShouldShowHeirloomHelp = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      UpgradeHeirloom = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_HeirloomInfo = {
    methods = {
      AreAllCollectionFiltersChecked = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      AreAllSourceFiltersChecked = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsHeirloomSourceValid = {
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
      SetAllCollectionFilters = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetAllSourceFilters = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetDefaultFilters = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_IncomingSummon = {
    methods = {
      HasIncomingSummon = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IncomingSummonStatus = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_InvasionInfo = {
    methods = {
      AreInvasionsAvailable = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetInvasionForUiMapID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetInvasionInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetInvasionTimeLeft = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_IslandsQueue = {
    methods = {
      CloseIslandsQueueScreen = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetIslandDifficultyInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetIslandsMaxGroupSize = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetIslandsWeeklyQuestID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      QueueForIsland = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RequestPreloadRewardData = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
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
      ClearPendingItem = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CloseUI = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetChargeInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetItemConversionCurrencyCost = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetItemInteractionInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetItemInteractionSpellId = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      InitializeFrame = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      PerformItemInteraction = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      Reset = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetCorruptionReforgerItemTooltip = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetItemConversionOutputTooltip = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetPendingItem = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
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
          wow_classic_beta = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
          wow_classic_ptr = true,
        },
      },
      GetActivityInfoExpensive = true,
      GetActivityInfoTable = {
        products = {
          wow = true,
          wow_beta = true,
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
          wow_classic_beta = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
          wow_classic_ptr = true,
        },
      },
      RequestAvailableActivities = true,
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
      CloseRuneforgeInteraction = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CraftRuneforgeLegendary = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRuneforgeItemPreviewInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRuneforgeLegendaryComponentInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRuneforgeLegendaryCost = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRuneforgeLegendaryCraftSpellID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRuneforgeLegendaryCurrencies = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRuneforgeLegendaryUpgradeCost = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRuneforgeModifierInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRuneforgeModifiers = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRuneforgePowerInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRuneforgePowerSlots = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRuneforgePowers = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRuneforgePowersByClassSpecAndCovenant = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsRuneforgeLegendary = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsRuneforgeLegendaryMaxLevel = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsUpgradeItemValidForRuneforgeLegendary = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsValidRuneforgeBaseItem = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      MakeRuneforgeCraftDescription = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      UpgradeRuneforgeLegendary = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_LevelLink = {
    methods = {
      IsActionLocked = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsSpellLocked = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_LevelSquish = {
    methods = {
      ConvertFollowerLevel = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ConvertPlayerLevel = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
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
      GetItemSetItems = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetItemSets = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_LoreText = {
    methods = {
      RequestLoreTextForCampaignID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
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
      GetDrawGroundTextures = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetUiMapID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetViewRadius = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsRotateMinimapIgnored = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetDrawGroundTextures = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetIgnoreRotateMinimap = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ShouldUseHybridMinimap = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
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
      GetModifiedInstanceInfoFromMapID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_MountJournal = {
    methods = {
      ApplyMountEquipment = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      AreMountEquipmentEffectsSuppressed = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ClearFanfare = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ClearRecentFanfares = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      Dismiss = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAppliedMountEquipmentID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCollectedFilterSetting = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetDisplayedMountAllCreatureDisplayInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetDisplayedMountInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetDisplayedMountInfoExtra = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetIsFavorite = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMountAllCreatureDisplayInfoByID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMountEquipmentUnlockLevel = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMountFromItem = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMountFromSpell = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMountIDs = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMountInfoByID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMountInfoExtraByID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMountUsabilityByID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumDisplayedMounts = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumMounts = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumMountsNeedingFanfare = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsItemMountEquipment = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsMountEquipmentApplied = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsSourceChecked = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsTypeChecked = {
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
      IsValidSourceFilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsValidTypeFilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      NeedsFanfare = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      Pickup = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetAllSourceFilters = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetAllTypeFilters = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetCollectedFilterSetting = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetDefaultFilters = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetIsFavorite = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetSearch = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetSourceFilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetTypeFilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SummonByID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_MythicPlus = {
    methods = {
      GetCurrentAffixes = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCurrentSeason = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCurrentSeasonValues = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetLastWeeklyBestInformation = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetOwnedKeystoneChallengeMapID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetOwnedKeystoneLevel = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetOwnedKeystoneMapID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRewardLevelForDifficultyLevel = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRewardLevelFromKeystoneLevel = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRunHistory = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSeasonBestAffixScoreInfoForMap = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSeasonBestForMap = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSeasonBestMythicRatingFromThisExpansion = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetWeeklyBestForMap = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetWeeklyChestRewardLevel = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsMythicPlusActive = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsWeeklyRewardAvailable = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RequestCurrentAffixes = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RequestMapInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RequestRewards = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
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
      GetDistance = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFrame = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetTargetState = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      HasValidScreenPosition = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      WasClampedToScreen = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
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
      GetPartyPoseInfoByMapID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_PetBattles = {
    methods = {
      AcceptPVPDuel = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      AcceptQueuedPVPMatch = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanAcceptQueuedPVPMatch = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanActivePetSwapOut = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanPetSwapIn = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CancelPVPDuel = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ChangePet = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      DeclineQueuedPVPMatch = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ForfeitGame = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAbilityEffectInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAbilityInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAbilityInfoByID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAbilityProcTurnIndex = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAbilityState = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAbilityStateModification = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetActivePet = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAllEffectNames = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAllStates = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAttackModifier = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAuraInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBattleState = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBreedQuality = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetDisplayID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetForfeitPenalty = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetHealth = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetIcon = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetLevel = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMaxHealth = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetName = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumAuras = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumPets = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPVPMatchmakingInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPetSpeciesID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPetType = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPlayerTrapAbility = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPower = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSelectedAction = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSpeed = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetStateValue = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetTurnTimeInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetXP = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsInBattle = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsPlayerNPC = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsSkipAvailable = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsTrapAvailable = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsWaitingOnOpponent = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsWildBattle = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetPendingReportBattlePetTarget = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetPendingReportTargetFromUnit = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ShouldShowPetSelect = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SkipTurn = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      StartPVPDuel = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      StartPVPMatchmaking = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      StopPVPMatchmaking = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      UseAbility = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      UseTrap = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_PetInfo = {
    methods = {
      GetPetTamersForMap = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_PetJournal = {
    methods = {
      CagePetByID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ClearFanfare = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ClearRecentFanfares = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ClearSearchFilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      FindPetIDByName = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBattlePetLink = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetDisplayIDByIndex = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetDisplayProbabilityByIndex = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumCollectedInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumDisplays = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumPetSources = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumPetTypes = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumPets = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumPetsNeedingFanfare = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetOwnedBattlePetString = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPetAbilityInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPetAbilityList = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPetAbilityListTable = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPetCooldownByGUID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPetInfoByIndex = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPetInfoByItemID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPetInfoByPetID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPetInfoBySpeciesID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPetInfoTableByPetID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPetLoadOutInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPetModelSceneInfoBySpeciesID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPetSortParameter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPetStats = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPetSummonInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPetTeamAverageLevel = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSummonBattlePetCooldown = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSummonRandomFavoritePetGUID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSummonedPetGUID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsFilterChecked = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsFindBattleEnabled = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsJournalReadOnly = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsJournalUnlocked = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsPetSourceChecked = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsPetTypeChecked = {
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
      PetCanBeReleased = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      PetIsCapturable = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      PetIsFavorite = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      PetIsHurt = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      PetIsLockedForConvert = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      PetIsRevoked = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      PetIsSlotted = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      PetIsSummonable = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      PetIsTradable = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      PetIsUsable = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      PetNeedsFanfare = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      PetUsesRandomDisplay = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      PickupPet = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      PickupSummonRandomPet = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ReleasePetByID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetAbility = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetAllPetSourcesChecked = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetAllPetTypesChecked = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetCustomName = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetDefaultFilters = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetFavorite = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetFilterChecked = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetPetLoadOutInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetPetSortParameter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetPetSourceChecked = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetPetTypeFilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetSearchFilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SummonPetByGUID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SummonRandomPet = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_PlayerChoice = {
    methods = {
      GetCurrentPlayerChoiceInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumRerolls = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRemainingTime = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsWaitingForPlayerChoiceResponse = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      OnUIClosed = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RequestRerollPlayerChoice = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SendPlayerChoiceResponse = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
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
      GetMentorLevelRequirement = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMentorRequirements = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMentorshipStatus = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsActivePlayerConsideredNewcomer = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsMentorRestricted = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_ProductChoice = {
    methods = {
      GetChoices = {
        products = {
          wow_classic = true,
          wow_classic_beta = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
          wow_classic_ptr = true,
        },
      },
      GetNumSuppressed = {
        products = {
          wow_classic = true,
          wow_classic_beta = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
          wow_classic_ptr = true,
        },
      },
      GetProducts = {
        products = {
          wow_classic = true,
          wow_classic_beta = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
          wow_classic_ptr = true,
        },
      },
      MakeSelection = {
        products = {
          wow_classic = true,
          wow_classic_beta = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
          wow_classic_ptr = true,
        },
      },
    },
    products = {
      wow_classic = true,
      wow_classic_beta = true,
      wow_classic_era = true,
      wow_classic_era_ptr = true,
      wow_classic_ptr = true,
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
      GetRandomBGRewards = {
        products = {
          wow = true,
          wow_beta = true,
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
  C_QuestLine = {
    methods = {
      GetAvailableQuestLines = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetQuestLineInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetQuestLineQuests = {
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
      RequestQuestLinesForMap = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
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
      ClaimActivityReward = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ClaimNextReward = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GenerateRecruitmentLink = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRAFInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRAFSystemInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRecruitActivityRequirementsText = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRecruitInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsEnabled = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsRecruitingEnabled = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RemoveRAFRecruit = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RequestUpdatedRecruitmentInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
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
          wowt = true,
        },
      },
      GetMajorCategoryString = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMinorCategoriesForReportTypeAndMajorCategory = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetMinorCategoryString = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      InitiateReportPlayer = {
        products = {
          wow_classic = true,
          wow_classic_beta = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
          wow_classic_ptr = true,
        },
      },
      OpenReportPlayerDialog = {
        products = {
          wow_classic = true,
          wow_classic_beta = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
          wow_classic_ptr = true,
        },
      },
      ReportServerLag = true,
      ReportStuckInCombat = true,
      SendReport = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SendReportPlayer = {
        products = {
          wow_classic = true,
          wow_classic_beta = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
          wow_classic_ptr = true,
        },
      },
      SetPendingReportPetTarget = {
        products = {
          wow_classic = true,
          wow_classic_beta = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
          wow_classic_ptr = true,
        },
      },
      SetPendingReportTarget = {
        products = {
          wow_classic = true,
          wow_classic_beta = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
          wow_classic_ptr = true,
        },
      },
      SetPendingReportTargetByGuid = {
        products = {
          wow_classic = true,
          wow_classic_beta = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
          wow_classic_ptr = true,
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
      GetDigSitesForMap = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_Scenario = {
    methods = {
      GetBonusStepRewardQuestID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBonusSteps = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCriteriaInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCriteriaInfoByStep = {
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
      GetProvingGroundsInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetScenarioIconInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetStepInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSupersededObjectives = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsInScenario = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ShouldShowCriteria = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      TreatScenarioAsDungeon = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_ScenarioInfo = {
    methods = {
      GetJailersTowerTypeString = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetScenarioInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetScenarioStepInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_ScrappingMachineUI = {
    methods = {
      CloseScrappingMachine = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      DropPendingScrapItemFromCursor = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCurrentPendingScrapItemLocationByIndex = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetScrapSpellID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetScrappingMachineName = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      HasScrappableItems = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RemoveAllScrapItems = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RemoveCurrentScrappingItem = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RemoveItemToScrap = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ScrapItems = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetScrappingMachine = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ValidateScrappingList = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
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
      GetActiveSeason = {
        products = {
          wow_classic = true,
          wow_classic_beta = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
          wow_classic_ptr = true,
        },
      },
      HasActiveSeason = {
        products = {
          wow_classic = true,
          wow_classic_beta = true,
          wow_classic_era = true,
          wow_classic_era_ptr = true,
          wow_classic_ptr = true,
        },
      },
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
      GetAllGroups = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetConfig = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetGroupForPlayer = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetGroupInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetGroupMembers = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetGroupQueues = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RequestToJoin = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SignalToastDisplayed = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
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
      ActivateSoulbind = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanActivateSoulbind = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanModifySoulbind = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanResetConduitsInSoulbind = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanSwitchActiveSoulbindTreeBranch = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CloseUI = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CommitPendingConduitsInSoulbind = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      FindNodeIDActuallyInstalled = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      FindNodeIDAppearingInstalled = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      FindNodeIDPendingInstall = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      FindNodeIDPendingUninstall = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetActiveSoulbindID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetConduitCollection = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetConduitCollectionCount = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetConduitCollectionData = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetConduitCollectionDataAtCursor = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetConduitCollectionDataByVirtualID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetConduitDisplayed = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetConduitHyperlink = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetConduitIDPendingInstall = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetConduitQuality = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetConduitRank = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetConduitSpellID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetInstalledConduitID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNode = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSoulbindData = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSpecsAssignedToSoulbind = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetTree = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      HasAnyInstalledConduitInSoulbind = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      HasAnyPendingConduits = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      HasPendingConduitsInSoulbind = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsConduitInstalled = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsConduitInstalledInSoulbind = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsItemConduitByItemInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsNodePendingModify = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsUnselectedConduitPendingInSoulbind = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ModifyNode = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SelectNode = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      UnmodifyNode = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_SpecializationInfo = {
    methods = {
      CanPlayerUsePVPTalentUI = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanPlayerUseTalentSpecUI = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanPlayerUseTalentUI = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAllSelectedPvpTalentIDs = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetInspectSelectedPvpTalent = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPvpTalentAlertStatus = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPvpTalentSlotInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPvpTalentSlotUnlockLevel = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPvpTalentUnlockLevel = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSpecIDs = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSpellsDisplay = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsInitialized = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsPvpTalentLocked = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      MatchesCurrentSpecSet = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetPvpTalentLocked = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
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
      ContainsAnyDisenchantSpell = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCurrentLevelSpells = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSkillLineIndexByID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSpellInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSpellLinkFromSpellID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsSpellDisabled = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_SplashScreen = {
    methods = {
      AcknowledgeSplash = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanViewSplashScreen = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RequestLatestSplashScreen = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
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
      GetHighestPrioritySuperTrackingType = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSuperTrackedQuestID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsSuperTrackingAnything = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsSuperTrackingCorpse = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsSuperTrackingQuest = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsSuperTrackingUserWaypoint = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetSuperTrackedQuestID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetSuperTrackedUserWaypoint = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
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
    },
  },
  C_Timer = {
    methods = {
      After = true,
    },
  },
  C_ToyBox = {
    methods = {
      ForceToyRefilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCollectedShown = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetIsFavorite = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumFilteredToys = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumLearnedDisplayedToys = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumTotalDisplayedToys = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumToys = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetToyFromIndex = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetToyInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetToyLink = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetUncollectedShown = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetUnusableShown = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      HasFavorites = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsExpansionTypeFilterChecked = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsSourceTypeFilterChecked = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsToyUsable = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      PickupToyBoxItem = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetAllExpansionTypeFilters = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetAllSourceTypeFilters = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetCollectedShown = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetExpansionTypeFilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetFilterString = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetIsFavorite = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetSourceTypeFilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetUncollectedShown = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetUnusableShown = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
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
      AnyRecipeCategoriesFiltered = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      AreAnyInventorySlotsFiltered = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanObliterateCursorItem = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanTradeSkillListLink = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ClearInventorySlotFilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ClearPendingObliterateItem = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ClearRecipeCategoryFilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ClearRecipeSourceTypeFilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CloseObliterumForge = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CloseTradeSkill = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CraftRecipe = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      DropPendingObliterateItemFromCursor = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAllFilterableInventorySlots = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAllProfessionTradeSkillLines = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAllRecipeIDs = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCategories = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCategoryInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFilterableInventorySlots = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFilteredRecipeIDs = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetObliterateSpellID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetOnlyShowLearnedRecipes = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetOnlyShowMakeableRecipes = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetOnlyShowSkillUpRecipes = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetOnlyShowUnlearnedRecipes = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetOptionalReagentBonusText = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetOptionalReagentInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPendingObliterateItemID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPendingObliterateItemLink = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRecipeCooldown = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRecipeDescription = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRecipeInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRecipeItemLevelFilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRecipeItemLink = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRecipeItemNameFilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRecipeLink = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRecipeNumItemsProduced = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRecipeNumReagents = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRecipeReagentInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRecipeReagentItemLink = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRecipeRepeatCount = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRecipeSourceText = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetRecipeTools = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSubCategories = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetTradeSkillDisplayName = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetTradeSkillLine = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetTradeSkillLineForRecipe = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetTradeSkillLineInfoByID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetTradeSkillListLink = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetTradeSkillTexture = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsAnyRecipeFromSource = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsDataSourceChanging = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsEmptySkillLineCategory = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsInventorySlotFiltered = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsNPCCrafting = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsRecipeCategoryFiltered = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsRecipeFavorite = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsRecipeRepeating = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsRecipeSearchInProgress = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsRecipeSourceTypeFiltered = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsTradeSkillGuild = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsTradeSkillGuildMember = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsTradeSkillLinked = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsTradeSkillReady = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ObliterateItem = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      OpenTradeSkill = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetInventorySlotFilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetOnlyShowLearnedRecipes = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetOnlyShowMakeableRecipes = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetOnlyShowSkillUpRecipes = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetOnlyShowUnlearnedRecipes = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetRecipeCategoryFilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetRecipeFavorite = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetRecipeItemLevelFilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetRecipeItemNameFilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetRecipeRepeatCount = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetRecipeSourceTypeFilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      StopRecipeRepeat = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_Transmog = {
    methods = {
      ApplyAllPending = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanHaveSecondaryAppearanceForSlotID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanTransmogItem = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanTransmogItemWithItem = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ClearAllPending = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ClearPending = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      Close = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ExtractTransmogIDList = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetApplyCost = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetApplyWarnings = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBaseCategory = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCreatureDisplayIDForSource = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetItemIDForSource = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPending = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSlotEffectiveCategory = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSlotForInventoryType = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSlotInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSlotUseError = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSlotVisualInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsAtTransmogNPC = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsSlotBeingCollapsed = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      LoadOutfit = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetPending = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_TransmogCollection = {
    methods = {
      AccountCanCollectSource = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      AreAllCollectionTypeFiltersChecked = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      AreAllSourceTypeFiltersChecked = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanAppearanceHaveIllusion = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ClearNewAppearance = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ClearSearch = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      DeleteOutfit = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      EndSearch = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAllAppearanceSources = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAppearanceCameraID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAppearanceCameraIDBySource = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAppearanceInfoBySource = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAppearanceSourceDrops = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAppearanceSourceInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAppearanceSources = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetArtifactAppearanceStrings = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCategoryAppearances = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCategoryCollectedCount = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCategoryForItem = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCategoryInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCategoryTotal = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCollectedShown = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetFallbackWeaponAppearance = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetIllusionInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetIllusionStrings = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetIllusions = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetInspectItemTransmogInfoList = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetIsAppearanceFavorite = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetItemInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetItemTransmogInfoListFromOutfitHyperlink = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetLatestAppearance = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumMaxOutfits = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNumTransmogSources = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetOutfitHyperlinkFromItemTransmogInfoList = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetOutfitInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetOutfitItemTransmogInfoList = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetOutfits = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetPairedArtifactAppearance = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSourceIcon = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSourceInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSourceItemID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSourceRequiredHoliday = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetUncollectedShown = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      HasFavorites = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsAppearanceHiddenVisual = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsCategoryValidForItem = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsNewAppearance = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsSearchDBLoading = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsSearchInProgress = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsSourceTypeFilterChecked = {
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
      ModifyOutfit = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      NewOutfit = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      PlayerCanCollectSource = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      PlayerHasTransmog = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      PlayerHasTransmogByItemInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      PlayerHasTransmogItemModifiedAppearance = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      PlayerKnowsSource = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      RenameOutfit = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SearchProgress = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SearchSize = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetAllCollectionTypeFilters = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetAllSourceTypeFilters = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetCollectedShown = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetDefaultFilters = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetIsAppearanceFavorite = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetSearch = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetSearchAndFilterCategory = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetSourceTypeFilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetUncollectedShown = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      UpdateUsableAppearances = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_TransmogSets = {
    methods = {
      ClearLatestSource = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ClearNewSource = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ClearSetNewSourcesForSlot = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAllSets = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetAllSourceIDs = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBaseSetID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBaseSets = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBaseSetsCounts = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetBaseSetsFilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetCameraIDs = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetIsFavorite = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetLatestSource = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSetInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSetNewSources = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSetPrimaryAppearances = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSetsContainingSourceID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSourceIDsForSlot = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetSourcesForSlot = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetUsableSets = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetVariantSets = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      HasUsableSets = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsBaseSetCollected = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsNewSource = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsSetVisible = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      IsUsingDefaultBaseSetsFilters = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetBaseSetsFilter = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetDefaultBaseSetsFilters = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetHasNewSources = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetHasNewSourcesForSlot = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      SetIsFavorite = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_Trophy = {
    methods = {
      MonumentChangeAppearanceToTrophyID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      MonumentCloseMonumentUI = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      MonumentGetCount = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      MonumentGetSelectedTrophyID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      MonumentGetTrophyInfoByIndex = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      MonumentLoadList = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      MonumentLoadSelectedTrophyID = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      MonumentRevertAppearanceToSaved = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      MonumentSaveSelection = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_Tutorial = {
    methods = {
      AbandonTutorialArea = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ReturnToTutorialArea = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
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
  C_UserFeedback = {
    methods = {
      SubmitBug = true,
      SubmitSuggestion = true,
    },
  },
  C_VideoOptions = {
    methods = {
      GetGxAdapterInfo = true,
    },
  },
  C_VignetteInfo = {
    methods = {
      FindBestUniqueVignette = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetVignetteInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetVignettePosition = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetVignettes = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
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
      AreRewardsForCurrentRewardPeriod = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CanClaimRewards = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      ClaimReward = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      CloseInteraction = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetActivities = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetActivityEncounterInfo = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetConquestWeeklyProgress = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetExampleRewardItemHyperlinks = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetItemHyperlink = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      GetNextMythicPlusIncrease = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      HasAvailableRewards = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      HasGeneratedRewards = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      HasInteraction = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
      OnUIInteract = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
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
      StartTokenSell = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
    },
    products = {
      wow = true,
      wow_beta = true,
      wowt = true,
    },
  },
  C_ZoneAbility = {
    methods = {
      GetActiveAbilities = {
        products = {
          wow = true,
          wow_beta = true,
          wowt = true,
        },
      },
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
        stdlib = { _G.bit.arshift },
      },
      band = {
        stdlib = { _G.bit.band },
      },
      bnot = {
        stdlib = { _G.bit.bnot },
      },
      bor = {
        stdlib = { _G.bit.bor },
      },
      bxor = {
        stdlib = { _G.bit.bxor },
      },
      lshift = {
        stdlib = { _G.bit.lshift },
      },
      mod = {
        stdlib = { _G.bit.mod },
      },
      rshift = {
        stdlib = { _G.bit.rshift },
      },
    },
  },
  coroutine = {
    methods = {
      create = {
        stdlib = { _G.coroutine.create },
      },
      resume = {
        stdlib = { _G.coroutine.resume },
      },
      running = {
        stdlib = { _G.coroutine.running },
      },
      status = {
        stdlib = { _G.coroutine.status },
      },
      wrap = {
        stdlib = { _G.coroutine.wrap },
      },
      yield = {
        stdlib = { _G.coroutine.yield },
      },
    },
  },
  math = {
    methods = {
      abs = {
        stdlib = { _G.math.abs },
      },
      acos = {
        stdlib = { _G.math.acos },
      },
      asin = {
        stdlib = { _G.math.asin },
      },
      atan = {
        stdlib = { _G.math.atan },
      },
      atan2 = {
        stdlib = { _G.math.atan2 },
      },
      ceil = {
        stdlib = { _G.math.ceil },
      },
      cos = {
        stdlib = { _G.math.cos },
      },
      cosh = {
        stdlib = { _G.math.cosh },
      },
      deg = {
        stdlib = { _G.math.deg },
      },
      exp = {
        stdlib = { _G.math.exp },
      },
      floor = {
        stdlib = { _G.math.floor },
      },
      fmod = {
        stdlib = { _G.math.fmod },
      },
      frexp = {
        stdlib = { _G.math.frexp },
      },
      huge = {
        stdlib = { _G.math.huge },
      },
      ldexp = {
        stdlib = { _G.math.ldexp },
      },
      log = {
        stdlib = { _G.math.log },
      },
      log10 = {
        stdlib = { _G.math.log10 },
      },
      max = {
        stdlib = { _G.math.max },
      },
      min = {
        stdlib = { _G.math.min },
      },
      modf = {
        stdlib = { _G.math.modf },
      },
      pi = {
        stdlib = { _G.math.pi },
      },
      pow = {
        stdlib = { _G.math.pow },
      },
      rad = {
        stdlib = { _G.math.rad },
      },
      random = {
        stdlib = { _G.math.random },
      },
      sin = {
        stdlib = { _G.math.sin },
      },
      sinh = {
        stdlib = { _G.math.sinh },
      },
      sqrt = {
        stdlib = { _G.math.sqrt },
      },
      tan = {
        stdlib = { _G.math.tan },
      },
      tanh = {
        stdlib = { _G.math.tanh },
      },
    },
  },
  string = {
    methods = {
      byte = {
        stdlib = { _G.string.byte },
      },
      char = {
        stdlib = { _G.string.char },
      },
      find = {
        stdlib = { _G.string.find },
      },
      format = {
        stdlib = { _G.string.format },
      },
      gfind = {
        stdlib = { _G.string.gfind },
      },
      gmatch = {
        stdlib = { _G.string.gmatch },
      },
      gsub = {
        stdlib = { _G.string.gsub },
      },
      join = {
        stdlib = { _G.strjoin },
      },
      len = {
        stdlib = { _G.string.len },
      },
      lower = {
        stdlib = { _G.string.lower },
      },
      match = {
        stdlib = { _G.string.match },
      },
      rep = {
        stdlib = { _G.string.rep },
      },
      reverse = {
        stdlib = { _G.string.reverse },
      },
      split = {
        stdlib = { _G.strsplit },
      },
      sub = {
        stdlib = { _G.string.sub },
      },
      trim = {
        stdlib = { _G.strtrim },
      },
      upper = {
        stdlib = { _G.string.upper },
      },
    },
  },
  table = {
    methods = {
      concat = {
        stdlib = { _G.table.concat },
      },
      foreach = {
        stdlib = { _G.table.foreach },
      },
      foreachi = {
        stdlib = { _G.table.foreachi },
      },
      getn = {
        stdlib = { _G.table.getn },
      },
      insert = {
        stdlib = { _G.table.insert },
      },
      maxn = {
        stdlib = { _G.table.maxn },
      },
      remove = {
        stdlib = { _G.table.remove },
      },
      removemulti = {
        stdlib = { _G.table.removemulti },
      },
      setn = {
        stdlib = { _G.table.setn },
      },
      sort = {
        stdlib = { _G.table.sort },
      },
      wipe = {
        stdlib = { _G.table.wipe },
      },
    },
  },
}
