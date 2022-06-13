local _, G = ...
local assertEquals = _G.assertEquals
local GetObjectType = CreateFrame('Frame').GetObjectType
function G.GeneratedTests()
  return {
    apiNamespaces = function()
      local function isLuaTest(f)
        return function()
          assertEquals('function', type(f))
          return {
            env = function()
              assertEquals(_G, getfenv(f))
            end,
            isLua = function()
              setfenv(f, getfenv(f)) -- This taints, alas.
            end,
          }
        end
      end
      local function mkTests(ns, tests)
        for k, v in pairs(ns) do
          -- Anything left over must be a FrameXML-defined function.
          tests[k] = tests[k] or isLuaTest(v)
        end
        return tests
      end
      local function checkFunc(func)
        assertEquals('function', type(func))
        return {
          getfenv = function()
            assertEquals(_G, getfenv(func))
          end,
          setfenv = function()
            assertEquals(
              false,
              pcall(function()
                setfenv(func, _G)
              end)
            )
          end,
        }
      end
      return {
        C_AccountInfo = function()
          local ns = _G.C_AccountInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetIDFromBattleNetAccountGUID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetIDFromBattleNetAccountGUID))
                return
              end
              return checkFunc(ns.GetIDFromBattleNetAccountGUID)
            end,
            IsGUIDBattleNetAccountType = function()
              return checkFunc(ns.IsGUIDBattleNetAccountType)
            end,
            IsGUIDRelatedToLocalAccount = function()
              return checkFunc(ns.IsGUIDRelatedToLocalAccount)
            end,
          })
        end,
        C_AchievementInfo = function()
          local ns = _G.C_AchievementInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetRewardItemID = function()
              return checkFunc(ns.GetRewardItemID)
            end,
            GetSupercedingAchievements = function()
              return checkFunc(ns.GetSupercedingAchievements)
            end,
            IsValidAchievement = function()
              return checkFunc(ns.IsValidAchievement)
            end,
            SetPortraitTexture = function()
              return checkFunc(ns.SetPortraitTexture)
            end,
          })
        end,
        C_ActionBar = function()
          local ns = _G.C_ActionBar
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            FindFlyoutActionButtons = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.FindFlyoutActionButtons))
                return
              end
              return checkFunc(ns.FindFlyoutActionButtons)
            end,
            FindPetActionButtons = function()
              return checkFunc(ns.FindPetActionButtons)
            end,
            FindSpellActionButtons = function()
              return checkFunc(ns.FindSpellActionButtons)
            end,
            GetBonusBarIndexForSlot = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetBonusBarIndexForSlot))
                return
              end
              return checkFunc(ns.GetBonusBarIndexForSlot)
            end,
            GetPetActionPetBarIndices = function()
              return checkFunc(ns.GetPetActionPetBarIndices)
            end,
            HasFlyoutActionButtons = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.HasFlyoutActionButtons))
                return
              end
              return checkFunc(ns.HasFlyoutActionButtons)
            end,
            HasPetActionButtons = function()
              return checkFunc(ns.HasPetActionButtons)
            end,
            HasPetActionPetBarIndices = function()
              return checkFunc(ns.HasPetActionPetBarIndices)
            end,
            HasSpellActionButtons = function()
              return checkFunc(ns.HasSpellActionButtons)
            end,
            IsAutoCastPetAction = function()
              return checkFunc(ns.IsAutoCastPetAction)
            end,
            IsEnabledAutoCastPetAction = function()
              return checkFunc(ns.IsEnabledAutoCastPetAction)
            end,
            IsHarmfulAction = function()
              return checkFunc(ns.IsHarmfulAction)
            end,
            IsHelpfulAction = function()
              return checkFunc(ns.IsHelpfulAction)
            end,
            IsOnBarOrSpecialBar = function()
              return checkFunc(ns.IsOnBarOrSpecialBar)
            end,
            PutActionInSlot = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.PutActionInSlot))
                return
              end
              return checkFunc(ns.PutActionInSlot)
            end,
            ShouldOverrideBarShowHealthBar = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ShouldOverrideBarShowHealthBar))
                return
              end
              return checkFunc(ns.ShouldOverrideBarShowHealthBar)
            end,
            ShouldOverrideBarShowManaBar = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ShouldOverrideBarShowManaBar))
                return
              end
              return checkFunc(ns.ShouldOverrideBarShowManaBar)
            end,
            ToggleAutoCastPetAction = function()
              return checkFunc(ns.ToggleAutoCastPetAction)
            end,
          })
        end,
        C_AdventureJournal = function()
          local ns = _G.C_AdventureJournal
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            ActivateEntry = function()
              return checkFunc(ns.ActivateEntry)
            end,
            CanBeShown = function()
              return checkFunc(ns.CanBeShown)
            end,
            GetNumAvailableSuggestions = function()
              return checkFunc(ns.GetNumAvailableSuggestions)
            end,
            GetPrimaryOffset = function()
              return checkFunc(ns.GetPrimaryOffset)
            end,
            GetReward = function()
              return checkFunc(ns.GetReward)
            end,
            GetSuggestions = function()
              return checkFunc(ns.GetSuggestions)
            end,
            SetPrimaryOffset = function()
              return checkFunc(ns.SetPrimaryOffset)
            end,
            UpdateSuggestions = function()
              return checkFunc(ns.UpdateSuggestions)
            end,
          })
        end,
        C_AdventureMap = function()
          local ns = _G.C_AdventureMap
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            Close = function()
              return checkFunc(ns.Close)
            end,
            GetMapID = function()
              return checkFunc(ns.GetMapID)
            end,
            GetMapInsetDetailTileInfo = function()
              return checkFunc(ns.GetMapInsetDetailTileInfo)
            end,
            GetMapInsetInfo = function()
              return checkFunc(ns.GetMapInsetInfo)
            end,
            GetNumMapInsets = function()
              return checkFunc(ns.GetNumMapInsets)
            end,
            GetNumQuestOffers = function()
              return checkFunc(ns.GetNumQuestOffers)
            end,
            GetNumZoneChoices = function()
              return checkFunc(ns.GetNumZoneChoices)
            end,
            GetQuestInfo = function()
              return checkFunc(ns.GetQuestInfo)
            end,
            GetQuestOfferInfo = function()
              return checkFunc(ns.GetQuestOfferInfo)
            end,
            GetZoneChoiceInfo = function()
              return checkFunc(ns.GetZoneChoiceInfo)
            end,
            StartQuest = function()
              return checkFunc(ns.StartQuest)
            end,
          })
        end,
        C_AlliedRaces = function()
          local ns = _G.C_AlliedRaces
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            ClearAlliedRaceDetailsGiver = function()
              return checkFunc(ns.ClearAlliedRaceDetailsGiver)
            end,
            GetAllRacialAbilitiesFromID = function()
              return checkFunc(ns.GetAllRacialAbilitiesFromID)
            end,
            GetRaceInfoByID = function()
              return checkFunc(ns.GetRaceInfoByID)
            end,
          })
        end,
        C_AnimaDiversion = function()
          local ns = _G.C_AnimaDiversion
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            CloseUI = function()
              return checkFunc(ns.CloseUI)
            end,
            GetAnimaDiversionNodes = function()
              return checkFunc(ns.GetAnimaDiversionNodes)
            end,
            GetOriginPosition = function()
              return checkFunc(ns.GetOriginPosition)
            end,
            GetReinforceProgress = function()
              return checkFunc(ns.GetReinforceProgress)
            end,
            GetTextureKit = function()
              return checkFunc(ns.GetTextureKit)
            end,
            OpenAnimaDiversionUI = function()
              return checkFunc(ns.OpenAnimaDiversionUI)
            end,
            SelectAnimaNode = function()
              return checkFunc(ns.SelectAnimaNode)
            end,
          })
        end,
        C_ArdenwealdGardening = function()
          local ns = _G.C_ArdenwealdGardening
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetGardenData = function()
              return checkFunc(ns.GetGardenData)
            end,
            IsGardenAccessible = function()
              return checkFunc(ns.IsGardenAccessible)
            end,
          })
        end,
        C_AreaPoiInfo = function()
          local ns = _G.C_AreaPoiInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetAreaPOIForMap = function()
              return checkFunc(ns.GetAreaPOIForMap)
            end,
            GetAreaPOIInfo = function()
              return checkFunc(ns.GetAreaPOIInfo)
            end,
            GetAreaPOISecondsLeft = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetAreaPOISecondsLeft))
                return
              end
              return checkFunc(ns.GetAreaPOISecondsLeft)
            end,
            GetAreaPOITimeLeft = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetAreaPOITimeLeft))
                return
              end
              return checkFunc(ns.GetAreaPOITimeLeft)
            end,
            IsAreaPOITimed = function()
              return checkFunc(ns.IsAreaPOITimed)
            end,
          })
        end,
        C_ArtifactUI = function()
          local ns = _G.C_ArtifactUI
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            AddPower = function()
              return checkFunc(ns.AddPower)
            end,
            ApplyCursorRelicToSlot = function()
              return checkFunc(ns.ApplyCursorRelicToSlot)
            end,
            CanApplyArtifactRelic = function()
              return checkFunc(ns.CanApplyArtifactRelic)
            end,
            CanApplyCursorRelicToSlot = function()
              return checkFunc(ns.CanApplyCursorRelicToSlot)
            end,
            CanApplyRelicItemIDToEquippedArtifactSlot = function()
              return checkFunc(ns.CanApplyRelicItemIDToEquippedArtifactSlot)
            end,
            CanApplyRelicItemIDToSlot = function()
              return checkFunc(ns.CanApplyRelicItemIDToSlot)
            end,
            CheckRespecNPC = function()
              return checkFunc(ns.CheckRespecNPC)
            end,
            Clear = function()
              return checkFunc(ns.Clear)
            end,
            ClearForgeCamera = function()
              return checkFunc(ns.ClearForgeCamera)
            end,
            ConfirmRespec = function()
              return checkFunc(ns.ConfirmRespec)
            end,
            DoesEquippedArtifactHaveAnyRelicsSlotted = function()
              return checkFunc(ns.DoesEquippedArtifactHaveAnyRelicsSlotted)
            end,
            GetAppearanceInfo = function()
              return checkFunc(ns.GetAppearanceInfo)
            end,
            GetAppearanceInfoByID = function()
              return checkFunc(ns.GetAppearanceInfoByID)
            end,
            GetAppearanceSetInfo = function()
              return checkFunc(ns.GetAppearanceSetInfo)
            end,
            GetArtifactArtInfo = function()
              return checkFunc(ns.GetArtifactArtInfo)
            end,
            GetArtifactInfo = function()
              return checkFunc(ns.GetArtifactInfo)
            end,
            GetArtifactItemID = function()
              return checkFunc(ns.GetArtifactItemID)
            end,
            GetArtifactTier = function()
              return checkFunc(ns.GetArtifactTier)
            end,
            GetArtifactXPRewardTargetInfo = function()
              return checkFunc(ns.GetArtifactXPRewardTargetInfo)
            end,
            GetCostForPointAtRank = function()
              return checkFunc(ns.GetCostForPointAtRank)
            end,
            GetEquippedArtifactArtInfo = function()
              return checkFunc(ns.GetEquippedArtifactArtInfo)
            end,
            GetEquippedArtifactInfo = function()
              return checkFunc(ns.GetEquippedArtifactInfo)
            end,
            GetEquippedArtifactItemID = function()
              return checkFunc(ns.GetEquippedArtifactItemID)
            end,
            GetEquippedArtifactNumRelicSlots = function()
              return checkFunc(ns.GetEquippedArtifactNumRelicSlots)
            end,
            GetEquippedArtifactRelicInfo = function()
              return checkFunc(ns.GetEquippedArtifactRelicInfo)
            end,
            GetEquippedRelicLockedReason = function()
              return checkFunc(ns.GetEquippedRelicLockedReason)
            end,
            GetForgeRotation = function()
              return checkFunc(ns.GetForgeRotation)
            end,
            GetItemLevelIncreaseProvidedByRelic = function()
              return checkFunc(ns.GetItemLevelIncreaseProvidedByRelic)
            end,
            GetMetaPowerInfo = function()
              return checkFunc(ns.GetMetaPowerInfo)
            end,
            GetNumAppearanceSets = function()
              return checkFunc(ns.GetNumAppearanceSets)
            end,
            GetNumObtainedArtifacts = function()
              return checkFunc(ns.GetNumObtainedArtifacts)
            end,
            GetNumRelicSlots = function()
              return checkFunc(ns.GetNumRelicSlots)
            end,
            GetPointsRemaining = function()
              return checkFunc(ns.GetPointsRemaining)
            end,
            GetPowerHyperlink = function()
              return checkFunc(ns.GetPowerHyperlink)
            end,
            GetPowerInfo = function()
              return checkFunc(ns.GetPowerInfo)
            end,
            GetPowerLinks = function()
              return checkFunc(ns.GetPowerLinks)
            end,
            GetPowers = function()
              return checkFunc(ns.GetPowers)
            end,
            GetPowersAffectedByRelic = function()
              return checkFunc(ns.GetPowersAffectedByRelic)
            end,
            GetPowersAffectedByRelicItemLink = function()
              return checkFunc(ns.GetPowersAffectedByRelicItemLink)
            end,
            GetPreviewAppearance = function()
              return checkFunc(ns.GetPreviewAppearance)
            end,
            GetRelicInfo = function()
              return checkFunc(ns.GetRelicInfo)
            end,
            GetRelicInfoByItemID = function()
              return checkFunc(ns.GetRelicInfoByItemID)
            end,
            GetRelicLockedReason = function()
              return checkFunc(ns.GetRelicLockedReason)
            end,
            GetRelicSlotType = function()
              return checkFunc(ns.GetRelicSlotType)
            end,
            GetRespecArtifactArtInfo = function()
              return checkFunc(ns.GetRespecArtifactArtInfo)
            end,
            GetRespecArtifactInfo = function()
              return checkFunc(ns.GetRespecArtifactInfo)
            end,
            GetRespecCost = function()
              return checkFunc(ns.GetRespecCost)
            end,
            GetTotalPowerCost = function()
              return checkFunc(ns.GetTotalPowerCost)
            end,
            GetTotalPurchasedRanks = function()
              return checkFunc(ns.GetTotalPurchasedRanks)
            end,
            IsArtifactDisabled = function()
              return checkFunc(ns.IsArtifactDisabled)
            end,
            IsAtForge = function()
              return checkFunc(ns.IsAtForge)
            end,
            IsEquippedArtifactDisabled = function()
              return checkFunc(ns.IsEquippedArtifactDisabled)
            end,
            IsEquippedArtifactMaxed = function()
              return checkFunc(ns.IsEquippedArtifactMaxed)
            end,
            IsMaxedByRulesOrEffect = function()
              return checkFunc(ns.IsMaxedByRulesOrEffect)
            end,
            IsPowerKnown = function()
              return checkFunc(ns.IsPowerKnown)
            end,
            IsViewedArtifactEquipped = function()
              return checkFunc(ns.IsViewedArtifactEquipped)
            end,
            SetAppearance = function()
              return checkFunc(ns.SetAppearance)
            end,
            SetForgeCamera = function()
              return checkFunc(ns.SetForgeCamera)
            end,
            SetForgeRotation = function()
              return checkFunc(ns.SetForgeRotation)
            end,
            SetPreviewAppearance = function()
              return checkFunc(ns.SetPreviewAppearance)
            end,
            ShouldSuppressForgeRotation = function()
              return checkFunc(ns.ShouldSuppressForgeRotation)
            end,
          })
        end,
        C_AuctionHouse = function()
          local ns = _G.C_AuctionHouse
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            CalculateCommodityDeposit = function()
              return checkFunc(ns.CalculateCommodityDeposit)
            end,
            CalculateItemDeposit = function()
              return checkFunc(ns.CalculateItemDeposit)
            end,
            CanCancelAuction = function()
              return checkFunc(ns.CanCancelAuction)
            end,
            CancelAuction = function()
              return checkFunc(ns.CancelAuction)
            end,
            CancelCommoditiesPurchase = function()
              return checkFunc(ns.CancelCommoditiesPurchase)
            end,
            CancelSell = function()
              return checkFunc(ns.CancelSell)
            end,
            CloseAuctionHouse = function()
              return checkFunc(ns.CloseAuctionHouse)
            end,
            ConfirmCommoditiesPurchase = function()
              return checkFunc(ns.ConfirmCommoditiesPurchase)
            end,
            FavoritesAreAvailable = function()
              return checkFunc(ns.FavoritesAreAvailable)
            end,
            GetAuctionInfoByID = function()
              return checkFunc(ns.GetAuctionInfoByID)
            end,
            GetAuctionItemSubClasses = function()
              return checkFunc(ns.GetAuctionItemSubClasses)
            end,
            GetAvailablePostCount = function()
              return checkFunc(ns.GetAvailablePostCount)
            end,
            GetBidInfo = function()
              return checkFunc(ns.GetBidInfo)
            end,
            GetBidType = function()
              return checkFunc(ns.GetBidType)
            end,
            GetBids = function()
              return checkFunc(ns.GetBids)
            end,
            GetBrowseResults = function()
              return checkFunc(ns.GetBrowseResults)
            end,
            GetCancelCost = function()
              return checkFunc(ns.GetCancelCost)
            end,
            GetCommoditySearchResultInfo = function()
              return checkFunc(ns.GetCommoditySearchResultInfo)
            end,
            GetCommoditySearchResultsQuantity = function()
              return checkFunc(ns.GetCommoditySearchResultsQuantity)
            end,
            GetExtraBrowseInfo = function()
              return checkFunc(ns.GetExtraBrowseInfo)
            end,
            GetFilterGroups = function()
              return checkFunc(ns.GetFilterGroups)
            end,
            GetItemCommodityStatus = function()
              return checkFunc(ns.GetItemCommodityStatus)
            end,
            GetItemKeyFromItem = function()
              return checkFunc(ns.GetItemKeyFromItem)
            end,
            GetItemKeyInfo = function()
              return checkFunc(ns.GetItemKeyInfo)
            end,
            GetItemKeyRequiredLevel = function()
              return checkFunc(ns.GetItemKeyRequiredLevel)
            end,
            GetItemSearchResultInfo = function()
              return checkFunc(ns.GetItemSearchResultInfo)
            end,
            GetItemSearchResultsQuantity = function()
              return checkFunc(ns.GetItemSearchResultsQuantity)
            end,
            GetMaxBidItemBid = function()
              return checkFunc(ns.GetMaxBidItemBid)
            end,
            GetMaxBidItemBuyout = function()
              return checkFunc(ns.GetMaxBidItemBuyout)
            end,
            GetMaxCommoditySearchResultPrice = function()
              return checkFunc(ns.GetMaxCommoditySearchResultPrice)
            end,
            GetMaxItemSearchResultBid = function()
              return checkFunc(ns.GetMaxItemSearchResultBid)
            end,
            GetMaxItemSearchResultBuyout = function()
              return checkFunc(ns.GetMaxItemSearchResultBuyout)
            end,
            GetMaxOwnedAuctionBid = function()
              return checkFunc(ns.GetMaxOwnedAuctionBid)
            end,
            GetMaxOwnedAuctionBuyout = function()
              return checkFunc(ns.GetMaxOwnedAuctionBuyout)
            end,
            GetNumBidTypes = function()
              return checkFunc(ns.GetNumBidTypes)
            end,
            GetNumBids = function()
              return checkFunc(ns.GetNumBids)
            end,
            GetNumCommoditySearchResults = function()
              return checkFunc(ns.GetNumCommoditySearchResults)
            end,
            GetNumItemSearchResults = function()
              return checkFunc(ns.GetNumItemSearchResults)
            end,
            GetNumOwnedAuctionTypes = function()
              return checkFunc(ns.GetNumOwnedAuctionTypes)
            end,
            GetNumOwnedAuctions = function()
              return checkFunc(ns.GetNumOwnedAuctions)
            end,
            GetNumReplicateItems = function()
              return checkFunc(ns.GetNumReplicateItems)
            end,
            GetOwnedAuctionInfo = function()
              return checkFunc(ns.GetOwnedAuctionInfo)
            end,
            GetOwnedAuctionType = function()
              return checkFunc(ns.GetOwnedAuctionType)
            end,
            GetOwnedAuctions = function()
              return checkFunc(ns.GetOwnedAuctions)
            end,
            GetQuoteDurationRemaining = function()
              return checkFunc(ns.GetQuoteDurationRemaining)
            end,
            GetReplicateItemBattlePetInfo = function()
              return checkFunc(ns.GetReplicateItemBattlePetInfo)
            end,
            GetReplicateItemInfo = function()
              return checkFunc(ns.GetReplicateItemInfo)
            end,
            GetReplicateItemLink = function()
              return checkFunc(ns.GetReplicateItemLink)
            end,
            GetReplicateItemTimeLeft = function()
              return checkFunc(ns.GetReplicateItemTimeLeft)
            end,
            GetTimeLeftBandInfo = function()
              return checkFunc(ns.GetTimeLeftBandInfo)
            end,
            HasFavorites = function()
              return checkFunc(ns.HasFavorites)
            end,
            HasFullBidResults = function()
              return checkFunc(ns.HasFullBidResults)
            end,
            HasFullBrowseResults = function()
              return checkFunc(ns.HasFullBrowseResults)
            end,
            HasFullCommoditySearchResults = function()
              return checkFunc(ns.HasFullCommoditySearchResults)
            end,
            HasFullItemSearchResults = function()
              return checkFunc(ns.HasFullItemSearchResults)
            end,
            HasFullOwnedAuctionResults = function()
              return checkFunc(ns.HasFullOwnedAuctionResults)
            end,
            HasMaxFavorites = function()
              return checkFunc(ns.HasMaxFavorites)
            end,
            HasSearchResults = function()
              return checkFunc(ns.HasSearchResults)
            end,
            IsFavoriteItem = function()
              return checkFunc(ns.IsFavoriteItem)
            end,
            IsSellItemValid = function()
              return checkFunc(ns.IsSellItemValid)
            end,
            IsThrottledMessageSystemReady = function()
              return checkFunc(ns.IsThrottledMessageSystemReady)
            end,
            MakeItemKey = function()
              return checkFunc(ns.MakeItemKey)
            end,
            PlaceBid = function()
              return checkFunc(ns.PlaceBid)
            end,
            PostCommodity = function()
              return checkFunc(ns.PostCommodity)
            end,
            PostItem = function()
              return checkFunc(ns.PostItem)
            end,
            QueryBids = function()
              return checkFunc(ns.QueryBids)
            end,
            QueryOwnedAuctions = function()
              return checkFunc(ns.QueryOwnedAuctions)
            end,
            RefreshCommoditySearchResults = function()
              return checkFunc(ns.RefreshCommoditySearchResults)
            end,
            RefreshItemSearchResults = function()
              return checkFunc(ns.RefreshItemSearchResults)
            end,
            ReplicateItems = function()
              return checkFunc(ns.ReplicateItems)
            end,
            RequestFavorites = function()
              return checkFunc(ns.RequestFavorites)
            end,
            RequestMoreBrowseResults = function()
              return checkFunc(ns.RequestMoreBrowseResults)
            end,
            RequestMoreCommoditySearchResults = function()
              return checkFunc(ns.RequestMoreCommoditySearchResults)
            end,
            RequestMoreItemSearchResults = function()
              return checkFunc(ns.RequestMoreItemSearchResults)
            end,
            RequestOwnedAuctionBidderInfo = function()
              return checkFunc(ns.RequestOwnedAuctionBidderInfo)
            end,
            SearchForFavorites = function()
              return checkFunc(ns.SearchForFavorites)
            end,
            SearchForItemKeys = function()
              return checkFunc(ns.SearchForItemKeys)
            end,
            SendBrowseQuery = function()
              return checkFunc(ns.SendBrowseQuery)
            end,
            SendSearchQuery = function()
              return checkFunc(ns.SendSearchQuery)
            end,
            SendSellSearchQuery = function()
              return checkFunc(ns.SendSellSearchQuery)
            end,
            SetFavoriteItem = function()
              return checkFunc(ns.SetFavoriteItem)
            end,
            StartCommoditiesPurchase = function()
              return checkFunc(ns.StartCommoditiesPurchase)
            end,
          })
        end,
        C_AzeriteEmpoweredItem = function()
          local ns = _G.C_AzeriteEmpoweredItem
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            CanSelectPower = function()
              return checkFunc(ns.CanSelectPower)
            end,
            CloseAzeriteEmpoweredItemRespec = function()
              return checkFunc(ns.CloseAzeriteEmpoweredItemRespec)
            end,
            ConfirmAzeriteEmpoweredItemRespec = function()
              return checkFunc(ns.ConfirmAzeriteEmpoweredItemRespec)
            end,
            GetAllTierInfo = function()
              return checkFunc(ns.GetAllTierInfo)
            end,
            GetAllTierInfoByItemID = function()
              return checkFunc(ns.GetAllTierInfoByItemID)
            end,
            GetAzeriteEmpoweredItemRespecCost = function()
              return checkFunc(ns.GetAzeriteEmpoweredItemRespecCost)
            end,
            GetPowerInfo = function()
              return checkFunc(ns.GetPowerInfo)
            end,
            GetPowerText = function()
              return checkFunc(ns.GetPowerText)
            end,
            GetSpecsForPower = function()
              return checkFunc(ns.GetSpecsForPower)
            end,
            HasAnyUnselectedPowers = function()
              return checkFunc(ns.HasAnyUnselectedPowers)
            end,
            HasBeenViewed = function()
              return checkFunc(ns.HasBeenViewed)
            end,
            IsAzeriteEmpoweredItem = function()
              return checkFunc(ns.IsAzeriteEmpoweredItem)
            end,
            IsAzeriteEmpoweredItemByID = function()
              return checkFunc(ns.IsAzeriteEmpoweredItemByID)
            end,
            IsAzeritePreviewSourceDisplayable = function()
              return checkFunc(ns.IsAzeritePreviewSourceDisplayable)
            end,
            IsHeartOfAzerothEquipped = function()
              return checkFunc(ns.IsHeartOfAzerothEquipped)
            end,
            IsPowerAvailableForSpec = function()
              return checkFunc(ns.IsPowerAvailableForSpec)
            end,
            IsPowerSelected = function()
              return checkFunc(ns.IsPowerSelected)
            end,
            SelectPower = function()
              return checkFunc(ns.SelectPower)
            end,
            SetHasBeenViewed = function()
              return checkFunc(ns.SetHasBeenViewed)
            end,
          })
        end,
        C_AzeriteEssence = function()
          local ns = _G.C_AzeriteEssence
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            ActivateEssence = function()
              return checkFunc(ns.ActivateEssence)
            end,
            CanActivateEssence = function()
              return checkFunc(ns.CanActivateEssence)
            end,
            CanDeactivateEssence = function()
              return checkFunc(ns.CanDeactivateEssence)
            end,
            CanOpenUI = function()
              return checkFunc(ns.CanOpenUI)
            end,
            ClearPendingActivationEssence = function()
              return checkFunc(ns.ClearPendingActivationEssence)
            end,
            CloseForge = function()
              return checkFunc(ns.CloseForge)
            end,
            GetEssenceHyperlink = function()
              return checkFunc(ns.GetEssenceHyperlink)
            end,
            GetEssenceInfo = function()
              return checkFunc(ns.GetEssenceInfo)
            end,
            GetEssences = function()
              return checkFunc(ns.GetEssences)
            end,
            GetMilestoneEssence = function()
              return checkFunc(ns.GetMilestoneEssence)
            end,
            GetMilestoneInfo = function()
              return checkFunc(ns.GetMilestoneInfo)
            end,
            GetMilestoneSpell = function()
              return checkFunc(ns.GetMilestoneSpell)
            end,
            GetMilestones = function()
              return checkFunc(ns.GetMilestones)
            end,
            GetNumUnlockedEssences = function()
              return checkFunc(ns.GetNumUnlockedEssences)
            end,
            GetNumUsableEssences = function()
              return checkFunc(ns.GetNumUsableEssences)
            end,
            GetPendingActivationEssence = function()
              return checkFunc(ns.GetPendingActivationEssence)
            end,
            HasNeverActivatedAnyEssences = function()
              return checkFunc(ns.HasNeverActivatedAnyEssences)
            end,
            HasPendingActivationEssence = function()
              return checkFunc(ns.HasPendingActivationEssence)
            end,
            IsAtForge = function()
              return checkFunc(ns.IsAtForge)
            end,
            SetPendingActivationEssence = function()
              return checkFunc(ns.SetPendingActivationEssence)
            end,
            UnlockMilestone = function()
              return checkFunc(ns.UnlockMilestone)
            end,
          })
        end,
        C_AzeriteItem = function()
          local ns = _G.C_AzeriteItem
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            FindActiveAzeriteItem = function()
              return checkFunc(ns.FindActiveAzeriteItem)
            end,
            GetAzeriteItemXPInfo = function()
              return checkFunc(ns.GetAzeriteItemXPInfo)
            end,
            GetPowerLevel = function()
              return checkFunc(ns.GetPowerLevel)
            end,
            GetUnlimitedPowerLevel = function()
              return checkFunc(ns.GetUnlimitedPowerLevel)
            end,
            HasActiveAzeriteItem = function()
              return checkFunc(ns.HasActiveAzeriteItem)
            end,
            IsAzeriteItem = function()
              return checkFunc(ns.IsAzeriteItem)
            end,
            IsAzeriteItemAtMaxLevel = function()
              return checkFunc(ns.IsAzeriteItemAtMaxLevel)
            end,
            IsAzeriteItemByID = function()
              return checkFunc(ns.IsAzeriteItemByID)
            end,
            IsAzeriteItemEnabled = function()
              return checkFunc(ns.IsAzeriteItemEnabled)
            end,
          })
        end,
        C_BarberShop = function()
          local ns = _G.C_BarberShop
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            ApplyCustomizationChoices = function()
              return checkFunc(ns.ApplyCustomizationChoices)
            end,
            Cancel = function()
              return checkFunc(ns.Cancel)
            end,
            ClearPreviewChoices = function()
              return checkFunc(ns.ClearPreviewChoices)
            end,
            GetAvailableCustomizations = function()
              return checkFunc(ns.GetAvailableCustomizations)
            end,
            GetCurrentCameraZoom = function()
              return checkFunc(ns.GetCurrentCameraZoom)
            end,
            GetCurrentCharacterData = function()
              return checkFunc(ns.GetCurrentCharacterData)
            end,
            GetCurrentCost = function()
              return checkFunc(ns.GetCurrentCost)
            end,
            HasAnyChanges = function()
              return checkFunc(ns.HasAnyChanges)
            end,
            IsViewingAlteredForm = function()
              return checkFunc(ns.IsViewingAlteredForm)
            end,
            MarkCustomizationChoiceAsSeen = function()
              return checkFunc(ns.MarkCustomizationChoiceAsSeen)
            end,
            MarkCustomizationOptionAsSeen = function()
              return checkFunc(ns.MarkCustomizationOptionAsSeen)
            end,
            PreviewCustomizationChoice = function()
              return checkFunc(ns.PreviewCustomizationChoice)
            end,
            RandomizeCustomizationChoices = function()
              return checkFunc(ns.RandomizeCustomizationChoices)
            end,
            ResetCameraRotation = function()
              return checkFunc(ns.ResetCameraRotation)
            end,
            ResetCustomizationChoices = function()
              return checkFunc(ns.ResetCustomizationChoices)
            end,
            RotateCamera = function()
              return checkFunc(ns.RotateCamera)
            end,
            SaveSeenChoices = function()
              return checkFunc(ns.SaveSeenChoices)
            end,
            SetCameraDistanceOffset = function()
              return checkFunc(ns.SetCameraDistanceOffset)
            end,
            SetCameraZoomLevel = function()
              return checkFunc(ns.SetCameraZoomLevel)
            end,
            SetCustomizationChoice = function()
              return checkFunc(ns.SetCustomizationChoice)
            end,
            SetModelDressState = function()
              return checkFunc(ns.SetModelDressState)
            end,
            SetSelectedSex = function()
              return checkFunc(ns.SetSelectedSex)
            end,
            SetViewingAlteredForm = function()
              return checkFunc(ns.SetViewingAlteredForm)
            end,
            SetViewingShapeshiftForm = function()
              return checkFunc(ns.SetViewingShapeshiftForm)
            end,
            ZoomCamera = function()
              return checkFunc(ns.ZoomCamera)
            end,
          })
        end,
        C_BattleNet = function()
          local ns = _G.C_BattleNet
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetAccountInfoByGUID = function()
              return checkFunc(ns.GetAccountInfoByGUID)
            end,
            GetAccountInfoByID = function()
              return checkFunc(ns.GetAccountInfoByID)
            end,
            GetFriendAccountInfo = function()
              return checkFunc(ns.GetFriendAccountInfo)
            end,
            GetFriendGameAccountInfo = function()
              return checkFunc(ns.GetFriendGameAccountInfo)
            end,
            GetFriendNumGameAccounts = function()
              return checkFunc(ns.GetFriendNumGameAccounts)
            end,
            GetGameAccountInfoByGUID = function()
              return checkFunc(ns.GetGameAccountInfoByGUID)
            end,
            GetGameAccountInfoByID = function()
              return checkFunc(ns.GetGameAccountInfoByID)
            end,
          })
        end,
        C_BehavioralMessaging = function()
          local ns = _G.C_BehavioralMessaging
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            SendNotificationReceipt = function()
              return checkFunc(ns.SendNotificationReceipt)
            end,
          })
        end,
        C_BlackMarket = function()
          local ns = _G.C_BlackMarket
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            Close = function()
              return checkFunc(ns.Close)
            end,
            GetHotItem = function()
              return checkFunc(ns.GetHotItem)
            end,
            GetItemInfoByID = function()
              return checkFunc(ns.GetItemInfoByID)
            end,
            GetItemInfoByIndex = function()
              return checkFunc(ns.GetItemInfoByIndex)
            end,
            GetNumItems = function()
              return checkFunc(ns.GetNumItems)
            end,
            IsViewOnly = function()
              return checkFunc(ns.IsViewOnly)
            end,
            ItemPlaceBid = function()
              return checkFunc(ns.ItemPlaceBid)
            end,
            RequestItems = function()
              return checkFunc(ns.RequestItems)
            end,
          })
        end,
        C_CVar = function()
          local ns = _G.C_CVar
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetCVar = function()
              return checkFunc(ns.GetCVar)
            end,
            GetCVarBitfield = function()
              return checkFunc(ns.GetCVarBitfield)
            end,
            GetCVarBool = function()
              return checkFunc(ns.GetCVarBool)
            end,
            GetCVarDefault = function()
              return checkFunc(ns.GetCVarDefault)
            end,
            RegisterCVar = function()
              return checkFunc(ns.RegisterCVar)
            end,
            ResetTestCVars = function()
              return checkFunc(ns.ResetTestCVars)
            end,
            SetCVar = function()
              return checkFunc(ns.SetCVar)
            end,
            SetCVarBitfield = function()
              return checkFunc(ns.SetCVarBitfield)
            end,
          })
        end,
        C_Calendar = function()
          local ns = _G.C_Calendar
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            AddEvent = function()
              return checkFunc(ns.AddEvent)
            end,
            AreNamesReady = function()
              return checkFunc(ns.AreNamesReady)
            end,
            CanAddEvent = function()
              return checkFunc(ns.CanAddEvent)
            end,
            CanSendInvite = function()
              return checkFunc(ns.CanSendInvite)
            end,
            CloseEvent = function()
              return checkFunc(ns.CloseEvent)
            end,
            ContextMenuEventCanComplain = function()
              return checkFunc(ns.ContextMenuEventCanComplain)
            end,
            ContextMenuEventCanEdit = function()
              return checkFunc(ns.ContextMenuEventCanEdit)
            end,
            ContextMenuEventCanRemove = function()
              return checkFunc(ns.ContextMenuEventCanRemove)
            end,
            ContextMenuEventClipboard = function()
              return checkFunc(ns.ContextMenuEventClipboard)
            end,
            ContextMenuEventComplain = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ContextMenuEventComplain))
                return
              end
              return checkFunc(ns.ContextMenuEventComplain)
            end,
            ContextMenuEventCopy = function()
              return checkFunc(ns.ContextMenuEventCopy)
            end,
            ContextMenuEventGetCalendarType = function()
              return checkFunc(ns.ContextMenuEventGetCalendarType)
            end,
            ContextMenuEventPaste = function()
              return checkFunc(ns.ContextMenuEventPaste)
            end,
            ContextMenuEventRemove = function()
              return checkFunc(ns.ContextMenuEventRemove)
            end,
            ContextMenuEventSignUp = function()
              return checkFunc(ns.ContextMenuEventSignUp)
            end,
            ContextMenuGetEventIndex = function()
              return checkFunc(ns.ContextMenuGetEventIndex)
            end,
            ContextMenuInviteAvailable = function()
              return checkFunc(ns.ContextMenuInviteAvailable)
            end,
            ContextMenuInviteDecline = function()
              return checkFunc(ns.ContextMenuInviteDecline)
            end,
            ContextMenuInviteRemove = function()
              return checkFunc(ns.ContextMenuInviteRemove)
            end,
            ContextMenuInviteTentative = function()
              return checkFunc(ns.ContextMenuInviteTentative)
            end,
            ContextMenuSelectEvent = function()
              return checkFunc(ns.ContextMenuSelectEvent)
            end,
            CreateCommunitySignUpEvent = function()
              return checkFunc(ns.CreateCommunitySignUpEvent)
            end,
            CreateGuildAnnouncementEvent = function()
              return checkFunc(ns.CreateGuildAnnouncementEvent)
            end,
            CreateGuildSignUpEvent = function()
              return checkFunc(ns.CreateGuildSignUpEvent)
            end,
            CreatePlayerEvent = function()
              return checkFunc(ns.CreatePlayerEvent)
            end,
            EventAvailable = function()
              return checkFunc(ns.EventAvailable)
            end,
            EventCanEdit = function()
              return checkFunc(ns.EventCanEdit)
            end,
            EventClearAutoApprove = function()
              return checkFunc(ns.EventClearAutoApprove)
            end,
            EventClearLocked = function()
              return checkFunc(ns.EventClearLocked)
            end,
            EventClearModerator = function()
              return checkFunc(ns.EventClearModerator)
            end,
            EventDecline = function()
              return checkFunc(ns.EventDecline)
            end,
            EventGetCalendarType = function()
              return checkFunc(ns.EventGetCalendarType)
            end,
            EventGetClubId = function()
              return checkFunc(ns.EventGetClubId)
            end,
            EventGetInvite = function()
              return checkFunc(ns.EventGetInvite)
            end,
            EventGetInviteResponseTime = function()
              return checkFunc(ns.EventGetInviteResponseTime)
            end,
            EventGetInviteSortCriterion = function()
              return checkFunc(ns.EventGetInviteSortCriterion)
            end,
            EventGetSelectedInvite = function()
              return checkFunc(ns.EventGetSelectedInvite)
            end,
            EventGetStatusOptions = function()
              return checkFunc(ns.EventGetStatusOptions)
            end,
            EventGetTextures = function()
              return checkFunc(ns.EventGetTextures)
            end,
            EventGetTypes = function()
              return checkFunc(ns.EventGetTypes)
            end,
            EventGetTypesDisplayOrdered = function()
              return checkFunc(ns.EventGetTypesDisplayOrdered)
            end,
            EventHasPendingInvite = function()
              return checkFunc(ns.EventHasPendingInvite)
            end,
            EventHaveSettingsChanged = function()
              return checkFunc(ns.EventHaveSettingsChanged)
            end,
            EventInvite = function()
              return checkFunc(ns.EventInvite)
            end,
            EventRemoveInvite = function()
              return checkFunc(ns.EventRemoveInvite)
            end,
            EventRemoveInviteByGuid = function()
              return checkFunc(ns.EventRemoveInviteByGuid)
            end,
            EventSelectInvite = function()
              return checkFunc(ns.EventSelectInvite)
            end,
            EventSetAutoApprove = function()
              return checkFunc(ns.EventSetAutoApprove)
            end,
            EventSetClubId = function()
              return checkFunc(ns.EventSetClubId)
            end,
            EventSetDate = function()
              return checkFunc(ns.EventSetDate)
            end,
            EventSetDescription = function()
              return checkFunc(ns.EventSetDescription)
            end,
            EventSetInviteStatus = function()
              return checkFunc(ns.EventSetInviteStatus)
            end,
            EventSetLocked = function()
              return checkFunc(ns.EventSetLocked)
            end,
            EventSetModerator = function()
              return checkFunc(ns.EventSetModerator)
            end,
            EventSetTextureID = function()
              return checkFunc(ns.EventSetTextureID)
            end,
            EventSetTime = function()
              return checkFunc(ns.EventSetTime)
            end,
            EventSetTitle = function()
              return checkFunc(ns.EventSetTitle)
            end,
            EventSetType = function()
              return checkFunc(ns.EventSetType)
            end,
            EventSignUp = function()
              return checkFunc(ns.EventSignUp)
            end,
            EventSortInvites = function()
              return checkFunc(ns.EventSortInvites)
            end,
            EventTentative = function()
              return checkFunc(ns.EventTentative)
            end,
            GetClubCalendarEvents = function()
              return checkFunc(ns.GetClubCalendarEvents)
            end,
            GetDayEvent = function()
              return checkFunc(ns.GetDayEvent)
            end,
            GetDefaultGuildFilter = function()
              return checkFunc(ns.GetDefaultGuildFilter)
            end,
            GetEventIndex = function()
              return checkFunc(ns.GetEventIndex)
            end,
            GetEventIndexInfo = function()
              return checkFunc(ns.GetEventIndexInfo)
            end,
            GetEventInfo = function()
              return checkFunc(ns.GetEventInfo)
            end,
            GetFirstPendingInvite = function()
              return checkFunc(ns.GetFirstPendingInvite)
            end,
            GetGuildEventInfo = function()
              return checkFunc(ns.GetGuildEventInfo)
            end,
            GetGuildEventSelectionInfo = function()
              return checkFunc(ns.GetGuildEventSelectionInfo)
            end,
            GetHolidayInfo = function()
              return checkFunc(ns.GetHolidayInfo)
            end,
            GetMaxCreateDate = function()
              return checkFunc(ns.GetMaxCreateDate)
            end,
            GetMinDate = function()
              return checkFunc(ns.GetMinDate)
            end,
            GetMonthInfo = function()
              return checkFunc(ns.GetMonthInfo)
            end,
            GetNextClubId = function()
              return checkFunc(ns.GetNextClubId)
            end,
            GetNumDayEvents = function()
              return checkFunc(ns.GetNumDayEvents)
            end,
            GetNumGuildEvents = function()
              return checkFunc(ns.GetNumGuildEvents)
            end,
            GetNumInvites = function()
              return checkFunc(ns.GetNumInvites)
            end,
            GetNumPendingInvites = function()
              return checkFunc(ns.GetNumPendingInvites)
            end,
            GetRaidInfo = function()
              return checkFunc(ns.GetRaidInfo)
            end,
            IsActionPending = function()
              return checkFunc(ns.IsActionPending)
            end,
            IsEventOpen = function()
              return checkFunc(ns.IsEventOpen)
            end,
            MassInviteCommunity = function()
              return checkFunc(ns.MassInviteCommunity)
            end,
            MassInviteGuild = function()
              return checkFunc(ns.MassInviteGuild)
            end,
            OpenCalendar = function()
              return checkFunc(ns.OpenCalendar)
            end,
            OpenEvent = function()
              return checkFunc(ns.OpenEvent)
            end,
            RemoveEvent = function()
              return checkFunc(ns.RemoveEvent)
            end,
            SetAbsMonth = function()
              return checkFunc(ns.SetAbsMonth)
            end,
            SetMonth = function()
              return checkFunc(ns.SetMonth)
            end,
            SetNextClubId = function()
              return checkFunc(ns.SetNextClubId)
            end,
            UpdateEvent = function()
              return checkFunc(ns.UpdateEvent)
            end,
          })
        end,
        C_CampaignInfo = function()
          local ns = _G.C_CampaignInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetAvailableCampaigns = function()
              return checkFunc(ns.GetAvailableCampaigns)
            end,
            GetCampaignChapterInfo = function()
              return checkFunc(ns.GetCampaignChapterInfo)
            end,
            GetCampaignID = function()
              return checkFunc(ns.GetCampaignID)
            end,
            GetCampaignInfo = function()
              return checkFunc(ns.GetCampaignInfo)
            end,
            GetChapterIDs = function()
              return checkFunc(ns.GetChapterIDs)
            end,
            GetCurrentChapterID = function()
              return checkFunc(ns.GetCurrentChapterID)
            end,
            GetFailureReason = function()
              return checkFunc(ns.GetFailureReason)
            end,
            GetState = function()
              return checkFunc(ns.GetState)
            end,
            IsCampaignQuest = function()
              return checkFunc(ns.IsCampaignQuest)
            end,
            UsesNormalQuestIcons = function()
              return checkFunc(ns.UsesNormalQuestIcons)
            end,
          })
        end,
        C_ChallengeMode = function()
          local ns = _G.C_ChallengeMode
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            CanUseKeystoneInCurrentMap = function()
              return checkFunc(ns.CanUseKeystoneInCurrentMap)
            end,
            ClearKeystone = function()
              return checkFunc(ns.ClearKeystone)
            end,
            CloseKeystoneFrame = function()
              return checkFunc(ns.CloseKeystoneFrame)
            end,
            GetActiveChallengeMapID = function()
              return checkFunc(ns.GetActiveChallengeMapID)
            end,
            GetActiveKeystoneInfo = function()
              return checkFunc(ns.GetActiveKeystoneInfo)
            end,
            GetAffixInfo = function()
              return checkFunc(ns.GetAffixInfo)
            end,
            GetCompletionInfo = function()
              return checkFunc(ns.GetCompletionInfo)
            end,
            GetDeathCount = function()
              return checkFunc(ns.GetDeathCount)
            end,
            GetDungeonScoreRarityColor = function()
              return checkFunc(ns.GetDungeonScoreRarityColor)
            end,
            GetGuildLeaders = function()
              return checkFunc(ns.GetGuildLeaders)
            end,
            GetKeystoneLevelRarityColor = function()
              return checkFunc(ns.GetKeystoneLevelRarityColor)
            end,
            GetMapScoreInfo = function()
              return checkFunc(ns.GetMapScoreInfo)
            end,
            GetMapTable = function()
              return checkFunc(ns.GetMapTable)
            end,
            GetMapUIInfo = function()
              return checkFunc(ns.GetMapUIInfo)
            end,
            GetOverallDungeonScore = function()
              return checkFunc(ns.GetOverallDungeonScore)
            end,
            GetPowerLevelDamageHealthMod = function()
              return checkFunc(ns.GetPowerLevelDamageHealthMod)
            end,
            GetSlottedKeystoneInfo = function()
              return checkFunc(ns.GetSlottedKeystoneInfo)
            end,
            GetSpecificDungeonOverallScoreRarityColor = function()
              return checkFunc(ns.GetSpecificDungeonOverallScoreRarityColor)
            end,
            GetSpecificDungeonScoreRarityColor = function()
              return checkFunc(ns.GetSpecificDungeonScoreRarityColor)
            end,
            HasSlottedKeystone = function()
              return checkFunc(ns.HasSlottedKeystone)
            end,
            IsChallengeModeActive = function()
              return checkFunc(ns.IsChallengeModeActive)
            end,
            RemoveKeystone = function()
              return checkFunc(ns.RemoveKeystone)
            end,
            RequestLeaders = function()
              return checkFunc(ns.RequestLeaders)
            end,
            Reset = function()
              return checkFunc(ns.Reset)
            end,
            SetKeystoneTooltip = function()
              return checkFunc(ns.SetKeystoneTooltip)
            end,
            SlotKeystone = function()
              return checkFunc(ns.SlotKeystone)
            end,
            StartChallengeMode = function()
              return checkFunc(ns.StartChallengeMode)
            end,
          })
        end,
        C_CharacterServices = function()
          local ns = _G.C_CharacterServices
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            AssignPCTDistribution = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.AssignPCTDistribution))
                return
              end
              return checkFunc(ns.AssignPCTDistribution)
            end,
            AssignPFCDistribution = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.AssignPFCDistribution))
                return
              end
              return checkFunc(ns.AssignPFCDistribution)
            end,
            AssignUpgradeDistribution = function()
              return checkFunc(ns.AssignUpgradeDistribution)
            end,
            GetActiveCharacterUpgradeBoostType = function()
              return checkFunc(ns.GetActiveCharacterUpgradeBoostType)
            end,
            GetActiveClassTrialBoostType = function()
              return checkFunc(ns.GetActiveClassTrialBoostType)
            end,
            GetAutomaticBoost = function()
              return checkFunc(ns.GetAutomaticBoost)
            end,
            GetAutomaticBoostCharacter = function()
              return checkFunc(ns.GetAutomaticBoostCharacter)
            end,
            GetCharacterServiceDisplayData = function()
              return checkFunc(ns.GetCharacterServiceDisplayData)
            end,
            GetCharacterServiceDisplayDataByVASType = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetCharacterServiceDisplayDataByVASType))
                return
              end
              return checkFunc(ns.GetCharacterServiceDisplayDataByVASType)
            end,
            GetCharacterServiceDisplayInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetCharacterServiceDisplayInfo))
                return
              end
              return checkFunc(ns.GetCharacterServiceDisplayInfo)
            end,
            GetCharacterServiceDisplayOrder = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetCharacterServiceDisplayOrder))
                return
              end
              return checkFunc(ns.GetCharacterServiceDisplayOrder)
            end,
            GetVASDistributions = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetVASDistributions))
                return
              end
              return checkFunc(ns.GetVASDistributions)
            end,
            HasRequiredBoostForClassTrial = function()
              return checkFunc(ns.HasRequiredBoostForClassTrial)
            end,
            HasRequiredBoostForUnrevoke = function()
              return checkFunc(ns.HasRequiredBoostForUnrevoke)
            end,
            SetAutomaticBoost = function()
              return checkFunc(ns.SetAutomaticBoost)
            end,
            SetAutomaticBoostCharacter = function()
              return checkFunc(ns.SetAutomaticBoostCharacter)
            end,
          })
        end,
        C_CharacterServicesPublic = function()
          local ns = _G.C_CharacterServicesPublic
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            ShouldSeeControlPopup = function()
              return checkFunc(ns.ShouldSeeControlPopup)
            end,
          })
        end,
        C_ChatBubbles = function()
          local ns = _G.C_ChatBubbles
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetAllChatBubbles = function()
              return checkFunc(ns.GetAllChatBubbles)
            end,
          })
        end,
        C_ChatInfo = function()
          local ns = _G.C_ChatInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            CanReportPlayer = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanReportPlayer))
                return
              end
              return checkFunc(ns.CanReportPlayer)
            end,
            GetChannelInfoFromIdentifier = function()
              return checkFunc(ns.GetChannelInfoFromIdentifier)
            end,
            GetChannelRosterInfo = function()
              return checkFunc(ns.GetChannelRosterInfo)
            end,
            GetChannelRuleset = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetChannelRuleset))
                return
              end
              return checkFunc(ns.GetChannelRuleset)
            end,
            GetChannelRulesetForChannelID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetChannelRulesetForChannelID))
                return
              end
              return checkFunc(ns.GetChannelRulesetForChannelID)
            end,
            GetChannelShortcut = function()
              return checkFunc(ns.GetChannelShortcut)
            end,
            GetChannelShortcutForChannelID = function()
              return checkFunc(ns.GetChannelShortcutForChannelID)
            end,
            GetChatTypeName = function()
              return checkFunc(ns.GetChatTypeName)
            end,
            GetClubStreamIDs = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetClubStreamIDs))
                return
              end
              return checkFunc(ns.GetClubStreamIDs)
            end,
            GetGeneralChannelID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetGeneralChannelID))
                return
              end
              return checkFunc(ns.GetGeneralChannelID)
            end,
            GetGeneralChannelLocalID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetGeneralChannelLocalID))
                return
              end
              return checkFunc(ns.GetGeneralChannelLocalID)
            end,
            GetMentorChannelID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetMentorChannelID))
                return
              end
              return checkFunc(ns.GetMentorChannelID)
            end,
            GetNumActiveChannels = function()
              return checkFunc(ns.GetNumActiveChannels)
            end,
            GetNumReservedChatWindows = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetNumReservedChatWindows))
                return
              end
              return checkFunc(ns.GetNumReservedChatWindows)
            end,
            GetRegisteredAddonMessagePrefixes = function()
              return checkFunc(ns.GetRegisteredAddonMessagePrefixes)
            end,
            IsAddonMessagePrefixRegistered = function()
              return checkFunc(ns.IsAddonMessagePrefixRegistered)
            end,
            IsChannelRegional = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsChannelRegional))
                return
              end
              return checkFunc(ns.IsChannelRegional)
            end,
            IsChannelRegionalForChannelID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsChannelRegionalForChannelID))
                return
              end
              return checkFunc(ns.IsChannelRegionalForChannelID)
            end,
            IsPartyChannelType = function()
              return checkFunc(ns.IsPartyChannelType)
            end,
            IsRegionalServiceAvailable = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsRegionalServiceAvailable))
                return
              end
              return checkFunc(ns.IsRegionalServiceAvailable)
            end,
            IsValidChatLine = function()
              return checkFunc(ns.IsValidChatLine)
            end,
            RegisterAddonMessagePrefix = function()
              return checkFunc(ns.RegisterAddonMessagePrefix)
            end,
            ReplaceIconAndGroupExpressions = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ReplaceIconAndGroupExpressions))
                return
              end
              return checkFunc(ns.ReplaceIconAndGroupExpressions)
            end,
            ReportPlayer = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ReportPlayer))
                return
              end
              return checkFunc(ns.ReportPlayer)
            end,
            ReportServerLag = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ReportServerLag))
                return
              end
              return checkFunc(ns.ReportServerLag)
            end,
            ResetDefaultZoneChannels = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ResetDefaultZoneChannels))
                return
              end
              return checkFunc(ns.ResetDefaultZoneChannels)
            end,
            SendAddonMessage = function()
              return checkFunc(ns.SendAddonMessage)
            end,
            SendAddonMessageLogged = function()
              return checkFunc(ns.SendAddonMessageLogged)
            end,
            SwapChatChannelsByChannelIndex = function()
              return checkFunc(ns.SwapChatChannelsByChannelIndex)
            end,
          })
        end,
        C_ChromieTime = function()
          local ns = _G.C_ChromieTime
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            CloseUI = function()
              return checkFunc(ns.CloseUI)
            end,
            GetChromieTimeExpansionOption = function()
              return checkFunc(ns.GetChromieTimeExpansionOption)
            end,
            GetChromieTimeExpansionOptions = function()
              return checkFunc(ns.GetChromieTimeExpansionOptions)
            end,
            SelectChromieTimeOption = function()
              return checkFunc(ns.SelectChromieTimeOption)
            end,
          })
        end,
        C_ClassColor = function()
          local ns = _G.C_ClassColor
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetClassColor = function()
              return checkFunc(ns.GetClassColor)
            end,
          })
        end,
        C_ClassTrial = function()
          local ns = _G.C_ClassTrial
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetClassTrialLogoutTimeSeconds = function()
              return checkFunc(ns.GetClassTrialLogoutTimeSeconds)
            end,
            IsClassTrialCharacter = function()
              return checkFunc(ns.IsClassTrialCharacter)
            end,
          })
        end,
        C_ClickBindings = function()
          local ns = _G.C_ClickBindings
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            CanSpellBeClickBound = function()
              return checkFunc(ns.CanSpellBeClickBound)
            end,
            ExecuteBinding = function()
              return checkFunc(ns.ExecuteBinding)
            end,
            GetBindingType = function()
              return checkFunc(ns.GetBindingType)
            end,
            GetEffectiveInteractionButton = function()
              return checkFunc(ns.GetEffectiveInteractionButton)
            end,
            GetProfileInfo = function()
              return checkFunc(ns.GetProfileInfo)
            end,
            GetStringFromModifiers = function()
              return checkFunc(ns.GetStringFromModifiers)
            end,
            GetTutorialShown = function()
              return checkFunc(ns.GetTutorialShown)
            end,
            MakeModifiers = function()
              return checkFunc(ns.MakeModifiers)
            end,
            ResetCurrentProfile = function()
              return checkFunc(ns.ResetCurrentProfile)
            end,
            SetProfileByInfo = function()
              return checkFunc(ns.SetProfileByInfo)
            end,
            SetTutorialShown = function()
              return checkFunc(ns.SetTutorialShown)
            end,
          })
        end,
        C_Club = function()
          local ns = _G.C_Club
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            AcceptInvitation = function()
              return checkFunc(ns.AcceptInvitation)
            end,
            AddClubStreamChatChannel = function()
              return checkFunc(ns.AddClubStreamChatChannel)
            end,
            AdvanceStreamViewMarker = function()
              return checkFunc(ns.AdvanceStreamViewMarker)
            end,
            AssignMemberRole = function()
              return checkFunc(ns.AssignMemberRole)
            end,
            CanResolvePlayerLocationFromClubMessageData = function()
              return checkFunc(ns.CanResolvePlayerLocationFromClubMessageData)
            end,
            ClearAutoAdvanceStreamViewMarker = function()
              return checkFunc(ns.ClearAutoAdvanceStreamViewMarker)
            end,
            ClearClubPresenceSubscription = function()
              return checkFunc(ns.ClearClubPresenceSubscription)
            end,
            CompareBattleNetDisplayName = function()
              return checkFunc(ns.CompareBattleNetDisplayName)
            end,
            CreateClub = function()
              return checkFunc(ns.CreateClub)
            end,
            CreateStream = function()
              return checkFunc(ns.CreateStream)
            end,
            CreateTicket = function()
              return checkFunc(ns.CreateTicket)
            end,
            DeclineInvitation = function()
              return checkFunc(ns.DeclineInvitation)
            end,
            DestroyClub = function()
              return checkFunc(ns.DestroyClub)
            end,
            DestroyMessage = function()
              return checkFunc(ns.DestroyMessage)
            end,
            DestroyStream = function()
              return checkFunc(ns.DestroyStream)
            end,
            DestroyTicket = function()
              return checkFunc(ns.DestroyTicket)
            end,
            DoesCommunityHaveMembersOfTheOppositeFaction = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.DoesCommunityHaveMembersOfTheOppositeFaction))
                return
              end
              return checkFunc(ns.DoesCommunityHaveMembersOfTheOppositeFaction)
            end,
            EditClub = function()
              return checkFunc(ns.EditClub)
            end,
            EditMessage = function()
              return checkFunc(ns.EditMessage)
            end,
            EditStream = function()
              return checkFunc(ns.EditStream)
            end,
            Flush = function()
              return checkFunc(ns.Flush)
            end,
            FocusCommunityStreams = function()
              return checkFunc(ns.FocusCommunityStreams)
            end,
            FocusStream = function()
              return checkFunc(ns.FocusStream)
            end,
            GetAssignableRoles = function()
              return checkFunc(ns.GetAssignableRoles)
            end,
            GetAvatarIdList = function()
              return checkFunc(ns.GetAvatarIdList)
            end,
            GetClubCapacity = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetClubCapacity))
                return
              end
              return checkFunc(ns.GetClubCapacity)
            end,
            GetClubInfo = function()
              return checkFunc(ns.GetClubInfo)
            end,
            GetClubLimits = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetClubLimits))
                return
              end
              return checkFunc(ns.GetClubLimits)
            end,
            GetClubMembers = function()
              return checkFunc(ns.GetClubMembers)
            end,
            GetClubPrivileges = function()
              return checkFunc(ns.GetClubPrivileges)
            end,
            GetClubStreamNotificationSettings = function()
              return checkFunc(ns.GetClubStreamNotificationSettings)
            end,
            GetCommunityNameResultText = function()
              return checkFunc(ns.GetCommunityNameResultText)
            end,
            GetGuildClubId = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetGuildClubId))
                return
              end
              return checkFunc(ns.GetGuildClubId)
            end,
            GetInfoFromLastCommunityChatLine = function()
              return checkFunc(ns.GetInfoFromLastCommunityChatLine)
            end,
            GetInvitationCandidates = function()
              return checkFunc(ns.GetInvitationCandidates)
            end,
            GetInvitationInfo = function()
              return checkFunc(ns.GetInvitationInfo)
            end,
            GetInvitationsForClub = function()
              return checkFunc(ns.GetInvitationsForClub)
            end,
            GetInvitationsForSelf = function()
              return checkFunc(ns.GetInvitationsForSelf)
            end,
            GetLastTicketResponse = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetLastTicketResponse))
                return
              end
              return checkFunc(ns.GetLastTicketResponse)
            end,
            GetMemberInfo = function()
              return checkFunc(ns.GetMemberInfo)
            end,
            GetMemberInfoForSelf = function()
              return checkFunc(ns.GetMemberInfoForSelf)
            end,
            GetMessageInfo = function()
              return checkFunc(ns.GetMessageInfo)
            end,
            GetMessageRanges = function()
              return checkFunc(ns.GetMessageRanges)
            end,
            GetMessagesBefore = function()
              return checkFunc(ns.GetMessagesBefore)
            end,
            GetMessagesInRange = function()
              return checkFunc(ns.GetMessagesInRange)
            end,
            GetStreamInfo = function()
              return checkFunc(ns.GetStreamInfo)
            end,
            GetStreamViewMarker = function()
              return checkFunc(ns.GetStreamViewMarker)
            end,
            GetStreams = function()
              return checkFunc(ns.GetStreams)
            end,
            GetSubscribedClubs = function()
              return checkFunc(ns.GetSubscribedClubs)
            end,
            GetTickets = function()
              return checkFunc(ns.GetTickets)
            end,
            IsAccountMuted = function()
              return checkFunc(ns.IsAccountMuted)
            end,
            IsBeginningOfStream = function()
              return checkFunc(ns.IsBeginningOfStream)
            end,
            IsEnabled = function()
              return checkFunc(ns.IsEnabled)
            end,
            IsRestricted = function()
              return checkFunc(ns.IsRestricted)
            end,
            IsSubscribedToStream = function()
              return checkFunc(ns.IsSubscribedToStream)
            end,
            KickMember = function()
              return checkFunc(ns.KickMember)
            end,
            LeaveClub = function()
              return checkFunc(ns.LeaveClub)
            end,
            RedeemTicket = function()
              return checkFunc(ns.RedeemTicket)
            end,
            RequestInvitationsForClub = function()
              return checkFunc(ns.RequestInvitationsForClub)
            end,
            RequestMoreMessagesBefore = function()
              return checkFunc(ns.RequestMoreMessagesBefore)
            end,
            RequestTicket = function()
              return checkFunc(ns.RequestTicket)
            end,
            RequestTickets = function()
              return checkFunc(ns.RequestTickets)
            end,
            RevokeInvitation = function()
              return checkFunc(ns.RevokeInvitation)
            end,
            SendBattleTagFriendRequest = function()
              return checkFunc(ns.SendBattleTagFriendRequest)
            end,
            SendCharacterInvitation = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SendCharacterInvitation))
                return
              end
              return checkFunc(ns.SendCharacterInvitation)
            end,
            SendInvitation = function()
              return checkFunc(ns.SendInvitation)
            end,
            SendMessage = function()
              return checkFunc(ns.SendMessage)
            end,
            SetAutoAdvanceStreamViewMarker = function()
              return checkFunc(ns.SetAutoAdvanceStreamViewMarker)
            end,
            SetAvatarTexture = function()
              return checkFunc(ns.SetAvatarTexture)
            end,
            SetClubMemberNote = function()
              return checkFunc(ns.SetClubMemberNote)
            end,
            SetClubPresenceSubscription = function()
              return checkFunc(ns.SetClubPresenceSubscription)
            end,
            SetClubStreamNotificationSettings = function()
              return checkFunc(ns.SetClubStreamNotificationSettings)
            end,
            SetCommunityID = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetCommunityID))
                return
              end
              return checkFunc(ns.SetCommunityID)
            end,
            SetFavorite = function()
              return checkFunc(ns.SetFavorite)
            end,
            SetSocialQueueingEnabled = function()
              return checkFunc(ns.SetSocialQueueingEnabled)
            end,
            ShouldAllowClubType = function()
              return checkFunc(ns.ShouldAllowClubType)
            end,
            UnfocusAllStreams = function()
              return checkFunc(ns.UnfocusAllStreams)
            end,
            UnfocusStream = function()
              return checkFunc(ns.UnfocusStream)
            end,
            ValidateText = function()
              return checkFunc(ns.ValidateText)
            end,
          })
        end,
        C_ClubFinder = function()
          local ns = _G.C_ClubFinder
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            ApplicantAcceptClubInvite = function()
              return checkFunc(ns.ApplicantAcceptClubInvite)
            end,
            ApplicantDeclineClubInvite = function()
              return checkFunc(ns.ApplicantDeclineClubInvite)
            end,
            CancelMembershipRequest = function()
              return checkFunc(ns.CancelMembershipRequest)
            end,
            CheckAllPlayerApplicantSettings = function()
              return checkFunc(ns.CheckAllPlayerApplicantSettings)
            end,
            ClearAllFinderCache = function()
              return checkFunc(ns.ClearAllFinderCache)
            end,
            ClearClubApplicantsCache = function()
              return checkFunc(ns.ClearClubApplicantsCache)
            end,
            ClearClubFinderPostingsCache = function()
              return checkFunc(ns.ClearClubFinderPostingsCache)
            end,
            DoesPlayerBelongToClubFromClubGUID = function()
              return checkFunc(ns.DoesPlayerBelongToClubFromClubGUID)
            end,
            GetClubFinderDisableReason = function()
              return checkFunc(ns.GetClubFinderDisableReason)
            end,
            GetClubRecruitmentSettings = function()
              return checkFunc(ns.GetClubRecruitmentSettings)
            end,
            GetClubTypeFromFinderGUID = function()
              return checkFunc(ns.GetClubTypeFromFinderGUID)
            end,
            GetFocusIndexFromFlag = function()
              return checkFunc(ns.GetFocusIndexFromFlag)
            end,
            GetPlayerApplicantLocaleFlags = function()
              return checkFunc(ns.GetPlayerApplicantLocaleFlags)
            end,
            GetPlayerApplicantSettings = function()
              return checkFunc(ns.GetPlayerApplicantSettings)
            end,
            GetPlayerClubApplicationStatus = function()
              return checkFunc(ns.GetPlayerClubApplicationStatus)
            end,
            GetPlayerSettingsFocusFlagsSelectedCount = function()
              return checkFunc(ns.GetPlayerSettingsFocusFlagsSelectedCount)
            end,
            GetPostingIDFromClubFinderGUID = function()
              return checkFunc(ns.GetPostingIDFromClubFinderGUID)
            end,
            GetRecruitingClubInfoFromClubID = function()
              return checkFunc(ns.GetRecruitingClubInfoFromClubID)
            end,
            GetRecruitingClubInfoFromFinderGUID = function()
              return checkFunc(ns.GetRecruitingClubInfoFromFinderGUID)
            end,
            GetStatusOfPostingFromClubId = function()
              return checkFunc(ns.GetStatusOfPostingFromClubId)
            end,
            GetTotalMatchingCommunityListSize = function()
              return checkFunc(ns.GetTotalMatchingCommunityListSize)
            end,
            GetTotalMatchingGuildListSize = function()
              return checkFunc(ns.GetTotalMatchingGuildListSize)
            end,
            HasAlreadyAppliedToLinkedPosting = function()
              return checkFunc(ns.HasAlreadyAppliedToLinkedPosting)
            end,
            HasPostingBeenDelisted = function()
              return checkFunc(ns.HasPostingBeenDelisted)
            end,
            IsEnabled = function()
              return checkFunc(ns.IsEnabled)
            end,
            IsListingEnabledFromFlags = function()
              return checkFunc(ns.IsListingEnabledFromFlags)
            end,
            IsPostingBanned = function()
              return checkFunc(ns.IsPostingBanned)
            end,
            LookupClubPostingFromClubFinderGUID = function()
              return checkFunc(ns.LookupClubPostingFromClubFinderGUID)
            end,
            PlayerGetClubInvitationList = function()
              return checkFunc(ns.PlayerGetClubInvitationList)
            end,
            PlayerRequestPendingClubsList = function()
              return checkFunc(ns.PlayerRequestPendingClubsList)
            end,
            PlayerReturnPendingCommunitiesList = function()
              return checkFunc(ns.PlayerReturnPendingCommunitiesList)
            end,
            PlayerReturnPendingGuildsList = function()
              return checkFunc(ns.PlayerReturnPendingGuildsList)
            end,
            PostClub = function()
              return checkFunc(ns.PostClub)
            end,
            RequestApplicantList = function()
              return checkFunc(ns.RequestApplicantList)
            end,
            RequestClubsList = function()
              return checkFunc(ns.RequestClubsList)
            end,
            RequestMembershipToClub = function()
              return checkFunc(ns.RequestMembershipToClub)
            end,
            RequestNextCommunityPage = function()
              return checkFunc(ns.RequestNextCommunityPage)
            end,
            RequestNextGuildPage = function()
              return checkFunc(ns.RequestNextGuildPage)
            end,
            RequestPostingInformationFromClubId = function()
              return checkFunc(ns.RequestPostingInformationFromClubId)
            end,
            RequestSubscribedClubPostingIDs = function()
              return checkFunc(ns.RequestSubscribedClubPostingIDs)
            end,
            ResetClubPostingMapCache = function()
              return checkFunc(ns.ResetClubPostingMapCache)
            end,
            RespondToApplicant = function()
              return checkFunc(ns.RespondToApplicant)
            end,
            ReturnClubApplicantList = function()
              return checkFunc(ns.ReturnClubApplicantList)
            end,
            ReturnMatchingCommunityList = function()
              return checkFunc(ns.ReturnMatchingCommunityList)
            end,
            ReturnMatchingGuildList = function()
              return checkFunc(ns.ReturnMatchingGuildList)
            end,
            ReturnPendingClubApplicantList = function()
              return checkFunc(ns.ReturnPendingClubApplicantList)
            end,
            SendChatWhisper = function()
              return checkFunc(ns.SendChatWhisper)
            end,
            SetAllRecruitmentSettings = function()
              return checkFunc(ns.SetAllRecruitmentSettings)
            end,
            SetPlayerApplicantLocaleFlags = function()
              return checkFunc(ns.SetPlayerApplicantLocaleFlags)
            end,
            SetPlayerApplicantSettings = function()
              return checkFunc(ns.SetPlayerApplicantSettings)
            end,
            SetRecruitmentLocale = function()
              return checkFunc(ns.SetRecruitmentLocale)
            end,
            SetRecruitmentSettings = function()
              return checkFunc(ns.SetRecruitmentSettings)
            end,
            ShouldShowClubFinder = function()
              return checkFunc(ns.ShouldShowClubFinder)
            end,
          })
        end,
        C_Commentator = function()
          local ns = _G.C_Commentator
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            AddPlayerOverrideName = function()
              return checkFunc(ns.AddPlayerOverrideName)
            end,
            AddTrackedDefensiveAuras = function()
              return checkFunc(ns.AddTrackedDefensiveAuras)
            end,
            AddTrackedOffensiveAuras = function()
              return checkFunc(ns.AddTrackedOffensiveAuras)
            end,
            AreTeamsSwapped = function()
              return checkFunc(ns.AreTeamsSwapped)
            end,
            AssignPlayerToTeam = function()
              return checkFunc(ns.AssignPlayerToTeam)
            end,
            AssignPlayersToTeam = function()
              return checkFunc(ns.AssignPlayersToTeam)
            end,
            AssignPlayersToTeamInCurrentInstance = function()
              return checkFunc(ns.AssignPlayersToTeamInCurrentInstance)
            end,
            CanUseCommentatorCheats = function()
              return checkFunc(ns.CanUseCommentatorCheats)
            end,
            ClearCameraTarget = function()
              return checkFunc(ns.ClearCameraTarget)
            end,
            ClearFollowTarget = function()
              return checkFunc(ns.ClearFollowTarget)
            end,
            ClearLookAtTarget = function()
              return checkFunc(ns.ClearLookAtTarget)
            end,
            EnterInstance = function()
              return checkFunc(ns.EnterInstance)
            end,
            ExitInstance = function()
              return checkFunc(ns.ExitInstance)
            end,
            FindSpectatedUnit = function()
              return checkFunc(ns.FindSpectatedUnit)
            end,
            FindTeamNameInCurrentInstance = function()
              return checkFunc(ns.FindTeamNameInCurrentInstance)
            end,
            FindTeamNameInDirectory = function()
              return checkFunc(ns.FindTeamNameInDirectory)
            end,
            FlushCommentatorHistory = function()
              return checkFunc(ns.FlushCommentatorHistory)
            end,
            FollowPlayer = function()
              return checkFunc(ns.FollowPlayer)
            end,
            FollowUnit = function()
              return checkFunc(ns.FollowUnit)
            end,
            ForceFollowTransition = function()
              return checkFunc(ns.ForceFollowTransition)
            end,
            GetAdditionalCameraWeight = function()
              return checkFunc(ns.GetAdditionalCameraWeight)
            end,
            GetAdditionalCameraWeightByToken = function()
              return checkFunc(ns.GetAdditionalCameraWeightByToken)
            end,
            GetAllPlayerOverrideNames = function()
              return checkFunc(ns.GetAllPlayerOverrideNames)
            end,
            GetCamera = function()
              return checkFunc(ns.GetCamera)
            end,
            GetCameraCollision = function()
              return checkFunc(ns.GetCameraCollision)
            end,
            GetCameraPosition = function()
              return checkFunc(ns.GetCameraPosition)
            end,
            GetCommentatorHistory = function()
              return checkFunc(ns.GetCommentatorHistory)
            end,
            GetCurrentMapID = function()
              return checkFunc(ns.GetCurrentMapID)
            end,
            GetDampeningPercent = function()
              return checkFunc(ns.GetDampeningPercent)
            end,
            GetDistanceBeforeForcedHorizontalConvergence = function()
              return checkFunc(ns.GetDistanceBeforeForcedHorizontalConvergence)
            end,
            GetDurationToForceHorizontalConvergence = function()
              return checkFunc(ns.GetDurationToForceHorizontalConvergence)
            end,
            GetExcludeDistance = function()
              return checkFunc(ns.GetExcludeDistance)
            end,
            GetHardlockWeight = function()
              return checkFunc(ns.GetHardlockWeight)
            end,
            GetHorizontalAngleThresholdToSmooth = function()
              return checkFunc(ns.GetHorizontalAngleThresholdToSmooth)
            end,
            GetIndirectSpellID = function()
              return checkFunc(ns.GetIndirectSpellID)
            end,
            GetInstanceInfo = function()
              return checkFunc(ns.GetInstanceInfo)
            end,
            GetLookAtLerpAmount = function()
              return checkFunc(ns.GetLookAtLerpAmount)
            end,
            GetMapInfo = function()
              return checkFunc(ns.GetMapInfo)
            end,
            GetMatchDuration = function()
              return checkFunc(ns.GetMatchDuration)
            end,
            GetMaxNumPlayersPerTeam = function()
              return checkFunc(ns.GetMaxNumPlayersPerTeam)
            end,
            GetMaxNumTeams = function()
              return checkFunc(ns.GetMaxNumTeams)
            end,
            GetMode = function()
              return checkFunc(ns.GetMode)
            end,
            GetMsToHoldForHorizontalMovement = function()
              return checkFunc(ns.GetMsToHoldForHorizontalMovement)
            end,
            GetMsToHoldForVerticalMovement = function()
              return checkFunc(ns.GetMsToHoldForVerticalMovement)
            end,
            GetMsToSmoothHorizontalChange = function()
              return checkFunc(ns.GetMsToSmoothHorizontalChange)
            end,
            GetMsToSmoothVerticalChange = function()
              return checkFunc(ns.GetMsToSmoothVerticalChange)
            end,
            GetNumMaps = function()
              return checkFunc(ns.GetNumMaps)
            end,
            GetNumPlayers = function()
              return checkFunc(ns.GetNumPlayers)
            end,
            GetOrCreateSeries = function()
              return checkFunc(ns.GetOrCreateSeries)
            end,
            GetPlayerAuraInfo = function()
              return checkFunc(ns.GetPlayerAuraInfo)
            end,
            GetPlayerAuraInfoByUnit = function()
              return checkFunc(ns.GetPlayerAuraInfoByUnit)
            end,
            GetPlayerCooldownInfo = function()
              return checkFunc(ns.GetPlayerCooldownInfo)
            end,
            GetPlayerCooldownInfoByUnit = function()
              return checkFunc(ns.GetPlayerCooldownInfoByUnit)
            end,
            GetPlayerCrowdControlInfo = function()
              return checkFunc(ns.GetPlayerCrowdControlInfo)
            end,
            GetPlayerCrowdControlInfoByUnit = function()
              return checkFunc(ns.GetPlayerCrowdControlInfoByUnit)
            end,
            GetPlayerData = function()
              return checkFunc(ns.GetPlayerData)
            end,
            GetPlayerFlagInfo = function()
              return checkFunc(ns.GetPlayerFlagInfo)
            end,
            GetPlayerFlagInfoByUnit = function()
              return checkFunc(ns.GetPlayerFlagInfoByUnit)
            end,
            GetPlayerOverrideName = function()
              return checkFunc(ns.GetPlayerOverrideName)
            end,
            GetPlayerSpellCharges = function()
              return checkFunc(ns.GetPlayerSpellCharges)
            end,
            GetPlayerSpellChargesByUnit = function()
              return checkFunc(ns.GetPlayerSpellChargesByUnit)
            end,
            GetPositionLerpAmount = function()
              return checkFunc(ns.GetPositionLerpAmount)
            end,
            GetSmoothFollowTransitioning = function()
              return checkFunc(ns.GetSmoothFollowTransitioning)
            end,
            GetSoftlockWeight = function()
              return checkFunc(ns.GetSoftlockWeight)
            end,
            GetSpeedFactor = function()
              return checkFunc(ns.GetSpeedFactor)
            end,
            GetStartLocation = function()
              return checkFunc(ns.GetStartLocation)
            end,
            GetTeamColor = function()
              return checkFunc(ns.GetTeamColor)
            end,
            GetTeamColorByUnit = function()
              return checkFunc(ns.GetTeamColorByUnit)
            end,
            GetTimeLeftInMatch = function()
              return checkFunc(ns.GetTimeLeftInMatch)
            end,
            GetTrackedSpellID = function()
              return checkFunc(ns.GetTrackedSpellID)
            end,
            GetTrackedSpells = function()
              return checkFunc(ns.GetTrackedSpells)
            end,
            GetTrackedSpellsByUnit = function()
              return checkFunc(ns.GetTrackedSpellsByUnit)
            end,
            GetUnitData = function()
              return checkFunc(ns.GetUnitData)
            end,
            GetWargameInfo = function()
              return checkFunc(ns.GetWargameInfo)
            end,
            HasTrackedAuras = function()
              return checkFunc(ns.HasTrackedAuras)
            end,
            IsSmartCameraLocked = function()
              return checkFunc(ns.IsSmartCameraLocked)
            end,
            IsSpectating = function()
              return checkFunc(ns.IsSpectating)
            end,
            IsTrackedDefensiveAura = function()
              return checkFunc(ns.IsTrackedDefensiveAura)
            end,
            IsTrackedOffensiveAura = function()
              return checkFunc(ns.IsTrackedOffensiveAura)
            end,
            IsTrackedSpell = function()
              return checkFunc(ns.IsTrackedSpell)
            end,
            IsTrackedSpellByUnit = function()
              return checkFunc(ns.IsTrackedSpellByUnit)
            end,
            IsUsingSmartCamera = function()
              return checkFunc(ns.IsUsingSmartCamera)
            end,
            LookAtPlayer = function()
              return checkFunc(ns.LookAtPlayer)
            end,
            RemoveAllOverrideNames = function()
              return checkFunc(ns.RemoveAllOverrideNames)
            end,
            RemovePlayerOverrideName = function()
              return checkFunc(ns.RemovePlayerOverrideName)
            end,
            RequestPlayerCooldownInfo = function()
              return checkFunc(ns.RequestPlayerCooldownInfo)
            end,
            ResetFoVTarget = function()
              return checkFunc(ns.ResetFoVTarget)
            end,
            ResetSeriesScores = function()
              return checkFunc(ns.ResetSeriesScores)
            end,
            ResetSettings = function()
              return checkFunc(ns.ResetSettings)
            end,
            ResetTrackedAuras = function()
              return checkFunc(ns.ResetTrackedAuras)
            end,
            SetAdditionalCameraWeight = function()
              return checkFunc(ns.SetAdditionalCameraWeight)
            end,
            SetAdditionalCameraWeightByToken = function()
              return checkFunc(ns.SetAdditionalCameraWeightByToken)
            end,
            SetBlocklistedAuras = function()
              return checkFunc(ns.SetBlocklistedAuras)
            end,
            SetBlocklistedCooldowns = function()
              return checkFunc(ns.SetBlocklistedCooldowns)
            end,
            SetCamera = function()
              return checkFunc(ns.SetCamera)
            end,
            SetCameraCollision = function()
              return checkFunc(ns.SetCameraCollision)
            end,
            SetCameraPosition = function()
              return checkFunc(ns.SetCameraPosition)
            end,
            SetCheatsEnabled = function()
              return checkFunc(ns.SetCheatsEnabled)
            end,
            SetCommentatorHistory = function()
              return checkFunc(ns.SetCommentatorHistory)
            end,
            SetDistanceBeforeForcedHorizontalConvergence = function()
              return checkFunc(ns.SetDistanceBeforeForcedHorizontalConvergence)
            end,
            SetDurationToForceHorizontalConvergence = function()
              return checkFunc(ns.SetDurationToForceHorizontalConvergence)
            end,
            SetExcludeDistance = function()
              return checkFunc(ns.SetExcludeDistance)
            end,
            SetFollowCameraSpeeds = function()
              return checkFunc(ns.SetFollowCameraSpeeds)
            end,
            SetHardlockWeight = function()
              return checkFunc(ns.SetHardlockWeight)
            end,
            SetHorizontalAngleThresholdToSmooth = function()
              return checkFunc(ns.SetHorizontalAngleThresholdToSmooth)
            end,
            SetLookAtLerpAmount = function()
              return checkFunc(ns.SetLookAtLerpAmount)
            end,
            SetMapAndInstanceIndex = function()
              return checkFunc(ns.SetMapAndInstanceIndex)
            end,
            SetMouseDisabled = function()
              return checkFunc(ns.SetMouseDisabled)
            end,
            SetMoveSpeed = function()
              return checkFunc(ns.SetMoveSpeed)
            end,
            SetMsToHoldForHorizontalMovement = function()
              return checkFunc(ns.SetMsToHoldForHorizontalMovement)
            end,
            SetMsToHoldForVerticalMovement = function()
              return checkFunc(ns.SetMsToHoldForVerticalMovement)
            end,
            SetMsToSmoothHorizontalChange = function()
              return checkFunc(ns.SetMsToSmoothHorizontalChange)
            end,
            SetMsToSmoothVerticalChange = function()
              return checkFunc(ns.SetMsToSmoothVerticalChange)
            end,
            SetPositionLerpAmount = function()
              return checkFunc(ns.SetPositionLerpAmount)
            end,
            SetRequestedDebuffCooldowns = function()
              return checkFunc(ns.SetRequestedDebuffCooldowns)
            end,
            SetRequestedDefensiveCooldowns = function()
              return checkFunc(ns.SetRequestedDefensiveCooldowns)
            end,
            SetRequestedOffensiveCooldowns = function()
              return checkFunc(ns.SetRequestedOffensiveCooldowns)
            end,
            SetSeriesScore = function()
              return checkFunc(ns.SetSeriesScore)
            end,
            SetSeriesScores = function()
              return checkFunc(ns.SetSeriesScores)
            end,
            SetSmartCameraLocked = function()
              return checkFunc(ns.SetSmartCameraLocked)
            end,
            SetSmoothFollowTransitioning = function()
              return checkFunc(ns.SetSmoothFollowTransitioning)
            end,
            SetSoftlockWeight = function()
              return checkFunc(ns.SetSoftlockWeight)
            end,
            SetSpeedFactor = function()
              return checkFunc(ns.SetSpeedFactor)
            end,
            SetTargetHeightOffset = function()
              return checkFunc(ns.SetTargetHeightOffset)
            end,
            SetUseSmartCamera = function()
              return checkFunc(ns.SetUseSmartCamera)
            end,
            SnapCameraLookAtPoint = function()
              return checkFunc(ns.SnapCameraLookAtPoint)
            end,
            StartWargame = function()
              return checkFunc(ns.StartWargame)
            end,
            SwapTeamSides = function()
              return checkFunc(ns.SwapTeamSides)
            end,
            ToggleCheats = function()
              return checkFunc(ns.ToggleCheats)
            end,
            UpdateMapInfo = function()
              return checkFunc(ns.UpdateMapInfo)
            end,
            UpdatePlayerInfo = function()
              return checkFunc(ns.UpdatePlayerInfo)
            end,
            ZoomIn = function()
              return checkFunc(ns.ZoomIn)
            end,
            ZoomOut = function()
              return checkFunc(ns.ZoomOut)
            end,
          })
        end,
        C_Console = function()
          local ns = _G.C_Console
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetAllCommands = function()
              return checkFunc(ns.GetAllCommands)
            end,
            GetColorFromType = function()
              return checkFunc(ns.GetColorFromType)
            end,
            GetFontHeight = function()
              return checkFunc(ns.GetFontHeight)
            end,
            PrintAllMatchingCommands = function()
              return checkFunc(ns.PrintAllMatchingCommands)
            end,
            SetFontHeight = function()
              return checkFunc(ns.SetFontHeight)
            end,
          })
        end,
        C_ContributionCollector = function()
          local ns = _G.C_ContributionCollector
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            Close = function()
              return checkFunc(ns.Close)
            end,
            Contribute = function()
              return checkFunc(ns.Contribute)
            end,
            GetActive = function()
              return checkFunc(ns.GetActive)
            end,
            GetAtlases = function()
              return checkFunc(ns.GetAtlases)
            end,
            GetBuffs = function()
              return checkFunc(ns.GetBuffs)
            end,
            GetContributionAppearance = function()
              return checkFunc(ns.GetContributionAppearance)
            end,
            GetContributionCollectorsForMap = function()
              return checkFunc(ns.GetContributionCollectorsForMap)
            end,
            GetContributionResult = function()
              return checkFunc(ns.GetContributionResult)
            end,
            GetDescription = function()
              return checkFunc(ns.GetDescription)
            end,
            GetManagedContributionsForCreatureID = function()
              return checkFunc(ns.GetManagedContributionsForCreatureID)
            end,
            GetName = function()
              return checkFunc(ns.GetName)
            end,
            GetOrderIndex = function()
              return checkFunc(ns.GetOrderIndex)
            end,
            GetRequiredContributionCurrency = function()
              return checkFunc(ns.GetRequiredContributionCurrency)
            end,
            GetRequiredContributionItem = function()
              return checkFunc(ns.GetRequiredContributionItem)
            end,
            GetRewardQuestID = function()
              return checkFunc(ns.GetRewardQuestID)
            end,
            GetState = function()
              return checkFunc(ns.GetState)
            end,
            HasPendingContribution = function()
              return checkFunc(ns.HasPendingContribution)
            end,
            IsAwaitingRewardQuestData = function()
              return checkFunc(ns.IsAwaitingRewardQuestData)
            end,
          })
        end,
        C_CovenantCallings = function()
          local ns = _G.C_CovenantCallings
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            AreCallingsUnlocked = function()
              return checkFunc(ns.AreCallingsUnlocked)
            end,
            RequestCallings = function()
              return checkFunc(ns.RequestCallings)
            end,
          })
        end,
        C_CovenantPreview = function()
          local ns = _G.C_CovenantPreview
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            CloseFromUI = function()
              return checkFunc(ns.CloseFromUI)
            end,
            GetCovenantInfoForPlayerChoiceResponseID = function()
              return checkFunc(ns.GetCovenantInfoForPlayerChoiceResponseID)
            end,
          })
        end,
        C_CovenantSanctumUI = function()
          local ns = _G.C_CovenantSanctumUI
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            CanAccessReservoir = function()
              return checkFunc(ns.CanAccessReservoir)
            end,
            CanDepositAnima = function()
              return checkFunc(ns.CanDepositAnima)
            end,
            DepositAnima = function()
              return checkFunc(ns.DepositAnima)
            end,
            EndInteraction = function()
              return checkFunc(ns.EndInteraction)
            end,
            GetAnimaInfo = function()
              return checkFunc(ns.GetAnimaInfo)
            end,
            GetCurrentTalentTreeID = function()
              return checkFunc(ns.GetCurrentTalentTreeID)
            end,
            GetFeatures = function()
              return checkFunc(ns.GetFeatures)
            end,
            GetRenownLevel = function()
              return checkFunc(ns.GetRenownLevel)
            end,
            GetRenownLevels = function()
              return checkFunc(ns.GetRenownLevels)
            end,
            GetRenownRewardsForLevel = function()
              return checkFunc(ns.GetRenownRewardsForLevel)
            end,
            GetSanctumType = function()
              return checkFunc(ns.GetSanctumType)
            end,
            GetSoulCurrencies = function()
              return checkFunc(ns.GetSoulCurrencies)
            end,
            HasMaximumRenown = function()
              return checkFunc(ns.HasMaximumRenown)
            end,
            IsPlayerInRenownCatchUpMode = function()
              return checkFunc(ns.IsPlayerInRenownCatchUpMode)
            end,
            IsWeeklyRenownCapped = function()
              return checkFunc(ns.IsWeeklyRenownCapped)
            end,
            RequestCatchUpState = function()
              return checkFunc(ns.RequestCatchUpState)
            end,
          })
        end,
        C_Covenants = function()
          local ns = _G.C_Covenants
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetActiveCovenantID = function()
              return checkFunc(ns.GetActiveCovenantID)
            end,
            GetCovenantData = function()
              return checkFunc(ns.GetCovenantData)
            end,
            GetCovenantIDs = function()
              return checkFunc(ns.GetCovenantIDs)
            end,
          })
        end,
        C_CreatureInfo = function()
          local ns = _G.C_CreatureInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetClassInfo = function()
              return checkFunc(ns.GetClassInfo)
            end,
            GetFactionInfo = function()
              return checkFunc(ns.GetFactionInfo)
            end,
            GetRaceInfo = function()
              return checkFunc(ns.GetRaceInfo)
            end,
          })
        end,
        C_CurrencyInfo = function()
          local ns = _G.C_CurrencyInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            DoesWarModeBonusApply = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.DoesWarModeBonusApply))
                return
              end
              return checkFunc(ns.DoesWarModeBonusApply)
            end,
            ExpandCurrencyList = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ExpandCurrencyList))
                return
              end
              return checkFunc(ns.ExpandCurrencyList)
            end,
            GetAzeriteCurrencyID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetAzeriteCurrencyID))
                return
              end
              return checkFunc(ns.GetAzeriteCurrencyID)
            end,
            GetBackpackCurrencyInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetBackpackCurrencyInfo))
                return
              end
              return checkFunc(ns.GetBackpackCurrencyInfo)
            end,
            GetBasicCurrencyInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetBasicCurrencyInfo))
                return
              end
              return checkFunc(ns.GetBasicCurrencyInfo)
            end,
            GetCurrencyContainerInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetCurrencyContainerInfo))
                return
              end
              return checkFunc(ns.GetCurrencyContainerInfo)
            end,
            GetCurrencyIDFromLink = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetCurrencyIDFromLink))
                return
              end
              return checkFunc(ns.GetCurrencyIDFromLink)
            end,
            GetCurrencyInfo = function()
              return checkFunc(ns.GetCurrencyInfo)
            end,
            GetCurrencyInfoFromLink = function()
              return checkFunc(ns.GetCurrencyInfoFromLink)
            end,
            GetCurrencyLink = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetCurrencyLink))
                return
              end
              return checkFunc(ns.GetCurrencyLink)
            end,
            GetCurrencyListInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetCurrencyListInfo))
                return
              end
              return checkFunc(ns.GetCurrencyListInfo)
            end,
            GetCurrencyListLink = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetCurrencyListLink))
                return
              end
              return checkFunc(ns.GetCurrencyListLink)
            end,
            GetCurrencyListSize = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetCurrencyListSize))
                return
              end
              return checkFunc(ns.GetCurrencyListSize)
            end,
            GetFactionGrantedByCurrency = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetFactionGrantedByCurrency))
                return
              end
              return checkFunc(ns.GetFactionGrantedByCurrency)
            end,
            GetWarResourcesCurrencyID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetWarResourcesCurrencyID))
                return
              end
              return checkFunc(ns.GetWarResourcesCurrencyID)
            end,
            IsCurrencyContainer = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsCurrencyContainer))
                return
              end
              return checkFunc(ns.IsCurrencyContainer)
            end,
            PickupCurrency = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.PickupCurrency))
                return
              end
              return checkFunc(ns.PickupCurrency)
            end,
            SetCurrencyBackpack = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetCurrencyBackpack))
                return
              end
              return checkFunc(ns.SetCurrencyBackpack)
            end,
            SetCurrencyUnused = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetCurrencyUnused))
                return
              end
              return checkFunc(ns.SetCurrencyUnused)
            end,
          })
        end,
        C_Cursor = function()
          local ns = _G.C_Cursor
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            DropCursorCommunitiesStream = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.DropCursorCommunitiesStream))
                return
              end
              return checkFunc(ns.DropCursorCommunitiesStream)
            end,
            GetCursorCommunitiesStream = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetCursorCommunitiesStream))
                return
              end
              return checkFunc(ns.GetCursorCommunitiesStream)
            end,
            GetCursorItem = function()
              return checkFunc(ns.GetCursorItem)
            end,
            SetCursorCommunitiesStream = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetCursorCommunitiesStream))
                return
              end
              return checkFunc(ns.SetCursorCommunitiesStream)
            end,
          })
        end,
        C_DateAndTime = function()
          local ns = _G.C_DateAndTime
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            AdjustTimeByDays = function()
              return checkFunc(ns.AdjustTimeByDays)
            end,
            AdjustTimeByMinutes = function()
              return checkFunc(ns.AdjustTimeByMinutes)
            end,
            CompareCalendarTime = function()
              return checkFunc(ns.CompareCalendarTime)
            end,
            GetCalendarTimeFromEpoch = function()
              return checkFunc(ns.GetCalendarTimeFromEpoch)
            end,
            GetCurrentCalendarTime = function()
              return checkFunc(ns.GetCurrentCalendarTime)
            end,
            GetSecondsUntilDailyReset = function()
              return checkFunc(ns.GetSecondsUntilDailyReset)
            end,
            GetSecondsUntilWeeklyReset = function()
              return checkFunc(ns.GetSecondsUntilWeeklyReset)
            end,
            GetServerTimeLocal = function()
              return checkFunc(ns.GetServerTimeLocal)
            end,
          })
        end,
        C_DeathInfo = function()
          local ns = _G.C_DeathInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetCorpseMapPosition = function()
              return checkFunc(ns.GetCorpseMapPosition)
            end,
            GetDeathReleasePosition = function()
              return checkFunc(ns.GetDeathReleasePosition)
            end,
            GetGraveyardsForMap = function()
              return checkFunc(ns.GetGraveyardsForMap)
            end,
            GetSelfResurrectOptions = function()
              return checkFunc(ns.GetSelfResurrectOptions)
            end,
            UseSelfResurrectOption = function()
              return checkFunc(ns.UseSelfResurrectOption)
            end,
          })
        end,
        C_EncounterJournal = function()
          local ns = _G.C_EncounterJournal
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetDungeonEntrancesForMap = function()
              return checkFunc(ns.GetDungeonEntrancesForMap)
            end,
            GetEncountersOnMap = function()
              return checkFunc(ns.GetEncountersOnMap)
            end,
            GetLootInfo = function()
              return checkFunc(ns.GetLootInfo)
            end,
            GetLootInfoByIndex = function()
              return checkFunc(ns.GetLootInfoByIndex)
            end,
            GetSectionIconFlags = function()
              return checkFunc(ns.GetSectionIconFlags)
            end,
            GetSectionInfo = function()
              return checkFunc(ns.GetSectionInfo)
            end,
            GetSlotFilter = function()
              return checkFunc(ns.GetSlotFilter)
            end,
            InstanceHasLoot = function()
              return checkFunc(ns.InstanceHasLoot)
            end,
            IsEncounterComplete = function()
              return checkFunc(ns.IsEncounterComplete)
            end,
            ResetSlotFilter = function()
              return checkFunc(ns.ResetSlotFilter)
            end,
            SetPreviewMythicPlusLevel = function()
              return checkFunc(ns.SetPreviewMythicPlusLevel)
            end,
            SetPreviewPvpTier = function()
              return checkFunc(ns.SetPreviewPvpTier)
            end,
            SetSlotFilter = function()
              return checkFunc(ns.SetSlotFilter)
            end,
          })
        end,
        C_EquipmentSet = function()
          local ns = _G.C_EquipmentSet
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            AssignSpecToEquipmentSet = function()
              return checkFunc(ns.AssignSpecToEquipmentSet)
            end,
            CanUseEquipmentSets = function()
              return checkFunc(ns.CanUseEquipmentSets)
            end,
            ClearIgnoredSlotsForSave = function()
              return checkFunc(ns.ClearIgnoredSlotsForSave)
            end,
            CreateEquipmentSet = function()
              return checkFunc(ns.CreateEquipmentSet)
            end,
            DeleteEquipmentSet = function()
              return checkFunc(ns.DeleteEquipmentSet)
            end,
            EquipmentSetContainsLockedItems = function()
              return checkFunc(ns.EquipmentSetContainsLockedItems)
            end,
            GetEquipmentSetAssignedSpec = function()
              return checkFunc(ns.GetEquipmentSetAssignedSpec)
            end,
            GetEquipmentSetForSpec = function()
              return checkFunc(ns.GetEquipmentSetForSpec)
            end,
            GetEquipmentSetID = function()
              return checkFunc(ns.GetEquipmentSetID)
            end,
            GetEquipmentSetIDs = function()
              return checkFunc(ns.GetEquipmentSetIDs)
            end,
            GetEquipmentSetInfo = function()
              return checkFunc(ns.GetEquipmentSetInfo)
            end,
            GetIgnoredSlots = function()
              return checkFunc(ns.GetIgnoredSlots)
            end,
            GetItemIDs = function()
              return checkFunc(ns.GetItemIDs)
            end,
            GetItemLocations = function()
              return checkFunc(ns.GetItemLocations)
            end,
            GetNumEquipmentSets = function()
              return checkFunc(ns.GetNumEquipmentSets)
            end,
            IgnoreSlotForSave = function()
              return checkFunc(ns.IgnoreSlotForSave)
            end,
            IsSlotIgnoredForSave = function()
              return checkFunc(ns.IsSlotIgnoredForSave)
            end,
            ModifyEquipmentSet = function()
              return checkFunc(ns.ModifyEquipmentSet)
            end,
            PickupEquipmentSet = function()
              return checkFunc(ns.PickupEquipmentSet)
            end,
            SaveEquipmentSet = function()
              return checkFunc(ns.SaveEquipmentSet)
            end,
            UnassignEquipmentSetSpec = function()
              return checkFunc(ns.UnassignEquipmentSetSpec)
            end,
            UnignoreSlotForSave = function()
              return checkFunc(ns.UnignoreSlotForSave)
            end,
            UseEquipmentSet = function()
              return checkFunc(ns.UseEquipmentSet)
            end,
          })
        end,
        C_EventToastManager = function()
          local ns = _G.C_EventToastManager
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetLevelUpDisplayToastsFromLevel = function()
              return checkFunc(ns.GetLevelUpDisplayToastsFromLevel)
            end,
            GetNextToastToDisplay = function()
              return checkFunc(ns.GetNextToastToDisplay)
            end,
            RemoveCurrentToast = function()
              return checkFunc(ns.RemoveCurrentToast)
            end,
          })
        end,
        C_FogOfWar = function()
          local ns = _G.C_FogOfWar
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetFogOfWarForMap = function()
              return checkFunc(ns.GetFogOfWarForMap)
            end,
            GetFogOfWarInfo = function()
              return checkFunc(ns.GetFogOfWarInfo)
            end,
          })
        end,
        C_FrameManager = function()
          local ns = _G.C_FrameManager
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetFrameVisibilityState = function()
              return checkFunc(ns.GetFrameVisibilityState)
            end,
          })
        end,
        C_FriendList = function()
          local ns = _G.C_FriendList
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            AddFriend = function()
              return checkFunc(ns.AddFriend)
            end,
            AddIgnore = function()
              return checkFunc(ns.AddIgnore)
            end,
            AddOrDelIgnore = function()
              return checkFunc(ns.AddOrDelIgnore)
            end,
            AddOrRemoveFriend = function()
              return checkFunc(ns.AddOrRemoveFriend)
            end,
            DelIgnore = function()
              return checkFunc(ns.DelIgnore)
            end,
            DelIgnoreByIndex = function()
              return checkFunc(ns.DelIgnoreByIndex)
            end,
            GetFriendInfo = function()
              return checkFunc(ns.GetFriendInfo)
            end,
            GetFriendInfoByIndex = function()
              return checkFunc(ns.GetFriendInfoByIndex)
            end,
            GetIgnoreName = function()
              return checkFunc(ns.GetIgnoreName)
            end,
            GetNumFriends = function()
              return checkFunc(ns.GetNumFriends)
            end,
            GetNumIgnores = function()
              return checkFunc(ns.GetNumIgnores)
            end,
            GetNumOnlineFriends = function()
              return checkFunc(ns.GetNumOnlineFriends)
            end,
            GetNumWhoResults = function()
              return checkFunc(ns.GetNumWhoResults)
            end,
            GetSelectedFriend = function()
              return checkFunc(ns.GetSelectedFriend)
            end,
            GetSelectedIgnore = function()
              return checkFunc(ns.GetSelectedIgnore)
            end,
            GetWhoInfo = function()
              return checkFunc(ns.GetWhoInfo)
            end,
            IsFriend = function()
              return checkFunc(ns.IsFriend)
            end,
            IsIgnored = function()
              return checkFunc(ns.IsIgnored)
            end,
            IsIgnoredByGuid = function()
              return checkFunc(ns.IsIgnoredByGuid)
            end,
            IsOnIgnoredList = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsOnIgnoredList))
                return
              end
              return checkFunc(ns.IsOnIgnoredList)
            end,
            RemoveFriend = function()
              return checkFunc(ns.RemoveFriend)
            end,
            RemoveFriendByIndex = function()
              return checkFunc(ns.RemoveFriendByIndex)
            end,
            SendWho = function()
              return checkFunc(ns.SendWho)
            end,
            SetFriendNotes = function()
              return checkFunc(ns.SetFriendNotes)
            end,
            SetFriendNotesByIndex = function()
              return checkFunc(ns.SetFriendNotesByIndex)
            end,
            SetSelectedFriend = function()
              return checkFunc(ns.SetSelectedFriend)
            end,
            SetSelectedIgnore = function()
              return checkFunc(ns.SetSelectedIgnore)
            end,
            SetWhoToUi = function()
              return checkFunc(ns.SetWhoToUi)
            end,
            ShowFriends = function()
              return checkFunc(ns.ShowFriends)
            end,
            SortWho = function()
              return checkFunc(ns.SortWho)
            end,
          })
        end,
        C_GamePad = function()
          local ns = _G.C_GamePad
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            AddSDLMapping = function()
              return checkFunc(ns.AddSDLMapping)
            end,
            ApplyConfigs = function()
              return checkFunc(ns.ApplyConfigs)
            end,
            AxisIndexToConfigName = function()
              return checkFunc(ns.AxisIndexToConfigName)
            end,
            ButtonBindingToIndex = function()
              return checkFunc(ns.ButtonBindingToIndex)
            end,
            ButtonIndexToBinding = function()
              return checkFunc(ns.ButtonIndexToBinding)
            end,
            ButtonIndexToConfigName = function()
              return checkFunc(ns.ButtonIndexToConfigName)
            end,
            ClearLedColor = function()
              return checkFunc(ns.ClearLedColor)
            end,
            DeleteConfig = function()
              return checkFunc(ns.DeleteConfig)
            end,
            GetActiveDeviceID = function()
              return checkFunc(ns.GetActiveDeviceID)
            end,
            GetAllConfigIDs = function()
              return checkFunc(ns.GetAllConfigIDs)
            end,
            GetAllDeviceIDs = function()
              return checkFunc(ns.GetAllDeviceIDs)
            end,
            GetCombinedDeviceID = function()
              return checkFunc(ns.GetCombinedDeviceID)
            end,
            GetConfig = function()
              return checkFunc(ns.GetConfig)
            end,
            GetDeviceMappedState = function()
              return checkFunc(ns.GetDeviceMappedState)
            end,
            GetDeviceRawState = function()
              return checkFunc(ns.GetDeviceRawState)
            end,
            GetLedColor = function()
              return checkFunc(ns.GetLedColor)
            end,
            GetPowerLevel = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetPowerLevel))
                return
              end
              return checkFunc(ns.GetPowerLevel)
            end,
            IsEnabled = function()
              return checkFunc(ns.IsEnabled)
            end,
            SetConfig = function()
              return checkFunc(ns.SetConfig)
            end,
            SetLedColor = function()
              return checkFunc(ns.SetLedColor)
            end,
            SetVibration = function()
              return checkFunc(ns.SetVibration)
            end,
            StickIndexToConfigName = function()
              return checkFunc(ns.StickIndexToConfigName)
            end,
            StopVibration = function()
              return checkFunc(ns.StopVibration)
            end,
          })
        end,
        C_Garrison = function()
          local ns = _G.C_Garrison
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            AddFollowerToMission = function()
              return checkFunc(ns.AddFollowerToMission)
            end,
            AllowMissionStartAboveSoftCap = function()
              return checkFunc(ns.AllowMissionStartAboveSoftCap)
            end,
            AreMissionFollowerRequirementsMet = function()
              return checkFunc(ns.AreMissionFollowerRequirementsMet)
            end,
            AssignFollowerToBuilding = function()
              return checkFunc(ns.AssignFollowerToBuilding)
            end,
            CanGenerateRecruits = function()
              return checkFunc(ns.CanGenerateRecruits)
            end,
            CanOpenMissionChest = function()
              return checkFunc(ns.CanOpenMissionChest)
            end,
            CanSetRecruitmentPreference = function()
              return checkFunc(ns.CanSetRecruitmentPreference)
            end,
            CanSpellTargetFollowerIDWithAddAbility = function()
              return checkFunc(ns.CanSpellTargetFollowerIDWithAddAbility)
            end,
            CanUpgradeGarrison = function()
              return checkFunc(ns.CanUpgradeGarrison)
            end,
            CancelConstruction = function()
              return checkFunc(ns.CancelConstruction)
            end,
            CastItemSpellOnFollowerAbility = function()
              return checkFunc(ns.CastItemSpellOnFollowerAbility)
            end,
            CastSpellOnFollower = function()
              return checkFunc(ns.CastSpellOnFollower)
            end,
            CastSpellOnFollowerAbility = function()
              return checkFunc(ns.CastSpellOnFollowerAbility)
            end,
            CastSpellOnMission = function()
              return checkFunc(ns.CastSpellOnMission)
            end,
            ClearCompleteTalent = function()
              return checkFunc(ns.ClearCompleteTalent)
            end,
            CloseArchitect = function()
              return checkFunc(ns.CloseArchitect)
            end,
            CloseGarrisonTradeskillNPC = function()
              return checkFunc(ns.CloseGarrisonTradeskillNPC)
            end,
            CloseMissionNPC = function()
              return checkFunc(ns.CloseMissionNPC)
            end,
            CloseRecruitmentNPC = function()
              return checkFunc(ns.CloseRecruitmentNPC)
            end,
            CloseTalentNPC = function()
              return checkFunc(ns.CloseTalentNPC)
            end,
            CloseTradeskillCrafter = function()
              return checkFunc(ns.CloseTradeskillCrafter)
            end,
            GenerateRecruits = function()
              return checkFunc(ns.GenerateRecruits)
            end,
            GetAllBonusAbilityEffects = function()
              return checkFunc(ns.GetAllBonusAbilityEffects)
            end,
            GetAllEncounterThreats = function()
              return checkFunc(ns.GetAllEncounterThreats)
            end,
            GetAutoCombatDamageClassValues = function()
              return checkFunc(ns.GetAutoCombatDamageClassValues)
            end,
            GetAutoMissionBoardState = function()
              return checkFunc(ns.GetAutoMissionBoardState)
            end,
            GetAutoMissionEnvironmentEffect = function()
              return checkFunc(ns.GetAutoMissionEnvironmentEffect)
            end,
            GetAutoMissionTargetingInfo = function()
              return checkFunc(ns.GetAutoMissionTargetingInfo)
            end,
            GetAutoMissionTargetingInfoForSpell = function()
              return checkFunc(ns.GetAutoMissionTargetingInfoForSpell)
            end,
            GetAutoTroops = function()
              return checkFunc(ns.GetAutoTroops)
            end,
            GetAvailableMissions = function()
              return checkFunc(ns.GetAvailableMissions)
            end,
            GetAvailableRecruits = function()
              return checkFunc(ns.GetAvailableRecruits)
            end,
            GetBasicMissionInfo = function()
              return checkFunc(ns.GetBasicMissionInfo)
            end,
            GetBuffedFollowersForMission = function()
              return checkFunc(ns.GetBuffedFollowersForMission)
            end,
            GetBuildingInfo = function()
              return checkFunc(ns.GetBuildingInfo)
            end,
            GetBuildingLockInfo = function()
              return checkFunc(ns.GetBuildingLockInfo)
            end,
            GetBuildingSizes = function()
              return checkFunc(ns.GetBuildingSizes)
            end,
            GetBuildingSpecInfo = function()
              return checkFunc(ns.GetBuildingSpecInfo)
            end,
            GetBuildingTimeRemaining = function()
              return checkFunc(ns.GetBuildingTimeRemaining)
            end,
            GetBuildingTooltip = function()
              return checkFunc(ns.GetBuildingTooltip)
            end,
            GetBuildingUpgradeInfo = function()
              return checkFunc(ns.GetBuildingUpgradeInfo)
            end,
            GetBuildings = function()
              return checkFunc(ns.GetBuildings)
            end,
            GetBuildingsForPlot = function()
              return checkFunc(ns.GetBuildingsForPlot)
            end,
            GetBuildingsForSize = function()
              return checkFunc(ns.GetBuildingsForSize)
            end,
            GetClassSpecCategoryInfo = function()
              return checkFunc(ns.GetClassSpecCategoryInfo)
            end,
            GetCombatAllyMission = function()
              return checkFunc(ns.GetCombatAllyMission)
            end,
            GetCombatLogSpellInfo = function()
              return checkFunc(ns.GetCombatLogSpellInfo)
            end,
            GetCompleteMissions = function()
              return checkFunc(ns.GetCompleteMissions)
            end,
            GetCompleteTalent = function()
              return checkFunc(ns.GetCompleteTalent)
            end,
            GetCurrencyTypes = function()
              return checkFunc(ns.GetCurrencyTypes)
            end,
            GetCurrentCypherEquipmentLevel = function()
              return checkFunc(ns.GetCurrentCypherEquipmentLevel)
            end,
            GetCurrentGarrTalentTreeFriendshipFactionID = function()
              return checkFunc(ns.GetCurrentGarrTalentTreeFriendshipFactionID)
            end,
            GetCurrentGarrTalentTreeID = function()
              return checkFunc(ns.GetCurrentGarrTalentTreeID)
            end,
            GetCyphersToNextEquipmentLevel = function()
              return checkFunc(ns.GetCyphersToNextEquipmentLevel)
            end,
            GetFollowerAbilities = function()
              return checkFunc(ns.GetFollowerAbilities)
            end,
            GetFollowerAbilityAtIndex = function()
              return checkFunc(ns.GetFollowerAbilityAtIndex)
            end,
            GetFollowerAbilityAtIndexByID = function()
              return checkFunc(ns.GetFollowerAbilityAtIndexByID)
            end,
            GetFollowerAbilityCounterMechanicInfo = function()
              return checkFunc(ns.GetFollowerAbilityCounterMechanicInfo)
            end,
            GetFollowerAbilityCountersForMechanicTypes = function()
              return checkFunc(ns.GetFollowerAbilityCountersForMechanicTypes)
            end,
            GetFollowerAbilityDescription = function()
              return checkFunc(ns.GetFollowerAbilityDescription)
            end,
            GetFollowerAbilityIcon = function()
              return checkFunc(ns.GetFollowerAbilityIcon)
            end,
            GetFollowerAbilityInfo = function()
              return checkFunc(ns.GetFollowerAbilityInfo)
            end,
            GetFollowerAbilityIsTrait = function()
              return checkFunc(ns.GetFollowerAbilityIsTrait)
            end,
            GetFollowerAbilityLink = function()
              return checkFunc(ns.GetFollowerAbilityLink)
            end,
            GetFollowerAbilityName = function()
              return checkFunc(ns.GetFollowerAbilityName)
            end,
            GetFollowerActivationCost = function()
              return checkFunc(ns.GetFollowerActivationCost)
            end,
            GetFollowerAutoCombatSpells = function()
              return checkFunc(ns.GetFollowerAutoCombatSpells)
            end,
            GetFollowerAutoCombatStats = function()
              return checkFunc(ns.GetFollowerAutoCombatStats)
            end,
            GetFollowerBiasForMission = function()
              return checkFunc(ns.GetFollowerBiasForMission)
            end,
            GetFollowerClassSpec = function()
              return checkFunc(ns.GetFollowerClassSpec)
            end,
            GetFollowerClassSpecAtlas = function()
              return checkFunc(ns.GetFollowerClassSpecAtlas)
            end,
            GetFollowerClassSpecByID = function()
              return checkFunc(ns.GetFollowerClassSpecByID)
            end,
            GetFollowerClassSpecName = function()
              return checkFunc(ns.GetFollowerClassSpecName)
            end,
            GetFollowerDisplayID = function()
              return checkFunc(ns.GetFollowerDisplayID)
            end,
            GetFollowerInfo = function()
              return checkFunc(ns.GetFollowerInfo)
            end,
            GetFollowerInfoForBuilding = function()
              return checkFunc(ns.GetFollowerInfoForBuilding)
            end,
            GetFollowerIsTroop = function()
              return checkFunc(ns.GetFollowerIsTroop)
            end,
            GetFollowerItemLevelAverage = function()
              return checkFunc(ns.GetFollowerItemLevelAverage)
            end,
            GetFollowerItems = function()
              return checkFunc(ns.GetFollowerItems)
            end,
            GetFollowerLevel = function()
              return checkFunc(ns.GetFollowerLevel)
            end,
            GetFollowerLevelXP = function()
              return checkFunc(ns.GetFollowerLevelXP)
            end,
            GetFollowerLink = function()
              return checkFunc(ns.GetFollowerLink)
            end,
            GetFollowerLinkByID = function()
              return checkFunc(ns.GetFollowerLinkByID)
            end,
            GetFollowerMissionCompleteInfo = function()
              return checkFunc(ns.GetFollowerMissionCompleteInfo)
            end,
            GetFollowerMissionTimeLeft = function()
              return checkFunc(ns.GetFollowerMissionTimeLeft)
            end,
            GetFollowerMissionTimeLeftSeconds = function()
              return checkFunc(ns.GetFollowerMissionTimeLeftSeconds)
            end,
            GetFollowerModelItems = function()
              return checkFunc(ns.GetFollowerModelItems)
            end,
            GetFollowerName = function()
              return checkFunc(ns.GetFollowerName)
            end,
            GetFollowerNameByID = function()
              return checkFunc(ns.GetFollowerNameByID)
            end,
            GetFollowerPortraitIconID = function()
              return checkFunc(ns.GetFollowerPortraitIconID)
            end,
            GetFollowerPortraitIconIDByID = function()
              return checkFunc(ns.GetFollowerPortraitIconIDByID)
            end,
            GetFollowerQuality = function()
              return checkFunc(ns.GetFollowerQuality)
            end,
            GetFollowerQualityTable = function()
              return checkFunc(ns.GetFollowerQualityTable)
            end,
            GetFollowerRecentlyGainedAbilityIDs = function()
              return checkFunc(ns.GetFollowerRecentlyGainedAbilityIDs)
            end,
            GetFollowerRecentlyGainedTraitIDs = function()
              return checkFunc(ns.GetFollowerRecentlyGainedTraitIDs)
            end,
            GetFollowerShipments = function()
              return checkFunc(ns.GetFollowerShipments)
            end,
            GetFollowerSoftCap = function()
              return checkFunc(ns.GetFollowerSoftCap)
            end,
            GetFollowerSourceTextByID = function()
              return checkFunc(ns.GetFollowerSourceTextByID)
            end,
            GetFollowerSpecializationAtIndex = function()
              return checkFunc(ns.GetFollowerSpecializationAtIndex)
            end,
            GetFollowerStatus = function()
              return checkFunc(ns.GetFollowerStatus)
            end,
            GetFollowerTraitAtIndex = function()
              return checkFunc(ns.GetFollowerTraitAtIndex)
            end,
            GetFollowerTraitAtIndexByID = function()
              return checkFunc(ns.GetFollowerTraitAtIndexByID)
            end,
            GetFollowerTypeByID = function()
              return checkFunc(ns.GetFollowerTypeByID)
            end,
            GetFollowerTypeByMissionID = function()
              return checkFunc(ns.GetFollowerTypeByMissionID)
            end,
            GetFollowerUnderBiasReason = function()
              return checkFunc(ns.GetFollowerUnderBiasReason)
            end,
            GetFollowerXP = function()
              return checkFunc(ns.GetFollowerXP)
            end,
            GetFollowerXPTable = function()
              return checkFunc(ns.GetFollowerXPTable)
            end,
            GetFollowerZoneSupportAbilities = function()
              return checkFunc(ns.GetFollowerZoneSupportAbilities)
            end,
            GetFollowers = function()
              return checkFunc(ns.GetFollowers)
            end,
            GetFollowersSpellsForMission = function()
              return checkFunc(ns.GetFollowersSpellsForMission)
            end,
            GetFollowersTraitsForMission = function()
              return checkFunc(ns.GetFollowersTraitsForMission)
            end,
            GetGarrisonInfo = function()
              return checkFunc(ns.GetGarrisonInfo)
            end,
            GetGarrisonPlotsInstancesForMap = function()
              return checkFunc(ns.GetGarrisonPlotsInstancesForMap)
            end,
            GetGarrisonTalentTreeCurrencyTypes = function()
              return checkFunc(ns.GetGarrisonTalentTreeCurrencyTypes)
            end,
            GetGarrisonTalentTreeType = function()
              return checkFunc(ns.GetGarrisonTalentTreeType)
            end,
            GetGarrisonUpgradeCost = function()
              return checkFunc(ns.GetGarrisonUpgradeCost)
            end,
            GetInProgressMissions = function()
              return checkFunc(ns.GetInProgressMissions)
            end,
            GetLandingPageGarrisonType = function()
              return checkFunc(ns.GetLandingPageGarrisonType)
            end,
            GetLandingPageItems = function()
              return checkFunc(ns.GetLandingPageItems)
            end,
            GetLandingPageShipmentCount = function()
              return checkFunc(ns.GetLandingPageShipmentCount)
            end,
            GetLandingPageShipmentInfo = function()
              return checkFunc(ns.GetLandingPageShipmentInfo)
            end,
            GetLandingPageShipmentInfoByContainerID = function()
              return checkFunc(ns.GetLandingPageShipmentInfoByContainerID)
            end,
            GetLooseShipments = function()
              return checkFunc(ns.GetLooseShipments)
            end,
            GetMaxCypherEquipmentLevel = function()
              return checkFunc(ns.GetMaxCypherEquipmentLevel)
            end,
            GetMissionBonusAbilityEffects = function()
              return checkFunc(ns.GetMissionBonusAbilityEffects)
            end,
            GetMissionCompleteEncounters = function()
              return checkFunc(ns.GetMissionCompleteEncounters)
            end,
            GetMissionCost = function()
              return checkFunc(ns.GetMissionCost)
            end,
            GetMissionDeploymentInfo = function()
              return checkFunc(ns.GetMissionDeploymentInfo)
            end,
            GetMissionDisplayIDs = function()
              return checkFunc(ns.GetMissionDisplayIDs)
            end,
            GetMissionEncounterIconInfo = function()
              return checkFunc(ns.GetMissionEncounterIconInfo)
            end,
            GetMissionLink = function()
              return checkFunc(ns.GetMissionLink)
            end,
            GetMissionMaxFollowers = function()
              return checkFunc(ns.GetMissionMaxFollowers)
            end,
            GetMissionName = function()
              return checkFunc(ns.GetMissionName)
            end,
            GetMissionRewardInfo = function()
              return checkFunc(ns.GetMissionRewardInfo)
            end,
            GetMissionSuccessChance = function()
              return checkFunc(ns.GetMissionSuccessChance)
            end,
            GetMissionTexture = function()
              return checkFunc(ns.GetMissionTexture)
            end,
            GetMissionTimes = function()
              return checkFunc(ns.GetMissionTimes)
            end,
            GetMissionUncounteredMechanics = function()
              return checkFunc(ns.GetMissionUncounteredMechanics)
            end,
            GetNumActiveFollowers = function()
              return checkFunc(ns.GetNumActiveFollowers)
            end,
            GetNumFollowerActivationsRemaining = function()
              return checkFunc(ns.GetNumFollowerActivationsRemaining)
            end,
            GetNumFollowerDailyActivations = function()
              return checkFunc(ns.GetNumFollowerDailyActivations)
            end,
            GetNumFollowers = function()
              return checkFunc(ns.GetNumFollowers)
            end,
            GetNumFollowersForMechanic = function()
              return checkFunc(ns.GetNumFollowersForMechanic)
            end,
            GetNumFollowersOnMission = function()
              return checkFunc(ns.GetNumFollowersOnMission)
            end,
            GetNumPendingShipments = function()
              return checkFunc(ns.GetNumPendingShipments)
            end,
            GetNumShipmentCurrencies = function()
              return checkFunc(ns.GetNumShipmentCurrencies)
            end,
            GetNumShipmentReagents = function()
              return checkFunc(ns.GetNumShipmentReagents)
            end,
            GetOwnedBuildingInfo = function()
              return checkFunc(ns.GetOwnedBuildingInfo)
            end,
            GetOwnedBuildingInfoAbbrev = function()
              return checkFunc(ns.GetOwnedBuildingInfoAbbrev)
            end,
            GetPartyBuffs = function()
              return checkFunc(ns.GetPartyBuffs)
            end,
            GetPartyMentorLevels = function()
              return checkFunc(ns.GetPartyMentorLevels)
            end,
            GetPartyMissionInfo = function()
              return checkFunc(ns.GetPartyMissionInfo)
            end,
            GetPendingShipmentInfo = function()
              return checkFunc(ns.GetPendingShipmentInfo)
            end,
            GetPlots = function()
              return checkFunc(ns.GetPlots)
            end,
            GetPlotsForBuilding = function()
              return checkFunc(ns.GetPlotsForBuilding)
            end,
            GetPossibleFollowersForBuilding = function()
              return checkFunc(ns.GetPossibleFollowersForBuilding)
            end,
            GetRecruitAbilities = function()
              return checkFunc(ns.GetRecruitAbilities)
            end,
            GetRecruiterAbilityCategories = function()
              return checkFunc(ns.GetRecruiterAbilityCategories)
            end,
            GetRecruiterAbilityList = function()
              return checkFunc(ns.GetRecruiterAbilityList)
            end,
            GetRecruitmentPreferences = function()
              return checkFunc(ns.GetRecruitmentPreferences)
            end,
            GetShipDeathAnimInfo = function()
              return checkFunc(ns.GetShipDeathAnimInfo)
            end,
            GetShipmentContainerInfo = function()
              return checkFunc(ns.GetShipmentContainerInfo)
            end,
            GetShipmentItemInfo = function()
              return checkFunc(ns.GetShipmentItemInfo)
            end,
            GetShipmentReagentCurrencyInfo = function()
              return checkFunc(ns.GetShipmentReagentCurrencyInfo)
            end,
            GetShipmentReagentInfo = function()
              return checkFunc(ns.GetShipmentReagentInfo)
            end,
            GetShipmentReagentItemLink = function()
              return checkFunc(ns.GetShipmentReagentItemLink)
            end,
            GetSpecChangeCost = function()
              return checkFunc(ns.GetSpecChangeCost)
            end,
            GetTabForPlot = function()
              return checkFunc(ns.GetTabForPlot)
            end,
            GetTalentInfo = function()
              return checkFunc(ns.GetTalentInfo)
            end,
            GetTalentPointsSpentInTalentTree = function()
              return checkFunc(ns.GetTalentPointsSpentInTalentTree)
            end,
            GetTalentTreeIDsByClassID = function()
              return checkFunc(ns.GetTalentTreeIDsByClassID)
            end,
            GetTalentTreeInfo = function()
              return checkFunc(ns.GetTalentTreeInfo)
            end,
            GetTalentTreeResetInfo = function()
              return checkFunc(ns.GetTalentTreeResetInfo)
            end,
            GetTalentTreeTalentPointResearchInfo = function()
              return checkFunc(ns.GetTalentTreeTalentPointResearchInfo)
            end,
            GetTalentUnlockWorldQuest = function()
              return checkFunc(ns.GetTalentUnlockWorldQuest)
            end,
            HasAdventures = function()
              return checkFunc(ns.HasAdventures)
            end,
            HasGarrison = function()
              return checkFunc(ns.HasGarrison)
            end,
            HasShipyard = function()
              return checkFunc(ns.HasShipyard)
            end,
            IsAboveFollowerSoftCap = function()
              return checkFunc(ns.IsAboveFollowerSoftCap)
            end,
            IsAtGarrisonMissionNPC = function()
              return checkFunc(ns.IsAtGarrisonMissionNPC)
            end,
            IsEnvironmentCountered = function()
              return checkFunc(ns.IsEnvironmentCountered)
            end,
            IsFollowerCollected = function()
              return checkFunc(ns.IsFollowerCollected)
            end,
            IsFollowerOnCompletedMission = function()
              return checkFunc(ns.IsFollowerOnCompletedMission)
            end,
            IsInvasionAvailable = function()
              return checkFunc(ns.IsInvasionAvailable)
            end,
            IsMechanicFullyCountered = function()
              return checkFunc(ns.IsMechanicFullyCountered)
            end,
            IsOnGarrisonMap = function()
              return checkFunc(ns.IsOnGarrisonMap)
            end,
            IsOnShipmentQuestForNPC = function()
              return checkFunc(ns.IsOnShipmentQuestForNPC)
            end,
            IsOnShipyardMap = function()
              return checkFunc(ns.IsOnShipyardMap)
            end,
            IsPlayerInGarrison = function()
              return checkFunc(ns.IsPlayerInGarrison)
            end,
            IsTalentConditionMet = function()
              return checkFunc(ns.IsTalentConditionMet)
            end,
            IsUsingPartyGarrison = function()
              return checkFunc(ns.IsUsingPartyGarrison)
            end,
            IsVisitGarrisonAvailable = function()
              return checkFunc(ns.IsVisitGarrisonAvailable)
            end,
            MarkMissionComplete = function()
              return checkFunc(ns.MarkMissionComplete)
            end,
            MissionBonusRoll = function()
              return checkFunc(ns.MissionBonusRoll)
            end,
            PlaceBuilding = function()
              return checkFunc(ns.PlaceBuilding)
            end,
            RecruitFollower = function()
              return checkFunc(ns.RecruitFollower)
            end,
            RegenerateCombatLog = function()
              return checkFunc(ns.RegenerateCombatLog)
            end,
            RemoveFollower = function()
              return checkFunc(ns.RemoveFollower)
            end,
            RemoveFollowerFromBuilding = function()
              return checkFunc(ns.RemoveFollowerFromBuilding)
            end,
            RemoveFollowerFromMission = function()
              return checkFunc(ns.RemoveFollowerFromMission)
            end,
            RenameFollower = function()
              return checkFunc(ns.RenameFollower)
            end,
            RequestClassSpecCategoryInfo = function()
              return checkFunc(ns.RequestClassSpecCategoryInfo)
            end,
            RequestGarrisonUpgradeable = function()
              return checkFunc(ns.RequestGarrisonUpgradeable)
            end,
            RequestLandingPageShipmentInfo = function()
              return checkFunc(ns.RequestLandingPageShipmentInfo)
            end,
            RequestShipmentCreation = function()
              return checkFunc(ns.RequestShipmentCreation)
            end,
            RequestShipmentInfo = function()
              return checkFunc(ns.RequestShipmentInfo)
            end,
            ResearchTalent = function()
              return checkFunc(ns.ResearchTalent)
            end,
            RushHealAllFollowers = function()
              return checkFunc(ns.RushHealAllFollowers)
            end,
            RushHealFollower = function()
              return checkFunc(ns.RushHealFollower)
            end,
            SearchForFollower = function()
              return checkFunc(ns.SearchForFollower)
            end,
            SetAutoCombatSpellFastForward = function()
              return checkFunc(ns.SetAutoCombatSpellFastForward)
            end,
            SetBuildingActive = function()
              return checkFunc(ns.SetBuildingActive)
            end,
            SetBuildingSpecialization = function()
              return checkFunc(ns.SetBuildingSpecialization)
            end,
            SetFollowerFavorite = function()
              return checkFunc(ns.SetFollowerFavorite)
            end,
            SetFollowerInactive = function()
              return checkFunc(ns.SetFollowerInactive)
            end,
            SetRecruitmentPreferences = function()
              return checkFunc(ns.SetRecruitmentPreferences)
            end,
            SetUsingPartyGarrison = function()
              return checkFunc(ns.SetUsingPartyGarrison)
            end,
            ShouldShowMapTab = function()
              return checkFunc(ns.ShouldShowMapTab)
            end,
            ShowFollowerNameInErrorMessage = function()
              return checkFunc(ns.ShowFollowerNameInErrorMessage)
            end,
            StartMission = function()
              return checkFunc(ns.StartMission)
            end,
            SwapBuildings = function()
              return checkFunc(ns.SwapBuildings)
            end,
            TargetSpellHasFollowerItemLevelUpgrade = function()
              return checkFunc(ns.TargetSpellHasFollowerItemLevelUpgrade)
            end,
            TargetSpellHasFollowerReroll = function()
              return checkFunc(ns.TargetSpellHasFollowerReroll)
            end,
            TargetSpellHasFollowerTemporaryAbility = function()
              return checkFunc(ns.TargetSpellHasFollowerTemporaryAbility)
            end,
            UpgradeBuilding = function()
              return checkFunc(ns.UpgradeBuilding)
            end,
            UpgradeGarrison = function()
              return checkFunc(ns.UpgradeGarrison)
            end,
          })
        end,
        C_GossipInfo = function()
          local ns = _G.C_GossipInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            CloseGossip = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CloseGossip))
                return
              end
              return checkFunc(ns.CloseGossip)
            end,
            ForceGossip = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ForceGossip))
                return
              end
              return checkFunc(ns.ForceGossip)
            end,
            GetActiveQuests = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetActiveQuests))
                return
              end
              return checkFunc(ns.GetActiveQuests)
            end,
            GetAvailableQuests = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetAvailableQuests))
                return
              end
              return checkFunc(ns.GetAvailableQuests)
            end,
            GetCompletedOptionDescriptionString = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetCompletedOptionDescriptionString))
                return
              end
              return checkFunc(ns.GetCompletedOptionDescriptionString)
            end,
            GetCustomGossipDescriptionString = function()
              return checkFunc(ns.GetCustomGossipDescriptionString)
            end,
            GetNumActiveQuests = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetNumActiveQuests))
                return
              end
              return checkFunc(ns.GetNumActiveQuests)
            end,
            GetNumAvailableQuests = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetNumAvailableQuests))
                return
              end
              return checkFunc(ns.GetNumAvailableQuests)
            end,
            GetNumOptions = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetNumOptions))
                return
              end
              return checkFunc(ns.GetNumOptions)
            end,
            GetOptions = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetOptions))
                return
              end
              return checkFunc(ns.GetOptions)
            end,
            GetPoiForUiMapID = function()
              return checkFunc(ns.GetPoiForUiMapID)
            end,
            GetPoiInfo = function()
              return checkFunc(ns.GetPoiInfo)
            end,
            GetText = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetText))
                return
              end
              return checkFunc(ns.GetText)
            end,
            RefreshOptions = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.RefreshOptions))
                return
              end
              return checkFunc(ns.RefreshOptions)
            end,
            SelectActiveQuest = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SelectActiveQuest))
                return
              end
              return checkFunc(ns.SelectActiveQuest)
            end,
            SelectAvailableQuest = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SelectAvailableQuest))
                return
              end
              return checkFunc(ns.SelectAvailableQuest)
            end,
            SelectOption = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SelectOption))
                return
              end
              return checkFunc(ns.SelectOption)
            end,
          })
        end,
        C_GuildInfo = function()
          local ns = _G.C_GuildInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            CanEditOfficerNote = function()
              return checkFunc(ns.CanEditOfficerNote)
            end,
            CanSpeakInGuildChat = function()
              return checkFunc(ns.CanSpeakInGuildChat)
            end,
            CanViewOfficerNote = function()
              return checkFunc(ns.CanViewOfficerNote)
            end,
            GetGuildNewsInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetGuildNewsInfo))
                return
              end
              return checkFunc(ns.GetGuildNewsInfo)
            end,
            GetGuildRankOrder = function()
              return checkFunc(ns.GetGuildRankOrder)
            end,
            GetGuildTabardInfo = function()
              return checkFunc(ns.GetGuildTabardInfo)
            end,
            GuildControlGetRankFlags = function()
              return checkFunc(ns.GuildControlGetRankFlags)
            end,
            GuildRoster = function()
              return checkFunc(ns.GuildRoster)
            end,
            IsGuildOfficer = function()
              return checkFunc(ns.IsGuildOfficer)
            end,
            IsGuildRankAssignmentAllowed = function()
              return checkFunc(ns.IsGuildRankAssignmentAllowed)
            end,
            QueryGuildMemberRecipes = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.QueryGuildMemberRecipes))
                return
              end
              return checkFunc(ns.QueryGuildMemberRecipes)
            end,
            QueryGuildMembersForRecipe = function()
              return checkFunc(ns.QueryGuildMembersForRecipe)
            end,
            RemoveFromGuild = function()
              return checkFunc(ns.RemoveFromGuild)
            end,
            SetGuildRankOrder = function()
              return checkFunc(ns.SetGuildRankOrder)
            end,
            SetNote = function()
              return checkFunc(ns.SetNote)
            end,
          })
        end,
        C_Heirloom = function()
          local ns = _G.C_Heirloom
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            CanHeirloomUpgradeFromPending = function()
              return checkFunc(ns.CanHeirloomUpgradeFromPending)
            end,
            CreateHeirloom = function()
              return checkFunc(ns.CreateHeirloom)
            end,
            GetClassAndSpecFilters = function()
              return checkFunc(ns.GetClassAndSpecFilters)
            end,
            GetCollectedHeirloomFilter = function()
              return checkFunc(ns.GetCollectedHeirloomFilter)
            end,
            GetHeirloomInfo = function()
              return checkFunc(ns.GetHeirloomInfo)
            end,
            GetHeirloomItemIDFromDisplayedIndex = function()
              return checkFunc(ns.GetHeirloomItemIDFromDisplayedIndex)
            end,
            GetHeirloomItemIDs = function()
              return checkFunc(ns.GetHeirloomItemIDs)
            end,
            GetHeirloomLink = function()
              return checkFunc(ns.GetHeirloomLink)
            end,
            GetHeirloomMaxUpgradeLevel = function()
              return checkFunc(ns.GetHeirloomMaxUpgradeLevel)
            end,
            GetHeirloomSourceFilter = function()
              return checkFunc(ns.GetHeirloomSourceFilter)
            end,
            GetNumDisplayedHeirlooms = function()
              return checkFunc(ns.GetNumDisplayedHeirlooms)
            end,
            GetNumHeirlooms = function()
              return checkFunc(ns.GetNumHeirlooms)
            end,
            GetNumKnownHeirlooms = function()
              return checkFunc(ns.GetNumKnownHeirlooms)
            end,
            GetUncollectedHeirloomFilter = function()
              return checkFunc(ns.GetUncollectedHeirloomFilter)
            end,
            IsItemHeirloom = function()
              return checkFunc(ns.IsItemHeirloom)
            end,
            IsPendingHeirloomUpgrade = function()
              return checkFunc(ns.IsPendingHeirloomUpgrade)
            end,
            PlayerHasHeirloom = function()
              return checkFunc(ns.PlayerHasHeirloom)
            end,
            SetClassAndSpecFilters = function()
              return checkFunc(ns.SetClassAndSpecFilters)
            end,
            SetCollectedHeirloomFilter = function()
              return checkFunc(ns.SetCollectedHeirloomFilter)
            end,
            SetHeirloomSourceFilter = function()
              return checkFunc(ns.SetHeirloomSourceFilter)
            end,
            SetSearch = function()
              return checkFunc(ns.SetSearch)
            end,
            SetUncollectedHeirloomFilter = function()
              return checkFunc(ns.SetUncollectedHeirloomFilter)
            end,
            ShouldShowHeirloomHelp = function()
              return checkFunc(ns.ShouldShowHeirloomHelp)
            end,
            UpgradeHeirloom = function()
              return checkFunc(ns.UpgradeHeirloom)
            end,
          })
        end,
        C_HeirloomInfo = function()
          local ns = _G.C_HeirloomInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            AreAllCollectionFiltersChecked = function()
              return checkFunc(ns.AreAllCollectionFiltersChecked)
            end,
            AreAllSourceFiltersChecked = function()
              return checkFunc(ns.AreAllSourceFiltersChecked)
            end,
            IsHeirloomSourceValid = function()
              return checkFunc(ns.IsHeirloomSourceValid)
            end,
            IsUsingDefaultFilters = function()
              return checkFunc(ns.IsUsingDefaultFilters)
            end,
            SetAllCollectionFilters = function()
              return checkFunc(ns.SetAllCollectionFilters)
            end,
            SetAllSourceFilters = function()
              return checkFunc(ns.SetAllSourceFilters)
            end,
            SetDefaultFilters = function()
              return checkFunc(ns.SetDefaultFilters)
            end,
          })
        end,
        C_IncomingSummon = function()
          local ns = _G.C_IncomingSummon
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            HasIncomingSummon = function()
              return checkFunc(ns.HasIncomingSummon)
            end,
            IncomingSummonStatus = function()
              return checkFunc(ns.IncomingSummonStatus)
            end,
          })
        end,
        C_InvasionInfo = function()
          local ns = _G.C_InvasionInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            AreInvasionsAvailable = function()
              return checkFunc(ns.AreInvasionsAvailable)
            end,
            GetInvasionForUiMapID = function()
              return checkFunc(ns.GetInvasionForUiMapID)
            end,
            GetInvasionInfo = function()
              return checkFunc(ns.GetInvasionInfo)
            end,
            GetInvasionTimeLeft = function()
              return checkFunc(ns.GetInvasionTimeLeft)
            end,
          })
        end,
        C_IslandsQueue = function()
          local ns = _G.C_IslandsQueue
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            CloseIslandsQueueScreen = function()
              return checkFunc(ns.CloseIslandsQueueScreen)
            end,
            GetIslandDifficultyInfo = function()
              return checkFunc(ns.GetIslandDifficultyInfo)
            end,
            GetIslandsMaxGroupSize = function()
              return checkFunc(ns.GetIslandsMaxGroupSize)
            end,
            GetIslandsWeeklyQuestID = function()
              return checkFunc(ns.GetIslandsWeeklyQuestID)
            end,
            QueueForIsland = function()
              return checkFunc(ns.QueueForIsland)
            end,
            RequestPreloadRewardData = function()
              return checkFunc(ns.RequestPreloadRewardData)
            end,
          })
        end,
        C_Item = function()
          local ns = _G.C_Item
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            CanItemTransmogAppearance = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanItemTransmogAppearance))
                return
              end
              return checkFunc(ns.CanItemTransmogAppearance)
            end,
            CanScrapItem = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanScrapItem))
                return
              end
              return checkFunc(ns.CanScrapItem)
            end,
            CanViewItemPowers = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanViewItemPowers))
                return
              end
              return checkFunc(ns.CanViewItemPowers)
            end,
            DoesItemExist = function()
              return checkFunc(ns.DoesItemExist)
            end,
            DoesItemExistByID = function()
              return checkFunc(ns.DoesItemExistByID)
            end,
            DoesItemMatchBonusTreeReplacement = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.DoesItemMatchBonusTreeReplacement))
                return
              end
              return checkFunc(ns.DoesItemMatchBonusTreeReplacement)
            end,
            GetAppliedItemTransmogInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetAppliedItemTransmogInfo))
                return
              end
              return checkFunc(ns.GetAppliedItemTransmogInfo)
            end,
            GetBaseItemTransmogInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetBaseItemTransmogInfo))
                return
              end
              return checkFunc(ns.GetBaseItemTransmogInfo)
            end,
            GetCurrentItemLevel = function()
              return checkFunc(ns.GetCurrentItemLevel)
            end,
            GetCurrentItemTransmogInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetCurrentItemTransmogInfo))
                return
              end
              return checkFunc(ns.GetCurrentItemTransmogInfo)
            end,
            GetItemConversionOutputIcon = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetItemConversionOutputIcon))
                return
              end
              return checkFunc(ns.GetItemConversionOutputIcon)
            end,
            GetItemGUID = function()
              return checkFunc(ns.GetItemGUID)
            end,
            GetItemID = function()
              return checkFunc(ns.GetItemID)
            end,
            GetItemIcon = function()
              return checkFunc(ns.GetItemIcon)
            end,
            GetItemIconByID = function()
              return checkFunc(ns.GetItemIconByID)
            end,
            GetItemInventoryType = function()
              return checkFunc(ns.GetItemInventoryType)
            end,
            GetItemInventoryTypeByID = function()
              return checkFunc(ns.GetItemInventoryTypeByID)
            end,
            GetItemLink = function()
              return checkFunc(ns.GetItemLink)
            end,
            GetItemName = function()
              return checkFunc(ns.GetItemName)
            end,
            GetItemNameByID = function()
              return checkFunc(ns.GetItemNameByID)
            end,
            GetItemQuality = function()
              return checkFunc(ns.GetItemQuality)
            end,
            GetItemQualityByID = function()
              return checkFunc(ns.GetItemQualityByID)
            end,
            GetItemUniquenessByID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetItemUniquenessByID))
                return
              end
              return checkFunc(ns.GetItemUniquenessByID)
            end,
            GetLimitedCurrencyItemInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetLimitedCurrencyItemInfo))
                return
              end
              return checkFunc(ns.GetLimitedCurrencyItemInfo)
            end,
            GetStackCount = function()
              return checkFunc(ns.GetStackCount)
            end,
            IsAnimaItemByID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsAnimaItemByID))
                return
              end
              return checkFunc(ns.IsAnimaItemByID)
            end,
            IsBound = function()
              return checkFunc(ns.IsBound)
            end,
            IsDressableItemByID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsDressableItemByID))
                return
              end
              return checkFunc(ns.IsDressableItemByID)
            end,
            IsItemConduit = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsItemConduit))
                return
              end
              return checkFunc(ns.IsItemConduit)
            end,
            IsItemConvertibleAndValidForPlayer = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsItemConvertibleAndValidForPlayer))
                return
              end
              return checkFunc(ns.IsItemConvertibleAndValidForPlayer)
            end,
            IsItemCorrupted = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsItemCorrupted))
                return
              end
              return checkFunc(ns.IsItemCorrupted)
            end,
            IsItemCorruptionRelated = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsItemCorruptionRelated))
                return
              end
              return checkFunc(ns.IsItemCorruptionRelated)
            end,
            IsItemCorruptionResistant = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsItemCorruptionResistant))
                return
              end
              return checkFunc(ns.IsItemCorruptionResistant)
            end,
            IsItemDataCached = function()
              return checkFunc(ns.IsItemDataCached)
            end,
            IsItemDataCachedByID = function()
              return checkFunc(ns.IsItemDataCachedByID)
            end,
            IsItemKeystoneByID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsItemKeystoneByID))
                return
              end
              return checkFunc(ns.IsItemKeystoneByID)
            end,
            IsItemSpecificToPlayerClass = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsItemSpecificToPlayerClass))
                return
              end
              return checkFunc(ns.IsItemSpecificToPlayerClass)
            end,
            IsLocked = function()
              return checkFunc(ns.IsLocked)
            end,
            LockItem = function()
              return checkFunc(ns.LockItem)
            end,
            LockItemByGUID = function()
              return checkFunc(ns.LockItemByGUID)
            end,
            RequestLoadItemData = function()
              return checkFunc(ns.RequestLoadItemData)
            end,
            RequestLoadItemDataByID = function()
              return checkFunc(ns.RequestLoadItemDataByID)
            end,
            UnlockItem = function()
              return checkFunc(ns.UnlockItem)
            end,
            UnlockItemByGUID = function()
              return checkFunc(ns.UnlockItemByGUID)
            end,
          })
        end,
        C_ItemInteraction = function()
          local ns = _G.C_ItemInteraction
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            ClearPendingItem = function()
              return checkFunc(ns.ClearPendingItem)
            end,
            CloseUI = function()
              return checkFunc(ns.CloseUI)
            end,
            GetChargeInfo = function()
              return checkFunc(ns.GetChargeInfo)
            end,
            GetItemConversionCurrencyCost = function()
              return checkFunc(ns.GetItemConversionCurrencyCost)
            end,
            GetItemInteractionInfo = function()
              return checkFunc(ns.GetItemInteractionInfo)
            end,
            GetItemInteractionSpellId = function()
              return checkFunc(ns.GetItemInteractionSpellId)
            end,
            InitializeFrame = function()
              return checkFunc(ns.InitializeFrame)
            end,
            PerformItemInteraction = function()
              return checkFunc(ns.PerformItemInteraction)
            end,
            Reset = function()
              return checkFunc(ns.Reset)
            end,
            SetCorruptionReforgerItemTooltip = function()
              return checkFunc(ns.SetCorruptionReforgerItemTooltip)
            end,
            SetItemConversionOutputTooltip = function()
              return checkFunc(ns.SetItemConversionOutputTooltip)
            end,
            SetPendingItem = function()
              return checkFunc(ns.SetPendingItem)
            end,
          })
        end,
        C_ItemSocketInfo = function()
          local ns = _G.C_ItemSocketInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            CompleteSocketing = function()
              return checkFunc(ns.CompleteSocketing)
            end,
          })
        end,
        C_ItemUpgrade = function()
          local ns = _G.C_ItemUpgrade
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            CanUpgradeItem = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanUpgradeItem))
                return
              end
              return checkFunc(ns.CanUpgradeItem)
            end,
            ClearItemUpgrade = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ClearItemUpgrade))
                return
              end
              return checkFunc(ns.ClearItemUpgrade)
            end,
            CloseItemUpgrade = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CloseItemUpgrade))
                return
              end
              return checkFunc(ns.CloseItemUpgrade)
            end,
            GetItemHyperlink = function()
              return checkFunc(ns.GetItemHyperlink)
            end,
            GetItemUpgradeCurrentLevel = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetItemUpgradeCurrentLevel))
                return
              end
              return checkFunc(ns.GetItemUpgradeCurrentLevel)
            end,
            GetItemUpgradeEffect = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetItemUpgradeEffect))
                return
              end
              return checkFunc(ns.GetItemUpgradeEffect)
            end,
            GetItemUpgradeItemInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetItemUpgradeItemInfo))
                return
              end
              return checkFunc(ns.GetItemUpgradeItemInfo)
            end,
            GetItemUpgradePvpItemLevelDeltaValues = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetItemUpgradePvpItemLevelDeltaValues))
                return
              end
              return checkFunc(ns.GetItemUpgradePvpItemLevelDeltaValues)
            end,
            GetNumItemUpgradeEffects = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetNumItemUpgradeEffects))
                return
              end
              return checkFunc(ns.GetNumItemUpgradeEffects)
            end,
            SetItemUpgradeFromCursorItem = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetItemUpgradeFromCursorItem))
                return
              end
              return checkFunc(ns.SetItemUpgradeFromCursorItem)
            end,
            SetItemUpgradeFromLocation = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetItemUpgradeFromLocation))
                return
              end
              return checkFunc(ns.SetItemUpgradeFromLocation)
            end,
            UpgradeItem = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.UpgradeItem))
                return
              end
              return checkFunc(ns.UpgradeItem)
            end,
          })
        end,
        C_KeyBindings = function()
          local ns = _G.C_KeyBindings
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetCustomBindingType = function()
              return checkFunc(ns.GetCustomBindingType)
            end,
          })
        end,
        C_LFGInfo = function()
          local ns = _G.C_LFGInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            CanPlayerUseGroupFinder = function()
              return checkFunc(ns.CanPlayerUseGroupFinder)
            end,
            CanPlayerUseLFD = function()
              return checkFunc(ns.CanPlayerUseLFD)
            end,
            CanPlayerUseLFR = function()
              return checkFunc(ns.CanPlayerUseLFR)
            end,
            CanPlayerUsePVP = function()
              return checkFunc(ns.CanPlayerUsePVP)
            end,
            CanPlayerUsePremadeGroup = function()
              return checkFunc(ns.CanPlayerUsePremadeGroup)
            end,
            ConfirmLfgExpandSearch = function()
              return checkFunc(ns.ConfirmLfgExpandSearch)
            end,
            GetAllEntriesForCategory = function()
              return checkFunc(ns.GetAllEntriesForCategory)
            end,
            GetDungeonInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetDungeonInfo))
                return
              end
              return checkFunc(ns.GetDungeonInfo)
            end,
            GetLFDLockStates = function()
              return checkFunc(ns.GetLFDLockStates)
            end,
            GetRoleCheckDifficultyDetails = function()
              return checkFunc(ns.GetRoleCheckDifficultyDetails)
            end,
            HideNameFromUI = function()
              return checkFunc(ns.HideNameFromUI)
            end,
          })
        end,
        C_LFGList = function()
          local ns = _G.C_LFGList
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            AcceptInvite = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.AcceptInvite))
                return
              end
              return checkFunc(ns.AcceptInvite)
            end,
            ApplyToGroup = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ApplyToGroup))
                return
              end
              return checkFunc(ns.ApplyToGroup)
            end,
            CanActiveEntryUseAutoAccept = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanActiveEntryUseAutoAccept))
                return
              end
              return checkFunc(ns.CanActiveEntryUseAutoAccept)
            end,
            CanCreateQuestGroup = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanCreateQuestGroup))
                return
              end
              return checkFunc(ns.CanCreateQuestGroup)
            end,
            CancelApplication = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CancelApplication))
                return
              end
              return checkFunc(ns.CancelApplication)
            end,
            ClearApplicationTextFields = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ClearApplicationTextFields))
                return
              end
              return checkFunc(ns.ClearApplicationTextFields)
            end,
            ClearCreationTextFields = function()
              return checkFunc(ns.ClearCreationTextFields)
            end,
            ClearSearchResults = function()
              return checkFunc(ns.ClearSearchResults)
            end,
            ClearSearchTextFields = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ClearSearchTextFields))
                return
              end
              return checkFunc(ns.ClearSearchTextFields)
            end,
            CopyActiveEntryInfoToCreationFields = function()
              return checkFunc(ns.CopyActiveEntryInfoToCreationFields)
            end,
            CreateListing = function()
              return checkFunc(ns.CreateListing)
            end,
            DeclineApplicant = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.DeclineApplicant))
                return
              end
              return checkFunc(ns.DeclineApplicant)
            end,
            DeclineInvite = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.DeclineInvite))
                return
              end
              return checkFunc(ns.DeclineInvite)
            end,
            DoesEntryTitleMatchPrebuiltTitle = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.DoesEntryTitleMatchPrebuiltTitle))
                return
              end
              return checkFunc(ns.DoesEntryTitleMatchPrebuiltTitle)
            end,
            GetActiveEntryInfo = function()
              return checkFunc(ns.GetActiveEntryInfo)
            end,
            GetActivityFullName = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetActivityFullName))
                return
              end
              return checkFunc(ns.GetActivityFullName)
            end,
            GetActivityGroupInfo = function()
              return checkFunc(ns.GetActivityGroupInfo)
            end,
            GetActivityIDForQuestID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetActivityIDForQuestID))
                return
              end
              return checkFunc(ns.GetActivityIDForQuestID)
            end,
            GetActivityInfoExpensive = function()
              return checkFunc(ns.GetActivityInfoExpensive)
            end,
            GetActivityInfoTable = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetActivityInfoTable))
                return
              end
              return checkFunc(ns.GetActivityInfoTable)
            end,
            GetApplicantDungeonScoreForListing = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetApplicantDungeonScoreForListing))
                return
              end
              return checkFunc(ns.GetApplicantDungeonScoreForListing)
            end,
            GetApplicantInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetApplicantInfo))
                return
              end
              return checkFunc(ns.GetApplicantInfo)
            end,
            GetApplicantMemberInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetApplicantMemberInfo))
                return
              end
              return checkFunc(ns.GetApplicantMemberInfo)
            end,
            GetApplicantMemberStats = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetApplicantMemberStats))
                return
              end
              return checkFunc(ns.GetApplicantMemberStats)
            end,
            GetApplicantPvpRatingInfoForListing = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetApplicantPvpRatingInfoForListing))
                return
              end
              return checkFunc(ns.GetApplicantPvpRatingInfoForListing)
            end,
            GetApplicants = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetApplicants))
                return
              end
              return checkFunc(ns.GetApplicants)
            end,
            GetApplicationInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetApplicationInfo))
                return
              end
              return checkFunc(ns.GetApplicationInfo)
            end,
            GetApplications = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetApplications))
                return
              end
              return checkFunc(ns.GetApplications)
            end,
            GetAvailableActivities = function()
              return checkFunc(ns.GetAvailableActivities)
            end,
            GetAvailableActivityGroups = function()
              return checkFunc(ns.GetAvailableActivityGroups)
            end,
            GetAvailableCategories = function()
              return checkFunc(ns.GetAvailableCategories)
            end,
            GetAvailableLanguageSearchFilter = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetAvailableLanguageSearchFilter))
                return
              end
              return checkFunc(ns.GetAvailableLanguageSearchFilter)
            end,
            GetAvailableRoles = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetAvailableRoles))
                return
              end
              return checkFunc(ns.GetAvailableRoles)
            end,
            GetDefaultLanguageSearchFilter = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetDefaultLanguageSearchFilter))
                return
              end
              return checkFunc(ns.GetDefaultLanguageSearchFilter)
            end,
            GetFilteredSearchResults = function()
              return checkFunc(ns.GetFilteredSearchResults)
            end,
            GetKeystoneForActivity = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetKeystoneForActivity))
                return
              end
              return checkFunc(ns.GetKeystoneForActivity)
            end,
            GetLanguageSearchFilter = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetLanguageSearchFilter))
                return
              end
              return checkFunc(ns.GetLanguageSearchFilter)
            end,
            GetLfgCategoryInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetLfgCategoryInfo))
                return
              end
              return checkFunc(ns.GetLfgCategoryInfo)
            end,
            GetNumApplicants = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetNumApplicants))
                return
              end
              return checkFunc(ns.GetNumApplicants)
            end,
            GetNumApplications = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetNumApplications))
                return
              end
              return checkFunc(ns.GetNumApplications)
            end,
            GetNumInvitedApplicantMembers = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetNumInvitedApplicantMembers))
                return
              end
              return checkFunc(ns.GetNumInvitedApplicantMembers)
            end,
            GetNumPendingApplicantMembers = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetNumPendingApplicantMembers))
                return
              end
              return checkFunc(ns.GetNumPendingApplicantMembers)
            end,
            GetOwnedKeystoneActivityAndGroupAndLevel = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetOwnedKeystoneActivityAndGroupAndLevel))
                return
              end
              return checkFunc(ns.GetOwnedKeystoneActivityAndGroupAndLevel)
            end,
            GetPlaystyleString = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetPlaystyleString))
                return
              end
              return checkFunc(ns.GetPlaystyleString)
            end,
            GetRoleCheckInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetRoleCheckInfo))
                return
              end
              return checkFunc(ns.GetRoleCheckInfo)
            end,
            GetSearchResultEncounterInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetSearchResultEncounterInfo))
                return
              end
              return checkFunc(ns.GetSearchResultEncounterInfo)
            end,
            GetSearchResultFriends = function()
              return checkFunc(ns.GetSearchResultFriends)
            end,
            GetSearchResultInfo = function()
              return checkFunc(ns.GetSearchResultInfo)
            end,
            GetSearchResultLeaderInfo = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetSearchResultLeaderInfo))
                return
              end
              return checkFunc(ns.GetSearchResultLeaderInfo)
            end,
            GetSearchResultMemberCounts = function()
              return checkFunc(ns.GetSearchResultMemberCounts)
            end,
            GetSearchResultMemberInfo = function()
              return checkFunc(ns.GetSearchResultMemberInfo)
            end,
            GetSearchResults = function()
              return checkFunc(ns.GetSearchResults)
            end,
            HasActiveEntryInfo = function()
              return checkFunc(ns.HasActiveEntryInfo)
            end,
            HasActivityList = function()
              return checkFunc(ns.HasActivityList)
            end,
            HasSearchResultInfo = function()
              return checkFunc(ns.HasSearchResultInfo)
            end,
            InviteApplicant = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.InviteApplicant))
                return
              end
              return checkFunc(ns.InviteApplicant)
            end,
            IsCurrentlyApplying = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsCurrentlyApplying))
                return
              end
              return checkFunc(ns.IsCurrentlyApplying)
            end,
            IsLookingForGroupEnabled = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsLookingForGroupEnabled))
                return
              end
              return checkFunc(ns.IsLookingForGroupEnabled)
            end,
            IsPlayerAuthenticatedForLFG = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsPlayerAuthenticatedForLFG))
                return
              end
              return checkFunc(ns.IsPlayerAuthenticatedForLFG)
            end,
            RefreshApplicants = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.RefreshApplicants))
                return
              end
              return checkFunc(ns.RefreshApplicants)
            end,
            RemoveApplicant = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.RemoveApplicant))
                return
              end
              return checkFunc(ns.RemoveApplicant)
            end,
            RemoveListing = function()
              return checkFunc(ns.RemoveListing)
            end,
            ReportSearchResult = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ReportSearchResult))
                return
              end
              return checkFunc(ns.ReportSearchResult)
            end,
            RequestAvailableActivities = function()
              return checkFunc(ns.RequestAvailableActivities)
            end,
            SaveLanguageSearchFilter = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SaveLanguageSearchFilter))
                return
              end
              return checkFunc(ns.SaveLanguageSearchFilter)
            end,
            Search = function()
              return checkFunc(ns.Search)
            end,
            SetApplicantMemberRole = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetApplicantMemberRole))
                return
              end
              return checkFunc(ns.SetApplicantMemberRole)
            end,
            SetEntryTitle = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetEntryTitle))
                return
              end
              return checkFunc(ns.SetEntryTitle)
            end,
            SetSearchToActivity = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetSearchToActivity))
                return
              end
              return checkFunc(ns.SetSearchToActivity)
            end,
            SetSearchToQuestID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetSearchToQuestID))
                return
              end
              return checkFunc(ns.SetSearchToQuestID)
            end,
            UpdateListing = function()
              return checkFunc(ns.UpdateListing)
            end,
            ValidateRequiredDungeonScore = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ValidateRequiredDungeonScore))
                return
              end
              return checkFunc(ns.ValidateRequiredDungeonScore)
            end,
            ValidateRequiredPvpRatingForActivity = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ValidateRequiredPvpRatingForActivity))
                return
              end
              return checkFunc(ns.ValidateRequiredPvpRatingForActivity)
            end,
          })
        end,
        C_LegendaryCrafting = function()
          local ns = _G.C_LegendaryCrafting
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            CloseRuneforgeInteraction = function()
              return checkFunc(ns.CloseRuneforgeInteraction)
            end,
            CraftRuneforgeLegendary = function()
              return checkFunc(ns.CraftRuneforgeLegendary)
            end,
            GetRuneforgeItemPreviewInfo = function()
              return checkFunc(ns.GetRuneforgeItemPreviewInfo)
            end,
            GetRuneforgeLegendaryComponentInfo = function()
              return checkFunc(ns.GetRuneforgeLegendaryComponentInfo)
            end,
            GetRuneforgeLegendaryCost = function()
              return checkFunc(ns.GetRuneforgeLegendaryCost)
            end,
            GetRuneforgeLegendaryCraftSpellID = function()
              return checkFunc(ns.GetRuneforgeLegendaryCraftSpellID)
            end,
            GetRuneforgeLegendaryCurrencies = function()
              return checkFunc(ns.GetRuneforgeLegendaryCurrencies)
            end,
            GetRuneforgeLegendaryUpgradeCost = function()
              return checkFunc(ns.GetRuneforgeLegendaryUpgradeCost)
            end,
            GetRuneforgeModifierInfo = function()
              return checkFunc(ns.GetRuneforgeModifierInfo)
            end,
            GetRuneforgeModifiers = function()
              return checkFunc(ns.GetRuneforgeModifiers)
            end,
            GetRuneforgePowerInfo = function()
              return checkFunc(ns.GetRuneforgePowerInfo)
            end,
            GetRuneforgePowerSlots = function()
              return checkFunc(ns.GetRuneforgePowerSlots)
            end,
            GetRuneforgePowers = function()
              return checkFunc(ns.GetRuneforgePowers)
            end,
            GetRuneforgePowersByClassAndSpec = function()
              return checkFunc(ns.GetRuneforgePowersByClassAndSpec)
            end,
            GetRuneforgePowersByClassSpecAndCovenant = function()
              return checkFunc(ns.GetRuneforgePowersByClassSpecAndCovenant)
            end,
            IsRuneforgeLegendary = function()
              return checkFunc(ns.IsRuneforgeLegendary)
            end,
            IsRuneforgeLegendaryMaxLevel = function()
              return checkFunc(ns.IsRuneforgeLegendaryMaxLevel)
            end,
            IsUpgradeItemValidForRuneforgeLegendary = function()
              return checkFunc(ns.IsUpgradeItemValidForRuneforgeLegendary)
            end,
            IsValidRuneforgeBaseItem = function()
              return checkFunc(ns.IsValidRuneforgeBaseItem)
            end,
            MakeRuneforgeCraftDescription = function()
              return checkFunc(ns.MakeRuneforgeCraftDescription)
            end,
            UpgradeRuneforgeLegendary = function()
              return checkFunc(ns.UpgradeRuneforgeLegendary)
            end,
          })
        end,
        C_LevelLink = function()
          local ns = _G.C_LevelLink
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            IsActionLocked = function()
              return checkFunc(ns.IsActionLocked)
            end,
            IsSpellLocked = function()
              return checkFunc(ns.IsSpellLocked)
            end,
          })
        end,
        C_LevelSquish = function()
          local ns = _G.C_LevelSquish
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            ConvertFollowerLevel = function()
              return checkFunc(ns.ConvertFollowerLevel)
            end,
            ConvertPlayerLevel = function()
              return checkFunc(ns.ConvertPlayerLevel)
            end,
          })
        end,
        C_Loot = function()
          local ns = _G.C_Loot
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            IsLegacyLootModeEnabled = function()
              return checkFunc(ns.IsLegacyLootModeEnabled)
            end,
          })
        end,
        C_LootHistory = function()
          local ns = _G.C_LootHistory
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            CanMasterLoot = function()
              return checkFunc(ns.CanMasterLoot)
            end,
            GetExpiration = function()
              return checkFunc(ns.GetExpiration)
            end,
            GetItem = function()
              return checkFunc(ns.GetItem)
            end,
            GetNumItems = function()
              return checkFunc(ns.GetNumItems)
            end,
            GetPlayerInfo = function()
              return checkFunc(ns.GetPlayerInfo)
            end,
            GiveMasterLoot = function()
              return checkFunc(ns.GiveMasterLoot)
            end,
            SetExpiration = function()
              return checkFunc(ns.SetExpiration)
            end,
          })
        end,
        C_LootJournal = function()
          local ns = _G.C_LootJournal
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetItemSetItems = function()
              return checkFunc(ns.GetItemSetItems)
            end,
            GetItemSets = function()
              return checkFunc(ns.GetItemSets)
            end,
          })
        end,
        C_LoreText = function()
          local ns = _G.C_LoreText
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            RequestLoreTextForCampaignID = function()
              return checkFunc(ns.RequestLoreTextForCampaignID)
            end,
          })
        end,
        C_LossOfControl = function()
          local ns = _G.C_LossOfControl
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetActiveLossOfControlData = function()
              return checkFunc(ns.GetActiveLossOfControlData)
            end,
            GetActiveLossOfControlDataByUnit = function()
              return checkFunc(ns.GetActiveLossOfControlDataByUnit)
            end,
            GetActiveLossOfControlDataCount = function()
              return checkFunc(ns.GetActiveLossOfControlDataCount)
            end,
            GetActiveLossOfControlDataCountByUnit = function()
              return checkFunc(ns.GetActiveLossOfControlDataCountByUnit)
            end,
          })
        end,
        C_Mail = function()
          local ns = _G.C_Mail
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            CanCheckInbox = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanCheckInbox))
                return
              end
              return checkFunc(ns.CanCheckInbox)
            end,
            HasInboxMoney = function()
              return checkFunc(ns.HasInboxMoney)
            end,
            IsCommandPending = function()
              return checkFunc(ns.IsCommandPending)
            end,
          })
        end,
        C_Map = function()
          local ns = _G.C_Map
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            CanSetUserWaypointOnMap = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanSetUserWaypointOnMap))
                return
              end
              return checkFunc(ns.CanSetUserWaypointOnMap)
            end,
            ClearUserWaypoint = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ClearUserWaypoint))
                return
              end
              return checkFunc(ns.ClearUserWaypoint)
            end,
            CloseWorldMapInteraction = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CloseWorldMapInteraction))
                return
              end
              return checkFunc(ns.CloseWorldMapInteraction)
            end,
            GetAreaInfo = function()
              return checkFunc(ns.GetAreaInfo)
            end,
            GetBestMapForUnit = function()
              return checkFunc(ns.GetBestMapForUnit)
            end,
            GetBountySetIDForMap = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetBountySetIDForMap))
                return
              end
              return checkFunc(ns.GetBountySetIDForMap)
            end,
            GetBountySetMaps = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetBountySetMaps))
                return
              end
              return checkFunc(ns.GetBountySetMaps)
            end,
            GetFallbackWorldMapID = function()
              return checkFunc(ns.GetFallbackWorldMapID)
            end,
            GetMapArtBackgroundAtlas = function()
              return checkFunc(ns.GetMapArtBackgroundAtlas)
            end,
            GetMapArtHelpTextPosition = function()
              return checkFunc(ns.GetMapArtHelpTextPosition)
            end,
            GetMapArtID = function()
              return checkFunc(ns.GetMapArtID)
            end,
            GetMapArtLayerTextures = function()
              return checkFunc(ns.GetMapArtLayerTextures)
            end,
            GetMapArtLayers = function()
              return checkFunc(ns.GetMapArtLayers)
            end,
            GetMapBannersForMap = function()
              return checkFunc(ns.GetMapBannersForMap)
            end,
            GetMapChildrenInfo = function()
              return checkFunc(ns.GetMapChildrenInfo)
            end,
            GetMapDisplayInfo = function()
              return checkFunc(ns.GetMapDisplayInfo)
            end,
            GetMapGroupID = function()
              return checkFunc(ns.GetMapGroupID)
            end,
            GetMapGroupMembersInfo = function()
              return checkFunc(ns.GetMapGroupMembersInfo)
            end,
            GetMapHighlightInfoAtPosition = function()
              return checkFunc(ns.GetMapHighlightInfoAtPosition)
            end,
            GetMapInfo = function()
              return checkFunc(ns.GetMapInfo)
            end,
            GetMapInfoAtPosition = function()
              return checkFunc(ns.GetMapInfoAtPosition)
            end,
            GetMapLevels = function()
              return checkFunc(ns.GetMapLevels)
            end,
            GetMapLinksForMap = function()
              return checkFunc(ns.GetMapLinksForMap)
            end,
            GetMapPosFromWorldPos = function()
              return checkFunc(ns.GetMapPosFromWorldPos)
            end,
            GetMapRectOnMap = function()
              return checkFunc(ns.GetMapRectOnMap)
            end,
            GetMapWorldSize = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetMapWorldSize))
                return
              end
              return checkFunc(ns.GetMapWorldSize)
            end,
            GetPlayerMapPosition = function()
              return checkFunc(ns.GetPlayerMapPosition)
            end,
            GetUserWaypoint = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetUserWaypoint))
                return
              end
              return checkFunc(ns.GetUserWaypoint)
            end,
            GetUserWaypointFromHyperlink = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetUserWaypointFromHyperlink))
                return
              end
              return checkFunc(ns.GetUserWaypointFromHyperlink)
            end,
            GetUserWaypointHyperlink = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetUserWaypointHyperlink))
                return
              end
              return checkFunc(ns.GetUserWaypointHyperlink)
            end,
            GetUserWaypointPositionForMap = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetUserWaypointPositionForMap))
                return
              end
              return checkFunc(ns.GetUserWaypointPositionForMap)
            end,
            GetWorldPosFromMapPos = function()
              return checkFunc(ns.GetWorldPosFromMapPos)
            end,
            HasUserWaypoint = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.HasUserWaypoint))
                return
              end
              return checkFunc(ns.HasUserWaypoint)
            end,
            IsMapValidForNavBarDropDown = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsMapValidForNavBarDropDown))
                return
              end
              return checkFunc(ns.IsMapValidForNavBarDropDown)
            end,
            MapHasArt = function()
              return checkFunc(ns.MapHasArt)
            end,
            RequestPreloadMap = function()
              return checkFunc(ns.RequestPreloadMap)
            end,
            SetUserWaypoint = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetUserWaypoint))
                return
              end
              return checkFunc(ns.SetUserWaypoint)
            end,
          })
        end,
        C_MapExplorationInfo = function()
          local ns = _G.C_MapExplorationInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetExploredAreaIDsAtPosition = function()
              return checkFunc(ns.GetExploredAreaIDsAtPosition)
            end,
            GetExploredMapTextures = function()
              return checkFunc(ns.GetExploredMapTextures)
            end,
          })
        end,
        C_MerchantFrame = function()
          local ns = _G.C_MerchantFrame
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetBuybackItemID = function()
              return checkFunc(ns.GetBuybackItemID)
            end,
            IsMerchantItemRefundable = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsMerchantItemRefundable))
                return
              end
              return checkFunc(ns.IsMerchantItemRefundable)
            end,
          })
        end,
        C_Minimap = function()
          local ns = _G.C_Minimap
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetDrawGroundTextures = function()
              return checkFunc(ns.GetDrawGroundTextures)
            end,
            GetUiMapID = function()
              return checkFunc(ns.GetUiMapID)
            end,
            GetViewRadius = function()
              return checkFunc(ns.GetViewRadius)
            end,
            IsRotateMinimapIgnored = function()
              return checkFunc(ns.IsRotateMinimapIgnored)
            end,
            SetDrawGroundTextures = function()
              return checkFunc(ns.SetDrawGroundTextures)
            end,
            SetIgnoreRotateMinimap = function()
              return checkFunc(ns.SetIgnoreRotateMinimap)
            end,
            ShouldUseHybridMinimap = function()
              return checkFunc(ns.ShouldUseHybridMinimap)
            end,
          })
        end,
        C_ModelInfo = function()
          local ns = _G.C_ModelInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            AddActiveModelScene = function()
              return checkFunc(ns.AddActiveModelScene)
            end,
            AddActiveModelSceneActor = function()
              return checkFunc(ns.AddActiveModelSceneActor)
            end,
            ClearActiveModelScene = function()
              return checkFunc(ns.ClearActiveModelScene)
            end,
            ClearActiveModelSceneActor = function()
              return checkFunc(ns.ClearActiveModelSceneActor)
            end,
            GetModelSceneActorDisplayInfoByID = function()
              return checkFunc(ns.GetModelSceneActorDisplayInfoByID)
            end,
            GetModelSceneActorInfoByID = function()
              return checkFunc(ns.GetModelSceneActorInfoByID)
            end,
            GetModelSceneCameraInfoByID = function()
              return checkFunc(ns.GetModelSceneCameraInfoByID)
            end,
            GetModelSceneInfoByID = function()
              return checkFunc(ns.GetModelSceneInfoByID)
            end,
          })
        end,
        C_ModifiedInstance = function()
          local ns = _G.C_ModifiedInstance
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetModifiedInstanceInfoFromMapID = function()
              return checkFunc(ns.GetModifiedInstanceInfoFromMapID)
            end,
          })
        end,
        C_MountJournal = function()
          local ns = _G.C_MountJournal
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            ApplyMountEquipment = function()
              return checkFunc(ns.ApplyMountEquipment)
            end,
            AreMountEquipmentEffectsSuppressed = function()
              return checkFunc(ns.AreMountEquipmentEffectsSuppressed)
            end,
            ClearFanfare = function()
              return checkFunc(ns.ClearFanfare)
            end,
            ClearRecentFanfares = function()
              return checkFunc(ns.ClearRecentFanfares)
            end,
            Dismiss = function()
              return checkFunc(ns.Dismiss)
            end,
            GetAppliedMountEquipmentID = function()
              return checkFunc(ns.GetAppliedMountEquipmentID)
            end,
            GetCollectedFilterSetting = function()
              return checkFunc(ns.GetCollectedFilterSetting)
            end,
            GetDisplayedMountAllCreatureDisplayInfo = function()
              return checkFunc(ns.GetDisplayedMountAllCreatureDisplayInfo)
            end,
            GetDisplayedMountInfo = function()
              return checkFunc(ns.GetDisplayedMountInfo)
            end,
            GetDisplayedMountInfoExtra = function()
              return checkFunc(ns.GetDisplayedMountInfoExtra)
            end,
            GetIsFavorite = function()
              return checkFunc(ns.GetIsFavorite)
            end,
            GetMountAllCreatureDisplayInfoByID = function()
              return checkFunc(ns.GetMountAllCreatureDisplayInfoByID)
            end,
            GetMountEquipmentUnlockLevel = function()
              return checkFunc(ns.GetMountEquipmentUnlockLevel)
            end,
            GetMountFromItem = function()
              return checkFunc(ns.GetMountFromItem)
            end,
            GetMountFromSpell = function()
              return checkFunc(ns.GetMountFromSpell)
            end,
            GetMountIDs = function()
              return checkFunc(ns.GetMountIDs)
            end,
            GetMountInfoByID = function()
              return checkFunc(ns.GetMountInfoByID)
            end,
            GetMountInfoExtraByID = function()
              return checkFunc(ns.GetMountInfoExtraByID)
            end,
            GetMountUsabilityByID = function()
              return checkFunc(ns.GetMountUsabilityByID)
            end,
            GetNumDisplayedMounts = function()
              return checkFunc(ns.GetNumDisplayedMounts)
            end,
            GetNumMounts = function()
              return checkFunc(ns.GetNumMounts)
            end,
            GetNumMountsNeedingFanfare = function()
              return checkFunc(ns.GetNumMountsNeedingFanfare)
            end,
            IsItemMountEquipment = function()
              return checkFunc(ns.IsItemMountEquipment)
            end,
            IsMountEquipmentApplied = function()
              return checkFunc(ns.IsMountEquipmentApplied)
            end,
            IsSourceChecked = function()
              return checkFunc(ns.IsSourceChecked)
            end,
            IsTypeChecked = function()
              return checkFunc(ns.IsTypeChecked)
            end,
            IsUsingDefaultFilters = function()
              return checkFunc(ns.IsUsingDefaultFilters)
            end,
            IsValidSourceFilter = function()
              return checkFunc(ns.IsValidSourceFilter)
            end,
            IsValidTypeFilter = function()
              return checkFunc(ns.IsValidTypeFilter)
            end,
            NeedsFanfare = function()
              return checkFunc(ns.NeedsFanfare)
            end,
            Pickup = function()
              return checkFunc(ns.Pickup)
            end,
            SetAllSourceFilters = function()
              return checkFunc(ns.SetAllSourceFilters)
            end,
            SetAllTypeFilters = function()
              return checkFunc(ns.SetAllTypeFilters)
            end,
            SetCollectedFilterSetting = function()
              return checkFunc(ns.SetCollectedFilterSetting)
            end,
            SetDefaultFilters = function()
              return checkFunc(ns.SetDefaultFilters)
            end,
            SetIsFavorite = function()
              return checkFunc(ns.SetIsFavorite)
            end,
            SetSearch = function()
              return checkFunc(ns.SetSearch)
            end,
            SetSourceFilter = function()
              return checkFunc(ns.SetSourceFilter)
            end,
            SetTypeFilter = function()
              return checkFunc(ns.SetTypeFilter)
            end,
            SummonByID = function()
              return checkFunc(ns.SummonByID)
            end,
          })
        end,
        C_MythicPlus = function()
          local ns = _G.C_MythicPlus
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetCurrentAffixes = function()
              return checkFunc(ns.GetCurrentAffixes)
            end,
            GetCurrentSeason = function()
              return checkFunc(ns.GetCurrentSeason)
            end,
            GetCurrentSeasonValues = function()
              return checkFunc(ns.GetCurrentSeasonValues)
            end,
            GetLastWeeklyBestInformation = function()
              return checkFunc(ns.GetLastWeeklyBestInformation)
            end,
            GetOwnedKeystoneChallengeMapID = function()
              return checkFunc(ns.GetOwnedKeystoneChallengeMapID)
            end,
            GetOwnedKeystoneLevel = function()
              return checkFunc(ns.GetOwnedKeystoneLevel)
            end,
            GetOwnedKeystoneMapID = function()
              return checkFunc(ns.GetOwnedKeystoneMapID)
            end,
            GetRewardLevelForDifficultyLevel = function()
              return checkFunc(ns.GetRewardLevelForDifficultyLevel)
            end,
            GetRewardLevelFromKeystoneLevel = function()
              return checkFunc(ns.GetRewardLevelFromKeystoneLevel)
            end,
            GetRunHistory = function()
              return checkFunc(ns.GetRunHistory)
            end,
            GetSeasonBestAffixScoreInfoForMap = function()
              return checkFunc(ns.GetSeasonBestAffixScoreInfoForMap)
            end,
            GetSeasonBestForMap = function()
              return checkFunc(ns.GetSeasonBestForMap)
            end,
            GetSeasonBestMythicRatingFromThisExpansion = function()
              return checkFunc(ns.GetSeasonBestMythicRatingFromThisExpansion)
            end,
            GetWeeklyBestForMap = function()
              return checkFunc(ns.GetWeeklyBestForMap)
            end,
            GetWeeklyChestRewardLevel = function()
              return checkFunc(ns.GetWeeklyChestRewardLevel)
            end,
            IsMythicPlusActive = function()
              return checkFunc(ns.IsMythicPlusActive)
            end,
            IsWeeklyRewardAvailable = function()
              return checkFunc(ns.IsWeeklyRewardAvailable)
            end,
            RequestCurrentAffixes = function()
              return checkFunc(ns.RequestCurrentAffixes)
            end,
            RequestMapInfo = function()
              return checkFunc(ns.RequestMapInfo)
            end,
            RequestRewards = function()
              return checkFunc(ns.RequestRewards)
            end,
          })
        end,
        C_NamePlate = function()
          local ns = _G.C_NamePlate
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetNamePlateEnemyClickThrough = function()
              return checkFunc(ns.GetNamePlateEnemyClickThrough)
            end,
            GetNamePlateEnemyPreferredClickInsets = function()
              return checkFunc(ns.GetNamePlateEnemyPreferredClickInsets)
            end,
            GetNamePlateEnemySize = function()
              return checkFunc(ns.GetNamePlateEnemySize)
            end,
            GetNamePlateForUnit = function()
              return checkFunc(ns.GetNamePlateForUnit)
            end,
            GetNamePlateFriendlyClickThrough = function()
              return checkFunc(ns.GetNamePlateFriendlyClickThrough)
            end,
            GetNamePlateFriendlyPreferredClickInsets = function()
              return checkFunc(ns.GetNamePlateFriendlyPreferredClickInsets)
            end,
            GetNamePlateFriendlySize = function()
              return checkFunc(ns.GetNamePlateFriendlySize)
            end,
            GetNamePlateSelfClickThrough = function()
              return checkFunc(ns.GetNamePlateSelfClickThrough)
            end,
            GetNamePlateSelfPreferredClickInsets = function()
              return checkFunc(ns.GetNamePlateSelfPreferredClickInsets)
            end,
            GetNamePlateSelfSize = function()
              return checkFunc(ns.GetNamePlateSelfSize)
            end,
            GetNamePlates = function()
              return checkFunc(ns.GetNamePlates)
            end,
            GetNumNamePlateMotionTypes = function()
              return checkFunc(ns.GetNumNamePlateMotionTypes)
            end,
            GetTargetClampingInsets = function()
              return checkFunc(ns.GetTargetClampingInsets)
            end,
            SetNamePlateEnemyClickThrough = function()
              return checkFunc(ns.SetNamePlateEnemyClickThrough)
            end,
            SetNamePlateEnemyPreferredClickInsets = function()
              return checkFunc(ns.SetNamePlateEnemyPreferredClickInsets)
            end,
            SetNamePlateEnemySize = function()
              return checkFunc(ns.SetNamePlateEnemySize)
            end,
            SetNamePlateFriendlyClickThrough = function()
              return checkFunc(ns.SetNamePlateFriendlyClickThrough)
            end,
            SetNamePlateFriendlyPreferredClickInsets = function()
              return checkFunc(ns.SetNamePlateFriendlyPreferredClickInsets)
            end,
            SetNamePlateFriendlySize = function()
              return checkFunc(ns.SetNamePlateFriendlySize)
            end,
            SetNamePlateSelfClickThrough = function()
              return checkFunc(ns.SetNamePlateSelfClickThrough)
            end,
            SetNamePlateSelfPreferredClickInsets = function()
              return checkFunc(ns.SetNamePlateSelfPreferredClickInsets)
            end,
            SetNamePlateSelfSize = function()
              return checkFunc(ns.SetNamePlateSelfSize)
            end,
            SetTargetClampingInsets = function()
              return checkFunc(ns.SetTargetClampingInsets)
            end,
          })
        end,
        C_Navigation = function()
          local ns = _G.C_Navigation
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetDistance = function()
              return checkFunc(ns.GetDistance)
            end,
            GetFrame = function()
              return checkFunc(ns.GetFrame)
            end,
            GetTargetState = function()
              return checkFunc(ns.GetTargetState)
            end,
            HasValidScreenPosition = function()
              return checkFunc(ns.HasValidScreenPosition)
            end,
            WasClampedToScreen = function()
              return checkFunc(ns.WasClampedToScreen)
            end,
          })
        end,
        C_NewItems = function()
          local ns = _G.C_NewItems
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            ClearAll = function()
              return checkFunc(ns.ClearAll)
            end,
            IsNewItem = function()
              return checkFunc(ns.IsNewItem)
            end,
            RemoveNewItem = function()
              return checkFunc(ns.RemoveNewItem)
            end,
          })
        end,
        C_PaperDollInfo = function()
          local ns = _G.C_PaperDollInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetArmorEffectiveness = function()
              return checkFunc(ns.GetArmorEffectiveness)
            end,
            GetArmorEffectivenessAgainstTarget = function()
              return checkFunc(ns.GetArmorEffectivenessAgainstTarget)
            end,
            GetInspectAzeriteItemEmpoweredChoices = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetInspectAzeriteItemEmpoweredChoices))
                return
              end
              return checkFunc(ns.GetInspectAzeriteItemEmpoweredChoices)
            end,
            GetInspectItemLevel = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetInspectItemLevel))
                return
              end
              return checkFunc(ns.GetInspectItemLevel)
            end,
            GetMinItemLevel = function()
              return checkFunc(ns.GetMinItemLevel)
            end,
            GetStaggerPercentage = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetStaggerPercentage))
                return
              end
              return checkFunc(ns.GetStaggerPercentage)
            end,
            OffhandHasShield = function()
              return checkFunc(ns.OffhandHasShield)
            end,
            OffhandHasWeapon = function()
              return checkFunc(ns.OffhandHasWeapon)
            end,
          })
        end,
        C_PartyInfo = function()
          local ns = _G.C_PartyInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            AllowedToDoPartyConversion = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.AllowedToDoPartyConversion))
                return
              end
              return checkFunc(ns.AllowedToDoPartyConversion)
            end,
            CanFormCrossFactionParties = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanFormCrossFactionParties))
                return
              end
              return checkFunc(ns.CanFormCrossFactionParties)
            end,
            CanInvite = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanInvite))
                return
              end
              return checkFunc(ns.CanInvite)
            end,
            ConfirmConvertToRaid = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ConfirmConvertToRaid))
                return
              end
              return checkFunc(ns.ConfirmConvertToRaid)
            end,
            ConfirmInviteTravelPass = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ConfirmInviteTravelPass))
                return
              end
              return checkFunc(ns.ConfirmInviteTravelPass)
            end,
            ConfirmInviteUnit = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ConfirmInviteUnit))
                return
              end
              return checkFunc(ns.ConfirmInviteUnit)
            end,
            ConfirmLeaveParty = function()
              return checkFunc(ns.ConfirmLeaveParty)
            end,
            ConfirmRequestInviteFromUnit = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ConfirmRequestInviteFromUnit))
                return
              end
              return checkFunc(ns.ConfirmRequestInviteFromUnit)
            end,
            ConvertToParty = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ConvertToParty))
                return
              end
              return checkFunc(ns.ConvertToParty)
            end,
            ConvertToRaid = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ConvertToRaid))
                return
              end
              return checkFunc(ns.ConvertToRaid)
            end,
            DoCountdown = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.DoCountdown))
                return
              end
              return checkFunc(ns.DoCountdown)
            end,
            GetActiveCategories = function()
              return checkFunc(ns.GetActiveCategories)
            end,
            GetInviteConfirmationInvalidQueues = function()
              return checkFunc(ns.GetInviteConfirmationInvalidQueues)
            end,
            GetInviteReferralInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetInviteReferralInfo))
                return
              end
              return checkFunc(ns.GetInviteReferralInfo)
            end,
            GetMinLevel = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetMinLevel))
                return
              end
              return checkFunc(ns.GetMinLevel)
            end,
            InviteUnit = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.InviteUnit))
                return
              end
              return checkFunc(ns.InviteUnit)
            end,
            IsCrossFactionParty = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsCrossFactionParty))
                return
              end
              return checkFunc(ns.IsCrossFactionParty)
            end,
            IsPartyFull = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsPartyFull))
                return
              end
              return checkFunc(ns.IsPartyFull)
            end,
            IsPartyInJailersTower = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsPartyInJailersTower))
                return
              end
              return checkFunc(ns.IsPartyInJailersTower)
            end,
            LeaveParty = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.LeaveParty))
                return
              end
              return checkFunc(ns.LeaveParty)
            end,
            RequestInviteFromUnit = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.RequestInviteFromUnit))
                return
              end
              return checkFunc(ns.RequestInviteFromUnit)
            end,
          })
        end,
        C_PartyPose = function()
          local ns = _G.C_PartyPose
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetPartyPoseInfoByMapID = function()
              return checkFunc(ns.GetPartyPoseInfoByMapID)
            end,
          })
        end,
        C_PetBattles = function()
          local ns = _G.C_PetBattles
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            AcceptPVPDuel = function()
              return checkFunc(ns.AcceptPVPDuel)
            end,
            AcceptQueuedPVPMatch = function()
              return checkFunc(ns.AcceptQueuedPVPMatch)
            end,
            CanAcceptQueuedPVPMatch = function()
              return checkFunc(ns.CanAcceptQueuedPVPMatch)
            end,
            CanActivePetSwapOut = function()
              return checkFunc(ns.CanActivePetSwapOut)
            end,
            CanPetSwapIn = function()
              return checkFunc(ns.CanPetSwapIn)
            end,
            CancelPVPDuel = function()
              return checkFunc(ns.CancelPVPDuel)
            end,
            ChangePet = function()
              return checkFunc(ns.ChangePet)
            end,
            DeclineQueuedPVPMatch = function()
              return checkFunc(ns.DeclineQueuedPVPMatch)
            end,
            ForfeitGame = function()
              return checkFunc(ns.ForfeitGame)
            end,
            GetAbilityEffectInfo = function()
              return checkFunc(ns.GetAbilityEffectInfo)
            end,
            GetAbilityInfo = function()
              return checkFunc(ns.GetAbilityInfo)
            end,
            GetAbilityInfoByID = function()
              return checkFunc(ns.GetAbilityInfoByID)
            end,
            GetAbilityProcTurnIndex = function()
              return checkFunc(ns.GetAbilityProcTurnIndex)
            end,
            GetAbilityState = function()
              return checkFunc(ns.GetAbilityState)
            end,
            GetAbilityStateModification = function()
              return checkFunc(ns.GetAbilityStateModification)
            end,
            GetActivePet = function()
              return checkFunc(ns.GetActivePet)
            end,
            GetAllEffectNames = function()
              return checkFunc(ns.GetAllEffectNames)
            end,
            GetAllStates = function()
              return checkFunc(ns.GetAllStates)
            end,
            GetAttackModifier = function()
              return checkFunc(ns.GetAttackModifier)
            end,
            GetAuraInfo = function()
              return checkFunc(ns.GetAuraInfo)
            end,
            GetBattleState = function()
              return checkFunc(ns.GetBattleState)
            end,
            GetBreedQuality = function()
              return checkFunc(ns.GetBreedQuality)
            end,
            GetDisplayID = function()
              return checkFunc(ns.GetDisplayID)
            end,
            GetForfeitPenalty = function()
              return checkFunc(ns.GetForfeitPenalty)
            end,
            GetHealth = function()
              return checkFunc(ns.GetHealth)
            end,
            GetIcon = function()
              return checkFunc(ns.GetIcon)
            end,
            GetLevel = function()
              return checkFunc(ns.GetLevel)
            end,
            GetMaxHealth = function()
              return checkFunc(ns.GetMaxHealth)
            end,
            GetName = function()
              return checkFunc(ns.GetName)
            end,
            GetNumAuras = function()
              return checkFunc(ns.GetNumAuras)
            end,
            GetNumPets = function()
              return checkFunc(ns.GetNumPets)
            end,
            GetPVPMatchmakingInfo = function()
              return checkFunc(ns.GetPVPMatchmakingInfo)
            end,
            GetPetSpeciesID = function()
              return checkFunc(ns.GetPetSpeciesID)
            end,
            GetPetType = function()
              return checkFunc(ns.GetPetType)
            end,
            GetPlayerTrapAbility = function()
              return checkFunc(ns.GetPlayerTrapAbility)
            end,
            GetPower = function()
              return checkFunc(ns.GetPower)
            end,
            GetSelectedAction = function()
              return checkFunc(ns.GetSelectedAction)
            end,
            GetSpeed = function()
              return checkFunc(ns.GetSpeed)
            end,
            GetStateValue = function()
              return checkFunc(ns.GetStateValue)
            end,
            GetTurnTimeInfo = function()
              return checkFunc(ns.GetTurnTimeInfo)
            end,
            GetXP = function()
              return checkFunc(ns.GetXP)
            end,
            IsInBattle = function()
              return checkFunc(ns.IsInBattle)
            end,
            IsPlayerNPC = function()
              return checkFunc(ns.IsPlayerNPC)
            end,
            IsSkipAvailable = function()
              return checkFunc(ns.IsSkipAvailable)
            end,
            IsTrapAvailable = function()
              return checkFunc(ns.IsTrapAvailable)
            end,
            IsWaitingOnOpponent = function()
              return checkFunc(ns.IsWaitingOnOpponent)
            end,
            IsWildBattle = function()
              return checkFunc(ns.IsWildBattle)
            end,
            SetPendingReportBattlePetTarget = function()
              return checkFunc(ns.SetPendingReportBattlePetTarget)
            end,
            SetPendingReportTargetFromUnit = function()
              return checkFunc(ns.SetPendingReportTargetFromUnit)
            end,
            ShouldShowPetSelect = function()
              return checkFunc(ns.ShouldShowPetSelect)
            end,
            SkipTurn = function()
              return checkFunc(ns.SkipTurn)
            end,
            StartPVPDuel = function()
              return checkFunc(ns.StartPVPDuel)
            end,
            StartPVPMatchmaking = function()
              return checkFunc(ns.StartPVPMatchmaking)
            end,
            StopPVPMatchmaking = function()
              return checkFunc(ns.StopPVPMatchmaking)
            end,
            UseAbility = function()
              return checkFunc(ns.UseAbility)
            end,
            UseTrap = function()
              return checkFunc(ns.UseTrap)
            end,
          })
        end,
        C_PetInfo = function()
          local ns = _G.C_PetInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetPetTamersForMap = function()
              return checkFunc(ns.GetPetTamersForMap)
            end,
          })
        end,
        C_PetJournal = function()
          local ns = _G.C_PetJournal
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            CagePetByID = function()
              return checkFunc(ns.CagePetByID)
            end,
            ClearFanfare = function()
              return checkFunc(ns.ClearFanfare)
            end,
            ClearRecentFanfares = function()
              return checkFunc(ns.ClearRecentFanfares)
            end,
            ClearSearchFilter = function()
              return checkFunc(ns.ClearSearchFilter)
            end,
            FindPetIDByName = function()
              return checkFunc(ns.FindPetIDByName)
            end,
            GetBattlePetLink = function()
              return checkFunc(ns.GetBattlePetLink)
            end,
            GetDisplayIDByIndex = function()
              return checkFunc(ns.GetDisplayIDByIndex)
            end,
            GetDisplayProbabilityByIndex = function()
              return checkFunc(ns.GetDisplayProbabilityByIndex)
            end,
            GetNumCollectedInfo = function()
              return checkFunc(ns.GetNumCollectedInfo)
            end,
            GetNumDisplays = function()
              return checkFunc(ns.GetNumDisplays)
            end,
            GetNumPetSources = function()
              return checkFunc(ns.GetNumPetSources)
            end,
            GetNumPetTypes = function()
              return checkFunc(ns.GetNumPetTypes)
            end,
            GetNumPets = function()
              return checkFunc(ns.GetNumPets)
            end,
            GetNumPetsNeedingFanfare = function()
              return checkFunc(ns.GetNumPetsNeedingFanfare)
            end,
            GetOwnedBattlePetString = function()
              return checkFunc(ns.GetOwnedBattlePetString)
            end,
            GetPetAbilityInfo = function()
              return checkFunc(ns.GetPetAbilityInfo)
            end,
            GetPetAbilityList = function()
              return checkFunc(ns.GetPetAbilityList)
            end,
            GetPetAbilityListTable = function()
              return checkFunc(ns.GetPetAbilityListTable)
            end,
            GetPetCooldownByGUID = function()
              return checkFunc(ns.GetPetCooldownByGUID)
            end,
            GetPetInfoByIndex = function()
              return checkFunc(ns.GetPetInfoByIndex)
            end,
            GetPetInfoByItemID = function()
              return checkFunc(ns.GetPetInfoByItemID)
            end,
            GetPetInfoByPetID = function()
              return checkFunc(ns.GetPetInfoByPetID)
            end,
            GetPetInfoBySpeciesID = function()
              return checkFunc(ns.GetPetInfoBySpeciesID)
            end,
            GetPetInfoTableByPetID = function()
              return checkFunc(ns.GetPetInfoTableByPetID)
            end,
            GetPetLoadOutInfo = function()
              return checkFunc(ns.GetPetLoadOutInfo)
            end,
            GetPetModelSceneInfoBySpeciesID = function()
              return checkFunc(ns.GetPetModelSceneInfoBySpeciesID)
            end,
            GetPetSortParameter = function()
              return checkFunc(ns.GetPetSortParameter)
            end,
            GetPetStats = function()
              return checkFunc(ns.GetPetStats)
            end,
            GetPetSummonInfo = function()
              return checkFunc(ns.GetPetSummonInfo)
            end,
            GetPetTeamAverageLevel = function()
              return checkFunc(ns.GetPetTeamAverageLevel)
            end,
            GetSummonBattlePetCooldown = function()
              return checkFunc(ns.GetSummonBattlePetCooldown)
            end,
            GetSummonRandomFavoritePetGUID = function()
              return checkFunc(ns.GetSummonRandomFavoritePetGUID)
            end,
            GetSummonedPetGUID = function()
              return checkFunc(ns.GetSummonedPetGUID)
            end,
            IsFilterChecked = function()
              return checkFunc(ns.IsFilterChecked)
            end,
            IsFindBattleEnabled = function()
              return checkFunc(ns.IsFindBattleEnabled)
            end,
            IsJournalReadOnly = function()
              return checkFunc(ns.IsJournalReadOnly)
            end,
            IsJournalUnlocked = function()
              return checkFunc(ns.IsJournalUnlocked)
            end,
            IsPetSourceChecked = function()
              return checkFunc(ns.IsPetSourceChecked)
            end,
            IsPetTypeChecked = function()
              return checkFunc(ns.IsPetTypeChecked)
            end,
            IsUsingDefaultFilters = function()
              return checkFunc(ns.IsUsingDefaultFilters)
            end,
            PetCanBeReleased = function()
              return checkFunc(ns.PetCanBeReleased)
            end,
            PetIsCapturable = function()
              return checkFunc(ns.PetIsCapturable)
            end,
            PetIsFavorite = function()
              return checkFunc(ns.PetIsFavorite)
            end,
            PetIsHurt = function()
              return checkFunc(ns.PetIsHurt)
            end,
            PetIsLockedForConvert = function()
              return checkFunc(ns.PetIsLockedForConvert)
            end,
            PetIsRevoked = function()
              return checkFunc(ns.PetIsRevoked)
            end,
            PetIsSlotted = function()
              return checkFunc(ns.PetIsSlotted)
            end,
            PetIsSummonable = function()
              return checkFunc(ns.PetIsSummonable)
            end,
            PetIsTradable = function()
              return checkFunc(ns.PetIsTradable)
            end,
            PetIsUsable = function()
              return checkFunc(ns.PetIsUsable)
            end,
            PetNeedsFanfare = function()
              return checkFunc(ns.PetNeedsFanfare)
            end,
            PetUsesRandomDisplay = function()
              return checkFunc(ns.PetUsesRandomDisplay)
            end,
            PickupPet = function()
              return checkFunc(ns.PickupPet)
            end,
            PickupSummonRandomPet = function()
              return checkFunc(ns.PickupSummonRandomPet)
            end,
            ReleasePetByID = function()
              return checkFunc(ns.ReleasePetByID)
            end,
            SetAbility = function()
              return checkFunc(ns.SetAbility)
            end,
            SetAllPetSourcesChecked = function()
              return checkFunc(ns.SetAllPetSourcesChecked)
            end,
            SetAllPetTypesChecked = function()
              return checkFunc(ns.SetAllPetTypesChecked)
            end,
            SetCustomName = function()
              return checkFunc(ns.SetCustomName)
            end,
            SetDefaultFilters = function()
              return checkFunc(ns.SetDefaultFilters)
            end,
            SetFavorite = function()
              return checkFunc(ns.SetFavorite)
            end,
            SetFilterChecked = function()
              return checkFunc(ns.SetFilterChecked)
            end,
            SetPetLoadOutInfo = function()
              return checkFunc(ns.SetPetLoadOutInfo)
            end,
            SetPetSortParameter = function()
              return checkFunc(ns.SetPetSortParameter)
            end,
            SetPetSourceChecked = function()
              return checkFunc(ns.SetPetSourceChecked)
            end,
            SetPetTypeFilter = function()
              return checkFunc(ns.SetPetTypeFilter)
            end,
            SetSearchFilter = function()
              return checkFunc(ns.SetSearchFilter)
            end,
            SummonPetByGUID = function()
              return checkFunc(ns.SummonPetByGUID)
            end,
            SummonRandomPet = function()
              return checkFunc(ns.SummonRandomPet)
            end,
          })
        end,
        C_PlayerChoice = function()
          local ns = _G.C_PlayerChoice
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetCurrentPlayerChoiceInfo = function()
              return checkFunc(ns.GetCurrentPlayerChoiceInfo)
            end,
            GetNumRerolls = function()
              return checkFunc(ns.GetNumRerolls)
            end,
            GetRemainingTime = function()
              return checkFunc(ns.GetRemainingTime)
            end,
            IsWaitingForPlayerChoiceResponse = function()
              return checkFunc(ns.IsWaitingForPlayerChoiceResponse)
            end,
            OnUIClosed = function()
              return checkFunc(ns.OnUIClosed)
            end,
            RequestRerollPlayerChoice = function()
              return checkFunc(ns.RequestRerollPlayerChoice)
            end,
            SendPlayerChoiceResponse = function()
              return checkFunc(ns.SendPlayerChoiceResponse)
            end,
          })
        end,
        C_PlayerInfo = function()
          local ns = _G.C_PlayerInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            CanPlayerEnterChromieTime = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanPlayerEnterChromieTime))
                return
              end
              return checkFunc(ns.CanPlayerEnterChromieTime)
            end,
            CanPlayerUseAreaLoot = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanPlayerUseAreaLoot))
                return
              end
              return checkFunc(ns.CanPlayerUseAreaLoot)
            end,
            CanPlayerUseMountEquipment = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanPlayerUseMountEquipment))
                return
              end
              return checkFunc(ns.CanPlayerUseMountEquipment)
            end,
            GUIDIsPlayer = function()
              return checkFunc(ns.GUIDIsPlayer)
            end,
            GetAlternateFormInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetAlternateFormInfo))
                return
              end
              return checkFunc(ns.GetAlternateFormInfo)
            end,
            GetClass = function()
              return checkFunc(ns.GetClass)
            end,
            GetContentDifficultyCreatureForPlayer = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetContentDifficultyCreatureForPlayer))
                return
              end
              return checkFunc(ns.GetContentDifficultyCreatureForPlayer)
            end,
            GetContentDifficultyQuestForPlayer = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetContentDifficultyQuestForPlayer))
                return
              end
              return checkFunc(ns.GetContentDifficultyQuestForPlayer)
            end,
            GetInstancesUnlockedAtLevel = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetInstancesUnlockedAtLevel))
                return
              end
              return checkFunc(ns.GetInstancesUnlockedAtLevel)
            end,
            GetName = function()
              return checkFunc(ns.GetName)
            end,
            GetPlayerMythicPlusRatingSummary = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetPlayerMythicPlusRatingSummary))
                return
              end
              return checkFunc(ns.GetPlayerMythicPlusRatingSummary)
            end,
            GetRace = function()
              return checkFunc(ns.GetRace)
            end,
            GetSex = function()
              return checkFunc(ns.GetSex)
            end,
            IsConnected = function()
              return checkFunc(ns.IsConnected)
            end,
            IsPlayerEligibleForNPE = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsPlayerEligibleForNPE))
                return
              end
              return checkFunc(ns.IsPlayerEligibleForNPE)
            end,
            IsPlayerEligibleForNPEv2 = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsPlayerEligibleForNPEv2))
                return
              end
              return checkFunc(ns.IsPlayerEligibleForNPEv2)
            end,
            IsPlayerInChromieTime = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsPlayerInChromieTime))
                return
              end
              return checkFunc(ns.IsPlayerInChromieTime)
            end,
            IsPlayerInGuildFromGUID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsPlayerInGuildFromGUID))
                return
              end
              return checkFunc(ns.IsPlayerInGuildFromGUID)
            end,
            IsPlayerNPERestricted = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsPlayerNPERestricted))
                return
              end
              return checkFunc(ns.IsPlayerNPERestricted)
            end,
            UnitIsSameServer = function()
              return checkFunc(ns.UnitIsSameServer)
            end,
          })
        end,
        C_PlayerMentorship = function()
          local ns = _G.C_PlayerMentorship
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetMentorLevelRequirement = function()
              return checkFunc(ns.GetMentorLevelRequirement)
            end,
            GetMentorRequirements = function()
              return checkFunc(ns.GetMentorRequirements)
            end,
            GetMentorshipStatus = function()
              return checkFunc(ns.GetMentorshipStatus)
            end,
            IsActivePlayerConsideredNewcomer = function()
              return checkFunc(ns.IsActivePlayerConsideredNewcomer)
            end,
            IsMentorRestricted = function()
              return checkFunc(ns.IsMentorRestricted)
            end,
          })
        end,
        C_ProductChoice = function()
          local ns = _G.C_ProductChoice
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetChoices = function()
              return checkFunc(ns.GetChoices)
            end,
            GetNumSuppressed = function()
              return checkFunc(ns.GetNumSuppressed)
            end,
            GetProducts = function()
              return checkFunc(ns.GetProducts)
            end,
            MakeSelection = function()
              return checkFunc(ns.MakeSelection)
            end,
          })
        end,
        C_PvP = function()
          local ns = _G.C_PvP
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            CanDisplayDamage = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanDisplayDamage))
                return
              end
              return checkFunc(ns.CanDisplayDamage)
            end,
            CanDisplayDeaths = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanDisplayDeaths))
                return
              end
              return checkFunc(ns.CanDisplayDeaths)
            end,
            CanDisplayHealing = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanDisplayHealing))
                return
              end
              return checkFunc(ns.CanDisplayHealing)
            end,
            CanDisplayHonorableKills = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanDisplayHonorableKills))
                return
              end
              return checkFunc(ns.CanDisplayHonorableKills)
            end,
            CanDisplayKillingBlows = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanDisplayKillingBlows))
                return
              end
              return checkFunc(ns.CanDisplayKillingBlows)
            end,
            CanPlayerUseRatedPVPUI = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanPlayerUseRatedPVPUI))
                return
              end
              return checkFunc(ns.CanPlayerUseRatedPVPUI)
            end,
            CanToggleWarMode = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanToggleWarMode))
                return
              end
              return checkFunc(ns.CanToggleWarMode)
            end,
            CanToggleWarModeInArea = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanToggleWarModeInArea))
                return
              end
              return checkFunc(ns.CanToggleWarModeInArea)
            end,
            DoesMatchOutcomeAffectRating = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.DoesMatchOutcomeAffectRating))
                return
              end
              return checkFunc(ns.DoesMatchOutcomeAffectRating)
            end,
            GetActiveBrawlInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetActiveBrawlInfo))
                return
              end
              return checkFunc(ns.GetActiveBrawlInfo)
            end,
            GetActiveMatchBracket = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetActiveMatchBracket))
                return
              end
              return checkFunc(ns.GetActiveMatchBracket)
            end,
            GetActiveMatchDuration = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetActiveMatchDuration))
                return
              end
              return checkFunc(ns.GetActiveMatchDuration)
            end,
            GetActiveMatchState = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetActiveMatchState))
                return
              end
              return checkFunc(ns.GetActiveMatchState)
            end,
            GetActiveMatchWinner = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetActiveMatchWinner))
                return
              end
              return checkFunc(ns.GetActiveMatchWinner)
            end,
            GetArenaCrowdControlInfo = function()
              return checkFunc(ns.GetArenaCrowdControlInfo)
            end,
            GetArenaRewards = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetArenaRewards))
                return
              end
              return checkFunc(ns.GetArenaRewards)
            end,
            GetArenaSkirmishRewards = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetArenaSkirmishRewards))
                return
              end
              return checkFunc(ns.GetArenaSkirmishRewards)
            end,
            GetAvailableBrawlInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetAvailableBrawlInfo))
                return
              end
              return checkFunc(ns.GetAvailableBrawlInfo)
            end,
            GetBattlefieldFlagPosition = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetBattlefieldFlagPosition))
                return
              end
              return checkFunc(ns.GetBattlefieldFlagPosition)
            end,
            GetBattlefieldVehicleInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetBattlefieldVehicleInfo))
                return
              end
              return checkFunc(ns.GetBattlefieldVehicleInfo)
            end,
            GetBattlefieldVehicles = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetBattlefieldVehicles))
                return
              end
              return checkFunc(ns.GetBattlefieldVehicles)
            end,
            GetBrawlRewards = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetBrawlRewards))
                return
              end
              return checkFunc(ns.GetBrawlRewards)
            end,
            GetCustomVictoryStatID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetCustomVictoryStatID))
                return
              end
              return checkFunc(ns.GetCustomVictoryStatID)
            end,
            GetGlobalPvpScalingInfoForSpecID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetGlobalPvpScalingInfoForSpecID))
                return
              end
              return checkFunc(ns.GetGlobalPvpScalingInfoForSpecID)
            end,
            GetHonorRewardInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetHonorRewardInfo))
                return
              end
              return checkFunc(ns.GetHonorRewardInfo)
            end,
            GetLevelUpBattlegrounds = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetLevelUpBattlegrounds))
                return
              end
              return checkFunc(ns.GetLevelUpBattlegrounds)
            end,
            GetMatchPVPStatColumn = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetMatchPVPStatColumn))
                return
              end
              return checkFunc(ns.GetMatchPVPStatColumn)
            end,
            GetMatchPVPStatColumns = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetMatchPVPStatColumns))
                return
              end
              return checkFunc(ns.GetMatchPVPStatColumns)
            end,
            GetNextHonorLevelForReward = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetNextHonorLevelForReward))
                return
              end
              return checkFunc(ns.GetNextHonorLevelForReward)
            end,
            GetOutdoorPvPWaitTime = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetOutdoorPvPWaitTime))
                return
              end
              return checkFunc(ns.GetOutdoorPvPWaitTime)
            end,
            GetPVPActiveMatchPersonalRatedInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetPVPActiveMatchPersonalRatedInfo))
                return
              end
              return checkFunc(ns.GetPVPActiveMatchPersonalRatedInfo)
            end,
            GetPVPSeasonRewardAchievementID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetPVPSeasonRewardAchievementID))
                return
              end
              return checkFunc(ns.GetPVPSeasonRewardAchievementID)
            end,
            GetPostMatchCurrencyRewards = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetPostMatchCurrencyRewards))
                return
              end
              return checkFunc(ns.GetPostMatchCurrencyRewards)
            end,
            GetPostMatchItemRewards = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetPostMatchItemRewards))
                return
              end
              return checkFunc(ns.GetPostMatchItemRewards)
            end,
            GetPvpTierID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetPvpTierID))
                return
              end
              return checkFunc(ns.GetPvpTierID)
            end,
            GetPvpTierInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetPvpTierInfo))
                return
              end
              return checkFunc(ns.GetPvpTierInfo)
            end,
            GetRandomBGInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetRandomBGInfo))
                return
              end
              return checkFunc(ns.GetRandomBGInfo)
            end,
            GetRandomBGRewards = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetRandomBGRewards))
                return
              end
              return checkFunc(ns.GetRandomBGRewards)
            end,
            GetRandomEpicBGInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetRandomEpicBGInfo))
                return
              end
              return checkFunc(ns.GetRandomEpicBGInfo)
            end,
            GetRandomEpicBGRewards = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetRandomEpicBGRewards))
                return
              end
              return checkFunc(ns.GetRandomEpicBGRewards)
            end,
            GetRatedBGRewards = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetRatedBGRewards))
                return
              end
              return checkFunc(ns.GetRatedBGRewards)
            end,
            GetRewardItemLevelsByTierEnum = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetRewardItemLevelsByTierEnum))
                return
              end
              return checkFunc(ns.GetRewardItemLevelsByTierEnum)
            end,
            GetScoreInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetScoreInfo))
                return
              end
              return checkFunc(ns.GetScoreInfo)
            end,
            GetScoreInfoByPlayerGuid = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetScoreInfoByPlayerGuid))
                return
              end
              return checkFunc(ns.GetScoreInfoByPlayerGuid)
            end,
            GetSeasonBestInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetSeasonBestInfo))
                return
              end
              return checkFunc(ns.GetSeasonBestInfo)
            end,
            GetSkirmishInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetSkirmishInfo))
                return
              end
              return checkFunc(ns.GetSkirmishInfo)
            end,
            GetSpecialEventBrawlInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetSpecialEventBrawlInfo))
                return
              end
              return checkFunc(ns.GetSpecialEventBrawlInfo)
            end,
            GetTeamInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetTeamInfo))
                return
              end
              return checkFunc(ns.GetTeamInfo)
            end,
            GetWarModeRewardBonus = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetWarModeRewardBonus))
                return
              end
              return checkFunc(ns.GetWarModeRewardBonus)
            end,
            GetWarModeRewardBonusDefault = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetWarModeRewardBonusDefault))
                return
              end
              return checkFunc(ns.GetWarModeRewardBonusDefault)
            end,
            GetWeeklyChestInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetWeeklyChestInfo))
                return
              end
              return checkFunc(ns.GetWeeklyChestInfo)
            end,
            HasArenaSkirmishWinToday = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.HasArenaSkirmishWinToday))
                return
              end
              return checkFunc(ns.HasArenaSkirmishWinToday)
            end,
            IsActiveBattlefield = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsActiveBattlefield))
                return
              end
              return checkFunc(ns.IsActiveBattlefield)
            end,
            IsActiveMatchRegistered = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsActiveMatchRegistered))
                return
              end
              return checkFunc(ns.IsActiveMatchRegistered)
            end,
            IsArena = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsArena))
                return
              end
              return checkFunc(ns.IsArena)
            end,
            IsBattleground = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsBattleground))
                return
              end
              return checkFunc(ns.IsBattleground)
            end,
            IsBattlegroundEnlistmentBonusActive = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsBattlegroundEnlistmentBonusActive))
                return
              end
              return checkFunc(ns.IsBattlegroundEnlistmentBonusActive)
            end,
            IsInBrawl = function()
              return checkFunc(ns.IsInBrawl)
            end,
            IsMatchConsideredArena = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsMatchConsideredArena))
                return
              end
              return checkFunc(ns.IsMatchConsideredArena)
            end,
            IsMatchFactional = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsMatchFactional))
                return
              end
              return checkFunc(ns.IsMatchFactional)
            end,
            IsPVPMap = function()
              return checkFunc(ns.IsPVPMap)
            end,
            IsRatedArena = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsRatedArena))
                return
              end
              return checkFunc(ns.IsRatedArena)
            end,
            IsRatedBattleground = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsRatedBattleground))
                return
              end
              return checkFunc(ns.IsRatedBattleground)
            end,
            IsRatedMap = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsRatedMap))
                return
              end
              return checkFunc(ns.IsRatedMap)
            end,
            IsSoloShuffle = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsSoloShuffle))
                return
              end
              return checkFunc(ns.IsSoloShuffle)
            end,
            IsWarModeActive = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsWarModeActive))
                return
              end
              return checkFunc(ns.IsWarModeActive)
            end,
            IsWarModeDesired = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsWarModeDesired))
                return
              end
              return checkFunc(ns.IsWarModeDesired)
            end,
            IsWarModeFeatureEnabled = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsWarModeFeatureEnabled))
                return
              end
              return checkFunc(ns.IsWarModeFeatureEnabled)
            end,
            JoinBrawl = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.JoinBrawl))
                return
              end
              return checkFunc(ns.JoinBrawl)
            end,
            RequestCrowdControlSpell = function()
              return checkFunc(ns.RequestCrowdControlSpell)
            end,
            SetWarModeDesired = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetWarModeDesired))
                return
              end
              return checkFunc(ns.SetWarModeDesired)
            end,
            ToggleWarMode = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ToggleWarMode))
                return
              end
              return checkFunc(ns.ToggleWarMode)
            end,
          })
        end,
        C_QuestLine = function()
          local ns = _G.C_QuestLine
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetAvailableQuestLines = function()
              return checkFunc(ns.GetAvailableQuestLines)
            end,
            GetQuestLineInfo = function()
              return checkFunc(ns.GetQuestLineInfo)
            end,
            GetQuestLineQuests = function()
              return checkFunc(ns.GetQuestLineQuests)
            end,
            IsComplete = function()
              return checkFunc(ns.IsComplete)
            end,
            RequestQuestLinesForMap = function()
              return checkFunc(ns.RequestQuestLinesForMap)
            end,
          })
        end,
        C_QuestLog = function()
          local ns = _G.C_QuestLog
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            AbandonQuest = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.AbandonQuest))
                return
              end
              return checkFunc(ns.AbandonQuest)
            end,
            AddQuestWatch = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.AddQuestWatch))
                return
              end
              return checkFunc(ns.AddQuestWatch)
            end,
            AddWorldQuestWatch = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.AddWorldQuestWatch))
                return
              end
              return checkFunc(ns.AddWorldQuestWatch)
            end,
            CanAbandonQuest = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.CanAbandonQuest))
                return
              end
              return checkFunc(ns.CanAbandonQuest)
            end,
            GetAbandonQuest = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetAbandonQuest))
                return
              end
              return checkFunc(ns.GetAbandonQuest)
            end,
            GetAbandonQuestItems = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetAbandonQuestItems))
                return
              end
              return checkFunc(ns.GetAbandonQuestItems)
            end,
            GetActiveThreatMaps = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetActiveThreatMaps))
                return
              end
              return checkFunc(ns.GetActiveThreatMaps)
            end,
            GetAllCompletedQuestIDs = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetAllCompletedQuestIDs))
                return
              end
              return checkFunc(ns.GetAllCompletedQuestIDs)
            end,
            GetBountiesForMapID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetBountiesForMapID))
                return
              end
              return checkFunc(ns.GetBountiesForMapID)
            end,
            GetBountySetInfoForMapID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetBountySetInfoForMapID))
                return
              end
              return checkFunc(ns.GetBountySetInfoForMapID)
            end,
            GetDistanceSqToQuest = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetDistanceSqToQuest))
                return
              end
              return checkFunc(ns.GetDistanceSqToQuest)
            end,
            GetInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetInfo))
                return
              end
              return checkFunc(ns.GetInfo)
            end,
            GetLogIndexForQuestID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetLogIndexForQuestID))
                return
              end
              return checkFunc(ns.GetLogIndexForQuestID)
            end,
            GetMapForQuestPOIs = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetMapForQuestPOIs))
                return
              end
              return checkFunc(ns.GetMapForQuestPOIs)
            end,
            GetMaxNumQuests = function()
              return checkFunc(ns.GetMaxNumQuests)
            end,
            GetMaxNumQuestsCanAccept = function()
              return checkFunc(ns.GetMaxNumQuestsCanAccept)
            end,
            GetNextWaypoint = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetNextWaypoint))
                return
              end
              return checkFunc(ns.GetNextWaypoint)
            end,
            GetNextWaypointForMap = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetNextWaypointForMap))
                return
              end
              return checkFunc(ns.GetNextWaypointForMap)
            end,
            GetNextWaypointText = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetNextWaypointText))
                return
              end
              return checkFunc(ns.GetNextWaypointText)
            end,
            GetNumQuestLogEntries = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetNumQuestLogEntries))
                return
              end
              return checkFunc(ns.GetNumQuestLogEntries)
            end,
            GetNumQuestObjectives = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetNumQuestObjectives))
                return
              end
              return checkFunc(ns.GetNumQuestObjectives)
            end,
            GetNumQuestWatches = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetNumQuestWatches))
                return
              end
              return checkFunc(ns.GetNumQuestWatches)
            end,
            GetNumWorldQuestWatches = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetNumWorldQuestWatches))
                return
              end
              return checkFunc(ns.GetNumWorldQuestWatches)
            end,
            GetQuestAdditionalHighlights = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetQuestAdditionalHighlights))
                return
              end
              return checkFunc(ns.GetQuestAdditionalHighlights)
            end,
            GetQuestDetailsTheme = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetQuestDetailsTheme))
                return
              end
              return checkFunc(ns.GetQuestDetailsTheme)
            end,
            GetQuestDifficultyLevel = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetQuestDifficultyLevel))
                return
              end
              return checkFunc(ns.GetQuestDifficultyLevel)
            end,
            GetQuestIDForLogIndex = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetQuestIDForLogIndex))
                return
              end
              return checkFunc(ns.GetQuestIDForLogIndex)
            end,
            GetQuestIDForQuestWatchIndex = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetQuestIDForQuestWatchIndex))
                return
              end
              return checkFunc(ns.GetQuestIDForQuestWatchIndex)
            end,
            GetQuestIDForWorldQuestWatchIndex = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetQuestIDForWorldQuestWatchIndex))
                return
              end
              return checkFunc(ns.GetQuestIDForWorldQuestWatchIndex)
            end,
            GetQuestInfo = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetQuestInfo))
                return
              end
              return checkFunc(ns.GetQuestInfo)
            end,
            GetQuestLogPortraitGiver = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetQuestLogPortraitGiver))
                return
              end
              return checkFunc(ns.GetQuestLogPortraitGiver)
            end,
            GetQuestObjectives = function()
              return checkFunc(ns.GetQuestObjectives)
            end,
            GetQuestTagInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetQuestTagInfo))
                return
              end
              return checkFunc(ns.GetQuestTagInfo)
            end,
            GetQuestType = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetQuestType))
                return
              end
              return checkFunc(ns.GetQuestType)
            end,
            GetQuestWatchType = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetQuestWatchType))
                return
              end
              return checkFunc(ns.GetQuestWatchType)
            end,
            GetQuestsOnMap = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetQuestsOnMap))
                return
              end
              return checkFunc(ns.GetQuestsOnMap)
            end,
            GetRequiredMoney = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetRequiredMoney))
                return
              end
              return checkFunc(ns.GetRequiredMoney)
            end,
            GetSelectedQuest = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetSelectedQuest))
                return
              end
              return checkFunc(ns.GetSelectedQuest)
            end,
            GetSuggestedGroupSize = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetSuggestedGroupSize))
                return
              end
              return checkFunc(ns.GetSuggestedGroupSize)
            end,
            GetTimeAllowed = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetTimeAllowed))
                return
              end
              return checkFunc(ns.GetTimeAllowed)
            end,
            GetTitleForLogIndex = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetTitleForLogIndex))
                return
              end
              return checkFunc(ns.GetTitleForLogIndex)
            end,
            GetTitleForQuestID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetTitleForQuestID))
                return
              end
              return checkFunc(ns.GetTitleForQuestID)
            end,
            GetZoneStoryInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetZoneStoryInfo))
                return
              end
              return checkFunc(ns.GetZoneStoryInfo)
            end,
            HasActiveThreats = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.HasActiveThreats))
                return
              end
              return checkFunc(ns.HasActiveThreats)
            end,
            IsAccountQuest = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsAccountQuest))
                return
              end
              return checkFunc(ns.IsAccountQuest)
            end,
            IsComplete = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsComplete))
                return
              end
              return checkFunc(ns.IsComplete)
            end,
            IsFailed = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsFailed))
                return
              end
              return checkFunc(ns.IsFailed)
            end,
            IsLegendaryQuest = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsLegendaryQuest))
                return
              end
              return checkFunc(ns.IsLegendaryQuest)
            end,
            IsOnMap = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsOnMap))
                return
              end
              return checkFunc(ns.IsOnMap)
            end,
            IsOnQuest = function()
              return checkFunc(ns.IsOnQuest)
            end,
            IsPushableQuest = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsPushableQuest))
                return
              end
              return checkFunc(ns.IsPushableQuest)
            end,
            IsQuestBounty = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsQuestBounty))
                return
              end
              return checkFunc(ns.IsQuestBounty)
            end,
            IsQuestCalling = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsQuestCalling))
                return
              end
              return checkFunc(ns.IsQuestCalling)
            end,
            IsQuestCriteriaForBounty = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsQuestCriteriaForBounty))
                return
              end
              return checkFunc(ns.IsQuestCriteriaForBounty)
            end,
            IsQuestDisabledForSession = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsQuestDisabledForSession))
                return
              end
              return checkFunc(ns.IsQuestDisabledForSession)
            end,
            IsQuestFlaggedCompleted = function()
              return checkFunc(ns.IsQuestFlaggedCompleted)
            end,
            IsQuestInvasion = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsQuestInvasion))
                return
              end
              return checkFunc(ns.IsQuestInvasion)
            end,
            IsQuestReplayable = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsQuestReplayable))
                return
              end
              return checkFunc(ns.IsQuestReplayable)
            end,
            IsQuestReplayedRecently = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsQuestReplayedRecently))
                return
              end
              return checkFunc(ns.IsQuestReplayedRecently)
            end,
            IsQuestTask = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsQuestTask))
                return
              end
              return checkFunc(ns.IsQuestTask)
            end,
            IsQuestTrivial = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsQuestTrivial))
                return
              end
              return checkFunc(ns.IsQuestTrivial)
            end,
            IsRepeatableQuest = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsRepeatableQuest))
                return
              end
              return checkFunc(ns.IsRepeatableQuest)
            end,
            IsThreatQuest = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsThreatQuest))
                return
              end
              return checkFunc(ns.IsThreatQuest)
            end,
            IsUnitOnQuest = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsUnitOnQuest))
                return
              end
              return checkFunc(ns.IsUnitOnQuest)
            end,
            IsWorldQuest = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsWorldQuest))
                return
              end
              return checkFunc(ns.IsWorldQuest)
            end,
            QuestCanHaveWarModeBonus = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.QuestCanHaveWarModeBonus))
                return
              end
              return checkFunc(ns.QuestCanHaveWarModeBonus)
            end,
            QuestHasQuestSessionBonus = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.QuestHasQuestSessionBonus))
                return
              end
              return checkFunc(ns.QuestHasQuestSessionBonus)
            end,
            QuestHasWarModeBonus = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.QuestHasWarModeBonus))
                return
              end
              return checkFunc(ns.QuestHasWarModeBonus)
            end,
            ReadyForTurnIn = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ReadyForTurnIn))
                return
              end
              return checkFunc(ns.ReadyForTurnIn)
            end,
            RemoveQuestWatch = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.RemoveQuestWatch))
                return
              end
              return checkFunc(ns.RemoveQuestWatch)
            end,
            RemoveWorldQuestWatch = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.RemoveWorldQuestWatch))
                return
              end
              return checkFunc(ns.RemoveWorldQuestWatch)
            end,
            RequestLoadQuestByID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.RequestLoadQuestByID))
                return
              end
              return checkFunc(ns.RequestLoadQuestByID)
            end,
            SetAbandonQuest = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetAbandonQuest))
                return
              end
              return checkFunc(ns.SetAbandonQuest)
            end,
            SetMapForQuestPOIs = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetMapForQuestPOIs))
                return
              end
              return checkFunc(ns.SetMapForQuestPOIs)
            end,
            SetSelectedQuest = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetSelectedQuest))
                return
              end
              return checkFunc(ns.SetSelectedQuest)
            end,
            ShouldDisplayTimeRemaining = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ShouldDisplayTimeRemaining))
                return
              end
              return checkFunc(ns.ShouldDisplayTimeRemaining)
            end,
            ShouldShowQuestRewards = function()
              return checkFunc(ns.ShouldShowQuestRewards)
            end,
            SortQuestWatches = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SortQuestWatches))
                return
              end
              return checkFunc(ns.SortQuestWatches)
            end,
          })
        end,
        C_QuestSession = function()
          local ns = _G.C_QuestSession
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            CanStart = function()
              return checkFunc(ns.CanStart)
            end,
            CanStop = function()
              return checkFunc(ns.CanStop)
            end,
            Exists = function()
              return checkFunc(ns.Exists)
            end,
            GetAvailableSessionCommand = function()
              return checkFunc(ns.GetAvailableSessionCommand)
            end,
            GetPendingCommand = function()
              return checkFunc(ns.GetPendingCommand)
            end,
            GetProposedMaxLevelForSession = function()
              return checkFunc(ns.GetProposedMaxLevelForSession)
            end,
            GetSessionBeginDetails = function()
              return checkFunc(ns.GetSessionBeginDetails)
            end,
            GetSuperTrackedQuest = function()
              return checkFunc(ns.GetSuperTrackedQuest)
            end,
            HasJoined = function()
              return checkFunc(ns.HasJoined)
            end,
            HasPendingCommand = function()
              return checkFunc(ns.HasPendingCommand)
            end,
            RequestSessionStart = function()
              return checkFunc(ns.RequestSessionStart)
            end,
            RequestSessionStop = function()
              return checkFunc(ns.RequestSessionStop)
            end,
            SendSessionBeginResponse = function()
              return checkFunc(ns.SendSessionBeginResponse)
            end,
            SetQuestIsSuperTracked = function()
              return checkFunc(ns.SetQuestIsSuperTracked)
            end,
          })
        end,
        C_RaidLocks = function()
          local ns = _G.C_RaidLocks
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            IsEncounterComplete = function()
              return checkFunc(ns.IsEncounterComplete)
            end,
          })
        end,
        C_RecruitAFriend = function()
          local ns = _G.C_RecruitAFriend
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            ClaimActivityReward = function()
              return checkFunc(ns.ClaimActivityReward)
            end,
            ClaimNextReward = function()
              return checkFunc(ns.ClaimNextReward)
            end,
            GenerateRecruitmentLink = function()
              return checkFunc(ns.GenerateRecruitmentLink)
            end,
            GetRAFInfo = function()
              return checkFunc(ns.GetRAFInfo)
            end,
            GetRAFSystemInfo = function()
              return checkFunc(ns.GetRAFSystemInfo)
            end,
            GetRecruitActivityRequirementsText = function()
              return checkFunc(ns.GetRecruitActivityRequirementsText)
            end,
            GetRecruitInfo = function()
              return checkFunc(ns.GetRecruitInfo)
            end,
            IsEnabled = function()
              return checkFunc(ns.IsEnabled)
            end,
            IsRecruitingEnabled = function()
              return checkFunc(ns.IsRecruitingEnabled)
            end,
            RemoveRAFRecruit = function()
              return checkFunc(ns.RemoveRAFRecruit)
            end,
            RequestUpdatedRecruitmentInfo = function()
              return checkFunc(ns.RequestUpdatedRecruitmentInfo)
            end,
          })
        end,
        C_ReportSystem = function()
          local ns = _G.C_ReportSystem
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            CanReportPlayer = function()
              return checkFunc(ns.CanReportPlayer)
            end,
            CanReportPlayerForLanguage = function()
              return checkFunc(ns.CanReportPlayerForLanguage)
            end,
            GetMajorCategoriesForReportType = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetMajorCategoriesForReportType))
                return
              end
              return checkFunc(ns.GetMajorCategoriesForReportType)
            end,
            GetMajorCategoryString = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetMajorCategoryString))
                return
              end
              return checkFunc(ns.GetMajorCategoryString)
            end,
            GetMinorCategoriesForReportTypeAndMajorCategory = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetMinorCategoriesForReportTypeAndMajorCategory))
                return
              end
              return checkFunc(ns.GetMinorCategoriesForReportTypeAndMajorCategory)
            end,
            GetMinorCategoryString = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetMinorCategoryString))
                return
              end
              return checkFunc(ns.GetMinorCategoryString)
            end,
            InitiateReportPlayer = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.InitiateReportPlayer))
                return
              end
              return checkFunc(ns.InitiateReportPlayer)
            end,
            OpenReportPlayerDialog = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.OpenReportPlayerDialog))
                return
              end
              return checkFunc(ns.OpenReportPlayerDialog)
            end,
            ReportServerLag = function()
              return checkFunc(ns.ReportServerLag)
            end,
            ReportStuckInCombat = function()
              return checkFunc(ns.ReportStuckInCombat)
            end,
            SendReport = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SendReport))
                return
              end
              return checkFunc(ns.SendReport)
            end,
            SendReportPlayer = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SendReportPlayer))
                return
              end
              return checkFunc(ns.SendReportPlayer)
            end,
            SetPendingReportPetTarget = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetPendingReportPetTarget))
                return
              end
              return checkFunc(ns.SetPendingReportPetTarget)
            end,
            SetPendingReportTarget = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetPendingReportTarget))
                return
              end
              return checkFunc(ns.SetPendingReportTarget)
            end,
            SetPendingReportTargetByGuid = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetPendingReportTargetByGuid))
                return
              end
              return checkFunc(ns.SetPendingReportTargetByGuid)
            end,
          })
        end,
        C_Reputation = function()
          local ns = _G.C_Reputation
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetFactionParagonInfo = function()
              return checkFunc(ns.GetFactionParagonInfo)
            end,
            IsFactionParagon = function()
              return checkFunc(ns.IsFactionParagon)
            end,
            RequestFactionParagonPreloadRewardData = function()
              return checkFunc(ns.RequestFactionParagonPreloadRewardData)
            end,
          })
        end,
        C_ResearchInfo = function()
          local ns = _G.C_ResearchInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetDigSitesForMap = function()
              return checkFunc(ns.GetDigSitesForMap)
            end,
          })
        end,
        C_Scenario = function()
          local ns = _G.C_Scenario
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetBonusStepRewardQuestID = function()
              return checkFunc(ns.GetBonusStepRewardQuestID)
            end,
            GetBonusSteps = function()
              return checkFunc(ns.GetBonusSteps)
            end,
            GetCriteriaInfo = function()
              return checkFunc(ns.GetCriteriaInfo)
            end,
            GetCriteriaInfoByStep = function()
              return checkFunc(ns.GetCriteriaInfoByStep)
            end,
            GetInfo = function()
              return checkFunc(ns.GetInfo)
            end,
            GetProvingGroundsInfo = function()
              return checkFunc(ns.GetProvingGroundsInfo)
            end,
            GetScenarioIconInfo = function()
              return checkFunc(ns.GetScenarioIconInfo)
            end,
            GetStepInfo = function()
              return checkFunc(ns.GetStepInfo)
            end,
            GetSupersededObjectives = function()
              return checkFunc(ns.GetSupersededObjectives)
            end,
            IsInScenario = function()
              return checkFunc(ns.IsInScenario)
            end,
            ShouldShowCriteria = function()
              return checkFunc(ns.ShouldShowCriteria)
            end,
            TreatScenarioAsDungeon = function()
              return checkFunc(ns.TreatScenarioAsDungeon)
            end,
          })
        end,
        C_ScenarioInfo = function()
          local ns = _G.C_ScenarioInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetJailersTowerTypeString = function()
              return checkFunc(ns.GetJailersTowerTypeString)
            end,
            GetScenarioInfo = function()
              return checkFunc(ns.GetScenarioInfo)
            end,
            GetScenarioStepInfo = function()
              return checkFunc(ns.GetScenarioStepInfo)
            end,
          })
        end,
        C_ScrappingMachineUI = function()
          local ns = _G.C_ScrappingMachineUI
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            CloseScrappingMachine = function()
              return checkFunc(ns.CloseScrappingMachine)
            end,
            DropPendingScrapItemFromCursor = function()
              return checkFunc(ns.DropPendingScrapItemFromCursor)
            end,
            GetCurrentPendingScrapItemLocationByIndex = function()
              return checkFunc(ns.GetCurrentPendingScrapItemLocationByIndex)
            end,
            GetScrapSpellID = function()
              return checkFunc(ns.GetScrapSpellID)
            end,
            GetScrappingMachineName = function()
              return checkFunc(ns.GetScrappingMachineName)
            end,
            HasScrappableItems = function()
              return checkFunc(ns.HasScrappableItems)
            end,
            RemoveAllScrapItems = function()
              return checkFunc(ns.RemoveAllScrapItems)
            end,
            RemoveCurrentScrappingItem = function()
              return checkFunc(ns.RemoveCurrentScrappingItem)
            end,
            RemoveItemToScrap = function()
              return checkFunc(ns.RemoveItemToScrap)
            end,
            ScrapItems = function()
              return checkFunc(ns.ScrapItems)
            end,
            SetScrappingMachine = function()
              return checkFunc(ns.SetScrappingMachine)
            end,
            ValidateScrappingList = function()
              return checkFunc(ns.ValidateScrappingList)
            end,
          })
        end,
        C_ScriptedAnimations = function()
          local ns = _G.C_ScriptedAnimations
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetAllScriptedAnimationEffects = function()
              return checkFunc(ns.GetAllScriptedAnimationEffects)
            end,
          })
        end,
        C_Seasons = function()
          local ns = _G.C_Seasons
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetActiveSeason = function()
              return checkFunc(ns.GetActiveSeason)
            end,
            HasActiveSeason = function()
              return checkFunc(ns.HasActiveSeason)
            end,
          })
        end,
        C_Social = function()
          local ns = _G.C_Social
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetLastAchievement = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetLastAchievement))
                return
              end
              return checkFunc(ns.GetLastAchievement)
            end,
            GetLastItem = function()
              return checkFunc(ns.GetLastItem)
            end,
            GetLastScreenshot = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetLastScreenshot))
                return
              end
              return checkFunc(ns.GetLastScreenshot)
            end,
            GetLastScreenshotIndex = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetLastScreenshotIndex))
                return
              end
              return checkFunc(ns.GetLastScreenshotIndex)
            end,
            GetMaxTweetLength = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetMaxTweetLength))
                return
              end
              return checkFunc(ns.GetMaxTweetLength)
            end,
            GetNumCharactersPerMedia = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetNumCharactersPerMedia))
                return
              end
              return checkFunc(ns.GetNumCharactersPerMedia)
            end,
            GetScreenshotByIndex = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetScreenshotByIndex))
                return
              end
              return checkFunc(ns.GetScreenshotByIndex)
            end,
            GetScreenshotInfoByIndex = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetScreenshotInfoByIndex))
                return
              end
              return checkFunc(ns.GetScreenshotInfoByIndex)
            end,
            GetTweetLength = function()
              return checkFunc(ns.GetTweetLength)
            end,
            IsSocialEnabled = function()
              return checkFunc(ns.IsSocialEnabled)
            end,
            RegisterSocialBrowser = function()
              return checkFunc(ns.RegisterSocialBrowser)
            end,
            SetTextureToScreenshot = function()
              return checkFunc(ns.SetTextureToScreenshot)
            end,
            TwitterCheckStatus = function()
              return checkFunc(ns.TwitterCheckStatus)
            end,
            TwitterConnect = function()
              return checkFunc(ns.TwitterConnect)
            end,
            TwitterDisconnect = function()
              return checkFunc(ns.TwitterDisconnect)
            end,
            TwitterGetMSTillCanPost = function()
              return checkFunc(ns.TwitterGetMSTillCanPost)
            end,
            TwitterPostAchievement = function()
              return checkFunc(ns.TwitterPostAchievement)
            end,
            TwitterPostItem = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.TwitterPostItem))
                return
              end
              return checkFunc(ns.TwitterPostItem)
            end,
            TwitterPostMessage = function()
              return checkFunc(ns.TwitterPostMessage)
            end,
            TwitterPostScreenshot = function()
              return checkFunc(ns.TwitterPostScreenshot)
            end,
          })
        end,
        C_SocialQueue = function()
          local ns = _G.C_SocialQueue
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetAllGroups = function()
              return checkFunc(ns.GetAllGroups)
            end,
            GetConfig = function()
              return checkFunc(ns.GetConfig)
            end,
            GetGroupForPlayer = function()
              return checkFunc(ns.GetGroupForPlayer)
            end,
            GetGroupInfo = function()
              return checkFunc(ns.GetGroupInfo)
            end,
            GetGroupMembers = function()
              return checkFunc(ns.GetGroupMembers)
            end,
            GetGroupQueues = function()
              return checkFunc(ns.GetGroupQueues)
            end,
            RequestToJoin = function()
              return checkFunc(ns.RequestToJoin)
            end,
            SignalToastDisplayed = function()
              return checkFunc(ns.SignalToastDisplayed)
            end,
          })
        end,
        C_SocialRestrictions = function()
          local ns = _G.C_SocialRestrictions
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            AcknowledgeRegionalChatDisabled = function()
              return checkFunc(ns.AcknowledgeRegionalChatDisabled)
            end,
            IsChatDisabled = function()
              return checkFunc(ns.IsChatDisabled)
            end,
            IsMuted = function()
              return checkFunc(ns.IsMuted)
            end,
            IsSilenced = function()
              return checkFunc(ns.IsSilenced)
            end,
            IsSquelched = function()
              return checkFunc(ns.IsSquelched)
            end,
            SetChatDisabled = function()
              return checkFunc(ns.SetChatDisabled)
            end,
          })
        end,
        C_Soulbinds = function()
          local ns = _G.C_Soulbinds
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            ActivateSoulbind = function()
              return checkFunc(ns.ActivateSoulbind)
            end,
            CanActivateSoulbind = function()
              return checkFunc(ns.CanActivateSoulbind)
            end,
            CanModifySoulbind = function()
              return checkFunc(ns.CanModifySoulbind)
            end,
            CanResetConduitsInSoulbind = function()
              return checkFunc(ns.CanResetConduitsInSoulbind)
            end,
            CanSwitchActiveSoulbindTreeBranch = function()
              return checkFunc(ns.CanSwitchActiveSoulbindTreeBranch)
            end,
            CloseUI = function()
              return checkFunc(ns.CloseUI)
            end,
            CommitPendingConduitsInSoulbind = function()
              return checkFunc(ns.CommitPendingConduitsInSoulbind)
            end,
            FindNodeIDActuallyInstalled = function()
              return checkFunc(ns.FindNodeIDActuallyInstalled)
            end,
            FindNodeIDAppearingInstalled = function()
              return checkFunc(ns.FindNodeIDAppearingInstalled)
            end,
            FindNodeIDPendingInstall = function()
              return checkFunc(ns.FindNodeIDPendingInstall)
            end,
            FindNodeIDPendingUninstall = function()
              return checkFunc(ns.FindNodeIDPendingUninstall)
            end,
            GetActiveSoulbindID = function()
              return checkFunc(ns.GetActiveSoulbindID)
            end,
            GetConduitCollection = function()
              return checkFunc(ns.GetConduitCollection)
            end,
            GetConduitCollectionCount = function()
              return checkFunc(ns.GetConduitCollectionCount)
            end,
            GetConduitCollectionData = function()
              return checkFunc(ns.GetConduitCollectionData)
            end,
            GetConduitCollectionDataAtCursor = function()
              return checkFunc(ns.GetConduitCollectionDataAtCursor)
            end,
            GetConduitCollectionDataByVirtualID = function()
              return checkFunc(ns.GetConduitCollectionDataByVirtualID)
            end,
            GetConduitDisplayed = function()
              return checkFunc(ns.GetConduitDisplayed)
            end,
            GetConduitHyperlink = function()
              return checkFunc(ns.GetConduitHyperlink)
            end,
            GetConduitIDPendingInstall = function()
              return checkFunc(ns.GetConduitIDPendingInstall)
            end,
            GetConduitQuality = function()
              return checkFunc(ns.GetConduitQuality)
            end,
            GetConduitRank = function()
              return checkFunc(ns.GetConduitRank)
            end,
            GetConduitSpellID = function()
              return checkFunc(ns.GetConduitSpellID)
            end,
            GetInstalledConduitID = function()
              return checkFunc(ns.GetInstalledConduitID)
            end,
            GetNode = function()
              return checkFunc(ns.GetNode)
            end,
            GetSoulbindData = function()
              return checkFunc(ns.GetSoulbindData)
            end,
            GetSpecsAssignedToSoulbind = function()
              return checkFunc(ns.GetSpecsAssignedToSoulbind)
            end,
            GetTree = function()
              return checkFunc(ns.GetTree)
            end,
            HasAnyInstalledConduitInSoulbind = function()
              return checkFunc(ns.HasAnyInstalledConduitInSoulbind)
            end,
            HasAnyPendingConduits = function()
              return checkFunc(ns.HasAnyPendingConduits)
            end,
            HasPendingConduitsInSoulbind = function()
              return checkFunc(ns.HasPendingConduitsInSoulbind)
            end,
            IsConduitInstalled = function()
              return checkFunc(ns.IsConduitInstalled)
            end,
            IsConduitInstalledInSoulbind = function()
              return checkFunc(ns.IsConduitInstalledInSoulbind)
            end,
            IsItemConduitByItemInfo = function()
              return checkFunc(ns.IsItemConduitByItemInfo)
            end,
            IsNodePendingModify = function()
              return checkFunc(ns.IsNodePendingModify)
            end,
            IsUnselectedConduitPendingInSoulbind = function()
              return checkFunc(ns.IsUnselectedConduitPendingInSoulbind)
            end,
            ModifyNode = function()
              return checkFunc(ns.ModifyNode)
            end,
            SelectNode = function()
              return checkFunc(ns.SelectNode)
            end,
            UnmodifyNode = function()
              return checkFunc(ns.UnmodifyNode)
            end,
          })
        end,
        C_SpecializationInfo = function()
          local ns = _G.C_SpecializationInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            CanPlayerUsePVPTalentUI = function()
              return checkFunc(ns.CanPlayerUsePVPTalentUI)
            end,
            CanPlayerUseTalentSpecUI = function()
              return checkFunc(ns.CanPlayerUseTalentSpecUI)
            end,
            CanPlayerUseTalentUI = function()
              return checkFunc(ns.CanPlayerUseTalentUI)
            end,
            GetAllSelectedPvpTalentIDs = function()
              return checkFunc(ns.GetAllSelectedPvpTalentIDs)
            end,
            GetInspectSelectedPvpTalent = function()
              return checkFunc(ns.GetInspectSelectedPvpTalent)
            end,
            GetPvpTalentAlertStatus = function()
              return checkFunc(ns.GetPvpTalentAlertStatus)
            end,
            GetPvpTalentSlotInfo = function()
              return checkFunc(ns.GetPvpTalentSlotInfo)
            end,
            GetPvpTalentSlotUnlockLevel = function()
              return checkFunc(ns.GetPvpTalentSlotUnlockLevel)
            end,
            GetPvpTalentUnlockLevel = function()
              return checkFunc(ns.GetPvpTalentUnlockLevel)
            end,
            GetSpecIDs = function()
              return checkFunc(ns.GetSpecIDs)
            end,
            GetSpellsDisplay = function()
              return checkFunc(ns.GetSpellsDisplay)
            end,
            IsInitialized = function()
              return checkFunc(ns.IsInitialized)
            end,
            IsPvpTalentLocked = function()
              return checkFunc(ns.IsPvpTalentLocked)
            end,
            MatchesCurrentSpecSet = function()
              return checkFunc(ns.MatchesCurrentSpecSet)
            end,
            SetPvpTalentLocked = function()
              return checkFunc(ns.SetPvpTalentLocked)
            end,
          })
        end,
        C_Spell = function()
          local ns = _G.C_Spell
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            DoesSpellExist = function()
              return checkFunc(ns.DoesSpellExist)
            end,
            GetMawPowerBorderAtlasBySpellID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetMawPowerBorderAtlasBySpellID))
                return
              end
              return checkFunc(ns.GetMawPowerBorderAtlasBySpellID)
            end,
            IsSpellDataCached = function()
              return checkFunc(ns.IsSpellDataCached)
            end,
            RequestLoadSpellData = function()
              return checkFunc(ns.RequestLoadSpellData)
            end,
          })
        end,
        C_SpellBook = function()
          local ns = _G.C_SpellBook
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            ContainsAnyDisenchantSpell = function()
              return checkFunc(ns.ContainsAnyDisenchantSpell)
            end,
            GetCurrentLevelSpells = function()
              return checkFunc(ns.GetCurrentLevelSpells)
            end,
            GetSkillLineIndexByID = function()
              return checkFunc(ns.GetSkillLineIndexByID)
            end,
            GetSpellInfo = function()
              return checkFunc(ns.GetSpellInfo)
            end,
            GetSpellLinkFromSpellID = function()
              return checkFunc(ns.GetSpellLinkFromSpellID)
            end,
            IsSpellDisabled = function()
              return checkFunc(ns.IsSpellDisabled)
            end,
          })
        end,
        C_SplashScreen = function()
          local ns = _G.C_SplashScreen
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            AcknowledgeSplash = function()
              return checkFunc(ns.AcknowledgeSplash)
            end,
            CanViewSplashScreen = function()
              return checkFunc(ns.CanViewSplashScreen)
            end,
            RequestLatestSplashScreen = function()
              return checkFunc(ns.RequestLatestSplashScreen)
            end,
          })
        end,
        C_StableInfo = function()
          local ns = _G.C_StableInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetNumActivePets = function()
              return checkFunc(ns.GetNumActivePets)
            end,
            GetNumStablePets = function()
              return checkFunc(ns.GetNumStablePets)
            end,
          })
        end,
        C_StorePublic = function()
          local ns = _G.C_StorePublic
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            DoesGroupHavePurchaseableProducts = function()
              return checkFunc(ns.DoesGroupHavePurchaseableProducts)
            end,
            HasPurchaseableProducts = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.HasPurchaseableProducts))
                return
              end
              return checkFunc(ns.HasPurchaseableProducts)
            end,
            IsDisabledByParentalControls = function()
              return checkFunc(ns.IsDisabledByParentalControls)
            end,
            IsEnabled = function()
              return checkFunc(ns.IsEnabled)
            end,
          })
        end,
        C_SummonInfo = function()
          local ns = _G.C_SummonInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            CancelSummon = function()
              return checkFunc(ns.CancelSummon)
            end,
            ConfirmSummon = function()
              return checkFunc(ns.ConfirmSummon)
            end,
            GetSummonConfirmAreaName = function()
              return checkFunc(ns.GetSummonConfirmAreaName)
            end,
            GetSummonConfirmSummoner = function()
              return checkFunc(ns.GetSummonConfirmSummoner)
            end,
            GetSummonConfirmTimeLeft = function()
              return checkFunc(ns.GetSummonConfirmTimeLeft)
            end,
            GetSummonReason = function()
              return checkFunc(ns.GetSummonReason)
            end,
            IsSummonSkippingStartExperience = function()
              return checkFunc(ns.IsSummonSkippingStartExperience)
            end,
          })
        end,
        C_SuperTrack = function()
          local ns = _G.C_SuperTrack
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetHighestPrioritySuperTrackingType = function()
              return checkFunc(ns.GetHighestPrioritySuperTrackingType)
            end,
            GetSuperTrackedQuestID = function()
              return checkFunc(ns.GetSuperTrackedQuestID)
            end,
            IsSuperTrackingAnything = function()
              return checkFunc(ns.IsSuperTrackingAnything)
            end,
            IsSuperTrackingCorpse = function()
              return checkFunc(ns.IsSuperTrackingCorpse)
            end,
            IsSuperTrackingQuest = function()
              return checkFunc(ns.IsSuperTrackingQuest)
            end,
            IsSuperTrackingUserWaypoint = function()
              return checkFunc(ns.IsSuperTrackingUserWaypoint)
            end,
            SetSuperTrackedQuestID = function()
              return checkFunc(ns.SetSuperTrackedQuestID)
            end,
            SetSuperTrackedUserWaypoint = function()
              return checkFunc(ns.SetSuperTrackedUserWaypoint)
            end,
          })
        end,
        C_System = function()
          local ns = _G.C_System
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetFrameStack = function()
              return checkFunc(ns.GetFrameStack)
            end,
          })
        end,
        C_TTSSettings = function()
          local ns = _G.C_TTSSettings
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetChannelEnabled = function()
              return checkFunc(ns.GetChannelEnabled)
            end,
            GetCharacterSettingsSaved = function()
              return checkFunc(ns.GetCharacterSettingsSaved)
            end,
            GetChatTypeEnabled = function()
              return checkFunc(ns.GetChatTypeEnabled)
            end,
            GetSetting = function()
              return checkFunc(ns.GetSetting)
            end,
            GetSpeechRate = function()
              return checkFunc(ns.GetSpeechRate)
            end,
            GetSpeechVolume = function()
              return checkFunc(ns.GetSpeechVolume)
            end,
            GetVoiceOptionID = function()
              return checkFunc(ns.GetVoiceOptionID)
            end,
            GetVoiceOptionName = function()
              return checkFunc(ns.GetVoiceOptionName)
            end,
            MarkCharacterSettingsSaved = function()
              return checkFunc(ns.MarkCharacterSettingsSaved)
            end,
            SetChannelEnabled = function()
              return checkFunc(ns.SetChannelEnabled)
            end,
            SetChannelKeyEnabled = function()
              return checkFunc(ns.SetChannelKeyEnabled)
            end,
            SetChatTypeEnabled = function()
              return checkFunc(ns.SetChatTypeEnabled)
            end,
            SetDefaultSettings = function()
              return checkFunc(ns.SetDefaultSettings)
            end,
            SetSetting = function()
              return checkFunc(ns.SetSetting)
            end,
            SetSpeechRate = function()
              return checkFunc(ns.SetSpeechRate)
            end,
            SetSpeechVolume = function()
              return checkFunc(ns.SetSpeechVolume)
            end,
            SetVoiceOption = function()
              return checkFunc(ns.SetVoiceOption)
            end,
            SetVoiceOptionName = function()
              return checkFunc(ns.SetVoiceOptionName)
            end,
            ShouldOverrideMessage = function()
              return checkFunc(ns.ShouldOverrideMessage)
            end,
          })
        end,
        C_TaskQuest = function()
          local ns = _G.C_TaskQuest
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            DoesMapShowTaskQuestObjectives = function()
              return checkFunc(ns.DoesMapShowTaskQuestObjectives)
            end,
            GetQuestInfoByQuestID = function()
              return checkFunc(ns.GetQuestInfoByQuestID)
            end,
            GetQuestLocation = function()
              return checkFunc(ns.GetQuestLocation)
            end,
            GetQuestProgressBarInfo = function()
              return checkFunc(ns.GetQuestProgressBarInfo)
            end,
            GetQuestTimeLeftMinutes = function()
              return checkFunc(ns.GetQuestTimeLeftMinutes)
            end,
            GetQuestTimeLeftSeconds = function()
              return checkFunc(ns.GetQuestTimeLeftSeconds)
            end,
            GetQuestZoneID = function()
              return checkFunc(ns.GetQuestZoneID)
            end,
            GetQuestsForPlayerByMapID = function()
              return checkFunc(ns.GetQuestsForPlayerByMapID)
            end,
            GetThreatQuests = function()
              return checkFunc(ns.GetThreatQuests)
            end,
            GetUIWidgetSetIDFromQuestID = function()
              return checkFunc(ns.GetUIWidgetSetIDFromQuestID)
            end,
            IsActive = function()
              return checkFunc(ns.IsActive)
            end,
            RequestPreloadRewardData = function()
              return checkFunc(ns.RequestPreloadRewardData)
            end,
          })
        end,
        C_TaxiMap = function()
          local ns = _G.C_TaxiMap
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetAllTaxiNodes = function()
              return checkFunc(ns.GetAllTaxiNodes)
            end,
            GetTaxiNodesForMap = function()
              return checkFunc(ns.GetTaxiNodesForMap)
            end,
            ShouldMapShowTaxiNodes = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.ShouldMapShowTaxiNodes))
                return
              end
              return checkFunc(ns.ShouldMapShowTaxiNodes)
            end,
          })
        end,
        C_Texture = function()
          local ns = _G.C_Texture
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetAtlasInfo = function()
              return checkFunc(ns.GetAtlasInfo)
            end,
          })
        end,
        C_Timer = function()
          local ns = _G.C_Timer
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            After = function()
              return checkFunc(ns.After)
            end,
          })
        end,
        C_ToyBox = function()
          local ns = _G.C_ToyBox
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            ForceToyRefilter = function()
              return checkFunc(ns.ForceToyRefilter)
            end,
            GetCollectedShown = function()
              return checkFunc(ns.GetCollectedShown)
            end,
            GetIsFavorite = function()
              return checkFunc(ns.GetIsFavorite)
            end,
            GetNumFilteredToys = function()
              return checkFunc(ns.GetNumFilteredToys)
            end,
            GetNumLearnedDisplayedToys = function()
              return checkFunc(ns.GetNumLearnedDisplayedToys)
            end,
            GetNumTotalDisplayedToys = function()
              return checkFunc(ns.GetNumTotalDisplayedToys)
            end,
            GetNumToys = function()
              return checkFunc(ns.GetNumToys)
            end,
            GetToyFromIndex = function()
              return checkFunc(ns.GetToyFromIndex)
            end,
            GetToyInfo = function()
              return checkFunc(ns.GetToyInfo)
            end,
            GetToyLink = function()
              return checkFunc(ns.GetToyLink)
            end,
            GetUncollectedShown = function()
              return checkFunc(ns.GetUncollectedShown)
            end,
            GetUnusableShown = function()
              return checkFunc(ns.GetUnusableShown)
            end,
            HasFavorites = function()
              return checkFunc(ns.HasFavorites)
            end,
            IsExpansionTypeFilterChecked = function()
              return checkFunc(ns.IsExpansionTypeFilterChecked)
            end,
            IsSourceTypeFilterChecked = function()
              return checkFunc(ns.IsSourceTypeFilterChecked)
            end,
            IsToyUsable = function()
              return checkFunc(ns.IsToyUsable)
            end,
            PickupToyBoxItem = function()
              return checkFunc(ns.PickupToyBoxItem)
            end,
            SetAllExpansionTypeFilters = function()
              return checkFunc(ns.SetAllExpansionTypeFilters)
            end,
            SetAllSourceTypeFilters = function()
              return checkFunc(ns.SetAllSourceTypeFilters)
            end,
            SetCollectedShown = function()
              return checkFunc(ns.SetCollectedShown)
            end,
            SetExpansionTypeFilter = function()
              return checkFunc(ns.SetExpansionTypeFilter)
            end,
            SetFilterString = function()
              return checkFunc(ns.SetFilterString)
            end,
            SetIsFavorite = function()
              return checkFunc(ns.SetIsFavorite)
            end,
            SetSourceTypeFilter = function()
              return checkFunc(ns.SetSourceTypeFilter)
            end,
            SetUncollectedShown = function()
              return checkFunc(ns.SetUncollectedShown)
            end,
            SetUnusableShown = function()
              return checkFunc(ns.SetUnusableShown)
            end,
          })
        end,
        C_ToyBoxInfo = function()
          local ns = _G.C_ToyBoxInfo
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            ClearFanfare = function()
              return checkFunc(ns.ClearFanfare)
            end,
            IsToySourceValid = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsToySourceValid))
                return
              end
              return checkFunc(ns.IsToySourceValid)
            end,
            IsUsingDefaultFilters = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.IsUsingDefaultFilters))
                return
              end
              return checkFunc(ns.IsUsingDefaultFilters)
            end,
            NeedsFanfare = function()
              return checkFunc(ns.NeedsFanfare)
            end,
            SetDefaultFilters = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetDefaultFilters))
                return
              end
              return checkFunc(ns.SetDefaultFilters)
            end,
          })
        end,
        C_TradeSkillUI = function()
          local ns = _G.C_TradeSkillUI
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            AnyRecipeCategoriesFiltered = function()
              return checkFunc(ns.AnyRecipeCategoriesFiltered)
            end,
            AreAnyInventorySlotsFiltered = function()
              return checkFunc(ns.AreAnyInventorySlotsFiltered)
            end,
            CanObliterateCursorItem = function()
              return checkFunc(ns.CanObliterateCursorItem)
            end,
            CanTradeSkillListLink = function()
              return checkFunc(ns.CanTradeSkillListLink)
            end,
            ClearInventorySlotFilter = function()
              return checkFunc(ns.ClearInventorySlotFilter)
            end,
            ClearPendingObliterateItem = function()
              return checkFunc(ns.ClearPendingObliterateItem)
            end,
            ClearRecipeCategoryFilter = function()
              return checkFunc(ns.ClearRecipeCategoryFilter)
            end,
            ClearRecipeSourceTypeFilter = function()
              return checkFunc(ns.ClearRecipeSourceTypeFilter)
            end,
            CloseObliterumForge = function()
              return checkFunc(ns.CloseObliterumForge)
            end,
            CloseTradeSkill = function()
              return checkFunc(ns.CloseTradeSkill)
            end,
            CraftRecipe = function()
              return checkFunc(ns.CraftRecipe)
            end,
            DropPendingObliterateItemFromCursor = function()
              return checkFunc(ns.DropPendingObliterateItemFromCursor)
            end,
            GetAllFilterableInventorySlots = function()
              return checkFunc(ns.GetAllFilterableInventorySlots)
            end,
            GetAllProfessionTradeSkillLines = function()
              return checkFunc(ns.GetAllProfessionTradeSkillLines)
            end,
            GetAllRecipeIDs = function()
              return checkFunc(ns.GetAllRecipeIDs)
            end,
            GetCategories = function()
              return checkFunc(ns.GetCategories)
            end,
            GetCategoryInfo = function()
              return checkFunc(ns.GetCategoryInfo)
            end,
            GetFilterableInventorySlots = function()
              return checkFunc(ns.GetFilterableInventorySlots)
            end,
            GetFilteredRecipeIDs = function()
              return checkFunc(ns.GetFilteredRecipeIDs)
            end,
            GetObliterateSpellID = function()
              return checkFunc(ns.GetObliterateSpellID)
            end,
            GetOnlyShowLearnedRecipes = function()
              return checkFunc(ns.GetOnlyShowLearnedRecipes)
            end,
            GetOnlyShowMakeableRecipes = function()
              return checkFunc(ns.GetOnlyShowMakeableRecipes)
            end,
            GetOnlyShowSkillUpRecipes = function()
              return checkFunc(ns.GetOnlyShowSkillUpRecipes)
            end,
            GetOnlyShowUnlearnedRecipes = function()
              return checkFunc(ns.GetOnlyShowUnlearnedRecipes)
            end,
            GetOptionalReagentBonusText = function()
              return checkFunc(ns.GetOptionalReagentBonusText)
            end,
            GetOptionalReagentInfo = function()
              return checkFunc(ns.GetOptionalReagentInfo)
            end,
            GetPendingObliterateItemID = function()
              return checkFunc(ns.GetPendingObliterateItemID)
            end,
            GetPendingObliterateItemLink = function()
              return checkFunc(ns.GetPendingObliterateItemLink)
            end,
            GetRecipeCooldown = function()
              return checkFunc(ns.GetRecipeCooldown)
            end,
            GetRecipeDescription = function()
              return checkFunc(ns.GetRecipeDescription)
            end,
            GetRecipeInfo = function()
              return checkFunc(ns.GetRecipeInfo)
            end,
            GetRecipeItemLevelFilter = function()
              return checkFunc(ns.GetRecipeItemLevelFilter)
            end,
            GetRecipeItemLink = function()
              return checkFunc(ns.GetRecipeItemLink)
            end,
            GetRecipeItemNameFilter = function()
              return checkFunc(ns.GetRecipeItemNameFilter)
            end,
            GetRecipeLink = function()
              return checkFunc(ns.GetRecipeLink)
            end,
            GetRecipeNumItemsProduced = function()
              return checkFunc(ns.GetRecipeNumItemsProduced)
            end,
            GetRecipeNumReagents = function()
              return checkFunc(ns.GetRecipeNumReagents)
            end,
            GetRecipeReagentInfo = function()
              return checkFunc(ns.GetRecipeReagentInfo)
            end,
            GetRecipeReagentItemLink = function()
              return checkFunc(ns.GetRecipeReagentItemLink)
            end,
            GetRecipeRepeatCount = function()
              return checkFunc(ns.GetRecipeRepeatCount)
            end,
            GetRecipeSourceText = function()
              return checkFunc(ns.GetRecipeSourceText)
            end,
            GetRecipeTools = function()
              return checkFunc(ns.GetRecipeTools)
            end,
            GetSubCategories = function()
              return checkFunc(ns.GetSubCategories)
            end,
            GetTradeSkillDisplayName = function()
              return checkFunc(ns.GetTradeSkillDisplayName)
            end,
            GetTradeSkillLine = function()
              return checkFunc(ns.GetTradeSkillLine)
            end,
            GetTradeSkillLineForRecipe = function()
              return checkFunc(ns.GetTradeSkillLineForRecipe)
            end,
            GetTradeSkillLineInfoByID = function()
              return checkFunc(ns.GetTradeSkillLineInfoByID)
            end,
            GetTradeSkillListLink = function()
              return checkFunc(ns.GetTradeSkillListLink)
            end,
            GetTradeSkillTexture = function()
              return checkFunc(ns.GetTradeSkillTexture)
            end,
            IsAnyRecipeFromSource = function()
              return checkFunc(ns.IsAnyRecipeFromSource)
            end,
            IsDataSourceChanging = function()
              return checkFunc(ns.IsDataSourceChanging)
            end,
            IsEmptySkillLineCategory = function()
              return checkFunc(ns.IsEmptySkillLineCategory)
            end,
            IsInventorySlotFiltered = function()
              return checkFunc(ns.IsInventorySlotFiltered)
            end,
            IsNPCCrafting = function()
              return checkFunc(ns.IsNPCCrafting)
            end,
            IsRecipeCategoryFiltered = function()
              return checkFunc(ns.IsRecipeCategoryFiltered)
            end,
            IsRecipeFavorite = function()
              return checkFunc(ns.IsRecipeFavorite)
            end,
            IsRecipeRepeating = function()
              return checkFunc(ns.IsRecipeRepeating)
            end,
            IsRecipeSearchInProgress = function()
              return checkFunc(ns.IsRecipeSearchInProgress)
            end,
            IsRecipeSourceTypeFiltered = function()
              return checkFunc(ns.IsRecipeSourceTypeFiltered)
            end,
            IsTradeSkillGuild = function()
              return checkFunc(ns.IsTradeSkillGuild)
            end,
            IsTradeSkillGuildMember = function()
              return checkFunc(ns.IsTradeSkillGuildMember)
            end,
            IsTradeSkillLinked = function()
              return checkFunc(ns.IsTradeSkillLinked)
            end,
            IsTradeSkillReady = function()
              return checkFunc(ns.IsTradeSkillReady)
            end,
            ObliterateItem = function()
              return checkFunc(ns.ObliterateItem)
            end,
            OpenTradeSkill = function()
              return checkFunc(ns.OpenTradeSkill)
            end,
            SetInventorySlotFilter = function()
              return checkFunc(ns.SetInventorySlotFilter)
            end,
            SetOnlyShowLearnedRecipes = function()
              return checkFunc(ns.SetOnlyShowLearnedRecipes)
            end,
            SetOnlyShowMakeableRecipes = function()
              return checkFunc(ns.SetOnlyShowMakeableRecipes)
            end,
            SetOnlyShowSkillUpRecipes = function()
              return checkFunc(ns.SetOnlyShowSkillUpRecipes)
            end,
            SetOnlyShowUnlearnedRecipes = function()
              return checkFunc(ns.SetOnlyShowUnlearnedRecipes)
            end,
            SetRecipeCategoryFilter = function()
              return checkFunc(ns.SetRecipeCategoryFilter)
            end,
            SetRecipeFavorite = function()
              return checkFunc(ns.SetRecipeFavorite)
            end,
            SetRecipeItemLevelFilter = function()
              return checkFunc(ns.SetRecipeItemLevelFilter)
            end,
            SetRecipeItemNameFilter = function()
              return checkFunc(ns.SetRecipeItemNameFilter)
            end,
            SetRecipeRepeatCount = function()
              return checkFunc(ns.SetRecipeRepeatCount)
            end,
            SetRecipeSourceTypeFilter = function()
              return checkFunc(ns.SetRecipeSourceTypeFilter)
            end,
            StopRecipeRepeat = function()
              return checkFunc(ns.StopRecipeRepeat)
            end,
          })
        end,
        C_Transmog = function()
          local ns = _G.C_Transmog
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            ApplyAllPending = function()
              return checkFunc(ns.ApplyAllPending)
            end,
            CanHaveSecondaryAppearanceForSlotID = function()
              return checkFunc(ns.CanHaveSecondaryAppearanceForSlotID)
            end,
            CanTransmogItem = function()
              return checkFunc(ns.CanTransmogItem)
            end,
            CanTransmogItemWithItem = function()
              return checkFunc(ns.CanTransmogItemWithItem)
            end,
            ClearAllPending = function()
              return checkFunc(ns.ClearAllPending)
            end,
            ClearPending = function()
              return checkFunc(ns.ClearPending)
            end,
            Close = function()
              return checkFunc(ns.Close)
            end,
            ExtractTransmogIDList = function()
              return checkFunc(ns.ExtractTransmogIDList)
            end,
            GetApplyCost = function()
              return checkFunc(ns.GetApplyCost)
            end,
            GetApplyWarnings = function()
              return checkFunc(ns.GetApplyWarnings)
            end,
            GetBaseCategory = function()
              return checkFunc(ns.GetBaseCategory)
            end,
            GetCreatureDisplayIDForSource = function()
              return checkFunc(ns.GetCreatureDisplayIDForSource)
            end,
            GetItemIDForSource = function()
              return checkFunc(ns.GetItemIDForSource)
            end,
            GetPending = function()
              return checkFunc(ns.GetPending)
            end,
            GetSlotEffectiveCategory = function()
              return checkFunc(ns.GetSlotEffectiveCategory)
            end,
            GetSlotForInventoryType = function()
              return checkFunc(ns.GetSlotForInventoryType)
            end,
            GetSlotInfo = function()
              return checkFunc(ns.GetSlotInfo)
            end,
            GetSlotUseError = function()
              return checkFunc(ns.GetSlotUseError)
            end,
            GetSlotVisualInfo = function()
              return checkFunc(ns.GetSlotVisualInfo)
            end,
            IsAtTransmogNPC = function()
              return checkFunc(ns.IsAtTransmogNPC)
            end,
            IsSlotBeingCollapsed = function()
              return checkFunc(ns.IsSlotBeingCollapsed)
            end,
            LoadOutfit = function()
              return checkFunc(ns.LoadOutfit)
            end,
            SetPending = function()
              return checkFunc(ns.SetPending)
            end,
          })
        end,
        C_TransmogCollection = function()
          local ns = _G.C_TransmogCollection
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            AccountCanCollectSource = function()
              return checkFunc(ns.AccountCanCollectSource)
            end,
            AreAllCollectionTypeFiltersChecked = function()
              return checkFunc(ns.AreAllCollectionTypeFiltersChecked)
            end,
            AreAllSourceTypeFiltersChecked = function()
              return checkFunc(ns.AreAllSourceTypeFiltersChecked)
            end,
            CanAppearanceHaveIllusion = function()
              return checkFunc(ns.CanAppearanceHaveIllusion)
            end,
            ClearNewAppearance = function()
              return checkFunc(ns.ClearNewAppearance)
            end,
            ClearSearch = function()
              return checkFunc(ns.ClearSearch)
            end,
            DeleteOutfit = function()
              return checkFunc(ns.DeleteOutfit)
            end,
            EndSearch = function()
              return checkFunc(ns.EndSearch)
            end,
            GetAllAppearanceSources = function()
              return checkFunc(ns.GetAllAppearanceSources)
            end,
            GetAppearanceCameraID = function()
              return checkFunc(ns.GetAppearanceCameraID)
            end,
            GetAppearanceCameraIDBySource = function()
              return checkFunc(ns.GetAppearanceCameraIDBySource)
            end,
            GetAppearanceInfoBySource = function()
              return checkFunc(ns.GetAppearanceInfoBySource)
            end,
            GetAppearanceSourceDrops = function()
              return checkFunc(ns.GetAppearanceSourceDrops)
            end,
            GetAppearanceSourceInfo = function()
              return checkFunc(ns.GetAppearanceSourceInfo)
            end,
            GetAppearanceSources = function()
              return checkFunc(ns.GetAppearanceSources)
            end,
            GetArtifactAppearanceStrings = function()
              return checkFunc(ns.GetArtifactAppearanceStrings)
            end,
            GetCategoryAppearances = function()
              return checkFunc(ns.GetCategoryAppearances)
            end,
            GetCategoryCollectedCount = function()
              return checkFunc(ns.GetCategoryCollectedCount)
            end,
            GetCategoryForItem = function()
              return checkFunc(ns.GetCategoryForItem)
            end,
            GetCategoryInfo = function()
              return checkFunc(ns.GetCategoryInfo)
            end,
            GetCategoryTotal = function()
              return checkFunc(ns.GetCategoryTotal)
            end,
            GetCollectedShown = function()
              return checkFunc(ns.GetCollectedShown)
            end,
            GetFallbackWeaponAppearance = function()
              return checkFunc(ns.GetFallbackWeaponAppearance)
            end,
            GetIllusionInfo = function()
              return checkFunc(ns.GetIllusionInfo)
            end,
            GetIllusionStrings = function()
              return checkFunc(ns.GetIllusionStrings)
            end,
            GetIllusions = function()
              return checkFunc(ns.GetIllusions)
            end,
            GetInspectItemTransmogInfoList = function()
              return checkFunc(ns.GetInspectItemTransmogInfoList)
            end,
            GetIsAppearanceFavorite = function()
              return checkFunc(ns.GetIsAppearanceFavorite)
            end,
            GetItemInfo = function()
              return checkFunc(ns.GetItemInfo)
            end,
            GetItemTransmogInfoListFromOutfitHyperlink = function()
              return checkFunc(ns.GetItemTransmogInfoListFromOutfitHyperlink)
            end,
            GetLatestAppearance = function()
              return checkFunc(ns.GetLatestAppearance)
            end,
            GetNumMaxOutfits = function()
              return checkFunc(ns.GetNumMaxOutfits)
            end,
            GetNumTransmogSources = function()
              return checkFunc(ns.GetNumTransmogSources)
            end,
            GetOutfitHyperlinkFromItemTransmogInfoList = function()
              return checkFunc(ns.GetOutfitHyperlinkFromItemTransmogInfoList)
            end,
            GetOutfitInfo = function()
              return checkFunc(ns.GetOutfitInfo)
            end,
            GetOutfitItemTransmogInfoList = function()
              return checkFunc(ns.GetOutfitItemTransmogInfoList)
            end,
            GetOutfits = function()
              return checkFunc(ns.GetOutfits)
            end,
            GetPairedArtifactAppearance = function()
              return checkFunc(ns.GetPairedArtifactAppearance)
            end,
            GetSourceIcon = function()
              return checkFunc(ns.GetSourceIcon)
            end,
            GetSourceInfo = function()
              return checkFunc(ns.GetSourceInfo)
            end,
            GetSourceItemID = function()
              return checkFunc(ns.GetSourceItemID)
            end,
            GetSourceRequiredHoliday = function()
              return checkFunc(ns.GetSourceRequiredHoliday)
            end,
            GetUncollectedShown = function()
              return checkFunc(ns.GetUncollectedShown)
            end,
            HasFavorites = function()
              return checkFunc(ns.HasFavorites)
            end,
            IsAppearanceHiddenVisual = function()
              return checkFunc(ns.IsAppearanceHiddenVisual)
            end,
            IsCategoryValidForItem = function()
              return checkFunc(ns.IsCategoryValidForItem)
            end,
            IsNewAppearance = function()
              return checkFunc(ns.IsNewAppearance)
            end,
            IsSearchDBLoading = function()
              return checkFunc(ns.IsSearchDBLoading)
            end,
            IsSearchInProgress = function()
              return checkFunc(ns.IsSearchInProgress)
            end,
            IsSourceTypeFilterChecked = function()
              return checkFunc(ns.IsSourceTypeFilterChecked)
            end,
            IsUsingDefaultFilters = function()
              return checkFunc(ns.IsUsingDefaultFilters)
            end,
            ModifyOutfit = function()
              return checkFunc(ns.ModifyOutfit)
            end,
            NewOutfit = function()
              return checkFunc(ns.NewOutfit)
            end,
            PlayerCanCollectSource = function()
              return checkFunc(ns.PlayerCanCollectSource)
            end,
            PlayerHasTransmog = function()
              return checkFunc(ns.PlayerHasTransmog)
            end,
            PlayerHasTransmogByItemInfo = function()
              return checkFunc(ns.PlayerHasTransmogByItemInfo)
            end,
            PlayerHasTransmogItemModifiedAppearance = function()
              return checkFunc(ns.PlayerHasTransmogItemModifiedAppearance)
            end,
            PlayerKnowsSource = function()
              return checkFunc(ns.PlayerKnowsSource)
            end,
            RenameOutfit = function()
              return checkFunc(ns.RenameOutfit)
            end,
            SearchProgress = function()
              return checkFunc(ns.SearchProgress)
            end,
            SearchSize = function()
              return checkFunc(ns.SearchSize)
            end,
            SetAllCollectionTypeFilters = function()
              return checkFunc(ns.SetAllCollectionTypeFilters)
            end,
            SetAllSourceTypeFilters = function()
              return checkFunc(ns.SetAllSourceTypeFilters)
            end,
            SetCollectedShown = function()
              return checkFunc(ns.SetCollectedShown)
            end,
            SetDefaultFilters = function()
              return checkFunc(ns.SetDefaultFilters)
            end,
            SetIsAppearanceFavorite = function()
              return checkFunc(ns.SetIsAppearanceFavorite)
            end,
            SetSearch = function()
              return checkFunc(ns.SetSearch)
            end,
            SetSearchAndFilterCategory = function()
              return checkFunc(ns.SetSearchAndFilterCategory)
            end,
            SetSourceTypeFilter = function()
              return checkFunc(ns.SetSourceTypeFilter)
            end,
            SetUncollectedShown = function()
              return checkFunc(ns.SetUncollectedShown)
            end,
            UpdateUsableAppearances = function()
              return checkFunc(ns.UpdateUsableAppearances)
            end,
          })
        end,
        C_TransmogSets = function()
          local ns = _G.C_TransmogSets
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            ClearLatestSource = function()
              return checkFunc(ns.ClearLatestSource)
            end,
            ClearNewSource = function()
              return checkFunc(ns.ClearNewSource)
            end,
            ClearSetNewSourcesForSlot = function()
              return checkFunc(ns.ClearSetNewSourcesForSlot)
            end,
            GetAllSets = function()
              return checkFunc(ns.GetAllSets)
            end,
            GetAllSourceIDs = function()
              return checkFunc(ns.GetAllSourceIDs)
            end,
            GetBaseSetID = function()
              return checkFunc(ns.GetBaseSetID)
            end,
            GetBaseSets = function()
              return checkFunc(ns.GetBaseSets)
            end,
            GetBaseSetsCounts = function()
              return checkFunc(ns.GetBaseSetsCounts)
            end,
            GetBaseSetsFilter = function()
              return checkFunc(ns.GetBaseSetsFilter)
            end,
            GetCameraIDs = function()
              return checkFunc(ns.GetCameraIDs)
            end,
            GetIsFavorite = function()
              return checkFunc(ns.GetIsFavorite)
            end,
            GetLatestSource = function()
              return checkFunc(ns.GetLatestSource)
            end,
            GetSetInfo = function()
              return checkFunc(ns.GetSetInfo)
            end,
            GetSetNewSources = function()
              return checkFunc(ns.GetSetNewSources)
            end,
            GetSetPrimaryAppearances = function()
              return checkFunc(ns.GetSetPrimaryAppearances)
            end,
            GetSetsContainingSourceID = function()
              return checkFunc(ns.GetSetsContainingSourceID)
            end,
            GetSourceIDsForSlot = function()
              return checkFunc(ns.GetSourceIDsForSlot)
            end,
            GetSourcesForSlot = function()
              return checkFunc(ns.GetSourcesForSlot)
            end,
            GetUsableSets = function()
              return checkFunc(ns.GetUsableSets)
            end,
            GetVariantSets = function()
              return checkFunc(ns.GetVariantSets)
            end,
            HasUsableSets = function()
              return checkFunc(ns.HasUsableSets)
            end,
            IsBaseSetCollected = function()
              return checkFunc(ns.IsBaseSetCollected)
            end,
            IsNewSource = function()
              return checkFunc(ns.IsNewSource)
            end,
            IsSetVisible = function()
              return checkFunc(ns.IsSetVisible)
            end,
            IsUsingDefaultBaseSetsFilters = function()
              return checkFunc(ns.IsUsingDefaultBaseSetsFilters)
            end,
            SetBaseSetsFilter = function()
              return checkFunc(ns.SetBaseSetsFilter)
            end,
            SetDefaultBaseSetsFilters = function()
              return checkFunc(ns.SetDefaultBaseSetsFilters)
            end,
            SetHasNewSources = function()
              return checkFunc(ns.SetHasNewSources)
            end,
            SetHasNewSourcesForSlot = function()
              return checkFunc(ns.SetHasNewSourcesForSlot)
            end,
            SetIsFavorite = function()
              return checkFunc(ns.SetIsFavorite)
            end,
          })
        end,
        C_Trophy = function()
          local ns = _G.C_Trophy
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            MonumentChangeAppearanceToTrophyID = function()
              return checkFunc(ns.MonumentChangeAppearanceToTrophyID)
            end,
            MonumentCloseMonumentUI = function()
              return checkFunc(ns.MonumentCloseMonumentUI)
            end,
            MonumentGetCount = function()
              return checkFunc(ns.MonumentGetCount)
            end,
            MonumentGetSelectedTrophyID = function()
              return checkFunc(ns.MonumentGetSelectedTrophyID)
            end,
            MonumentGetTrophyInfoByIndex = function()
              return checkFunc(ns.MonumentGetTrophyInfoByIndex)
            end,
            MonumentLoadList = function()
              return checkFunc(ns.MonumentLoadList)
            end,
            MonumentLoadSelectedTrophyID = function()
              return checkFunc(ns.MonumentLoadSelectedTrophyID)
            end,
            MonumentRevertAppearanceToSaved = function()
              return checkFunc(ns.MonumentRevertAppearanceToSaved)
            end,
            MonumentSaveSelection = function()
              return checkFunc(ns.MonumentSaveSelection)
            end,
          })
        end,
        C_Tutorial = function()
          local ns = _G.C_Tutorial
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            AbandonTutorialArea = function()
              return checkFunc(ns.AbandonTutorialArea)
            end,
            ReturnToTutorialArea = function()
              return checkFunc(ns.ReturnToTutorialArea)
            end,
          })
        end,
        C_UI = function()
          local ns = _G.C_UI
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            DoesAnyDisplayHaveNotch = function()
              return checkFunc(ns.DoesAnyDisplayHaveNotch)
            end,
            GetTopLeftNotchSafeRegion = function()
              return checkFunc(ns.GetTopLeftNotchSafeRegion)
            end,
            GetTopRightNotchSafeRegion = function()
              return checkFunc(ns.GetTopRightNotchSafeRegion)
            end,
            Reload = function()
              return checkFunc(ns.Reload)
            end,
            ShouldUIParentAvoidNotch = function()
              return checkFunc(ns.ShouldUIParentAvoidNotch)
            end,
          })
        end,
        C_UIWidgetManager = function()
          local ns = _G.C_UIWidgetManager
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetAllWidgetsBySetID = function()
              return checkFunc(ns.GetAllWidgetsBySetID)
            end,
            GetBelowMinimapWidgetSetID = function()
              return checkFunc(ns.GetBelowMinimapWidgetSetID)
            end,
            GetBulletTextListWidgetVisualizationInfo = function()
              return checkFunc(ns.GetBulletTextListWidgetVisualizationInfo)
            end,
            GetCaptureBarWidgetVisualizationInfo = function()
              return checkFunc(ns.GetCaptureBarWidgetVisualizationInfo)
            end,
            GetCaptureZoneVisualizationInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetCaptureZoneVisualizationInfo))
                return
              end
              return checkFunc(ns.GetCaptureZoneVisualizationInfo)
            end,
            GetDiscreteProgressStepsVisualizationInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetDiscreteProgressStepsVisualizationInfo))
                return
              end
              return checkFunc(ns.GetDiscreteProgressStepsVisualizationInfo)
            end,
            GetDoubleIconAndTextWidgetVisualizationInfo = function()
              return checkFunc(ns.GetDoubleIconAndTextWidgetVisualizationInfo)
            end,
            GetDoubleStateIconRowVisualizationInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetDoubleStateIconRowVisualizationInfo))
                return
              end
              return checkFunc(ns.GetDoubleStateIconRowVisualizationInfo)
            end,
            GetDoubleStatusBarWidgetVisualizationInfo = function()
              return checkFunc(ns.GetDoubleStatusBarWidgetVisualizationInfo)
            end,
            GetHorizontalCurrenciesWidgetVisualizationInfo = function()
              return checkFunc(ns.GetHorizontalCurrenciesWidgetVisualizationInfo)
            end,
            GetIconAndTextWidgetVisualizationInfo = function()
              return checkFunc(ns.GetIconAndTextWidgetVisualizationInfo)
            end,
            GetIconTextAndBackgroundWidgetVisualizationInfo = function()
              return checkFunc(ns.GetIconTextAndBackgroundWidgetVisualizationInfo)
            end,
            GetIconTextAndCurrenciesWidgetVisualizationInfo = function()
              return checkFunc(ns.GetIconTextAndCurrenciesWidgetVisualizationInfo)
            end,
            GetObjectiveTrackerWidgetSetID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetObjectiveTrackerWidgetSetID))
                return
              end
              return checkFunc(ns.GetObjectiveTrackerWidgetSetID)
            end,
            GetPowerBarWidgetSetID = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetPowerBarWidgetSetID))
                return
              end
              return checkFunc(ns.GetPowerBarWidgetSetID)
            end,
            GetScenarioHeaderCurrenciesAndBackgroundWidgetVisualizationInfo = function()
              return checkFunc(ns.GetScenarioHeaderCurrenciesAndBackgroundWidgetVisualizationInfo)
            end,
            GetScenarioHeaderTimerWidgetVisualizationInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetScenarioHeaderTimerWidgetVisualizationInfo))
                return
              end
              return checkFunc(ns.GetScenarioHeaderTimerWidgetVisualizationInfo)
            end,
            GetSpacerVisualizationInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetSpacerVisualizationInfo))
                return
              end
              return checkFunc(ns.GetSpacerVisualizationInfo)
            end,
            GetSpellDisplayVisualizationInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetSpellDisplayVisualizationInfo))
                return
              end
              return checkFunc(ns.GetSpellDisplayVisualizationInfo)
            end,
            GetStackedResourceTrackerWidgetVisualizationInfo = function()
              return checkFunc(ns.GetStackedResourceTrackerWidgetVisualizationInfo)
            end,
            GetStatusBarWidgetVisualizationInfo = function()
              return checkFunc(ns.GetStatusBarWidgetVisualizationInfo)
            end,
            GetTextColumnRowVisualizationInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetTextColumnRowVisualizationInfo))
                return
              end
              return checkFunc(ns.GetTextColumnRowVisualizationInfo)
            end,
            GetTextWithStateWidgetVisualizationInfo = function()
              return checkFunc(ns.GetTextWithStateWidgetVisualizationInfo)
            end,
            GetTextureAndTextRowVisualizationInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetTextureAndTextRowVisualizationInfo))
                return
              end
              return checkFunc(ns.GetTextureAndTextRowVisualizationInfo)
            end,
            GetTextureAndTextVisualizationInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetTextureAndTextVisualizationInfo))
                return
              end
              return checkFunc(ns.GetTextureAndTextVisualizationInfo)
            end,
            GetTextureWithAnimationVisualizationInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetTextureWithAnimationVisualizationInfo))
                return
              end
              return checkFunc(ns.GetTextureWithAnimationVisualizationInfo)
            end,
            GetTextureWithStateVisualizationInfo = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetTextureWithStateVisualizationInfo))
                return
              end
              return checkFunc(ns.GetTextureWithStateVisualizationInfo)
            end,
            GetTopCenterWidgetSetID = function()
              return checkFunc(ns.GetTopCenterWidgetSetID)
            end,
            GetUnitPowerBarWidgetVisualizationInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetUnitPowerBarWidgetVisualizationInfo))
                return
              end
              return checkFunc(ns.GetUnitPowerBarWidgetVisualizationInfo)
            end,
            GetWidgetSetInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetWidgetSetInfo))
                return
              end
              return checkFunc(ns.GetWidgetSetInfo)
            end,
            GetZoneControlVisualizationInfo = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetZoneControlVisualizationInfo))
                return
              end
              return checkFunc(ns.GetZoneControlVisualizationInfo)
            end,
            RegisterUnitForWidgetUpdates = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.RegisterUnitForWidgetUpdates))
                return
              end
              return checkFunc(ns.RegisterUnitForWidgetUpdates)
            end,
            SetProcessingUnit = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetProcessingUnit))
                return
              end
              return checkFunc(ns.SetProcessingUnit)
            end,
            SetProcessingUnitGuid = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SetProcessingUnitGuid))
                return
              end
              return checkFunc(ns.SetProcessingUnitGuid)
            end,
            UnregisterUnitForWidgetUpdates = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.UnregisterUnitForWidgetUpdates))
                return
              end
              return checkFunc(ns.UnregisterUnitForWidgetUpdates)
            end,
          })
        end,
        C_UserFeedback = function()
          local ns = _G.C_UserFeedback
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            SubmitBug = function()
              return checkFunc(ns.SubmitBug)
            end,
            SubmitSuggestion = function()
              return checkFunc(ns.SubmitSuggestion)
            end,
          })
        end,
        C_VideoOptions = function()
          local ns = _G.C_VideoOptions
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetGxAdapterInfo = function()
              return checkFunc(ns.GetGxAdapterInfo)
            end,
          })
        end,
        C_VignetteInfo = function()
          local ns = _G.C_VignetteInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            FindBestUniqueVignette = function()
              return checkFunc(ns.FindBestUniqueVignette)
            end,
            GetVignetteInfo = function()
              return checkFunc(ns.GetVignetteInfo)
            end,
            GetVignettePosition = function()
              return checkFunc(ns.GetVignettePosition)
            end,
            GetVignettes = function()
              return checkFunc(ns.GetVignettes)
            end,
          })
        end,
        C_VoiceChat = function()
          local ns = _G.C_VoiceChat
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            ActivateChannel = function()
              return checkFunc(ns.ActivateChannel)
            end,
            ActivateChannelTranscription = function()
              return checkFunc(ns.ActivateChannelTranscription)
            end,
            BeginLocalCapture = function()
              return checkFunc(ns.BeginLocalCapture)
            end,
            CanPlayerUseVoiceChat = function()
              return checkFunc(ns.CanPlayerUseVoiceChat)
            end,
            CreateChannel = function()
              return checkFunc(ns.CreateChannel)
            end,
            DeactivateChannel = function()
              return checkFunc(ns.DeactivateChannel)
            end,
            DeactivateChannelTranscription = function()
              return checkFunc(ns.DeactivateChannelTranscription)
            end,
            EndLocalCapture = function()
              return checkFunc(ns.EndLocalCapture)
            end,
            GetActiveChannelID = function()
              return checkFunc(ns.GetActiveChannelID)
            end,
            GetActiveChannelType = function()
              return checkFunc(ns.GetActiveChannelType)
            end,
            GetAvailableInputDevices = function()
              return checkFunc(ns.GetAvailableInputDevices)
            end,
            GetAvailableOutputDevices = function()
              return checkFunc(ns.GetAvailableOutputDevices)
            end,
            GetChannel = function()
              return checkFunc(ns.GetChannel)
            end,
            GetChannelForChannelType = function()
              return checkFunc(ns.GetChannelForChannelType)
            end,
            GetChannelForCommunityStream = function()
              return checkFunc(ns.GetChannelForCommunityStream)
            end,
            GetCommunicationMode = function()
              return checkFunc(ns.GetCommunicationMode)
            end,
            GetCurrentVoiceChatConnectionStatusCode = function()
              return checkFunc(ns.GetCurrentVoiceChatConnectionStatusCode)
            end,
            GetInputVolume = function()
              return checkFunc(ns.GetInputVolume)
            end,
            GetJoinClubVoiceChannelError = function()
              if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.GetJoinClubVoiceChannelError))
                return
              end
              return checkFunc(ns.GetJoinClubVoiceChannelError)
            end,
            GetLocalPlayerActiveChannelMemberInfo = function()
              return checkFunc(ns.GetLocalPlayerActiveChannelMemberInfo)
            end,
            GetLocalPlayerMemberID = function()
              return checkFunc(ns.GetLocalPlayerMemberID)
            end,
            GetMasterVolumeScale = function()
              return checkFunc(ns.GetMasterVolumeScale)
            end,
            GetMemberGUID = function()
              return checkFunc(ns.GetMemberGUID)
            end,
            GetMemberID = function()
              return checkFunc(ns.GetMemberID)
            end,
            GetMemberInfo = function()
              return checkFunc(ns.GetMemberInfo)
            end,
            GetMemberName = function()
              return checkFunc(ns.GetMemberName)
            end,
            GetMemberVolume = function()
              return checkFunc(ns.GetMemberVolume)
            end,
            GetOutputVolume = function()
              return checkFunc(ns.GetOutputVolume)
            end,
            GetPTTButtonPressedState = function()
              return checkFunc(ns.GetPTTButtonPressedState)
            end,
            GetProcesses = function()
              return checkFunc(ns.GetProcesses)
            end,
            GetPushToTalkBinding = function()
              return checkFunc(ns.GetPushToTalkBinding)
            end,
            GetRemoteTtsVoices = function()
              return checkFunc(ns.GetRemoteTtsVoices)
            end,
            GetTtsVoices = function()
              return checkFunc(ns.GetTtsVoices)
            end,
            GetVADSensitivity = function()
              return checkFunc(ns.GetVADSensitivity)
            end,
            IsChannelJoinPending = function()
              return checkFunc(ns.IsChannelJoinPending)
            end,
            IsDeafened = function()
              return checkFunc(ns.IsDeafened)
            end,
            IsEnabled = function()
              return checkFunc(ns.IsEnabled)
            end,
            IsLoggedIn = function()
              return checkFunc(ns.IsLoggedIn)
            end,
            IsMemberLocalPlayer = function()
              return checkFunc(ns.IsMemberLocalPlayer)
            end,
            IsMemberMuted = function()
              return checkFunc(ns.IsMemberMuted)
            end,
            IsMemberMutedForAll = function()
              return checkFunc(ns.IsMemberMutedForAll)
            end,
            IsMemberSilenced = function()
              return checkFunc(ns.IsMemberSilenced)
            end,
            IsMuted = function()
              return checkFunc(ns.IsMuted)
            end,
            IsParentalDisabled = function()
              return checkFunc(ns.IsParentalDisabled)
            end,
            IsParentalMuted = function()
              return checkFunc(ns.IsParentalMuted)
            end,
            IsPlayerUsingVoice = function()
              return checkFunc(ns.IsPlayerUsingVoice)
            end,
            IsSilenced = function()
              return checkFunc(ns.IsSilenced)
            end,
            IsSpeakForMeActive = function()
              return checkFunc(ns.IsSpeakForMeActive)
            end,
            IsSpeakForMeAllowed = function()
              return checkFunc(ns.IsSpeakForMeAllowed)
            end,
            IsTranscriptionAllowed = function()
              return checkFunc(ns.IsTranscriptionAllowed)
            end,
            LeaveChannel = function()
              return checkFunc(ns.LeaveChannel)
            end,
            Login = function()
              return checkFunc(ns.Login)
            end,
            Logout = function()
              return checkFunc(ns.Logout)
            end,
            MarkChannelsDiscovered = function()
              return checkFunc(ns.MarkChannelsDiscovered)
            end,
            RequestJoinAndActivateCommunityStreamChannel = function()
              return checkFunc(ns.RequestJoinAndActivateCommunityStreamChannel)
            end,
            RequestJoinChannelByChannelType = function()
              return checkFunc(ns.RequestJoinChannelByChannelType)
            end,
            SetCommunicationMode = function()
              return checkFunc(ns.SetCommunicationMode)
            end,
            SetDeafened = function()
              return checkFunc(ns.SetDeafened)
            end,
            SetInputDevice = function()
              return checkFunc(ns.SetInputDevice)
            end,
            SetInputVolume = function()
              return checkFunc(ns.SetInputVolume)
            end,
            SetMasterVolumeScale = function()
              return checkFunc(ns.SetMasterVolumeScale)
            end,
            SetMemberMuted = function()
              return checkFunc(ns.SetMemberMuted)
            end,
            SetMemberVolume = function()
              return checkFunc(ns.SetMemberVolume)
            end,
            SetMuted = function()
              return checkFunc(ns.SetMuted)
            end,
            SetOutputDevice = function()
              return checkFunc(ns.SetOutputDevice)
            end,
            SetOutputVolume = function()
              return checkFunc(ns.SetOutputVolume)
            end,
            SetPortraitTexture = function()
              return checkFunc(ns.SetPortraitTexture)
            end,
            SetPushToTalkBinding = function()
              return checkFunc(ns.SetPushToTalkBinding)
            end,
            SetVADSensitivity = function()
              return checkFunc(ns.SetVADSensitivity)
            end,
            ShouldDiscoverChannels = function()
              return checkFunc(ns.ShouldDiscoverChannels)
            end,
            SpeakRemoteTextSample = function()
              return checkFunc(ns.SpeakRemoteTextSample)
            end,
            SpeakText = function()
              return checkFunc(ns.SpeakText)
            end,
            StopSpeakingText = function()
              return checkFunc(ns.StopSpeakingText)
            end,
            ToggleDeafened = function()
              return checkFunc(ns.ToggleDeafened)
            end,
            ToggleMemberMuted = function()
              return checkFunc(ns.ToggleMemberMuted)
            end,
            ToggleMuted = function()
              return checkFunc(ns.ToggleMuted)
            end,
          })
        end,
        C_WeeklyRewards = function()
          local ns = _G.C_WeeklyRewards
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            AreRewardsForCurrentRewardPeriod = function()
              return checkFunc(ns.AreRewardsForCurrentRewardPeriod)
            end,
            CanClaimRewards = function()
              return checkFunc(ns.CanClaimRewards)
            end,
            ClaimReward = function()
              return checkFunc(ns.ClaimReward)
            end,
            CloseInteraction = function()
              return checkFunc(ns.CloseInteraction)
            end,
            GetActivities = function()
              return checkFunc(ns.GetActivities)
            end,
            GetActivityEncounterInfo = function()
              return checkFunc(ns.GetActivityEncounterInfo)
            end,
            GetConquestWeeklyProgress = function()
              return checkFunc(ns.GetConquestWeeklyProgress)
            end,
            GetExampleRewardItemHyperlinks = function()
              return checkFunc(ns.GetExampleRewardItemHyperlinks)
            end,
            GetItemHyperlink = function()
              return checkFunc(ns.GetItemHyperlink)
            end,
            GetNextMythicPlusIncrease = function()
              return checkFunc(ns.GetNextMythicPlusIncrease)
            end,
            HasAvailableRewards = function()
              return checkFunc(ns.HasAvailableRewards)
            end,
            HasGeneratedRewards = function()
              return checkFunc(ns.HasGeneratedRewards)
            end,
            HasInteraction = function()
              return checkFunc(ns.HasInteraction)
            end,
            OnUIInteract = function()
              return checkFunc(ns.OnUIInteract)
            end,
          })
        end,
        C_Widget = function()
          local ns = _G.C_Widget
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            IsFrameWidget = function()
              return checkFunc(ns.IsFrameWidget)
            end,
            IsRenderableWidget = function()
              return checkFunc(ns.IsRenderableWidget)
            end,
            IsWidget = function()
              return checkFunc(ns.IsWidget)
            end,
          })
        end,
        C_WowTokenPublic = function()
          local ns = _G.C_WowTokenPublic
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            BuyToken = function()
              return checkFunc(ns.BuyToken)
            end,
            GetCommerceSystemStatus = function()
              return checkFunc(ns.GetCommerceSystemStatus)
            end,
            GetCurrentMarketPrice = function()
              return checkFunc(ns.GetCurrentMarketPrice)
            end,
            GetGuaranteedPrice = function()
              return checkFunc(ns.GetGuaranteedPrice)
            end,
            GetListedAuctionableTokenInfo = function()
              return checkFunc(ns.GetListedAuctionableTokenInfo)
            end,
            GetNumListedAuctionableTokens = function()
              return checkFunc(ns.GetNumListedAuctionableTokens)
            end,
            IsAuctionableWowToken = function()
              return checkFunc(ns.IsAuctionableWowToken)
            end,
            IsConsumableWowToken = function()
              return checkFunc(ns.IsConsumableWowToken)
            end,
            SellToken = function()
              if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                assertEquals('nil', type(ns.SellToken))
                return
              end
              return checkFunc(ns.SellToken)
            end,
            UpdateListedAuctionableTokens = function()
              return checkFunc(ns.UpdateListedAuctionableTokens)
            end,
            UpdateMarketPrice = function()
              return checkFunc(ns.UpdateMarketPrice)
            end,
            UpdateTokenCount = function()
              return checkFunc(ns.UpdateTokenCount)
            end,
          })
        end,
        C_WowTokenUI = function()
          local ns = _G.C_WowTokenUI
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            StartTokenSell = function()
              return checkFunc(ns.StartTokenSell)
            end,
          })
        end,
        C_ZoneAbility = function()
          local ns = _G.C_ZoneAbility
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetActiveAbilities = function()
              return checkFunc(ns.GetActiveAbilities)
            end,
          })
        end,
        Kiosk = function()
          local ns = _G.Kiosk
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
            GetCharacterTemplateSetIndex = function()
              return checkFunc(ns.GetCharacterTemplateSetIndex)
            end,
            IsEnabled = function()
              return checkFunc(ns.IsEnabled)
            end,
            ShutdownSession = function()
              return checkFunc(ns.ShutdownSession)
            end,
            StartSession = function()
              return checkFunc(ns.StartSession)
            end,
          })
        end,
      }
    end,
    globalApis = function()
      return {
        AcceptAreaSpiritHeal = function()
          local fn = _G.AcceptAreaSpiritHeal
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        AcceptBattlefieldPort = function()
          local fn = _G.AcceptBattlefieldPort
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        AddChatWindowMessages = function()
          local fn = _G.AddChatWindowMessages
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        AddQuestWatch = function()
          local fn = _G.AddQuestWatch
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        AntiAliasingSupported = function()
          local fn = _G.AntiAliasingSupported
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        AreDangerousScriptsAllowed = function()
          local fn = _G.AreDangerousScriptsAllowed
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        AscendStop = function()
          local fn = _G.AscendStop
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        AssistUnit = function()
          local fn = _G.AssistUnit
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        AttackTarget = function()
          local fn = _G.AttackTarget
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        BNFeaturesEnabled = function()
          local fn = _G.BNFeaturesEnabled
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        BNFeaturesEnabledAndConnected = function()
          local fn = _G.BNFeaturesEnabledAndConnected
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        BNGetBlockedInfo = function()
          local fn = _G.BNGetBlockedInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        BNGetFriendInfo = function()
          local fn = _G.BNGetFriendInfo
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        BNGetFriendInviteInfo = function()
          local fn = _G.BNGetFriendInviteInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        BNGetInfo = function()
          local fn = _G.BNGetInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        BNGetNumBlocked = function()
          local fn = _G.BNGetNumBlocked
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        BNGetNumFriendInvites = function()
          local fn = _G.BNGetNumFriendInvites
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        BNGetNumFriends = function()
          local fn = _G.BNGetNumFriends
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        BankButtonIDToInvSlotID = function()
          local fn = _G.BankButtonIDToInvSlotID
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        BreakUpLargeNumbers = function()
          local fn = _G.BreakUpLargeNumbers
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CameraOrSelectOrMoveStart = function()
          local fn = _G.CameraOrSelectOrMoveStart
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CameraOrSelectOrMoveStop = function()
          local fn = _G.CameraOrSelectOrMoveStop
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CameraZoomIn = function()
          local fn = _G.CameraZoomIn
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CameraZoomOut = function()
          local fn = _G.CameraZoomOut
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CanAffordMerchantItem = function()
          local fn = _G.CanAffordMerchantItem
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CanAutoSetGamePadCursorControl = function()
          local fn = _G.CanAutoSetGamePadCursorControl
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CanBeRaidTarget = function()
          local fn = _G.CanBeRaidTarget
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CanEditGuildInfo = function()
          local fn = _G.CanEditGuildInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CanEditMOTD = function()
          local fn = _G.CanEditMOTD
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CanEditOfficerNote = function()
          local fn = _G.CanEditOfficerNote
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CanExitVehicle = function()
          local fn = _G.CanExitVehicle
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CanGuildBankRepair = function()
          local fn = _G.CanGuildBankRepair
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CanGuildDemote = function()
          local fn = _G.CanGuildDemote
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CanGuildInvite = function()
          local fn = _G.CanGuildInvite
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CanGuildPromote = function()
          local fn = _G.CanGuildPromote
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CanHearthAndResurrectFromArea = function()
          local fn = _G.CanHearthAndResurrectFromArea
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CanInspect = function()
          local fn = _G.CanInspect
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CanJoinBattlefieldAsGroup = function()
          local fn = _G.CanJoinBattlefieldAsGroup
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CanMerchantRepair = function()
          local fn = _G.CanMerchantRepair
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CanPartyLFGBackfill = function()
          local fn = _G.CanPartyLFGBackfill
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CanReplaceGuildMaster = function()
          local fn = _G.CanReplaceGuildMaster
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CanSendSoRByText = function()
          local fn = _G.CanSendSoRByText
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CanSignPetition = function()
          local fn = _G.CanSignPetition
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CanTrackBattlePets = function()
          local fn = _G.CanTrackBattlePets
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CanUpgradeExpansion = function()
          local fn = _G.CanUpgradeExpansion
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CanUseVoidStorage = function()
          local fn = _G.CanUseVoidStorage
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CanWithdrawGuildBankMoney = function()
          local fn = _G.CanWithdrawGuildBankMoney
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CancelEmote = function()
          local fn = _G.CancelEmote
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CancelLogout = function()
          local fn = _G.CancelLogout
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CancelShapeshiftForm = function()
          local fn = _G.CancelShapeshiftForm
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CancelSpellByName = function()
          local fn = _G.CancelSpellByName
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CannotBeResurrected = function()
          local fn = _G.CannotBeResurrected
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CastPetAction = function()
          local fn = _G.CastPetAction
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CastShapeshiftForm = function()
          local fn = _G.CastShapeshiftForm
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CastSpellByName = function()
          local fn = _G.CastSpellByName
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CastingInfo = function()
          local fn = _G.CastingInfo
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CenterCamera = function()
          local fn = _G.CenterCamera
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ChangeActionBarPage = function()
          local fn = _G.ChangeActionBarPage
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ChannelInfo = function()
          local fn = _G.ChannelInfo
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CheckInbox = function()
          local fn = _G.CheckInbox
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ClearBattlemaster = function()
          local fn = _G.ClearBattlemaster
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ClearFocus = function()
          local fn = _G.ClearFocus
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ClearOverrideBindings = function()
          local fn = _G.ClearOverrideBindings
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ClearPartyAssignment = function()
          local fn = _G.ClearPartyAssignment
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ClearTarget = function()
          local fn = _G.ClearTarget
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CloseAuctionHouse = function()
          local fn = _G.CloseAuctionHouse
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CloseBankFrame = function()
          local fn = _G.CloseBankFrame
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CloseCraft = function()
          local fn = _G.CloseCraft
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CloseGossip = function()
          local fn = _G.CloseGossip
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CloseGuildBankFrame = function()
          local fn = _G.CloseGuildBankFrame
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CloseGuildRegistrar = function()
          local fn = _G.CloseGuildRegistrar
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CloseItemText = function()
          local fn = _G.CloseItemText
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CloseLoot = function()
          local fn = _G.CloseLoot
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CloseMail = function()
          local fn = _G.CloseMail
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CloseMerchant = function()
          local fn = _G.CloseMerchant
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ClosePetStables = function()
          local fn = _G.ClosePetStables
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ClosePetition = function()
          local fn = _G.ClosePetition
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ClosePetitionRegistrar = function()
          local fn = _G.ClosePetitionRegistrar
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CloseQuest = function()
          local fn = _G.CloseQuest
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CloseResearch = function()
          local fn = _G.CloseResearch
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CloseSocketInfo = function()
          local fn = _G.CloseSocketInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CloseTabardCreation = function()
          local fn = _G.CloseTabardCreation
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CloseTrade = function()
          local fn = _G.CloseTrade
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CloseTradeSkill = function()
          local fn = _G.CloseTradeSkill
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CloseTrainer = function()
          local fn = _G.CloseTrainer
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CloseVoidStorageFrame = function()
          local fn = _G.CloseVoidStorageFrame
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CollapseSkillHeader = function()
          local fn = _G.CollapseSkillHeader
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CombatLogAddFilter = function()
          local fn = _G.CombatLogAddFilter
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CombatLogGetCurrentEntry = function()
          local fn = _G.CombatLogGetCurrentEntry
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CombatLogGetCurrentEventInfo = function()
          local fn = _G.CombatLogGetCurrentEventInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CombatLogGetNumEntries = function()
          local fn = _G.CombatLogGetNumEntries
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CombatLogResetFilter = function()
          local fn = _G.CombatLogResetFilter
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CombatLogSetCurrentEntry = function()
          local fn = _G.CombatLogSetCurrentEntry
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CombatLog_Object_IsA = function()
          local fn = _G.CombatLog_Object_IsA
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CombatTextSetActiveUnit = function()
          local fn = _G.CombatTextSetActiveUnit
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ConsoleExec = function()
          local fn = _G.ConsoleExec
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ContainerIDToInventoryID = function()
          local fn = _G.ContainerIDToInventoryID
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CraftIsEnchanting = function()
          local fn = _G.CraftIsEnchanting
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CreateFont = function()
          local fn = _G.CreateFont
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CreateFrame = function()
          local fn = _G.CreateFrame
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CursorCanGoInSlot = function()
          local fn = _G.CursorCanGoInSlot
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        CursorHasItem = function()
          local fn = _G.CursorHasItem
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        DeathRecap_HasEvents = function()
          local fn = _G.DeathRecap_HasEvents
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        DeleteMacro = function()
          local fn = _G.DeleteMacro
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        DescendStop = function()
          local fn = _G.DescendStop
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        DisableAddOn = function()
          local fn = _G.DisableAddOn
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        Dismount = function()
          local fn = _G.Dismount
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        DoEmote = function()
          local fn = _G.DoEmote
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        DoesCurrentLocaleSellExpansionLevels = function()
          local fn = _G.DoesCurrentLocaleSellExpansionLevels
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        DoesSpellExist = function()
          local fn = _G.DoesSpellExist
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        DropCursorMoney = function()
          local fn = _G.DropCursorMoney
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        DumpMovementCapture = function()
          local fn = _G.DumpMovementCapture
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        EJ_GetCurrentTier = function()
          local fn = _G.EJ_GetCurrentTier
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        EJ_GetDifficulty = function()
          local fn = _G.EJ_GetDifficulty
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        EJ_GetEncounterInfo = function()
          local fn = _G.EJ_GetEncounterInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        EJ_GetInstanceByIndex = function()
          local fn = _G.EJ_GetInstanceByIndex
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        EJ_GetInstanceInfo = function()
          local fn = _G.EJ_GetInstanceInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        EJ_GetLootFilter = function()
          local fn = _G.EJ_GetLootFilter
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        EJ_GetNumLoot = function()
          local fn = _G.EJ_GetNumLoot
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        EJ_GetNumTiers = function()
          local fn = _G.EJ_GetNumTiers
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        EJ_GetTierInfo = function()
          local fn = _G.EJ_GetTierInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        EJ_IsValidInstanceDifficulty = function()
          local fn = _G.EJ_IsValidInstanceDifficulty
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        EJ_SelectTier = function()
          local fn = _G.EJ_SelectTier
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        EnableAddOn = function()
          local fn = _G.EnableAddOn
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        EnumerateFrames = function()
          local fn = _G.EnumerateFrames
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        EnumerateServerChannels = function()
          local fn = _G.EnumerateServerChannels
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        EquipItemByName = function()
          local fn = _G.EquipItemByName
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ExpandTrainerSkillLine = function()
          local fn = _G.ExpandTrainerSkillLine
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        FillLocalizedClassList = function()
          local fn = _G.FillLocalizedClassList
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        FindSpellBookSlotBySpellID = function()
          local fn = _G.FindSpellBookSlotBySpellID
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        FlashClientIcon = function()
          local fn = _G.FlashClientIcon
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        FlipCameraYaw = function()
          local fn = _G.FlipCameraYaw
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        FocusUnit = function()
          local fn = _G.FocusUnit
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        FollowUnit = function()
          local fn = _G.FollowUnit
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GMEuropaBugsEnabled = function()
          local fn = _G.GMEuropaBugsEnabled
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GMEuropaComplaintsEnabled = function()
          local fn = _G.GMEuropaComplaintsEnabled
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GMEuropaSuggestionsEnabled = function()
          local fn = _G.GMEuropaSuggestionsEnabled
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GMEuropaTicketsEnabled = function()
          local fn = _G.GMEuropaTicketsEnabled
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GMSubmitBug = function()
          local fn = _G.GMSubmitBug
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GameMovieFinished = function()
          local fn = _G.GameMovieFinished
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetAccountExpansionLevel = function()
          local fn = _G.GetAccountExpansionLevel
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetAchievementCriteriaInfo = function()
          local fn = _G.GetAchievementCriteriaInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetAchievementCriteriaInfoByID = function()
          local fn = _G.GetAchievementCriteriaInfoByID
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetAchievementInfo = function()
          local fn = _G.GetAchievementInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetAchievementNumCriteria = function()
          local fn = _G.GetAchievementNumCriteria
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetActionBarPage = function()
          local fn = _G.GetActionBarPage
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetActionBarToggles = function()
          local fn = _G.GetActionBarToggles
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetActionCharges = function()
          local fn = _G.GetActionCharges
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetActionCooldown = function()
          local fn = _G.GetActionCooldown
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetActionCount = function()
          local fn = _G.GetActionCount
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetActionInfo = function()
          local fn = _G.GetActionInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetActionLossOfControlCooldown = function()
          local fn = _G.GetActionLossOfControlCooldown
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetActionText = function()
          local fn = _G.GetActionText
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetActionTexture = function()
          local fn = _G.GetActionTexture
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetActiveLootRollIDs = function()
          local fn = _G.GetActiveLootRollIDs
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetActiveQuestID = function()
          local fn = _G.GetActiveQuestID
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetActiveSpecGroup = function()
          local fn = _G.GetActiveSpecGroup
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetActiveTitle = function()
          local fn = _G.GetActiveTitle
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetAddOnDependencies = function()
          local fn = _G.GetAddOnDependencies
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetAddOnEnableState = function()
          local fn = _G.GetAddOnEnableState
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetAddOnInfo = function()
          local fn = _G.GetAddOnInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetAddOnMemoryUsage = function()
          local fn = _G.GetAddOnMemoryUsage
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetAddOnMetadata = function()
          local fn = _G.GetAddOnMetadata
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetAddOnOptionalDependencies = function()
          local fn = _G.GetAddOnOptionalDependencies
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetAlternativeDefaultLanguage = function()
          local fn = _G.GetAlternativeDefaultLanguage
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetArchaeologyInfo = function()
          local fn = _G.GetArchaeologyInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetArchaeologyRaceInfo = function()
          local fn = _G.GetArchaeologyRaceInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetAreaSpiritHealerTime = function()
          local fn = _G.GetAreaSpiritHealerTime
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetAreaText = function()
          local fn = _G.GetAreaText
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetArenaOpponentSpec = function()
          local fn = _G.GetArenaOpponentSpec
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetArenaTeam = function()
          local fn = _G.GetArenaTeam
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetArmorPenetration = function()
          local fn = _G.GetArmorPenetration
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetAttackPowerForStat = function()
          local fn = _G.GetAttackPowerForStat
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetAuctionDeposit = function()
          local fn = _G.GetAuctionDeposit
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetAuctionItemInfo = function()
          local fn = _G.GetAuctionItemInfo
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetAuctionItemLink = function()
          local fn = _G.GetAuctionItemLink
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetAuctionItemSubClasses = function()
          local fn = _G.GetAuctionItemSubClasses
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetAuctionItemTimeLeft = function()
          local fn = _G.GetAuctionItemTimeLeft
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetAuctionSellItemInfo = function()
          local fn = _G.GetAuctionSellItemInfo
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetAuctionSort = function()
          local fn = _G.GetAuctionSort
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetAutoCompleteRealms = function()
          local fn = _G.GetAutoCompleteRealms
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetAutoDeclineGuildInvites = function()
          local fn = _G.GetAutoDeclineGuildInvites
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetAvailableBandwidth = function()
          local fn = _G.GetAvailableBandwidth
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetAvailableLocaleInfo = function()
          local fn = _G.GetAvailableLocaleInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetAvailableLocales = function()
          local fn = _G.GetAvailableLocales
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetAvailableQuestInfo = function()
          local fn = _G.GetAvailableQuestInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetAvailableTitle = function()
          local fn = _G.GetAvailableTitle
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetAverageItemLevel = function()
          local fn = _G.GetAverageItemLevel
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetAvoidance = function()
          local fn = _G.GetAvoidance
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetBagName = function()
          local fn = _G.GetBagName
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetBagSlotFlag = function()
          local fn = _G.GetBagSlotFlag
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetBankBagSlotFlag = function()
          local fn = _G.GetBankBagSlotFlag
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetBankSlotCost = function()
          local fn = _G.GetBankSlotCost
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetBattlefieldArenaFaction = function()
          local fn = _G.GetBattlefieldArenaFaction
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetBattlefieldFlagPosition = function()
          local fn = _G.GetBattlefieldFlagPosition
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetBattlefieldInstanceInfo = function()
          local fn = _G.GetBattlefieldInstanceInfo
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetBattlefieldStatus = function()
          local fn = _G.GetBattlefieldStatus
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetBattlegroundInfo = function()
          local fn = _G.GetBattlegroundInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetBestRFChoice = function()
          local fn = _G.GetBestRFChoice
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetBidderAuctionItems = function()
          local fn = _G.GetBidderAuctionItems
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetBinding = function()
          local fn = _G.GetBinding
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetBindingKey = function()
          local fn = _G.GetBindingKey
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetBindingText = function()
          local fn = _G.GetBindingText
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetBuybackItemInfo = function()
          local fn = _G.GetBuybackItemInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetBuybackItemLink = function()
          local fn = _G.GetBuybackItemLink
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCVarInfo = function()
          local fn = _G.GetCVarInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCVarSettingValidity = function()
          local fn = _G.GetCVarSettingValidity
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCategoryAchievementPoints = function()
          local fn = _G.GetCategoryAchievementPoints
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCategoryInfo = function()
          local fn = _G.GetCategoryInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCategoryList = function()
          local fn = _G.GetCategoryList
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetChannelDisplayInfo = function()
          local fn = _G.GetChannelDisplayInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetChannelList = function()
          local fn = _G.GetChannelList
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetChatTypeIndex = function()
          local fn = _G.GetChatTypeIndex
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetChatWindowChannels = function()
          local fn = _G.GetChatWindowChannels
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetChatWindowInfo = function()
          local fn = _G.GetChatWindowInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetChatWindowMessages = function()
          local fn = _G.GetChatWindowMessages
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetChatWindowSavedDimensions = function()
          local fn = _G.GetChatWindowSavedDimensions
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetChatWindowSavedPosition = function()
          local fn = _G.GetChatWindowSavedPosition
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetClassInfo = function()
          local fn = _G.GetClassInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetClassicExpansionLevel = function()
          local fn = _G.GetClassicExpansionLevel
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetClickFrame = function()
          local fn = _G.GetClickFrame
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetClientDisplayExpansionLevel = function()
          local fn = _G.GetClientDisplayExpansionLevel
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCoinText = function()
          local fn = _G.GetCoinText
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCoinTextureString = function()
          local fn = _G.GetCoinTextureString
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCombatRating = function()
          local fn = _G.GetCombatRating
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCombatRatingBonus = function()
          local fn = _G.GetCombatRatingBonus
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetComboPoints = function()
          local fn = _G.GetComboPoints
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetContainerItemCooldown = function()
          local fn = _G.GetContainerItemCooldown
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetContainerItemInfo = function()
          local fn = _G.GetContainerItemInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetContainerItemLink = function()
          local fn = _G.GetContainerItemLink
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetContainerItemQuestInfo = function()
          local fn = _G.GetContainerItemQuestInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetContainerNumFreeSlots = function()
          local fn = _G.GetContainerNumFreeSlots
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetContainerNumSlots = function()
          local fn = _G.GetContainerNumSlots
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCorruption = function()
          local fn = _G.GetCorruption
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCraftButtonToken = function()
          local fn = _G.GetCraftButtonToken
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCraftCooldown = function()
          local fn = _G.GetCraftCooldown
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCraftDescription = function()
          local fn = _G.GetCraftDescription
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCraftDisplaySkillLine = function()
          local fn = _G.GetCraftDisplaySkillLine
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCraftFilter = function()
          local fn = _G.GetCraftFilter
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCraftIcon = function()
          local fn = _G.GetCraftIcon
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCraftInfo = function()
          local fn = _G.GetCraftInfo
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCraftName = function()
          local fn = _G.GetCraftName
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCraftNumMade = function()
          local fn = _G.GetCraftNumMade
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCraftNumReagents = function()
          local fn = _G.GetCraftNumReagents
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCraftReagentInfo = function()
          local fn = _G.GetCraftReagentInfo
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCraftSelectionIndex = function()
          local fn = _G.GetCraftSelectionIndex
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCraftSlots = function()
          local fn = _G.GetCraftSlots
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCraftSpellFocus = function()
          local fn = _G.GetCraftSpellFocus
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCritChance = function()
          local fn = _G.GetCritChance
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCritChanceFromAgility = function()
          local fn = _G.GetCritChanceFromAgility
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCritChanceProvidesParryEffect = function()
          local fn = _G.GetCritChanceProvidesParryEffect
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCurrentArenaSeason = function()
          local fn = _G.GetCurrentArenaSeason
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCurrentBindingSet = function()
          local fn = _G.GetCurrentBindingSet
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCurrentGuildBankTab = function()
          local fn = _G.GetCurrentGuildBankTab
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCurrentRegion = function()
          local fn = _G.GetCurrentRegion
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCurrentRegionName = function()
          local fn = _G.GetCurrentRegionName
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCurrentResolution = function()
          local fn = _G.GetCurrentResolution
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCurrentScaledResolution = function()
          local fn = _G.GetCurrentScaledResolution
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCurrentTitle = function()
          local fn = _G.GetCurrentTitle
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCursorInfo = function()
          local fn = _G.GetCursorInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCursorMoney = function()
          local fn = _G.GetCursorMoney
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetCursorPosition = function()
          local fn = _G.GetCursorPosition
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetDailyQuestsCompleted = function()
          local fn = _G.GetDailyQuestsCompleted
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetDefaultLanguage = function()
          local fn = _G.GetDefaultLanguage
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetDefaultScale = function()
          local fn = _G.GetDefaultScale
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetDefaultVideoOptions = function()
          local fn = _G.GetDefaultVideoOptions
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetDifficultyInfo = function()
          local fn = _G.GetDifficultyInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetDownloadedPercentage = function()
          local fn = _G.GetDownloadedPercentage
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetDungeonDifficultyID = function()
          local fn = _G.GetDungeonDifficultyID
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetExistingSocketInfo = function()
          local fn = _G.GetExistingSocketInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetExpansionDisplayInfo = function()
          local fn = _G.GetExpansionDisplayInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetExpansionForLevel = function()
          local fn = _G.GetExpansionForLevel
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetExpansionLevel = function()
          local fn = _G.GetExpansionLevel
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetExpansionTrialInfo = function()
          local fn = _G.GetExpansionTrialInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetExpertise = function()
          local fn = _G.GetExpertise
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetExpertisePercent = function()
          local fn = _G.GetExpertisePercent
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetExtraBarIndex = function()
          local fn = _G.GetExtraBarIndex
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetFactionInfo = function()
          local fn = _G.GetFactionInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetFactionInfoByID = function()
          local fn = _G.GetFactionInfoByID
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetFileStreamingStatus = function()
          local fn = _G.GetFileStreamingStatus
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetFirstTradeSkill = function()
          local fn = _G.GetFirstTradeSkill
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetFramerate = function()
          local fn = _G.GetFramerate
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetFriendshipReputation = function()
          local fn = _G.GetFriendshipReputation
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetFriendshipReputationRanks = function()
          local fn = _G.GetFriendshipReputationRanks
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetGMStatus = function()
          local fn = _G.GetGMStatus
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetGMTicket = function()
          local fn = _G.GetGMTicket
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetGameTime = function()
          local fn = _G.GetGameTime
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetGossipActiveQuests = function()
          local fn = _G.GetGossipActiveQuests
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetGossipAvailableQuests = function()
          local fn = _G.GetGossipAvailableQuests
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetGossipOptions = function()
          local fn = _G.GetGossipOptions
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetGossipText = function()
          local fn = _G.GetGossipText
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetGreetingText = function()
          local fn = _G.GetGreetingText
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetGroupMemberCounts = function()
          local fn = _G.GetGroupMemberCounts
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetGuildBankItemInfo = function()
          local fn = _G.GetGuildBankItemInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetGuildBankItemLink = function()
          local fn = _G.GetGuildBankItemLink
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetGuildBankMoney = function()
          local fn = _G.GetGuildBankMoney
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetGuildBankMoneyTransaction = function()
          local fn = _G.GetGuildBankMoneyTransaction
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetGuildBankTabInfo = function()
          local fn = _G.GetGuildBankTabInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetGuildBankText = function()
          local fn = _G.GetGuildBankText
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetGuildBankWithdrawMoney = function()
          local fn = _G.GetGuildBankWithdrawMoney
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetGuildChallengeInfo = function()
          local fn = _G.GetGuildChallengeInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetGuildEventInfo = function()
          local fn = _G.GetGuildEventInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetGuildFactionGroup = function()
          local fn = _G.GetGuildFactionGroup
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetGuildFactionInfo = function()
          local fn = _G.GetGuildFactionInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetGuildInfo = function()
          local fn = _G.GetGuildInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetGuildInfoText = function()
          local fn = _G.GetGuildInfoText
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetGuildLogoInfo = function()
          local fn = _G.GetGuildLogoInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetGuildPerkInfo = function()
          local fn = _G.GetGuildPerkInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetGuildRenameRequired = function()
          local fn = _G.GetGuildRenameRequired
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetGuildRewardInfo = function()
          local fn = _G.GetGuildRewardInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetGuildRosterInfo = function()
          local fn = _G.GetGuildRosterInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetGuildRosterMOTD = function()
          local fn = _G.GetGuildRosterMOTD
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetGuildRosterSelection = function()
          local fn = _G.GetGuildRosterSelection
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetGuildRosterShowOffline = function()
          local fn = _G.GetGuildRosterShowOffline
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetGuildTabardFiles = function()
          local fn = _G.GetGuildTabardFiles
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetHaste = function()
          local fn = _G.GetHaste
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetInboxHeaderInfo = function()
          local fn = _G.GetInboxHeaderInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetInboxItemLink = function()
          local fn = _G.GetInboxItemLink
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetInboxNumItems = function()
          local fn = _G.GetInboxNumItems
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetInspectArenaTeamData = function()
          local fn = _G.GetInspectArenaTeamData
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetInspectHonorData = function()
          local fn = _G.GetInspectHonorData
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetInspectPVPRankProgress = function()
          local fn = _G.GetInspectPVPRankProgress
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetInstanceInfo = function()
          local fn = _G.GetInstanceInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetInstanceLockTimeRemaining = function()
          local fn = _G.GetInstanceLockTimeRemaining
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetInventoryAlertStatus = function()
          local fn = _G.GetInventoryAlertStatus
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetInventoryItemCooldown = function()
          local fn = _G.GetInventoryItemCooldown
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetInventoryItemCount = function()
          local fn = _G.GetInventoryItemCount
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetInventoryItemDurability = function()
          local fn = _G.GetInventoryItemDurability
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetInventoryItemID = function()
          local fn = _G.GetInventoryItemID
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetInventoryItemLink = function()
          local fn = _G.GetInventoryItemLink
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetInventoryItemQuality = function()
          local fn = _G.GetInventoryItemQuality
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetInventoryItemTexture = function()
          local fn = _G.GetInventoryItemTexture
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetInventorySlotInfo = function()
          local fn = _G.GetInventorySlotInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetItemClassInfo = function()
          local fn = _G.GetItemClassInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetItemCooldown = function()
          local fn = _G.GetItemCooldown
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetItemCount = function()
          local fn = _G.GetItemCount
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetItemIcon = function()
          local fn = _G.GetItemIcon
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetItemInfo = function()
          local fn = _G.GetItemInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetItemInfoInstant = function()
          local fn = _G.GetItemInfoInstant
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetItemInventorySlotInfo = function()
          local fn = _G.GetItemInventorySlotInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetItemQualityColor = function()
          local fn = _G.GetItemQualityColor
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetItemSubClassInfo = function()
          local fn = _G.GetItemSubClassInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetLFDChoiceCollapseState = function()
          local fn = _G.GetLFDChoiceCollapseState
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetLFDLockInfo = function()
          local fn = _G.GetLFDLockInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetLFDLockPlayerCount = function()
          local fn = _G.GetLFDLockPlayerCount
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetLFDRoleRestrictions = function()
          local fn = _G.GetLFDRoleRestrictions
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetLFGBootProposal = function()
          local fn = _G.GetLFGBootProposal
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetLFGCategoryForID = function()
          local fn = _G.GetLFGCategoryForID
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetLFGCompletionReward = function()
          local fn = _G.GetLFGCompletionReward
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetLFGCompletionRewardItem = function()
          local fn = _G.GetLFGCompletionRewardItem
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetLFGCompletionRewardItemLink = function()
          local fn = _G.GetLFGCompletionRewardItemLink
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetLFGDeserterExpiration = function()
          local fn = _G.GetLFGDeserterExpiration
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetLFGDungeonInfo = function()
          local fn = _G.GetLFGDungeonInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetLFGDungeonNumEncounters = function()
          local fn = _G.GetLFGDungeonNumEncounters
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetLFGDungeonRewardCapInfo = function()
          local fn = _G.GetLFGDungeonRewardCapInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetLFGDungeonRewardInfo = function()
          local fn = _G.GetLFGDungeonRewardInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetLFGDungeonRewards = function()
          local fn = _G.GetLFGDungeonRewards
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetLFGInfoServer = function()
          local fn = _G.GetLFGInfoServer
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetLFGProposal = function()
          local fn = _G.GetLFGProposal
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetLFGQueuedList = function()
          local fn = _G.GetLFGQueuedList
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetLFGRandomDungeonInfo = function()
          local fn = _G.GetLFGRandomDungeonInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetLFGReadyCheckUpdate = function()
          local fn = _G.GetLFGReadyCheckUpdate
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetLFGRoleShortageRewards = function()
          local fn = _G.GetLFGRoleShortageRewards
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetLFGRoleUpdate = function()
          local fn = _G.GetLFGRoleUpdate
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetLFGRoles = function()
          local fn = _G.GetLFGRoles
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetLanguageByIndex = function()
          local fn = _G.GetLanguageByIndex
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetLegacyRaidDifficultyID = function()
          local fn = _G.GetLegacyRaidDifficultyID
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetLifesteal = function()
          local fn = _G.GetLifesteal
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetLocale = function()
          local fn = _G.GetLocale
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetLooseMacroIcons = function()
          local fn = _G.GetLooseMacroIcons
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetLootMethod = function()
          local fn = _G.GetLootMethod
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetLootSlotInfo = function()
          local fn = _G.GetLootSlotInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetLootSpecialization = function()
          local fn = _G.GetLootSpecialization
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetLootThreshold = function()
          local fn = _G.GetLootThreshold
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetMacroIcons = function()
          local fn = _G.GetMacroIcons
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetMacroIndexByName = function()
          local fn = _G.GetMacroIndexByName
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetMacroInfo = function()
          local fn = _G.GetMacroInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetMasterLootCandidate = function()
          local fn = _G.GetMasterLootCandidate
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetMasteryEffect = function()
          local fn = _G.GetMasteryEffect
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetMaxBattlefieldID = function()
          local fn = _G.GetMaxBattlefieldID
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetMaxDailyQuests = function()
          local fn = _G.GetMaxDailyQuests
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetMaxLevelForExpansionLevel = function()
          local fn = _G.GetMaxLevelForExpansionLevel
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetMaxLevelForLatestExpansion = function()
          local fn = _G.GetMaxLevelForLatestExpansion
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetMaxLevelForPlayerExpansion = function()
          local fn = _G.GetMaxLevelForPlayerExpansion
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetMaxPlayerLevel = function()
          local fn = _G.GetMaxPlayerLevel
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetMaxRenderScale = function()
          local fn = _G.GetMaxRenderScale
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetMaximumExpansionLevel = function()
          local fn = _G.GetMaximumExpansionLevel
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetMerchantCurrencies = function()
          local fn = _G.GetMerchantCurrencies
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetMerchantFilter = function()
          local fn = _G.GetMerchantFilter
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetMerchantItemID = function()
          local fn = _G.GetMerchantItemID
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetMerchantItemInfo = function()
          local fn = _G.GetMerchantItemInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetMerchantItemLink = function()
          local fn = _G.GetMerchantItemLink
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetMerchantNumItems = function()
          local fn = _G.GetMerchantNumItems
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetMinRenderScale = function()
          local fn = _G.GetMinRenderScale
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetMinimapZoneText = function()
          local fn = _G.GetMinimapZoneText
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetMinimumExpansionLevel = function()
          local fn = _G.GetMinimumExpansionLevel
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetMirrorTimerInfo = function()
          local fn = _G.GetMirrorTimerInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetModifiedClick = function()
          local fn = _G.GetModifiedClick
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetMoney = function()
          local fn = _G.GetMoney
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetMouseFocus = function()
          local fn = _G.GetMouseFocus
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetMultiCastBarIndex = function()
          local fn = _G.GetMultiCastBarIndex
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNegativeCorruptionEffectInfo = function()
          local fn = _G.GetNegativeCorruptionEffectInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNetStats = function()
          local fn = _G.GetNetStats
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNewSocketInfo = function()
          local fn = _G.GetNewSocketInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNextPendingInviteConfirmation = function()
          local fn = _G.GetNextPendingInviteConfirmation
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNormalizedRealmName = function()
          local fn = _G.GetNormalizedRealmName
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumActiveQuests = function()
          local fn = _G.GetNumActiveQuests
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumAddOns = function()
          local fn = _G.GetNumAddOns
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumArchaeologyRaces = function()
          local fn = _G.GetNumArchaeologyRaces
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumArenaOpponentSpecs = function()
          local fn = _G.GetNumArenaOpponentSpecs
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumArenaOpponents = function()
          local fn = _G.GetNumArenaOpponents
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumArtifactsByRace = function()
          local fn = _G.GetNumArtifactsByRace
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumAuctionItems = function()
          local fn = _G.GetNumAuctionItems
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumAvailableQuests = function()
          local fn = _G.GetNumAvailableQuests
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumBankSlots = function()
          local fn = _G.GetNumBankSlots
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumBattlefieldFlagPositions = function()
          local fn = _G.GetNumBattlefieldFlagPositions
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumBattlefieldScores = function()
          local fn = _G.GetNumBattlefieldScores
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumBattlefields = function()
          local fn = _G.GetNumBattlefields
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumBattlegroundTypes = function()
          local fn = _G.GetNumBattlegroundTypes
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumBindings = function()
          local fn = _G.GetNumBindings
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumBuybackItems = function()
          local fn = _G.GetNumBuybackItems
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumClasses = function()
          local fn = _G.GetNumClasses
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumCompletedAchievements = function()
          local fn = _G.GetNumCompletedAchievements
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumCrafts = function()
          local fn = _G.GetNumCrafts
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumDisplayChannels = function()
          local fn = _G.GetNumDisplayChannels
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumExpansions = function()
          local fn = _G.GetNumExpansions
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumFactions = function()
          local fn = _G.GetNumFactions
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumGossipAvailableQuests = function()
          local fn = _G.GetNumGossipAvailableQuests
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumGroupMembers = function()
          local fn = _G.GetNumGroupMembers
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumGuildBankMoneyTransactions = function()
          local fn = _G.GetNumGuildBankMoneyTransactions
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumGuildBankTabs = function()
          local fn = _G.GetNumGuildBankTabs
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumGuildChallenges = function()
          local fn = _G.GetNumGuildChallenges
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumGuildEvents = function()
          local fn = _G.GetNumGuildEvents
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumGuildMembers = function()
          local fn = _G.GetNumGuildMembers
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumGuildNews = function()
          local fn = _G.GetNumGuildNews
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumGuildPerks = function()
          local fn = _G.GetNumGuildPerks
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumGuildRewards = function()
          local fn = _G.GetNumGuildRewards
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumLanguages = function()
          local fn = _G.GetNumLanguages
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumLootItems = function()
          local fn = _G.GetNumLootItems
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumMacros = function()
          local fn = _G.GetNumMacros
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumPetitionNames = function()
          local fn = _G.GetNumPetitionNames
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumQuestChoices = function()
          local fn = _G.GetNumQuestChoices
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumQuestCurrencies = function()
          local fn = _G.GetNumQuestCurrencies
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumQuestItems = function()
          local fn = _G.GetNumQuestItems
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumQuestLeaderBoards = function()
          local fn = _G.GetNumQuestLeaderBoards
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumQuestLogChoices = function()
          local fn = _G.GetNumQuestLogChoices
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumQuestLogEntries = function()
          local fn = _G.GetNumQuestLogEntries
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumQuestLogRewardSpells = function()
          local fn = _G.GetNumQuestLogRewardSpells
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumQuestLogRewards = function()
          local fn = _G.GetNumQuestLogRewards
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumQuestRewards = function()
          local fn = _G.GetNumQuestRewards
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumQuestWatches = function()
          local fn = _G.GetNumQuestWatches
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumRFDungeons = function()
          local fn = _G.GetNumRFDungeons
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumRandomDungeons = function()
          local fn = _G.GetNumRandomDungeons
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumRewardCurrencies = function()
          local fn = _G.GetNumRewardCurrencies
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumRewardSpells = function()
          local fn = _G.GetNumRewardSpells
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumSavedInstances = function()
          local fn = _G.GetNumSavedInstances
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumSavedWorldBosses = function()
          local fn = _G.GetNumSavedWorldBosses
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumShapeshiftForms = function()
          local fn = _G.GetNumShapeshiftForms
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumSkillLines = function()
          local fn = _G.GetNumSkillLines
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumSockets = function()
          local fn = _G.GetNumSockets
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumSpecGroups = function()
          local fn = _G.GetNumSpecGroups
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumSpecializations = function()
          local fn = _G.GetNumSpecializations
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumSpecializationsForClassID = function()
          local fn = _G.GetNumSpecializationsForClassID
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumSpellTabs = function()
          local fn = _G.GetNumSpellTabs
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumSubgroupMembers = function()
          local fn = _G.GetNumSubgroupMembers
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumTalentTabs = function()
          local fn = _G.GetNumTalentTabs
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumTalents = function()
          local fn = _G.GetNumTalents
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumTitles = function()
          local fn = _G.GetNumTitles
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumTrackingTypes = function()
          local fn = _G.GetNumTrackingTypes
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumTradeSkills = function()
          local fn = _G.GetNumTradeSkills
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumTrainerServices = function()
          local fn = _G.GetNumTrainerServices
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumVoidTransferDeposit = function()
          local fn = _G.GetNumVoidTransferDeposit
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetNumVoidTransferWithdrawal = function()
          local fn = _G.GetNumVoidTransferWithdrawal
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetOptOutOfLoot = function()
          local fn = _G.GetOptOutOfLoot
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetOverrideBarIndex = function()
          local fn = _G.GetOverrideBarIndex
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetOwnerAuctionItems = function()
          local fn = _G.GetOwnerAuctionItems
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetPVPLastWeekStats = function()
          local fn = _G.GetPVPLastWeekStats
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetPVPLifetimeStats = function()
          local fn = _G.GetPVPLifetimeStats
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetPVPRankInfo = function()
          local fn = _G.GetPVPRankInfo
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetPVPRankProgress = function()
          local fn = _G.GetPVPRankProgress
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetPVPRoles = function()
          local fn = _G.GetPVPRoles
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetPVPSessionStats = function()
          local fn = _G.GetPVPSessionStats
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetPVPThisWeekStats = function()
          local fn = _G.GetPVPThisWeekStats
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetPVPYesterdayStats = function()
          local fn = _G.GetPVPYesterdayStats
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetPartyLFGID = function()
          local fn = _G.GetPartyLFGID
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetPetActionCooldown = function()
          local fn = _G.GetPetActionCooldown
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetPetActionInfo = function()
          local fn = _G.GetPetActionInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetPetExperience = function()
          local fn = _G.GetPetExperience
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetPetHappiness = function()
          local fn = _G.GetPetHappiness
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetPetTrainingPoints = function()
          local fn = _G.GetPetTrainingPoints
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetPetitionInfo = function()
          local fn = _G.GetPetitionInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetPetitionNameInfo = function()
          local fn = _G.GetPetitionNameInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetPhysicalScreenSize = function()
          local fn = _G.GetPhysicalScreenSize
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetPlayerInfoByGUID = function()
          local fn = _G.GetPlayerInfoByGUID
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetPlayerTradeMoney = function()
          local fn = _G.GetPlayerTradeMoney
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetProfessions = function()
          local fn = _G.GetProfessions
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetProgressText = function()
          local fn = _G.GetProgressText
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetQuestBackgroundMaterial = function()
          local fn = _G.GetQuestBackgroundMaterial
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetQuestCurrencyInfo = function()
          local fn = _G.GetQuestCurrencyInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetQuestGreenRange = function()
          local fn = _G.GetQuestGreenRange
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetQuestID = function()
          local fn = _G.GetQuestID
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetQuestIndexForWatch = function()
          local fn = _G.GetQuestIndexForWatch
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetQuestItemInfo = function()
          local fn = _G.GetQuestItemInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetQuestItemInfoLootType = function()
          local fn = _G.GetQuestItemInfoLootType
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetQuestItemLink = function()
          local fn = _G.GetQuestItemLink
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetQuestLogChoiceInfo = function()
          local fn = _G.GetQuestLogChoiceInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetQuestLogGroupNum = function()
          local fn = _G.GetQuestLogGroupNum
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetQuestLogIndexByID = function()
          local fn = _G.GetQuestLogIndexByID
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetQuestLogLeaderBoard = function()
          local fn = _G.GetQuestLogLeaderBoard
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetQuestLogPushable = function()
          local fn = _G.GetQuestLogPushable
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetQuestLogQuestText = function()
          local fn = _G.GetQuestLogQuestText
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetQuestLogRequiredMoney = function()
          local fn = _G.GetQuestLogRequiredMoney
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetQuestLogRewardHonor = function()
          local fn = _G.GetQuestLogRewardHonor
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetQuestLogRewardInfo = function()
          local fn = _G.GetQuestLogRewardInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetQuestLogRewardMoney = function()
          local fn = _G.GetQuestLogRewardMoney
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetQuestLogRewardSpell = function()
          local fn = _G.GetQuestLogRewardSpell
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetQuestLogRewardTitle = function()
          local fn = _G.GetQuestLogRewardTitle
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetQuestLogSelection = function()
          local fn = _G.GetQuestLogSelection
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetQuestLogTimeLeft = function()
          local fn = _G.GetQuestLogTimeLeft
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetQuestLogTitle = function()
          local fn = _G.GetQuestLogTitle
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetQuestMoneyToGet = function()
          local fn = _G.GetQuestMoneyToGet
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetQuestPOIs = function()
          local fn = _G.GetQuestPOIs
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetQuestPortraitTurnIn = function()
          local fn = _G.GetQuestPortraitTurnIn
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetQuestTimers = function()
          local fn = _G.GetQuestTimers
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetQuestsCompleted = function()
          local fn = _G.GetQuestsCompleted
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetRFDungeonInfo = function()
          local fn = _G.GetRFDungeonInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetRaidDifficultyID = function()
          local fn = _G.GetRaidDifficultyID
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetRaidRosterInfo = function()
          local fn = _G.GetRaidRosterInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetRaidTargetIndex = function()
          local fn = _G.GetRaidTargetIndex
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetRandomDungeonBestChoice = function()
          local fn = _G.GetRandomDungeonBestChoice
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetRangedCritChance = function()
          local fn = _G.GetRangedCritChance
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetReadyCheckStatus = function()
          local fn = _G.GetReadyCheckStatus
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetRealZoneText = function()
          local fn = _G.GetRealZoneText
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetRealmID = function()
          local fn = _G.GetRealmID
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetRealmName = function()
          local fn = _G.GetRealmName
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetReleaseTimeRemaining = function()
          local fn = _G.GetReleaseTimeRemaining
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetRepairAllCost = function()
          local fn = _G.GetRepairAllCost
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetResSicknessDuration = function()
          local fn = _G.GetResSicknessDuration
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetRestState = function()
          local fn = _G.GetRestState
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetRestrictedAccountData = function()
          local fn = _G.GetRestrictedAccountData
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetRewardArtifactXP = function()
          local fn = _G.GetRewardArtifactXP
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetRewardHonor = function()
          local fn = _G.GetRewardHonor
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetRewardMoney = function()
          local fn = _G.GetRewardMoney
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetRewardSkillPoints = function()
          local fn = _G.GetRewardSkillPoints
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetRewardSpell = function()
          local fn = _G.GetRewardSpell
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetRewardText = function()
          local fn = _G.GetRewardText
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetRewardTitle = function()
          local fn = _G.GetRewardTitle
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetRewardXP = function()
          local fn = _G.GetRewardXP
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSavedInstanceChatLink = function()
          local fn = _G.GetSavedInstanceChatLink
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSavedInstanceInfo = function()
          local fn = _G.GetSavedInstanceInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSchoolString = function()
          local fn = _G.GetSchoolString
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetScreenHeight = function()
          local fn = _G.GetScreenHeight
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetScreenResolutions = function()
          local fn = _G.GetScreenResolutions
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetScreenWidth = function()
          local fn = _G.GetScreenWidth
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSelectedAuctionItem = function()
          local fn = _G.GetSelectedAuctionItem
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSelectedBattlefield = function()
          local fn = _G.GetSelectedBattlefield
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSelectedFaction = function()
          local fn = _G.GetSelectedFaction
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSelectedSkill = function()
          local fn = _G.GetSelectedSkill
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSendMailPrice = function()
          local fn = _G.GetSendMailPrice
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetServerExpansionLevel = function()
          local fn = _G.GetServerExpansionLevel
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetServerTime = function()
          local fn = _G.GetServerTime
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetShapeshiftForm = function()
          local fn = _G.GetShapeshiftForm
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetShapeshiftFormCooldown = function()
          local fn = _G.GetShapeshiftFormCooldown
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetShapeshiftFormID = function()
          local fn = _G.GetShapeshiftFormID
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetShapeshiftFormInfo = function()
          local fn = _G.GetShapeshiftFormInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSkillLineInfo = function()
          local fn = _G.GetSkillLineInfo
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSocketItemBoundTradeable = function()
          local fn = _G.GetSocketItemBoundTradeable
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSocketItemInfo = function()
          local fn = _G.GetSocketItemInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSocketItemRefundable = function()
          local fn = _G.GetSocketItemRefundable
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSocketTypes = function()
          local fn = _G.GetSocketTypes
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSpecialization = function()
          local fn = _G.GetSpecialization
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSpecializationInfo = function()
          local fn = _G.GetSpecializationInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSpecializationInfoByID = function()
          local fn = _G.GetSpecializationInfoByID
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSpecializationInfoForClassID = function()
          local fn = _G.GetSpecializationInfoForClassID
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSpecializationNameForSpecID = function()
          local fn = _G.GetSpecializationNameForSpecID
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSpecializationRole = function()
          local fn = _G.GetSpecializationRole
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSpeed = function()
          local fn = _G.GetSpeed
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSpellAutocast = function()
          local fn = _G.GetSpellAutocast
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSpellBonusHealing = function()
          local fn = _G.GetSpellBonusHealing
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSpellBookItemInfo = function()
          local fn = _G.GetSpellBookItemInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSpellBookItemName = function()
          local fn = _G.GetSpellBookItemName
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSpellBookItemTexture = function()
          local fn = _G.GetSpellBookItemTexture
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSpellConfirmationPromptsInfo = function()
          local fn = _G.GetSpellConfirmationPromptsInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSpellCooldown = function()
          local fn = _G.GetSpellCooldown
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSpellCritChance = function()
          local fn = _G.GetSpellCritChance
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSpellCritChanceFromIntellect = function()
          local fn = _G.GetSpellCritChanceFromIntellect
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSpellDescription = function()
          local fn = _G.GetSpellDescription
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSpellInfo = function()
          local fn = _G.GetSpellInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSpellSubtext = function()
          local fn = _G.GetSpellSubtext
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSpellTabInfo = function()
          local fn = _G.GetSpellTabInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSpellTexture = function()
          local fn = _G.GetSpellTexture
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetStablePetFoodTypes = function()
          local fn = _G.GetStablePetFoodTypes
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetStablePetInfo = function()
          local fn = _G.GetStablePetInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSubZoneText = function()
          local fn = _G.GetSubZoneText
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetSummonFriendCooldown = function()
          local fn = _G.GetSummonFriendCooldown
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTabardCreationCost = function()
          local fn = _G.GetTabardCreationCost
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTalentInfo = function()
          local fn = _G.GetTalentInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTalentInfoBySpecialization = function()
          local fn = _G.GetTalentInfoBySpecialization
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTalentTabInfo = function()
          local fn = _G.GetTalentTabInfo
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTargetTradeMoney = function()
          local fn = _G.GetTargetTradeMoney
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetText = function()
          local fn = _G.GetText
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTime = function()
          local fn = _G.GetTime
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTitleName = function()
          local fn = _G.GetTitleName
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTitleText = function()
          local fn = _G.GetTitleText
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTotalAchievementPoints = function()
          local fn = _G.GetTotalAchievementPoints
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTotemInfo = function()
          local fn = _G.GetTotemInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTrackedAchievements = function()
          local fn = _G.GetTrackedAchievements
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTrackingInfo = function()
          local fn = _G.GetTrackingInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTrackingTexture = function()
          local fn = _G.GetTrackingTexture
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTradePlayerItemInfo = function()
          local fn = _G.GetTradePlayerItemInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTradePlayerItemLink = function()
          local fn = _G.GetTradePlayerItemLink
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTradeSkillCooldown = function()
          local fn = _G.GetTradeSkillCooldown
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTradeSkillIcon = function()
          local fn = _G.GetTradeSkillIcon
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTradeSkillInfo = function()
          local fn = _G.GetTradeSkillInfo
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTradeSkillInvSlotFilter = function()
          local fn = _G.GetTradeSkillInvSlotFilter
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTradeSkillInvSlots = function()
          local fn = _G.GetTradeSkillInvSlots
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTradeSkillLine = function()
          local fn = _G.GetTradeSkillLine
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTradeSkillNumMade = function()
          local fn = _G.GetTradeSkillNumMade
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTradeSkillNumReagents = function()
          local fn = _G.GetTradeSkillNumReagents
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTradeSkillReagentInfo = function()
          local fn = _G.GetTradeSkillReagentInfo
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTradeSkillSelectionIndex = function()
          local fn = _G.GetTradeSkillSelectionIndex
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTradeSkillSubClassFilter = function()
          local fn = _G.GetTradeSkillSubClassFilter
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTradeSkillSubClasses = function()
          local fn = _G.GetTradeSkillSubClasses
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTradeSkillTools = function()
          local fn = _G.GetTradeSkillTools
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTradeTargetItemInfo = function()
          local fn = _G.GetTradeTargetItemInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTradeTargetItemLink = function()
          local fn = _G.GetTradeTargetItemLink
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTradeskillRepeatCount = function()
          local fn = _G.GetTradeskillRepeatCount
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTrainerGreetingText = function()
          local fn = _G.GetTrainerGreetingText
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTrainerSelectionIndex = function()
          local fn = _G.GetTrainerSelectionIndex
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTrainerServiceAbilityReq = function()
          local fn = _G.GetTrainerServiceAbilityReq
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTrainerServiceCost = function()
          local fn = _G.GetTrainerServiceCost
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTrainerServiceInfo = function()
          local fn = _G.GetTrainerServiceInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTrainerServiceNumAbilityReq = function()
          local fn = _G.GetTrainerServiceNumAbilityReq
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTrainerServiceStepIndex = function()
          local fn = _G.GetTrainerServiceStepIndex
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTrainerServiceTypeFilter = function()
          local fn = _G.GetTrainerServiceTypeFilter
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTrainerTradeskillRankValues = function()
          local fn = _G.GetTrainerTradeskillRankValues
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetTutorialsEnabled = function()
          local fn = _G.GetTutorialsEnabled
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetUnitChargedPowerPoints = function()
          local fn = _G.GetUnitChargedPowerPoints
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetUnitHealthRegenRateFromSpirit = function()
          local fn = _G.GetUnitHealthRegenRateFromSpirit
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetUnitManaRegenRateFromSpirit = function()
          local fn = _G.GetUnitManaRegenRateFromSpirit
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetUnitMaxHealthModifier = function()
          local fn = _G.GetUnitMaxHealthModifier
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetUnitPowerBarInfo = function()
          local fn = _G.GetUnitPowerBarInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetUnitPowerBarInfoByID = function()
          local fn = _G.GetUnitPowerBarInfoByID
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetUnitPowerBarStrings = function()
          local fn = _G.GetUnitPowerBarStrings
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetUnitPowerBarStringsByID = function()
          local fn = _G.GetUnitPowerBarStringsByID
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetUnitPowerBarTextureInfo = function()
          local fn = _G.GetUnitPowerBarTextureInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetUnitPowerBarTextureInfoByID = function()
          local fn = _G.GetUnitPowerBarTextureInfoByID
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetUnitSpeed = function()
          local fn = _G.GetUnitSpeed
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetVehicleBarIndex = function()
          local fn = _G.GetVehicleBarIndex
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetVersatilityBonus = function()
          local fn = _G.GetVersatilityBonus
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetVoidItemInfo = function()
          local fn = _G.GetVoidItemInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetVoidTransferCost = function()
          local fn = _G.GetVoidTransferCost
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetVoidTransferDepositInfo = function()
          local fn = _G.GetVoidTransferDepositInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetVoidTransferWithdrawalInfo = function()
          local fn = _G.GetVoidTransferWithdrawalInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetVoidUnlockCost = function()
          local fn = _G.GetVoidUnlockCost
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetWatchedFactionInfo = function()
          local fn = _G.GetWatchedFactionInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetWeaponEnchantInfo = function()
          local fn = _G.GetWeaponEnchantInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetWebTicket = function()
          local fn = _G.GetWebTicket
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetWorldElapsedTimers = function()
          local fn = _G.GetWorldElapsedTimers
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetWorldPVPQueueStatus = function()
          local fn = _G.GetWorldPVPQueueStatus
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetXPExhaustion = function()
          local fn = _G.GetXPExhaustion
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetZonePVPInfo = function()
          local fn = _G.GetZonePVPInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GetZoneText = function()
          local fn = _G.GetZoneText
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GuildControlGetNumRanks = function()
          local fn = _G.GuildControlGetNumRanks
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GuildControlGetRankName = function()
          local fn = _G.GuildControlGetRankName
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GuildControlSetRank = function()
          local fn = _G.GuildControlSetRank
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GuildNewsSort = function()
          local fn = _G.GuildNewsSort
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        GuildRoster = function()
          local fn = _G.GuildRoster
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        HasAction = function()
          local fn = _G.HasAction
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        HasArtifactEquipped = function()
          local fn = _G.HasArtifactEquipped
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        HasBonusActionBar = function()
          local fn = _G.HasBonusActionBar
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        HasBoundGemProposed = function()
          local fn = _G.HasBoundGemProposed
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        HasCompletedAnyAchievement = function()
          local fn = _G.HasCompletedAnyAchievement
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        HasExtraActionBar = function()
          local fn = _G.HasExtraActionBar
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        HasFilledPetition = function()
          local fn = _G.HasFilledPetition
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        HasKey = function()
          local fn = _G.HasKey
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        HasLFGRestrictions = function()
          local fn = _G.HasLFGRestrictions
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        HasLoadedCUFProfiles = function()
          local fn = _G.HasLoadedCUFProfiles
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        HasNewMail = function()
          local fn = _G.HasNewMail
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        HasOverrideActionBar = function()
          local fn = _G.HasOverrideActionBar
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        HasPetSpells = function()
          local fn = _G.HasPetSpells
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        HasPetUI = function()
          local fn = _G.HasPetUI
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        HasSendMailItem = function()
          local fn = _G.HasSendMailItem
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        HasTempShapeshiftActionBar = function()
          local fn = _G.HasTempShapeshiftActionBar
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        HasVehicleActionBar = function()
          local fn = _G.HasVehicleActionBar
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        HaveQuestData = function()
          local fn = _G.HaveQuestData
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        HaveQuestRewardData = function()
          local fn = _G.HaveQuestRewardData
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        HonorSystemEnabled = function()
          local fn = _G.HonorSystemEnabled
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        InActiveBattlefield = function()
          local fn = _G.InActiveBattlefield
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        InCinematic = function()
          local fn = _G.InCinematic
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        InCombatLockdown = function()
          local fn = _G.InCombatLockdown
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        InRepairMode = function()
          local fn = _G.InRepairMode
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        InboxItemCanDelete = function()
          local fn = _G.InboxItemCanDelete
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        InitiateTrade = function()
          local fn = _G.InitiateTrade
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        InteractUnit = function()
          local fn = _G.InteractUnit
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsAccountSecured = function()
          local fn = _G.IsAccountSecured
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsActionInRange = function()
          local fn = _G.IsActionInRange
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsActiveBattlefieldArena = function()
          local fn = _G.IsActiveBattlefieldArena
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsActiveQuestLegendary = function()
          local fn = _G.IsActiveQuestLegendary
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsActiveQuestTrivial = function()
          local fn = _G.IsActiveQuestTrivial
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsAddOnLoadOnDemand = function()
          local fn = _G.IsAddOnLoadOnDemand
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsAddOnLoaded = function()
          local fn = _G.IsAddOnLoaded
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsAddonVersionCheckEnabled = function()
          local fn = _G.IsAddonVersionCheckEnabled
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsAltKeyDown = function()
          local fn = _G.IsAltKeyDown
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsArtifactRelicItem = function()
          local fn = _G.IsArtifactRelicItem
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsAttackAction = function()
          local fn = _G.IsAttackAction
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsAutoRepeatAction = function()
          local fn = _G.IsAutoRepeatAction
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsAutoRepeatSpell = function()
          local fn = _G.IsAutoRepeatSpell
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsBattlePayItem = function()
          local fn = _G.IsBattlePayItem
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsBattlefieldArena = function()
          local fn = _G.IsBattlefieldArena
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsCemeterySelectionAvailable = function()
          local fn = _G.IsCemeterySelectionAvailable
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsCharacterNewlyBoosted = function()
          local fn = _G.IsCharacterNewlyBoosted
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsConsumableAction = function()
          local fn = _G.IsConsumableAction
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsConsumableItem = function()
          local fn = _G.IsConsumableItem
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsConsumableSpell = function()
          local fn = _G.IsConsumableSpell
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsContainerFiltered = function()
          local fn = _G.IsContainerFiltered
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsContainerItemAnUpgrade = function()
          local fn = _G.IsContainerItemAnUpgrade
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsControlKeyDown = function()
          local fn = _G.IsControlKeyDown
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsCorruptedItem = function()
          local fn = _G.IsCorruptedItem
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsCosmeticItem = function()
          local fn = _G.IsCosmeticItem
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsCurrentAction = function()
          local fn = _G.IsCurrentAction
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsCurrentQuestFailed = function()
          local fn = _G.IsCurrentQuestFailed
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsCurrentSpell = function()
          local fn = _G.IsCurrentSpell
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsEncounterInProgress = function()
          local fn = _G.IsEncounterInProgress
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsEncounterLimitingResurrections = function()
          local fn = _G.IsEncounterLimitingResurrections
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsEquippedAction = function()
          local fn = _G.IsEquippedAction
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsEquippedItem = function()
          local fn = _G.IsEquippedItem
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsEveryoneAssistant = function()
          local fn = _G.IsEveryoneAssistant
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsExpansionTrial = function()
          local fn = _G.IsExpansionTrial
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsFalling = function()
          local fn = _G.IsFalling
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsFishingLoot = function()
          local fn = _G.IsFishingLoot
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsGMClient = function()
          local fn = _G.IsGMClient
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsGuildLeader = function()
          local fn = _G.IsGuildLeader
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsInActiveWorldPVP = function()
          local fn = _G.IsInActiveWorldPVP
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsInGroup = function()
          local fn = _G.IsInGroup
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsInGuild = function()
          local fn = _G.IsInGuild
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsInInstance = function()
          local fn = _G.IsInInstance
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsInJailersTower = function()
          local fn = _G.IsInJailersTower
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsInRaid = function()
          local fn = _G.IsInRaid
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsInventoryItemLocked = function()
          local fn = _G.IsInventoryItemLocked
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsInventoryItemProfessionBag = function()
          local fn = _G.IsInventoryItemProfessionBag
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsItemAction = function()
          local fn = _G.IsItemAction
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsItemInRange = function()
          local fn = _G.IsItemInRange
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsLFGDungeonJoinable = function()
          local fn = _G.IsLFGDungeonJoinable
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsLoggedIn = function()
          local fn = _G.IsLoggedIn
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsMacClient = function()
          local fn = _G.IsMacClient
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsModifiedClick = function()
          local fn = _G.IsModifiedClick
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsMounted = function()
          local fn = _G.IsMounted
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsOnGlueScreen = function()
          local fn = _G.IsOnGlueScreen
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsPVPTimerRunning = function()
          local fn = _G.IsPVPTimerRunning
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsPartyLFG = function()
          local fn = _G.IsPartyLFG
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsPassiveSpell = function()
          local fn = _G.IsPassiveSpell
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsPetAttackAction = function()
          local fn = _G.IsPetAttackAction
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsPlayerInWorld = function()
          local fn = _G.IsPlayerInWorld
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsPlayerMoving = function()
          local fn = _G.IsPlayerMoving
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsPossessBarVisible = function()
          local fn = _G.IsPossessBarVisible
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsPublicBuild = function()
          local fn = _G.IsPublicBuild
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsQuestCompletable = function()
          local fn = _G.IsQuestCompletable
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsQuestItemHidden = function()
          local fn = _G.IsQuestItemHidden
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsQuestWatched = function()
          local fn = _G.IsQuestWatched
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsRaidMarkerActive = function()
          local fn = _G.IsRaidMarkerActive
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsReagentBankUnlocked = function()
          local fn = _G.IsReagentBankUnlocked
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsResting = function()
          local fn = _G.IsResting
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsRestrictedAccount = function()
          local fn = _G.IsRestrictedAccount
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsSelectedSpellBookItem = function()
          local fn = _G.IsSelectedSpellBookItem
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsShiftKeyDown = function()
          local fn = _G.IsShiftKeyDown
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsSpellInRange = function()
          local fn = _G.IsSpellInRange
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsSpellKnown = function()
          local fn = _G.IsSpellKnown
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsSpellKnownOrOverridesKnown = function()
          local fn = _G.IsSpellKnownOrOverridesKnown
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsStackableAction = function()
          local fn = _G.IsStackableAction
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsStealthed = function()
          local fn = _G.IsStealthed
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsTestBuild = function()
          local fn = _G.IsTestBuild
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsThreatWarningEnabled = function()
          local fn = _G.IsThreatWarningEnabled
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsTitleKnown = function()
          local fn = _G.IsTitleKnown
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsTradeskillTrainer = function()
          local fn = _G.IsTradeskillTrainer
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsTrialAccount = function()
          local fn = _G.IsTrialAccount
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsTutorialFlagged = function()
          local fn = _G.IsTutorialFlagged
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsUnitModelReadyForUI = function()
          local fn = _G.IsUnitModelReadyForUI
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsUnitOnQuest = function()
          local fn = _G.IsUnitOnQuest
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsUsableAction = function()
          local fn = _G.IsUsableAction
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsUsableItem = function()
          local fn = _G.IsUsableItem
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsUsableSpell = function()
          local fn = _G.IsUsableSpell
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsVeteranTrialAccount = function()
          local fn = _G.IsVeteranTrialAccount
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsVoidStorageReady = function()
          local fn = _G.IsVoidStorageReady
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        IsWindowsClient = function()
          local fn = _G.IsWindowsClient
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ItemTextGetCreator = function()
          local fn = _G.ItemTextGetCreator
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ItemTextGetItem = function()
          local fn = _G.ItemTextGetItem
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ItemTextGetMaterial = function()
          local fn = _G.ItemTextGetMaterial
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ItemTextGetPage = function()
          local fn = _G.ItemTextGetPage
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ItemTextGetText = function()
          local fn = _G.ItemTextGetText
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ItemTextHasNextPage = function()
          local fn = _G.ItemTextHasNextPage
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ItemTextIsFullPage = function()
          local fn = _G.ItemTextIsFullPage
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        JumpOrAscendStart = function()
          local fn = _G.JumpOrAscendStart
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        KeyRingButtonIDToInvSlotID = function()
          local fn = _G.KeyRingButtonIDToInvSlotID
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        LoadAddOn = function()
          local fn = _G.LoadAddOn
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        LoggingChat = function()
          local fn = _G.LoggingChat
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        LoggingCombat = function()
          local fn = _G.LoggingCombat
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        Logout = function()
          local fn = _G.Logout
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        LootSlotHasItem = function()
          local fn = _G.LootSlotHasItem
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        MoveAndSteerStart = function()
          local fn = _G.MoveAndSteerStart
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        MoveAndSteerStop = function()
          local fn = _G.MoveAndSteerStop
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        MoveBackwardStart = function()
          local fn = _G.MoveBackwardStart
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        MoveBackwardStop = function()
          local fn = _G.MoveBackwardStop
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        MoveForwardStart = function()
          local fn = _G.MoveForwardStart
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        MoveForwardStop = function()
          local fn = _G.MoveForwardStop
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        MoveViewInStart = function()
          local fn = _G.MoveViewInStart
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        MoveViewOutStart = function()
          local fn = _G.MoveViewOutStart
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        MultiSampleAntiAliasingSupported = function()
          local fn = _G.MultiSampleAntiAliasingSupported
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        NextView = function()
          local fn = _G.NextView
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        NoPlayTime = function()
          local fn = _G.NoPlayTime
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        PartialPlayTime = function()
          local fn = _G.PartialPlayTime
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        PetAttack = function()
          local fn = _G.PetAttack
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        PetHasActionBar = function()
          local fn = _G.PetHasActionBar
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        PickupContainerItem = function()
          local fn = _G.PickupContainerItem
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        PickupInventoryItem = function()
          local fn = _G.PickupInventoryItem
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        PitchDownStart = function()
          local fn = _G.PitchDownStart
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        PitchDownStop = function()
          local fn = _G.PitchDownStop
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        PitchUpStart = function()
          local fn = _G.PitchUpStart
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        PitchUpStop = function()
          local fn = _G.PitchUpStop
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        PlaySound = function()
          local fn = _G.PlaySound
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        PlayerHasToy = function()
          local fn = _G.PlayerHasToy
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        PlayerIsPVPInactive = function()
          local fn = _G.PlayerIsPVPInactive
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        PlayerVehicleHasComboPoints = function()
          local fn = _G.PlayerVehicleHasComboPoints
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        PrevView = function()
          local fn = _G.PrevView
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        PromoteToLeader = function()
          local fn = _G.PromoteToLeader
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        PutItemInBackpack = function()
          local fn = _G.PutItemInBackpack
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        PutItemInBag = function()
          local fn = _G.PutItemInBag
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        QueryGuildBankTab = function()
          local fn = _G.QueryGuildBankTab
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        QueryGuildBankText = function()
          local fn = _G.QueryGuildBankText
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        QueryGuildNews = function()
          local fn = _G.QueryGuildNews
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        QuestMapUpdateAllQuests = function()
          local fn = _G.QuestMapUpdateAllQuests
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        QuestPOIUpdateIcons = function()
          local fn = _G.QuestPOIUpdateIcons
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        Quit = function()
          local fn = _G.Quit
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        RandomRoll = function()
          local fn = _G.RandomRoll
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        RedockChatWindows = function()
          local fn = _G.RedockChatWindows
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        RegisterStaticConstants = function()
          local fn = _G.RegisterStaticConstants
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        RepopMe = function()
          local fn = _G.RepopMe
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        RequestGuildChallengeInfo = function()
          local fn = _G.RequestGuildChallengeInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        RequestGuildPartyState = function()
          local fn = _G.RequestGuildPartyState
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        RequestGuildRewards = function()
          local fn = _G.RequestGuildRewards
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        RequestLFDPartyLockInfo = function()
          local fn = _G.RequestLFDPartyLockInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        RequestLFDPlayerLockInfo = function()
          local fn = _G.RequestLFDPlayerLockInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        RequestPVPOptionsEnabled = function()
          local fn = _G.RequestPVPOptionsEnabled
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        RequestPVPRewards = function()
          local fn = _G.RequestPVPRewards
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        RequestRaidInfo = function()
          local fn = _G.RequestRaidInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        RequestRandomBattlegroundInstanceInfo = function()
          local fn = _G.RequestRandomBattlegroundInstanceInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        RequestRatedInfo = function()
          local fn = _G.RequestRatedInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        RequestTimePlayed = function()
          local fn = _G.RequestTimePlayed
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ResetAddOns = function()
          local fn = _G.ResetAddOns
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ResetCursor = function()
          local fn = _G.ResetCursor
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ResetSetMerchantFilter = function()
          local fn = _G.ResetSetMerchantFilter
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ResetView = function()
          local fn = _G.ResetView
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        RespondInstanceLock = function()
          local fn = _G.RespondInstanceLock
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ResurrectGetOfferer = function()
          local fn = _G.ResurrectGetOfferer
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        RollOnLoot = function()
          local fn = _G.RollOnLoot
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        RunMacroText = function()
          local fn = _G.RunMacroText
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        RunScript = function()
          local fn = _G.RunScript
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SaveBindings = function()
          local fn = _G.SaveBindings
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SaveView = function()
          local fn = _G.SaveView
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        Screenshot = function()
          local fn = _G.Screenshot
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ScriptsDisallowedForBeta = function()
          local fn = _G.ScriptsDisallowedForBeta
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SecureCmdOptionParse = function()
          local fn = _G.SecureCmdOptionParse
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SelectCraft = function()
          local fn = _G.SelectCraft
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SelectGossipOption = function()
          local fn = _G.SelectGossipOption
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SelectQuestLogEntry = function()
          local fn = _G.SelectQuestLogEntry
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SelectTradeSkill = function()
          local fn = _G.SelectTradeSkill
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SendChatMessage = function()
          local fn = _G.SendChatMessage
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SendSubscriptionInterstitialResponse = function()
          local fn = _G.SendSubscriptionInterstitialResponse
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SendSystemMessage = function()
          local fn = _G.SendSystemMessage
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SetActionBarToggles = function()
          local fn = _G.SetActionBarToggles
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SetActionUIButton = function()
          local fn = _G.SetActionUIButton
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SetAuctionsTabShowing = function()
          local fn = _G.SetAuctionsTabShowing
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SetBagPortraitTexture = function()
          local fn = _G.SetBagPortraitTexture
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SetBinding = function()
          local fn = _G.SetBinding
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SetBindingClick = function()
          local fn = _G.SetBindingClick
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SetChatWindowDocked = function()
          local fn = _G.SetChatWindowDocked
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SetChatWindowLocked = function()
          local fn = _G.SetChatWindowLocked
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SetChatWindowName = function()
          local fn = _G.SetChatWindowName
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SetChatWindowShown = function()
          local fn = _G.SetChatWindowShown
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SetChatWindowSize = function()
          local fn = _G.SetChatWindowSize
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SetChatWindowUninteractable = function()
          local fn = _G.SetChatWindowUninteractable
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SetConsoleKey = function()
          local fn = _G.SetConsoleKey
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SetCursor = function()
          local fn = _G.SetCursor
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SetGuildRosterSelection = function()
          local fn = _G.SetGuildRosterSelection
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SetInsertItemsLeftToRight = function()
          local fn = _G.SetInsertItemsLeftToRight
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SetItemSearch = function()
          local fn = _G.SetItemSearch
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SetModifiedClick = function()
          local fn = _G.SetModifiedClick
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SetOverrideBindingClick = function()
          local fn = _G.SetOverrideBindingClick
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SetPartyAssignment = function()
          local fn = _G.SetPartyAssignment
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SetPetStablePaperdoll = function()
          local fn = _G.SetPetStablePaperdoll
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SetPortraitTexture = function()
          local fn = _G.SetPortraitTexture
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SetPortraitTextureFromCreatureDisplayID = function()
          local fn = _G.SetPortraitTextureFromCreatureDisplayID
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SetPortraitToTexture = function()
          local fn = _G.SetPortraitToTexture
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SetRaidTarget = function()
          local fn = _G.SetRaidTarget
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SetSelectedSkill = function()
          local fn = _G.SetSelectedSkill
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SetSendMailShowing = function()
          local fn = _G.SetSendMailShowing
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SetTaxiBenchmarkMode = function()
          local fn = _G.SetTaxiBenchmarkMode
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SetTradeMoney = function()
          local fn = _G.SetTradeMoney
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SetTrainerServiceTypeFilter = function()
          local fn = _G.SetTrainerServiceTypeFilter
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SetUIVisibility = function()
          local fn = _G.SetUIVisibility
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SetView = function()
          local fn = _G.SetView
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ShouldKnowUnitHealth = function()
          local fn = _G.ShouldKnowUnitHealth
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ShowBossFrameWhenUninteractable = function()
          local fn = _G.ShowBossFrameWhenUninteractable
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SitStandOrDescendStart = function()
          local fn = _G.SitStandOrDescendStart
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SortAuctionClearSort = function()
          local fn = _G.SortAuctionClearSort
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SortAuctionSetSort = function()
          local fn = _G.SortAuctionSetSort
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SortQuestSortTypes = function()
          local fn = _G.SortQuestSortTypes
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SortQuests = function()
          local fn = _G.SortQuests
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        Sound_GameSystem_GetNumOutputDrivers = function()
          local fn = _G.Sound_GameSystem_GetNumOutputDrivers
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        Sound_GameSystem_GetOutputDriverNameByIndex = function()
          local fn = _G.Sound_GameSystem_GetOutputDriverNameByIndex
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SpellCanTargetItem = function()
          local fn = _G.SpellCanTargetItem
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SpellCanTargetItemID = function()
          local fn = _G.SpellCanTargetItemID
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SpellCanTargetQuest = function()
          local fn = _G.SpellCanTargetQuest
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SpellCancelQueuedSpell = function()
          local fn = _G.SpellCancelQueuedSpell
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SpellIsTargeting = function()
          local fn = _G.SpellIsTargeting
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SpellStopCasting = function()
          local fn = _G.SpellStopCasting
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SpellStopTargeting = function()
          local fn = _G.SpellStopTargeting
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        StartAttack = function()
          local fn = _G.StartAttack
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        StartAutoRun = function()
          local fn = _G.StartAutoRun
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        StartDuel = function()
          local fn = _G.StartDuel
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        StartWarGameByName = function()
          local fn = _G.StartWarGameByName
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        StopAttack = function()
          local fn = _G.StopAttack
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        StopAutoRun = function()
          local fn = _G.StopAutoRun
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        StopMacro = function()
          local fn = _G.StopMacro
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        StoreSecureReference = function()
          local fn = _G.StoreSecureReference
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        StrafeLeftStart = function()
          local fn = _G.StrafeLeftStart
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        StrafeLeftStop = function()
          local fn = _G.StrafeLeftStop
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        StrafeRightStart = function()
          local fn = _G.StrafeRightStart
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        StrafeRightStop = function()
          local fn = _G.StrafeRightStop
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        SupportsClipCursor = function()
          local fn = _G.SupportsClipCursor
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        TargetLastEnemy = function()
          local fn = _G.TargetLastEnemy
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        TargetLastTarget = function()
          local fn = _G.TargetLastTarget
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        TargetNearestEnemy = function()
          local fn = _G.TargetNearestEnemy
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        TargetNearestEnemyPlayer = function()
          local fn = _G.TargetNearestEnemyPlayer
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        TargetNearestFriend = function()
          local fn = _G.TargetNearestFriend
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        TargetNearestFriendPlayer = function()
          local fn = _G.TargetNearestFriendPlayer
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        TargetPriorityHighlightEnd = function()
          local fn = _G.TargetPriorityHighlightEnd
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        TargetPriorityHighlightStart = function()
          local fn = _G.TargetPriorityHighlightStart
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        TargetSpellReplacesBonusTree = function()
          local fn = _G.TargetSpellReplacesBonusTree
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        TargetUnit = function()
          local fn = _G.TargetUnit
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ToggleAnimKitDisplay = function()
          local fn = _G.ToggleAnimKitDisplay
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ToggleAutoRun = function()
          local fn = _G.ToggleAutoRun
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ToggleDebugAIDisplay = function()
          local fn = _G.ToggleDebugAIDisplay
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        TogglePVP = function()
          local fn = _G.TogglePVP
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ToggleRun = function()
          local fn = _G.ToggleRun
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ToggleSelfHighlight = function()
          local fn = _G.ToggleSelfHighlight
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ToggleSheath = function()
          local fn = _G.ToggleSheath
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ToggleWindowed = function()
          local fn = _G.ToggleWindowed
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        ToggleWorldMap = function()
          local fn = _G.ToggleWorldMap
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        TriggerTutorial = function()
          local fn = _G.TriggerTutorial
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        TurnLeftStart = function()
          local fn = _G.TurnLeftStart
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        TurnLeftStop = function()
          local fn = _G.TurnLeftStop
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        TurnOrActionStart = function()
          local fn = _G.TurnOrActionStart
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        TurnOrActionStop = function()
          local fn = _G.TurnOrActionStop
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        TurnRightStart = function()
          local fn = _G.TurnRightStart
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        TurnRightStop = function()
          local fn = _G.TurnRightStop
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitAffectingCombat = function()
          local fn = _G.UnitAffectingCombat
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitAlliedRaceInfo = function()
          local fn = _G.UnitAlliedRaceInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitArmor = function()
          local fn = _G.UnitArmor
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitAttackBothHands = function()
          local fn = _G.UnitAttackBothHands
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitAttackPower = function()
          local fn = _G.UnitAttackPower
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitAttackSpeed = function()
          local fn = _G.UnitAttackSpeed
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitAura = function()
          local fn = _G.UnitAura
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitAuraSlots = function()
          local fn = _G.UnitAuraSlots
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitBuff = function()
          local fn = _G.UnitBuff
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitCanAssist = function()
          local fn = _G.UnitCanAssist
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitCanAttack = function()
          local fn = _G.UnitCanAttack
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitCanCooperate = function()
          local fn = _G.UnitCanCooperate
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitCastingInfo = function()
          local fn = _G.UnitCastingInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitChannelInfo = function()
          local fn = _G.UnitChannelInfo
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitCharacterPoints = function()
          local fn = _G.UnitCharacterPoints
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitChromieTimeID = function()
          local fn = _G.UnitChromieTimeID
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitClass = function()
          local fn = _G.UnitClass
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitClassBase = function()
          local fn = _G.UnitClassBase
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitClassification = function()
          local fn = _G.UnitClassification
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitDamage = function()
          local fn = _G.UnitDamage
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitDebuff = function()
          local fn = _G.UnitDebuff
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitEffectiveLevel = function()
          local fn = _G.UnitEffectiveLevel
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitExists = function()
          local fn = _G.UnitExists
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitFactionGroup = function()
          local fn = _G.UnitFactionGroup
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitFullName = function()
          local fn = _G.UnitFullName
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitGUID = function()
          local fn = _G.UnitGUID
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitGetAvailableRoles = function()
          local fn = _G.UnitGetAvailableRoles
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitGetIncomingHeals = function()
          local fn = _G.UnitGetIncomingHeals
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitGetTotalAbsorbs = function()
          local fn = _G.UnitGetTotalAbsorbs
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitGetTotalHealAbsorbs = function()
          local fn = _G.UnitGetTotalHealAbsorbs
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitGroupRolesAssigned = function()
          local fn = _G.UnitGroupRolesAssigned
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitHPPerStamina = function()
          local fn = _G.UnitHPPerStamina
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitHasIncomingResurrection = function()
          local fn = _G.UnitHasIncomingResurrection
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitHasLFGDeserter = function()
          local fn = _G.UnitHasLFGDeserter
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitHasLFGRandomCooldown = function()
          local fn = _G.UnitHasLFGRandomCooldown
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitHasRelicSlot = function()
          local fn = _G.UnitHasRelicSlot
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitHasVehiclePlayerFrameUI = function()
          local fn = _G.UnitHasVehiclePlayerFrameUI
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitHasVehicleUI = function()
          local fn = _G.UnitHasVehicleUI
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitHealth = function()
          local fn = _G.UnitHealth
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitHealthMax = function()
          local fn = _G.UnitHealthMax
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitHonor = function()
          local fn = _G.UnitHonor
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitHonorLevel = function()
          local fn = _G.UnitHonorLevel
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitHonorMax = function()
          local fn = _G.UnitHonorMax
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitInBattleground = function()
          local fn = _G.UnitInBattleground
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitInParty = function()
          local fn = _G.UnitInParty
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitInPartyShard = function()
          local fn = _G.UnitInPartyShard
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitInRaid = function()
          local fn = _G.UnitInRaid
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitInRange = function()
          local fn = _G.UnitInRange
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitInVehicle = function()
          local fn = _G.UnitInVehicle
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitIsAFK = function()
          local fn = _G.UnitIsAFK
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitIsCharmed = function()
          local fn = _G.UnitIsCharmed
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitIsConnected = function()
          local fn = _G.UnitIsConnected
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitIsDND = function()
          local fn = _G.UnitIsDND
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitIsDead = function()
          local fn = _G.UnitIsDead
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitIsDeadOrGhost = function()
          local fn = _G.UnitIsDeadOrGhost
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitIsEnemy = function()
          local fn = _G.UnitIsEnemy
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitIsFeignDeath = function()
          local fn = _G.UnitIsFeignDeath
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitIsFriend = function()
          local fn = _G.UnitIsFriend
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitIsGhost = function()
          local fn = _G.UnitIsGhost
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitIsGroupAssistant = function()
          local fn = _G.UnitIsGroupAssistant
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitIsGroupLeader = function()
          local fn = _G.UnitIsGroupLeader
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitIsOtherPlayersPet = function()
          local fn = _G.UnitIsOtherPlayersPet
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitIsOwnerOrControllerOfUnit = function()
          local fn = _G.UnitIsOwnerOrControllerOfUnit
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitIsPVP = function()
          local fn = _G.UnitIsPVP
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitIsPVPFreeForAll = function()
          local fn = _G.UnitIsPVPFreeForAll
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitIsPlayer = function()
          local fn = _G.UnitIsPlayer
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitIsPossessed = function()
          local fn = _G.UnitIsPossessed
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitIsTapDenied = function()
          local fn = _G.UnitIsTapDenied
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitIsUnit = function()
          local fn = _G.UnitIsUnit
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitIsVisible = function()
          local fn = _G.UnitIsVisible
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitLevel = function()
          local fn = _G.UnitLevel
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitName = function()
          local fn = _G.UnitName
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitNameUnmodified = function()
          local fn = _G.UnitNameUnmodified
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitNameplateShowsWidgetsOnly = function()
          local fn = _G.UnitNameplateShowsWidgetsOnly
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitOnTaxi = function()
          local fn = _G.UnitOnTaxi
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitPVPName = function()
          local fn = _G.UnitPVPName
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitPVPRank = function()
          local fn = _G.UnitPVPRank
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitPhaseReason = function()
          local fn = _G.UnitPhaseReason
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitPlayerControlled = function()
          local fn = _G.UnitPlayerControlled
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitPlayerOrPetInParty = function()
          local fn = _G.UnitPlayerOrPetInParty
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitPlayerOrPetInRaid = function()
          local fn = _G.UnitPlayerOrPetInRaid
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitPosition = function()
          local fn = _G.UnitPosition
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitPower = function()
          local fn = _G.UnitPower
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitPowerBarID = function()
          local fn = _G.UnitPowerBarID
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitPowerBarTimerInfo = function()
          local fn = _G.UnitPowerBarTimerInfo
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitPowerDisplayMod = function()
          local fn = _G.UnitPowerDisplayMod
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitPowerMax = function()
          local fn = _G.UnitPowerMax
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitPowerType = function()
          local fn = _G.UnitPowerType
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitPvpClassification = function()
          local fn = _G.UnitPvpClassification
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitQuestTrivialLevelRange = function()
          local fn = _G.UnitQuestTrivialLevelRange
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitQuestTrivialLevelRangeScaling = function()
          local fn = _G.UnitQuestTrivialLevelRangeScaling
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitRace = function()
          local fn = _G.UnitRace
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitRangedAttack = function()
          local fn = _G.UnitRangedAttack
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitReaction = function()
          local fn = _G.UnitReaction
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitRealmRelationship = function()
          local fn = _G.UnitRealmRelationship
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitResistance = function()
          local fn = _G.UnitResistance
          if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitSelectionColor = function()
          local fn = _G.UnitSelectionColor
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitSex = function()
          local fn = _G.UnitSex
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitStagger = function()
          local fn = _G.UnitStagger
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitStat = function()
          local fn = _G.UnitStat
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitTargetsVehicleInRaidUI = function()
          local fn = _G.UnitTargetsVehicleInRaidUI
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitThreatSituation = function()
          local fn = _G.UnitThreatSituation
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitTreatAsPlayerForDisplay = function()
          local fn = _G.UnitTreatAsPlayerForDisplay
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitWidgetSet = function()
          local fn = _G.UnitWidgetSet
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitXP = function()
          local fn = _G.UnitXP
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UnitXPMax = function()
          local fn = _G.UnitXPMax
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UpdateAddOnMemoryUsage = function()
          local fn = _G.UpdateAddOnMemoryUsage
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UseAction = function()
          local fn = _G.UseAction
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        UseInventoryItem = function()
          local fn = _G.UseInventoryItem
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        VehicleAimDecrement = function()
          local fn = _G.VehicleAimDecrement
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        VehicleAimDownStart = function()
          local fn = _G.VehicleAimDownStart
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        VehicleAimDownStop = function()
          local fn = _G.VehicleAimDownStop
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        VehicleAimIncrement = function()
          local fn = _G.VehicleAimIncrement
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        VehicleAimUpStart = function()
          local fn = _G.VehicleAimUpStart
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        VehicleAimUpStop = function()
          local fn = _G.VehicleAimUpStop
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        VehicleExit = function()
          local fn = _G.VehicleExit
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        VehicleNextSeat = function()
          local fn = _G.VehicleNextSeat
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        VehiclePrevSeat = function()
          local fn = _G.VehiclePrevSeat
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertEquals('nil', type(fn))
            return
          end
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        debugprofilestop = function()
          local fn = _G.debugprofilestop
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        geterrorhandler = function()
          local fn = _G.geterrorhandler
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        getfenv = function()
          local fn = _G.getfenv
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        hooksecurefunc = function()
          local fn = _G.hooksecurefunc
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        loadstring = function()
          local fn = _G.loadstring
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        securecall = function()
          local fn = _G.securecall
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        securecallfunction = function()
          local fn = _G.securecallfunction
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        secureexecuterange = function()
          local fn = _G.secureexecuterange
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        seterrorhandler = function()
          local fn = _G.seterrorhandler
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
            end,
          }
        end,
        xpcall = function()
          local fn = _G.xpcall
          assertEquals('function', type(fn))
          return {
            env = function()
              assert(_G == getfenv(fn))
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
                InitializeCamera = function()
                  assertEquals('function', type(mt.__index.InitializeCamera))
                end,
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
