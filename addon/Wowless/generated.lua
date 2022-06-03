local _, G = ...
local assertEquals = _G.assertEquals
local GetObjectType = CreateFrame('Frame').GetObjectType
function G.GeneratedTests()
  return {
    apiNamespaces = function()
      return {
        C_AccountInfo = function()
          local ns = _G.C_AccountInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetIDFromBattleNetAccountGUID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetIDFromBattleNetAccountGUID))
                return
              end
              assertEquals('function', type(ns.GetIDFromBattleNetAccountGUID))
            end,
            IsGUIDBattleNetAccountType = function()
              assertEquals('function', type(ns.IsGUIDBattleNetAccountType))
            end,
            IsGUIDRelatedToLocalAccount = function()
              assertEquals('function', type(ns.IsGUIDRelatedToLocalAccount))
            end,
          }
        end,
        C_AchievementInfo = function()
          local ns = _G.C_AchievementInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetRewardItemID = function()
              assertEquals('function', type(ns.GetRewardItemID))
            end,
            GetSupercedingAchievements = function()
              assertEquals('function', type(ns.GetSupercedingAchievements))
            end,
            IsValidAchievement = function()
              assertEquals('function', type(ns.IsValidAchievement))
            end,
            SetPortraitTexture = function()
              assertEquals('function', type(ns.SetPortraitTexture))
            end,
          }
        end,
        C_ActionBar = function()
          local ns = _G.C_ActionBar
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            FindFlyoutActionButtons = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.FindFlyoutActionButtons))
                return
              end
              assertEquals('function', type(ns.FindFlyoutActionButtons))
            end,
            FindPetActionButtons = function()
              assertEquals('function', type(ns.FindPetActionButtons))
            end,
            FindSpellActionButtons = function()
              assertEquals('function', type(ns.FindSpellActionButtons))
            end,
            GetBonusBarIndexForSlot = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetBonusBarIndexForSlot))
                return
              end
              assertEquals('function', type(ns.GetBonusBarIndexForSlot))
            end,
            GetPetActionPetBarIndices = function()
              assertEquals('function', type(ns.GetPetActionPetBarIndices))
            end,
            HasFlyoutActionButtons = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.HasFlyoutActionButtons))
                return
              end
              assertEquals('function', type(ns.HasFlyoutActionButtons))
            end,
            HasPetActionButtons = function()
              assertEquals('function', type(ns.HasPetActionButtons))
            end,
            HasPetActionPetBarIndices = function()
              assertEquals('function', type(ns.HasPetActionPetBarIndices))
            end,
            HasSpellActionButtons = function()
              assertEquals('function', type(ns.HasSpellActionButtons))
            end,
            IsAutoCastPetAction = function()
              assertEquals('function', type(ns.IsAutoCastPetAction))
            end,
            IsEnabledAutoCastPetAction = function()
              assertEquals('function', type(ns.IsEnabledAutoCastPetAction))
            end,
            IsHarmfulAction = function()
              assertEquals('function', type(ns.IsHarmfulAction))
            end,
            IsHelpfulAction = function()
              assertEquals('function', type(ns.IsHelpfulAction))
            end,
            IsOnBarOrSpecialBar = function()
              assertEquals('function', type(ns.IsOnBarOrSpecialBar))
            end,
            PutActionInSlot = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.PutActionInSlot))
                return
              end
              assertEquals('function', type(ns.PutActionInSlot))
            end,
            ShouldOverrideBarShowHealthBar = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ShouldOverrideBarShowHealthBar))
                return
              end
              assertEquals('function', type(ns.ShouldOverrideBarShowHealthBar))
            end,
            ShouldOverrideBarShowManaBar = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ShouldOverrideBarShowManaBar))
                return
              end
              assertEquals('function', type(ns.ShouldOverrideBarShowManaBar))
            end,
            ToggleAutoCastPetAction = function()
              assertEquals('function', type(ns.ToggleAutoCastPetAction))
            end,
          }
        end,
        C_AdventureJournal = function()
          local ns = _G.C_AdventureJournal
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            CanBeShown = function()
              assertEquals('function', type(ns.CanBeShown))
            end,
          }
        end,
        C_AdventureMap = function()
          local ns = _G.C_AdventureMap
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            Close = function()
              assertEquals('function', type(ns.Close))
            end,
          }
        end,
        C_AlliedRaces = function()
          local ns = _G.C_AlliedRaces
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            ClearAlliedRaceDetailsGiver = function()
              assertEquals('function', type(ns.ClearAlliedRaceDetailsGiver))
            end,
            GetAllRacialAbilitiesFromID = function()
              assertEquals('function', type(ns.GetAllRacialAbilitiesFromID))
            end,
            GetRaceInfoByID = function()
              assertEquals('function', type(ns.GetRaceInfoByID))
            end,
          }
        end,
        C_AnimaDiversion = function()
          local ns = _G.C_AnimaDiversion
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            CloseUI = function()
              assertEquals('function', type(ns.CloseUI))
            end,
            GetAnimaDiversionNodes = function()
              assertEquals('function', type(ns.GetAnimaDiversionNodes))
            end,
            GetOriginPosition = function()
              assertEquals('function', type(ns.GetOriginPosition))
            end,
            GetReinforceProgress = function()
              assertEquals('function', type(ns.GetReinforceProgress))
            end,
            GetTextureKit = function()
              assertEquals('function', type(ns.GetTextureKit))
            end,
            OpenAnimaDiversionUI = function()
              assertEquals('function', type(ns.OpenAnimaDiversionUI))
            end,
            SelectAnimaNode = function()
              assertEquals('function', type(ns.SelectAnimaNode))
            end,
          }
        end,
        C_ArdenwealdGardening = function()
          local ns = _G.C_ArdenwealdGardening
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetGardenData = function()
              assertEquals('function', type(ns.GetGardenData))
            end,
            IsGardenAccessible = function()
              assertEquals('function', type(ns.IsGardenAccessible))
            end,
          }
        end,
        C_AreaPoiInfo = function()
          local ns = _G.C_AreaPoiInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetAreaPOIForMap = function()
              assertEquals('function', type(ns.GetAreaPOIForMap))
            end,
            GetAreaPOIInfo = function()
              assertEquals('function', type(ns.GetAreaPOIInfo))
            end,
            GetAreaPOISecondsLeft = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetAreaPOISecondsLeft))
                return
              end
              assertEquals('function', type(ns.GetAreaPOISecondsLeft))
            end,
            GetAreaPOITimeLeft = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetAreaPOITimeLeft))
                return
              end
              assertEquals('function', type(ns.GetAreaPOITimeLeft))
            end,
            IsAreaPOITimed = function()
              assertEquals('function', type(ns.IsAreaPOITimed))
            end,
          }
        end,
        C_ArtifactUI = function()
          local ns = _G.C_ArtifactUI
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            AddPower = function()
              assertEquals('function', type(ns.AddPower))
            end,
            ApplyCursorRelicToSlot = function()
              assertEquals('function', type(ns.ApplyCursorRelicToSlot))
            end,
            CanApplyArtifactRelic = function()
              assertEquals('function', type(ns.CanApplyArtifactRelic))
            end,
            CanApplyCursorRelicToSlot = function()
              assertEquals('function', type(ns.CanApplyCursorRelicToSlot))
            end,
            CanApplyRelicItemIDToEquippedArtifactSlot = function()
              assertEquals('function', type(ns.CanApplyRelicItemIDToEquippedArtifactSlot))
            end,
            CanApplyRelicItemIDToSlot = function()
              assertEquals('function', type(ns.CanApplyRelicItemIDToSlot))
            end,
            CheckRespecNPC = function()
              assertEquals('function', type(ns.CheckRespecNPC))
            end,
            Clear = function()
              assertEquals('function', type(ns.Clear))
            end,
            ClearForgeCamera = function()
              assertEquals('function', type(ns.ClearForgeCamera))
            end,
            ConfirmRespec = function()
              assertEquals('function', type(ns.ConfirmRespec))
            end,
            DoesEquippedArtifactHaveAnyRelicsSlotted = function()
              assertEquals('function', type(ns.DoesEquippedArtifactHaveAnyRelicsSlotted))
            end,
            GetAppearanceInfo = function()
              assertEquals('function', type(ns.GetAppearanceInfo))
            end,
            GetAppearanceInfoByID = function()
              assertEquals('function', type(ns.GetAppearanceInfoByID))
            end,
            GetAppearanceSetInfo = function()
              assertEquals('function', type(ns.GetAppearanceSetInfo))
            end,
            GetArtifactArtInfo = function()
              assertEquals('function', type(ns.GetArtifactArtInfo))
            end,
            GetArtifactInfo = function()
              assertEquals('function', type(ns.GetArtifactInfo))
            end,
            GetArtifactItemID = function()
              assertEquals('function', type(ns.GetArtifactItemID))
            end,
            GetArtifactTier = function()
              assertEquals('function', type(ns.GetArtifactTier))
            end,
            GetArtifactXPRewardTargetInfo = function()
              assertEquals('function', type(ns.GetArtifactXPRewardTargetInfo))
            end,
            GetCostForPointAtRank = function()
              assertEquals('function', type(ns.GetCostForPointAtRank))
            end,
            GetEquippedArtifactArtInfo = function()
              assertEquals('function', type(ns.GetEquippedArtifactArtInfo))
            end,
            GetEquippedArtifactInfo = function()
              assertEquals('function', type(ns.GetEquippedArtifactInfo))
            end,
            GetEquippedArtifactItemID = function()
              assertEquals('function', type(ns.GetEquippedArtifactItemID))
            end,
            GetEquippedArtifactNumRelicSlots = function()
              assertEquals('function', type(ns.GetEquippedArtifactNumRelicSlots))
            end,
            GetEquippedArtifactRelicInfo = function()
              assertEquals('function', type(ns.GetEquippedArtifactRelicInfo))
            end,
            GetEquippedRelicLockedReason = function()
              assertEquals('function', type(ns.GetEquippedRelicLockedReason))
            end,
            GetForgeRotation = function()
              assertEquals('function', type(ns.GetForgeRotation))
            end,
            GetItemLevelIncreaseProvidedByRelic = function()
              assertEquals('function', type(ns.GetItemLevelIncreaseProvidedByRelic))
            end,
            GetMetaPowerInfo = function()
              assertEquals('function', type(ns.GetMetaPowerInfo))
            end,
            GetNumAppearanceSets = function()
              assertEquals('function', type(ns.GetNumAppearanceSets))
            end,
            GetNumObtainedArtifacts = function()
              assertEquals('function', type(ns.GetNumObtainedArtifacts))
            end,
            GetNumRelicSlots = function()
              assertEquals('function', type(ns.GetNumRelicSlots))
            end,
            GetPointsRemaining = function()
              assertEquals('function', type(ns.GetPointsRemaining))
            end,
            GetPowerHyperlink = function()
              assertEquals('function', type(ns.GetPowerHyperlink))
            end,
            GetPowerInfo = function()
              assertEquals('function', type(ns.GetPowerInfo))
            end,
            GetPowerLinks = function()
              assertEquals('function', type(ns.GetPowerLinks))
            end,
            GetPowers = function()
              assertEquals('function', type(ns.GetPowers))
            end,
            GetPowersAffectedByRelic = function()
              assertEquals('function', type(ns.GetPowersAffectedByRelic))
            end,
            GetPowersAffectedByRelicItemLink = function()
              assertEquals('function', type(ns.GetPowersAffectedByRelicItemLink))
            end,
            GetPreviewAppearance = function()
              assertEquals('function', type(ns.GetPreviewAppearance))
            end,
            GetRelicInfo = function()
              assertEquals('function', type(ns.GetRelicInfo))
            end,
            GetRelicInfoByItemID = function()
              assertEquals('function', type(ns.GetRelicInfoByItemID))
            end,
            GetRelicLockedReason = function()
              assertEquals('function', type(ns.GetRelicLockedReason))
            end,
            GetRelicSlotType = function()
              assertEquals('function', type(ns.GetRelicSlotType))
            end,
            GetRespecArtifactArtInfo = function()
              assertEquals('function', type(ns.GetRespecArtifactArtInfo))
            end,
            GetRespecArtifactInfo = function()
              assertEquals('function', type(ns.GetRespecArtifactInfo))
            end,
            GetRespecCost = function()
              assertEquals('function', type(ns.GetRespecCost))
            end,
            GetTotalPowerCost = function()
              assertEquals('function', type(ns.GetTotalPowerCost))
            end,
            GetTotalPurchasedRanks = function()
              assertEquals('function', type(ns.GetTotalPurchasedRanks))
            end,
            IsArtifactDisabled = function()
              assertEquals('function', type(ns.IsArtifactDisabled))
            end,
            IsAtForge = function()
              assertEquals('function', type(ns.IsAtForge))
            end,
            IsEquippedArtifactDisabled = function()
              assertEquals('function', type(ns.IsEquippedArtifactDisabled))
            end,
            IsEquippedArtifactMaxed = function()
              assertEquals('function', type(ns.IsEquippedArtifactMaxed))
            end,
            IsMaxedByRulesOrEffect = function()
              assertEquals('function', type(ns.IsMaxedByRulesOrEffect))
            end,
            IsPowerKnown = function()
              assertEquals('function', type(ns.IsPowerKnown))
            end,
            IsViewedArtifactEquipped = function()
              assertEquals('function', type(ns.IsViewedArtifactEquipped))
            end,
            SetAppearance = function()
              assertEquals('function', type(ns.SetAppearance))
            end,
            SetForgeCamera = function()
              assertEquals('function', type(ns.SetForgeCamera))
            end,
            SetForgeRotation = function()
              assertEquals('function', type(ns.SetForgeRotation))
            end,
            SetPreviewAppearance = function()
              assertEquals('function', type(ns.SetPreviewAppearance))
            end,
            ShouldSuppressForgeRotation = function()
              assertEquals('function', type(ns.ShouldSuppressForgeRotation))
            end,
          }
        end,
        C_AuctionHouse = function()
          local ns = _G.C_AuctionHouse
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            CalculateCommodityDeposit = function()
              assertEquals('function', type(ns.CalculateCommodityDeposit))
            end,
            CalculateItemDeposit = function()
              assertEquals('function', type(ns.CalculateItemDeposit))
            end,
            CanCancelAuction = function()
              assertEquals('function', type(ns.CanCancelAuction))
            end,
            CancelAuction = function()
              assertEquals('function', type(ns.CancelAuction))
            end,
            CancelCommoditiesPurchase = function()
              assertEquals('function', type(ns.CancelCommoditiesPurchase))
            end,
            CancelSell = function()
              assertEquals('function', type(ns.CancelSell))
            end,
            CloseAuctionHouse = function()
              assertEquals('function', type(ns.CloseAuctionHouse))
            end,
            ConfirmCommoditiesPurchase = function()
              assertEquals('function', type(ns.ConfirmCommoditiesPurchase))
            end,
            FavoritesAreAvailable = function()
              assertEquals('function', type(ns.FavoritesAreAvailable))
            end,
            GetAuctionInfoByID = function()
              assertEquals('function', type(ns.GetAuctionInfoByID))
            end,
            GetAuctionItemSubClasses = function()
              assertEquals('function', type(ns.GetAuctionItemSubClasses))
            end,
            GetAvailablePostCount = function()
              assertEquals('function', type(ns.GetAvailablePostCount))
            end,
            GetBidInfo = function()
              assertEquals('function', type(ns.GetBidInfo))
            end,
            GetBidType = function()
              assertEquals('function', type(ns.GetBidType))
            end,
            GetBids = function()
              assertEquals('function', type(ns.GetBids))
            end,
            GetBrowseResults = function()
              assertEquals('function', type(ns.GetBrowseResults))
            end,
            GetCancelCost = function()
              assertEquals('function', type(ns.GetCancelCost))
            end,
            GetCommoditySearchResultInfo = function()
              assertEquals('function', type(ns.GetCommoditySearchResultInfo))
            end,
            GetCommoditySearchResultsQuantity = function()
              assertEquals('function', type(ns.GetCommoditySearchResultsQuantity))
            end,
            GetExtraBrowseInfo = function()
              assertEquals('function', type(ns.GetExtraBrowseInfo))
            end,
            GetFilterGroups = function()
              assertEquals('function', type(ns.GetFilterGroups))
            end,
            GetItemCommodityStatus = function()
              assertEquals('function', type(ns.GetItemCommodityStatus))
            end,
            GetItemKeyFromItem = function()
              assertEquals('function', type(ns.GetItemKeyFromItem))
            end,
            GetItemKeyInfo = function()
              assertEquals('function', type(ns.GetItemKeyInfo))
            end,
            GetItemKeyRequiredLevel = function()
              assertEquals('function', type(ns.GetItemKeyRequiredLevel))
            end,
            GetItemSearchResultInfo = function()
              assertEquals('function', type(ns.GetItemSearchResultInfo))
            end,
            GetItemSearchResultsQuantity = function()
              assertEquals('function', type(ns.GetItemSearchResultsQuantity))
            end,
            GetMaxBidItemBid = function()
              assertEquals('function', type(ns.GetMaxBidItemBid))
            end,
            GetMaxBidItemBuyout = function()
              assertEquals('function', type(ns.GetMaxBidItemBuyout))
            end,
            GetMaxCommoditySearchResultPrice = function()
              assertEquals('function', type(ns.GetMaxCommoditySearchResultPrice))
            end,
            GetMaxItemSearchResultBid = function()
              assertEquals('function', type(ns.GetMaxItemSearchResultBid))
            end,
            GetMaxItemSearchResultBuyout = function()
              assertEquals('function', type(ns.GetMaxItemSearchResultBuyout))
            end,
            GetMaxOwnedAuctionBid = function()
              assertEquals('function', type(ns.GetMaxOwnedAuctionBid))
            end,
            GetMaxOwnedAuctionBuyout = function()
              assertEquals('function', type(ns.GetMaxOwnedAuctionBuyout))
            end,
            GetNumBidTypes = function()
              assertEquals('function', type(ns.GetNumBidTypes))
            end,
            GetNumBids = function()
              assertEquals('function', type(ns.GetNumBids))
            end,
            GetNumCommoditySearchResults = function()
              assertEquals('function', type(ns.GetNumCommoditySearchResults))
            end,
            GetNumItemSearchResults = function()
              assertEquals('function', type(ns.GetNumItemSearchResults))
            end,
            GetNumOwnedAuctionTypes = function()
              assertEquals('function', type(ns.GetNumOwnedAuctionTypes))
            end,
            GetNumOwnedAuctions = function()
              assertEquals('function', type(ns.GetNumOwnedAuctions))
            end,
            GetNumReplicateItems = function()
              assertEquals('function', type(ns.GetNumReplicateItems))
            end,
            GetOwnedAuctionInfo = function()
              assertEquals('function', type(ns.GetOwnedAuctionInfo))
            end,
            GetOwnedAuctionType = function()
              assertEquals('function', type(ns.GetOwnedAuctionType))
            end,
            GetOwnedAuctions = function()
              assertEquals('function', type(ns.GetOwnedAuctions))
            end,
            GetQuoteDurationRemaining = function()
              assertEquals('function', type(ns.GetQuoteDurationRemaining))
            end,
            GetReplicateItemBattlePetInfo = function()
              assertEquals('function', type(ns.GetReplicateItemBattlePetInfo))
            end,
            GetReplicateItemInfo = function()
              assertEquals('function', type(ns.GetReplicateItemInfo))
            end,
            GetReplicateItemLink = function()
              assertEquals('function', type(ns.GetReplicateItemLink))
            end,
            GetReplicateItemTimeLeft = function()
              assertEquals('function', type(ns.GetReplicateItemTimeLeft))
            end,
            GetTimeLeftBandInfo = function()
              assertEquals('function', type(ns.GetTimeLeftBandInfo))
            end,
            HasFavorites = function()
              assertEquals('function', type(ns.HasFavorites))
            end,
            HasFullBidResults = function()
              assertEquals('function', type(ns.HasFullBidResults))
            end,
            HasFullBrowseResults = function()
              assertEquals('function', type(ns.HasFullBrowseResults))
            end,
            HasFullCommoditySearchResults = function()
              assertEquals('function', type(ns.HasFullCommoditySearchResults))
            end,
            HasFullItemSearchResults = function()
              assertEquals('function', type(ns.HasFullItemSearchResults))
            end,
            HasFullOwnedAuctionResults = function()
              assertEquals('function', type(ns.HasFullOwnedAuctionResults))
            end,
            HasMaxFavorites = function()
              assertEquals('function', type(ns.HasMaxFavorites))
            end,
            HasSearchResults = function()
              assertEquals('function', type(ns.HasSearchResults))
            end,
            IsFavoriteItem = function()
              assertEquals('function', type(ns.IsFavoriteItem))
            end,
            IsSellItemValid = function()
              assertEquals('function', type(ns.IsSellItemValid))
            end,
            IsThrottledMessageSystemReady = function()
              assertEquals('function', type(ns.IsThrottledMessageSystemReady))
            end,
            MakeItemKey = function()
              assertEquals('function', type(ns.MakeItemKey))
            end,
            PlaceBid = function()
              assertEquals('function', type(ns.PlaceBid))
            end,
            PostCommodity = function()
              assertEquals('function', type(ns.PostCommodity))
            end,
            PostItem = function()
              assertEquals('function', type(ns.PostItem))
            end,
            QueryBids = function()
              assertEquals('function', type(ns.QueryBids))
            end,
            QueryOwnedAuctions = function()
              assertEquals('function', type(ns.QueryOwnedAuctions))
            end,
            RefreshCommoditySearchResults = function()
              assertEquals('function', type(ns.RefreshCommoditySearchResults))
            end,
            RefreshItemSearchResults = function()
              assertEquals('function', type(ns.RefreshItemSearchResults))
            end,
            ReplicateItems = function()
              assertEquals('function', type(ns.ReplicateItems))
            end,
            RequestFavorites = function()
              assertEquals('function', type(ns.RequestFavorites))
            end,
            RequestMoreBrowseResults = function()
              assertEquals('function', type(ns.RequestMoreBrowseResults))
            end,
            RequestMoreCommoditySearchResults = function()
              assertEquals('function', type(ns.RequestMoreCommoditySearchResults))
            end,
            RequestMoreItemSearchResults = function()
              assertEquals('function', type(ns.RequestMoreItemSearchResults))
            end,
            RequestOwnedAuctionBidderInfo = function()
              assertEquals('function', type(ns.RequestOwnedAuctionBidderInfo))
            end,
            SearchForFavorites = function()
              assertEquals('function', type(ns.SearchForFavorites))
            end,
            SearchForItemKeys = function()
              assertEquals('function', type(ns.SearchForItemKeys))
            end,
            SendBrowseQuery = function()
              assertEquals('function', type(ns.SendBrowseQuery))
            end,
            SendSearchQuery = function()
              assertEquals('function', type(ns.SendSearchQuery))
            end,
            SendSellSearchQuery = function()
              assertEquals('function', type(ns.SendSellSearchQuery))
            end,
            SetFavoriteItem = function()
              assertEquals('function', type(ns.SetFavoriteItem))
            end,
            StartCommoditiesPurchase = function()
              assertEquals('function', type(ns.StartCommoditiesPurchase))
            end,
          }
        end,
        C_AzeriteEmpoweredItem = function()
          local ns = _G.C_AzeriteEmpoweredItem
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            CanSelectPower = function()
              assertEquals('function', type(ns.CanSelectPower))
            end,
            CloseAzeriteEmpoweredItemRespec = function()
              assertEquals('function', type(ns.CloseAzeriteEmpoweredItemRespec))
            end,
            ConfirmAzeriteEmpoweredItemRespec = function()
              assertEquals('function', type(ns.ConfirmAzeriteEmpoweredItemRespec))
            end,
            GetAllTierInfo = function()
              assertEquals('function', type(ns.GetAllTierInfo))
            end,
            GetAllTierInfoByItemID = function()
              assertEquals('function', type(ns.GetAllTierInfoByItemID))
            end,
            GetAzeriteEmpoweredItemRespecCost = function()
              assertEquals('function', type(ns.GetAzeriteEmpoweredItemRespecCost))
            end,
            GetPowerInfo = function()
              assertEquals('function', type(ns.GetPowerInfo))
            end,
            GetPowerText = function()
              assertEquals('function', type(ns.GetPowerText))
            end,
            GetSpecsForPower = function()
              assertEquals('function', type(ns.GetSpecsForPower))
            end,
            HasAnyUnselectedPowers = function()
              assertEquals('function', type(ns.HasAnyUnselectedPowers))
            end,
            HasBeenViewed = function()
              assertEquals('function', type(ns.HasBeenViewed))
            end,
            IsAzeriteEmpoweredItem = function()
              assertEquals('function', type(ns.IsAzeriteEmpoweredItem))
            end,
            IsAzeriteEmpoweredItemByID = function()
              assertEquals('function', type(ns.IsAzeriteEmpoweredItemByID))
            end,
            IsAzeritePreviewSourceDisplayable = function()
              assertEquals('function', type(ns.IsAzeritePreviewSourceDisplayable))
            end,
            IsHeartOfAzerothEquipped = function()
              assertEquals('function', type(ns.IsHeartOfAzerothEquipped))
            end,
            IsPowerAvailableForSpec = function()
              assertEquals('function', type(ns.IsPowerAvailableForSpec))
            end,
            IsPowerSelected = function()
              assertEquals('function', type(ns.IsPowerSelected))
            end,
            SelectPower = function()
              assertEquals('function', type(ns.SelectPower))
            end,
            SetHasBeenViewed = function()
              assertEquals('function', type(ns.SetHasBeenViewed))
            end,
          }
        end,
        C_AzeriteEssence = function()
          local ns = _G.C_AzeriteEssence
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            ActivateEssence = function()
              assertEquals('function', type(ns.ActivateEssence))
            end,
            CanActivateEssence = function()
              assertEquals('function', type(ns.CanActivateEssence))
            end,
            CanDeactivateEssence = function()
              assertEquals('function', type(ns.CanDeactivateEssence))
            end,
            CanOpenUI = function()
              assertEquals('function', type(ns.CanOpenUI))
            end,
            ClearPendingActivationEssence = function()
              assertEquals('function', type(ns.ClearPendingActivationEssence))
            end,
            CloseForge = function()
              assertEquals('function', type(ns.CloseForge))
            end,
            GetEssenceHyperlink = function()
              assertEquals('function', type(ns.GetEssenceHyperlink))
            end,
            GetEssenceInfo = function()
              assertEquals('function', type(ns.GetEssenceInfo))
            end,
            GetEssences = function()
              assertEquals('function', type(ns.GetEssences))
            end,
            GetMilestoneEssence = function()
              assertEquals('function', type(ns.GetMilestoneEssence))
            end,
            GetMilestoneInfo = function()
              assertEquals('function', type(ns.GetMilestoneInfo))
            end,
            GetMilestoneSpell = function()
              assertEquals('function', type(ns.GetMilestoneSpell))
            end,
            GetMilestones = function()
              assertEquals('function', type(ns.GetMilestones))
            end,
            GetNumUnlockedEssences = function()
              assertEquals('function', type(ns.GetNumUnlockedEssences))
            end,
            GetNumUsableEssences = function()
              assertEquals('function', type(ns.GetNumUsableEssences))
            end,
            GetPendingActivationEssence = function()
              assertEquals('function', type(ns.GetPendingActivationEssence))
            end,
            HasNeverActivatedAnyEssences = function()
              assertEquals('function', type(ns.HasNeverActivatedAnyEssences))
            end,
            HasPendingActivationEssence = function()
              assertEquals('function', type(ns.HasPendingActivationEssence))
            end,
            IsAtForge = function()
              assertEquals('function', type(ns.IsAtForge))
            end,
            SetPendingActivationEssence = function()
              assertEquals('function', type(ns.SetPendingActivationEssence))
            end,
            UnlockMilestone = function()
              assertEquals('function', type(ns.UnlockMilestone))
            end,
          }
        end,
        C_AzeriteItem = function()
          local ns = _G.C_AzeriteItem
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            FindActiveAzeriteItem = function()
              assertEquals('function', type(ns.FindActiveAzeriteItem))
            end,
            GetAzeriteItemXPInfo = function()
              assertEquals('function', type(ns.GetAzeriteItemXPInfo))
            end,
            GetPowerLevel = function()
              assertEquals('function', type(ns.GetPowerLevel))
            end,
            GetUnlimitedPowerLevel = function()
              assertEquals('function', type(ns.GetUnlimitedPowerLevel))
            end,
            HasActiveAzeriteItem = function()
              assertEquals('function', type(ns.HasActiveAzeriteItem))
            end,
            IsAzeriteItem = function()
              assertEquals('function', type(ns.IsAzeriteItem))
            end,
            IsAzeriteItemAtMaxLevel = function()
              assertEquals('function', type(ns.IsAzeriteItemAtMaxLevel))
            end,
            IsAzeriteItemByID = function()
              assertEquals('function', type(ns.IsAzeriteItemByID))
            end,
            IsAzeriteItemEnabled = function()
              assertEquals('function', type(ns.IsAzeriteItemEnabled))
            end,
          }
        end,
        C_BarberShop = function()
          local ns = _G.C_BarberShop
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            ApplyCustomizationChoices = function()
              assertEquals('function', type(ns.ApplyCustomizationChoices))
            end,
            Cancel = function()
              assertEquals('function', type(ns.Cancel))
            end,
            ClearPreviewChoices = function()
              assertEquals('function', type(ns.ClearPreviewChoices))
            end,
            GetAvailableCustomizations = function()
              assertEquals('function', type(ns.GetAvailableCustomizations))
            end,
            GetCurrentCameraZoom = function()
              assertEquals('function', type(ns.GetCurrentCameraZoom))
            end,
            GetCurrentCharacterData = function()
              assertEquals('function', type(ns.GetCurrentCharacterData))
            end,
            GetCurrentCost = function()
              assertEquals('function', type(ns.GetCurrentCost))
            end,
            HasAnyChanges = function()
              assertEquals('function', type(ns.HasAnyChanges))
            end,
            IsViewingAlteredForm = function()
              assertEquals('function', type(ns.IsViewingAlteredForm))
            end,
            MarkCustomizationChoiceAsSeen = function()
              assertEquals('function', type(ns.MarkCustomizationChoiceAsSeen))
            end,
            MarkCustomizationOptionAsSeen = function()
              assertEquals('function', type(ns.MarkCustomizationOptionAsSeen))
            end,
            PreviewCustomizationChoice = function()
              assertEquals('function', type(ns.PreviewCustomizationChoice))
            end,
            RandomizeCustomizationChoices = function()
              assertEquals('function', type(ns.RandomizeCustomizationChoices))
            end,
            ResetCameraRotation = function()
              assertEquals('function', type(ns.ResetCameraRotation))
            end,
            ResetCustomizationChoices = function()
              assertEquals('function', type(ns.ResetCustomizationChoices))
            end,
            RotateCamera = function()
              assertEquals('function', type(ns.RotateCamera))
            end,
            SaveSeenChoices = function()
              assertEquals('function', type(ns.SaveSeenChoices))
            end,
            SetCameraDistanceOffset = function()
              assertEquals('function', type(ns.SetCameraDistanceOffset))
            end,
            SetCameraZoomLevel = function()
              assertEquals('function', type(ns.SetCameraZoomLevel))
            end,
            SetCustomizationChoice = function()
              assertEquals('function', type(ns.SetCustomizationChoice))
            end,
            SetModelDressState = function()
              assertEquals('function', type(ns.SetModelDressState))
            end,
            SetSelectedSex = function()
              assertEquals('function', type(ns.SetSelectedSex))
            end,
            SetViewingAlteredForm = function()
              assertEquals('function', type(ns.SetViewingAlteredForm))
            end,
            SetViewingShapeshiftForm = function()
              assertEquals('function', type(ns.SetViewingShapeshiftForm))
            end,
            ZoomCamera = function()
              assertEquals('function', type(ns.ZoomCamera))
            end,
          }
        end,
        C_BattleNet = function()
          local ns = _G.C_BattleNet
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetAccountInfoByGUID = function()
              assertEquals('function', type(ns.GetAccountInfoByGUID))
            end,
            GetAccountInfoByID = function()
              assertEquals('function', type(ns.GetAccountInfoByID))
            end,
            GetFriendAccountInfo = function()
              assertEquals('function', type(ns.GetFriendAccountInfo))
            end,
            GetFriendGameAccountInfo = function()
              assertEquals('function', type(ns.GetFriendGameAccountInfo))
            end,
            GetFriendNumGameAccounts = function()
              assertEquals('function', type(ns.GetFriendNumGameAccounts))
            end,
            GetGameAccountInfoByGUID = function()
              assertEquals('function', type(ns.GetGameAccountInfoByGUID))
            end,
            GetGameAccountInfoByID = function()
              assertEquals('function', type(ns.GetGameAccountInfoByID))
            end,
          }
        end,
        C_BehavioralMessaging = function()
          local ns = _G.C_BehavioralMessaging
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            SendNotificationReceipt = function()
              assertEquals('function', type(ns.SendNotificationReceipt))
            end,
          }
        end,
        C_BlackMarket = function()
          local ns = _G.C_BlackMarket
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            Close = function()
              assertEquals('function', type(ns.Close))
            end,
            IsViewOnly = function()
              assertEquals('function', type(ns.IsViewOnly))
            end,
            RequestItems = function()
              assertEquals('function', type(ns.RequestItems))
            end,
          }
        end,
        C_CVar = function()
          local ns = _G.C_CVar
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetCVar = function()
              assertEquals('function', type(ns.GetCVar))
            end,
            GetCVarBitfield = function()
              assertEquals('function', type(ns.GetCVarBitfield))
            end,
            GetCVarBool = function()
              assertEquals('function', type(ns.GetCVarBool))
            end,
            RegisterCVar = function()
              assertEquals('function', type(ns.RegisterCVar))
            end,
            ResetTestCVars = function()
              assertEquals('function', type(ns.ResetTestCVars))
            end,
            SetCVar = function()
              assertEquals('function', type(ns.SetCVar))
            end,
            SetCVarBitfield = function()
              assertEquals('function', type(ns.SetCVarBitfield))
            end,
          }
        end,
        C_Calendar = function()
          local ns = _G.C_Calendar
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            AddEvent = function()
              assertEquals('function', type(ns.AddEvent))
            end,
            AreNamesReady = function()
              assertEquals('function', type(ns.AreNamesReady))
            end,
            CanAddEvent = function()
              assertEquals('function', type(ns.CanAddEvent))
            end,
            CanSendInvite = function()
              assertEquals('function', type(ns.CanSendInvite))
            end,
            CloseEvent = function()
              assertEquals('function', type(ns.CloseEvent))
            end,
            ContextMenuEventCanComplain = function()
              assertEquals('function', type(ns.ContextMenuEventCanComplain))
            end,
            ContextMenuEventCanEdit = function()
              assertEquals('function', type(ns.ContextMenuEventCanEdit))
            end,
            ContextMenuEventCanRemove = function()
              assertEquals('function', type(ns.ContextMenuEventCanRemove))
            end,
            ContextMenuEventClipboard = function()
              assertEquals('function', type(ns.ContextMenuEventClipboard))
            end,
            ContextMenuEventComplain = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ContextMenuEventComplain))
                return
              end
              assertEquals('function', type(ns.ContextMenuEventComplain))
            end,
            ContextMenuEventCopy = function()
              assertEquals('function', type(ns.ContextMenuEventCopy))
            end,
            ContextMenuEventGetCalendarType = function()
              assertEquals('function', type(ns.ContextMenuEventGetCalendarType))
            end,
            ContextMenuEventPaste = function()
              assertEquals('function', type(ns.ContextMenuEventPaste))
            end,
            ContextMenuEventRemove = function()
              assertEquals('function', type(ns.ContextMenuEventRemove))
            end,
            ContextMenuEventSignUp = function()
              assertEquals('function', type(ns.ContextMenuEventSignUp))
            end,
            ContextMenuGetEventIndex = function()
              assertEquals('function', type(ns.ContextMenuGetEventIndex))
            end,
            ContextMenuInviteAvailable = function()
              assertEquals('function', type(ns.ContextMenuInviteAvailable))
            end,
            ContextMenuInviteDecline = function()
              assertEquals('function', type(ns.ContextMenuInviteDecline))
            end,
            ContextMenuInviteRemove = function()
              assertEquals('function', type(ns.ContextMenuInviteRemove))
            end,
            ContextMenuInviteTentative = function()
              assertEquals('function', type(ns.ContextMenuInviteTentative))
            end,
            ContextMenuSelectEvent = function()
              assertEquals('function', type(ns.ContextMenuSelectEvent))
            end,
            CreateCommunitySignUpEvent = function()
              assertEquals('function', type(ns.CreateCommunitySignUpEvent))
            end,
            CreateGuildAnnouncementEvent = function()
              assertEquals('function', type(ns.CreateGuildAnnouncementEvent))
            end,
            CreateGuildSignUpEvent = function()
              assertEquals('function', type(ns.CreateGuildSignUpEvent))
            end,
            CreatePlayerEvent = function()
              assertEquals('function', type(ns.CreatePlayerEvent))
            end,
            EventAvailable = function()
              assertEquals('function', type(ns.EventAvailable))
            end,
            EventCanEdit = function()
              assertEquals('function', type(ns.EventCanEdit))
            end,
            EventClearAutoApprove = function()
              assertEquals('function', type(ns.EventClearAutoApprove))
            end,
            EventClearLocked = function()
              assertEquals('function', type(ns.EventClearLocked))
            end,
            EventClearModerator = function()
              assertEquals('function', type(ns.EventClearModerator))
            end,
            EventDecline = function()
              assertEquals('function', type(ns.EventDecline))
            end,
            EventGetCalendarType = function()
              assertEquals('function', type(ns.EventGetCalendarType))
            end,
            EventGetClubId = function()
              assertEquals('function', type(ns.EventGetClubId))
            end,
            EventGetInvite = function()
              assertEquals('function', type(ns.EventGetInvite))
            end,
            EventGetInviteResponseTime = function()
              assertEquals('function', type(ns.EventGetInviteResponseTime))
            end,
            EventGetInviteSortCriterion = function()
              assertEquals('function', type(ns.EventGetInviteSortCriterion))
            end,
            EventGetSelectedInvite = function()
              assertEquals('function', type(ns.EventGetSelectedInvite))
            end,
            EventGetStatusOptions = function()
              assertEquals('function', type(ns.EventGetStatusOptions))
            end,
            EventGetTextures = function()
              assertEquals('function', type(ns.EventGetTextures))
            end,
            EventGetTypes = function()
              assertEquals('function', type(ns.EventGetTypes))
            end,
            EventGetTypesDisplayOrdered = function()
              assertEquals('function', type(ns.EventGetTypesDisplayOrdered))
            end,
            EventHasPendingInvite = function()
              assertEquals('function', type(ns.EventHasPendingInvite))
            end,
            EventHaveSettingsChanged = function()
              assertEquals('function', type(ns.EventHaveSettingsChanged))
            end,
            EventInvite = function()
              assertEquals('function', type(ns.EventInvite))
            end,
            EventRemoveInvite = function()
              assertEquals('function', type(ns.EventRemoveInvite))
            end,
            EventRemoveInviteByGuid = function()
              assertEquals('function', type(ns.EventRemoveInviteByGuid))
            end,
            EventSelectInvite = function()
              assertEquals('function', type(ns.EventSelectInvite))
            end,
            EventSetAutoApprove = function()
              assertEquals('function', type(ns.EventSetAutoApprove))
            end,
            EventSetClubId = function()
              assertEquals('function', type(ns.EventSetClubId))
            end,
            EventSetDate = function()
              assertEquals('function', type(ns.EventSetDate))
            end,
            EventSetDescription = function()
              assertEquals('function', type(ns.EventSetDescription))
            end,
            EventSetInviteStatus = function()
              assertEquals('function', type(ns.EventSetInviteStatus))
            end,
            EventSetLocked = function()
              assertEquals('function', type(ns.EventSetLocked))
            end,
            EventSetModerator = function()
              assertEquals('function', type(ns.EventSetModerator))
            end,
            EventSetTextureID = function()
              assertEquals('function', type(ns.EventSetTextureID))
            end,
            EventSetTime = function()
              assertEquals('function', type(ns.EventSetTime))
            end,
            EventSetTitle = function()
              assertEquals('function', type(ns.EventSetTitle))
            end,
            EventSetType = function()
              assertEquals('function', type(ns.EventSetType))
            end,
            EventSignUp = function()
              assertEquals('function', type(ns.EventSignUp))
            end,
            EventSortInvites = function()
              assertEquals('function', type(ns.EventSortInvites))
            end,
            EventTentative = function()
              assertEquals('function', type(ns.EventTentative))
            end,
            GetClubCalendarEvents = function()
              assertEquals('function', type(ns.GetClubCalendarEvents))
            end,
            GetDayEvent = function()
              assertEquals('function', type(ns.GetDayEvent))
            end,
            GetDefaultGuildFilter = function()
              assertEquals('function', type(ns.GetDefaultGuildFilter))
            end,
            GetEventIndex = function()
              assertEquals('function', type(ns.GetEventIndex))
            end,
            GetEventIndexInfo = function()
              assertEquals('function', type(ns.GetEventIndexInfo))
            end,
            GetEventInfo = function()
              assertEquals('function', type(ns.GetEventInfo))
            end,
            GetFirstPendingInvite = function()
              assertEquals('function', type(ns.GetFirstPendingInvite))
            end,
            GetGuildEventInfo = function()
              assertEquals('function', type(ns.GetGuildEventInfo))
            end,
            GetGuildEventSelectionInfo = function()
              assertEquals('function', type(ns.GetGuildEventSelectionInfo))
            end,
            GetHolidayInfo = function()
              assertEquals('function', type(ns.GetHolidayInfo))
            end,
            GetMaxCreateDate = function()
              assertEquals('function', type(ns.GetMaxCreateDate))
            end,
            GetMinDate = function()
              assertEquals('function', type(ns.GetMinDate))
            end,
            GetMonthInfo = function()
              assertEquals('function', type(ns.GetMonthInfo))
            end,
            GetNextClubId = function()
              assertEquals('function', type(ns.GetNextClubId))
            end,
            GetNumDayEvents = function()
              assertEquals('function', type(ns.GetNumDayEvents))
            end,
            GetNumGuildEvents = function()
              assertEquals('function', type(ns.GetNumGuildEvents))
            end,
            GetNumInvites = function()
              assertEquals('function', type(ns.GetNumInvites))
            end,
            GetNumPendingInvites = function()
              assertEquals('function', type(ns.GetNumPendingInvites))
            end,
            GetRaidInfo = function()
              assertEquals('function', type(ns.GetRaidInfo))
            end,
            IsActionPending = function()
              assertEquals('function', type(ns.IsActionPending))
            end,
            IsEventOpen = function()
              assertEquals('function', type(ns.IsEventOpen))
            end,
            MassInviteCommunity = function()
              assertEquals('function', type(ns.MassInviteCommunity))
            end,
            MassInviteGuild = function()
              assertEquals('function', type(ns.MassInviteGuild))
            end,
            OpenCalendar = function()
              assertEquals('function', type(ns.OpenCalendar))
            end,
            OpenEvent = function()
              assertEquals('function', type(ns.OpenEvent))
            end,
            RemoveEvent = function()
              assertEquals('function', type(ns.RemoveEvent))
            end,
            SetAbsMonth = function()
              assertEquals('function', type(ns.SetAbsMonth))
            end,
            SetMonth = function()
              assertEquals('function', type(ns.SetMonth))
            end,
            SetNextClubId = function()
              assertEquals('function', type(ns.SetNextClubId))
            end,
            UpdateEvent = function()
              assertEquals('function', type(ns.UpdateEvent))
            end,
          }
        end,
        C_CampaignInfo = function()
          local ns = _G.C_CampaignInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetAvailableCampaigns = function()
              assertEquals('function', type(ns.GetAvailableCampaigns))
            end,
            GetCampaignChapterInfo = function()
              assertEquals('function', type(ns.GetCampaignChapterInfo))
            end,
            GetCampaignID = function()
              assertEquals('function', type(ns.GetCampaignID))
            end,
            GetCampaignInfo = function()
              assertEquals('function', type(ns.GetCampaignInfo))
            end,
            GetChapterIDs = function()
              assertEquals('function', type(ns.GetChapterIDs))
            end,
            GetCurrentChapterID = function()
              assertEquals('function', type(ns.GetCurrentChapterID))
            end,
            GetFailureReason = function()
              assertEquals('function', type(ns.GetFailureReason))
            end,
            GetState = function()
              assertEquals('function', type(ns.GetState))
            end,
            IsCampaignQuest = function()
              assertEquals('function', type(ns.IsCampaignQuest))
            end,
            UsesNormalQuestIcons = function()
              assertEquals('function', type(ns.UsesNormalQuestIcons))
            end,
          }
        end,
        C_ChallengeMode = function()
          local ns = _G.C_ChallengeMode
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            CanUseKeystoneInCurrentMap = function()
              assertEquals('function', type(ns.CanUseKeystoneInCurrentMap))
            end,
            ClearKeystone = function()
              assertEquals('function', type(ns.ClearKeystone))
            end,
            CloseKeystoneFrame = function()
              assertEquals('function', type(ns.CloseKeystoneFrame))
            end,
            GetActiveChallengeMapID = function()
              assertEquals('function', type(ns.GetActiveChallengeMapID))
            end,
            GetActiveKeystoneInfo = function()
              assertEquals('function', type(ns.GetActiveKeystoneInfo))
            end,
            GetAffixInfo = function()
              assertEquals('function', type(ns.GetAffixInfo))
            end,
            GetCompletionInfo = function()
              assertEquals('function', type(ns.GetCompletionInfo))
            end,
            GetDeathCount = function()
              assertEquals('function', type(ns.GetDeathCount))
            end,
            GetDungeonScoreRarityColor = function()
              assertEquals('function', type(ns.GetDungeonScoreRarityColor))
            end,
            GetGuildLeaders = function()
              assertEquals('function', type(ns.GetGuildLeaders))
            end,
            GetKeystoneLevelRarityColor = function()
              assertEquals('function', type(ns.GetKeystoneLevelRarityColor))
            end,
            GetMapScoreInfo = function()
              assertEquals('function', type(ns.GetMapScoreInfo))
            end,
            GetMapTable = function()
              assertEquals('function', type(ns.GetMapTable))
            end,
            GetMapUIInfo = function()
              assertEquals('function', type(ns.GetMapUIInfo))
            end,
            GetOverallDungeonScore = function()
              assertEquals('function', type(ns.GetOverallDungeonScore))
            end,
            GetPowerLevelDamageHealthMod = function()
              assertEquals('function', type(ns.GetPowerLevelDamageHealthMod))
            end,
            GetSlottedKeystoneInfo = function()
              assertEquals('function', type(ns.GetSlottedKeystoneInfo))
            end,
            GetSpecificDungeonOverallScoreRarityColor = function()
              assertEquals('function', type(ns.GetSpecificDungeonOverallScoreRarityColor))
            end,
            GetSpecificDungeonScoreRarityColor = function()
              assertEquals('function', type(ns.GetSpecificDungeonScoreRarityColor))
            end,
            HasSlottedKeystone = function()
              assertEquals('function', type(ns.HasSlottedKeystone))
            end,
            IsChallengeModeActive = function()
              assertEquals('function', type(ns.IsChallengeModeActive))
            end,
            RemoveKeystone = function()
              assertEquals('function', type(ns.RemoveKeystone))
            end,
            RequestLeaders = function()
              assertEquals('function', type(ns.RequestLeaders))
            end,
            Reset = function()
              assertEquals('function', type(ns.Reset))
            end,
            SetKeystoneTooltip = function()
              assertEquals('function', type(ns.SetKeystoneTooltip))
            end,
            SlotKeystone = function()
              assertEquals('function', type(ns.SlotKeystone))
            end,
            StartChallengeMode = function()
              assertEquals('function', type(ns.StartChallengeMode))
            end,
          }
        end,
        C_CharacterServices = function()
          local ns = _G.C_CharacterServices
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetCharacterServiceDisplayData = function()
              assertEquals('function', type(ns.GetCharacterServiceDisplayData))
            end,
            HasRequiredBoostForClassTrial = function()
              assertEquals('function', type(ns.HasRequiredBoostForClassTrial))
            end,
          }
        end,
        C_CharacterServicesPublic = function()
          local ns = _G.C_CharacterServicesPublic
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            ShouldSeeControlPopup = function()
              assertEquals('function', type(ns.ShouldSeeControlPopup))
            end,
          }
        end,
        C_ChatBubbles = function()
          local ns = _G.C_ChatBubbles
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetAllChatBubbles = function()
              assertEquals('function', type(ns.GetAllChatBubbles))
            end,
          }
        end,
        C_ChatInfo = function()
          local ns = _G.C_ChatInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            CanReportPlayer = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanReportPlayer))
                return
              end
              assertEquals('function', type(ns.CanReportPlayer))
            end,
            GetChannelInfoFromIdentifier = function()
              assertEquals('function', type(ns.GetChannelInfoFromIdentifier))
            end,
            GetChannelRosterInfo = function()
              assertEquals('function', type(ns.GetChannelRosterInfo))
            end,
            GetChannelRuleset = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetChannelRuleset))
                return
              end
              assertEquals('function', type(ns.GetChannelRuleset))
            end,
            GetChannelRulesetForChannelID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetChannelRulesetForChannelID))
                return
              end
              assertEquals('function', type(ns.GetChannelRulesetForChannelID))
            end,
            GetChannelShortcut = function()
              assertEquals('function', type(ns.GetChannelShortcut))
            end,
            GetChannelShortcutForChannelID = function()
              assertEquals('function', type(ns.GetChannelShortcutForChannelID))
            end,
            GetChatTypeName = function()
              assertEquals('function', type(ns.GetChatTypeName))
            end,
            GetClubStreamIDs = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetClubStreamIDs))
                return
              end
              assertEquals('function', type(ns.GetClubStreamIDs))
            end,
            GetGeneralChannelID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetGeneralChannelID))
                return
              end
              assertEquals('function', type(ns.GetGeneralChannelID))
            end,
            GetGeneralChannelLocalID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetGeneralChannelLocalID))
                return
              end
              assertEquals('function', type(ns.GetGeneralChannelLocalID))
            end,
            GetMentorChannelID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetMentorChannelID))
                return
              end
              assertEquals('function', type(ns.GetMentorChannelID))
            end,
            GetNumActiveChannels = function()
              assertEquals('function', type(ns.GetNumActiveChannels))
            end,
            GetNumReservedChatWindows = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetNumReservedChatWindows))
                return
              end
              assertEquals('function', type(ns.GetNumReservedChatWindows))
            end,
            GetRegisteredAddonMessagePrefixes = function()
              assertEquals('function', type(ns.GetRegisteredAddonMessagePrefixes))
            end,
            IsAddonMessagePrefixRegistered = function()
              assertEquals('function', type(ns.IsAddonMessagePrefixRegistered))
            end,
            IsChannelRegional = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsChannelRegional))
                return
              end
              assertEquals('function', type(ns.IsChannelRegional))
            end,
            IsChannelRegionalForChannelID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsChannelRegionalForChannelID))
                return
              end
              assertEquals('function', type(ns.IsChannelRegionalForChannelID))
            end,
            IsPartyChannelType = function()
              assertEquals('function', type(ns.IsPartyChannelType))
            end,
            IsRegionalServiceAvailable = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsRegionalServiceAvailable))
                return
              end
              assertEquals('function', type(ns.IsRegionalServiceAvailable))
            end,
            IsValidChatLine = function()
              assertEquals('function', type(ns.IsValidChatLine))
            end,
            RegisterAddonMessagePrefix = function()
              assertEquals('function', type(ns.RegisterAddonMessagePrefix))
            end,
            ReplaceIconAndGroupExpressions = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ReplaceIconAndGroupExpressions))
                return
              end
              assertEquals('function', type(ns.ReplaceIconAndGroupExpressions))
            end,
            ReportPlayer = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ReportPlayer))
                return
              end
              assertEquals('function', type(ns.ReportPlayer))
            end,
            ReportServerLag = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ReportServerLag))
                return
              end
              assertEquals('function', type(ns.ReportServerLag))
            end,
            ResetDefaultZoneChannels = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ResetDefaultZoneChannels))
                return
              end
              assertEquals('function', type(ns.ResetDefaultZoneChannels))
            end,
            SendAddonMessage = function()
              assertEquals('function', type(ns.SendAddonMessage))
            end,
            SendAddonMessageLogged = function()
              assertEquals('function', type(ns.SendAddonMessageLogged))
            end,
            SwapChatChannelsByChannelIndex = function()
              assertEquals('function', type(ns.SwapChatChannelsByChannelIndex))
            end,
          }
        end,
        C_ChromieTime = function()
          local ns = _G.C_ChromieTime
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            CloseUI = function()
              assertEquals('function', type(ns.CloseUI))
            end,
            GetChromieTimeExpansionOption = function()
              assertEquals('function', type(ns.GetChromieTimeExpansionOption))
            end,
            GetChromieTimeExpansionOptions = function()
              assertEquals('function', type(ns.GetChromieTimeExpansionOptions))
            end,
            SelectChromieTimeOption = function()
              assertEquals('function', type(ns.SelectChromieTimeOption))
            end,
          }
        end,
        C_ClassColor = function()
          local ns = _G.C_ClassColor
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetClassColor = function()
              assertEquals('function', type(ns.GetClassColor))
            end,
          }
        end,
        C_ClassTrial = function()
          local ns = _G.C_ClassTrial
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetClassTrialLogoutTimeSeconds = function()
              assertEquals('function', type(ns.GetClassTrialLogoutTimeSeconds))
            end,
            IsClassTrialCharacter = function()
              assertEquals('function', type(ns.IsClassTrialCharacter))
            end,
          }
        end,
        C_ClickBindings = function()
          local ns = _G.C_ClickBindings
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            CanSpellBeClickBound = function()
              assertEquals('function', type(ns.CanSpellBeClickBound))
            end,
            ExecuteBinding = function()
              assertEquals('function', type(ns.ExecuteBinding))
            end,
            GetBindingType = function()
              assertEquals('function', type(ns.GetBindingType))
            end,
            GetEffectiveInteractionButton = function()
              assertEquals('function', type(ns.GetEffectiveInteractionButton))
            end,
            GetProfileInfo = function()
              assertEquals('function', type(ns.GetProfileInfo))
            end,
            GetStringFromModifiers = function()
              assertEquals('function', type(ns.GetStringFromModifiers))
            end,
            GetTutorialShown = function()
              assertEquals('function', type(ns.GetTutorialShown))
            end,
            MakeModifiers = function()
              assertEquals('function', type(ns.MakeModifiers))
            end,
            ResetCurrentProfile = function()
              assertEquals('function', type(ns.ResetCurrentProfile))
            end,
            SetProfileByInfo = function()
              assertEquals('function', type(ns.SetProfileByInfo))
            end,
            SetTutorialShown = function()
              assertEquals('function', type(ns.SetTutorialShown))
            end,
          }
        end,
        C_Club = function()
          local ns = _G.C_Club
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            AcceptInvitation = function()
              assertEquals('function', type(ns.AcceptInvitation))
            end,
            AddClubStreamChatChannel = function()
              assertEquals('function', type(ns.AddClubStreamChatChannel))
            end,
            AdvanceStreamViewMarker = function()
              assertEquals('function', type(ns.AdvanceStreamViewMarker))
            end,
            AssignMemberRole = function()
              assertEquals('function', type(ns.AssignMemberRole))
            end,
            CanResolvePlayerLocationFromClubMessageData = function()
              assertEquals('function', type(ns.CanResolvePlayerLocationFromClubMessageData))
            end,
            ClearAutoAdvanceStreamViewMarker = function()
              assertEquals('function', type(ns.ClearAutoAdvanceStreamViewMarker))
            end,
            ClearClubPresenceSubscription = function()
              assertEquals('function', type(ns.ClearClubPresenceSubscription))
            end,
            CompareBattleNetDisplayName = function()
              assertEquals('function', type(ns.CompareBattleNetDisplayName))
            end,
            CreateClub = function()
              assertEquals('function', type(ns.CreateClub))
            end,
            CreateStream = function()
              assertEquals('function', type(ns.CreateStream))
            end,
            CreateTicket = function()
              assertEquals('function', type(ns.CreateTicket))
            end,
            DeclineInvitation = function()
              assertEquals('function', type(ns.DeclineInvitation))
            end,
            DestroyClub = function()
              assertEquals('function', type(ns.DestroyClub))
            end,
            DestroyMessage = function()
              assertEquals('function', type(ns.DestroyMessage))
            end,
            DestroyStream = function()
              assertEquals('function', type(ns.DestroyStream))
            end,
            DestroyTicket = function()
              assertEquals('function', type(ns.DestroyTicket))
            end,
            DoesCommunityHaveMembersOfTheOppositeFaction = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.DoesCommunityHaveMembersOfTheOppositeFaction))
                return
              end
              assertEquals('function', type(ns.DoesCommunityHaveMembersOfTheOppositeFaction))
            end,
            EditClub = function()
              assertEquals('function', type(ns.EditClub))
            end,
            EditMessage = function()
              assertEquals('function', type(ns.EditMessage))
            end,
            EditStream = function()
              assertEquals('function', type(ns.EditStream))
            end,
            Flush = function()
              assertEquals('function', type(ns.Flush))
            end,
            FocusCommunityStreams = function()
              assertEquals('function', type(ns.FocusCommunityStreams))
            end,
            FocusStream = function()
              assertEquals('function', type(ns.FocusStream))
            end,
            GetAssignableRoles = function()
              assertEquals('function', type(ns.GetAssignableRoles))
            end,
            GetAvatarIdList = function()
              assertEquals('function', type(ns.GetAvatarIdList))
            end,
            GetClubCapacity = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetClubCapacity))
                return
              end
              assertEquals('function', type(ns.GetClubCapacity))
            end,
            GetClubInfo = function()
              assertEquals('function', type(ns.GetClubInfo))
            end,
            GetClubLimits = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetClubLimits))
                return
              end
              assertEquals('function', type(ns.GetClubLimits))
            end,
            GetClubMembers = function()
              assertEquals('function', type(ns.GetClubMembers))
            end,
            GetClubPrivileges = function()
              assertEquals('function', type(ns.GetClubPrivileges))
            end,
            GetClubStreamNotificationSettings = function()
              assertEquals('function', type(ns.GetClubStreamNotificationSettings))
            end,
            GetCommunityNameResultText = function()
              assertEquals('function', type(ns.GetCommunityNameResultText))
            end,
            GetGuildClubId = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetGuildClubId))
                return
              end
              assertEquals('function', type(ns.GetGuildClubId))
            end,
            GetInfoFromLastCommunityChatLine = function()
              assertEquals('function', type(ns.GetInfoFromLastCommunityChatLine))
            end,
            GetInvitationCandidates = function()
              assertEquals('function', type(ns.GetInvitationCandidates))
            end,
            GetInvitationInfo = function()
              assertEquals('function', type(ns.GetInvitationInfo))
            end,
            GetInvitationsForClub = function()
              assertEquals('function', type(ns.GetInvitationsForClub))
            end,
            GetInvitationsForSelf = function()
              assertEquals('function', type(ns.GetInvitationsForSelf))
            end,
            GetLastTicketResponse = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetLastTicketResponse))
                return
              end
              assertEquals('function', type(ns.GetLastTicketResponse))
            end,
            GetMemberInfo = function()
              assertEquals('function', type(ns.GetMemberInfo))
            end,
            GetMemberInfoForSelf = function()
              assertEquals('function', type(ns.GetMemberInfoForSelf))
            end,
            GetMessageInfo = function()
              assertEquals('function', type(ns.GetMessageInfo))
            end,
            GetMessageRanges = function()
              assertEquals('function', type(ns.GetMessageRanges))
            end,
            GetMessagesBefore = function()
              assertEquals('function', type(ns.GetMessagesBefore))
            end,
            GetMessagesInRange = function()
              assertEquals('function', type(ns.GetMessagesInRange))
            end,
            GetStreamInfo = function()
              assertEquals('function', type(ns.GetStreamInfo))
            end,
            GetStreamViewMarker = function()
              assertEquals('function', type(ns.GetStreamViewMarker))
            end,
            GetStreams = function()
              assertEquals('function', type(ns.GetStreams))
            end,
            GetSubscribedClubs = function()
              assertEquals('function', type(ns.GetSubscribedClubs))
            end,
            GetTickets = function()
              assertEquals('function', type(ns.GetTickets))
            end,
            IsAccountMuted = function()
              assertEquals('function', type(ns.IsAccountMuted))
            end,
            IsBeginningOfStream = function()
              assertEquals('function', type(ns.IsBeginningOfStream))
            end,
            IsEnabled = function()
              assertEquals('function', type(ns.IsEnabled))
            end,
            IsRestricted = function()
              assertEquals('function', type(ns.IsRestricted))
            end,
            IsSubscribedToStream = function()
              assertEquals('function', type(ns.IsSubscribedToStream))
            end,
            KickMember = function()
              assertEquals('function', type(ns.KickMember))
            end,
            LeaveClub = function()
              assertEquals('function', type(ns.LeaveClub))
            end,
            RedeemTicket = function()
              assertEquals('function', type(ns.RedeemTicket))
            end,
            RequestInvitationsForClub = function()
              assertEquals('function', type(ns.RequestInvitationsForClub))
            end,
            RequestMoreMessagesBefore = function()
              assertEquals('function', type(ns.RequestMoreMessagesBefore))
            end,
            RequestTicket = function()
              assertEquals('function', type(ns.RequestTicket))
            end,
            RequestTickets = function()
              assertEquals('function', type(ns.RequestTickets))
            end,
            RevokeInvitation = function()
              assertEquals('function', type(ns.RevokeInvitation))
            end,
            SendBattleTagFriendRequest = function()
              assertEquals('function', type(ns.SendBattleTagFriendRequest))
            end,
            SendCharacterInvitation = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SendCharacterInvitation))
                return
              end
              assertEquals('function', type(ns.SendCharacterInvitation))
            end,
            SendInvitation = function()
              assertEquals('function', type(ns.SendInvitation))
            end,
            SendMessage = function()
              assertEquals('function', type(ns.SendMessage))
            end,
            SetAutoAdvanceStreamViewMarker = function()
              assertEquals('function', type(ns.SetAutoAdvanceStreamViewMarker))
            end,
            SetAvatarTexture = function()
              assertEquals('function', type(ns.SetAvatarTexture))
            end,
            SetClubMemberNote = function()
              assertEquals('function', type(ns.SetClubMemberNote))
            end,
            SetClubPresenceSubscription = function()
              assertEquals('function', type(ns.SetClubPresenceSubscription))
            end,
            SetClubStreamNotificationSettings = function()
              assertEquals('function', type(ns.SetClubStreamNotificationSettings))
            end,
            SetCommunityID = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetCommunityID))
                return
              end
              assertEquals('function', type(ns.SetCommunityID))
            end,
            SetFavorite = function()
              assertEquals('function', type(ns.SetFavorite))
            end,
            SetSocialQueueingEnabled = function()
              assertEquals('function', type(ns.SetSocialQueueingEnabled))
            end,
            ShouldAllowClubType = function()
              assertEquals('function', type(ns.ShouldAllowClubType))
            end,
            UnfocusAllStreams = function()
              assertEquals('function', type(ns.UnfocusAllStreams))
            end,
            UnfocusStream = function()
              assertEquals('function', type(ns.UnfocusStream))
            end,
            ValidateText = function()
              assertEquals('function', type(ns.ValidateText))
            end,
          }
        end,
        C_ClubFinder = function()
          local ns = _G.C_ClubFinder
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            ApplicantAcceptClubInvite = function()
              assertEquals('function', type(ns.ApplicantAcceptClubInvite))
            end,
            ApplicantDeclineClubInvite = function()
              assertEquals('function', type(ns.ApplicantDeclineClubInvite))
            end,
            CancelMembershipRequest = function()
              assertEquals('function', type(ns.CancelMembershipRequest))
            end,
            CheckAllPlayerApplicantSettings = function()
              assertEquals('function', type(ns.CheckAllPlayerApplicantSettings))
            end,
            ClearAllFinderCache = function()
              assertEquals('function', type(ns.ClearAllFinderCache))
            end,
            ClearClubApplicantsCache = function()
              assertEquals('function', type(ns.ClearClubApplicantsCache))
            end,
            ClearClubFinderPostingsCache = function()
              assertEquals('function', type(ns.ClearClubFinderPostingsCache))
            end,
            DoesPlayerBelongToClubFromClubGUID = function()
              assertEquals('function', type(ns.DoesPlayerBelongToClubFromClubGUID))
            end,
            GetClubFinderDisableReason = function()
              assertEquals('function', type(ns.GetClubFinderDisableReason))
            end,
            GetClubRecruitmentSettings = function()
              assertEquals('function', type(ns.GetClubRecruitmentSettings))
            end,
            GetClubTypeFromFinderGUID = function()
              assertEquals('function', type(ns.GetClubTypeFromFinderGUID))
            end,
            GetFocusIndexFromFlag = function()
              assertEquals('function', type(ns.GetFocusIndexFromFlag))
            end,
            GetPlayerApplicantLocaleFlags = function()
              assertEquals('function', type(ns.GetPlayerApplicantLocaleFlags))
            end,
            GetPlayerApplicantSettings = function()
              assertEquals('function', type(ns.GetPlayerApplicantSettings))
            end,
            GetPlayerClubApplicationStatus = function()
              assertEquals('function', type(ns.GetPlayerClubApplicationStatus))
            end,
            GetPlayerSettingsFocusFlagsSelectedCount = function()
              assertEquals('function', type(ns.GetPlayerSettingsFocusFlagsSelectedCount))
            end,
            GetPostingIDFromClubFinderGUID = function()
              assertEquals('function', type(ns.GetPostingIDFromClubFinderGUID))
            end,
            GetRecruitingClubInfoFromClubID = function()
              assertEquals('function', type(ns.GetRecruitingClubInfoFromClubID))
            end,
            GetRecruitingClubInfoFromFinderGUID = function()
              assertEquals('function', type(ns.GetRecruitingClubInfoFromFinderGUID))
            end,
            GetStatusOfPostingFromClubId = function()
              assertEquals('function', type(ns.GetStatusOfPostingFromClubId))
            end,
            GetTotalMatchingCommunityListSize = function()
              assertEquals('function', type(ns.GetTotalMatchingCommunityListSize))
            end,
            GetTotalMatchingGuildListSize = function()
              assertEquals('function', type(ns.GetTotalMatchingGuildListSize))
            end,
            HasAlreadyAppliedToLinkedPosting = function()
              assertEquals('function', type(ns.HasAlreadyAppliedToLinkedPosting))
            end,
            HasPostingBeenDelisted = function()
              assertEquals('function', type(ns.HasPostingBeenDelisted))
            end,
            IsEnabled = function()
              assertEquals('function', type(ns.IsEnabled))
            end,
            IsListingEnabledFromFlags = function()
              assertEquals('function', type(ns.IsListingEnabledFromFlags))
            end,
            IsPostingBanned = function()
              assertEquals('function', type(ns.IsPostingBanned))
            end,
            LookupClubPostingFromClubFinderGUID = function()
              assertEquals('function', type(ns.LookupClubPostingFromClubFinderGUID))
            end,
            PlayerGetClubInvitationList = function()
              assertEquals('function', type(ns.PlayerGetClubInvitationList))
            end,
            PlayerRequestPendingClubsList = function()
              assertEquals('function', type(ns.PlayerRequestPendingClubsList))
            end,
            PlayerReturnPendingCommunitiesList = function()
              assertEquals('function', type(ns.PlayerReturnPendingCommunitiesList))
            end,
            PlayerReturnPendingGuildsList = function()
              assertEquals('function', type(ns.PlayerReturnPendingGuildsList))
            end,
            PostClub = function()
              assertEquals('function', type(ns.PostClub))
            end,
            RequestApplicantList = function()
              assertEquals('function', type(ns.RequestApplicantList))
            end,
            RequestClubsList = function()
              assertEquals('function', type(ns.RequestClubsList))
            end,
            RequestMembershipToClub = function()
              assertEquals('function', type(ns.RequestMembershipToClub))
            end,
            RequestNextCommunityPage = function()
              assertEquals('function', type(ns.RequestNextCommunityPage))
            end,
            RequestNextGuildPage = function()
              assertEquals('function', type(ns.RequestNextGuildPage))
            end,
            RequestPostingInformationFromClubId = function()
              assertEquals('function', type(ns.RequestPostingInformationFromClubId))
            end,
            RequestSubscribedClubPostingIDs = function()
              assertEquals('function', type(ns.RequestSubscribedClubPostingIDs))
            end,
            ResetClubPostingMapCache = function()
              assertEquals('function', type(ns.ResetClubPostingMapCache))
            end,
            RespondToApplicant = function()
              assertEquals('function', type(ns.RespondToApplicant))
            end,
            ReturnClubApplicantList = function()
              assertEquals('function', type(ns.ReturnClubApplicantList))
            end,
            ReturnMatchingCommunityList = function()
              assertEquals('function', type(ns.ReturnMatchingCommunityList))
            end,
            ReturnMatchingGuildList = function()
              assertEquals('function', type(ns.ReturnMatchingGuildList))
            end,
            ReturnPendingClubApplicantList = function()
              assertEquals('function', type(ns.ReturnPendingClubApplicantList))
            end,
            SendChatWhisper = function()
              assertEquals('function', type(ns.SendChatWhisper))
            end,
            SetAllRecruitmentSettings = function()
              assertEquals('function', type(ns.SetAllRecruitmentSettings))
            end,
            SetPlayerApplicantLocaleFlags = function()
              assertEquals('function', type(ns.SetPlayerApplicantLocaleFlags))
            end,
            SetPlayerApplicantSettings = function()
              assertEquals('function', type(ns.SetPlayerApplicantSettings))
            end,
            SetRecruitmentLocale = function()
              assertEquals('function', type(ns.SetRecruitmentLocale))
            end,
            SetRecruitmentSettings = function()
              assertEquals('function', type(ns.SetRecruitmentSettings))
            end,
            ShouldShowClubFinder = function()
              assertEquals('function', type(ns.ShouldShowClubFinder))
            end,
          }
        end,
        C_Commentator = function()
          local ns = _G.C_Commentator
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            AddPlayerOverrideName = function()
              assertEquals('function', type(ns.AddPlayerOverrideName))
            end,
            AddTrackedDefensiveAuras = function()
              assertEquals('function', type(ns.AddTrackedDefensiveAuras))
            end,
            AddTrackedOffensiveAuras = function()
              assertEquals('function', type(ns.AddTrackedOffensiveAuras))
            end,
            AreTeamsSwapped = function()
              assertEquals('function', type(ns.AreTeamsSwapped))
            end,
            AssignPlayerToTeam = function()
              assertEquals('function', type(ns.AssignPlayerToTeam))
            end,
            AssignPlayersToTeam = function()
              assertEquals('function', type(ns.AssignPlayersToTeam))
            end,
            AssignPlayersToTeamInCurrentInstance = function()
              assertEquals('function', type(ns.AssignPlayersToTeamInCurrentInstance))
            end,
            CanUseCommentatorCheats = function()
              assertEquals('function', type(ns.CanUseCommentatorCheats))
            end,
            ClearCameraTarget = function()
              assertEquals('function', type(ns.ClearCameraTarget))
            end,
            ClearFollowTarget = function()
              assertEquals('function', type(ns.ClearFollowTarget))
            end,
            ClearLookAtTarget = function()
              assertEquals('function', type(ns.ClearLookAtTarget))
            end,
            EnterInstance = function()
              assertEquals('function', type(ns.EnterInstance))
            end,
            ExitInstance = function()
              assertEquals('function', type(ns.ExitInstance))
            end,
            FindSpectatedUnit = function()
              assertEquals('function', type(ns.FindSpectatedUnit))
            end,
            FindTeamNameInCurrentInstance = function()
              assertEquals('function', type(ns.FindTeamNameInCurrentInstance))
            end,
            FindTeamNameInDirectory = function()
              assertEquals('function', type(ns.FindTeamNameInDirectory))
            end,
            FlushCommentatorHistory = function()
              assertEquals('function', type(ns.FlushCommentatorHistory))
            end,
            FollowPlayer = function()
              assertEquals('function', type(ns.FollowPlayer))
            end,
            FollowUnit = function()
              assertEquals('function', type(ns.FollowUnit))
            end,
            ForceFollowTransition = function()
              assertEquals('function', type(ns.ForceFollowTransition))
            end,
            GetAdditionalCameraWeight = function()
              assertEquals('function', type(ns.GetAdditionalCameraWeight))
            end,
            GetAdditionalCameraWeightByToken = function()
              assertEquals('function', type(ns.GetAdditionalCameraWeightByToken))
            end,
            GetAllPlayerOverrideNames = function()
              assertEquals('function', type(ns.GetAllPlayerOverrideNames))
            end,
            GetCamera = function()
              assertEquals('function', type(ns.GetCamera))
            end,
            GetCameraCollision = function()
              assertEquals('function', type(ns.GetCameraCollision))
            end,
            GetCameraPosition = function()
              assertEquals('function', type(ns.GetCameraPosition))
            end,
            GetCommentatorHistory = function()
              assertEquals('function', type(ns.GetCommentatorHistory))
            end,
            GetCurrentMapID = function()
              assertEquals('function', type(ns.GetCurrentMapID))
            end,
            GetDampeningPercent = function()
              assertEquals('function', type(ns.GetDampeningPercent))
            end,
            GetDistanceBeforeForcedHorizontalConvergence = function()
              assertEquals('function', type(ns.GetDistanceBeforeForcedHorizontalConvergence))
            end,
            GetDurationToForceHorizontalConvergence = function()
              assertEquals('function', type(ns.GetDurationToForceHorizontalConvergence))
            end,
            GetExcludeDistance = function()
              assertEquals('function', type(ns.GetExcludeDistance))
            end,
            GetHardlockWeight = function()
              assertEquals('function', type(ns.GetHardlockWeight))
            end,
            GetHorizontalAngleThresholdToSmooth = function()
              assertEquals('function', type(ns.GetHorizontalAngleThresholdToSmooth))
            end,
            GetIndirectSpellID = function()
              assertEquals('function', type(ns.GetIndirectSpellID))
            end,
            GetInstanceInfo = function()
              assertEquals('function', type(ns.GetInstanceInfo))
            end,
            GetLookAtLerpAmount = function()
              assertEquals('function', type(ns.GetLookAtLerpAmount))
            end,
            GetMapInfo = function()
              assertEquals('function', type(ns.GetMapInfo))
            end,
            GetMatchDuration = function()
              assertEquals('function', type(ns.GetMatchDuration))
            end,
            GetMaxNumPlayersPerTeam = function()
              assertEquals('function', type(ns.GetMaxNumPlayersPerTeam))
            end,
            GetMaxNumTeams = function()
              assertEquals('function', type(ns.GetMaxNumTeams))
            end,
            GetMode = function()
              assertEquals('function', type(ns.GetMode))
            end,
            GetMsToHoldForHorizontalMovement = function()
              assertEquals('function', type(ns.GetMsToHoldForHorizontalMovement))
            end,
            GetMsToHoldForVerticalMovement = function()
              assertEquals('function', type(ns.GetMsToHoldForVerticalMovement))
            end,
            GetMsToSmoothHorizontalChange = function()
              assertEquals('function', type(ns.GetMsToSmoothHorizontalChange))
            end,
            GetMsToSmoothVerticalChange = function()
              assertEquals('function', type(ns.GetMsToSmoothVerticalChange))
            end,
            GetNumMaps = function()
              assertEquals('function', type(ns.GetNumMaps))
            end,
            GetNumPlayers = function()
              assertEquals('function', type(ns.GetNumPlayers))
            end,
            GetOrCreateSeries = function()
              assertEquals('function', type(ns.GetOrCreateSeries))
            end,
            GetPlayerAuraInfo = function()
              assertEquals('function', type(ns.GetPlayerAuraInfo))
            end,
            GetPlayerAuraInfoByUnit = function()
              assertEquals('function', type(ns.GetPlayerAuraInfoByUnit))
            end,
            GetPlayerCooldownInfo = function()
              assertEquals('function', type(ns.GetPlayerCooldownInfo))
            end,
            GetPlayerCooldownInfoByUnit = function()
              assertEquals('function', type(ns.GetPlayerCooldownInfoByUnit))
            end,
            GetPlayerCrowdControlInfo = function()
              assertEquals('function', type(ns.GetPlayerCrowdControlInfo))
            end,
            GetPlayerCrowdControlInfoByUnit = function()
              assertEquals('function', type(ns.GetPlayerCrowdControlInfoByUnit))
            end,
            GetPlayerData = function()
              assertEquals('function', type(ns.GetPlayerData))
            end,
            GetPlayerFlagInfo = function()
              assertEquals('function', type(ns.GetPlayerFlagInfo))
            end,
            GetPlayerFlagInfoByUnit = function()
              assertEquals('function', type(ns.GetPlayerFlagInfoByUnit))
            end,
            GetPlayerOverrideName = function()
              assertEquals('function', type(ns.GetPlayerOverrideName))
            end,
            GetPlayerSpellCharges = function()
              assertEquals('function', type(ns.GetPlayerSpellCharges))
            end,
            GetPlayerSpellChargesByUnit = function()
              assertEquals('function', type(ns.GetPlayerSpellChargesByUnit))
            end,
            GetPositionLerpAmount = function()
              assertEquals('function', type(ns.GetPositionLerpAmount))
            end,
            GetSmoothFollowTransitioning = function()
              assertEquals('function', type(ns.GetSmoothFollowTransitioning))
            end,
            GetSoftlockWeight = function()
              assertEquals('function', type(ns.GetSoftlockWeight))
            end,
            GetSpeedFactor = function()
              assertEquals('function', type(ns.GetSpeedFactor))
            end,
            GetStartLocation = function()
              assertEquals('function', type(ns.GetStartLocation))
            end,
            GetTeamColor = function()
              assertEquals('function', type(ns.GetTeamColor))
            end,
            GetTeamColorByUnit = function()
              assertEquals('function', type(ns.GetTeamColorByUnit))
            end,
            GetTimeLeftInMatch = function()
              assertEquals('function', type(ns.GetTimeLeftInMatch))
            end,
            GetTrackedSpellID = function()
              assertEquals('function', type(ns.GetTrackedSpellID))
            end,
            GetTrackedSpells = function()
              assertEquals('function', type(ns.GetTrackedSpells))
            end,
            GetTrackedSpellsByUnit = function()
              assertEquals('function', type(ns.GetTrackedSpellsByUnit))
            end,
            GetUnitData = function()
              assertEquals('function', type(ns.GetUnitData))
            end,
            GetWargameInfo = function()
              assertEquals('function', type(ns.GetWargameInfo))
            end,
            HasTrackedAuras = function()
              assertEquals('function', type(ns.HasTrackedAuras))
            end,
            IsSmartCameraLocked = function()
              assertEquals('function', type(ns.IsSmartCameraLocked))
            end,
            IsSpectating = function()
              assertEquals('function', type(ns.IsSpectating))
            end,
            IsTrackedDefensiveAura = function()
              assertEquals('function', type(ns.IsTrackedDefensiveAura))
            end,
            IsTrackedOffensiveAura = function()
              assertEquals('function', type(ns.IsTrackedOffensiveAura))
            end,
            IsTrackedSpell = function()
              assertEquals('function', type(ns.IsTrackedSpell))
            end,
            IsTrackedSpellByUnit = function()
              assertEquals('function', type(ns.IsTrackedSpellByUnit))
            end,
            IsUsingSmartCamera = function()
              assertEquals('function', type(ns.IsUsingSmartCamera))
            end,
            LookAtPlayer = function()
              assertEquals('function', type(ns.LookAtPlayer))
            end,
            RemoveAllOverrideNames = function()
              assertEquals('function', type(ns.RemoveAllOverrideNames))
            end,
            RemovePlayerOverrideName = function()
              assertEquals('function', type(ns.RemovePlayerOverrideName))
            end,
            RequestPlayerCooldownInfo = function()
              assertEquals('function', type(ns.RequestPlayerCooldownInfo))
            end,
            ResetFoVTarget = function()
              assertEquals('function', type(ns.ResetFoVTarget))
            end,
            ResetSeriesScores = function()
              assertEquals('function', type(ns.ResetSeriesScores))
            end,
            ResetSettings = function()
              assertEquals('function', type(ns.ResetSettings))
            end,
            ResetTrackedAuras = function()
              assertEquals('function', type(ns.ResetTrackedAuras))
            end,
            SetAdditionalCameraWeight = function()
              assertEquals('function', type(ns.SetAdditionalCameraWeight))
            end,
            SetAdditionalCameraWeightByToken = function()
              assertEquals('function', type(ns.SetAdditionalCameraWeightByToken))
            end,
            SetBlocklistedAuras = function()
              assertEquals('function', type(ns.SetBlocklistedAuras))
            end,
            SetBlocklistedCooldowns = function()
              assertEquals('function', type(ns.SetBlocklistedCooldowns))
            end,
            SetCamera = function()
              assertEquals('function', type(ns.SetCamera))
            end,
            SetCameraCollision = function()
              assertEquals('function', type(ns.SetCameraCollision))
            end,
            SetCameraPosition = function()
              assertEquals('function', type(ns.SetCameraPosition))
            end,
            SetCheatsEnabled = function()
              assertEquals('function', type(ns.SetCheatsEnabled))
            end,
            SetCommentatorHistory = function()
              assertEquals('function', type(ns.SetCommentatorHistory))
            end,
            SetDistanceBeforeForcedHorizontalConvergence = function()
              assertEquals('function', type(ns.SetDistanceBeforeForcedHorizontalConvergence))
            end,
            SetDurationToForceHorizontalConvergence = function()
              assertEquals('function', type(ns.SetDurationToForceHorizontalConvergence))
            end,
            SetExcludeDistance = function()
              assertEquals('function', type(ns.SetExcludeDistance))
            end,
            SetFollowCameraSpeeds = function()
              assertEquals('function', type(ns.SetFollowCameraSpeeds))
            end,
            SetHardlockWeight = function()
              assertEquals('function', type(ns.SetHardlockWeight))
            end,
            SetHorizontalAngleThresholdToSmooth = function()
              assertEquals('function', type(ns.SetHorizontalAngleThresholdToSmooth))
            end,
            SetLookAtLerpAmount = function()
              assertEquals('function', type(ns.SetLookAtLerpAmount))
            end,
            SetMapAndInstanceIndex = function()
              assertEquals('function', type(ns.SetMapAndInstanceIndex))
            end,
            SetMouseDisabled = function()
              assertEquals('function', type(ns.SetMouseDisabled))
            end,
            SetMoveSpeed = function()
              assertEquals('function', type(ns.SetMoveSpeed))
            end,
            SetMsToHoldForHorizontalMovement = function()
              assertEquals('function', type(ns.SetMsToHoldForHorizontalMovement))
            end,
            SetMsToHoldForVerticalMovement = function()
              assertEquals('function', type(ns.SetMsToHoldForVerticalMovement))
            end,
            SetMsToSmoothHorizontalChange = function()
              assertEquals('function', type(ns.SetMsToSmoothHorizontalChange))
            end,
            SetMsToSmoothVerticalChange = function()
              assertEquals('function', type(ns.SetMsToSmoothVerticalChange))
            end,
            SetPositionLerpAmount = function()
              assertEquals('function', type(ns.SetPositionLerpAmount))
            end,
            SetRequestedDebuffCooldowns = function()
              assertEquals('function', type(ns.SetRequestedDebuffCooldowns))
            end,
            SetRequestedDefensiveCooldowns = function()
              assertEquals('function', type(ns.SetRequestedDefensiveCooldowns))
            end,
            SetRequestedOffensiveCooldowns = function()
              assertEquals('function', type(ns.SetRequestedOffensiveCooldowns))
            end,
            SetSeriesScore = function()
              assertEquals('function', type(ns.SetSeriesScore))
            end,
            SetSeriesScores = function()
              assertEquals('function', type(ns.SetSeriesScores))
            end,
            SetSmartCameraLocked = function()
              assertEquals('function', type(ns.SetSmartCameraLocked))
            end,
            SetSmoothFollowTransitioning = function()
              assertEquals('function', type(ns.SetSmoothFollowTransitioning))
            end,
            SetSoftlockWeight = function()
              assertEquals('function', type(ns.SetSoftlockWeight))
            end,
            SetSpeedFactor = function()
              assertEquals('function', type(ns.SetSpeedFactor))
            end,
            SetTargetHeightOffset = function()
              assertEquals('function', type(ns.SetTargetHeightOffset))
            end,
            SetUseSmartCamera = function()
              assertEquals('function', type(ns.SetUseSmartCamera))
            end,
            SnapCameraLookAtPoint = function()
              assertEquals('function', type(ns.SnapCameraLookAtPoint))
            end,
            StartWargame = function()
              assertEquals('function', type(ns.StartWargame))
            end,
            SwapTeamSides = function()
              assertEquals('function', type(ns.SwapTeamSides))
            end,
            ToggleCheats = function()
              assertEquals('function', type(ns.ToggleCheats))
            end,
            UpdateMapInfo = function()
              assertEquals('function', type(ns.UpdateMapInfo))
            end,
            UpdatePlayerInfo = function()
              assertEquals('function', type(ns.UpdatePlayerInfo))
            end,
            ZoomIn = function()
              assertEquals('function', type(ns.ZoomIn))
            end,
            ZoomOut = function()
              assertEquals('function', type(ns.ZoomOut))
            end,
          }
        end,
        C_Console = function()
          local ns = _G.C_Console
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetAllCommands = function()
              assertEquals('function', type(ns.GetAllCommands))
            end,
            GetColorFromType = function()
              assertEquals('function', type(ns.GetColorFromType))
            end,
            GetFontHeight = function()
              assertEquals('function', type(ns.GetFontHeight))
            end,
            PrintAllMatchingCommands = function()
              assertEquals('function', type(ns.PrintAllMatchingCommands))
            end,
            SetFontHeight = function()
              assertEquals('function', type(ns.SetFontHeight))
            end,
          }
        end,
        C_ContributionCollector = function()
          local ns = _G.C_ContributionCollector
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            Close = function()
              assertEquals('function', type(ns.Close))
            end,
            Contribute = function()
              assertEquals('function', type(ns.Contribute))
            end,
            GetActive = function()
              assertEquals('function', type(ns.GetActive))
            end,
            GetAtlases = function()
              assertEquals('function', type(ns.GetAtlases))
            end,
            GetBuffs = function()
              assertEquals('function', type(ns.GetBuffs))
            end,
            GetContributionAppearance = function()
              assertEquals('function', type(ns.GetContributionAppearance))
            end,
            GetContributionCollectorsForMap = function()
              assertEquals('function', type(ns.GetContributionCollectorsForMap))
            end,
            GetContributionResult = function()
              assertEquals('function', type(ns.GetContributionResult))
            end,
            GetDescription = function()
              assertEquals('function', type(ns.GetDescription))
            end,
            GetManagedContributionsForCreatureID = function()
              assertEquals('function', type(ns.GetManagedContributionsForCreatureID))
            end,
            GetName = function()
              assertEquals('function', type(ns.GetName))
            end,
            GetOrderIndex = function()
              assertEquals('function', type(ns.GetOrderIndex))
            end,
            GetRequiredContributionCurrency = function()
              assertEquals('function', type(ns.GetRequiredContributionCurrency))
            end,
            GetRequiredContributionItem = function()
              assertEquals('function', type(ns.GetRequiredContributionItem))
            end,
            GetRewardQuestID = function()
              assertEquals('function', type(ns.GetRewardQuestID))
            end,
            GetState = function()
              assertEquals('function', type(ns.GetState))
            end,
            HasPendingContribution = function()
              assertEquals('function', type(ns.HasPendingContribution))
            end,
            IsAwaitingRewardQuestData = function()
              assertEquals('function', type(ns.IsAwaitingRewardQuestData))
            end,
          }
        end,
        C_CovenantCallings = function()
          local ns = _G.C_CovenantCallings
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            AreCallingsUnlocked = function()
              assertEquals('function', type(ns.AreCallingsUnlocked))
            end,
            RequestCallings = function()
              assertEquals('function', type(ns.RequestCallings))
            end,
          }
        end,
        C_CovenantPreview = function()
          local ns = _G.C_CovenantPreview
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            CloseFromUI = function()
              assertEquals('function', type(ns.CloseFromUI))
            end,
            GetCovenantInfoForPlayerChoiceResponseID = function()
              assertEquals('function', type(ns.GetCovenantInfoForPlayerChoiceResponseID))
            end,
          }
        end,
        C_CovenantSanctumUI = function()
          local ns = _G.C_CovenantSanctumUI
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            CanAccessReservoir = function()
              assertEquals('function', type(ns.CanAccessReservoir))
            end,
            CanDepositAnima = function()
              assertEquals('function', type(ns.CanDepositAnima))
            end,
            DepositAnima = function()
              assertEquals('function', type(ns.DepositAnima))
            end,
            EndInteraction = function()
              assertEquals('function', type(ns.EndInteraction))
            end,
            GetAnimaInfo = function()
              assertEquals('function', type(ns.GetAnimaInfo))
            end,
            GetCurrentTalentTreeID = function()
              assertEquals('function', type(ns.GetCurrentTalentTreeID))
            end,
            GetFeatures = function()
              assertEquals('function', type(ns.GetFeatures))
            end,
            GetRenownLevel = function()
              assertEquals('function', type(ns.GetRenownLevel))
            end,
            GetRenownLevels = function()
              assertEquals('function', type(ns.GetRenownLevels))
            end,
            GetRenownRewardsForLevel = function()
              assertEquals('function', type(ns.GetRenownRewardsForLevel))
            end,
            GetSanctumType = function()
              assertEquals('function', type(ns.GetSanctumType))
            end,
            GetSoulCurrencies = function()
              assertEquals('function', type(ns.GetSoulCurrencies))
            end,
            HasMaximumRenown = function()
              assertEquals('function', type(ns.HasMaximumRenown))
            end,
            IsPlayerInRenownCatchUpMode = function()
              assertEquals('function', type(ns.IsPlayerInRenownCatchUpMode))
            end,
            IsWeeklyRenownCapped = function()
              assertEquals('function', type(ns.IsWeeklyRenownCapped))
            end,
            RequestCatchUpState = function()
              assertEquals('function', type(ns.RequestCatchUpState))
            end,
          }
        end,
        C_Covenants = function()
          local ns = _G.C_Covenants
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetActiveCovenantID = function()
              assertEquals('function', type(ns.GetActiveCovenantID))
            end,
            GetCovenantData = function()
              assertEquals('function', type(ns.GetCovenantData))
            end,
            GetCovenantIDs = function()
              assertEquals('function', type(ns.GetCovenantIDs))
            end,
          }
        end,
        C_CreatureInfo = function()
          local ns = _G.C_CreatureInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetClassInfo = function()
              assertEquals('function', type(ns.GetClassInfo))
            end,
            GetFactionInfo = function()
              assertEquals('function', type(ns.GetFactionInfo))
            end,
            GetRaceInfo = function()
              assertEquals('function', type(ns.GetRaceInfo))
            end,
          }
        end,
        C_CurrencyInfo = function()
          local ns = _G.C_CurrencyInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            DoesWarModeBonusApply = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.DoesWarModeBonusApply))
                return
              end
              assertEquals('function', type(ns.DoesWarModeBonusApply))
            end,
            ExpandCurrencyList = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ExpandCurrencyList))
                return
              end
              assertEquals('function', type(ns.ExpandCurrencyList))
            end,
            GetAzeriteCurrencyID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetAzeriteCurrencyID))
                return
              end
              assertEquals('function', type(ns.GetAzeriteCurrencyID))
            end,
            GetBackpackCurrencyInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetBackpackCurrencyInfo))
                return
              end
              assertEquals('function', type(ns.GetBackpackCurrencyInfo))
            end,
            GetBasicCurrencyInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetBasicCurrencyInfo))
                return
              end
              assertEquals('function', type(ns.GetBasicCurrencyInfo))
            end,
            GetCurrencyContainerInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetCurrencyContainerInfo))
                return
              end
              assertEquals('function', type(ns.GetCurrencyContainerInfo))
            end,
            GetCurrencyIDFromLink = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetCurrencyIDFromLink))
                return
              end
              assertEquals('function', type(ns.GetCurrencyIDFromLink))
            end,
            GetCurrencyInfo = function()
              assertEquals('function', type(ns.GetCurrencyInfo))
            end,
            GetCurrencyInfoFromLink = function()
              assertEquals('function', type(ns.GetCurrencyInfoFromLink))
            end,
            GetCurrencyLink = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetCurrencyLink))
                return
              end
              assertEquals('function', type(ns.GetCurrencyLink))
            end,
            GetCurrencyListInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetCurrencyListInfo))
                return
              end
              assertEquals('function', type(ns.GetCurrencyListInfo))
            end,
            GetCurrencyListLink = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetCurrencyListLink))
                return
              end
              assertEquals('function', type(ns.GetCurrencyListLink))
            end,
            GetCurrencyListSize = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetCurrencyListSize))
                return
              end
              assertEquals('function', type(ns.GetCurrencyListSize))
            end,
            GetFactionGrantedByCurrency = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetFactionGrantedByCurrency))
                return
              end
              assertEquals('function', type(ns.GetFactionGrantedByCurrency))
            end,
            GetWarResourcesCurrencyID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetWarResourcesCurrencyID))
                return
              end
              assertEquals('function', type(ns.GetWarResourcesCurrencyID))
            end,
            IsCurrencyContainer = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsCurrencyContainer))
                return
              end
              assertEquals('function', type(ns.IsCurrencyContainer))
            end,
            PickupCurrency = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.PickupCurrency))
                return
              end
              assertEquals('function', type(ns.PickupCurrency))
            end,
            SetCurrencyBackpack = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetCurrencyBackpack))
                return
              end
              assertEquals('function', type(ns.SetCurrencyBackpack))
            end,
            SetCurrencyUnused = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetCurrencyUnused))
                return
              end
              assertEquals('function', type(ns.SetCurrencyUnused))
            end,
          }
        end,
        C_Cursor = function()
          local ns = _G.C_Cursor
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            DropCursorCommunitiesStream = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.DropCursorCommunitiesStream))
                return
              end
              assertEquals('function', type(ns.DropCursorCommunitiesStream))
            end,
            GetCursorCommunitiesStream = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetCursorCommunitiesStream))
                return
              end
              assertEquals('function', type(ns.GetCursorCommunitiesStream))
            end,
            GetCursorItem = function()
              assertEquals('function', type(ns.GetCursorItem))
            end,
            SetCursorCommunitiesStream = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetCursorCommunitiesStream))
                return
              end
              assertEquals('function', type(ns.SetCursorCommunitiesStream))
            end,
          }
        end,
        C_DateAndTime = function()
          local ns = _G.C_DateAndTime
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            AdjustTimeByDays = function()
              assertEquals('function', type(ns.AdjustTimeByDays))
            end,
            AdjustTimeByMinutes = function()
              assertEquals('function', type(ns.AdjustTimeByMinutes))
            end,
            CompareCalendarTime = function()
              assertEquals('function', type(ns.CompareCalendarTime))
            end,
            GetCalendarTimeFromEpoch = function()
              assertEquals('function', type(ns.GetCalendarTimeFromEpoch))
            end,
            GetCurrentCalendarTime = function()
              assertEquals('function', type(ns.GetCurrentCalendarTime))
            end,
            GetSecondsUntilDailyReset = function()
              assertEquals('function', type(ns.GetSecondsUntilDailyReset))
            end,
            GetSecondsUntilWeeklyReset = function()
              assertEquals('function', type(ns.GetSecondsUntilWeeklyReset))
            end,
            GetServerTimeLocal = function()
              assertEquals('function', type(ns.GetServerTimeLocal))
            end,
          }
        end,
        C_DeathInfo = function()
          local ns = _G.C_DeathInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetCorpseMapPosition = function()
              assertEquals('function', type(ns.GetCorpseMapPosition))
            end,
            GetDeathReleasePosition = function()
              assertEquals('function', type(ns.GetDeathReleasePosition))
            end,
            GetGraveyardsForMap = function()
              assertEquals('function', type(ns.GetGraveyardsForMap))
            end,
            GetSelfResurrectOptions = function()
              assertEquals('function', type(ns.GetSelfResurrectOptions))
            end,
            UseSelfResurrectOption = function()
              assertEquals('function', type(ns.UseSelfResurrectOption))
            end,
          }
        end,
        C_EncounterJournal = function()
          local ns = _G.C_EncounterJournal
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetDungeonEntrancesForMap = function()
              assertEquals('function', type(ns.GetDungeonEntrancesForMap))
            end,
            GetEncountersOnMap = function()
              assertEquals('function', type(ns.GetEncountersOnMap))
            end,
            GetLootInfo = function()
              assertEquals('function', type(ns.GetLootInfo))
            end,
            GetLootInfoByIndex = function()
              assertEquals('function', type(ns.GetLootInfoByIndex))
            end,
            GetSectionIconFlags = function()
              assertEquals('function', type(ns.GetSectionIconFlags))
            end,
            GetSectionInfo = function()
              assertEquals('function', type(ns.GetSectionInfo))
            end,
            GetSlotFilter = function()
              assertEquals('function', type(ns.GetSlotFilter))
            end,
            InstanceHasLoot = function()
              assertEquals('function', type(ns.InstanceHasLoot))
            end,
            IsEncounterComplete = function()
              assertEquals('function', type(ns.IsEncounterComplete))
            end,
            ResetSlotFilter = function()
              assertEquals('function', type(ns.ResetSlotFilter))
            end,
            SetPreviewMythicPlusLevel = function()
              assertEquals('function', type(ns.SetPreviewMythicPlusLevel))
            end,
            SetPreviewPvpTier = function()
              assertEquals('function', type(ns.SetPreviewPvpTier))
            end,
            SetSlotFilter = function()
              assertEquals('function', type(ns.SetSlotFilter))
            end,
          }
        end,
        C_EquipmentSet = function()
          local ns = _G.C_EquipmentSet
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            AssignSpecToEquipmentSet = function()
              assertEquals('function', type(ns.AssignSpecToEquipmentSet))
            end,
            CanUseEquipmentSets = function()
              assertEquals('function', type(ns.CanUseEquipmentSets))
            end,
            ClearIgnoredSlotsForSave = function()
              assertEquals('function', type(ns.ClearIgnoredSlotsForSave))
            end,
            CreateEquipmentSet = function()
              assertEquals('function', type(ns.CreateEquipmentSet))
            end,
            DeleteEquipmentSet = function()
              assertEquals('function', type(ns.DeleteEquipmentSet))
            end,
            EquipmentSetContainsLockedItems = function()
              assertEquals('function', type(ns.EquipmentSetContainsLockedItems))
            end,
            GetEquipmentSetAssignedSpec = function()
              assertEquals('function', type(ns.GetEquipmentSetAssignedSpec))
            end,
            GetEquipmentSetForSpec = function()
              assertEquals('function', type(ns.GetEquipmentSetForSpec))
            end,
            GetEquipmentSetID = function()
              assertEquals('function', type(ns.GetEquipmentSetID))
            end,
            GetEquipmentSetIDs = function()
              assertEquals('function', type(ns.GetEquipmentSetIDs))
            end,
            GetEquipmentSetInfo = function()
              assertEquals('function', type(ns.GetEquipmentSetInfo))
            end,
            GetIgnoredSlots = function()
              assertEquals('function', type(ns.GetIgnoredSlots))
            end,
            GetItemIDs = function()
              assertEquals('function', type(ns.GetItemIDs))
            end,
            GetItemLocations = function()
              assertEquals('function', type(ns.GetItemLocations))
            end,
            GetNumEquipmentSets = function()
              assertEquals('function', type(ns.GetNumEquipmentSets))
            end,
            IgnoreSlotForSave = function()
              assertEquals('function', type(ns.IgnoreSlotForSave))
            end,
            IsSlotIgnoredForSave = function()
              assertEquals('function', type(ns.IsSlotIgnoredForSave))
            end,
            ModifyEquipmentSet = function()
              assertEquals('function', type(ns.ModifyEquipmentSet))
            end,
            PickupEquipmentSet = function()
              assertEquals('function', type(ns.PickupEquipmentSet))
            end,
            SaveEquipmentSet = function()
              assertEquals('function', type(ns.SaveEquipmentSet))
            end,
            UnassignEquipmentSetSpec = function()
              assertEquals('function', type(ns.UnassignEquipmentSetSpec))
            end,
            UnignoreSlotForSave = function()
              assertEquals('function', type(ns.UnignoreSlotForSave))
            end,
            UseEquipmentSet = function()
              assertEquals('function', type(ns.UseEquipmentSet))
            end,
          }
        end,
        C_EventToastManager = function()
          local ns = _G.C_EventToastManager
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetLevelUpDisplayToastsFromLevel = function()
              assertEquals('function', type(ns.GetLevelUpDisplayToastsFromLevel))
            end,
            GetNextToastToDisplay = function()
              assertEquals('function', type(ns.GetNextToastToDisplay))
            end,
            RemoveCurrentToast = function()
              assertEquals('function', type(ns.RemoveCurrentToast))
            end,
          }
        end,
        C_FogOfWar = function()
          local ns = _G.C_FogOfWar
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetFogOfWarForMap = function()
              assertEquals('function', type(ns.GetFogOfWarForMap))
            end,
            GetFogOfWarInfo = function()
              assertEquals('function', type(ns.GetFogOfWarInfo))
            end,
          }
        end,
        C_FrameManager = function()
          local ns = _G.C_FrameManager
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetFrameVisibilityState = function()
              assertEquals('function', type(ns.GetFrameVisibilityState))
            end,
          }
        end,
        C_FriendList = function()
          local ns = _G.C_FriendList
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            AddFriend = function()
              assertEquals('function', type(ns.AddFriend))
            end,
            AddIgnore = function()
              assertEquals('function', type(ns.AddIgnore))
            end,
            AddOrDelIgnore = function()
              assertEquals('function', type(ns.AddOrDelIgnore))
            end,
            AddOrRemoveFriend = function()
              assertEquals('function', type(ns.AddOrRemoveFriend))
            end,
            DelIgnore = function()
              assertEquals('function', type(ns.DelIgnore))
            end,
            DelIgnoreByIndex = function()
              assertEquals('function', type(ns.DelIgnoreByIndex))
            end,
            GetFriendInfo = function()
              assertEquals('function', type(ns.GetFriendInfo))
            end,
            GetFriendInfoByIndex = function()
              assertEquals('function', type(ns.GetFriendInfoByIndex))
            end,
            GetIgnoreName = function()
              assertEquals('function', type(ns.GetIgnoreName))
            end,
            GetNumFriends = function()
              assertEquals('function', type(ns.GetNumFriends))
            end,
            GetNumIgnores = function()
              assertEquals('function', type(ns.GetNumIgnores))
            end,
            GetNumOnlineFriends = function()
              assertEquals('function', type(ns.GetNumOnlineFriends))
            end,
            GetNumWhoResults = function()
              assertEquals('function', type(ns.GetNumWhoResults))
            end,
            GetSelectedFriend = function()
              assertEquals('function', type(ns.GetSelectedFriend))
            end,
            GetSelectedIgnore = function()
              assertEquals('function', type(ns.GetSelectedIgnore))
            end,
            GetWhoInfo = function()
              assertEquals('function', type(ns.GetWhoInfo))
            end,
            IsFriend = function()
              assertEquals('function', type(ns.IsFriend))
            end,
            IsIgnored = function()
              assertEquals('function', type(ns.IsIgnored))
            end,
            IsIgnoredByGuid = function()
              assertEquals('function', type(ns.IsIgnoredByGuid))
            end,
            IsOnIgnoredList = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsOnIgnoredList))
                return
              end
              assertEquals('function', type(ns.IsOnIgnoredList))
            end,
            RemoveFriend = function()
              assertEquals('function', type(ns.RemoveFriend))
            end,
            RemoveFriendByIndex = function()
              assertEquals('function', type(ns.RemoveFriendByIndex))
            end,
            SendWho = function()
              assertEquals('function', type(ns.SendWho))
            end,
            SetFriendNotes = function()
              assertEquals('function', type(ns.SetFriendNotes))
            end,
            SetFriendNotesByIndex = function()
              assertEquals('function', type(ns.SetFriendNotesByIndex))
            end,
            SetSelectedFriend = function()
              assertEquals('function', type(ns.SetSelectedFriend))
            end,
            SetSelectedIgnore = function()
              assertEquals('function', type(ns.SetSelectedIgnore))
            end,
            SetWhoToUi = function()
              assertEquals('function', type(ns.SetWhoToUi))
            end,
            ShowFriends = function()
              assertEquals('function', type(ns.ShowFriends))
            end,
            SortWho = function()
              assertEquals('function', type(ns.SortWho))
            end,
          }
        end,
        C_GamePad = function()
          local ns = _G.C_GamePad
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            AddSDLMapping = function()
              assertEquals('function', type(ns.AddSDLMapping))
            end,
            ApplyConfigs = function()
              assertEquals('function', type(ns.ApplyConfigs))
            end,
            AxisIndexToConfigName = function()
              assertEquals('function', type(ns.AxisIndexToConfigName))
            end,
            ButtonBindingToIndex = function()
              assertEquals('function', type(ns.ButtonBindingToIndex))
            end,
            ButtonIndexToBinding = function()
              assertEquals('function', type(ns.ButtonIndexToBinding))
            end,
            ButtonIndexToConfigName = function()
              assertEquals('function', type(ns.ButtonIndexToConfigName))
            end,
            ClearLedColor = function()
              assertEquals('function', type(ns.ClearLedColor))
            end,
            DeleteConfig = function()
              assertEquals('function', type(ns.DeleteConfig))
            end,
            GetActiveDeviceID = function()
              assertEquals('function', type(ns.GetActiveDeviceID))
            end,
            GetAllConfigIDs = function()
              assertEquals('function', type(ns.GetAllConfigIDs))
            end,
            GetAllDeviceIDs = function()
              assertEquals('function', type(ns.GetAllDeviceIDs))
            end,
            GetCombinedDeviceID = function()
              assertEquals('function', type(ns.GetCombinedDeviceID))
            end,
            GetConfig = function()
              assertEquals('function', type(ns.GetConfig))
            end,
            GetDeviceMappedState = function()
              assertEquals('function', type(ns.GetDeviceMappedState))
            end,
            GetDeviceRawState = function()
              assertEquals('function', type(ns.GetDeviceRawState))
            end,
            GetLedColor = function()
              assertEquals('function', type(ns.GetLedColor))
            end,
            GetPowerLevel = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetPowerLevel))
                return
              end
              assertEquals('function', type(ns.GetPowerLevel))
            end,
            IsEnabled = function()
              assertEquals('function', type(ns.IsEnabled))
            end,
            SetConfig = function()
              assertEquals('function', type(ns.SetConfig))
            end,
            SetLedColor = function()
              assertEquals('function', type(ns.SetLedColor))
            end,
            SetVibration = function()
              assertEquals('function', type(ns.SetVibration))
            end,
            StickIndexToConfigName = function()
              assertEquals('function', type(ns.StickIndexToConfigName))
            end,
            StopVibration = function()
              assertEquals('function', type(ns.StopVibration))
            end,
          }
        end,
        C_Garrison = function()
          local ns = _G.C_Garrison
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            AddFollowerToMission = function()
              assertEquals('function', type(ns.AddFollowerToMission))
            end,
            CloseGarrisonTradeskillNPC = function()
              assertEquals('function', type(ns.CloseGarrisonTradeskillNPC))
            end,
            GetAllEncounterThreats = function()
              assertEquals('function', type(ns.GetAllEncounterThreats))
            end,
            GetAutoCombatDamageClassValues = function()
              assertEquals('function', type(ns.GetAutoCombatDamageClassValues))
            end,
            GetAutoMissionBoardState = function()
              assertEquals('function', type(ns.GetAutoMissionBoardState))
            end,
            GetAutoMissionEnvironmentEffect = function()
              assertEquals('function', type(ns.GetAutoMissionEnvironmentEffect))
            end,
            GetAutoMissionTargetingInfo = function()
              assertEquals('function', type(ns.GetAutoMissionTargetingInfo))
            end,
            GetAutoMissionTargetingInfoForSpell = function()
              assertEquals('function', type(ns.GetAutoMissionTargetingInfoForSpell))
            end,
            GetAutoTroops = function()
              assertEquals('function', type(ns.GetAutoTroops))
            end,
            GetAvailableMissions = function()
              assertEquals('function', type(ns.GetAvailableMissions))
            end,
            GetAvailableRecruits = function()
              assertEquals('function', type(ns.GetAvailableRecruits))
            end,
            GetBuildingSizes = function()
              assertEquals('function', type(ns.GetBuildingSizes))
            end,
            GetCombatAllyMission = function()
              assertEquals('function', type(ns.GetCombatAllyMission))
            end,
            GetCombatLogSpellInfo = function()
              assertEquals('function', type(ns.GetCombatLogSpellInfo))
            end,
            GetCurrencyTypes = function()
              assertEquals('function', type(ns.GetCurrencyTypes))
            end,
            GetCurrentCypherEquipmentLevel = function()
              assertEquals('function', type(ns.GetCurrentCypherEquipmentLevel))
            end,
            GetCurrentGarrTalentTreeFriendshipFactionID = function()
              assertEquals('function', type(ns.GetCurrentGarrTalentTreeFriendshipFactionID))
            end,
            GetCurrentGarrTalentTreeID = function()
              assertEquals('function', type(ns.GetCurrentGarrTalentTreeID))
            end,
            GetCyphersToNextEquipmentLevel = function()
              assertEquals('function', type(ns.GetCyphersToNextEquipmentLevel))
            end,
            GetFollowerAutoCombatSpells = function()
              assertEquals('function', type(ns.GetFollowerAutoCombatSpells))
            end,
            GetFollowerAutoCombatStats = function()
              assertEquals('function', type(ns.GetFollowerAutoCombatStats))
            end,
            GetFollowerMissionCompleteInfo = function()
              assertEquals('function', type(ns.GetFollowerMissionCompleteInfo))
            end,
            GetFollowerSoftCap = function()
              assertEquals('function', type(ns.GetFollowerSoftCap))
            end,
            GetFollowerXPTable = function()
              assertEquals('function', type(ns.GetFollowerXPTable))
            end,
            GetFollowers = function()
              assertEquals('function', type(ns.GetFollowers))
            end,
            GetGarrisonPlotsInstancesForMap = function()
              assertEquals('function', type(ns.GetGarrisonPlotsInstancesForMap))
            end,
            GetGarrisonTalentTreeCurrencyTypes = function()
              assertEquals('function', type(ns.GetGarrisonTalentTreeCurrencyTypes))
            end,
            GetGarrisonTalentTreeType = function()
              assertEquals('function', type(ns.GetGarrisonTalentTreeType))
            end,
            GetInProgressMissions = function()
              assertEquals('function', type(ns.GetInProgressMissions))
            end,
            GetLandingPageGarrisonType = function()
              assertEquals('function', type(ns.GetLandingPageGarrisonType))
            end,
            GetMaxCypherEquipmentLevel = function()
              assertEquals('function', type(ns.GetMaxCypherEquipmentLevel))
            end,
            GetMissionCompleteEncounters = function()
              assertEquals('function', type(ns.GetMissionCompleteEncounters))
            end,
            GetMissionDeploymentInfo = function()
              assertEquals('function', type(ns.GetMissionDeploymentInfo))
            end,
            GetMissionEncounterIconInfo = function()
              assertEquals('function', type(ns.GetMissionEncounterIconInfo))
            end,
            GetNumFollowers = function()
              assertEquals('function', type(ns.GetNumFollowers))
            end,
            GetRecruiterAbilityCategories = function()
              assertEquals('function', type(ns.GetRecruiterAbilityCategories))
            end,
            GetRecruitmentPreferences = function()
              assertEquals('function', type(ns.GetRecruitmentPreferences))
            end,
            GetTalentInfo = function()
              assertEquals('function', type(ns.GetTalentInfo))
            end,
            GetTalentPointsSpentInTalentTree = function()
              assertEquals('function', type(ns.GetTalentPointsSpentInTalentTree))
            end,
            GetTalentTreeIDsByClassID = function()
              assertEquals('function', type(ns.GetTalentTreeIDsByClassID))
            end,
            GetTalentTreeInfo = function()
              assertEquals('function', type(ns.GetTalentTreeInfo))
            end,
            GetTalentTreeResetInfo = function()
              assertEquals('function', type(ns.GetTalentTreeResetInfo))
            end,
            GetTalentTreeTalentPointResearchInfo = function()
              assertEquals('function', type(ns.GetTalentTreeTalentPointResearchInfo))
            end,
            GetTalentUnlockWorldQuest = function()
              assertEquals('function', type(ns.GetTalentUnlockWorldQuest))
            end,
            HasAdventures = function()
              assertEquals('function', type(ns.HasAdventures))
            end,
            IsAtGarrisonMissionNPC = function()
              assertEquals('function', type(ns.IsAtGarrisonMissionNPC))
            end,
            IsEnvironmentCountered = function()
              assertEquals('function', type(ns.IsEnvironmentCountered))
            end,
            IsFollowerOnCompletedMission = function()
              assertEquals('function', type(ns.IsFollowerOnCompletedMission))
            end,
            IsPlayerInGarrison = function()
              assertEquals('function', type(ns.IsPlayerInGarrison))
            end,
            IsTalentConditionMet = function()
              assertEquals('function', type(ns.IsTalentConditionMet))
            end,
            IsUsingPartyGarrison = function()
              assertEquals('function', type(ns.IsUsingPartyGarrison))
            end,
            RegenerateCombatLog = function()
              assertEquals('function', type(ns.RegenerateCombatLog))
            end,
            RemoveFollowerFromMission = function()
              assertEquals('function', type(ns.RemoveFollowerFromMission))
            end,
            RushHealAllFollowers = function()
              assertEquals('function', type(ns.RushHealAllFollowers))
            end,
            RushHealFollower = function()
              assertEquals('function', type(ns.RushHealFollower))
            end,
            SetAutoCombatSpellFastForward = function()
              assertEquals('function', type(ns.SetAutoCombatSpellFastForward))
            end,
          }
        end,
        C_GossipInfo = function()
          local ns = _G.C_GossipInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            CloseGossip = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CloseGossip))
                return
              end
              assertEquals('function', type(ns.CloseGossip))
            end,
            ForceGossip = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ForceGossip))
                return
              end
              assertEquals('function', type(ns.ForceGossip))
            end,
            GetActiveQuests = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetActiveQuests))
                return
              end
              assertEquals('function', type(ns.GetActiveQuests))
            end,
            GetAvailableQuests = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetAvailableQuests))
                return
              end
              assertEquals('function', type(ns.GetAvailableQuests))
            end,
            GetCompletedOptionDescriptionString = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetCompletedOptionDescriptionString))
                return
              end
              assertEquals('function', type(ns.GetCompletedOptionDescriptionString))
            end,
            GetCustomGossipDescriptionString = function()
              assertEquals('function', type(ns.GetCustomGossipDescriptionString))
            end,
            GetNumActiveQuests = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetNumActiveQuests))
                return
              end
              assertEquals('function', type(ns.GetNumActiveQuests))
            end,
            GetNumAvailableQuests = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetNumAvailableQuests))
                return
              end
              assertEquals('function', type(ns.GetNumAvailableQuests))
            end,
            GetNumOptions = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetNumOptions))
                return
              end
              assertEquals('function', type(ns.GetNumOptions))
            end,
            GetOptions = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetOptions))
                return
              end
              assertEquals('function', type(ns.GetOptions))
            end,
            GetPoiForUiMapID = function()
              assertEquals('function', type(ns.GetPoiForUiMapID))
            end,
            GetPoiInfo = function()
              assertEquals('function', type(ns.GetPoiInfo))
            end,
            GetText = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetText))
                return
              end
              assertEquals('function', type(ns.GetText))
            end,
            RefreshOptions = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.RefreshOptions))
                return
              end
              assertEquals('function', type(ns.RefreshOptions))
            end,
            SelectActiveQuest = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SelectActiveQuest))
                return
              end
              assertEquals('function', type(ns.SelectActiveQuest))
            end,
            SelectAvailableQuest = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SelectAvailableQuest))
                return
              end
              assertEquals('function', type(ns.SelectAvailableQuest))
            end,
            SelectOption = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SelectOption))
                return
              end
              assertEquals('function', type(ns.SelectOption))
            end,
          }
        end,
        C_GuildInfo = function()
          local ns = _G.C_GuildInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            CanEditOfficerNote = function()
              assertEquals('function', type(ns.CanEditOfficerNote))
            end,
            CanSpeakInGuildChat = function()
              assertEquals('function', type(ns.CanSpeakInGuildChat))
            end,
            CanViewOfficerNote = function()
              assertEquals('function', type(ns.CanViewOfficerNote))
            end,
            GetGuildNewsInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetGuildNewsInfo))
                return
              end
              assertEquals('function', type(ns.GetGuildNewsInfo))
            end,
            GetGuildRankOrder = function()
              assertEquals('function', type(ns.GetGuildRankOrder))
            end,
            GetGuildTabardInfo = function()
              assertEquals('function', type(ns.GetGuildTabardInfo))
            end,
            GuildControlGetRankFlags = function()
              assertEquals('function', type(ns.GuildControlGetRankFlags))
            end,
            GuildRoster = function()
              assertEquals('function', type(ns.GuildRoster))
            end,
            IsGuildOfficer = function()
              assertEquals('function', type(ns.IsGuildOfficer))
            end,
            IsGuildRankAssignmentAllowed = function()
              assertEquals('function', type(ns.IsGuildRankAssignmentAllowed))
            end,
            QueryGuildMemberRecipes = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.QueryGuildMemberRecipes))
                return
              end
              assertEquals('function', type(ns.QueryGuildMemberRecipes))
            end,
            QueryGuildMembersForRecipe = function()
              assertEquals('function', type(ns.QueryGuildMembersForRecipe))
            end,
            RemoveFromGuild = function()
              assertEquals('function', type(ns.RemoveFromGuild))
            end,
            SetGuildRankOrder = function()
              assertEquals('function', type(ns.SetGuildRankOrder))
            end,
            SetNote = function()
              assertEquals('function', type(ns.SetNote))
            end,
          }
        end,
        C_Heirloom = function()
          local ns = _G.C_Heirloom
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetClassAndSpecFilters = function()
              assertEquals('function', type(ns.GetClassAndSpecFilters))
            end,
            GetHeirloomInfo = function()
              assertEquals('function', type(ns.GetHeirloomInfo))
            end,
            GetHeirloomItemIDFromDisplayedIndex = function()
              assertEquals('function', type(ns.GetHeirloomItemIDFromDisplayedIndex))
            end,
            GetHeirloomMaxUpgradeLevel = function()
              assertEquals('function', type(ns.GetHeirloomMaxUpgradeLevel))
            end,
            GetNumDisplayedHeirlooms = function()
              assertEquals('function', type(ns.GetNumDisplayedHeirlooms))
            end,
            SetClassAndSpecFilters = function()
              assertEquals('function', type(ns.SetClassAndSpecFilters))
            end,
            ShouldShowHeirloomHelp = function()
              assertEquals('function', type(ns.ShouldShowHeirloomHelp))
            end,
          }
        end,
        C_HeirloomInfo = function()
          local ns = _G.C_HeirloomInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            AreAllCollectionFiltersChecked = function()
              assertEquals('function', type(ns.AreAllCollectionFiltersChecked))
            end,
            AreAllSourceFiltersChecked = function()
              assertEquals('function', type(ns.AreAllSourceFiltersChecked))
            end,
            IsHeirloomSourceValid = function()
              assertEquals('function', type(ns.IsHeirloomSourceValid))
            end,
            IsUsingDefaultFilters = function()
              assertEquals('function', type(ns.IsUsingDefaultFilters))
            end,
            SetAllCollectionFilters = function()
              assertEquals('function', type(ns.SetAllCollectionFilters))
            end,
            SetAllSourceFilters = function()
              assertEquals('function', type(ns.SetAllSourceFilters))
            end,
            SetDefaultFilters = function()
              assertEquals('function', type(ns.SetDefaultFilters))
            end,
          }
        end,
        C_IncomingSummon = function()
          local ns = _G.C_IncomingSummon
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            HasIncomingSummon = function()
              assertEquals('function', type(ns.HasIncomingSummon))
            end,
            IncomingSummonStatus = function()
              assertEquals('function', type(ns.IncomingSummonStatus))
            end,
          }
        end,
        C_InvasionInfo = function()
          local ns = _G.C_InvasionInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            AreInvasionsAvailable = function()
              assertEquals('function', type(ns.AreInvasionsAvailable))
            end,
            GetInvasionForUiMapID = function()
              assertEquals('function', type(ns.GetInvasionForUiMapID))
            end,
            GetInvasionInfo = function()
              assertEquals('function', type(ns.GetInvasionInfo))
            end,
            GetInvasionTimeLeft = function()
              assertEquals('function', type(ns.GetInvasionTimeLeft))
            end,
          }
        end,
        C_IslandsQueue = function()
          local ns = _G.C_IslandsQueue
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            CloseIslandsQueueScreen = function()
              assertEquals('function', type(ns.CloseIslandsQueueScreen))
            end,
            GetIslandDifficultyInfo = function()
              assertEquals('function', type(ns.GetIslandDifficultyInfo))
            end,
            GetIslandsMaxGroupSize = function()
              assertEquals('function', type(ns.GetIslandsMaxGroupSize))
            end,
            GetIslandsWeeklyQuestID = function()
              assertEquals('function', type(ns.GetIslandsWeeklyQuestID))
            end,
            QueueForIsland = function()
              assertEquals('function', type(ns.QueueForIsland))
            end,
            RequestPreloadRewardData = function()
              assertEquals('function', type(ns.RequestPreloadRewardData))
            end,
          }
        end,
        C_Item = function()
          local ns = _G.C_Item
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            CanItemTransmogAppearance = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanItemTransmogAppearance))
                return
              end
              assertEquals('function', type(ns.CanItemTransmogAppearance))
            end,
            CanScrapItem = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanScrapItem))
                return
              end
              assertEquals('function', type(ns.CanScrapItem))
            end,
            CanViewItemPowers = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanViewItemPowers))
                return
              end
              assertEquals('function', type(ns.CanViewItemPowers))
            end,
            DoesItemExist = function()
              assertEquals('function', type(ns.DoesItemExist))
            end,
            DoesItemExistByID = function()
              assertEquals('function', type(ns.DoesItemExistByID))
            end,
            DoesItemMatchBonusTreeReplacement = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.DoesItemMatchBonusTreeReplacement))
                return
              end
              assertEquals('function', type(ns.DoesItemMatchBonusTreeReplacement))
            end,
            GetAppliedItemTransmogInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetAppliedItemTransmogInfo))
                return
              end
              assertEquals('function', type(ns.GetAppliedItemTransmogInfo))
            end,
            GetBaseItemTransmogInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetBaseItemTransmogInfo))
                return
              end
              assertEquals('function', type(ns.GetBaseItemTransmogInfo))
            end,
            GetCurrentItemLevel = function()
              assertEquals('function', type(ns.GetCurrentItemLevel))
            end,
            GetCurrentItemTransmogInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetCurrentItemTransmogInfo))
                return
              end
              assertEquals('function', type(ns.GetCurrentItemTransmogInfo))
            end,
            GetItemConversionOutputIcon = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetItemConversionOutputIcon))
                return
              end
              assertEquals('function', type(ns.GetItemConversionOutputIcon))
            end,
            GetItemGUID = function()
              assertEquals('function', type(ns.GetItemGUID))
            end,
            GetItemID = function()
              assertEquals('function', type(ns.GetItemID))
            end,
            GetItemIcon = function()
              assertEquals('function', type(ns.GetItemIcon))
            end,
            GetItemIconByID = function()
              assertEquals('function', type(ns.GetItemIconByID))
            end,
            GetItemInventoryType = function()
              assertEquals('function', type(ns.GetItemInventoryType))
            end,
            GetItemInventoryTypeByID = function()
              assertEquals('function', type(ns.GetItemInventoryTypeByID))
            end,
            GetItemLink = function()
              assertEquals('function', type(ns.GetItemLink))
            end,
            GetItemName = function()
              assertEquals('function', type(ns.GetItemName))
            end,
            GetItemNameByID = function()
              assertEquals('function', type(ns.GetItemNameByID))
            end,
            GetItemQuality = function()
              assertEquals('function', type(ns.GetItemQuality))
            end,
            GetItemQualityByID = function()
              assertEquals('function', type(ns.GetItemQualityByID))
            end,
            GetItemUniquenessByID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetItemUniquenessByID))
                return
              end
              assertEquals('function', type(ns.GetItemUniquenessByID))
            end,
            GetLimitedCurrencyItemInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetLimitedCurrencyItemInfo))
                return
              end
              assertEquals('function', type(ns.GetLimitedCurrencyItemInfo))
            end,
            GetStackCount = function()
              assertEquals('function', type(ns.GetStackCount))
            end,
            IsAnimaItemByID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsAnimaItemByID))
                return
              end
              assertEquals('function', type(ns.IsAnimaItemByID))
            end,
            IsBound = function()
              assertEquals('function', type(ns.IsBound))
            end,
            IsDressableItemByID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsDressableItemByID))
                return
              end
              assertEquals('function', type(ns.IsDressableItemByID))
            end,
            IsItemConduit = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsItemConduit))
                return
              end
              assertEquals('function', type(ns.IsItemConduit))
            end,
            IsItemConvertibleAndValidForPlayer = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsItemConvertibleAndValidForPlayer))
                return
              end
              assertEquals('function', type(ns.IsItemConvertibleAndValidForPlayer))
            end,
            IsItemCorrupted = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsItemCorrupted))
                return
              end
              assertEquals('function', type(ns.IsItemCorrupted))
            end,
            IsItemCorruptionRelated = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsItemCorruptionRelated))
                return
              end
              assertEquals('function', type(ns.IsItemCorruptionRelated))
            end,
            IsItemCorruptionResistant = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsItemCorruptionResistant))
                return
              end
              assertEquals('function', type(ns.IsItemCorruptionResistant))
            end,
            IsItemDataCached = function()
              assertEquals('function', type(ns.IsItemDataCached))
            end,
            IsItemDataCachedByID = function()
              assertEquals('function', type(ns.IsItemDataCachedByID))
            end,
            IsItemKeystoneByID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsItemKeystoneByID))
                return
              end
              assertEquals('function', type(ns.IsItemKeystoneByID))
            end,
            IsItemSpecificToPlayerClass = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsItemSpecificToPlayerClass))
                return
              end
              assertEquals('function', type(ns.IsItemSpecificToPlayerClass))
            end,
            IsLocked = function()
              assertEquals('function', type(ns.IsLocked))
            end,
            LockItem = function()
              assertEquals('function', type(ns.LockItem))
            end,
            LockItemByGUID = function()
              assertEquals('function', type(ns.LockItemByGUID))
            end,
            RequestLoadItemData = function()
              assertEquals('function', type(ns.RequestLoadItemData))
            end,
            RequestLoadItemDataByID = function()
              assertEquals('function', type(ns.RequestLoadItemDataByID))
            end,
            UnlockItem = function()
              assertEquals('function', type(ns.UnlockItem))
            end,
            UnlockItemByGUID = function()
              assertEquals('function', type(ns.UnlockItemByGUID))
            end,
          }
        end,
        C_ItemInteraction = function()
          local ns = _G.C_ItemInteraction
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            ClearPendingItem = function()
              assertEquals('function', type(ns.ClearPendingItem))
            end,
            CloseUI = function()
              assertEquals('function', type(ns.CloseUI))
            end,
            GetChargeInfo = function()
              assertEquals('function', type(ns.GetChargeInfo))
            end,
            GetItemConversionCurrencyCost = function()
              assertEquals('function', type(ns.GetItemConversionCurrencyCost))
            end,
            GetItemInteractionInfo = function()
              assertEquals('function', type(ns.GetItemInteractionInfo))
            end,
            GetItemInteractionSpellId = function()
              assertEquals('function', type(ns.GetItemInteractionSpellId))
            end,
            InitializeFrame = function()
              assertEquals('function', type(ns.InitializeFrame))
            end,
            PerformItemInteraction = function()
              assertEquals('function', type(ns.PerformItemInteraction))
            end,
            Reset = function()
              assertEquals('function', type(ns.Reset))
            end,
            SetCorruptionReforgerItemTooltip = function()
              assertEquals('function', type(ns.SetCorruptionReforgerItemTooltip))
            end,
            SetItemConversionOutputTooltip = function()
              assertEquals('function', type(ns.SetItemConversionOutputTooltip))
            end,
            SetPendingItem = function()
              assertEquals('function', type(ns.SetPendingItem))
            end,
          }
        end,
        C_ItemSocketInfo = function()
          local ns = _G.C_ItemSocketInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            CompleteSocketing = function()
              assertEquals('function', type(ns.CompleteSocketing))
            end,
          }
        end,
        C_ItemUpgrade = function()
          local ns = _G.C_ItemUpgrade
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            CanUpgradeItem = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanUpgradeItem))
                return
              end
              assertEquals('function', type(ns.CanUpgradeItem))
            end,
            ClearItemUpgrade = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ClearItemUpgrade))
                return
              end
              assertEquals('function', type(ns.ClearItemUpgrade))
            end,
            CloseItemUpgrade = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CloseItemUpgrade))
                return
              end
              assertEquals('function', type(ns.CloseItemUpgrade))
            end,
            GetItemHyperlink = function()
              assertEquals('function', type(ns.GetItemHyperlink))
            end,
            GetItemLevelIncrement = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetItemLevelIncrement))
                return
              end
              assertEquals('function', type(ns.GetItemLevelIncrement))
            end,
            GetItemUpgradeCurrentLevel = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetItemUpgradeCurrentLevel))
                return
              end
              assertEquals('function', type(ns.GetItemUpgradeCurrentLevel))
            end,
            GetItemUpgradeEffect = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetItemUpgradeEffect))
                return
              end
              assertEquals('function', type(ns.GetItemUpgradeEffect))
            end,
            GetItemUpgradeItemInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetItemUpgradeItemInfo))
                return
              end
              assertEquals('function', type(ns.GetItemUpgradeItemInfo))
            end,
            GetItemUpgradePvpItemLevelDeltaValues = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetItemUpgradePvpItemLevelDeltaValues))
                return
              end
              assertEquals('function', type(ns.GetItemUpgradePvpItemLevelDeltaValues))
            end,
            GetNumItemUpgradeEffects = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetNumItemUpgradeEffects))
                return
              end
              assertEquals('function', type(ns.GetNumItemUpgradeEffects))
            end,
            SetItemUpgradeFromCursorItem = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetItemUpgradeFromCursorItem))
                return
              end
              assertEquals('function', type(ns.SetItemUpgradeFromCursorItem))
            end,
            SetItemUpgradeFromLocation = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetItemUpgradeFromLocation))
                return
              end
              assertEquals('function', type(ns.SetItemUpgradeFromLocation))
            end,
            UpgradeItem = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.UpgradeItem))
                return
              end
              assertEquals('function', type(ns.UpgradeItem))
            end,
          }
        end,
        C_KeyBindings = function()
          local ns = _G.C_KeyBindings
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetCustomBindingType = function()
              assertEquals('function', type(ns.GetCustomBindingType))
            end,
          }
        end,
        C_LFGInfo = function()
          local ns = _G.C_LFGInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            CanPlayerUseGroupFinder = function()
              assertEquals('function', type(ns.CanPlayerUseGroupFinder))
            end,
            CanPlayerUseLFD = function()
              assertEquals('function', type(ns.CanPlayerUseLFD))
            end,
            CanPlayerUseLFR = function()
              assertEquals('function', type(ns.CanPlayerUseLFR))
            end,
            CanPlayerUsePVP = function()
              assertEquals('function', type(ns.CanPlayerUsePVP))
            end,
            CanPlayerUsePremadeGroup = function()
              assertEquals('function', type(ns.CanPlayerUsePremadeGroup))
            end,
            ConfirmLfgExpandSearch = function()
              assertEquals('function', type(ns.ConfirmLfgExpandSearch))
            end,
            GetAllEntriesForCategory = function()
              assertEquals('function', type(ns.GetAllEntriesForCategory))
            end,
            GetDungeonInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetDungeonInfo))
                return
              end
              assertEquals('function', type(ns.GetDungeonInfo))
            end,
            GetLFDLockStates = function()
              assertEquals('function', type(ns.GetLFDLockStates))
            end,
            GetRoleCheckDifficultyDetails = function()
              assertEquals('function', type(ns.GetRoleCheckDifficultyDetails))
            end,
            HideNameFromUI = function()
              assertEquals('function', type(ns.HideNameFromUI))
            end,
          }
        end,
        C_LFGList = function()
          local ns = _G.C_LFGList
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            CanActiveEntryUseAutoAccept = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanActiveEntryUseAutoAccept))
                return
              end
              assertEquals('function', type(ns.CanActiveEntryUseAutoAccept))
            end,
            CanCreateQuestGroup = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanCreateQuestGroup))
                return
              end
              assertEquals('function', type(ns.CanCreateQuestGroup))
            end,
            ClearApplicationTextFields = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ClearApplicationTextFields))
                return
              end
              assertEquals('function', type(ns.ClearApplicationTextFields))
            end,
            ClearCreationTextFields = function()
              assertEquals('function', type(ns.ClearCreationTextFields))
            end,
            ClearSearchTextFields = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ClearSearchTextFields))
                return
              end
              assertEquals('function', type(ns.ClearSearchTextFields))
            end,
            CopyActiveEntryInfoToCreationFields = function()
              assertEquals('function', type(ns.CopyActiveEntryInfoToCreationFields))
            end,
            CreateListing = function()
              assertEquals('function', type(ns.CreateListing))
            end,
            DoesEntryTitleMatchPrebuiltTitle = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.DoesEntryTitleMatchPrebuiltTitle))
                return
              end
              assertEquals('function', type(ns.DoesEntryTitleMatchPrebuiltTitle))
            end,
            GetActiveEntryInfo = function()
              assertEquals('function', type(ns.GetActiveEntryInfo))
            end,
            GetActivityFullName = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetActivityFullName))
                return
              end
              assertEquals('function', type(ns.GetActivityFullName))
            end,
            GetActivityGroupInfo = function()
              assertEquals('function', type(ns.GetActivityGroupInfo))
            end,
            GetActivityInfoTable = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetActivityInfoTable))
                return
              end
              assertEquals('function', type(ns.GetActivityInfoTable))
            end,
            GetApplicantDungeonScoreForListing = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetApplicantDungeonScoreForListing))
                return
              end
              assertEquals('function', type(ns.GetApplicantDungeonScoreForListing))
            end,
            GetApplicantInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetApplicantInfo))
                return
              end
              assertEquals('function', type(ns.GetApplicantInfo))
            end,
            GetApplicantPvpRatingInfoForListing = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetApplicantPvpRatingInfoForListing))
                return
              end
              assertEquals('function', type(ns.GetApplicantPvpRatingInfoForListing))
            end,
            GetApplications = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetApplications))
                return
              end
              assertEquals('function', type(ns.GetApplications))
            end,
            GetAvailableActivities = function()
              assertEquals('function', type(ns.GetAvailableActivities))
            end,
            GetAvailableCategories = function()
              assertEquals('function', type(ns.GetAvailableCategories))
            end,
            GetAvailableLanguageSearchFilter = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetAvailableLanguageSearchFilter))
                return
              end
              assertEquals('function', type(ns.GetAvailableLanguageSearchFilter))
            end,
            GetAvailableRoles = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetAvailableRoles))
                return
              end
              assertEquals('function', type(ns.GetAvailableRoles))
            end,
            GetDefaultLanguageSearchFilter = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetDefaultLanguageSearchFilter))
                return
              end
              assertEquals('function', type(ns.GetDefaultLanguageSearchFilter))
            end,
            GetFilteredSearchResults = function()
              assertEquals('function', type(ns.GetFilteredSearchResults))
            end,
            GetKeystoneForActivity = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetKeystoneForActivity))
                return
              end
              assertEquals('function', type(ns.GetKeystoneForActivity))
            end,
            GetLanguageSearchFilter = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetLanguageSearchFilter))
                return
              end
              assertEquals('function', type(ns.GetLanguageSearchFilter))
            end,
            GetLfgCategoryInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetLfgCategoryInfo))
                return
              end
              assertEquals('function', type(ns.GetLfgCategoryInfo))
            end,
            GetNumApplications = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetNumApplications))
                return
              end
              assertEquals('function', type(ns.GetNumApplications))
            end,
            GetOwnedKeystoneActivityAndGroupAndLevel = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetOwnedKeystoneActivityAndGroupAndLevel))
                return
              end
              assertEquals('function', type(ns.GetOwnedKeystoneActivityAndGroupAndLevel))
            end,
            GetPlaystyleString = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetPlaystyleString))
                return
              end
              assertEquals('function', type(ns.GetPlaystyleString))
            end,
            GetSearchResultInfo = function()
              assertEquals('function', type(ns.GetSearchResultInfo))
            end,
            GetSearchResults = function()
              assertEquals('function', type(ns.GetSearchResults))
            end,
            HasActiveEntryInfo = function()
              assertEquals('function', type(ns.HasActiveEntryInfo))
            end,
            HasActivityList = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.HasActivityList))
                return
              end
              assertEquals('function', type(ns.HasActivityList))
            end,
            HasSearchResultInfo = function()
              assertEquals('function', type(ns.HasSearchResultInfo))
            end,
            IsLookingForGroupEnabled = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsLookingForGroupEnabled))
                return
              end
              assertEquals('function', type(ns.IsLookingForGroupEnabled))
            end,
            IsPlayerAuthenticatedForLFG = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsPlayerAuthenticatedForLFG))
                return
              end
              assertEquals('function', type(ns.IsPlayerAuthenticatedForLFG))
            end,
            RequestAvailableActivities = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.RequestAvailableActivities))
                return
              end
              assertEquals('function', type(ns.RequestAvailableActivities))
            end,
            Search = function()
              assertEquals('function', type(ns.Search))
            end,
            SetEntryTitle = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetEntryTitle))
                return
              end
              assertEquals('function', type(ns.SetEntryTitle))
            end,
            SetSearchToActivity = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetSearchToActivity))
                return
              end
              assertEquals('function', type(ns.SetSearchToActivity))
            end,
            SetSearchToQuestID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetSearchToQuestID))
                return
              end
              assertEquals('function', type(ns.SetSearchToQuestID))
            end,
            UpdateListing = function()
              assertEquals('function', type(ns.UpdateListing))
            end,
            ValidateRequiredDungeonScore = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ValidateRequiredDungeonScore))
                return
              end
              assertEquals('function', type(ns.ValidateRequiredDungeonScore))
            end,
            ValidateRequiredPvpRatingForActivity = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ValidateRequiredPvpRatingForActivity))
                return
              end
              assertEquals('function', type(ns.ValidateRequiredPvpRatingForActivity))
            end,
          }
        end,
        C_LegendaryCrafting = function()
          local ns = _G.C_LegendaryCrafting
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            CloseRuneforgeInteraction = function()
              assertEquals('function', type(ns.CloseRuneforgeInteraction))
            end,
            CraftRuneforgeLegendary = function()
              assertEquals('function', type(ns.CraftRuneforgeLegendary))
            end,
            GetRuneforgeItemPreviewInfo = function()
              assertEquals('function', type(ns.GetRuneforgeItemPreviewInfo))
            end,
            GetRuneforgeLegendaryComponentInfo = function()
              assertEquals('function', type(ns.GetRuneforgeLegendaryComponentInfo))
            end,
            GetRuneforgeLegendaryCost = function()
              assertEquals('function', type(ns.GetRuneforgeLegendaryCost))
            end,
            GetRuneforgeLegendaryCraftSpellID = function()
              assertEquals('function', type(ns.GetRuneforgeLegendaryCraftSpellID))
            end,
            GetRuneforgeLegendaryCurrencies = function()
              assertEquals('function', type(ns.GetRuneforgeLegendaryCurrencies))
            end,
            GetRuneforgeLegendaryUpgradeCost = function()
              assertEquals('function', type(ns.GetRuneforgeLegendaryUpgradeCost))
            end,
            GetRuneforgeModifierInfo = function()
              assertEquals('function', type(ns.GetRuneforgeModifierInfo))
            end,
            GetRuneforgeModifiers = function()
              assertEquals('function', type(ns.GetRuneforgeModifiers))
            end,
            GetRuneforgePowerInfo = function()
              assertEquals('function', type(ns.GetRuneforgePowerInfo))
            end,
            GetRuneforgePowerSlots = function()
              assertEquals('function', type(ns.GetRuneforgePowerSlots))
            end,
            GetRuneforgePowers = function()
              assertEquals('function', type(ns.GetRuneforgePowers))
            end,
            GetRuneforgePowersByClassSpecAndCovenant = function()
              assertEquals('function', type(ns.GetRuneforgePowersByClassSpecAndCovenant))
            end,
            IsRuneforgeLegendary = function()
              assertEquals('function', type(ns.IsRuneforgeLegendary))
            end,
            IsRuneforgeLegendaryMaxLevel = function()
              assertEquals('function', type(ns.IsRuneforgeLegendaryMaxLevel))
            end,
            IsUpgradeItemValidForRuneforgeLegendary = function()
              assertEquals('function', type(ns.IsUpgradeItemValidForRuneforgeLegendary))
            end,
            IsValidRuneforgeBaseItem = function()
              assertEquals('function', type(ns.IsValidRuneforgeBaseItem))
            end,
            MakeRuneforgeCraftDescription = function()
              assertEquals('function', type(ns.MakeRuneforgeCraftDescription))
            end,
            UpgradeRuneforgeLegendary = function()
              assertEquals('function', type(ns.UpgradeRuneforgeLegendary))
            end,
          }
        end,
        C_LevelLink = function()
          local ns = _G.C_LevelLink
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            IsActionLocked = function()
              assertEquals('function', type(ns.IsActionLocked))
            end,
            IsSpellLocked = function()
              assertEquals('function', type(ns.IsSpellLocked))
            end,
          }
        end,
        C_LevelSquish = function()
          local ns = _G.C_LevelSquish
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            ConvertFollowerLevel = function()
              assertEquals('function', type(ns.ConvertFollowerLevel))
            end,
            ConvertPlayerLevel = function()
              assertEquals('function', type(ns.ConvertPlayerLevel))
            end,
          }
        end,
        C_Loot = function()
          local ns = _G.C_Loot
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            IsLegacyLootModeEnabled = function()
              assertEquals('function', type(ns.IsLegacyLootModeEnabled))
            end,
          }
        end,
        C_LootHistory = function()
          local ns = _G.C_LootHistory
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetItem = function()
              assertEquals('function', type(ns.GetItem))
            end,
            GetNumItems = function()
              assertEquals('function', type(ns.GetNumItems))
            end,
            GetPlayerInfo = function()
              assertEquals('function', type(ns.GetPlayerInfo))
            end,
          }
        end,
        C_LootJournal = function()
          local ns = _G.C_LootJournal
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetItemSetItems = function()
              assertEquals('function', type(ns.GetItemSetItems))
            end,
            GetItemSets = function()
              assertEquals('function', type(ns.GetItemSets))
            end,
          }
        end,
        C_LoreText = function()
          local ns = _G.C_LoreText
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            RequestLoreTextForCampaignID = function()
              assertEquals('function', type(ns.RequestLoreTextForCampaignID))
            end,
          }
        end,
        C_LossOfControl = function()
          local ns = _G.C_LossOfControl
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetActiveLossOfControlData = function()
              assertEquals('function', type(ns.GetActiveLossOfControlData))
            end,
            GetActiveLossOfControlDataByUnit = function()
              assertEquals('function', type(ns.GetActiveLossOfControlDataByUnit))
            end,
            GetActiveLossOfControlDataCount = function()
              assertEquals('function', type(ns.GetActiveLossOfControlDataCount))
            end,
            GetActiveLossOfControlDataCountByUnit = function()
              assertEquals('function', type(ns.GetActiveLossOfControlDataCountByUnit))
            end,
          }
        end,
        C_Mail = function()
          local ns = _G.C_Mail
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            CanCheckInbox = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanCheckInbox))
                return
              end
              assertEquals('function', type(ns.CanCheckInbox))
            end,
            HasInboxMoney = function()
              assertEquals('function', type(ns.HasInboxMoney))
            end,
            IsCommandPending = function()
              assertEquals('function', type(ns.IsCommandPending))
            end,
          }
        end,
        C_Map = function()
          local ns = _G.C_Map
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            CanSetUserWaypointOnMap = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanSetUserWaypointOnMap))
                return
              end
              assertEquals('function', type(ns.CanSetUserWaypointOnMap))
            end,
            ClearUserWaypoint = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ClearUserWaypoint))
                return
              end
              assertEquals('function', type(ns.ClearUserWaypoint))
            end,
            CloseWorldMapInteraction = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CloseWorldMapInteraction))
                return
              end
              assertEquals('function', type(ns.CloseWorldMapInteraction))
            end,
            GetAreaInfo = function()
              assertEquals('function', type(ns.GetAreaInfo))
            end,
            GetBestMapForUnit = function()
              assertEquals('function', type(ns.GetBestMapForUnit))
            end,
            GetBountySetIDForMap = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetBountySetIDForMap))
                return
              end
              assertEquals('function', type(ns.GetBountySetIDForMap))
            end,
            GetBountySetMaps = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetBountySetMaps))
                return
              end
              assertEquals('function', type(ns.GetBountySetMaps))
            end,
            GetFallbackWorldMapID = function()
              assertEquals('function', type(ns.GetFallbackWorldMapID))
            end,
            GetMapArtBackgroundAtlas = function()
              assertEquals('function', type(ns.GetMapArtBackgroundAtlas))
            end,
            GetMapArtHelpTextPosition = function()
              assertEquals('function', type(ns.GetMapArtHelpTextPosition))
            end,
            GetMapArtID = function()
              assertEquals('function', type(ns.GetMapArtID))
            end,
            GetMapArtLayerTextures = function()
              assertEquals('function', type(ns.GetMapArtLayerTextures))
            end,
            GetMapArtLayers = function()
              assertEquals('function', type(ns.GetMapArtLayers))
            end,
            GetMapBannersForMap = function()
              assertEquals('function', type(ns.GetMapBannersForMap))
            end,
            GetMapChildrenInfo = function()
              assertEquals('function', type(ns.GetMapChildrenInfo))
            end,
            GetMapDisplayInfo = function()
              assertEquals('function', type(ns.GetMapDisplayInfo))
            end,
            GetMapGroupID = function()
              assertEquals('function', type(ns.GetMapGroupID))
            end,
            GetMapGroupMembersInfo = function()
              assertEquals('function', type(ns.GetMapGroupMembersInfo))
            end,
            GetMapHighlightInfoAtPosition = function()
              assertEquals('function', type(ns.GetMapHighlightInfoAtPosition))
            end,
            GetMapInfo = function()
              assertEquals('function', type(ns.GetMapInfo))
            end,
            GetMapInfoAtPosition = function()
              assertEquals('function', type(ns.GetMapInfoAtPosition))
            end,
            GetMapLevels = function()
              assertEquals('function', type(ns.GetMapLevels))
            end,
            GetMapLinksForMap = function()
              assertEquals('function', type(ns.GetMapLinksForMap))
            end,
            GetMapPosFromWorldPos = function()
              assertEquals('function', type(ns.GetMapPosFromWorldPos))
            end,
            GetMapRectOnMap = function()
              assertEquals('function', type(ns.GetMapRectOnMap))
            end,
            GetMapWorldSize = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetMapWorldSize))
                return
              end
              assertEquals('function', type(ns.GetMapWorldSize))
            end,
            GetPlayerMapPosition = function()
              assertEquals('function', type(ns.GetPlayerMapPosition))
            end,
            GetUserWaypoint = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetUserWaypoint))
                return
              end
              assertEquals('function', type(ns.GetUserWaypoint))
            end,
            GetUserWaypointFromHyperlink = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetUserWaypointFromHyperlink))
                return
              end
              assertEquals('function', type(ns.GetUserWaypointFromHyperlink))
            end,
            GetUserWaypointHyperlink = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetUserWaypointHyperlink))
                return
              end
              assertEquals('function', type(ns.GetUserWaypointHyperlink))
            end,
            GetUserWaypointPositionForMap = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetUserWaypointPositionForMap))
                return
              end
              assertEquals('function', type(ns.GetUserWaypointPositionForMap))
            end,
            GetWorldPosFromMapPos = function()
              assertEquals('function', type(ns.GetWorldPosFromMapPos))
            end,
            HasUserWaypoint = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.HasUserWaypoint))
                return
              end
              assertEquals('function', type(ns.HasUserWaypoint))
            end,
            IsMapValidForNavBarDropDown = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsMapValidForNavBarDropDown))
                return
              end
              assertEquals('function', type(ns.IsMapValidForNavBarDropDown))
            end,
            MapHasArt = function()
              assertEquals('function', type(ns.MapHasArt))
            end,
            RequestPreloadMap = function()
              assertEquals('function', type(ns.RequestPreloadMap))
            end,
            SetUserWaypoint = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetUserWaypoint))
                return
              end
              assertEquals('function', type(ns.SetUserWaypoint))
            end,
          }
        end,
        C_MapExplorationInfo = function()
          local ns = _G.C_MapExplorationInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetExploredAreaIDsAtPosition = function()
              assertEquals('function', type(ns.GetExploredAreaIDsAtPosition))
            end,
            GetExploredMapTextures = function()
              assertEquals('function', type(ns.GetExploredMapTextures))
            end,
          }
        end,
        C_MerchantFrame = function()
          local ns = _G.C_MerchantFrame
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetBuybackItemID = function()
              assertEquals('function', type(ns.GetBuybackItemID))
            end,
            IsMerchantItemRefundable = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsMerchantItemRefundable))
                return
              end
              assertEquals('function', type(ns.IsMerchantItemRefundable))
            end,
          }
        end,
        C_Minimap = function()
          local ns = _G.C_Minimap
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetDrawGroundTextures = function()
              assertEquals('function', type(ns.GetDrawGroundTextures))
            end,
            GetUiMapID = function()
              assertEquals('function', type(ns.GetUiMapID))
            end,
            GetViewRadius = function()
              assertEquals('function', type(ns.GetViewRadius))
            end,
            IsRotateMinimapIgnored = function()
              assertEquals('function', type(ns.IsRotateMinimapIgnored))
            end,
            SetDrawGroundTextures = function()
              assertEquals('function', type(ns.SetDrawGroundTextures))
            end,
            SetIgnoreRotateMinimap = function()
              assertEquals('function', type(ns.SetIgnoreRotateMinimap))
            end,
            ShouldUseHybridMinimap = function()
              assertEquals('function', type(ns.ShouldUseHybridMinimap))
            end,
          }
        end,
        C_ModelInfo = function()
          local ns = _G.C_ModelInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            AddActiveModelScene = function()
              assertEquals('function', type(ns.AddActiveModelScene))
            end,
            AddActiveModelSceneActor = function()
              assertEquals('function', type(ns.AddActiveModelSceneActor))
            end,
            ClearActiveModelScene = function()
              assertEquals('function', type(ns.ClearActiveModelScene))
            end,
            ClearActiveModelSceneActor = function()
              assertEquals('function', type(ns.ClearActiveModelSceneActor))
            end,
            GetModelSceneActorDisplayInfoByID = function()
              assertEquals('function', type(ns.GetModelSceneActorDisplayInfoByID))
            end,
            GetModelSceneActorInfoByID = function()
              assertEquals('function', type(ns.GetModelSceneActorInfoByID))
            end,
            GetModelSceneCameraInfoByID = function()
              assertEquals('function', type(ns.GetModelSceneCameraInfoByID))
            end,
            GetModelSceneInfoByID = function()
              assertEquals('function', type(ns.GetModelSceneInfoByID))
            end,
          }
        end,
        C_ModifiedInstance = function()
          local ns = _G.C_ModifiedInstance
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetModifiedInstanceInfoFromMapID = function()
              assertEquals('function', type(ns.GetModifiedInstanceInfoFromMapID))
            end,
          }
        end,
        C_MountJournal = function()
          local ns = _G.C_MountJournal
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            ApplyMountEquipment = function()
              assertEquals('function', type(ns.ApplyMountEquipment))
            end,
            AreMountEquipmentEffectsSuppressed = function()
              assertEquals('function', type(ns.AreMountEquipmentEffectsSuppressed))
            end,
            ClearFanfare = function()
              assertEquals('function', type(ns.ClearFanfare))
            end,
            ClearRecentFanfares = function()
              assertEquals('function', type(ns.ClearRecentFanfares))
            end,
            Dismiss = function()
              assertEquals('function', type(ns.Dismiss))
            end,
            GetAppliedMountEquipmentID = function()
              assertEquals('function', type(ns.GetAppliedMountEquipmentID))
            end,
            GetCollectedFilterSetting = function()
              assertEquals('function', type(ns.GetCollectedFilterSetting))
            end,
            GetDisplayedMountAllCreatureDisplayInfo = function()
              assertEquals('function', type(ns.GetDisplayedMountAllCreatureDisplayInfo))
            end,
            GetDisplayedMountInfo = function()
              assertEquals('function', type(ns.GetDisplayedMountInfo))
            end,
            GetDisplayedMountInfoExtra = function()
              assertEquals('function', type(ns.GetDisplayedMountInfoExtra))
            end,
            GetIsFavorite = function()
              assertEquals('function', type(ns.GetIsFavorite))
            end,
            GetMountAllCreatureDisplayInfoByID = function()
              assertEquals('function', type(ns.GetMountAllCreatureDisplayInfoByID))
            end,
            GetMountEquipmentUnlockLevel = function()
              assertEquals('function', type(ns.GetMountEquipmentUnlockLevel))
            end,
            GetMountFromItem = function()
              assertEquals('function', type(ns.GetMountFromItem))
            end,
            GetMountFromSpell = function()
              assertEquals('function', type(ns.GetMountFromSpell))
            end,
            GetMountIDs = function()
              assertEquals('function', type(ns.GetMountIDs))
            end,
            GetMountInfoByID = function()
              assertEquals('function', type(ns.GetMountInfoByID))
            end,
            GetMountInfoExtraByID = function()
              assertEquals('function', type(ns.GetMountInfoExtraByID))
            end,
            GetMountUsabilityByID = function()
              assertEquals('function', type(ns.GetMountUsabilityByID))
            end,
            GetNumDisplayedMounts = function()
              assertEquals('function', type(ns.GetNumDisplayedMounts))
            end,
            GetNumMounts = function()
              assertEquals('function', type(ns.GetNumMounts))
            end,
            GetNumMountsNeedingFanfare = function()
              assertEquals('function', type(ns.GetNumMountsNeedingFanfare))
            end,
            IsItemMountEquipment = function()
              assertEquals('function', type(ns.IsItemMountEquipment))
            end,
            IsMountEquipmentApplied = function()
              assertEquals('function', type(ns.IsMountEquipmentApplied))
            end,
            IsSourceChecked = function()
              assertEquals('function', type(ns.IsSourceChecked))
            end,
            IsTypeChecked = function()
              assertEquals('function', type(ns.IsTypeChecked))
            end,
            IsUsingDefaultFilters = function()
              assertEquals('function', type(ns.IsUsingDefaultFilters))
            end,
            IsValidSourceFilter = function()
              assertEquals('function', type(ns.IsValidSourceFilter))
            end,
            IsValidTypeFilter = function()
              assertEquals('function', type(ns.IsValidTypeFilter))
            end,
            NeedsFanfare = function()
              assertEquals('function', type(ns.NeedsFanfare))
            end,
            Pickup = function()
              assertEquals('function', type(ns.Pickup))
            end,
            SetAllSourceFilters = function()
              assertEquals('function', type(ns.SetAllSourceFilters))
            end,
            SetAllTypeFilters = function()
              assertEquals('function', type(ns.SetAllTypeFilters))
            end,
            SetCollectedFilterSetting = function()
              assertEquals('function', type(ns.SetCollectedFilterSetting))
            end,
            SetDefaultFilters = function()
              assertEquals('function', type(ns.SetDefaultFilters))
            end,
            SetIsFavorite = function()
              assertEquals('function', type(ns.SetIsFavorite))
            end,
            SetSearch = function()
              assertEquals('function', type(ns.SetSearch))
            end,
            SetSourceFilter = function()
              assertEquals('function', type(ns.SetSourceFilter))
            end,
            SetTypeFilter = function()
              assertEquals('function', type(ns.SetTypeFilter))
            end,
            SummonByID = function()
              assertEquals('function', type(ns.SummonByID))
            end,
          }
        end,
        C_MythicPlus = function()
          local ns = _G.C_MythicPlus
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetCurrentAffixes = function()
              assertEquals('function', type(ns.GetCurrentAffixes))
            end,
            GetCurrentSeason = function()
              assertEquals('function', type(ns.GetCurrentSeason))
            end,
            GetCurrentSeasonValues = function()
              assertEquals('function', type(ns.GetCurrentSeasonValues))
            end,
            GetLastWeeklyBestInformation = function()
              assertEquals('function', type(ns.GetLastWeeklyBestInformation))
            end,
            GetOwnedKeystoneChallengeMapID = function()
              assertEquals('function', type(ns.GetOwnedKeystoneChallengeMapID))
            end,
            GetOwnedKeystoneLevel = function()
              assertEquals('function', type(ns.GetOwnedKeystoneLevel))
            end,
            GetOwnedKeystoneMapID = function()
              assertEquals('function', type(ns.GetOwnedKeystoneMapID))
            end,
            GetRewardLevelForDifficultyLevel = function()
              assertEquals('function', type(ns.GetRewardLevelForDifficultyLevel))
            end,
            GetRewardLevelFromKeystoneLevel = function()
              assertEquals('function', type(ns.GetRewardLevelFromKeystoneLevel))
            end,
            GetRunHistory = function()
              assertEquals('function', type(ns.GetRunHistory))
            end,
            GetSeasonBestAffixScoreInfoForMap = function()
              assertEquals('function', type(ns.GetSeasonBestAffixScoreInfoForMap))
            end,
            GetSeasonBestForMap = function()
              assertEquals('function', type(ns.GetSeasonBestForMap))
            end,
            GetSeasonBestMythicRatingFromThisExpansion = function()
              assertEquals('function', type(ns.GetSeasonBestMythicRatingFromThisExpansion))
            end,
            GetWeeklyBestForMap = function()
              assertEquals('function', type(ns.GetWeeklyBestForMap))
            end,
            GetWeeklyChestRewardLevel = function()
              assertEquals('function', type(ns.GetWeeklyChestRewardLevel))
            end,
            IsMythicPlusActive = function()
              assertEquals('function', type(ns.IsMythicPlusActive))
            end,
            IsWeeklyRewardAvailable = function()
              assertEquals('function', type(ns.IsWeeklyRewardAvailable))
            end,
            RequestCurrentAffixes = function()
              assertEquals('function', type(ns.RequestCurrentAffixes))
            end,
            RequestMapInfo = function()
              assertEquals('function', type(ns.RequestMapInfo))
            end,
            RequestRewards = function()
              assertEquals('function', type(ns.RequestRewards))
            end,
          }
        end,
        C_NamePlate = function()
          local ns = _G.C_NamePlate
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetNamePlateForUnit = function()
              assertEquals('function', type(ns.GetNamePlateForUnit))
            end,
            GetNamePlates = function()
              assertEquals('function', type(ns.GetNamePlates))
            end,
            GetNumNamePlateMotionTypes = function()
              assertEquals('function', type(ns.GetNumNamePlateMotionTypes))
            end,
            SetNamePlateEnemySize = function()
              assertEquals('function', type(ns.SetNamePlateEnemySize))
            end,
            SetNamePlateFriendlySize = function()
              assertEquals('function', type(ns.SetNamePlateFriendlySize))
            end,
            SetNamePlateSelfClickThrough = function()
              assertEquals('function', type(ns.SetNamePlateSelfClickThrough))
            end,
            SetNamePlateSelfSize = function()
              assertEquals('function', type(ns.SetNamePlateSelfSize))
            end,
            SetTargetClampingInsets = function()
              assertEquals('function', type(ns.SetTargetClampingInsets))
            end,
          }
        end,
        C_Navigation = function()
          local ns = _G.C_Navigation
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetDistance = function()
              assertEquals('function', type(ns.GetDistance))
            end,
            GetFrame = function()
              assertEquals('function', type(ns.GetFrame))
            end,
            GetTargetState = function()
              assertEquals('function', type(ns.GetTargetState))
            end,
            HasValidScreenPosition = function()
              assertEquals('function', type(ns.HasValidScreenPosition))
            end,
            WasClampedToScreen = function()
              assertEquals('function', type(ns.WasClampedToScreen))
            end,
          }
        end,
        C_NewItems = function()
          local ns = _G.C_NewItems
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            IsNewItem = function()
              assertEquals('function', type(ns.IsNewItem))
            end,
            RemoveNewItem = function()
              assertEquals('function', type(ns.RemoveNewItem))
            end,
          }
        end,
        C_PaperDollInfo = function()
          local ns = _G.C_PaperDollInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetArmorEffectiveness = function()
              assertEquals('function', type(ns.GetArmorEffectiveness))
            end,
            GetArmorEffectivenessAgainstTarget = function()
              assertEquals('function', type(ns.GetArmorEffectivenessAgainstTarget))
            end,
            GetInspectAzeriteItemEmpoweredChoices = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetInspectAzeriteItemEmpoweredChoices))
                return
              end
              assertEquals('function', type(ns.GetInspectAzeriteItemEmpoweredChoices))
            end,
            GetInspectItemLevel = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetInspectItemLevel))
                return
              end
              assertEquals('function', type(ns.GetInspectItemLevel))
            end,
            GetMinItemLevel = function()
              assertEquals('function', type(ns.GetMinItemLevel))
            end,
            GetStaggerPercentage = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetStaggerPercentage))
                return
              end
              assertEquals('function', type(ns.GetStaggerPercentage))
            end,
            OffhandHasShield = function()
              assertEquals('function', type(ns.OffhandHasShield))
            end,
            OffhandHasWeapon = function()
              assertEquals('function', type(ns.OffhandHasWeapon))
            end,
          }
        end,
        C_PartyInfo = function()
          local ns = _G.C_PartyInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            AllowedToDoPartyConversion = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.AllowedToDoPartyConversion))
                return
              end
              assertEquals('function', type(ns.AllowedToDoPartyConversion))
            end,
            CanFormCrossFactionParties = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanFormCrossFactionParties))
                return
              end
              assertEquals('function', type(ns.CanFormCrossFactionParties))
            end,
            CanInvite = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanInvite))
                return
              end
              assertEquals('function', type(ns.CanInvite))
            end,
            ConfirmConvertToRaid = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ConfirmConvertToRaid))
                return
              end
              assertEquals('function', type(ns.ConfirmConvertToRaid))
            end,
            ConfirmInviteTravelPass = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ConfirmInviteTravelPass))
                return
              end
              assertEquals('function', type(ns.ConfirmInviteTravelPass))
            end,
            ConfirmInviteUnit = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ConfirmInviteUnit))
                return
              end
              assertEquals('function', type(ns.ConfirmInviteUnit))
            end,
            ConfirmLeaveParty = function()
              assertEquals('function', type(ns.ConfirmLeaveParty))
            end,
            ConfirmRequestInviteFromUnit = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ConfirmRequestInviteFromUnit))
                return
              end
              assertEquals('function', type(ns.ConfirmRequestInviteFromUnit))
            end,
            ConvertToParty = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ConvertToParty))
                return
              end
              assertEquals('function', type(ns.ConvertToParty))
            end,
            ConvertToRaid = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ConvertToRaid))
                return
              end
              assertEquals('function', type(ns.ConvertToRaid))
            end,
            DoCountdown = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.DoCountdown))
                return
              end
              assertEquals('function', type(ns.DoCountdown))
            end,
            GetActiveCategories = function()
              assertEquals('function', type(ns.GetActiveCategories))
            end,
            GetInviteConfirmationInvalidQueues = function()
              assertEquals('function', type(ns.GetInviteConfirmationInvalidQueues))
            end,
            GetInviteReferralInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetInviteReferralInfo))
                return
              end
              assertEquals('function', type(ns.GetInviteReferralInfo))
            end,
            GetMinLevel = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetMinLevel))
                return
              end
              assertEquals('function', type(ns.GetMinLevel))
            end,
            InviteUnit = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.InviteUnit))
                return
              end
              assertEquals('function', type(ns.InviteUnit))
            end,
            IsCrossFactionParty = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsCrossFactionParty))
                return
              end
              assertEquals('function', type(ns.IsCrossFactionParty))
            end,
            IsPartyFull = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsPartyFull))
                return
              end
              assertEquals('function', type(ns.IsPartyFull))
            end,
            IsPartyInJailersTower = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsPartyInJailersTower))
                return
              end
              assertEquals('function', type(ns.IsPartyInJailersTower))
            end,
            LeaveParty = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.LeaveParty))
                return
              end
              assertEquals('function', type(ns.LeaveParty))
            end,
            RequestInviteFromUnit = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.RequestInviteFromUnit))
                return
              end
              assertEquals('function', type(ns.RequestInviteFromUnit))
            end,
          }
        end,
        C_PartyPose = function()
          local ns = _G.C_PartyPose
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetPartyPoseInfoByMapID = function()
              assertEquals('function', type(ns.GetPartyPoseInfoByMapID))
            end,
          }
        end,
        C_PetBattles = function()
          local ns = _G.C_PetBattles
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            CanPetSwapIn = function()
              assertEquals('function', type(ns.CanPetSwapIn))
            end,
            GetAllEffectNames = function()
              assertEquals('function', type(ns.GetAllEffectNames))
            end,
            GetAllStates = function()
              assertEquals('function', type(ns.GetAllStates))
            end,
            GetBattleState = function()
              assertEquals('function', type(ns.GetBattleState))
            end,
            GetBreedQuality = function()
              assertEquals('function', type(ns.GetBreedQuality))
            end,
            GetDisplayID = function()
              assertEquals('function', type(ns.GetDisplayID))
            end,
            GetHealth = function()
              assertEquals('function', type(ns.GetHealth))
            end,
            GetIcon = function()
              assertEquals('function', type(ns.GetIcon))
            end,
            GetLevel = function()
              assertEquals('function', type(ns.GetLevel))
            end,
            GetMaxHealth = function()
              assertEquals('function', type(ns.GetMaxHealth))
            end,
            GetName = function()
              assertEquals('function', type(ns.GetName))
            end,
            GetNumPets = function()
              assertEquals('function', type(ns.GetNumPets))
            end,
            GetPVPMatchmakingInfo = function()
              assertEquals('function', type(ns.GetPVPMatchmakingInfo))
            end,
            GetPetSpeciesID = function()
              assertEquals('function', type(ns.GetPetSpeciesID))
            end,
            GetPlayerTrapAbility = function()
              assertEquals('function', type(ns.GetPlayerTrapAbility))
            end,
            GetSelectedAction = function()
              assertEquals('function', type(ns.GetSelectedAction))
            end,
            GetTurnTimeInfo = function()
              assertEquals('function', type(ns.GetTurnTimeInfo))
            end,
            IsInBattle = function()
              assertEquals('function', type(ns.IsInBattle))
            end,
            IsPlayerNPC = function()
              assertEquals('function', type(ns.IsPlayerNPC))
            end,
            IsSkipAvailable = function()
              assertEquals('function', type(ns.IsSkipAvailable))
            end,
            IsTrapAvailable = function()
              assertEquals('function', type(ns.IsTrapAvailable))
            end,
            IsWildBattle = function()
              assertEquals('function', type(ns.IsWildBattle))
            end,
            ShouldShowPetSelect = function()
              assertEquals('function', type(ns.ShouldShowPetSelect))
            end,
          }
        end,
        C_PetInfo = function()
          local ns = _G.C_PetInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetPetTamersForMap = function()
              assertEquals('function', type(ns.GetPetTamersForMap))
            end,
          }
        end,
        C_PetJournal = function()
          local ns = _G.C_PetJournal
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            ClearRecentFanfares = function()
              assertEquals('function', type(ns.ClearRecentFanfares))
            end,
            GetDisplayIDByIndex = function()
              assertEquals('function', type(ns.GetDisplayIDByIndex))
            end,
            GetDisplayProbabilityByIndex = function()
              assertEquals('function', type(ns.GetDisplayProbabilityByIndex))
            end,
            GetNumDisplays = function()
              assertEquals('function', type(ns.GetNumDisplays))
            end,
            GetNumPetSources = function()
              assertEquals('function', type(ns.GetNumPetSources))
            end,
            GetNumPets = function()
              assertEquals('function', type(ns.GetNumPets))
            end,
            GetNumPetsNeedingFanfare = function()
              assertEquals('function', type(ns.GetNumPetsNeedingFanfare))
            end,
            GetPetAbilityInfo = function()
              assertEquals('function', type(ns.GetPetAbilityInfo))
            end,
            GetPetAbilityListTable = function()
              assertEquals('function', type(ns.GetPetAbilityListTable))
            end,
            GetPetInfoByIndex = function()
              assertEquals('function', type(ns.GetPetInfoByIndex))
            end,
            GetPetInfoBySpeciesID = function()
              assertEquals('function', type(ns.GetPetInfoBySpeciesID))
            end,
            GetPetInfoTableByPetID = function()
              assertEquals('function', type(ns.GetPetInfoTableByPetID))
            end,
            GetPetLoadOutInfo = function()
              assertEquals('function', type(ns.GetPetLoadOutInfo))
            end,
            GetPetSummonInfo = function()
              assertEquals('function', type(ns.GetPetSummonInfo))
            end,
            GetSummonBattlePetCooldown = function()
              assertEquals('function', type(ns.GetSummonBattlePetCooldown))
            end,
            GetSummonRandomFavoritePetGUID = function()
              assertEquals('function', type(ns.GetSummonRandomFavoritePetGUID))
            end,
            GetSummonedPetGUID = function()
              assertEquals('function', type(ns.GetSummonedPetGUID))
            end,
            IsFindBattleEnabled = function()
              assertEquals('function', type(ns.IsFindBattleEnabled))
            end,
            IsJournalUnlocked = function()
              assertEquals('function', type(ns.IsJournalUnlocked))
            end,
            IsUsingDefaultFilters = function()
              assertEquals('function', type(ns.IsUsingDefaultFilters))
            end,
            PetIsSummonable = function()
              assertEquals('function', type(ns.PetIsSummonable))
            end,
            PetUsesRandomDisplay = function()
              assertEquals('function', type(ns.PetUsesRandomDisplay))
            end,
            SetDefaultFilters = function()
              assertEquals('function', type(ns.SetDefaultFilters))
            end,
            SummonRandomPet = function()
              assertEquals('function', type(ns.SummonRandomPet))
            end,
          }
        end,
        C_PlayerChoice = function()
          local ns = _G.C_PlayerChoice
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetCurrentPlayerChoiceInfo = function()
              assertEquals('function', type(ns.GetCurrentPlayerChoiceInfo))
            end,
            GetNumRerolls = function()
              assertEquals('function', type(ns.GetNumRerolls))
            end,
            GetRemainingTime = function()
              assertEquals('function', type(ns.GetRemainingTime))
            end,
            IsWaitingForPlayerChoiceResponse = function()
              assertEquals('function', type(ns.IsWaitingForPlayerChoiceResponse))
            end,
            OnUIClosed = function()
              assertEquals('function', type(ns.OnUIClosed))
            end,
            RequestRerollPlayerChoice = function()
              assertEquals('function', type(ns.RequestRerollPlayerChoice))
            end,
            SendPlayerChoiceResponse = function()
              assertEquals('function', type(ns.SendPlayerChoiceResponse))
            end,
          }
        end,
        C_PlayerInfo = function()
          local ns = _G.C_PlayerInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            CanPlayerEnterChromieTime = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanPlayerEnterChromieTime))
                return
              end
              assertEquals('function', type(ns.CanPlayerEnterChromieTime))
            end,
            CanPlayerUseAreaLoot = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanPlayerUseAreaLoot))
                return
              end
              assertEquals('function', type(ns.CanPlayerUseAreaLoot))
            end,
            CanPlayerUseMountEquipment = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanPlayerUseMountEquipment))
                return
              end
              assertEquals('function', type(ns.CanPlayerUseMountEquipment))
            end,
            GUIDIsPlayer = function()
              assertEquals('function', type(ns.GUIDIsPlayer))
            end,
            GetAlternateFormInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetAlternateFormInfo))
                return
              end
              assertEquals('function', type(ns.GetAlternateFormInfo))
            end,
            GetClass = function()
              assertEquals('function', type(ns.GetClass))
            end,
            GetContentDifficultyCreatureForPlayer = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetContentDifficultyCreatureForPlayer))
                return
              end
              assertEquals('function', type(ns.GetContentDifficultyCreatureForPlayer))
            end,
            GetContentDifficultyQuestForPlayer = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetContentDifficultyQuestForPlayer))
                return
              end
              assertEquals('function', type(ns.GetContentDifficultyQuestForPlayer))
            end,
            GetInstancesUnlockedAtLevel = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetInstancesUnlockedAtLevel))
                return
              end
              assertEquals('function', type(ns.GetInstancesUnlockedAtLevel))
            end,
            GetName = function()
              assertEquals('function', type(ns.GetName))
            end,
            GetPlayerMythicPlusRatingSummary = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetPlayerMythicPlusRatingSummary))
                return
              end
              assertEquals('function', type(ns.GetPlayerMythicPlusRatingSummary))
            end,
            GetRace = function()
              assertEquals('function', type(ns.GetRace))
            end,
            GetSex = function()
              assertEquals('function', type(ns.GetSex))
            end,
            IsConnected = function()
              assertEquals('function', type(ns.IsConnected))
            end,
            IsPlayerEligibleForNPE = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsPlayerEligibleForNPE))
                return
              end
              assertEquals('function', type(ns.IsPlayerEligibleForNPE))
            end,
            IsPlayerEligibleForNPEv2 = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsPlayerEligibleForNPEv2))
                return
              end
              assertEquals('function', type(ns.IsPlayerEligibleForNPEv2))
            end,
            IsPlayerInChromieTime = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsPlayerInChromieTime))
                return
              end
              assertEquals('function', type(ns.IsPlayerInChromieTime))
            end,
            IsPlayerInGuildFromGUID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsPlayerInGuildFromGUID))
                return
              end
              assertEquals('function', type(ns.IsPlayerInGuildFromGUID))
            end,
            IsPlayerNPERestricted = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsPlayerNPERestricted))
                return
              end
              assertEquals('function', type(ns.IsPlayerNPERestricted))
            end,
            UnitIsSameServer = function()
              assertEquals('function', type(ns.UnitIsSameServer))
            end,
          }
        end,
        C_PlayerMentorship = function()
          local ns = _G.C_PlayerMentorship
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetMentorLevelRequirement = function()
              assertEquals('function', type(ns.GetMentorLevelRequirement))
            end,
            GetMentorRequirements = function()
              assertEquals('function', type(ns.GetMentorRequirements))
            end,
            GetMentorshipStatus = function()
              assertEquals('function', type(ns.GetMentorshipStatus))
            end,
            IsActivePlayerConsideredNewcomer = function()
              assertEquals('function', type(ns.IsActivePlayerConsideredNewcomer))
            end,
            IsMentorRestricted = function()
              assertEquals('function', type(ns.IsMentorRestricted))
            end,
          }
        end,
        C_ProductChoice = function()
          local ns = _G.C_ProductChoice
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetChoices = function()
              assertEquals('function', type(ns.GetChoices))
            end,
            GetNumSuppressed = function()
              assertEquals('function', type(ns.GetNumSuppressed))
            end,
          }
        end,
        C_PvP = function()
          local ns = _G.C_PvP
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            CanDisplayDamage = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanDisplayDamage))
                return
              end
              assertEquals('function', type(ns.CanDisplayDamage))
            end,
            CanDisplayDeaths = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanDisplayDeaths))
                return
              end
              assertEquals('function', type(ns.CanDisplayDeaths))
            end,
            CanDisplayHealing = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanDisplayHealing))
                return
              end
              assertEquals('function', type(ns.CanDisplayHealing))
            end,
            CanDisplayHonorableKills = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanDisplayHonorableKills))
                return
              end
              assertEquals('function', type(ns.CanDisplayHonorableKills))
            end,
            CanDisplayKillingBlows = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanDisplayKillingBlows))
                return
              end
              assertEquals('function', type(ns.CanDisplayKillingBlows))
            end,
            CanPlayerUseRatedPVPUI = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanPlayerUseRatedPVPUI))
                return
              end
              assertEquals('function', type(ns.CanPlayerUseRatedPVPUI))
            end,
            CanToggleWarMode = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanToggleWarMode))
                return
              end
              assertEquals('function', type(ns.CanToggleWarMode))
            end,
            CanToggleWarModeInArea = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanToggleWarModeInArea))
                return
              end
              assertEquals('function', type(ns.CanToggleWarModeInArea))
            end,
            DoesMatchOutcomeAffectRating = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.DoesMatchOutcomeAffectRating))
                return
              end
              assertEquals('function', type(ns.DoesMatchOutcomeAffectRating))
            end,
            GetActiveBrawlInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetActiveBrawlInfo))
                return
              end
              assertEquals('function', type(ns.GetActiveBrawlInfo))
            end,
            GetActiveMatchBracket = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetActiveMatchBracket))
                return
              end
              assertEquals('function', type(ns.GetActiveMatchBracket))
            end,
            GetActiveMatchDuration = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetActiveMatchDuration))
                return
              end
              assertEquals('function', type(ns.GetActiveMatchDuration))
            end,
            GetActiveMatchState = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetActiveMatchState))
                return
              end
              assertEquals('function', type(ns.GetActiveMatchState))
            end,
            GetActiveMatchWinner = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetActiveMatchWinner))
                return
              end
              assertEquals('function', type(ns.GetActiveMatchWinner))
            end,
            GetArenaCrowdControlInfo = function()
              assertEquals('function', type(ns.GetArenaCrowdControlInfo))
            end,
            GetArenaRewards = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetArenaRewards))
                return
              end
              assertEquals('function', type(ns.GetArenaRewards))
            end,
            GetArenaSkirmishRewards = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetArenaSkirmishRewards))
                return
              end
              assertEquals('function', type(ns.GetArenaSkirmishRewards))
            end,
            GetAvailableBrawlInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetAvailableBrawlInfo))
                return
              end
              assertEquals('function', type(ns.GetAvailableBrawlInfo))
            end,
            GetBattlefieldFlagPosition = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetBattlefieldFlagPosition))
                return
              end
              assertEquals('function', type(ns.GetBattlefieldFlagPosition))
            end,
            GetBattlefieldVehicleInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetBattlefieldVehicleInfo))
                return
              end
              assertEquals('function', type(ns.GetBattlefieldVehicleInfo))
            end,
            GetBattlefieldVehicles = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetBattlefieldVehicles))
                return
              end
              assertEquals('function', type(ns.GetBattlefieldVehicles))
            end,
            GetBrawlRewards = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetBrawlRewards))
                return
              end
              assertEquals('function', type(ns.GetBrawlRewards))
            end,
            GetCustomVictoryStatID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetCustomVictoryStatID))
                return
              end
              assertEquals('function', type(ns.GetCustomVictoryStatID))
            end,
            GetGlobalPvpScalingInfoForSpecID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetGlobalPvpScalingInfoForSpecID))
                return
              end
              assertEquals('function', type(ns.GetGlobalPvpScalingInfoForSpecID))
            end,
            GetHonorRewardInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetHonorRewardInfo))
                return
              end
              assertEquals('function', type(ns.GetHonorRewardInfo))
            end,
            GetLevelUpBattlegrounds = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetLevelUpBattlegrounds))
                return
              end
              assertEquals('function', type(ns.GetLevelUpBattlegrounds))
            end,
            GetMatchPVPStatColumn = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetMatchPVPStatColumn))
                return
              end
              assertEquals('function', type(ns.GetMatchPVPStatColumn))
            end,
            GetMatchPVPStatColumns = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetMatchPVPStatColumns))
                return
              end
              assertEquals('function', type(ns.GetMatchPVPStatColumns))
            end,
            GetNextHonorLevelForReward = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetNextHonorLevelForReward))
                return
              end
              assertEquals('function', type(ns.GetNextHonorLevelForReward))
            end,
            GetOutdoorPvPWaitTime = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetOutdoorPvPWaitTime))
                return
              end
              assertEquals('function', type(ns.GetOutdoorPvPWaitTime))
            end,
            GetPVPActiveMatchPersonalRatedInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetPVPActiveMatchPersonalRatedInfo))
                return
              end
              assertEquals('function', type(ns.GetPVPActiveMatchPersonalRatedInfo))
            end,
            GetPVPSeasonRewardAchievementID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetPVPSeasonRewardAchievementID))
                return
              end
              assertEquals('function', type(ns.GetPVPSeasonRewardAchievementID))
            end,
            GetPostMatchCurrencyRewards = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetPostMatchCurrencyRewards))
                return
              end
              assertEquals('function', type(ns.GetPostMatchCurrencyRewards))
            end,
            GetPostMatchItemRewards = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetPostMatchItemRewards))
                return
              end
              assertEquals('function', type(ns.GetPostMatchItemRewards))
            end,
            GetPvpTierID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetPvpTierID))
                return
              end
              assertEquals('function', type(ns.GetPvpTierID))
            end,
            GetPvpTierInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetPvpTierInfo))
                return
              end
              assertEquals('function', type(ns.GetPvpTierInfo))
            end,
            GetRandomBGInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetRandomBGInfo))
                return
              end
              assertEquals('function', type(ns.GetRandomBGInfo))
            end,
            GetRandomBGRewards = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetRandomBGRewards))
                return
              end
              assertEquals('function', type(ns.GetRandomBGRewards))
            end,
            GetRandomEpicBGInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetRandomEpicBGInfo))
                return
              end
              assertEquals('function', type(ns.GetRandomEpicBGInfo))
            end,
            GetRandomEpicBGRewards = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetRandomEpicBGRewards))
                return
              end
              assertEquals('function', type(ns.GetRandomEpicBGRewards))
            end,
            GetRatedBGRewards = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetRatedBGRewards))
                return
              end
              assertEquals('function', type(ns.GetRatedBGRewards))
            end,
            GetRewardItemLevelsByTierEnum = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetRewardItemLevelsByTierEnum))
                return
              end
              assertEquals('function', type(ns.GetRewardItemLevelsByTierEnum))
            end,
            GetScoreInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetScoreInfo))
                return
              end
              assertEquals('function', type(ns.GetScoreInfo))
            end,
            GetScoreInfoByPlayerGuid = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetScoreInfoByPlayerGuid))
                return
              end
              assertEquals('function', type(ns.GetScoreInfoByPlayerGuid))
            end,
            GetSeasonBestInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetSeasonBestInfo))
                return
              end
              assertEquals('function', type(ns.GetSeasonBestInfo))
            end,
            GetSkirmishInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetSkirmishInfo))
                return
              end
              assertEquals('function', type(ns.GetSkirmishInfo))
            end,
            GetSpecialEventBrawlInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetSpecialEventBrawlInfo))
                return
              end
              assertEquals('function', type(ns.GetSpecialEventBrawlInfo))
            end,
            GetTeamInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetTeamInfo))
                return
              end
              assertEquals('function', type(ns.GetTeamInfo))
            end,
            GetWarModeRewardBonus = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetWarModeRewardBonus))
                return
              end
              assertEquals('function', type(ns.GetWarModeRewardBonus))
            end,
            GetWarModeRewardBonusDefault = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetWarModeRewardBonusDefault))
                return
              end
              assertEquals('function', type(ns.GetWarModeRewardBonusDefault))
            end,
            GetWeeklyChestInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetWeeklyChestInfo))
                return
              end
              assertEquals('function', type(ns.GetWeeklyChestInfo))
            end,
            HasArenaSkirmishWinToday = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.HasArenaSkirmishWinToday))
                return
              end
              assertEquals('function', type(ns.HasArenaSkirmishWinToday))
            end,
            IsActiveBattlefield = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsActiveBattlefield))
                return
              end
              assertEquals('function', type(ns.IsActiveBattlefield))
            end,
            IsActiveMatchRegistered = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsActiveMatchRegistered))
                return
              end
              assertEquals('function', type(ns.IsActiveMatchRegistered))
            end,
            IsArena = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsArena))
                return
              end
              assertEquals('function', type(ns.IsArena))
            end,
            IsBattleground = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsBattleground))
                return
              end
              assertEquals('function', type(ns.IsBattleground))
            end,
            IsBattlegroundEnlistmentBonusActive = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsBattlegroundEnlistmentBonusActive))
                return
              end
              assertEquals('function', type(ns.IsBattlegroundEnlistmentBonusActive))
            end,
            IsInBrawl = function()
              assertEquals('function', type(ns.IsInBrawl))
            end,
            IsMatchConsideredArena = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsMatchConsideredArena))
                return
              end
              assertEquals('function', type(ns.IsMatchConsideredArena))
            end,
            IsMatchFactional = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsMatchFactional))
                return
              end
              assertEquals('function', type(ns.IsMatchFactional))
            end,
            IsPVPMap = function()
              assertEquals('function', type(ns.IsPVPMap))
            end,
            IsRatedArena = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsRatedArena))
                return
              end
              assertEquals('function', type(ns.IsRatedArena))
            end,
            IsRatedBattleground = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsRatedBattleground))
                return
              end
              assertEquals('function', type(ns.IsRatedBattleground))
            end,
            IsRatedMap = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsRatedMap))
                return
              end
              assertEquals('function', type(ns.IsRatedMap))
            end,
            IsSoloShuffle = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsSoloShuffle))
                return
              end
              assertEquals('function', type(ns.IsSoloShuffle))
            end,
            IsWarModeActive = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsWarModeActive))
                return
              end
              assertEquals('function', type(ns.IsWarModeActive))
            end,
            IsWarModeDesired = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsWarModeDesired))
                return
              end
              assertEquals('function', type(ns.IsWarModeDesired))
            end,
            IsWarModeFeatureEnabled = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsWarModeFeatureEnabled))
                return
              end
              assertEquals('function', type(ns.IsWarModeFeatureEnabled))
            end,
            JoinBrawl = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.JoinBrawl))
                return
              end
              assertEquals('function', type(ns.JoinBrawl))
            end,
            RequestCrowdControlSpell = function()
              assertEquals('function', type(ns.RequestCrowdControlSpell))
            end,
            SetWarModeDesired = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetWarModeDesired))
                return
              end
              assertEquals('function', type(ns.SetWarModeDesired))
            end,
            ToggleWarMode = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ToggleWarMode))
                return
              end
              assertEquals('function', type(ns.ToggleWarMode))
            end,
          }
        end,
        C_QuestLine = function()
          local ns = _G.C_QuestLine
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetAvailableQuestLines = function()
              assertEquals('function', type(ns.GetAvailableQuestLines))
            end,
            GetQuestLineInfo = function()
              assertEquals('function', type(ns.GetQuestLineInfo))
            end,
            GetQuestLineQuests = function()
              assertEquals('function', type(ns.GetQuestLineQuests))
            end,
            IsComplete = function()
              assertEquals('function', type(ns.IsComplete))
            end,
            RequestQuestLinesForMap = function()
              assertEquals('function', type(ns.RequestQuestLinesForMap))
            end,
          }
        end,
        C_QuestLog = function()
          local ns = _G.C_QuestLog
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            AbandonQuest = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.AbandonQuest))
                return
              end
              assertEquals('function', type(ns.AbandonQuest))
            end,
            AddQuestWatch = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.AddQuestWatch))
                return
              end
              assertEquals('function', type(ns.AddQuestWatch))
            end,
            AddWorldQuestWatch = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.AddWorldQuestWatch))
                return
              end
              assertEquals('function', type(ns.AddWorldQuestWatch))
            end,
            CanAbandonQuest = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanAbandonQuest))
                return
              end
              assertEquals('function', type(ns.CanAbandonQuest))
            end,
            GetAbandonQuest = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetAbandonQuest))
                return
              end
              assertEquals('function', type(ns.GetAbandonQuest))
            end,
            GetAbandonQuestItems = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetAbandonQuestItems))
                return
              end
              assertEquals('function', type(ns.GetAbandonQuestItems))
            end,
            GetActiveThreatMaps = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetActiveThreatMaps))
                return
              end
              assertEquals('function', type(ns.GetActiveThreatMaps))
            end,
            GetAllCompletedQuestIDs = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetAllCompletedQuestIDs))
                return
              end
              assertEquals('function', type(ns.GetAllCompletedQuestIDs))
            end,
            GetBountiesForMapID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetBountiesForMapID))
                return
              end
              assertEquals('function', type(ns.GetBountiesForMapID))
            end,
            GetBountySetInfoForMapID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetBountySetInfoForMapID))
                return
              end
              assertEquals('function', type(ns.GetBountySetInfoForMapID))
            end,
            GetDistanceSqToQuest = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetDistanceSqToQuest))
                return
              end
              assertEquals('function', type(ns.GetDistanceSqToQuest))
            end,
            GetInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetInfo))
                return
              end
              assertEquals('function', type(ns.GetInfo))
            end,
            GetLogIndexForQuestID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetLogIndexForQuestID))
                return
              end
              assertEquals('function', type(ns.GetLogIndexForQuestID))
            end,
            GetMapForQuestPOIs = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetMapForQuestPOIs))
                return
              end
              assertEquals('function', type(ns.GetMapForQuestPOIs))
            end,
            GetMaxNumQuests = function()
              assertEquals('function', type(ns.GetMaxNumQuests))
            end,
            GetMaxNumQuestsCanAccept = function()
              assertEquals('function', type(ns.GetMaxNumQuestsCanAccept))
            end,
            GetNextWaypoint = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetNextWaypoint))
                return
              end
              assertEquals('function', type(ns.GetNextWaypoint))
            end,
            GetNextWaypointForMap = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetNextWaypointForMap))
                return
              end
              assertEquals('function', type(ns.GetNextWaypointForMap))
            end,
            GetNextWaypointText = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetNextWaypointText))
                return
              end
              assertEquals('function', type(ns.GetNextWaypointText))
            end,
            GetNumQuestLogEntries = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetNumQuestLogEntries))
                return
              end
              assertEquals('function', type(ns.GetNumQuestLogEntries))
            end,
            GetNumQuestObjectives = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetNumQuestObjectives))
                return
              end
              assertEquals('function', type(ns.GetNumQuestObjectives))
            end,
            GetNumQuestWatches = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetNumQuestWatches))
                return
              end
              assertEquals('function', type(ns.GetNumQuestWatches))
            end,
            GetNumWorldQuestWatches = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetNumWorldQuestWatches))
                return
              end
              assertEquals('function', type(ns.GetNumWorldQuestWatches))
            end,
            GetQuestAdditionalHighlights = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetQuestAdditionalHighlights))
                return
              end
              assertEquals('function', type(ns.GetQuestAdditionalHighlights))
            end,
            GetQuestDetailsTheme = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetQuestDetailsTheme))
                return
              end
              assertEquals('function', type(ns.GetQuestDetailsTheme))
            end,
            GetQuestDifficultyLevel = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetQuestDifficultyLevel))
                return
              end
              assertEquals('function', type(ns.GetQuestDifficultyLevel))
            end,
            GetQuestIDForLogIndex = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetQuestIDForLogIndex))
                return
              end
              assertEquals('function', type(ns.GetQuestIDForLogIndex))
            end,
            GetQuestIDForQuestWatchIndex = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetQuestIDForQuestWatchIndex))
                return
              end
              assertEquals('function', type(ns.GetQuestIDForQuestWatchIndex))
            end,
            GetQuestIDForWorldQuestWatchIndex = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetQuestIDForWorldQuestWatchIndex))
                return
              end
              assertEquals('function', type(ns.GetQuestIDForWorldQuestWatchIndex))
            end,
            GetQuestInfo = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetQuestInfo))
                return
              end
              assertEquals('function', type(ns.GetQuestInfo))
            end,
            GetQuestLogPortraitGiver = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetQuestLogPortraitGiver))
                return
              end
              assertEquals('function', type(ns.GetQuestLogPortraitGiver))
            end,
            GetQuestObjectives = function()
              assertEquals('function', type(ns.GetQuestObjectives))
            end,
            GetQuestTagInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetQuestTagInfo))
                return
              end
              assertEquals('function', type(ns.GetQuestTagInfo))
            end,
            GetQuestType = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetQuestType))
                return
              end
              assertEquals('function', type(ns.GetQuestType))
            end,
            GetQuestWatchType = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetQuestWatchType))
                return
              end
              assertEquals('function', type(ns.GetQuestWatchType))
            end,
            GetQuestsOnMap = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetQuestsOnMap))
                return
              end
              assertEquals('function', type(ns.GetQuestsOnMap))
            end,
            GetRequiredMoney = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetRequiredMoney))
                return
              end
              assertEquals('function', type(ns.GetRequiredMoney))
            end,
            GetSelectedQuest = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetSelectedQuest))
                return
              end
              assertEquals('function', type(ns.GetSelectedQuest))
            end,
            GetSuggestedGroupSize = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetSuggestedGroupSize))
                return
              end
              assertEquals('function', type(ns.GetSuggestedGroupSize))
            end,
            GetTimeAllowed = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetTimeAllowed))
                return
              end
              assertEquals('function', type(ns.GetTimeAllowed))
            end,
            GetTitleForLogIndex = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetTitleForLogIndex))
                return
              end
              assertEquals('function', type(ns.GetTitleForLogIndex))
            end,
            GetTitleForQuestID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetTitleForQuestID))
                return
              end
              assertEquals('function', type(ns.GetTitleForQuestID))
            end,
            GetZoneStoryInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetZoneStoryInfo))
                return
              end
              assertEquals('function', type(ns.GetZoneStoryInfo))
            end,
            HasActiveThreats = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.HasActiveThreats))
                return
              end
              assertEquals('function', type(ns.HasActiveThreats))
            end,
            IsAccountQuest = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsAccountQuest))
                return
              end
              assertEquals('function', type(ns.IsAccountQuest))
            end,
            IsComplete = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsComplete))
                return
              end
              assertEquals('function', type(ns.IsComplete))
            end,
            IsFailed = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsFailed))
                return
              end
              assertEquals('function', type(ns.IsFailed))
            end,
            IsLegendaryQuest = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsLegendaryQuest))
                return
              end
              assertEquals('function', type(ns.IsLegendaryQuest))
            end,
            IsOnMap = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsOnMap))
                return
              end
              assertEquals('function', type(ns.IsOnMap))
            end,
            IsOnQuest = function()
              assertEquals('function', type(ns.IsOnQuest))
            end,
            IsPushableQuest = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsPushableQuest))
                return
              end
              assertEquals('function', type(ns.IsPushableQuest))
            end,
            IsQuestBounty = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsQuestBounty))
                return
              end
              assertEquals('function', type(ns.IsQuestBounty))
            end,
            IsQuestCalling = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsQuestCalling))
                return
              end
              assertEquals('function', type(ns.IsQuestCalling))
            end,
            IsQuestCriteriaForBounty = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsQuestCriteriaForBounty))
                return
              end
              assertEquals('function', type(ns.IsQuestCriteriaForBounty))
            end,
            IsQuestDisabledForSession = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsQuestDisabledForSession))
                return
              end
              assertEquals('function', type(ns.IsQuestDisabledForSession))
            end,
            IsQuestFlaggedCompleted = function()
              assertEquals('function', type(ns.IsQuestFlaggedCompleted))
            end,
            IsQuestInvasion = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsQuestInvasion))
                return
              end
              assertEquals('function', type(ns.IsQuestInvasion))
            end,
            IsQuestReplayable = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsQuestReplayable))
                return
              end
              assertEquals('function', type(ns.IsQuestReplayable))
            end,
            IsQuestReplayedRecently = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsQuestReplayedRecently))
                return
              end
              assertEquals('function', type(ns.IsQuestReplayedRecently))
            end,
            IsQuestTask = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsQuestTask))
                return
              end
              assertEquals('function', type(ns.IsQuestTask))
            end,
            IsQuestTrivial = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsQuestTrivial))
                return
              end
              assertEquals('function', type(ns.IsQuestTrivial))
            end,
            IsRepeatableQuest = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsRepeatableQuest))
                return
              end
              assertEquals('function', type(ns.IsRepeatableQuest))
            end,
            IsThreatQuest = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsThreatQuest))
                return
              end
              assertEquals('function', type(ns.IsThreatQuest))
            end,
            IsUnitOnQuest = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsUnitOnQuest))
                return
              end
              assertEquals('function', type(ns.IsUnitOnQuest))
            end,
            IsWorldQuest = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsWorldQuest))
                return
              end
              assertEquals('function', type(ns.IsWorldQuest))
            end,
            QuestCanHaveWarModeBonus = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.QuestCanHaveWarModeBonus))
                return
              end
              assertEquals('function', type(ns.QuestCanHaveWarModeBonus))
            end,
            QuestHasQuestSessionBonus = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.QuestHasQuestSessionBonus))
                return
              end
              assertEquals('function', type(ns.QuestHasQuestSessionBonus))
            end,
            QuestHasWarModeBonus = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.QuestHasWarModeBonus))
                return
              end
              assertEquals('function', type(ns.QuestHasWarModeBonus))
            end,
            ReadyForTurnIn = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ReadyForTurnIn))
                return
              end
              assertEquals('function', type(ns.ReadyForTurnIn))
            end,
            RemoveQuestWatch = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.RemoveQuestWatch))
                return
              end
              assertEquals('function', type(ns.RemoveQuestWatch))
            end,
            RemoveWorldQuestWatch = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.RemoveWorldQuestWatch))
                return
              end
              assertEquals('function', type(ns.RemoveWorldQuestWatch))
            end,
            RequestLoadQuestByID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.RequestLoadQuestByID))
                return
              end
              assertEquals('function', type(ns.RequestLoadQuestByID))
            end,
            SetAbandonQuest = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetAbandonQuest))
                return
              end
              assertEquals('function', type(ns.SetAbandonQuest))
            end,
            SetMapForQuestPOIs = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetMapForQuestPOIs))
                return
              end
              assertEquals('function', type(ns.SetMapForQuestPOIs))
            end,
            SetSelectedQuest = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetSelectedQuest))
                return
              end
              assertEquals('function', type(ns.SetSelectedQuest))
            end,
            ShouldDisplayTimeRemaining = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ShouldDisplayTimeRemaining))
                return
              end
              assertEquals('function', type(ns.ShouldDisplayTimeRemaining))
            end,
            ShouldShowQuestRewards = function()
              assertEquals('function', type(ns.ShouldShowQuestRewards))
            end,
            SortQuestWatches = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SortQuestWatches))
                return
              end
              assertEquals('function', type(ns.SortQuestWatches))
            end,
          }
        end,
        C_QuestSession = function()
          local ns = _G.C_QuestSession
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            CanStart = function()
              assertEquals('function', type(ns.CanStart))
            end,
            CanStop = function()
              assertEquals('function', type(ns.CanStop))
            end,
            Exists = function()
              assertEquals('function', type(ns.Exists))
            end,
            GetAvailableSessionCommand = function()
              assertEquals('function', type(ns.GetAvailableSessionCommand))
            end,
            GetPendingCommand = function()
              assertEquals('function', type(ns.GetPendingCommand))
            end,
            GetProposedMaxLevelForSession = function()
              assertEquals('function', type(ns.GetProposedMaxLevelForSession))
            end,
            GetSessionBeginDetails = function()
              assertEquals('function', type(ns.GetSessionBeginDetails))
            end,
            GetSuperTrackedQuest = function()
              assertEquals('function', type(ns.GetSuperTrackedQuest))
            end,
            HasJoined = function()
              assertEquals('function', type(ns.HasJoined))
            end,
            HasPendingCommand = function()
              assertEquals('function', type(ns.HasPendingCommand))
            end,
            RequestSessionStart = function()
              assertEquals('function', type(ns.RequestSessionStart))
            end,
            RequestSessionStop = function()
              assertEquals('function', type(ns.RequestSessionStop))
            end,
            SendSessionBeginResponse = function()
              assertEquals('function', type(ns.SendSessionBeginResponse))
            end,
            SetQuestIsSuperTracked = function()
              assertEquals('function', type(ns.SetQuestIsSuperTracked))
            end,
          }
        end,
        C_RaidLocks = function()
          local ns = _G.C_RaidLocks
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            IsEncounterComplete = function()
              assertEquals('function', type(ns.IsEncounterComplete))
            end,
          }
        end,
        C_RecruitAFriend = function()
          local ns = _G.C_RecruitAFriend
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            ClaimActivityReward = function()
              assertEquals('function', type(ns.ClaimActivityReward))
            end,
            ClaimNextReward = function()
              assertEquals('function', type(ns.ClaimNextReward))
            end,
            GenerateRecruitmentLink = function()
              assertEquals('function', type(ns.GenerateRecruitmentLink))
            end,
            GetRAFInfo = function()
              assertEquals('function', type(ns.GetRAFInfo))
            end,
            GetRAFSystemInfo = function()
              assertEquals('function', type(ns.GetRAFSystemInfo))
            end,
            GetRecruitActivityRequirementsText = function()
              assertEquals('function', type(ns.GetRecruitActivityRequirementsText))
            end,
            GetRecruitInfo = function()
              assertEquals('function', type(ns.GetRecruitInfo))
            end,
            IsEnabled = function()
              assertEquals('function', type(ns.IsEnabled))
            end,
            IsRecruitingEnabled = function()
              assertEquals('function', type(ns.IsRecruitingEnabled))
            end,
            RemoveRAFRecruit = function()
              assertEquals('function', type(ns.RemoveRAFRecruit))
            end,
            RequestUpdatedRecruitmentInfo = function()
              assertEquals('function', type(ns.RequestUpdatedRecruitmentInfo))
            end,
          }
        end,
        C_ReportSystem = function()
          local ns = _G.C_ReportSystem
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            CanReportPlayer = function()
              assertEquals('function', type(ns.CanReportPlayer))
            end,
            CanReportPlayerForLanguage = function()
              assertEquals('function', type(ns.CanReportPlayerForLanguage))
            end,
            GetMajorCategoriesForReportType = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetMajorCategoriesForReportType))
                return
              end
              assertEquals('function', type(ns.GetMajorCategoriesForReportType))
            end,
            GetMajorCategoryString = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetMajorCategoryString))
                return
              end
              assertEquals('function', type(ns.GetMajorCategoryString))
            end,
            GetMinorCategoriesForReportTypeAndMajorCategory = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetMinorCategoriesForReportTypeAndMajorCategory))
                return
              end
              assertEquals('function', type(ns.GetMinorCategoriesForReportTypeAndMajorCategory))
            end,
            GetMinorCategoryString = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetMinorCategoryString))
                return
              end
              assertEquals('function', type(ns.GetMinorCategoryString))
            end,
            InitiateReportPlayer = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.InitiateReportPlayer))
                return
              end
              assertEquals('function', type(ns.InitiateReportPlayer))
            end,
            OpenReportPlayerDialog = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.OpenReportPlayerDialog))
                return
              end
              assertEquals('function', type(ns.OpenReportPlayerDialog))
            end,
            ReportServerLag = function()
              assertEquals('function', type(ns.ReportServerLag))
            end,
            ReportStuckInCombat = function()
              assertEquals('function', type(ns.ReportStuckInCombat))
            end,
            SendReport = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SendReport))
                return
              end
              assertEquals('function', type(ns.SendReport))
            end,
            SendReportPlayer = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SendReportPlayer))
                return
              end
              assertEquals('function', type(ns.SendReportPlayer))
            end,
            SetPendingReportPetTarget = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetPendingReportPetTarget))
                return
              end
              assertEquals('function', type(ns.SetPendingReportPetTarget))
            end,
            SetPendingReportTarget = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetPendingReportTarget))
                return
              end
              assertEquals('function', type(ns.SetPendingReportTarget))
            end,
            SetPendingReportTargetByGuid = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetPendingReportTargetByGuid))
                return
              end
              assertEquals('function', type(ns.SetPendingReportTargetByGuid))
            end,
          }
        end,
        C_Reputation = function()
          local ns = _G.C_Reputation
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetFactionParagonInfo = function()
              assertEquals('function', type(ns.GetFactionParagonInfo))
            end,
            IsFactionParagon = function()
              assertEquals('function', type(ns.IsFactionParagon))
            end,
            RequestFactionParagonPreloadRewardData = function()
              assertEquals('function', type(ns.RequestFactionParagonPreloadRewardData))
            end,
          }
        end,
        C_ResearchInfo = function()
          local ns = _G.C_ResearchInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetDigSitesForMap = function()
              assertEquals('function', type(ns.GetDigSitesForMap))
            end,
          }
        end,
        C_Scenario = function()
          local ns = _G.C_Scenario
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetInfo = function()
              assertEquals('function', type(ns.GetInfo))
            end,
            IsInScenario = function()
              assertEquals('function', type(ns.IsInScenario))
            end,
            ShouldShowCriteria = function()
              assertEquals('function', type(ns.ShouldShowCriteria))
            end,
          }
        end,
        C_ScenarioInfo = function()
          local ns = _G.C_ScenarioInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetJailersTowerTypeString = function()
              assertEquals('function', type(ns.GetJailersTowerTypeString))
            end,
            GetScenarioInfo = function()
              assertEquals('function', type(ns.GetScenarioInfo))
            end,
            GetScenarioStepInfo = function()
              assertEquals('function', type(ns.GetScenarioStepInfo))
            end,
          }
        end,
        C_ScrappingMachineUI = function()
          local ns = _G.C_ScrappingMachineUI
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            CloseScrappingMachine = function()
              assertEquals('function', type(ns.CloseScrappingMachine))
            end,
            DropPendingScrapItemFromCursor = function()
              assertEquals('function', type(ns.DropPendingScrapItemFromCursor))
            end,
            GetCurrentPendingScrapItemLocationByIndex = function()
              assertEquals('function', type(ns.GetCurrentPendingScrapItemLocationByIndex))
            end,
            GetScrapSpellID = function()
              assertEquals('function', type(ns.GetScrapSpellID))
            end,
            GetScrappingMachineName = function()
              assertEquals('function', type(ns.GetScrappingMachineName))
            end,
            HasScrappableItems = function()
              assertEquals('function', type(ns.HasScrappableItems))
            end,
            RemoveAllScrapItems = function()
              assertEquals('function', type(ns.RemoveAllScrapItems))
            end,
            RemoveCurrentScrappingItem = function()
              assertEquals('function', type(ns.RemoveCurrentScrappingItem))
            end,
            RemoveItemToScrap = function()
              assertEquals('function', type(ns.RemoveItemToScrap))
            end,
            ScrapItems = function()
              assertEquals('function', type(ns.ScrapItems))
            end,
            SetScrappingMachine = function()
              assertEquals('function', type(ns.SetScrappingMachine))
            end,
            ValidateScrappingList = function()
              assertEquals('function', type(ns.ValidateScrappingList))
            end,
          }
        end,
        C_ScriptedAnimations = function()
          local ns = _G.C_ScriptedAnimations
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetAllScriptedAnimationEffects = function()
              assertEquals('function', type(ns.GetAllScriptedAnimationEffects))
            end,
          }
        end,
        C_Seasons = function()
          local ns = _G.C_Seasons
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetActiveSeason = function()
              assertEquals('function', type(ns.GetActiveSeason))
            end,
            HasActiveSeason = function()
              assertEquals('function', type(ns.HasActiveSeason))
            end,
          }
        end,
        C_Social = function()
          local ns = _G.C_Social
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetLastAchievement = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetLastAchievement))
                return
              end
              assertEquals('function', type(ns.GetLastAchievement))
            end,
            GetLastItem = function()
              assertEquals('function', type(ns.GetLastItem))
            end,
            GetLastScreenshotIndex = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetLastScreenshotIndex))
                return
              end
              assertEquals('function', type(ns.GetLastScreenshotIndex))
            end,
            GetMaxTweetLength = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetMaxTweetLength))
                return
              end
              assertEquals('function', type(ns.GetMaxTweetLength))
            end,
            GetScreenshotInfoByIndex = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetScreenshotInfoByIndex))
                return
              end
              assertEquals('function', type(ns.GetScreenshotInfoByIndex))
            end,
            GetTweetLength = function()
              assertEquals('function', type(ns.GetTweetLength))
            end,
            IsSocialEnabled = function()
              assertEquals('function', type(ns.IsSocialEnabled))
            end,
            RegisterSocialBrowser = function()
              assertEquals('function', type(ns.RegisterSocialBrowser))
            end,
            TwitterCheckStatus = function()
              assertEquals('function', type(ns.TwitterCheckStatus))
            end,
            TwitterConnect = function()
              assertEquals('function', type(ns.TwitterConnect))
            end,
            TwitterDisconnect = function()
              assertEquals('function', type(ns.TwitterDisconnect))
            end,
            TwitterGetMSTillCanPost = function()
              assertEquals('function', type(ns.TwitterGetMSTillCanPost))
            end,
            TwitterPostMessage = function()
              assertEquals('function', type(ns.TwitterPostMessage))
            end,
          }
        end,
        C_SocialQueue = function()
          local ns = _G.C_SocialQueue
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetAllGroups = function()
              assertEquals('function', type(ns.GetAllGroups))
            end,
            GetConfig = function()
              assertEquals('function', type(ns.GetConfig))
            end,
            GetGroupForPlayer = function()
              assertEquals('function', type(ns.GetGroupForPlayer))
            end,
            GetGroupInfo = function()
              assertEquals('function', type(ns.GetGroupInfo))
            end,
            GetGroupMembers = function()
              assertEquals('function', type(ns.GetGroupMembers))
            end,
            GetGroupQueues = function()
              assertEquals('function', type(ns.GetGroupQueues))
            end,
            RequestToJoin = function()
              assertEquals('function', type(ns.RequestToJoin))
            end,
            SignalToastDisplayed = function()
              assertEquals('function', type(ns.SignalToastDisplayed))
            end,
          }
        end,
        C_SocialRestrictions = function()
          local ns = _G.C_SocialRestrictions
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            AcknowledgeRegionalChatDisabled = function()
              assertEquals('function', type(ns.AcknowledgeRegionalChatDisabled))
            end,
            IsChatDisabled = function()
              assertEquals('function', type(ns.IsChatDisabled))
            end,
            IsMuted = function()
              assertEquals('function', type(ns.IsMuted))
            end,
            IsSilenced = function()
              assertEquals('function', type(ns.IsSilenced))
            end,
            IsSquelched = function()
              assertEquals('function', type(ns.IsSquelched))
            end,
            SetChatDisabled = function()
              assertEquals('function', type(ns.SetChatDisabled))
            end,
          }
        end,
        C_Soulbinds = function()
          local ns = _G.C_Soulbinds
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            ActivateSoulbind = function()
              assertEquals('function', type(ns.ActivateSoulbind))
            end,
            CanActivateSoulbind = function()
              assertEquals('function', type(ns.CanActivateSoulbind))
            end,
            CanModifySoulbind = function()
              assertEquals('function', type(ns.CanModifySoulbind))
            end,
            CanResetConduitsInSoulbind = function()
              assertEquals('function', type(ns.CanResetConduitsInSoulbind))
            end,
            CanSwitchActiveSoulbindTreeBranch = function()
              assertEquals('function', type(ns.CanSwitchActiveSoulbindTreeBranch))
            end,
            CloseUI = function()
              assertEquals('function', type(ns.CloseUI))
            end,
            CommitPendingConduitsInSoulbind = function()
              assertEquals('function', type(ns.CommitPendingConduitsInSoulbind))
            end,
            FindNodeIDActuallyInstalled = function()
              assertEquals('function', type(ns.FindNodeIDActuallyInstalled))
            end,
            FindNodeIDAppearingInstalled = function()
              assertEquals('function', type(ns.FindNodeIDAppearingInstalled))
            end,
            FindNodeIDPendingInstall = function()
              assertEquals('function', type(ns.FindNodeIDPendingInstall))
            end,
            FindNodeIDPendingUninstall = function()
              assertEquals('function', type(ns.FindNodeIDPendingUninstall))
            end,
            GetActiveSoulbindID = function()
              assertEquals('function', type(ns.GetActiveSoulbindID))
            end,
            GetConduitCollection = function()
              assertEquals('function', type(ns.GetConduitCollection))
            end,
            GetConduitCollectionCount = function()
              assertEquals('function', type(ns.GetConduitCollectionCount))
            end,
            GetConduitCollectionData = function()
              assertEquals('function', type(ns.GetConduitCollectionData))
            end,
            GetConduitCollectionDataAtCursor = function()
              assertEquals('function', type(ns.GetConduitCollectionDataAtCursor))
            end,
            GetConduitCollectionDataByVirtualID = function()
              assertEquals('function', type(ns.GetConduitCollectionDataByVirtualID))
            end,
            GetConduitDisplayed = function()
              assertEquals('function', type(ns.GetConduitDisplayed))
            end,
            GetConduitHyperlink = function()
              assertEquals('function', type(ns.GetConduitHyperlink))
            end,
            GetConduitIDPendingInstall = function()
              assertEquals('function', type(ns.GetConduitIDPendingInstall))
            end,
            GetConduitQuality = function()
              assertEquals('function', type(ns.GetConduitQuality))
            end,
            GetConduitRank = function()
              assertEquals('function', type(ns.GetConduitRank))
            end,
            GetConduitSpellID = function()
              assertEquals('function', type(ns.GetConduitSpellID))
            end,
            GetInstalledConduitID = function()
              assertEquals('function', type(ns.GetInstalledConduitID))
            end,
            GetNode = function()
              assertEquals('function', type(ns.GetNode))
            end,
            GetSoulbindData = function()
              assertEquals('function', type(ns.GetSoulbindData))
            end,
            GetSpecsAssignedToSoulbind = function()
              assertEquals('function', type(ns.GetSpecsAssignedToSoulbind))
            end,
            GetTree = function()
              assertEquals('function', type(ns.GetTree))
            end,
            HasAnyInstalledConduitInSoulbind = function()
              assertEquals('function', type(ns.HasAnyInstalledConduitInSoulbind))
            end,
            HasAnyPendingConduits = function()
              assertEquals('function', type(ns.HasAnyPendingConduits))
            end,
            HasPendingConduitsInSoulbind = function()
              assertEquals('function', type(ns.HasPendingConduitsInSoulbind))
            end,
            IsConduitInstalled = function()
              assertEquals('function', type(ns.IsConduitInstalled))
            end,
            IsConduitInstalledInSoulbind = function()
              assertEquals('function', type(ns.IsConduitInstalledInSoulbind))
            end,
            IsItemConduitByItemInfo = function()
              assertEquals('function', type(ns.IsItemConduitByItemInfo))
            end,
            IsNodePendingModify = function()
              assertEquals('function', type(ns.IsNodePendingModify))
            end,
            IsUnselectedConduitPendingInSoulbind = function()
              assertEquals('function', type(ns.IsUnselectedConduitPendingInSoulbind))
            end,
            ModifyNode = function()
              assertEquals('function', type(ns.ModifyNode))
            end,
            SelectNode = function()
              assertEquals('function', type(ns.SelectNode))
            end,
            UnmodifyNode = function()
              assertEquals('function', type(ns.UnmodifyNode))
            end,
          }
        end,
        C_SpecializationInfo = function()
          local ns = _G.C_SpecializationInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            CanPlayerUsePVPTalentUI = function()
              assertEquals('function', type(ns.CanPlayerUsePVPTalentUI))
            end,
            CanPlayerUseTalentSpecUI = function()
              assertEquals('function', type(ns.CanPlayerUseTalentSpecUI))
            end,
            CanPlayerUseTalentUI = function()
              assertEquals('function', type(ns.CanPlayerUseTalentUI))
            end,
            GetAllSelectedPvpTalentIDs = function()
              assertEquals('function', type(ns.GetAllSelectedPvpTalentIDs))
            end,
            GetInspectSelectedPvpTalent = function()
              assertEquals('function', type(ns.GetInspectSelectedPvpTalent))
            end,
            GetPvpTalentAlertStatus = function()
              assertEquals('function', type(ns.GetPvpTalentAlertStatus))
            end,
            GetPvpTalentSlotInfo = function()
              assertEquals('function', type(ns.GetPvpTalentSlotInfo))
            end,
            GetPvpTalentSlotUnlockLevel = function()
              assertEquals('function', type(ns.GetPvpTalentSlotUnlockLevel))
            end,
            GetPvpTalentUnlockLevel = function()
              assertEquals('function', type(ns.GetPvpTalentUnlockLevel))
            end,
            GetSpecIDs = function()
              assertEquals('function', type(ns.GetSpecIDs))
            end,
            GetSpellsDisplay = function()
              assertEquals('function', type(ns.GetSpellsDisplay))
            end,
            IsInitialized = function()
              assertEquals('function', type(ns.IsInitialized))
            end,
            IsPvpTalentLocked = function()
              assertEquals('function', type(ns.IsPvpTalentLocked))
            end,
            MatchesCurrentSpecSet = function()
              assertEquals('function', type(ns.MatchesCurrentSpecSet))
            end,
            SetPvpTalentLocked = function()
              assertEquals('function', type(ns.SetPvpTalentLocked))
            end,
          }
        end,
        C_Spell = function()
          local ns = _G.C_Spell
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            DoesSpellExist = function()
              assertEquals('function', type(ns.DoesSpellExist))
            end,
            GetMawPowerBorderAtlasBySpellID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetMawPowerBorderAtlasBySpellID))
                return
              end
              assertEquals('function', type(ns.GetMawPowerBorderAtlasBySpellID))
            end,
            IsSpellDataCached = function()
              assertEquals('function', type(ns.IsSpellDataCached))
            end,
            RequestLoadSpellData = function()
              assertEquals('function', type(ns.RequestLoadSpellData))
            end,
          }
        end,
        C_SpellBook = function()
          local ns = _G.C_SpellBook
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            ContainsAnyDisenchantSpell = function()
              assertEquals('function', type(ns.ContainsAnyDisenchantSpell))
            end,
            GetCurrentLevelSpells = function()
              assertEquals('function', type(ns.GetCurrentLevelSpells))
            end,
            GetSkillLineIndexByID = function()
              assertEquals('function', type(ns.GetSkillLineIndexByID))
            end,
            GetSpellInfo = function()
              assertEquals('function', type(ns.GetSpellInfo))
            end,
            GetSpellLinkFromSpellID = function()
              assertEquals('function', type(ns.GetSpellLinkFromSpellID))
            end,
            IsSpellDisabled = function()
              assertEquals('function', type(ns.IsSpellDisabled))
            end,
          }
        end,
        C_SplashScreen = function()
          local ns = _G.C_SplashScreen
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            AcknowledgeSplash = function()
              assertEquals('function', type(ns.AcknowledgeSplash))
            end,
            CanViewSplashScreen = function()
              assertEquals('function', type(ns.CanViewSplashScreen))
            end,
            RequestLatestSplashScreen = function()
              assertEquals('function', type(ns.RequestLatestSplashScreen))
            end,
          }
        end,
        C_StableInfo = function()
          local ns = _G.C_StableInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetNumActivePets = function()
              assertEquals('function', type(ns.GetNumActivePets))
            end,
            GetNumStablePets = function()
              assertEquals('function', type(ns.GetNumStablePets))
            end,
          }
        end,
        C_StorePublic = function()
          local ns = _G.C_StorePublic
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            DoesGroupHavePurchaseableProducts = function()
              assertEquals('function', type(ns.DoesGroupHavePurchaseableProducts))
            end,
            HasPurchaseableProducts = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.HasPurchaseableProducts))
                return
              end
              assertEquals('function', type(ns.HasPurchaseableProducts))
            end,
            IsDisabledByParentalControls = function()
              assertEquals('function', type(ns.IsDisabledByParentalControls))
            end,
            IsEnabled = function()
              assertEquals('function', type(ns.IsEnabled))
            end,
          }
        end,
        C_SummonInfo = function()
          local ns = _G.C_SummonInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            CancelSummon = function()
              assertEquals('function', type(ns.CancelSummon))
            end,
            ConfirmSummon = function()
              assertEquals('function', type(ns.ConfirmSummon))
            end,
            GetSummonConfirmAreaName = function()
              assertEquals('function', type(ns.GetSummonConfirmAreaName))
            end,
            GetSummonConfirmSummoner = function()
              assertEquals('function', type(ns.GetSummonConfirmSummoner))
            end,
            GetSummonConfirmTimeLeft = function()
              assertEquals('function', type(ns.GetSummonConfirmTimeLeft))
            end,
            GetSummonReason = function()
              assertEquals('function', type(ns.GetSummonReason))
            end,
            IsSummonSkippingStartExperience = function()
              assertEquals('function', type(ns.IsSummonSkippingStartExperience))
            end,
          }
        end,
        C_SuperTrack = function()
          local ns = _G.C_SuperTrack
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetHighestPrioritySuperTrackingType = function()
              assertEquals('function', type(ns.GetHighestPrioritySuperTrackingType))
            end,
            GetSuperTrackedQuestID = function()
              assertEquals('function', type(ns.GetSuperTrackedQuestID))
            end,
            IsSuperTrackingAnything = function()
              assertEquals('function', type(ns.IsSuperTrackingAnything))
            end,
            IsSuperTrackingCorpse = function()
              assertEquals('function', type(ns.IsSuperTrackingCorpse))
            end,
            IsSuperTrackingQuest = function()
              assertEquals('function', type(ns.IsSuperTrackingQuest))
            end,
            IsSuperTrackingUserWaypoint = function()
              assertEquals('function', type(ns.IsSuperTrackingUserWaypoint))
            end,
            SetSuperTrackedQuestID = function()
              assertEquals('function', type(ns.SetSuperTrackedQuestID))
            end,
            SetSuperTrackedUserWaypoint = function()
              assertEquals('function', type(ns.SetSuperTrackedUserWaypoint))
            end,
          }
        end,
        C_System = function()
          local ns = _G.C_System
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetFrameStack = function()
              assertEquals('function', type(ns.GetFrameStack))
            end,
          }
        end,
        C_TTSSettings = function()
          local ns = _G.C_TTSSettings
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetChannelEnabled = function()
              assertEquals('function', type(ns.GetChannelEnabled))
            end,
            GetCharacterSettingsSaved = function()
              assertEquals('function', type(ns.GetCharacterSettingsSaved))
            end,
            GetChatTypeEnabled = function()
              assertEquals('function', type(ns.GetChatTypeEnabled))
            end,
            GetSetting = function()
              assertEquals('function', type(ns.GetSetting))
            end,
            GetSpeechRate = function()
              assertEquals('function', type(ns.GetSpeechRate))
            end,
            GetSpeechVolume = function()
              assertEquals('function', type(ns.GetSpeechVolume))
            end,
            GetVoiceOptionID = function()
              assertEquals('function', type(ns.GetVoiceOptionID))
            end,
            GetVoiceOptionName = function()
              assertEquals('function', type(ns.GetVoiceOptionName))
            end,
            MarkCharacterSettingsSaved = function()
              assertEquals('function', type(ns.MarkCharacterSettingsSaved))
            end,
            SetChannelEnabled = function()
              assertEquals('function', type(ns.SetChannelEnabled))
            end,
            SetChannelKeyEnabled = function()
              assertEquals('function', type(ns.SetChannelKeyEnabled))
            end,
            SetChatTypeEnabled = function()
              assertEquals('function', type(ns.SetChatTypeEnabled))
            end,
            SetDefaultSettings = function()
              assertEquals('function', type(ns.SetDefaultSettings))
            end,
            SetSetting = function()
              assertEquals('function', type(ns.SetSetting))
            end,
            SetSpeechRate = function()
              assertEquals('function', type(ns.SetSpeechRate))
            end,
            SetSpeechVolume = function()
              assertEquals('function', type(ns.SetSpeechVolume))
            end,
            SetVoiceOption = function()
              assertEquals('function', type(ns.SetVoiceOption))
            end,
            SetVoiceOptionName = function()
              assertEquals('function', type(ns.SetVoiceOptionName))
            end,
            ShouldOverrideMessage = function()
              assertEquals('function', type(ns.ShouldOverrideMessage))
            end,
          }
        end,
        C_TaskQuest = function()
          local ns = _G.C_TaskQuest
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            DoesMapShowTaskQuestObjectives = function()
              assertEquals('function', type(ns.DoesMapShowTaskQuestObjectives))
            end,
            GetQuestInfoByQuestID = function()
              assertEquals('function', type(ns.GetQuestInfoByQuestID))
            end,
            GetQuestLocation = function()
              assertEquals('function', type(ns.GetQuestLocation))
            end,
            GetQuestProgressBarInfo = function()
              assertEquals('function', type(ns.GetQuestProgressBarInfo))
            end,
            GetQuestTimeLeftMinutes = function()
              assertEquals('function', type(ns.GetQuestTimeLeftMinutes))
            end,
            GetQuestTimeLeftSeconds = function()
              assertEquals('function', type(ns.GetQuestTimeLeftSeconds))
            end,
            GetQuestZoneID = function()
              assertEquals('function', type(ns.GetQuestZoneID))
            end,
            GetQuestsForPlayerByMapID = function()
              assertEquals('function', type(ns.GetQuestsForPlayerByMapID))
            end,
            GetThreatQuests = function()
              assertEquals('function', type(ns.GetThreatQuests))
            end,
            GetUIWidgetSetIDFromQuestID = function()
              assertEquals('function', type(ns.GetUIWidgetSetIDFromQuestID))
            end,
            IsActive = function()
              assertEquals('function', type(ns.IsActive))
            end,
            RequestPreloadRewardData = function()
              assertEquals('function', type(ns.RequestPreloadRewardData))
            end,
          }
        end,
        C_TaxiMap = function()
          local ns = _G.C_TaxiMap
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetAllTaxiNodes = function()
              assertEquals('function', type(ns.GetAllTaxiNodes))
            end,
            GetTaxiNodesForMap = function()
              assertEquals('function', type(ns.GetTaxiNodesForMap))
            end,
            ShouldMapShowTaxiNodes = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ShouldMapShowTaxiNodes))
                return
              end
              assertEquals('function', type(ns.ShouldMapShowTaxiNodes))
            end,
          }
        end,
        C_Texture = function()
          local ns = _G.C_Texture
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetAtlasInfo = function()
              assertEquals('function', type(ns.GetAtlasInfo))
            end,
          }
        end,
        C_Timer = function()
          local ns = _G.C_Timer
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            After = function()
              assertEquals('function', type(ns.After))
            end,
          }
        end,
        C_ToyBox = function()
          local ns = _G.C_ToyBox
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            ForceToyRefilter = function()
              assertEquals('function', type(ns.ForceToyRefilter))
            end,
            GetIsFavorite = function()
              assertEquals('function', type(ns.GetIsFavorite))
            end,
            GetNumFilteredToys = function()
              assertEquals('function', type(ns.GetNumFilteredToys))
            end,
            GetNumLearnedDisplayedToys = function()
              assertEquals('function', type(ns.GetNumLearnedDisplayedToys))
            end,
            GetNumTotalDisplayedToys = function()
              assertEquals('function', type(ns.GetNumTotalDisplayedToys))
            end,
            GetToyFromIndex = function()
              assertEquals('function', type(ns.GetToyFromIndex))
            end,
            GetToyInfo = function()
              assertEquals('function', type(ns.GetToyInfo))
            end,
            HasFavorites = function()
              assertEquals('function', type(ns.HasFavorites))
            end,
          }
        end,
        C_ToyBoxInfo = function()
          local ns = _G.C_ToyBoxInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            ClearFanfare = function()
              assertEquals('function', type(ns.ClearFanfare))
            end,
            IsToySourceValid = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsToySourceValid))
                return
              end
              assertEquals('function', type(ns.IsToySourceValid))
            end,
            IsUsingDefaultFilters = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsUsingDefaultFilters))
                return
              end
              assertEquals('function', type(ns.IsUsingDefaultFilters))
            end,
            NeedsFanfare = function()
              assertEquals('function', type(ns.NeedsFanfare))
            end,
            SetDefaultFilters = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetDefaultFilters))
                return
              end
              assertEquals('function', type(ns.SetDefaultFilters))
            end,
          }
        end,
        C_TradeSkillUI = function()
          local ns = _G.C_TradeSkillUI
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            CloseObliterumForge = function()
              assertEquals('function', type(ns.CloseObliterumForge))
            end,
            CloseTradeSkill = function()
              assertEquals('function', type(ns.CloseTradeSkill))
            end,
            CraftRecipe = function()
              assertEquals('function', type(ns.CraftRecipe))
            end,
            GetAllProfessionTradeSkillLines = function()
              assertEquals('function', type(ns.GetAllProfessionTradeSkillLines))
            end,
            GetCategories = function()
              assertEquals('function', type(ns.GetCategories))
            end,
            GetOptionalReagentBonusText = function()
              assertEquals('function', type(ns.GetOptionalReagentBonusText))
            end,
            GetOptionalReagentInfo = function()
              assertEquals('function', type(ns.GetOptionalReagentInfo))
            end,
            GetPendingObliterateItemID = function()
              assertEquals('function', type(ns.GetPendingObliterateItemID))
            end,
            GetRecipeInfo = function()
              assertEquals('function', type(ns.GetRecipeInfo))
            end,
            GetRecipeNumReagents = function()
              assertEquals('function', type(ns.GetRecipeNumReagents))
            end,
            GetRecipeReagentInfo = function()
              assertEquals('function', type(ns.GetRecipeReagentInfo))
            end,
            GetRecipeRepeatCount = function()
              assertEquals('function', type(ns.GetRecipeRepeatCount))
            end,
            GetTradeSkillDisplayName = function()
              assertEquals('function', type(ns.GetTradeSkillDisplayName))
            end,
            GetTradeSkillLine = function()
              assertEquals('function', type(ns.GetTradeSkillLine))
            end,
            GetTradeSkillLineInfoByID = function()
              assertEquals('function', type(ns.GetTradeSkillLineInfoByID))
            end,
            IsEmptySkillLineCategory = function()
              assertEquals('function', type(ns.IsEmptySkillLineCategory))
            end,
            IsNPCCrafting = function()
              assertEquals('function', type(ns.IsNPCCrafting))
            end,
            IsTradeSkillGuild = function()
              assertEquals('function', type(ns.IsTradeSkillGuild))
            end,
            IsTradeSkillReady = function()
              assertEquals('function', type(ns.IsTradeSkillReady))
            end,
            SetOnlyShowLearnedRecipes = function()
              assertEquals('function', type(ns.SetOnlyShowLearnedRecipes))
            end,
            SetOnlyShowUnlearnedRecipes = function()
              assertEquals('function', type(ns.SetOnlyShowUnlearnedRecipes))
            end,
            SetRecipeRepeatCount = function()
              assertEquals('function', type(ns.SetRecipeRepeatCount))
            end,
          }
        end,
        C_Transmog = function()
          local ns = _G.C_Transmog
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            ApplyAllPending = function()
              assertEquals('function', type(ns.ApplyAllPending))
            end,
            CanHaveSecondaryAppearanceForSlotID = function()
              assertEquals('function', type(ns.CanHaveSecondaryAppearanceForSlotID))
            end,
            CanTransmogItem = function()
              assertEquals('function', type(ns.CanTransmogItem))
            end,
            CanTransmogItemWithItem = function()
              assertEquals('function', type(ns.CanTransmogItemWithItem))
            end,
            ClearAllPending = function()
              assertEquals('function', type(ns.ClearAllPending))
            end,
            ClearPending = function()
              assertEquals('function', type(ns.ClearPending))
            end,
            Close = function()
              assertEquals('function', type(ns.Close))
            end,
            ExtractTransmogIDList = function()
              assertEquals('function', type(ns.ExtractTransmogIDList))
            end,
            GetApplyCost = function()
              assertEquals('function', type(ns.GetApplyCost))
            end,
            GetApplyWarnings = function()
              assertEquals('function', type(ns.GetApplyWarnings))
            end,
            GetBaseCategory = function()
              assertEquals('function', type(ns.GetBaseCategory))
            end,
            GetCreatureDisplayIDForSource = function()
              assertEquals('function', type(ns.GetCreatureDisplayIDForSource))
            end,
            GetItemIDForSource = function()
              assertEquals('function', type(ns.GetItemIDForSource))
            end,
            GetPending = function()
              assertEquals('function', type(ns.GetPending))
            end,
            GetSlotEffectiveCategory = function()
              assertEquals('function', type(ns.GetSlotEffectiveCategory))
            end,
            GetSlotForInventoryType = function()
              assertEquals('function', type(ns.GetSlotForInventoryType))
            end,
            GetSlotInfo = function()
              assertEquals('function', type(ns.GetSlotInfo))
            end,
            GetSlotUseError = function()
              assertEquals('function', type(ns.GetSlotUseError))
            end,
            GetSlotVisualInfo = function()
              assertEquals('function', type(ns.GetSlotVisualInfo))
            end,
            IsAtTransmogNPC = function()
              assertEquals('function', type(ns.IsAtTransmogNPC))
            end,
            IsSlotBeingCollapsed = function()
              assertEquals('function', type(ns.IsSlotBeingCollapsed))
            end,
            LoadOutfit = function()
              assertEquals('function', type(ns.LoadOutfit))
            end,
            SetPending = function()
              assertEquals('function', type(ns.SetPending))
            end,
          }
        end,
        C_TransmogCollection = function()
          local ns = _G.C_TransmogCollection
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            AccountCanCollectSource = function()
              assertEquals('function', type(ns.AccountCanCollectSource))
            end,
            AreAllCollectionTypeFiltersChecked = function()
              assertEquals('function', type(ns.AreAllCollectionTypeFiltersChecked))
            end,
            AreAllSourceTypeFiltersChecked = function()
              assertEquals('function', type(ns.AreAllSourceTypeFiltersChecked))
            end,
            CanAppearanceHaveIllusion = function()
              assertEquals('function', type(ns.CanAppearanceHaveIllusion))
            end,
            ClearNewAppearance = function()
              assertEquals('function', type(ns.ClearNewAppearance))
            end,
            ClearSearch = function()
              assertEquals('function', type(ns.ClearSearch))
            end,
            DeleteOutfit = function()
              assertEquals('function', type(ns.DeleteOutfit))
            end,
            EndSearch = function()
              assertEquals('function', type(ns.EndSearch))
            end,
            GetAllAppearanceSources = function()
              assertEquals('function', type(ns.GetAllAppearanceSources))
            end,
            GetAppearanceCameraID = function()
              assertEquals('function', type(ns.GetAppearanceCameraID))
            end,
            GetAppearanceCameraIDBySource = function()
              assertEquals('function', type(ns.GetAppearanceCameraIDBySource))
            end,
            GetAppearanceInfoBySource = function()
              assertEquals('function', type(ns.GetAppearanceInfoBySource))
            end,
            GetAppearanceSourceDrops = function()
              assertEquals('function', type(ns.GetAppearanceSourceDrops))
            end,
            GetAppearanceSourceInfo = function()
              assertEquals('function', type(ns.GetAppearanceSourceInfo))
            end,
            GetAppearanceSources = function()
              assertEquals('function', type(ns.GetAppearanceSources))
            end,
            GetArtifactAppearanceStrings = function()
              assertEquals('function', type(ns.GetArtifactAppearanceStrings))
            end,
            GetCategoryAppearances = function()
              assertEquals('function', type(ns.GetCategoryAppearances))
            end,
            GetCategoryCollectedCount = function()
              assertEquals('function', type(ns.GetCategoryCollectedCount))
            end,
            GetCategoryForItem = function()
              assertEquals('function', type(ns.GetCategoryForItem))
            end,
            GetCategoryInfo = function()
              assertEquals('function', type(ns.GetCategoryInfo))
            end,
            GetCategoryTotal = function()
              assertEquals('function', type(ns.GetCategoryTotal))
            end,
            GetCollectedShown = function()
              assertEquals('function', type(ns.GetCollectedShown))
            end,
            GetFallbackWeaponAppearance = function()
              assertEquals('function', type(ns.GetFallbackWeaponAppearance))
            end,
            GetIllusionInfo = function()
              assertEquals('function', type(ns.GetIllusionInfo))
            end,
            GetIllusionStrings = function()
              assertEquals('function', type(ns.GetIllusionStrings))
            end,
            GetIllusions = function()
              assertEquals('function', type(ns.GetIllusions))
            end,
            GetInspectItemTransmogInfoList = function()
              assertEquals('function', type(ns.GetInspectItemTransmogInfoList))
            end,
            GetIsAppearanceFavorite = function()
              assertEquals('function', type(ns.GetIsAppearanceFavorite))
            end,
            GetItemInfo = function()
              assertEquals('function', type(ns.GetItemInfo))
            end,
            GetItemTransmogInfoListFromOutfitHyperlink = function()
              assertEquals('function', type(ns.GetItemTransmogInfoListFromOutfitHyperlink))
            end,
            GetLatestAppearance = function()
              assertEquals('function', type(ns.GetLatestAppearance))
            end,
            GetNumMaxOutfits = function()
              assertEquals('function', type(ns.GetNumMaxOutfits))
            end,
            GetNumTransmogSources = function()
              assertEquals('function', type(ns.GetNumTransmogSources))
            end,
            GetOutfitHyperlinkFromItemTransmogInfoList = function()
              assertEquals('function', type(ns.GetOutfitHyperlinkFromItemTransmogInfoList))
            end,
            GetOutfitInfo = function()
              assertEquals('function', type(ns.GetOutfitInfo))
            end,
            GetOutfitItemTransmogInfoList = function()
              assertEquals('function', type(ns.GetOutfitItemTransmogInfoList))
            end,
            GetOutfits = function()
              assertEquals('function', type(ns.GetOutfits))
            end,
            GetPairedArtifactAppearance = function()
              assertEquals('function', type(ns.GetPairedArtifactAppearance))
            end,
            GetSourceIcon = function()
              assertEquals('function', type(ns.GetSourceIcon))
            end,
            GetSourceInfo = function()
              assertEquals('function', type(ns.GetSourceInfo))
            end,
            GetSourceItemID = function()
              assertEquals('function', type(ns.GetSourceItemID))
            end,
            GetSourceRequiredHoliday = function()
              assertEquals('function', type(ns.GetSourceRequiredHoliday))
            end,
            GetUncollectedShown = function()
              assertEquals('function', type(ns.GetUncollectedShown))
            end,
            HasFavorites = function()
              assertEquals('function', type(ns.HasFavorites))
            end,
            IsAppearanceHiddenVisual = function()
              assertEquals('function', type(ns.IsAppearanceHiddenVisual))
            end,
            IsCategoryValidForItem = function()
              assertEquals('function', type(ns.IsCategoryValidForItem))
            end,
            IsNewAppearance = function()
              assertEquals('function', type(ns.IsNewAppearance))
            end,
            IsSearchDBLoading = function()
              assertEquals('function', type(ns.IsSearchDBLoading))
            end,
            IsSearchInProgress = function()
              assertEquals('function', type(ns.IsSearchInProgress))
            end,
            IsSourceTypeFilterChecked = function()
              assertEquals('function', type(ns.IsSourceTypeFilterChecked))
            end,
            IsUsingDefaultFilters = function()
              assertEquals('function', type(ns.IsUsingDefaultFilters))
            end,
            ModifyOutfit = function()
              assertEquals('function', type(ns.ModifyOutfit))
            end,
            NewOutfit = function()
              assertEquals('function', type(ns.NewOutfit))
            end,
            PlayerCanCollectSource = function()
              assertEquals('function', type(ns.PlayerCanCollectSource))
            end,
            PlayerHasTransmog = function()
              assertEquals('function', type(ns.PlayerHasTransmog))
            end,
            PlayerHasTransmogByItemInfo = function()
              assertEquals('function', type(ns.PlayerHasTransmogByItemInfo))
            end,
            PlayerHasTransmogItemModifiedAppearance = function()
              assertEquals('function', type(ns.PlayerHasTransmogItemModifiedAppearance))
            end,
            PlayerKnowsSource = function()
              assertEquals('function', type(ns.PlayerKnowsSource))
            end,
            RenameOutfit = function()
              assertEquals('function', type(ns.RenameOutfit))
            end,
            SearchProgress = function()
              assertEquals('function', type(ns.SearchProgress))
            end,
            SearchSize = function()
              assertEquals('function', type(ns.SearchSize))
            end,
            SetAllCollectionTypeFilters = function()
              assertEquals('function', type(ns.SetAllCollectionTypeFilters))
            end,
            SetAllSourceTypeFilters = function()
              assertEquals('function', type(ns.SetAllSourceTypeFilters))
            end,
            SetCollectedShown = function()
              assertEquals('function', type(ns.SetCollectedShown))
            end,
            SetDefaultFilters = function()
              assertEquals('function', type(ns.SetDefaultFilters))
            end,
            SetIsAppearanceFavorite = function()
              assertEquals('function', type(ns.SetIsAppearanceFavorite))
            end,
            SetSearch = function()
              assertEquals('function', type(ns.SetSearch))
            end,
            SetSearchAndFilterCategory = function()
              assertEquals('function', type(ns.SetSearchAndFilterCategory))
            end,
            SetSourceTypeFilter = function()
              assertEquals('function', type(ns.SetSourceTypeFilter))
            end,
            SetUncollectedShown = function()
              assertEquals('function', type(ns.SetUncollectedShown))
            end,
            UpdateUsableAppearances = function()
              assertEquals('function', type(ns.UpdateUsableAppearances))
            end,
          }
        end,
        C_TransmogSets = function()
          local ns = _G.C_TransmogSets
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            ClearLatestSource = function()
              assertEquals('function', type(ns.ClearLatestSource))
            end,
            ClearNewSource = function()
              assertEquals('function', type(ns.ClearNewSource))
            end,
            ClearSetNewSourcesForSlot = function()
              assertEquals('function', type(ns.ClearSetNewSourcesForSlot))
            end,
            GetAllSets = function()
              assertEquals('function', type(ns.GetAllSets))
            end,
            GetAllSourceIDs = function()
              assertEquals('function', type(ns.GetAllSourceIDs))
            end,
            GetBaseSetID = function()
              assertEquals('function', type(ns.GetBaseSetID))
            end,
            GetBaseSets = function()
              assertEquals('function', type(ns.GetBaseSets))
            end,
            GetBaseSetsCounts = function()
              assertEquals('function', type(ns.GetBaseSetsCounts))
            end,
            GetBaseSetsFilter = function()
              assertEquals('function', type(ns.GetBaseSetsFilter))
            end,
            GetCameraIDs = function()
              assertEquals('function', type(ns.GetCameraIDs))
            end,
            GetIsFavorite = function()
              assertEquals('function', type(ns.GetIsFavorite))
            end,
            GetLatestSource = function()
              assertEquals('function', type(ns.GetLatestSource))
            end,
            GetSetInfo = function()
              assertEquals('function', type(ns.GetSetInfo))
            end,
            GetSetNewSources = function()
              assertEquals('function', type(ns.GetSetNewSources))
            end,
            GetSetPrimaryAppearances = function()
              assertEquals('function', type(ns.GetSetPrimaryAppearances))
            end,
            GetSetsContainingSourceID = function()
              assertEquals('function', type(ns.GetSetsContainingSourceID))
            end,
            GetSourceIDsForSlot = function()
              assertEquals('function', type(ns.GetSourceIDsForSlot))
            end,
            GetSourcesForSlot = function()
              assertEquals('function', type(ns.GetSourcesForSlot))
            end,
            GetUsableSets = function()
              assertEquals('function', type(ns.GetUsableSets))
            end,
            GetVariantSets = function()
              assertEquals('function', type(ns.GetVariantSets))
            end,
            HasUsableSets = function()
              assertEquals('function', type(ns.HasUsableSets))
            end,
            IsBaseSetCollected = function()
              assertEquals('function', type(ns.IsBaseSetCollected))
            end,
            IsNewSource = function()
              assertEquals('function', type(ns.IsNewSource))
            end,
            IsSetVisible = function()
              assertEquals('function', type(ns.IsSetVisible))
            end,
            IsUsingDefaultBaseSetsFilters = function()
              assertEquals('function', type(ns.IsUsingDefaultBaseSetsFilters))
            end,
            SetBaseSetsFilter = function()
              assertEquals('function', type(ns.SetBaseSetsFilter))
            end,
            SetDefaultBaseSetsFilters = function()
              assertEquals('function', type(ns.SetDefaultBaseSetsFilters))
            end,
            SetHasNewSources = function()
              assertEquals('function', type(ns.SetHasNewSources))
            end,
            SetHasNewSourcesForSlot = function()
              assertEquals('function', type(ns.SetHasNewSourcesForSlot))
            end,
            SetIsFavorite = function()
              assertEquals('function', type(ns.SetIsFavorite))
            end,
          }
        end,
        C_Trophy = function()
          local ns = _G.C_Trophy
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            MonumentLoadList = function()
              assertEquals('function', type(ns.MonumentLoadList))
            end,
          }
        end,
        C_Tutorial = function()
          local ns = _G.C_Tutorial
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            AbandonTutorialArea = function()
              assertEquals('function', type(ns.AbandonTutorialArea))
            end,
            ReturnToTutorialArea = function()
              assertEquals('function', type(ns.ReturnToTutorialArea))
            end,
          }
        end,
        C_UI = function()
          local ns = _G.C_UI
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            DoesAnyDisplayHaveNotch = function()
              assertEquals('function', type(ns.DoesAnyDisplayHaveNotch))
            end,
            GetTopLeftNotchSafeRegion = function()
              assertEquals('function', type(ns.GetTopLeftNotchSafeRegion))
            end,
            GetTopRightNotchSafeRegion = function()
              assertEquals('function', type(ns.GetTopRightNotchSafeRegion))
            end,
            Reload = function()
              assertEquals('function', type(ns.Reload))
            end,
            ShouldUIParentAvoidNotch = function()
              assertEquals('function', type(ns.ShouldUIParentAvoidNotch))
            end,
          }
        end,
        C_UIWidgetManager = function()
          local ns = _G.C_UIWidgetManager
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetAllWidgetsBySetID = function()
              assertEquals('function', type(ns.GetAllWidgetsBySetID))
            end,
            GetBelowMinimapWidgetSetID = function()
              assertEquals('function', type(ns.GetBelowMinimapWidgetSetID))
            end,
            GetBulletTextListWidgetVisualizationInfo = function()
              assertEquals('function', type(ns.GetBulletTextListWidgetVisualizationInfo))
            end,
            GetCaptureBarWidgetVisualizationInfo = function()
              assertEquals('function', type(ns.GetCaptureBarWidgetVisualizationInfo))
            end,
            GetCaptureZoneVisualizationInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetCaptureZoneVisualizationInfo))
                return
              end
              assertEquals('function', type(ns.GetCaptureZoneVisualizationInfo))
            end,
            GetDiscreteProgressStepsVisualizationInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetDiscreteProgressStepsVisualizationInfo))
                return
              end
              assertEquals('function', type(ns.GetDiscreteProgressStepsVisualizationInfo))
            end,
            GetDoubleIconAndTextWidgetVisualizationInfo = function()
              assertEquals('function', type(ns.GetDoubleIconAndTextWidgetVisualizationInfo))
            end,
            GetDoubleStateIconRowVisualizationInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetDoubleStateIconRowVisualizationInfo))
                return
              end
              assertEquals('function', type(ns.GetDoubleStateIconRowVisualizationInfo))
            end,
            GetDoubleStatusBarWidgetVisualizationInfo = function()
              assertEquals('function', type(ns.GetDoubleStatusBarWidgetVisualizationInfo))
            end,
            GetHorizontalCurrenciesWidgetVisualizationInfo = function()
              assertEquals('function', type(ns.GetHorizontalCurrenciesWidgetVisualizationInfo))
            end,
            GetIconAndTextWidgetVisualizationInfo = function()
              assertEquals('function', type(ns.GetIconAndTextWidgetVisualizationInfo))
            end,
            GetIconTextAndBackgroundWidgetVisualizationInfo = function()
              assertEquals('function', type(ns.GetIconTextAndBackgroundWidgetVisualizationInfo))
            end,
            GetIconTextAndCurrenciesWidgetVisualizationInfo = function()
              assertEquals('function', type(ns.GetIconTextAndCurrenciesWidgetVisualizationInfo))
            end,
            GetObjectiveTrackerWidgetSetID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetObjectiveTrackerWidgetSetID))
                return
              end
              assertEquals('function', type(ns.GetObjectiveTrackerWidgetSetID))
            end,
            GetPowerBarWidgetSetID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetPowerBarWidgetSetID))
                return
              end
              assertEquals('function', type(ns.GetPowerBarWidgetSetID))
            end,
            GetScenarioHeaderCurrenciesAndBackgroundWidgetVisualizationInfo = function()
              assertEquals('function', type(ns.GetScenarioHeaderCurrenciesAndBackgroundWidgetVisualizationInfo))
            end,
            GetScenarioHeaderTimerWidgetVisualizationInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetScenarioHeaderTimerWidgetVisualizationInfo))
                return
              end
              assertEquals('function', type(ns.GetScenarioHeaderTimerWidgetVisualizationInfo))
            end,
            GetSpacerVisualizationInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetSpacerVisualizationInfo))
                return
              end
              assertEquals('function', type(ns.GetSpacerVisualizationInfo))
            end,
            GetSpellDisplayVisualizationInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetSpellDisplayVisualizationInfo))
                return
              end
              assertEquals('function', type(ns.GetSpellDisplayVisualizationInfo))
            end,
            GetStackedResourceTrackerWidgetVisualizationInfo = function()
              assertEquals('function', type(ns.GetStackedResourceTrackerWidgetVisualizationInfo))
            end,
            GetStatusBarWidgetVisualizationInfo = function()
              assertEquals('function', type(ns.GetStatusBarWidgetVisualizationInfo))
            end,
            GetTextColumnRowVisualizationInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetTextColumnRowVisualizationInfo))
                return
              end
              assertEquals('function', type(ns.GetTextColumnRowVisualizationInfo))
            end,
            GetTextWithStateWidgetVisualizationInfo = function()
              assertEquals('function', type(ns.GetTextWithStateWidgetVisualizationInfo))
            end,
            GetTextureAndTextRowVisualizationInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetTextureAndTextRowVisualizationInfo))
                return
              end
              assertEquals('function', type(ns.GetTextureAndTextRowVisualizationInfo))
            end,
            GetTextureAndTextVisualizationInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetTextureAndTextVisualizationInfo))
                return
              end
              assertEquals('function', type(ns.GetTextureAndTextVisualizationInfo))
            end,
            GetTextureWithAnimationVisualizationInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetTextureWithAnimationVisualizationInfo))
                return
              end
              assertEquals('function', type(ns.GetTextureWithAnimationVisualizationInfo))
            end,
            GetTextureWithStateVisualizationInfo = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetTextureWithStateVisualizationInfo))
                return
              end
              assertEquals('function', type(ns.GetTextureWithStateVisualizationInfo))
            end,
            GetTopCenterWidgetSetID = function()
              assertEquals('function', type(ns.GetTopCenterWidgetSetID))
            end,
            GetUnitPowerBarWidgetVisualizationInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetUnitPowerBarWidgetVisualizationInfo))
                return
              end
              assertEquals('function', type(ns.GetUnitPowerBarWidgetVisualizationInfo))
            end,
            GetWidgetSetInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetWidgetSetInfo))
                return
              end
              assertEquals('function', type(ns.GetWidgetSetInfo))
            end,
            GetZoneControlVisualizationInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetZoneControlVisualizationInfo))
                return
              end
              assertEquals('function', type(ns.GetZoneControlVisualizationInfo))
            end,
            RegisterUnitForWidgetUpdates = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.RegisterUnitForWidgetUpdates))
                return
              end
              assertEquals('function', type(ns.RegisterUnitForWidgetUpdates))
            end,
            SetProcessingUnit = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetProcessingUnit))
                return
              end
              assertEquals('function', type(ns.SetProcessingUnit))
            end,
            SetProcessingUnitGuid = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetProcessingUnitGuid))
                return
              end
              assertEquals('function', type(ns.SetProcessingUnitGuid))
            end,
            UnregisterUnitForWidgetUpdates = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.UnregisterUnitForWidgetUpdates))
                return
              end
              assertEquals('function', type(ns.UnregisterUnitForWidgetUpdates))
            end,
          }
        end,
        C_UserFeedback = function()
          local ns = _G.C_UserFeedback
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            SubmitBug = function()
              assertEquals('function', type(ns.SubmitBug))
            end,
            SubmitSuggestion = function()
              assertEquals('function', type(ns.SubmitSuggestion))
            end,
          }
        end,
        C_VideoOptions = function()
          local ns = _G.C_VideoOptions
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetGxAdapterInfo = function()
              assertEquals('function', type(ns.GetGxAdapterInfo))
            end,
          }
        end,
        C_VignetteInfo = function()
          local ns = _G.C_VignetteInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            FindBestUniqueVignette = function()
              assertEquals('function', type(ns.FindBestUniqueVignette))
            end,
            GetVignetteInfo = function()
              assertEquals('function', type(ns.GetVignetteInfo))
            end,
            GetVignettePosition = function()
              assertEquals('function', type(ns.GetVignettePosition))
            end,
            GetVignettes = function()
              assertEquals('function', type(ns.GetVignettes))
            end,
          }
        end,
        C_VoiceChat = function()
          local ns = _G.C_VoiceChat
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            ActivateChannel = function()
              assertEquals('function', type(ns.ActivateChannel))
            end,
            ActivateChannelTranscription = function()
              assertEquals('function', type(ns.ActivateChannelTranscription))
            end,
            BeginLocalCapture = function()
              assertEquals('function', type(ns.BeginLocalCapture))
            end,
            CanPlayerUseVoiceChat = function()
              assertEquals('function', type(ns.CanPlayerUseVoiceChat))
            end,
            CreateChannel = function()
              assertEquals('function', type(ns.CreateChannel))
            end,
            DeactivateChannel = function()
              assertEquals('function', type(ns.DeactivateChannel))
            end,
            DeactivateChannelTranscription = function()
              assertEquals('function', type(ns.DeactivateChannelTranscription))
            end,
            EndLocalCapture = function()
              assertEquals('function', type(ns.EndLocalCapture))
            end,
            GetActiveChannelID = function()
              assertEquals('function', type(ns.GetActiveChannelID))
            end,
            GetActiveChannelType = function()
              assertEquals('function', type(ns.GetActiveChannelType))
            end,
            GetAvailableInputDevices = function()
              assertEquals('function', type(ns.GetAvailableInputDevices))
            end,
            GetAvailableOutputDevices = function()
              assertEquals('function', type(ns.GetAvailableOutputDevices))
            end,
            GetChannel = function()
              assertEquals('function', type(ns.GetChannel))
            end,
            GetChannelForChannelType = function()
              assertEquals('function', type(ns.GetChannelForChannelType))
            end,
            GetChannelForCommunityStream = function()
              assertEquals('function', type(ns.GetChannelForCommunityStream))
            end,
            GetCommunicationMode = function()
              assertEquals('function', type(ns.GetCommunicationMode))
            end,
            GetCurrentVoiceChatConnectionStatusCode = function()
              assertEquals('function', type(ns.GetCurrentVoiceChatConnectionStatusCode))
            end,
            GetInputVolume = function()
              assertEquals('function', type(ns.GetInputVolume))
            end,
            GetJoinClubVoiceChannelError = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetJoinClubVoiceChannelError))
                return
              end
              assertEquals('function', type(ns.GetJoinClubVoiceChannelError))
            end,
            GetLocalPlayerActiveChannelMemberInfo = function()
              assertEquals('function', type(ns.GetLocalPlayerActiveChannelMemberInfo))
            end,
            GetLocalPlayerMemberID = function()
              assertEquals('function', type(ns.GetLocalPlayerMemberID))
            end,
            GetMasterVolumeScale = function()
              assertEquals('function', type(ns.GetMasterVolumeScale))
            end,
            GetMemberGUID = function()
              assertEquals('function', type(ns.GetMemberGUID))
            end,
            GetMemberID = function()
              assertEquals('function', type(ns.GetMemberID))
            end,
            GetMemberInfo = function()
              assertEquals('function', type(ns.GetMemberInfo))
            end,
            GetMemberName = function()
              assertEquals('function', type(ns.GetMemberName))
            end,
            GetMemberVolume = function()
              assertEquals('function', type(ns.GetMemberVolume))
            end,
            GetOutputVolume = function()
              assertEquals('function', type(ns.GetOutputVolume))
            end,
            GetPTTButtonPressedState = function()
              assertEquals('function', type(ns.GetPTTButtonPressedState))
            end,
            GetProcesses = function()
              assertEquals('function', type(ns.GetProcesses))
            end,
            GetPushToTalkBinding = function()
              assertEquals('function', type(ns.GetPushToTalkBinding))
            end,
            GetRemoteTtsVoices = function()
              assertEquals('function', type(ns.GetRemoteTtsVoices))
            end,
            GetTtsVoices = function()
              assertEquals('function', type(ns.GetTtsVoices))
            end,
            GetVADSensitivity = function()
              assertEquals('function', type(ns.GetVADSensitivity))
            end,
            IsChannelJoinPending = function()
              assertEquals('function', type(ns.IsChannelJoinPending))
            end,
            IsDeafened = function()
              assertEquals('function', type(ns.IsDeafened))
            end,
            IsEnabled = function()
              assertEquals('function', type(ns.IsEnabled))
            end,
            IsLoggedIn = function()
              assertEquals('function', type(ns.IsLoggedIn))
            end,
            IsMemberLocalPlayer = function()
              assertEquals('function', type(ns.IsMemberLocalPlayer))
            end,
            IsMemberMuted = function()
              assertEquals('function', type(ns.IsMemberMuted))
            end,
            IsMemberMutedForAll = function()
              assertEquals('function', type(ns.IsMemberMutedForAll))
            end,
            IsMemberSilenced = function()
              assertEquals('function', type(ns.IsMemberSilenced))
            end,
            IsMuted = function()
              assertEquals('function', type(ns.IsMuted))
            end,
            IsParentalDisabled = function()
              assertEquals('function', type(ns.IsParentalDisabled))
            end,
            IsParentalMuted = function()
              assertEquals('function', type(ns.IsParentalMuted))
            end,
            IsPlayerUsingVoice = function()
              assertEquals('function', type(ns.IsPlayerUsingVoice))
            end,
            IsSilenced = function()
              assertEquals('function', type(ns.IsSilenced))
            end,
            IsSpeakForMeActive = function()
              assertEquals('function', type(ns.IsSpeakForMeActive))
            end,
            IsSpeakForMeAllowed = function()
              assertEquals('function', type(ns.IsSpeakForMeAllowed))
            end,
            IsTranscriptionAllowed = function()
              assertEquals('function', type(ns.IsTranscriptionAllowed))
            end,
            LeaveChannel = function()
              assertEquals('function', type(ns.LeaveChannel))
            end,
            Login = function()
              assertEquals('function', type(ns.Login))
            end,
            Logout = function()
              assertEquals('function', type(ns.Logout))
            end,
            MarkChannelsDiscovered = function()
              assertEquals('function', type(ns.MarkChannelsDiscovered))
            end,
            RequestJoinAndActivateCommunityStreamChannel = function()
              assertEquals('function', type(ns.RequestJoinAndActivateCommunityStreamChannel))
            end,
            RequestJoinChannelByChannelType = function()
              assertEquals('function', type(ns.RequestJoinChannelByChannelType))
            end,
            SetCommunicationMode = function()
              assertEquals('function', type(ns.SetCommunicationMode))
            end,
            SetDeafened = function()
              assertEquals('function', type(ns.SetDeafened))
            end,
            SetInputDevice = function()
              assertEquals('function', type(ns.SetInputDevice))
            end,
            SetInputVolume = function()
              assertEquals('function', type(ns.SetInputVolume))
            end,
            SetMasterVolumeScale = function()
              assertEquals('function', type(ns.SetMasterVolumeScale))
            end,
            SetMemberMuted = function()
              assertEquals('function', type(ns.SetMemberMuted))
            end,
            SetMemberVolume = function()
              assertEquals('function', type(ns.SetMemberVolume))
            end,
            SetMuted = function()
              assertEquals('function', type(ns.SetMuted))
            end,
            SetOutputDevice = function()
              assertEquals('function', type(ns.SetOutputDevice))
            end,
            SetOutputVolume = function()
              assertEquals('function', type(ns.SetOutputVolume))
            end,
            SetPortraitTexture = function()
              assertEquals('function', type(ns.SetPortraitTexture))
            end,
            SetPushToTalkBinding = function()
              assertEquals('function', type(ns.SetPushToTalkBinding))
            end,
            SetVADSensitivity = function()
              assertEquals('function', type(ns.SetVADSensitivity))
            end,
            ShouldDiscoverChannels = function()
              assertEquals('function', type(ns.ShouldDiscoverChannels))
            end,
            SpeakRemoteTextSample = function()
              assertEquals('function', type(ns.SpeakRemoteTextSample))
            end,
            SpeakText = function()
              assertEquals('function', type(ns.SpeakText))
            end,
            StopSpeakingText = function()
              assertEquals('function', type(ns.StopSpeakingText))
            end,
            ToggleDeafened = function()
              assertEquals('function', type(ns.ToggleDeafened))
            end,
            ToggleMemberMuted = function()
              assertEquals('function', type(ns.ToggleMemberMuted))
            end,
            ToggleMuted = function()
              assertEquals('function', type(ns.ToggleMuted))
            end,
          }
        end,
        C_WeeklyRewards = function()
          local ns = _G.C_WeeklyRewards
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            AreRewardsForCurrentRewardPeriod = function()
              assertEquals('function', type(ns.AreRewardsForCurrentRewardPeriod))
            end,
            CanClaimRewards = function()
              assertEquals('function', type(ns.CanClaimRewards))
            end,
            ClaimReward = function()
              assertEquals('function', type(ns.ClaimReward))
            end,
            CloseInteraction = function()
              assertEquals('function', type(ns.CloseInteraction))
            end,
            GetActivities = function()
              assertEquals('function', type(ns.GetActivities))
            end,
            GetActivityEncounterInfo = function()
              assertEquals('function', type(ns.GetActivityEncounterInfo))
            end,
            GetConquestWeeklyProgress = function()
              assertEquals('function', type(ns.GetConquestWeeklyProgress))
            end,
            GetExampleRewardItemHyperlinks = function()
              assertEquals('function', type(ns.GetExampleRewardItemHyperlinks))
            end,
            GetItemHyperlink = function()
              assertEquals('function', type(ns.GetItemHyperlink))
            end,
            GetNextMythicPlusIncrease = function()
              assertEquals('function', type(ns.GetNextMythicPlusIncrease))
            end,
            HasAvailableRewards = function()
              assertEquals('function', type(ns.HasAvailableRewards))
            end,
            HasGeneratedRewards = function()
              assertEquals('function', type(ns.HasGeneratedRewards))
            end,
            HasInteraction = function()
              assertEquals('function', type(ns.HasInteraction))
            end,
            OnUIInteract = function()
              assertEquals('function', type(ns.OnUIInteract))
            end,
          }
        end,
        C_Widget = function()
          local ns = _G.C_Widget
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            IsFrameWidget = function()
              assertEquals('function', type(ns.IsFrameWidget))
            end,
            IsWidget = function()
              assertEquals('function', type(ns.IsWidget))
            end,
          }
        end,
        C_WowTokenPublic = function()
          local ns = _G.C_WowTokenPublic
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetCommerceSystemStatus = function()
              assertEquals('function', type(ns.GetCommerceSystemStatus))
            end,
            GetCurrentMarketPrice = function()
              assertEquals('function', type(ns.GetCurrentMarketPrice))
            end,
            GetGuaranteedPrice = function()
              assertEquals('function', type(ns.GetGuaranteedPrice))
            end,
            GetListedAuctionableTokenInfo = function()
              assertEquals('function', type(ns.GetListedAuctionableTokenInfo))
            end,
            GetNumListedAuctionableTokens = function()
              assertEquals('function', type(ns.GetNumListedAuctionableTokens))
            end,
            IsAuctionableWowToken = function()
              assertEquals('function', type(ns.IsAuctionableWowToken))
            end,
            UpdateListedAuctionableTokens = function()
              assertEquals('function', type(ns.UpdateListedAuctionableTokens))
            end,
            UpdateMarketPrice = function()
              assertEquals('function', type(ns.UpdateMarketPrice))
            end,
          }
        end,
        C_WowTokenUI = function()
          local ns = _G.C_WowTokenUI
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            StartTokenSell = function()
              assertEquals('function', type(ns.StartTokenSell))
            end,
          }
        end,
        C_ZoneAbility = function()
          local ns = _G.C_ZoneAbility
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            GetActiveAbilities = function()
              assertEquals('function', type(ns.GetActiveAbilities))
            end,
          }
        end,
        Kiosk = function()
          local ns = _G.Kiosk
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return {
            IsEnabled = function()
              assertEquals('function', type(ns.IsEnabled))
            end,
          }
        end,
      }
    end,
    uiobjects = function()
      local function assertCreateFrame(ty)
        local function process(...)
          assertEquals(1, select('#', ...))
          local frame = ...
          assert(type(frame) == 'table')
          return frame
        end
        return process(CreateFrame(ty))
      end
      local function assertCreateFrameFails(ty)
        local success, err = pcall(function()
          CreateFrame(ty)
        end)
        assert(not success)
        local expectedErr = 'CreateFrame: Unknown frame type \'' .. ty .. '\''
        assertEquals(expectedErr, err:sub(err:len() - expectedErr:len() + 1))
      end
      return {
        Actor = function()
          assertCreateFrameFails('Actor')
        end,
        Alpha = function()
          assertCreateFrameFails('Alpha')
        end,
        Animation = function()
          assertCreateFrameFails('Animation')
        end,
        AnimationGroup = function()
          assertCreateFrameFails('AnimationGroup')
        end,
        Browser = function()
          local frame = assertCreateFrame('Browser')
          local frame2 = assertCreateFrame('Browser')
          assertEquals('Browser', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                NavigateHome = function()
                  assertEquals('function', type(mt.__index.NavigateHome))
                end,
              }
            end,
          }
        end,
        Button = function()
          local frame = assertCreateFrame('Button')
          local frame2 = assertCreateFrame('Button')
          assertEquals('Button', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                Click = function()
                  assertEquals('function', type(mt.__index.Click))
                end,
                Disable = function()
                  assertEquals('function', type(mt.__index.Disable))
                end,
                Enable = function()
                  assertEquals('function', type(mt.__index.Enable))
                end,
                GetButtonState = function()
                  assertEquals('function', type(mt.__index.GetButtonState))
                end,
                GetDisabledFontObject = function()
                  assertEquals('function', type(mt.__index.GetDisabledFontObject))
                end,
                GetDisabledTexture = function()
                  assertEquals('function', type(mt.__index.GetDisabledTexture))
                end,
                GetFontString = function()
                  assertEquals('function', type(mt.__index.GetFontString))
                end,
                GetHighlightFontObject = function()
                  assertEquals('function', type(mt.__index.GetHighlightFontObject))
                end,
                GetHighlightTexture = function()
                  assertEquals('function', type(mt.__index.GetHighlightTexture))
                end,
                GetMotionScriptsWhileDisabled = function()
                  assertEquals('function', type(mt.__index.GetMotionScriptsWhileDisabled))
                end,
                GetNormalFontObject = function()
                  assertEquals('function', type(mt.__index.GetNormalFontObject))
                end,
                GetNormalTexture = function()
                  assertEquals('function', type(mt.__index.GetNormalTexture))
                end,
                GetPushedTextOffset = function()
                  assertEquals('function', type(mt.__index.GetPushedTextOffset))
                end,
                GetPushedTexture = function()
                  assertEquals('function', type(mt.__index.GetPushedTexture))
                end,
                GetText = function()
                  assertEquals('function', type(mt.__index.GetText))
                end,
                GetTextHeight = function()
                  assertEquals('function', type(mt.__index.GetTextHeight))
                end,
                GetTextWidth = function()
                  assertEquals('function', type(mt.__index.GetTextWidth))
                end,
                IsEnabled = function()
                  assertEquals('function', type(mt.__index.IsEnabled))
                end,
                LockHighlight = function()
                  assertEquals('function', type(mt.__index.LockHighlight))
                end,
                RegisterForClicks = function()
                  assertEquals('function', type(mt.__index.RegisterForClicks))
                end,
                RegisterForMouse = function()
                  assertEquals('function', type(mt.__index.RegisterForMouse))
                end,
                SetButtonState = function()
                  assertEquals('function', type(mt.__index.SetButtonState))
                end,
                SetDisabledAtlas = function()
                  assertEquals('function', type(mt.__index.SetDisabledAtlas))
                end,
                SetDisabledFontObject = function()
                  assertEquals('function', type(mt.__index.SetDisabledFontObject))
                end,
                SetDisabledTexture = function()
                  assertEquals('function', type(mt.__index.SetDisabledTexture))
                end,
                SetEnabled = function()
                  assertEquals('function', type(mt.__index.SetEnabled))
                end,
                SetFontString = function()
                  assertEquals('function', type(mt.__index.SetFontString))
                end,
                SetFormattedText = function()
                  assertEquals('function', type(mt.__index.SetFormattedText))
                end,
                SetHighlightAtlas = function()
                  assertEquals('function', type(mt.__index.SetHighlightAtlas))
                end,
                SetHighlightFontObject = function()
                  assertEquals('function', type(mt.__index.SetHighlightFontObject))
                end,
                SetHighlightTexture = function()
                  assertEquals('function', type(mt.__index.SetHighlightTexture))
                end,
                SetMotionScriptsWhileDisabled = function()
                  assertEquals('function', type(mt.__index.SetMotionScriptsWhileDisabled))
                end,
                SetNormalAtlas = function()
                  assertEquals('function', type(mt.__index.SetNormalAtlas))
                end,
                SetNormalFontObject = function()
                  assertEquals('function', type(mt.__index.SetNormalFontObject))
                end,
                SetNormalTexture = function()
                  assertEquals('function', type(mt.__index.SetNormalTexture))
                end,
                SetPushedAtlas = function()
                  assertEquals('function', type(mt.__index.SetPushedAtlas))
                end,
                SetPushedTextOffset = function()
                  assertEquals('function', type(mt.__index.SetPushedTextOffset))
                end,
                SetPushedTexture = function()
                  assertEquals('function', type(mt.__index.SetPushedTexture))
                end,
                SetText = function()
                  assertEquals('function', type(mt.__index.SetText))
                end,
                UnlockHighlight = function()
                  assertEquals('function', type(mt.__index.UnlockHighlight))
                end,
              }
            end,
          }
        end,
        CheckButton = function()
          local frame = assertCreateFrame('CheckButton')
          local frame2 = assertCreateFrame('CheckButton')
          assertEquals('CheckButton', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                GetChecked = function()
                  assertEquals('function', type(mt.__index.GetChecked))
                end,
                GetCheckedTexture = function()
                  assertEquals('function', type(mt.__index.GetCheckedTexture))
                end,
                GetDisabledCheckedTexture = function()
                  assertEquals('function', type(mt.__index.GetDisabledCheckedTexture))
                end,
                SetChecked = function()
                  assertEquals('function', type(mt.__index.SetChecked))
                end,
                SetCheckedTexture = function()
                  assertEquals('function', type(mt.__index.SetCheckedTexture))
                end,
                SetDisabledCheckedTexture = function()
                  assertEquals('function', type(mt.__index.SetDisabledCheckedTexture))
                end,
              }
            end,
          }
        end,
        Checkout = function()
          local frame = assertCreateFrame('Checkout')
          local frame2 = assertCreateFrame('Checkout')
          assertEquals('BlizzardCheckout', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
          }
        end,
        CinematicModel = function()
          local frame = assertCreateFrame('CinematicModel')
          local frame2 = assertCreateFrame('CinematicModel')
          assertEquals('CinematicModel', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                SetFacingLeft = function()
                  assertEquals('function', type(mt.__index.SetFacingLeft))
                end,
                SetHeightFactor = function()
                  assertEquals('function', type(mt.__index.SetHeightFactor))
                end,
                SetTargetDistance = function()
                  assertEquals('function', type(mt.__index.SetTargetDistance))
                end,
              }
            end,
          }
        end,
        ColorSelect = function()
          local frame = assertCreateFrame('ColorSelect')
          local frame2 = assertCreateFrame('ColorSelect')
          assertEquals('ColorSelect', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                GetColorHSV = function()
                  assertEquals('function', type(mt.__index.GetColorHSV))
                end,
                GetColorRGB = function()
                  assertEquals('function', type(mt.__index.GetColorRGB))
                end,
                GetColorValueTexture = function()
                  assertEquals('function', type(mt.__index.GetColorValueTexture))
                end,
                GetColorValueThumbTexture = function()
                  assertEquals('function', type(mt.__index.GetColorValueThumbTexture))
                end,
                GetColorWheelTexture = function()
                  assertEquals('function', type(mt.__index.GetColorWheelTexture))
                end,
                GetColorWheelThumbTexture = function()
                  assertEquals('function', type(mt.__index.GetColorWheelThumbTexture))
                end,
                SetColorHSV = function()
                  assertEquals('function', type(mt.__index.SetColorHSV))
                end,
                SetColorRGB = function()
                  assertEquals('function', type(mt.__index.SetColorRGB))
                end,
                SetColorValueTexture = function()
                  assertEquals('function', type(mt.__index.SetColorValueTexture))
                end,
                SetColorValueThumbTexture = function()
                  assertEquals('function', type(mt.__index.SetColorValueThumbTexture))
                end,
                SetColorWheelTexture = function()
                  assertEquals('function', type(mt.__index.SetColorWheelTexture))
                end,
                SetColorWheelThumbTexture = function()
                  assertEquals('function', type(mt.__index.SetColorWheelThumbTexture))
                end,
              }
            end,
          }
        end,
        ControlPoint = function()
          assertCreateFrameFails('ControlPoint')
        end,
        Cooldown = function()
          local frame = assertCreateFrame('Cooldown')
          local frame2 = assertCreateFrame('Cooldown')
          assertEquals('Cooldown', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                Clear = function()
                  assertEquals('function', type(mt.__index.Clear))
                end,
                GetCooldownDisplayDuration = function()
                  assertEquals('function', type(mt.__index.GetCooldownDisplayDuration))
                end,
                GetCooldownDuration = function()
                  assertEquals('function', type(mt.__index.GetCooldownDuration))
                end,
                GetCooldownTimes = function()
                  assertEquals('function', type(mt.__index.GetCooldownTimes))
                end,
                GetDrawBling = function()
                  assertEquals('function', type(mt.__index.GetDrawBling))
                end,
                GetDrawEdge = function()
                  assertEquals('function', type(mt.__index.GetDrawEdge))
                end,
                GetDrawSwipe = function()
                  assertEquals('function', type(mt.__index.GetDrawSwipe))
                end,
                GetEdgeScale = function()
                  assertEquals('function', type(mt.__index.GetEdgeScale))
                end,
                GetReverse = function()
                  assertEquals('function', type(mt.__index.GetReverse))
                end,
                GetRotation = function()
                  assertEquals('function', type(mt.__index.GetRotation))
                end,
                IsPaused = function()
                  assertEquals('function', type(mt.__index.IsPaused))
                end,
                Pause = function()
                  assertEquals('function', type(mt.__index.Pause))
                end,
                Resume = function()
                  assertEquals('function', type(mt.__index.Resume))
                end,
                SetBlingTexture = function()
                  assertEquals('function', type(mt.__index.SetBlingTexture))
                end,
                SetCooldown = function()
                  assertEquals('function', type(mt.__index.SetCooldown))
                end,
                SetCooldownDuration = function()
                  assertEquals('function', type(mt.__index.SetCooldownDuration))
                end,
                SetCooldownUNIX = function()
                  assertEquals('function', type(mt.__index.SetCooldownUNIX))
                end,
                SetCountdownAbbrevThreshold = function()
                  assertEquals('function', type(mt.__index.SetCountdownAbbrevThreshold))
                end,
                SetCountdownFont = function()
                  assertEquals('function', type(mt.__index.SetCountdownFont))
                end,
                SetDrawBling = function()
                  assertEquals('function', type(mt.__index.SetDrawBling))
                end,
                SetDrawEdge = function()
                  assertEquals('function', type(mt.__index.SetDrawEdge))
                end,
                SetDrawSwipe = function()
                  assertEquals('function', type(mt.__index.SetDrawSwipe))
                end,
                SetEdgeScale = function()
                  assertEquals('function', type(mt.__index.SetEdgeScale))
                end,
                SetEdgeTexture = function()
                  assertEquals('function', type(mt.__index.SetEdgeTexture))
                end,
                SetHideCountdownNumbers = function()
                  assertEquals('function', type(mt.__index.SetHideCountdownNumbers))
                end,
                SetReverse = function()
                  assertEquals('function', type(mt.__index.SetReverse))
                end,
                SetRotation = function()
                  assertEquals('function', type(mt.__index.SetRotation))
                end,
                SetSwipeColor = function()
                  assertEquals('function', type(mt.__index.SetSwipeColor))
                end,
                SetSwipeTexture = function()
                  assertEquals('function', type(mt.__index.SetSwipeTexture))
                end,
                SetUseCircularEdge = function()
                  assertEquals('function', type(mt.__index.SetUseCircularEdge))
                end,
              }
            end,
          }
        end,
        DressUpModel = function()
          local frame = assertCreateFrame('DressUpModel')
          local frame2 = assertCreateFrame('DressUpModel')
          assertEquals('DressUpModel', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                SetAutoDress = function()
                  assertEquals('function', type(mt.__index.SetAutoDress))
                end,
              }
            end,
          }
        end,
        EditBox = function()
          local frame = assertCreateFrame('EditBox')
          local frame2 = assertCreateFrame('EditBox')
          frame:Hide() -- captures input focus otherwise
          frame2:Hide() -- captures input focus otherwise
          assertEquals('EditBox', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                AddHistoryLine = function()
                  assertEquals('function', type(mt.__index.AddHistoryLine))
                end,
                ClearFocus = function()
                  assertEquals('function', type(mt.__index.ClearFocus))
                end,
                ClearHistory = function()
                  assertEquals('function', type(mt.__index.ClearHistory))
                end,
                Disable = function()
                  assertEquals('function', type(mt.__index.Disable))
                end,
                Enable = function()
                  assertEquals('function', type(mt.__index.Enable))
                end,
                GetHistoryLines = function()
                  assertEquals('function', type(mt.__index.GetHistoryLines))
                end,
                GetInputLanguage = function()
                  assertEquals('function', type(mt.__index.GetInputLanguage))
                end,
                GetMaxBytes = function()
                  assertEquals('function', type(mt.__index.GetMaxBytes))
                end,
                GetMaxLetters = function()
                  assertEquals('function', type(mt.__index.GetMaxLetters))
                end,
                GetNumber = function()
                  assertEquals('function', type(mt.__index.GetNumber))
                end,
                GetText = function()
                  assertEquals('function', type(mt.__index.GetText))
                end,
                HasFocus = function()
                  assertEquals('function', type(mt.__index.HasFocus))
                end,
                HighlightText = function()
                  assertEquals('function', type(mt.__index.HighlightText))
                end,
                Insert = function()
                  assertEquals('function', type(mt.__index.Insert))
                end,
                IsAutoFocus = function()
                  assertEquals('function', type(mt.__index.IsAutoFocus))
                end,
                IsCountInvisibleLetters = function()
                  assertEquals('function', type(mt.__index.IsCountInvisibleLetters))
                end,
                IsEnabled = function()
                  assertEquals('function', type(mt.__index.IsEnabled))
                end,
                IsMultiLine = function()
                  assertEquals('function', type(mt.__index.IsMultiLine))
                end,
                IsSecureText = function()
                  assertEquals('function', type(mt.__index.IsSecureText))
                end,
                SetAltArrowKeyMode = function()
                  assertEquals('function', type(mt.__index.SetAltArrowKeyMode))
                end,
                SetAutoFocus = function()
                  assertEquals('function', type(mt.__index.SetAutoFocus))
                end,
                SetCountInvisibleLetters = function()
                  assertEquals('function', type(mt.__index.SetCountInvisibleLetters))
                end,
                SetCursorPosition = function()
                  assertEquals('function', type(mt.__index.SetCursorPosition))
                end,
                SetEnabled = function()
                  assertEquals('function', type(mt.__index.SetEnabled))
                end,
                SetFocus = function()
                  assertEquals('function', type(mt.__index.SetFocus))
                end,
                SetHighlightColor = function()
                  assertEquals('function', type(mt.__index.SetHighlightColor))
                end,
                SetHistoryLines = function()
                  assertEquals('function', type(mt.__index.SetHistoryLines))
                end,
                SetMaxBytes = function()
                  assertEquals('function', type(mt.__index.SetMaxBytes))
                end,
                SetMaxLetters = function()
                  assertEquals('function', type(mt.__index.SetMaxLetters))
                end,
                SetMultiLine = function()
                  assertEquals('function', type(mt.__index.SetMultiLine))
                end,
                SetNumber = function()
                  assertEquals('function', type(mt.__index.SetNumber))
                end,
                SetNumeric = function()
                  assertEquals('function', type(mt.__index.SetNumeric))
                end,
                SetSecureText = function()
                  assertEquals('function', type(mt.__index.SetSecureText))
                end,
                SetSecurityDisablePaste = function()
                  assertEquals('function', type(mt.__index.SetSecurityDisablePaste))
                end,
                SetSecurityDisableSetText = function()
                  assertEquals('function', type(mt.__index.SetSecurityDisableSetText))
                end,
                SetText = function()
                  assertEquals('function', type(mt.__index.SetText))
                end,
                SetTextInsets = function()
                  assertEquals('function', type(mt.__index.SetTextInsets))
                end,
              }
            end,
          }
        end,
        FogOfWarFrame = function()
          local frame = assertCreateFrame('FogOfWarFrame')
          local frame2 = assertCreateFrame('FogOfWarFrame')
          assertEquals('FogOfWarFrame', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
        end,
        Font = function()
          assertCreateFrameFails('Font')
        end,
        FontInstance = function()
          assertCreateFrameFails('FontInstance')
        end,
        FontString = function()
          assertCreateFrameFails('FontString')
        end,
        Frame = function()
          local frame = assertCreateFrame('Frame')
          local frame2 = assertCreateFrame('Frame')
          assertEquals('Frame', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                CreateFontString = function()
                  assertEquals('function', type(mt.__index.CreateFontString))
                end,
                CreateLine = function()
                  assertEquals('function', type(mt.__index.CreateLine))
                end,
                CreateMaskTexture = function()
                  assertEquals('function', type(mt.__index.CreateMaskTexture))
                end,
                CreateTexture = function()
                  assertEquals('function', type(mt.__index.CreateTexture))
                end,
                DesaturateHierarchy = function()
                  assertEquals('function', type(mt.__index.DesaturateHierarchy))
                end,
                DisableDrawLayer = function()
                  assertEquals('function', type(mt.__index.DisableDrawLayer))
                end,
                EnableKeyboard = function()
                  assertEquals('function', type(mt.__index.EnableKeyboard))
                end,
                EnableMouse = function()
                  assertEquals('function', type(mt.__index.EnableMouse))
                end,
                EnableMouseWheel = function()
                  assertEquals('function', type(mt.__index.EnableMouseWheel))
                end,
                GetAttribute = function()
                  assertEquals('function', type(mt.__index.GetAttribute))
                end,
                GetChildren = function()
                  assertEquals('function', type(mt.__index.GetChildren))
                end,
                GetFrameLevel = function()
                  assertEquals('function', type(mt.__index.GetFrameLevel))
                end,
                GetFrameStrata = function()
                  assertEquals('function', type(mt.__index.GetFrameStrata))
                end,
                GetHyperlinksEnabled = function()
                  assertEquals('function', type(mt.__index.GetHyperlinksEnabled))
                end,
                GetID = function()
                  assertEquals('function', type(mt.__index.GetID))
                end,
                GetMaxResize = function()
                  assertEquals('function', type(mt.__index.GetMaxResize))
                end,
                GetMinResize = function()
                  assertEquals('function', type(mt.__index.GetMinResize))
                end,
                GetNumChildren = function()
                  assertEquals('function', type(mt.__index.GetNumChildren))
                end,
                GetNumRegions = function()
                  assertEquals('function', type(mt.__index.GetNumRegions))
                end,
                GetPropagateKeyboardInput = function()
                  assertEquals('function', type(mt.__index.GetPropagateKeyboardInput))
                end,
                GetRegions = function()
                  assertEquals('function', type(mt.__index.GetRegions))
                end,
                IgnoreDepth = function()
                  assertEquals('function', type(mt.__index.IgnoreDepth))
                end,
                IsClampedToScreen = function()
                  assertEquals('function', type(mt.__index.IsClampedToScreen))
                end,
                IsEventRegistered = function()
                  assertEquals('function', type(mt.__index.IsEventRegistered))
                end,
                IsMouseClickEnabled = function()
                  assertEquals('function', type(mt.__index.IsMouseClickEnabled))
                end,
                IsMouseEnabled = function()
                  assertEquals('function', type(mt.__index.IsMouseEnabled))
                end,
                IsMouseMotionEnabled = function()
                  assertEquals('function', type(mt.__index.IsMouseMotionEnabled))
                end,
                IsMouseWheelEnabled = function()
                  assertEquals('function', type(mt.__index.IsMouseWheelEnabled))
                end,
                IsMovable = function()
                  assertEquals('function', type(mt.__index.IsMovable))
                end,
                IsResizable = function()
                  assertEquals('function', type(mt.__index.IsResizable))
                end,
                IsToplevel = function()
                  assertEquals('function', type(mt.__index.IsToplevel))
                end,
                IsUserPlaced = function()
                  assertEquals('function', type(mt.__index.IsUserPlaced))
                end,
                Raise = function()
                  assertEquals('function', type(mt.__index.Raise))
                end,
                RegisterAllEvents = function()
                  assertEquals('function', type(mt.__index.RegisterAllEvents))
                end,
                RegisterEvent = function()
                  assertEquals('function', type(mt.__index.RegisterEvent))
                end,
                RegisterForDrag = function()
                  assertEquals('function', type(mt.__index.RegisterForDrag))
                end,
                RegisterUnitEvent = function()
                  assertEquals('function', type(mt.__index.RegisterUnitEvent))
                end,
                SetAttribute = function()
                  assertEquals('function', type(mt.__index.SetAttribute))
                end,
                SetAttributeNoHandler = function()
                  assertEquals('function', type(mt.__index.SetAttributeNoHandler))
                end,
                SetClampRectInsets = function()
                  assertEquals('function', type(mt.__index.SetClampRectInsets))
                end,
                SetClampedToScreen = function()
                  assertEquals('function', type(mt.__index.SetClampedToScreen))
                end,
                SetClipsChildren = function()
                  assertEquals('function', type(mt.__index.SetClipsChildren))
                end,
                SetDepth = function()
                  assertEquals('function', type(mt.__index.SetDepth))
                end,
                SetDontSavePosition = function()
                  assertEquals('function', type(mt.__index.SetDontSavePosition))
                end,
                SetFixedFrameLevel = function()
                  assertEquals('function', type(mt.__index.SetFixedFrameLevel))
                end,
                SetFixedFrameStrata = function()
                  assertEquals('function', type(mt.__index.SetFixedFrameStrata))
                end,
                SetFrameLevel = function()
                  assertEquals('function', type(mt.__index.SetFrameLevel))
                end,
                SetFrameStrata = function()
                  assertEquals('function', type(mt.__index.SetFrameStrata))
                end,
                SetHitRectInsets = function()
                  assertEquals('function', type(mt.__index.SetHitRectInsets))
                end,
                SetHyperlinksEnabled = function()
                  assertEquals('function', type(mt.__index.SetHyperlinksEnabled))
                end,
                SetID = function()
                  assertEquals('function', type(mt.__index.SetID))
                end,
                SetMaxResize = function()
                  assertEquals('function', type(mt.__index.SetMaxResize))
                end,
                SetMinResize = function()
                  assertEquals('function', type(mt.__index.SetMinResize))
                end,
                SetMouseClickEnabled = function()
                  assertEquals('function', type(mt.__index.SetMouseClickEnabled))
                end,
                SetMouseMotionEnabled = function()
                  assertEquals('function', type(mt.__index.SetMouseMotionEnabled))
                end,
                SetMovable = function()
                  assertEquals('function', type(mt.__index.SetMovable))
                end,
                SetPropagateKeyboardInput = function()
                  assertEquals('function', type(mt.__index.SetPropagateKeyboardInput))
                end,
                SetResizable = function()
                  assertEquals('function', type(mt.__index.SetResizable))
                end,
                SetToplevel = function()
                  assertEquals('function', type(mt.__index.SetToplevel))
                end,
                SetUserPlaced = function()
                  assertEquals('function', type(mt.__index.SetUserPlaced))
                end,
                StartMoving = function()
                  assertEquals('function', type(mt.__index.StartMoving))
                end,
                StopMovingOrSizing = function()
                  assertEquals('function', type(mt.__index.StopMovingOrSizing))
                end,
                UnregisterAllEvents = function()
                  assertEquals('function', type(mt.__index.UnregisterAllEvents))
                end,
                UnregisterEvent = function()
                  assertEquals('function', type(mt.__index.UnregisterEvent))
                end,
              }
            end,
          }
        end,
        GameTooltip = function()
          local frame = assertCreateFrame('GameTooltip')
          local frame2 = assertCreateFrame('GameTooltip')
          assertEquals('GameTooltip', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                AddAtlas = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.AddAtlas))
                    return
                  end
                  assertEquals('function', type(mt.__index.AddAtlas))
                end,
                AddDoubleLine = function()
                  assertEquals('function', type(mt.__index.AddDoubleLine))
                end,
                AddFontStrings = function()
                  assertEquals('function', type(mt.__index.AddFontStrings))
                end,
                AddLine = function()
                  assertEquals('function', type(mt.__index.AddLine))
                end,
                AddSpellByID = function()
                  assertEquals('function', type(mt.__index.AddSpellByID))
                end,
                AddTexture = function()
                  assertEquals('function', type(mt.__index.AddTexture))
                end,
                AdvanceSecondaryCompareItem = function()
                  assertEquals('function', type(mt.__index.AdvanceSecondaryCompareItem))
                end,
                AppendText = function()
                  assertEquals('function', type(mt.__index.AppendText))
                end,
                ClearLines = function()
                  assertEquals('function', type(mt.__index.ClearLines))
                end,
                CopyTooltip = function()
                  assertEquals('function', type(mt.__index.CopyTooltip))
                end,
                FadeOut = function()
                  assertEquals('function', type(mt.__index.FadeOut))
                end,
                GetAnchorType = function()
                  assertEquals('function', type(mt.__index.GetAnchorType))
                end,
                GetAzeritePowerID = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.GetAzeritePowerID))
                    return
                  end
                  assertEquals('function', type(mt.__index.GetAzeritePowerID))
                end,
                GetCustomLineSpacing = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.GetCustomLineSpacing))
                    return
                  end
                  assertEquals('function', type(mt.__index.GetCustomLineSpacing))
                end,
                GetItem = function()
                  assertEquals('function', type(mt.__index.GetItem))
                end,
                GetMinimumWidth = function()
                  assertEquals('function', type(mt.__index.GetMinimumWidth))
                end,
                GetOwner = function()
                  assertEquals('function', type(mt.__index.GetOwner))
                end,
                GetPadding = function()
                  assertEquals('function', type(mt.__index.GetPadding))
                end,
                GetSpell = function()
                  assertEquals('function', type(mt.__index.GetSpell))
                end,
                GetUnit = function()
                  assertEquals('function', type(mt.__index.GetUnit))
                end,
                IsEquippedItem = function()
                  assertEquals('function', type(mt.__index.IsEquippedItem))
                end,
                IsOwned = function()
                  assertEquals('function', type(mt.__index.IsOwned))
                end,
                IsUnit = function()
                  assertEquals('function', type(mt.__index.IsUnit))
                end,
                NumLines = function()
                  assertEquals('function', type(mt.__index.NumLines))
                end,
                ResetSecondaryCompareItem = function()
                  assertEquals('function', type(mt.__index.ResetSecondaryCompareItem))
                end,
                SetAchievementByID = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetAchievementByID))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetAchievementByID))
                end,
                SetAction = function()
                  assertEquals('function', type(mt.__index.SetAction))
                end,
                SetAllowShowWithNoLines = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetAllowShowWithNoLines))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetAllowShowWithNoLines))
                end,
                SetAnchorType = function()
                  assertEquals('function', type(mt.__index.SetAnchorType))
                end,
                SetArtifactItem = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetArtifactItem))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetArtifactItem))
                end,
                SetArtifactPowerByID = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetArtifactPowerByID))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetArtifactPowerByID))
                end,
                SetAuctionItem = function()
                  if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetAuctionItem))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetAuctionItem))
                end,
                SetAuctionSellItem = function()
                  if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetAuctionSellItem))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetAuctionSellItem))
                end,
                SetAzeriteEssence = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetAzeriteEssence))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetAzeriteEssence))
                end,
                SetAzeriteEssenceSlot = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetAzeriteEssenceSlot))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetAzeriteEssenceSlot))
                end,
                SetAzeritePower = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetAzeritePower))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetAzeritePower))
                end,
                SetBackpackToken = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetBackpackToken))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetBackpackToken))
                end,
                SetBagItem = function()
                  assertEquals('function', type(mt.__index.SetBagItem))
                end,
                SetBagItemChild = function()
                  assertEquals('function', type(mt.__index.SetBagItemChild))
                end,
                SetBuybackItem = function()
                  assertEquals('function', type(mt.__index.SetBuybackItem))
                end,
                SetCompanionPet = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetCompanionPet))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetCompanionPet))
                end,
                SetCompareAzeritePower = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetCompareAzeritePower))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetCompareAzeritePower))
                end,
                SetCompareItem = function()
                  assertEquals('function', type(mt.__index.SetCompareItem))
                end,
                SetConduit = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetConduit))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetConduit))
                end,
                SetCraftItem = function()
                  if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetCraftItem))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetCraftItem))
                end,
                SetCraftSpell = function()
                  if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetCraftSpell))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetCraftSpell))
                end,
                SetCurrencyByID = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetCurrencyByID))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetCurrencyByID))
                end,
                SetCurrencyToken = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetCurrencyToken))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetCurrencyToken))
                end,
                SetCurrencyTokenByID = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetCurrencyTokenByID))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetCurrencyTokenByID))
                end,
                SetCustomLineSpacing = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetCustomLineSpacing))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetCustomLineSpacing))
                end,
                SetEnhancedConduit = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetEnhancedConduit))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetEnhancedConduit))
                end,
                SetEquipmentSet = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetEquipmentSet))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetEquipmentSet))
                end,
                SetExistingSocketGem = function()
                  assertEquals('function', type(mt.__index.SetExistingSocketGem))
                end,
                SetFrameStack = function()
                  assertEquals('function', type(mt.__index.SetFrameStack))
                end,
                SetGuildBankItem = function()
                  assertEquals('function', type(mt.__index.SetGuildBankItem))
                end,
                SetHeirloomByItemID = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetHeirloomByItemID))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetHeirloomByItemID))
                end,
                SetHyperlink = function()
                  assertEquals('function', type(mt.__index.SetHyperlink))
                end,
                SetInboxItem = function()
                  assertEquals('function', type(mt.__index.SetInboxItem))
                end,
                SetInstanceLockEncountersComplete = function()
                  assertEquals('function', type(mt.__index.SetInstanceLockEncountersComplete))
                end,
                SetInventoryItem = function()
                  assertEquals('function', type(mt.__index.SetInventoryItem))
                end,
                SetInventoryItemByID = function()
                  assertEquals('function', type(mt.__index.SetInventoryItemByID))
                end,
                SetItemByID = function()
                  assertEquals('function', type(mt.__index.SetItemByID))
                end,
                SetItemKey = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetItemKey))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetItemKey))
                end,
                SetLFGDungeonReward = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetLFGDungeonReward))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetLFGDungeonReward))
                end,
                SetLFGDungeonShortageReward = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetLFGDungeonShortageReward))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetLFGDungeonShortageReward))
                end,
                SetLootCurrency = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetLootCurrency))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetLootCurrency))
                end,
                SetLootItem = function()
                  assertEquals('function', type(mt.__index.SetLootItem))
                end,
                SetLootRollItem = function()
                  assertEquals('function', type(mt.__index.SetLootRollItem))
                end,
                SetMerchantCostItem = function()
                  assertEquals('function', type(mt.__index.SetMerchantCostItem))
                end,
                SetMerchantItem = function()
                  assertEquals('function', type(mt.__index.SetMerchantItem))
                end,
                SetMinimumWidth = function()
                  assertEquals('function', type(mt.__index.SetMinimumWidth))
                end,
                SetMountBySpellID = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetMountBySpellID))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetMountBySpellID))
                end,
                SetOwnedItemByID = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetOwnedItemByID))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetOwnedItemByID))
                end,
                SetOwner = function()
                  assertEquals('function', type(mt.__index.SetOwner))
                end,
                SetPadding = function()
                  assertEquals('function', type(mt.__index.SetPadding))
                end,
                SetPetAction = function()
                  assertEquals('function', type(mt.__index.SetPetAction))
                end,
                SetPossession = function()
                  assertEquals('function', type(mt.__index.SetPossession))
                end,
                SetPvpBrawl = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetPvpBrawl))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetPvpBrawl))
                end,
                SetPvpTalent = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetPvpTalent))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetPvpTalent))
                end,
                SetQuestCurrency = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetQuestCurrency))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetQuestCurrency))
                end,
                SetQuestItem = function()
                  assertEquals('function', type(mt.__index.SetQuestItem))
                end,
                SetQuestLogCurrency = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetQuestLogCurrency))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetQuestLogCurrency))
                end,
                SetQuestLogItem = function()
                  assertEquals('function', type(mt.__index.SetQuestLogItem))
                end,
                SetQuestLogRewardSpell = function()
                  assertEquals('function', type(mt.__index.SetQuestLogRewardSpell))
                end,
                SetQuestLogSpecialItem = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetQuestLogSpecialItem))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetQuestLogSpecialItem))
                end,
                SetQuestPartyProgress = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetQuestPartyProgress))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetQuestPartyProgress))
                end,
                SetQuestRewardSpell = function()
                  assertEquals('function', type(mt.__index.SetQuestRewardSpell))
                end,
                SetRecipeRankInfo = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetRecipeRankInfo))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetRecipeRankInfo))
                end,
                SetRecipeReagentItem = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetRecipeReagentItem))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetRecipeReagentItem))
                end,
                SetRecipeResultItem = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetRecipeResultItem))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetRecipeResultItem))
                end,
                SetRuneforgeResultItem = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetRuneforgeResultItem))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetRuneforgeResultItem))
                end,
                SetSendMailItem = function()
                  assertEquals('function', type(mt.__index.SetSendMailItem))
                end,
                SetShapeshift = function()
                  assertEquals('function', type(mt.__index.SetShapeshift))
                end,
                SetShrinkToFitWrapped = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetShrinkToFitWrapped))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetShrinkToFitWrapped))
                end,
                SetSocketGem = function()
                  assertEquals('function', type(mt.__index.SetSocketGem))
                end,
                SetSocketedItem = function()
                  assertEquals('function', type(mt.__index.SetSocketedItem))
                end,
                SetSocketedRelic = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetSocketedRelic))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetSocketedRelic))
                end,
                SetSpellBookItem = function()
                  assertEquals('function', type(mt.__index.SetSpellBookItem))
                end,
                SetSpellByID = function()
                  assertEquals('function', type(mt.__index.SetSpellByID))
                end,
                SetTalent = function()
                  assertEquals('function', type(mt.__index.SetTalent))
                end,
                SetText = function()
                  assertEquals('function', type(mt.__index.SetText))
                end,
                SetTotem = function()
                  assertEquals('function', type(mt.__index.SetTotem))
                end,
                SetToyByItemID = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetToyByItemID))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetToyByItemID))
                end,
                SetTrackingSpell = function()
                  if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetTrackingSpell))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetTrackingSpell))
                end,
                SetTradePlayerItem = function()
                  assertEquals('function', type(mt.__index.SetTradePlayerItem))
                end,
                SetTradeSkillItem = function()
                  if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetTradeSkillItem))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetTradeSkillItem))
                end,
                SetTradeTargetItem = function()
                  assertEquals('function', type(mt.__index.SetTradeTargetItem))
                end,
                SetTrainerService = function()
                  assertEquals('function', type(mt.__index.SetTrainerService))
                end,
                SetTransmogrifyItem = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetTransmogrifyItem))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetTransmogrifyItem))
                end,
                SetUnit = function()
                  assertEquals('function', type(mt.__index.SetUnit))
                end,
                SetUnitAura = function()
                  assertEquals('function', type(mt.__index.SetUnitAura))
                end,
                SetUnitBuff = function()
                  assertEquals('function', type(mt.__index.SetUnitBuff))
                end,
                SetUnitDebuff = function()
                  assertEquals('function', type(mt.__index.SetUnitDebuff))
                end,
                SetUpgradeItem = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetUpgradeItem))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetUpgradeItem))
                end,
                SetVoidDepositItem = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetVoidDepositItem))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetVoidDepositItem))
                end,
                SetVoidItem = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetVoidItem))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetVoidItem))
                end,
                SetVoidWithdrawalItem = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetVoidWithdrawalItem))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetVoidWithdrawalItem))
                end,
                SetWeeklyReward = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetWeeklyReward))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetWeeklyReward))
                end,
              }
            end,
          }
        end,
        LayeredRegion = function()
          assertCreateFrameFails('LayeredRegion')
        end,
        Line = function()
          assertCreateFrameFails('Line')
        end,
        MaskTexture = function()
          assertCreateFrameFails('MaskTexture')
        end,
        MessageFrame = function()
          local frame = assertCreateFrame('MessageFrame')
          local frame2 = assertCreateFrame('MessageFrame')
          assertEquals('MessageFrame', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                AddMessage = function()
                  assertEquals('function', type(mt.__index.AddMessage))
                end,
                Clear = function()
                  assertEquals('function', type(mt.__index.Clear))
                end,
              }
            end,
          }
        end,
        Model = function()
          local frame = assertCreateFrame('Model')
          local frame2 = assertCreateFrame('Model')
          assertEquals('Model', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                ClearModel = function()
                  assertEquals('function', type(mt.__index.ClearModel))
                end,
                GetModelScale = function()
                  assertEquals('function', type(mt.__index.GetModelScale))
                end,
                SetFacing = function()
                  assertEquals('function', type(mt.__index.SetFacing))
                end,
                SetLight = function()
                  assertEquals('function', type(mt.__index.SetLight))
                end,
                SetModel = function()
                  assertEquals('function', type(mt.__index.SetModel))
                end,
                SetModelScale = function()
                  assertEquals('function', type(mt.__index.SetModelScale))
                end,
                SetPosition = function()
                  assertEquals('function', type(mt.__index.SetPosition))
                end,
                TransformCameraSpaceToModelSpace = function()
                  assertEquals('function', type(mt.__index.TransformCameraSpaceToModelSpace))
                end,
              }
            end,
          }
        end,
        ModelScene = function()
          local frame = assertCreateFrame('ModelScene')
          local frame2 = assertCreateFrame('ModelScene')
          assertEquals('ModelScene', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                ClearFog = function()
                  assertEquals('function', type(mt.__index.ClearFog))
                end,
                CreateActor = function()
                  assertEquals('function', type(mt.__index.CreateActor))
                end,
                GetActorAtIndex = function()
                  assertEquals('function', type(mt.__index.GetActorAtIndex))
                end,
                GetCameraFarClip = function()
                  assertEquals('function', type(mt.__index.GetCameraFarClip))
                end,
                GetCameraFieldOfView = function()
                  assertEquals('function', type(mt.__index.GetCameraFieldOfView))
                end,
                GetCameraForward = function()
                  assertEquals('function', type(mt.__index.GetCameraForward))
                end,
                GetCameraNearClip = function()
                  assertEquals('function', type(mt.__index.GetCameraNearClip))
                end,
                GetCameraPosition = function()
                  assertEquals('function', type(mt.__index.GetCameraPosition))
                end,
                GetCameraRight = function()
                  assertEquals('function', type(mt.__index.GetCameraRight))
                end,
                GetCameraUp = function()
                  assertEquals('function', type(mt.__index.GetCameraUp))
                end,
                GetDrawLayer = function()
                  assertEquals('function', type(mt.__index.GetDrawLayer))
                end,
                GetFogColor = function()
                  assertEquals('function', type(mt.__index.GetFogColor))
                end,
                GetFogFar = function()
                  assertEquals('function', type(mt.__index.GetFogFar))
                end,
                GetFogNear = function()
                  assertEquals('function', type(mt.__index.GetFogNear))
                end,
                GetLightAmbientColor = function()
                  assertEquals('function', type(mt.__index.GetLightAmbientColor))
                end,
                GetLightDiffuseColor = function()
                  assertEquals('function', type(mt.__index.GetLightDiffuseColor))
                end,
                GetLightDirection = function()
                  assertEquals('function', type(mt.__index.GetLightDirection))
                end,
                GetLightPosition = function()
                  assertEquals('function', type(mt.__index.GetLightPosition))
                end,
                GetLightType = function()
                  assertEquals('function', type(mt.__index.GetLightType))
                end,
                GetNumActors = function()
                  assertEquals('function', type(mt.__index.GetNumActors))
                end,
                GetViewInsets = function()
                  assertEquals('function', type(mt.__index.GetViewInsets))
                end,
                GetViewTranslation = function()
                  assertEquals('function', type(mt.__index.GetViewTranslation))
                end,
                IsLightVisible = function()
                  assertEquals('function', type(mt.__index.IsLightVisible))
                end,
                Project3DPointTo2D = function()
                  assertEquals('function', type(mt.__index.Project3DPointTo2D))
                end,
                SetCameraFarClip = function()
                  assertEquals('function', type(mt.__index.SetCameraFarClip))
                end,
                SetCameraFieldOfView = function()
                  assertEquals('function', type(mt.__index.SetCameraFieldOfView))
                end,
                SetCameraNearClip = function()
                  assertEquals('function', type(mt.__index.SetCameraNearClip))
                end,
                SetCameraOrientationByAxisVectors = function()
                  assertEquals('function', type(mt.__index.SetCameraOrientationByAxisVectors))
                end,
                SetCameraOrientationByYawPitchRoll = function()
                  assertEquals('function', type(mt.__index.SetCameraOrientationByYawPitchRoll))
                end,
                SetCameraPosition = function()
                  assertEquals('function', type(mt.__index.SetCameraPosition))
                end,
                SetDesaturation = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetDesaturation))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetDesaturation))
                end,
                SetDrawLayer = function()
                  assertEquals('function', type(mt.__index.SetDrawLayer))
                end,
                SetFogColor = function()
                  assertEquals('function', type(mt.__index.SetFogColor))
                end,
                SetFogFar = function()
                  assertEquals('function', type(mt.__index.SetFogFar))
                end,
                SetFogNear = function()
                  assertEquals('function', type(mt.__index.SetFogNear))
                end,
                SetLightAmbientColor = function()
                  assertEquals('function', type(mt.__index.SetLightAmbientColor))
                end,
                SetLightDiffuseColor = function()
                  assertEquals('function', type(mt.__index.SetLightDiffuseColor))
                end,
                SetLightDirection = function()
                  assertEquals('function', type(mt.__index.SetLightDirection))
                end,
                SetLightPosition = function()
                  assertEquals('function', type(mt.__index.SetLightPosition))
                end,
                SetLightType = function()
                  assertEquals('function', type(mt.__index.SetLightType))
                end,
                SetLightVisible = function()
                  assertEquals('function', type(mt.__index.SetLightVisible))
                end,
                SetPaused = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetPaused))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetPaused))
                end,
                SetViewInsets = function()
                  assertEquals('function', type(mt.__index.SetViewInsets))
                end,
                SetViewTranslation = function()
                  assertEquals('function', type(mt.__index.SetViewTranslation))
                end,
                TakeActor = function()
                  assertEquals('function', type(mt.__index.TakeActor))
                end,
              }
            end,
          }
        end,
        MovieFrame = function()
          local frame = assertCreateFrame('MovieFrame')
          local frame2 = assertCreateFrame('MovieFrame')
          assertEquals('MovieFrame', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                EnableSubtitles = function()
                  assertEquals('function', type(mt.__index.EnableSubtitles))
                end,
                StartMovie = function()
                  assertEquals('function', type(mt.__index.StartMovie))
                end,
                StopMovie = function()
                  assertEquals('function', type(mt.__index.StopMovie))
                end,
              }
            end,
          }
        end,
        OffScreenFrame = function()
          local frame = assertCreateFrame('OffScreenFrame')
          local frame2 = assertCreateFrame('OffScreenFrame')
          assertEquals('OffScreenFrame', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
          }
        end,
        POIFrame = function()
          assertCreateFrameFails('POIFrame')
        end,
        ParentedObject = function()
          assertCreateFrameFails('ParentedObject')
        end,
        Path = function()
          assertCreateFrameFails('Path')
        end,
        PlayerModel = function()
          local frame = assertCreateFrame('PlayerModel')
          local frame2 = assertCreateFrame('PlayerModel')
          assertEquals('PlayerModel', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                FreezeAnimation = function()
                  assertEquals('function', type(mt.__index.FreezeAnimation))
                end,
                GetDisplayInfo = function()
                  assertEquals('function', type(mt.__index.GetDisplayInfo))
                end,
                RefreshCamera = function()
                  assertEquals('function', type(mt.__index.RefreshCamera))
                end,
                RefreshUnit = function()
                  assertEquals('function', type(mt.__index.RefreshUnit))
                end,
                SetAnimation = function()
                  assertEquals('function', type(mt.__index.SetAnimation))
                end,
                SetCamDistanceScale = function()
                  assertEquals('function', type(mt.__index.SetCamDistanceScale))
                end,
                SetDisplayInfo = function()
                  assertEquals('function', type(mt.__index.SetDisplayInfo))
                end,
                SetDoBlend = function()
                  assertEquals('function', type(mt.__index.SetDoBlend))
                end,
                SetKeepModelOnHide = function()
                  assertEquals('function', type(mt.__index.SetKeepModelOnHide))
                end,
                SetPortraitZoom = function()
                  assertEquals('function', type(mt.__index.SetPortraitZoom))
                end,
                SetRotation = function()
                  assertEquals('function', type(mt.__index.SetRotation))
                end,
                SetUnit = function()
                  assertEquals('function', type(mt.__index.SetUnit))
                end,
              }
            end,
          }
        end,
        QuestPOIFrame = function()
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertCreateFrameFails('QuestPOIFrame')
            return
          end
          local frame = assertCreateFrame('QuestPOIFrame')
          local frame2 = assertCreateFrame('QuestPOIFrame')
          assertEquals('QuestPOIFrame', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
          }
        end,
        Region = function()
          assertCreateFrameFails('Region')
        end,
        Rotation = function()
          assertCreateFrameFails('Rotation')
        end,
        Scale = function()
          assertCreateFrameFails('Scale')
        end,
        ScenarioPOIFrame = function()
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertCreateFrameFails('ScenarioPOIFrame')
            return
          end
          local frame = assertCreateFrame('ScenarioPOIFrame')
          local frame2 = assertCreateFrame('ScenarioPOIFrame')
          assertEquals('ScenarioPOIFrame', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
          }
        end,
        ScriptObject = function()
          assertCreateFrameFails('ScriptObject')
        end,
        ScrollFrame = function()
          local frame = assertCreateFrame('ScrollFrame')
          local frame2 = assertCreateFrame('ScrollFrame')
          assertEquals('ScrollFrame', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                GetHorizontalScroll = function()
                  assertEquals('function', type(mt.__index.GetHorizontalScroll))
                end,
                GetHorizontalScrollRange = function()
                  assertEquals('function', type(mt.__index.GetHorizontalScrollRange))
                end,
                GetScrollChild = function()
                  assertEquals('function', type(mt.__index.GetScrollChild))
                end,
                GetVerticalScroll = function()
                  assertEquals('function', type(mt.__index.GetVerticalScroll))
                end,
                GetVerticalScrollRange = function()
                  assertEquals('function', type(mt.__index.GetVerticalScrollRange))
                end,
                SetHorizontalScroll = function()
                  assertEquals('function', type(mt.__index.SetHorizontalScroll))
                end,
                SetScrollChild = function()
                  assertEquals('function', type(mt.__index.SetScrollChild))
                end,
                SetVerticalScroll = function()
                  assertEquals('function', type(mt.__index.SetVerticalScroll))
                end,
                UpdateScrollChildRect = function()
                  assertEquals('function', type(mt.__index.UpdateScrollChildRect))
                end,
              }
            end,
          }
        end,
        SimpleHTML = function()
          local frame = assertCreateFrame('SimpleHTML')
          local frame2 = assertCreateFrame('SimpleHTML')
          assertEquals('SimpleHTML', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                GetContentHeight = function()
                  assertEquals('function', type(mt.__index.GetContentHeight))
                end,
                SetText = function()
                  assertEquals('function', type(mt.__index.SetText))
                end,
              }
            end,
          }
        end,
        Slider = function()
          local frame = assertCreateFrame('Slider')
          local frame2 = assertCreateFrame('Slider')
          assertEquals('Slider', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                Disable = function()
                  assertEquals('function', type(mt.__index.Disable))
                end,
                Enable = function()
                  assertEquals('function', type(mt.__index.Enable))
                end,
                GetMinMaxValues = function()
                  assertEquals('function', type(mt.__index.GetMinMaxValues))
                end,
                GetObeyStepOnDrag = function()
                  assertEquals('function', type(mt.__index.GetObeyStepOnDrag))
                end,
                GetOrientation = function()
                  assertEquals('function', type(mt.__index.GetOrientation))
                end,
                GetStepsPerPage = function()
                  assertEquals('function', type(mt.__index.GetStepsPerPage))
                end,
                GetThumbTexture = function()
                  assertEquals('function', type(mt.__index.GetThumbTexture))
                end,
                GetValue = function()
                  assertEquals('function', type(mt.__index.GetValue))
                end,
                GetValueStep = function()
                  assertEquals('function', type(mt.__index.GetValueStep))
                end,
                IsDraggingThumb = function()
                  assertEquals('function', type(mt.__index.IsDraggingThumb))
                end,
                IsEnabled = function()
                  assertEquals('function', type(mt.__index.IsEnabled))
                end,
                SetEnabled = function()
                  assertEquals('function', type(mt.__index.SetEnabled))
                end,
                SetMinMaxValues = function()
                  assertEquals('function', type(mt.__index.SetMinMaxValues))
                end,
                SetObeyStepOnDrag = function()
                  assertEquals('function', type(mt.__index.SetObeyStepOnDrag))
                end,
                SetOrientation = function()
                  assertEquals('function', type(mt.__index.SetOrientation))
                end,
                SetStepsPerPage = function()
                  assertEquals('function', type(mt.__index.SetStepsPerPage))
                end,
                SetThumbTexture = function()
                  assertEquals('function', type(mt.__index.SetThumbTexture))
                end,
                SetValue = function()
                  assertEquals('function', type(mt.__index.SetValue))
                end,
                SetValueStep = function()
                  assertEquals('function', type(mt.__index.SetValueStep))
                end,
              }
            end,
          }
        end,
        StatusBar = function()
          local frame = assertCreateFrame('StatusBar')
          local frame2 = assertCreateFrame('StatusBar')
          assertEquals('StatusBar', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                GetFillStyle = function()
                  assertEquals('function', type(mt.__index.GetFillStyle))
                end,
                GetMinMaxValues = function()
                  assertEquals('function', type(mt.__index.GetMinMaxValues))
                end,
                GetOrientation = function()
                  assertEquals('function', type(mt.__index.GetOrientation))
                end,
                GetReverseFill = function()
                  assertEquals('function', type(mt.__index.GetReverseFill))
                end,
                GetRotatesTexture = function()
                  assertEquals('function', type(mt.__index.GetRotatesTexture))
                end,
                GetStatusBarAtlas = function()
                  assertEquals('function', type(mt.__index.GetStatusBarAtlas))
                end,
                GetStatusBarColor = function()
                  assertEquals('function', type(mt.__index.GetStatusBarColor))
                end,
                GetStatusBarTexture = function()
                  assertEquals('function', type(mt.__index.GetStatusBarTexture))
                end,
                GetValue = function()
                  assertEquals('function', type(mt.__index.GetValue))
                end,
                SetFillStyle = function()
                  assertEquals('function', type(mt.__index.SetFillStyle))
                end,
                SetMinMaxValues = function()
                  assertEquals('function', type(mt.__index.SetMinMaxValues))
                end,
                SetOrientation = function()
                  assertEquals('function', type(mt.__index.SetOrientation))
                end,
                SetReverseFill = function()
                  assertEquals('function', type(mt.__index.SetReverseFill))
                end,
                SetRotatesTexture = function()
                  assertEquals('function', type(mt.__index.SetRotatesTexture))
                end,
                SetStatusBarAtlas = function()
                  assertEquals('function', type(mt.__index.SetStatusBarAtlas))
                end,
                SetStatusBarColor = function()
                  assertEquals('function', type(mt.__index.SetStatusBarColor))
                end,
                SetStatusBarTexture = function()
                  assertEquals('function', type(mt.__index.SetStatusBarTexture))
                end,
                SetValue = function()
                  assertEquals('function', type(mt.__index.SetValue))
                end,
              }
            end,
          }
        end,
        TabardModel = function()
          local frame = assertCreateFrame('TabardModel')
          local frame2 = assertCreateFrame('TabardModel')
          assertEquals('TabardModel', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                GetLowerEmblemTexture = function()
                  assertEquals('function', type(mt.__index.GetLowerEmblemTexture))
                end,
                GetUpperEmblemTexture = function()
                  assertEquals('function', type(mt.__index.GetUpperEmblemTexture))
                end,
                InitializeTabardColors = function()
                  assertEquals('function', type(mt.__index.InitializeTabardColors))
                end,
              }
            end,
          }
        end,
        Texture = function()
          assertCreateFrameFails('Texture')
        end,
        TextureCoordTranslation = function()
          assertCreateFrameFails('TextureCoordTranslation')
        end,
        Translation = function()
          assertCreateFrameFails('Translation')
        end,
        UIObject = function()
          assertCreateFrameFails('UIObject')
        end,
        UnitPositionFrame = function()
          local frame = assertCreateFrame('UnitPositionFrame')
          local frame2 = assertCreateFrame('UnitPositionFrame')
          assertEquals('UnitPositionFrame', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                AddUnit = function()
                  assertEquals('function', type(mt.__index.AddUnit))
                end,
                ClearUnits = function()
                  assertEquals('function', type(mt.__index.ClearUnits))
                end,
                FinalizeUnits = function()
                  assertEquals('function', type(mt.__index.FinalizeUnits))
                end,
                GetMouseOverUnits = function()
                  assertEquals('function', type(mt.__index.GetMouseOverUnits))
                end,
                SetPlayerPingScale = function()
                  assertEquals('function', type(mt.__index.SetPlayerPingScale))
                end,
                SetPlayerPingTexture = function()
                  assertEquals('function', type(mt.__index.SetPlayerPingTexture))
                end,
                SetUiMapID = function()
                  assertEquals('function', type(mt.__index.SetUiMapID))
                end,
                StartPlayerPing = function()
                  assertEquals('function', type(mt.__index.StartPlayerPing))
                end,
                StopPlayerPing = function()
                  assertEquals('function', type(mt.__index.StopPlayerPing))
                end,
              }
            end,
          }
        end,
      }
    end,
  }
end
