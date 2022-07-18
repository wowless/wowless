local _, G = ...
local assertEquals = _G.assertEquals
local runtimeProduct = (function()
  if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
    return IsTestBuild() and 'wow_classic_era_ptr' or 'wow_classic_era'
  elseif WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC then
    local wrath = GetBuildInfo():sub(1, 1) == '3'
    return wrath and 'wow_classic_beta' or IsTestBuild() and 'wow_classic_ptr' or 'wow_classic'
  elseif WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
    local dragon = GetBuildInfo():sub(1, 1) ~= '9'
    return dragon and 'wow_beta' or IsTestBuild() and 'wowt' or 'wow'
  else
    error('invalid product')
  end
end)()
local function badProduct(s)
  for p in string.gmatch(s, '[^,]+') do
    if p == runtimeProduct then
      return false
    end
  end
  return true
end
function G.GeneratedTests()
  local cfuncs = {}
  local function checkFunc(func, isLua)
    assertEquals('function', type(func))
    return {
      getfenv = function()
        assertEquals(_G, getfenv(func))
      end,
      impltype = function()
        assertEquals(
          isLua,
          pcall(function()
            coroutine.create(func)
          end)
        )
      end,
      unique = not isLua and function()
        assertEquals(nil, cfuncs[func])
        cfuncs[func] = true
      end or nil,
    }
  end
  local function checkCFunc(func)
    return checkFunc(func, false)
  end
  local function checkLuaFunc(func)
    return checkFunc(func, true)
  end
  local function checkNotCFunc(func)
    if func ~= nil and not cfuncs[func] then
      return checkLuaFunc(func)
    end
  end
  return {
    apiNamespaces = function()
      local function mkTests(ns, tests)
        for k, v in pairs(ns) do
          -- Anything left over must be a FrameXML-defined function.
          if not tests[k] then
            tests['~' .. k] = function()
              if not cfuncs[v] then
                return checkLuaFunc(v)
              end
            end
          end
        end
        return tests
      end
      local tests = {}
      local empty = {}
      for name, ncfg in pairs(G.NamespaceApis) do
        tests[name] = function()
          local ns = _G[name]
          if ncfg.products and not ncfg.products[runtimeProduct] then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          local mtests = {}
          for mname, mcfg in pairs(ncfg.methods) do
            mcfg = mcfg == true and empty or mcfg
            mtests[mname] = function()
              local func = ns[mname]
              if mcfg.products and not mcfg.products[runtimeProduct] then
                return checkNotCFunc(func)
              end
              if mcfg.stdlib then
                local ty = type(mcfg.stdlib[1])
                if ty == 'function' then
                  return checkCFunc(func)
                else
                  assertEquals(ty, type(func))
                end
              else
                return checkCFunc(func)
              end
            end
          end
          return mkTests(ns, mtests)
        end
      end
      return tests
    end,
    globalApis = function()
      local tests = {}
      local empty = {}
      for name, cfg in pairs(G.GlobalApis) do
        cfg = cfg == true and empty or cfg
        tests[name] = function()
          local func = _G[name]
          if cfg.products and not cfg.products[runtimeProduct] then
            return checkNotCFunc(func)
          end
          if cfg.secureCapsule then
            assertEquals(_G.SecureCapsuleGet == nil, func ~= nil) -- addon_spec hack
          elseif cfg.alias then
            assertEquals(func, assert(cfg.alias[1]))
          elseif cfg.stdlib then
            local ty = type(cfg.stdlib[1])
            if ty == 'function' then
              return checkCFunc(func)
            else
              assertEquals(ty, type(func))
            end
          elseif cfg.nowrap then
            return checkLuaFunc(func)
          else
            return checkCFunc(func)
          end
        end
      end
      local ptrhooked = { -- TODO test these better
        FauxScrollFrame_Update = true,
        QuestLog_Update = true,
        QuestMapLogTitleButton_OnEnter = true,
        SetItemRef = true,
      }
      for k, v in pairs(_G) do
        if type(v) == 'function' and not tests[k] and not ptrhooked[k] then
          tests['~' .. k] = function()
            if not cfuncs[v] then
              return checkLuaFunc(v)
            end
          end
        end
      end
      return tests
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
      local GetObjectType = CreateFrame('Frame').GetObjectType
      local indexes = {}
      local function mkTests(objectTypeName, factory, tests)
        local obj = factory()
        local obj2 = factory()
        if objectTypeName == 'EditBox' then
          obj:Hide() -- captures input focus otherwise
          obj2:Hide() -- captures input focus otherwise
        end
        assert(obj ~= obj2)
        assertEquals(objectTypeName, GetObjectType(obj))
        local mt = getmetatable(obj)
        assert(mt == getmetatable(obj2))
        if objectTypeName ~= 'FogOfWarFrame' or WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
          assert(mt ~= nil)
          assert(getmetatable(mt) == nil)
          local mtk, __index = next(mt)
          assertEquals('__index', mtk)
          assertEquals('table', type(__index))
          assertEquals(nil, next(mt, mtk))
          assertEquals(nil, getmetatable(__index))
          assertEquals(nil, indexes[__index])
          indexes[__index] = true
          return {
            contents = function()
              local udk, udv = next(obj)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(obj, udk) == nil)
            end,
            methods = function()
              local t = tests(__index)
              for k in pairs(__index) do
                t[k] = t[k] or function()
                  error('missing')
                end
              end
              return t
            end,
          }
        end
      end
      return {
        Actor = function()
          assertCreateFrameFails('Actor')
        end,
        Alpha = function()
          assertCreateFrameFails('Alpha')
        end,
        Animation = function()
          local function factory()
            return CreateFrame('Frame'):CreateAnimationGroup():CreateAnimation()
          end
          return mkTests('Animation', factory, function(__index)
            return {
              GetDebugName = function()
                return checkCFunc(__index.GetDebugName)
              end,
              GetDuration = function()
                return checkCFunc(__index.GetDuration)
              end,
              GetElapsed = function()
                return checkCFunc(__index.GetElapsed)
              end,
              GetEndDelay = function()
                return checkCFunc(__index.GetEndDelay)
              end,
              GetName = function()
                return checkCFunc(__index.GetName)
              end,
              GetObjectType = function()
                return checkCFunc(__index.GetObjectType)
              end,
              GetOrder = function()
                return checkCFunc(__index.GetOrder)
              end,
              GetParent = function()
                return checkCFunc(__index.GetParent)
              end,
              GetProgress = function()
                return checkCFunc(__index.GetProgress)
              end,
              GetRegionParent = function()
                return checkCFunc(__index.GetRegionParent)
              end,
              GetScript = function()
                return checkCFunc(__index.GetScript)
              end,
              GetSmoothProgress = function()
                return checkCFunc(__index.GetSmoothProgress)
              end,
              GetSmoothing = function()
                return checkCFunc(__index.GetSmoothing)
              end,
              GetSourceLocation = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetSourceLocation))
                  return
                end
              end,
              GetStartDelay = function()
                return checkCFunc(__index.GetStartDelay)
              end,
              GetTarget = function()
                return checkCFunc(__index.GetTarget)
              end,
              HasScript = function()
                return checkCFunc(__index.HasScript)
              end,
              HookScript = function()
                return checkCFunc(__index.HookScript)
              end,
              IsDelaying = function()
                return checkCFunc(__index.IsDelaying)
              end,
              IsDone = function()
                return checkCFunc(__index.IsDone)
              end,
              IsForbidden = function()
                return checkCFunc(__index.IsForbidden)
              end,
              IsObjectType = function()
                return checkCFunc(__index.IsObjectType)
              end,
              IsPaused = function()
                return checkCFunc(__index.IsPaused)
              end,
              IsPlaying = function()
                return checkCFunc(__index.IsPlaying)
              end,
              IsStopped = function()
                return checkCFunc(__index.IsStopped)
              end,
              Pause = function()
                return checkCFunc(__index.Pause)
              end,
              Play = function()
                return checkCFunc(__index.Play)
              end,
              Restart = function()
                return checkCFunc(__index.Restart)
              end,
              SetChildKey = function()
                return checkCFunc(__index.SetChildKey)
              end,
              SetDuration = function()
                return checkCFunc(__index.SetDuration)
              end,
              SetEndDelay = function()
                return checkCFunc(__index.SetEndDelay)
              end,
              SetForbidden = function()
                return checkCFunc(__index.SetForbidden)
              end,
              SetOrder = function()
                return checkCFunc(__index.SetOrder)
              end,
              SetParent = function()
                return checkCFunc(__index.SetParent)
              end,
              SetPlaying = function()
                return checkCFunc(__index.SetPlaying)
              end,
              SetScript = function()
                return checkCFunc(__index.SetScript)
              end,
              SetSmoothProgress = function()
                return checkCFunc(__index.SetSmoothProgress)
              end,
              SetSmoothing = function()
                return checkCFunc(__index.SetSmoothing)
              end,
              SetStartDelay = function()
                return checkCFunc(__index.SetStartDelay)
              end,
              SetTarget = function()
                return checkCFunc(__index.SetTarget)
              end,
              SetTargetKey = function()
                return checkCFunc(__index.SetTargetKey)
              end,
              Stop = function()
                return checkCFunc(__index.Stop)
              end,
            }
          end)
        end,
        AnimationGroup = function()
          assertCreateFrameFails('AnimationGroup')
        end,
        Browser = function()
          local function factory()
            return assertCreateFrame('Browser')
          end
          return mkTests('Browser', factory, function(__index)
            return {
              AdjustPointsOffset = function()
                return checkCFunc(__index.AdjustPointsOffset)
              end,
              CanChangeAttribute = function()
                return checkCFunc(__index.CanChangeAttribute)
              end,
              CanChangeProtectedState = function()
                return checkCFunc(__index.CanChangeProtectedState)
              end,
              ClearAllPoints = function()
                return checkCFunc(__index.ClearAllPoints)
              end,
              ClearFocus = function()
                return checkCFunc(__index.ClearFocus)
              end,
              ClearPointByName = function()
                return checkCFunc(__index.ClearPointByName)
              end,
              ClearPointsOffset = function()
                return checkCFunc(__index.ClearPointsOffset)
              end,
              CopyExternalLink = function()
                return checkCFunc(__index.CopyExternalLink)
              end,
              CreateAnimationGroup = function()
                return checkCFunc(__index.CreateAnimationGroup)
              end,
              CreateFontString = function()
                return checkCFunc(__index.CreateFontString)
              end,
              CreateLine = function()
                return checkCFunc(__index.CreateLine)
              end,
              CreateMaskTexture = function()
                return checkCFunc(__index.CreateMaskTexture)
              end,
              CreateTexture = function()
                return checkCFunc(__index.CreateTexture)
              end,
              DeleteCookies = function()
                return checkCFunc(__index.DeleteCookies)
              end,
              DesaturateHierarchy = function()
                return checkCFunc(__index.DesaturateHierarchy)
              end,
              DisableDrawLayer = function()
                return checkCFunc(__index.DisableDrawLayer)
              end,
              DoesClipChildren = function()
                return checkCFunc(__index.DoesClipChildren)
              end,
              EnableDrawLayer = function()
                return checkCFunc(__index.EnableDrawLayer)
              end,
              EnableGamePadButton = function()
                return checkCFunc(__index.EnableGamePadButton)
              end,
              EnableGamePadStick = function()
                return checkCFunc(__index.EnableGamePadStick)
              end,
              EnableKeyboard = function()
                return checkCFunc(__index.EnableKeyboard)
              end,
              EnableMouse = function()
                return checkCFunc(__index.EnableMouse)
              end,
              EnableMouseWheel = function()
                return checkCFunc(__index.EnableMouseWheel)
              end,
              ExecuteAttribute = function()
                return checkCFunc(__index.ExecuteAttribute)
              end,
              GetAlpha = function()
                return checkCFunc(__index.GetAlpha)
              end,
              GetAnimationGroups = function()
                return checkCFunc(__index.GetAnimationGroups)
              end,
              GetAttribute = function()
                return checkCFunc(__index.GetAttribute)
              end,
              GetBottom = function()
                return checkCFunc(__index.GetBottom)
              end,
              GetBoundsRect = function()
                return checkCFunc(__index.GetBoundsRect)
              end,
              GetCenter = function()
                return checkCFunc(__index.GetCenter)
              end,
              GetChildren = function()
                return checkCFunc(__index.GetChildren)
              end,
              GetClampRectInsets = function()
                return checkCFunc(__index.GetClampRectInsets)
              end,
              GetDebugName = function()
                return checkCFunc(__index.GetDebugName)
              end,
              GetDepth = function()
                return checkCFunc(__index.GetDepth)
              end,
              GetDontSavePosition = function()
                return checkCFunc(__index.GetDontSavePosition)
              end,
              GetEffectiveAlpha = function()
                return checkCFunc(__index.GetEffectiveAlpha)
              end,
              GetEffectiveDepth = function()
                return checkCFunc(__index.GetEffectiveDepth)
              end,
              GetEffectiveScale = function()
                return checkCFunc(__index.GetEffectiveScale)
              end,
              GetEffectivelyFlattensRenderLayers = function()
                return checkCFunc(__index.GetEffectivelyFlattensRenderLayers)
              end,
              GetFlattensRenderLayers = function()
                return checkCFunc(__index.GetFlattensRenderLayers)
              end,
              GetFrameLevel = function()
                return checkCFunc(__index.GetFrameLevel)
              end,
              GetFrameStrata = function()
                return checkCFunc(__index.GetFrameStrata)
              end,
              GetHeight = function()
                return checkCFunc(__index.GetHeight)
              end,
              GetHitRectInsets = function()
                return checkCFunc(__index.GetHitRectInsets)
              end,
              GetHyperlinksEnabled = function()
                return checkCFunc(__index.GetHyperlinksEnabled)
              end,
              GetID = function()
                return checkCFunc(__index.GetID)
              end,
              GetLeft = function()
                return checkCFunc(__index.GetLeft)
              end,
              GetMaxResize = function()
                return checkCFunc(__index.GetMaxResize)
              end,
              GetMinResize = function()
                return checkCFunc(__index.GetMinResize)
              end,
              GetName = function()
                return checkCFunc(__index.GetName)
              end,
              GetNumChildren = function()
                return checkCFunc(__index.GetNumChildren)
              end,
              GetNumPoints = function()
                return checkCFunc(__index.GetNumPoints)
              end,
              GetNumRegions = function()
                return checkCFunc(__index.GetNumRegions)
              end,
              GetObjectType = function()
                return checkCFunc(__index.GetObjectType)
              end,
              GetParent = function()
                return checkCFunc(__index.GetParent)
              end,
              GetPoint = function()
                return checkCFunc(__index.GetPoint)
              end,
              GetPointByName = function()
                return checkCFunc(__index.GetPointByName)
              end,
              GetPropagateKeyboardInput = function()
                return checkCFunc(__index.GetPropagateKeyboardInput)
              end,
              GetRect = function()
                return checkCFunc(__index.GetRect)
              end,
              GetRegions = function()
                return checkCFunc(__index.GetRegions)
              end,
              GetRight = function()
                return checkCFunc(__index.GetRight)
              end,
              GetScale = function()
                return checkCFunc(__index.GetScale)
              end,
              GetScaledRect = function()
                return checkCFunc(__index.GetScaledRect)
              end,
              GetScript = function()
                return checkCFunc(__index.GetScript)
              end,
              GetSize = function()
                return checkCFunc(__index.GetSize)
              end,
              GetSourceLocation = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetSourceLocation))
                  return
                end
                return checkCFunc(__index.GetSourceLocation)
              end,
              GetTop = function()
                return checkCFunc(__index.GetTop)
              end,
              GetWidth = function()
                return checkCFunc(__index.GetWidth)
              end,
              HasFixedFrameLevel = function()
                return checkCFunc(__index.HasFixedFrameLevel)
              end,
              HasFixedFrameStrata = function()
                return checkCFunc(__index.HasFixedFrameStrata)
              end,
              HasScript = function()
                return checkCFunc(__index.HasScript)
              end,
              Hide = function()
                return checkCFunc(__index.Hide)
              end,
              HookScript = function()
                return checkCFunc(__index.HookScript)
              end,
              IgnoreDepth = function()
                return checkCFunc(__index.IgnoreDepth)
              end,
              IsAnchoringRestricted = function()
                return checkCFunc(__index.IsAnchoringRestricted)
              end,
              IsClampedToScreen = function()
                return checkCFunc(__index.IsClampedToScreen)
              end,
              IsDragging = function()
                return checkCFunc(__index.IsDragging)
              end,
              IsEventRegistered = function()
                return checkCFunc(__index.IsEventRegistered)
              end,
              IsForbidden = function()
                return checkCFunc(__index.IsForbidden)
              end,
              IsGamePadButtonEnabled = function()
                return checkCFunc(__index.IsGamePadButtonEnabled)
              end,
              IsGamePadStickEnabled = function()
                return checkCFunc(__index.IsGamePadStickEnabled)
              end,
              IsIgnoringDepth = function()
                return checkCFunc(__index.IsIgnoringDepth)
              end,
              IsIgnoringParentAlpha = function()
                return checkCFunc(__index.IsIgnoringParentAlpha)
              end,
              IsIgnoringParentScale = function()
                return checkCFunc(__index.IsIgnoringParentScale)
              end,
              IsKeyboardEnabled = function()
                return checkCFunc(__index.IsKeyboardEnabled)
              end,
              IsMouseClickEnabled = function()
                return checkCFunc(__index.IsMouseClickEnabled)
              end,
              IsMouseEnabled = function()
                return checkCFunc(__index.IsMouseEnabled)
              end,
              IsMouseMotionEnabled = function()
                return checkCFunc(__index.IsMouseMotionEnabled)
              end,
              IsMouseOver = function()
                return checkCFunc(__index.IsMouseOver)
              end,
              IsMouseWheelEnabled = function()
                return checkCFunc(__index.IsMouseWheelEnabled)
              end,
              IsMovable = function()
                return checkCFunc(__index.IsMovable)
              end,
              IsObjectLoaded = function()
                return checkCFunc(__index.IsObjectLoaded)
              end,
              IsObjectType = function()
                return checkCFunc(__index.IsObjectType)
              end,
              IsProtected = function()
                return checkCFunc(__index.IsProtected)
              end,
              IsRectValid = function()
                return checkCFunc(__index.IsRectValid)
              end,
              IsResizable = function()
                return checkCFunc(__index.IsResizable)
              end,
              IsShown = function()
                return checkCFunc(__index.IsShown)
              end,
              IsToplevel = function()
                return checkCFunc(__index.IsToplevel)
              end,
              IsUserPlaced = function()
                return checkCFunc(__index.IsUserPlaced)
              end,
              IsVisible = function()
                return checkCFunc(__index.IsVisible)
              end,
              Lower = function()
                return checkCFunc(__index.Lower)
              end,
              NavigateBack = function()
                return checkCFunc(__index.NavigateBack)
              end,
              NavigateForward = function()
                return checkCFunc(__index.NavigateForward)
              end,
              NavigateHome = function()
                return checkCFunc(__index.NavigateHome)
              end,
              NavigateReload = function()
                return checkCFunc(__index.NavigateReload)
              end,
              NavigateStop = function()
                return checkCFunc(__index.NavigateStop)
              end,
              OpenExternalLink = function()
                return checkCFunc(__index.OpenExternalLink)
              end,
              OpenTicket = function()
                return checkCFunc(__index.OpenTicket)
              end,
              Raise = function()
                return checkCFunc(__index.Raise)
              end,
              RegisterAllEvents = function()
                return checkCFunc(__index.RegisterAllEvents)
              end,
              RegisterEvent = function()
                return checkCFunc(__index.RegisterEvent)
              end,
              RegisterForDrag = function()
                return checkCFunc(__index.RegisterForDrag)
              end,
              RegisterUnitEvent = function()
                return checkCFunc(__index.RegisterUnitEvent)
              end,
              RotateTextures = function()
                return checkCFunc(__index.RotateTextures)
              end,
              SetAllPoints = function()
                return checkCFunc(__index.SetAllPoints)
              end,
              SetAlpha = function()
                return checkCFunc(__index.SetAlpha)
              end,
              SetAttribute = function()
                return checkCFunc(__index.SetAttribute)
              end,
              SetAttributeNoHandler = function()
                return checkCFunc(__index.SetAttributeNoHandler)
              end,
              SetClampRectInsets = function()
                return checkCFunc(__index.SetClampRectInsets)
              end,
              SetClampedToScreen = function()
                return checkCFunc(__index.SetClampedToScreen)
              end,
              SetClipsChildren = function()
                return checkCFunc(__index.SetClipsChildren)
              end,
              SetDepth = function()
                return checkCFunc(__index.SetDepth)
              end,
              SetDontSavePosition = function()
                return checkCFunc(__index.SetDontSavePosition)
              end,
              SetDrawLayerEnabled = function()
                return checkCFunc(__index.SetDrawLayerEnabled)
              end,
              SetFixedFrameLevel = function()
                return checkCFunc(__index.SetFixedFrameLevel)
              end,
              SetFixedFrameStrata = function()
                return checkCFunc(__index.SetFixedFrameStrata)
              end,
              SetFlattensRenderLayers = function()
                return checkCFunc(__index.SetFlattensRenderLayers)
              end,
              SetFocus = function()
                return checkCFunc(__index.SetFocus)
              end,
              SetForbidden = function()
                return checkCFunc(__index.SetForbidden)
              end,
              SetFrameBuffer = function()
                return checkCFunc(__index.SetFrameBuffer)
              end,
              SetFrameLevel = function()
                return checkCFunc(__index.SetFrameLevel)
              end,
              SetFrameStrata = function()
                return checkCFunc(__index.SetFrameStrata)
              end,
              SetHeight = function()
                return checkCFunc(__index.SetHeight)
              end,
              SetHitRectInsets = function()
                return checkCFunc(__index.SetHitRectInsets)
              end,
              SetHyperlinksEnabled = function()
                return checkCFunc(__index.SetHyperlinksEnabled)
              end,
              SetID = function()
                return checkCFunc(__index.SetID)
              end,
              SetIgnoreParentAlpha = function()
                return checkCFunc(__index.SetIgnoreParentAlpha)
              end,
              SetIgnoreParentScale = function()
                return checkCFunc(__index.SetIgnoreParentScale)
              end,
              SetMaxResize = function()
                return checkCFunc(__index.SetMaxResize)
              end,
              SetMinResize = function()
                return checkCFunc(__index.SetMinResize)
              end,
              SetMouseClickEnabled = function()
                return checkCFunc(__index.SetMouseClickEnabled)
              end,
              SetMouseMotionEnabled = function()
                return checkCFunc(__index.SetMouseMotionEnabled)
              end,
              SetMovable = function()
                return checkCFunc(__index.SetMovable)
              end,
              SetParent = function()
                return checkCFunc(__index.SetParent)
              end,
              SetPoint = function()
                return checkCFunc(__index.SetPoint)
              end,
              SetPropagateKeyboardInput = function()
                return checkCFunc(__index.SetPropagateKeyboardInput)
              end,
              SetResizable = function()
                return checkCFunc(__index.SetResizable)
              end,
              SetScale = function()
                return checkCFunc(__index.SetScale)
              end,
              SetScript = function()
                return checkCFunc(__index.SetScript)
              end,
              SetShown = function()
                return checkCFunc(__index.SetShown)
              end,
              SetSize = function()
                return checkCFunc(__index.SetSize)
              end,
              SetToplevel = function()
                return checkCFunc(__index.SetToplevel)
              end,
              SetUserPlaced = function()
                return checkCFunc(__index.SetUserPlaced)
              end,
              SetWidth = function()
                return checkCFunc(__index.SetWidth)
              end,
              SetZoom = function()
                return checkCFunc(__index.SetZoom)
              end,
              Show = function()
                return checkCFunc(__index.Show)
              end,
              StartMoving = function()
                return checkCFunc(__index.StartMoving)
              end,
              StartSizing = function()
                return checkCFunc(__index.StartSizing)
              end,
              StopAnimating = function()
                return checkCFunc(__index.StopAnimating)
              end,
              StopMovingOrSizing = function()
                return checkCFunc(__index.StopMovingOrSizing)
              end,
              UnregisterAllEvents = function()
                return checkCFunc(__index.UnregisterAllEvents)
              end,
              UnregisterEvent = function()
                return checkCFunc(__index.UnregisterEvent)
              end,
            }
          end)
        end,
        Button = function()
          local function factory()
            return assertCreateFrame('Button')
          end
          return mkTests('Button', factory, function(__index)
            return {
              AdjustPointsOffset = function()
                return checkCFunc(__index.AdjustPointsOffset)
              end,
              CanChangeAttribute = function()
                return checkCFunc(__index.CanChangeAttribute)
              end,
              CanChangeProtectedState = function()
                return checkCFunc(__index.CanChangeProtectedState)
              end,
              ClearAllPoints = function()
                return checkCFunc(__index.ClearAllPoints)
              end,
              ClearPointByName = function()
                return checkCFunc(__index.ClearPointByName)
              end,
              ClearPointsOffset = function()
                return checkCFunc(__index.ClearPointsOffset)
              end,
              Click = function()
                return checkCFunc(__index.Click)
              end,
              CreateAnimationGroup = function()
                return checkCFunc(__index.CreateAnimationGroup)
              end,
              CreateFontString = function()
                return checkCFunc(__index.CreateFontString)
              end,
              CreateLine = function()
                return checkCFunc(__index.CreateLine)
              end,
              CreateMaskTexture = function()
                return checkCFunc(__index.CreateMaskTexture)
              end,
              CreateTexture = function()
                return checkCFunc(__index.CreateTexture)
              end,
              DesaturateHierarchy = function()
                return checkCFunc(__index.DesaturateHierarchy)
              end,
              Disable = function()
                return checkCFunc(__index.Disable)
              end,
              DisableDrawLayer = function()
                return checkCFunc(__index.DisableDrawLayer)
              end,
              DoesClipChildren = function()
                return checkCFunc(__index.DoesClipChildren)
              end,
              Enable = function()
                return checkCFunc(__index.Enable)
              end,
              EnableDrawLayer = function()
                return checkCFunc(__index.EnableDrawLayer)
              end,
              EnableGamePadButton = function()
                return checkCFunc(__index.EnableGamePadButton)
              end,
              EnableGamePadStick = function()
                return checkCFunc(__index.EnableGamePadStick)
              end,
              EnableKeyboard = function()
                return checkCFunc(__index.EnableKeyboard)
              end,
              EnableMouse = function()
                return checkCFunc(__index.EnableMouse)
              end,
              EnableMouseWheel = function()
                return checkCFunc(__index.EnableMouseWheel)
              end,
              ExecuteAttribute = function()
                return checkCFunc(__index.ExecuteAttribute)
              end,
              GetAlpha = function()
                return checkCFunc(__index.GetAlpha)
              end,
              GetAnimationGroups = function()
                return checkCFunc(__index.GetAnimationGroups)
              end,
              GetAttribute = function()
                return checkCFunc(__index.GetAttribute)
              end,
              GetBottom = function()
                return checkCFunc(__index.GetBottom)
              end,
              GetBoundsRect = function()
                return checkCFunc(__index.GetBoundsRect)
              end,
              GetButtonState = function()
                return checkCFunc(__index.GetButtonState)
              end,
              GetCenter = function()
                return checkCFunc(__index.GetCenter)
              end,
              GetChildren = function()
                return checkCFunc(__index.GetChildren)
              end,
              GetClampRectInsets = function()
                return checkCFunc(__index.GetClampRectInsets)
              end,
              GetDebugName = function()
                return checkCFunc(__index.GetDebugName)
              end,
              GetDepth = function()
                return checkCFunc(__index.GetDepth)
              end,
              GetDisabledFontObject = function()
                return checkCFunc(__index.GetDisabledFontObject)
              end,
              GetDisabledTexture = function()
                return checkCFunc(__index.GetDisabledTexture)
              end,
              GetDontSavePosition = function()
                return checkCFunc(__index.GetDontSavePosition)
              end,
              GetEffectiveAlpha = function()
                return checkCFunc(__index.GetEffectiveAlpha)
              end,
              GetEffectiveDepth = function()
                return checkCFunc(__index.GetEffectiveDepth)
              end,
              GetEffectiveScale = function()
                return checkCFunc(__index.GetEffectiveScale)
              end,
              GetEffectivelyFlattensRenderLayers = function()
                return checkCFunc(__index.GetEffectivelyFlattensRenderLayers)
              end,
              GetFlattensRenderLayers = function()
                return checkCFunc(__index.GetFlattensRenderLayers)
              end,
              GetFontString = function()
                return checkCFunc(__index.GetFontString)
              end,
              GetFrameLevel = function()
                return checkCFunc(__index.GetFrameLevel)
              end,
              GetFrameStrata = function()
                return checkCFunc(__index.GetFrameStrata)
              end,
              GetHeight = function()
                return checkCFunc(__index.GetHeight)
              end,
              GetHighlightFontObject = function()
                return checkCFunc(__index.GetHighlightFontObject)
              end,
              GetHighlightTexture = function()
                return checkCFunc(__index.GetHighlightTexture)
              end,
              GetHitRectInsets = function()
                return checkCFunc(__index.GetHitRectInsets)
              end,
              GetHyperlinksEnabled = function()
                return checkCFunc(__index.GetHyperlinksEnabled)
              end,
              GetID = function()
                return checkCFunc(__index.GetID)
              end,
              GetLeft = function()
                return checkCFunc(__index.GetLeft)
              end,
              GetMaxResize = function()
                return checkCFunc(__index.GetMaxResize)
              end,
              GetMinResize = function()
                return checkCFunc(__index.GetMinResize)
              end,
              GetMotionScriptsWhileDisabled = function()
                return checkCFunc(__index.GetMotionScriptsWhileDisabled)
              end,
              GetName = function()
                return checkCFunc(__index.GetName)
              end,
              GetNormalFontObject = function()
                return checkCFunc(__index.GetNormalFontObject)
              end,
              GetNormalTexture = function()
                return checkCFunc(__index.GetNormalTexture)
              end,
              GetNumChildren = function()
                return checkCFunc(__index.GetNumChildren)
              end,
              GetNumPoints = function()
                return checkCFunc(__index.GetNumPoints)
              end,
              GetNumRegions = function()
                return checkCFunc(__index.GetNumRegions)
              end,
              GetObjectType = function()
                return checkCFunc(__index.GetObjectType)
              end,
              GetParent = function()
                return checkCFunc(__index.GetParent)
              end,
              GetPoint = function()
                return checkCFunc(__index.GetPoint)
              end,
              GetPointByName = function()
                return checkCFunc(__index.GetPointByName)
              end,
              GetPropagateKeyboardInput = function()
                return checkCFunc(__index.GetPropagateKeyboardInput)
              end,
              GetPushedTextOffset = function()
                return checkCFunc(__index.GetPushedTextOffset)
              end,
              GetPushedTexture = function()
                return checkCFunc(__index.GetPushedTexture)
              end,
              GetRect = function()
                return checkCFunc(__index.GetRect)
              end,
              GetRegions = function()
                return checkCFunc(__index.GetRegions)
              end,
              GetRight = function()
                return checkCFunc(__index.GetRight)
              end,
              GetScale = function()
                return checkCFunc(__index.GetScale)
              end,
              GetScaledRect = function()
                return checkCFunc(__index.GetScaledRect)
              end,
              GetScript = function()
                return checkCFunc(__index.GetScript)
              end,
              GetSize = function()
                return checkCFunc(__index.GetSize)
              end,
              GetSourceLocation = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetSourceLocation))
                  return
                end
                return checkCFunc(__index.GetSourceLocation)
              end,
              GetText = function()
                return checkCFunc(__index.GetText)
              end,
              GetTextHeight = function()
                return checkCFunc(__index.GetTextHeight)
              end,
              GetTextWidth = function()
                return checkCFunc(__index.GetTextWidth)
              end,
              GetTop = function()
                return checkCFunc(__index.GetTop)
              end,
              GetWidth = function()
                return checkCFunc(__index.GetWidth)
              end,
              HasFixedFrameLevel = function()
                return checkCFunc(__index.HasFixedFrameLevel)
              end,
              HasFixedFrameStrata = function()
                return checkCFunc(__index.HasFixedFrameStrata)
              end,
              HasScript = function()
                return checkCFunc(__index.HasScript)
              end,
              Hide = function()
                return checkCFunc(__index.Hide)
              end,
              HookScript = function()
                return checkCFunc(__index.HookScript)
              end,
              IgnoreDepth = function()
                return checkCFunc(__index.IgnoreDepth)
              end,
              IsAnchoringRestricted = function()
                return checkCFunc(__index.IsAnchoringRestricted)
              end,
              IsClampedToScreen = function()
                return checkCFunc(__index.IsClampedToScreen)
              end,
              IsDragging = function()
                return checkCFunc(__index.IsDragging)
              end,
              IsEnabled = function()
                return checkCFunc(__index.IsEnabled)
              end,
              IsEventRegistered = function()
                return checkCFunc(__index.IsEventRegistered)
              end,
              IsForbidden = function()
                return checkCFunc(__index.IsForbidden)
              end,
              IsGamePadButtonEnabled = function()
                return checkCFunc(__index.IsGamePadButtonEnabled)
              end,
              IsGamePadStickEnabled = function()
                return checkCFunc(__index.IsGamePadStickEnabled)
              end,
              IsIgnoringDepth = function()
                return checkCFunc(__index.IsIgnoringDepth)
              end,
              IsIgnoringParentAlpha = function()
                return checkCFunc(__index.IsIgnoringParentAlpha)
              end,
              IsIgnoringParentScale = function()
                return checkCFunc(__index.IsIgnoringParentScale)
              end,
              IsKeyboardEnabled = function()
                return checkCFunc(__index.IsKeyboardEnabled)
              end,
              IsMouseClickEnabled = function()
                return checkCFunc(__index.IsMouseClickEnabled)
              end,
              IsMouseEnabled = function()
                return checkCFunc(__index.IsMouseEnabled)
              end,
              IsMouseMotionEnabled = function()
                return checkCFunc(__index.IsMouseMotionEnabled)
              end,
              IsMouseOver = function()
                return checkCFunc(__index.IsMouseOver)
              end,
              IsMouseWheelEnabled = function()
                return checkCFunc(__index.IsMouseWheelEnabled)
              end,
              IsMovable = function()
                return checkCFunc(__index.IsMovable)
              end,
              IsObjectLoaded = function()
                return checkCFunc(__index.IsObjectLoaded)
              end,
              IsObjectType = function()
                return checkCFunc(__index.IsObjectType)
              end,
              IsProtected = function()
                return checkCFunc(__index.IsProtected)
              end,
              IsRectValid = function()
                return checkCFunc(__index.IsRectValid)
              end,
              IsResizable = function()
                return checkCFunc(__index.IsResizable)
              end,
              IsShown = function()
                return checkCFunc(__index.IsShown)
              end,
              IsToplevel = function()
                return checkCFunc(__index.IsToplevel)
              end,
              IsUserPlaced = function()
                return checkCFunc(__index.IsUserPlaced)
              end,
              IsVisible = function()
                return checkCFunc(__index.IsVisible)
              end,
              LockHighlight = function()
                return checkCFunc(__index.LockHighlight)
              end,
              Lower = function()
                return checkCFunc(__index.Lower)
              end,
              Raise = function()
                return checkCFunc(__index.Raise)
              end,
              RegisterAllEvents = function()
                return checkCFunc(__index.RegisterAllEvents)
              end,
              RegisterEvent = function()
                return checkCFunc(__index.RegisterEvent)
              end,
              RegisterForClicks = function()
                return checkCFunc(__index.RegisterForClicks)
              end,
              RegisterForDrag = function()
                return checkCFunc(__index.RegisterForDrag)
              end,
              RegisterForMouse = function()
                return checkCFunc(__index.RegisterForMouse)
              end,
              RegisterUnitEvent = function()
                return checkCFunc(__index.RegisterUnitEvent)
              end,
              RotateTextures = function()
                return checkCFunc(__index.RotateTextures)
              end,
              SetAllPoints = function()
                return checkCFunc(__index.SetAllPoints)
              end,
              SetAlpha = function()
                return checkCFunc(__index.SetAlpha)
              end,
              SetAttribute = function()
                return checkCFunc(__index.SetAttribute)
              end,
              SetAttributeNoHandler = function()
                return checkCFunc(__index.SetAttributeNoHandler)
              end,
              SetButtonState = function()
                return checkCFunc(__index.SetButtonState)
              end,
              SetClampRectInsets = function()
                return checkCFunc(__index.SetClampRectInsets)
              end,
              SetClampedToScreen = function()
                return checkCFunc(__index.SetClampedToScreen)
              end,
              SetClipsChildren = function()
                return checkCFunc(__index.SetClipsChildren)
              end,
              SetDepth = function()
                return checkCFunc(__index.SetDepth)
              end,
              SetDisabledAtlas = function()
                return checkCFunc(__index.SetDisabledAtlas)
              end,
              SetDisabledFontObject = function()
                return checkCFunc(__index.SetDisabledFontObject)
              end,
              SetDisabledTexture = function()
                return checkCFunc(__index.SetDisabledTexture)
              end,
              SetDontSavePosition = function()
                return checkCFunc(__index.SetDontSavePosition)
              end,
              SetDrawLayerEnabled = function()
                return checkCFunc(__index.SetDrawLayerEnabled)
              end,
              SetEnabled = function()
                return checkCFunc(__index.SetEnabled)
              end,
              SetFixedFrameLevel = function()
                return checkCFunc(__index.SetFixedFrameLevel)
              end,
              SetFixedFrameStrata = function()
                return checkCFunc(__index.SetFixedFrameStrata)
              end,
              SetFlattensRenderLayers = function()
                return checkCFunc(__index.SetFlattensRenderLayers)
              end,
              SetFontString = function()
                return checkCFunc(__index.SetFontString)
              end,
              SetForbidden = function()
                return checkCFunc(__index.SetForbidden)
              end,
              SetFormattedText = function()
                return checkCFunc(__index.SetFormattedText)
              end,
              SetFrameBuffer = function()
                return checkCFunc(__index.SetFrameBuffer)
              end,
              SetFrameLevel = function()
                return checkCFunc(__index.SetFrameLevel)
              end,
              SetFrameStrata = function()
                return checkCFunc(__index.SetFrameStrata)
              end,
              SetHeight = function()
                return checkCFunc(__index.SetHeight)
              end,
              SetHighlightAtlas = function()
                return checkCFunc(__index.SetHighlightAtlas)
              end,
              SetHighlightFontObject = function()
                return checkCFunc(__index.SetHighlightFontObject)
              end,
              SetHighlightTexture = function()
                return checkCFunc(__index.SetHighlightTexture)
              end,
              SetHitRectInsets = function()
                return checkCFunc(__index.SetHitRectInsets)
              end,
              SetHyperlinksEnabled = function()
                return checkCFunc(__index.SetHyperlinksEnabled)
              end,
              SetID = function()
                return checkCFunc(__index.SetID)
              end,
              SetIgnoreParentAlpha = function()
                return checkCFunc(__index.SetIgnoreParentAlpha)
              end,
              SetIgnoreParentScale = function()
                return checkCFunc(__index.SetIgnoreParentScale)
              end,
              SetMaxResize = function()
                return checkCFunc(__index.SetMaxResize)
              end,
              SetMinResize = function()
                return checkCFunc(__index.SetMinResize)
              end,
              SetMotionScriptsWhileDisabled = function()
                return checkCFunc(__index.SetMotionScriptsWhileDisabled)
              end,
              SetMouseClickEnabled = function()
                return checkCFunc(__index.SetMouseClickEnabled)
              end,
              SetMouseMotionEnabled = function()
                return checkCFunc(__index.SetMouseMotionEnabled)
              end,
              SetMovable = function()
                return checkCFunc(__index.SetMovable)
              end,
              SetNormalAtlas = function()
                return checkCFunc(__index.SetNormalAtlas)
              end,
              SetNormalFontObject = function()
                return checkCFunc(__index.SetNormalFontObject)
              end,
              SetNormalTexture = function()
                return checkCFunc(__index.SetNormalTexture)
              end,
              SetParent = function()
                return checkCFunc(__index.SetParent)
              end,
              SetPoint = function()
                return checkCFunc(__index.SetPoint)
              end,
              SetPropagateKeyboardInput = function()
                return checkCFunc(__index.SetPropagateKeyboardInput)
              end,
              SetPushedAtlas = function()
                return checkCFunc(__index.SetPushedAtlas)
              end,
              SetPushedTextOffset = function()
                return checkCFunc(__index.SetPushedTextOffset)
              end,
              SetPushedTexture = function()
                return checkCFunc(__index.SetPushedTexture)
              end,
              SetResizable = function()
                return checkCFunc(__index.SetResizable)
              end,
              SetScale = function()
                return checkCFunc(__index.SetScale)
              end,
              SetScript = function()
                return checkCFunc(__index.SetScript)
              end,
              SetShown = function()
                return checkCFunc(__index.SetShown)
              end,
              SetSize = function()
                return checkCFunc(__index.SetSize)
              end,
              SetText = function()
                return checkCFunc(__index.SetText)
              end,
              SetToplevel = function()
                return checkCFunc(__index.SetToplevel)
              end,
              SetUserPlaced = function()
                return checkCFunc(__index.SetUserPlaced)
              end,
              SetWidth = function()
                return checkCFunc(__index.SetWidth)
              end,
              Show = function()
                return checkCFunc(__index.Show)
              end,
              StartMoving = function()
                return checkCFunc(__index.StartMoving)
              end,
              StartSizing = function()
                return checkCFunc(__index.StartSizing)
              end,
              StopAnimating = function()
                return checkCFunc(__index.StopAnimating)
              end,
              StopMovingOrSizing = function()
                return checkCFunc(__index.StopMovingOrSizing)
              end,
              UnlockHighlight = function()
                return checkCFunc(__index.UnlockHighlight)
              end,
              UnregisterAllEvents = function()
                return checkCFunc(__index.UnregisterAllEvents)
              end,
              UnregisterEvent = function()
                return checkCFunc(__index.UnregisterEvent)
              end,
            }
          end)
        end,
        CheckButton = function()
          local function factory()
            return assertCreateFrame('CheckButton')
          end
          return mkTests('CheckButton', factory, function(__index)
            return {
              AdjustPointsOffset = function()
                return checkCFunc(__index.AdjustPointsOffset)
              end,
              CanChangeAttribute = function()
                return checkCFunc(__index.CanChangeAttribute)
              end,
              CanChangeProtectedState = function()
                return checkCFunc(__index.CanChangeProtectedState)
              end,
              ClearAllPoints = function()
                return checkCFunc(__index.ClearAllPoints)
              end,
              ClearPointByName = function()
                return checkCFunc(__index.ClearPointByName)
              end,
              ClearPointsOffset = function()
                return checkCFunc(__index.ClearPointsOffset)
              end,
              Click = function()
                return checkCFunc(__index.Click)
              end,
              CreateAnimationGroup = function()
                return checkCFunc(__index.CreateAnimationGroup)
              end,
              CreateFontString = function()
                return checkCFunc(__index.CreateFontString)
              end,
              CreateLine = function()
                return checkCFunc(__index.CreateLine)
              end,
              CreateMaskTexture = function()
                return checkCFunc(__index.CreateMaskTexture)
              end,
              CreateTexture = function()
                return checkCFunc(__index.CreateTexture)
              end,
              DesaturateHierarchy = function()
                return checkCFunc(__index.DesaturateHierarchy)
              end,
              Disable = function()
                return checkCFunc(__index.Disable)
              end,
              DisableDrawLayer = function()
                return checkCFunc(__index.DisableDrawLayer)
              end,
              DoesClipChildren = function()
                return checkCFunc(__index.DoesClipChildren)
              end,
              Enable = function()
                return checkCFunc(__index.Enable)
              end,
              EnableDrawLayer = function()
                return checkCFunc(__index.EnableDrawLayer)
              end,
              EnableGamePadButton = function()
                return checkCFunc(__index.EnableGamePadButton)
              end,
              EnableGamePadStick = function()
                return checkCFunc(__index.EnableGamePadStick)
              end,
              EnableKeyboard = function()
                return checkCFunc(__index.EnableKeyboard)
              end,
              EnableMouse = function()
                return checkCFunc(__index.EnableMouse)
              end,
              EnableMouseWheel = function()
                return checkCFunc(__index.EnableMouseWheel)
              end,
              ExecuteAttribute = function()
                return checkCFunc(__index.ExecuteAttribute)
              end,
              GetAlpha = function()
                return checkCFunc(__index.GetAlpha)
              end,
              GetAnimationGroups = function()
                return checkCFunc(__index.GetAnimationGroups)
              end,
              GetAttribute = function()
                return checkCFunc(__index.GetAttribute)
              end,
              GetBottom = function()
                return checkCFunc(__index.GetBottom)
              end,
              GetBoundsRect = function()
                return checkCFunc(__index.GetBoundsRect)
              end,
              GetButtonState = function()
                return checkCFunc(__index.GetButtonState)
              end,
              GetCenter = function()
                return checkCFunc(__index.GetCenter)
              end,
              GetChecked = function()
                return checkCFunc(__index.GetChecked)
              end,
              GetCheckedTexture = function()
                return checkCFunc(__index.GetCheckedTexture)
              end,
              GetChildren = function()
                return checkCFunc(__index.GetChildren)
              end,
              GetClampRectInsets = function()
                return checkCFunc(__index.GetClampRectInsets)
              end,
              GetDebugName = function()
                return checkCFunc(__index.GetDebugName)
              end,
              GetDepth = function()
                return checkCFunc(__index.GetDepth)
              end,
              GetDisabledCheckedTexture = function()
                return checkCFunc(__index.GetDisabledCheckedTexture)
              end,
              GetDisabledFontObject = function()
                return checkCFunc(__index.GetDisabledFontObject)
              end,
              GetDisabledTexture = function()
                return checkCFunc(__index.GetDisabledTexture)
              end,
              GetDontSavePosition = function()
                return checkCFunc(__index.GetDontSavePosition)
              end,
              GetEffectiveAlpha = function()
                return checkCFunc(__index.GetEffectiveAlpha)
              end,
              GetEffectiveDepth = function()
                return checkCFunc(__index.GetEffectiveDepth)
              end,
              GetEffectiveScale = function()
                return checkCFunc(__index.GetEffectiveScale)
              end,
              GetEffectivelyFlattensRenderLayers = function()
                return checkCFunc(__index.GetEffectivelyFlattensRenderLayers)
              end,
              GetFlattensRenderLayers = function()
                return checkCFunc(__index.GetFlattensRenderLayers)
              end,
              GetFontString = function()
                return checkCFunc(__index.GetFontString)
              end,
              GetFrameLevel = function()
                return checkCFunc(__index.GetFrameLevel)
              end,
              GetFrameStrata = function()
                return checkCFunc(__index.GetFrameStrata)
              end,
              GetHeight = function()
                return checkCFunc(__index.GetHeight)
              end,
              GetHighlightFontObject = function()
                return checkCFunc(__index.GetHighlightFontObject)
              end,
              GetHighlightTexture = function()
                return checkCFunc(__index.GetHighlightTexture)
              end,
              GetHitRectInsets = function()
                return checkCFunc(__index.GetHitRectInsets)
              end,
              GetHyperlinksEnabled = function()
                return checkCFunc(__index.GetHyperlinksEnabled)
              end,
              GetID = function()
                return checkCFunc(__index.GetID)
              end,
              GetLeft = function()
                return checkCFunc(__index.GetLeft)
              end,
              GetMaxResize = function()
                return checkCFunc(__index.GetMaxResize)
              end,
              GetMinResize = function()
                return checkCFunc(__index.GetMinResize)
              end,
              GetMotionScriptsWhileDisabled = function()
                return checkCFunc(__index.GetMotionScriptsWhileDisabled)
              end,
              GetName = function()
                return checkCFunc(__index.GetName)
              end,
              GetNormalFontObject = function()
                return checkCFunc(__index.GetNormalFontObject)
              end,
              GetNormalTexture = function()
                return checkCFunc(__index.GetNormalTexture)
              end,
              GetNumChildren = function()
                return checkCFunc(__index.GetNumChildren)
              end,
              GetNumPoints = function()
                return checkCFunc(__index.GetNumPoints)
              end,
              GetNumRegions = function()
                return checkCFunc(__index.GetNumRegions)
              end,
              GetObjectType = function()
                return checkCFunc(__index.GetObjectType)
              end,
              GetParent = function()
                return checkCFunc(__index.GetParent)
              end,
              GetPoint = function()
                return checkCFunc(__index.GetPoint)
              end,
              GetPointByName = function()
                return checkCFunc(__index.GetPointByName)
              end,
              GetPropagateKeyboardInput = function()
                return checkCFunc(__index.GetPropagateKeyboardInput)
              end,
              GetPushedTextOffset = function()
                return checkCFunc(__index.GetPushedTextOffset)
              end,
              GetPushedTexture = function()
                return checkCFunc(__index.GetPushedTexture)
              end,
              GetRect = function()
                return checkCFunc(__index.GetRect)
              end,
              GetRegions = function()
                return checkCFunc(__index.GetRegions)
              end,
              GetRight = function()
                return checkCFunc(__index.GetRight)
              end,
              GetScale = function()
                return checkCFunc(__index.GetScale)
              end,
              GetScaledRect = function()
                return checkCFunc(__index.GetScaledRect)
              end,
              GetScript = function()
                return checkCFunc(__index.GetScript)
              end,
              GetSize = function()
                return checkCFunc(__index.GetSize)
              end,
              GetSourceLocation = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetSourceLocation))
                  return
                end
                return checkCFunc(__index.GetSourceLocation)
              end,
              GetText = function()
                return checkCFunc(__index.GetText)
              end,
              GetTextHeight = function()
                return checkCFunc(__index.GetTextHeight)
              end,
              GetTextWidth = function()
                return checkCFunc(__index.GetTextWidth)
              end,
              GetTop = function()
                return checkCFunc(__index.GetTop)
              end,
              GetWidth = function()
                return checkCFunc(__index.GetWidth)
              end,
              HasFixedFrameLevel = function()
                return checkCFunc(__index.HasFixedFrameLevel)
              end,
              HasFixedFrameStrata = function()
                return checkCFunc(__index.HasFixedFrameStrata)
              end,
              HasScript = function()
                return checkCFunc(__index.HasScript)
              end,
              Hide = function()
                return checkCFunc(__index.Hide)
              end,
              HookScript = function()
                return checkCFunc(__index.HookScript)
              end,
              IgnoreDepth = function()
                return checkCFunc(__index.IgnoreDepth)
              end,
              IsAnchoringRestricted = function()
                return checkCFunc(__index.IsAnchoringRestricted)
              end,
              IsClampedToScreen = function()
                return checkCFunc(__index.IsClampedToScreen)
              end,
              IsDragging = function()
                return checkCFunc(__index.IsDragging)
              end,
              IsEnabled = function()
                return checkCFunc(__index.IsEnabled)
              end,
              IsEventRegistered = function()
                return checkCFunc(__index.IsEventRegistered)
              end,
              IsForbidden = function()
                return checkCFunc(__index.IsForbidden)
              end,
              IsGamePadButtonEnabled = function()
                return checkCFunc(__index.IsGamePadButtonEnabled)
              end,
              IsGamePadStickEnabled = function()
                return checkCFunc(__index.IsGamePadStickEnabled)
              end,
              IsIgnoringDepth = function()
                return checkCFunc(__index.IsIgnoringDepth)
              end,
              IsIgnoringParentAlpha = function()
                return checkCFunc(__index.IsIgnoringParentAlpha)
              end,
              IsIgnoringParentScale = function()
                return checkCFunc(__index.IsIgnoringParentScale)
              end,
              IsKeyboardEnabled = function()
                return checkCFunc(__index.IsKeyboardEnabled)
              end,
              IsMouseClickEnabled = function()
                return checkCFunc(__index.IsMouseClickEnabled)
              end,
              IsMouseEnabled = function()
                return checkCFunc(__index.IsMouseEnabled)
              end,
              IsMouseMotionEnabled = function()
                return checkCFunc(__index.IsMouseMotionEnabled)
              end,
              IsMouseOver = function()
                return checkCFunc(__index.IsMouseOver)
              end,
              IsMouseWheelEnabled = function()
                return checkCFunc(__index.IsMouseWheelEnabled)
              end,
              IsMovable = function()
                return checkCFunc(__index.IsMovable)
              end,
              IsObjectLoaded = function()
                return checkCFunc(__index.IsObjectLoaded)
              end,
              IsObjectType = function()
                return checkCFunc(__index.IsObjectType)
              end,
              IsProtected = function()
                return checkCFunc(__index.IsProtected)
              end,
              IsRectValid = function()
                return checkCFunc(__index.IsRectValid)
              end,
              IsResizable = function()
                return checkCFunc(__index.IsResizable)
              end,
              IsShown = function()
                return checkCFunc(__index.IsShown)
              end,
              IsToplevel = function()
                return checkCFunc(__index.IsToplevel)
              end,
              IsUserPlaced = function()
                return checkCFunc(__index.IsUserPlaced)
              end,
              IsVisible = function()
                return checkCFunc(__index.IsVisible)
              end,
              LockHighlight = function()
                return checkCFunc(__index.LockHighlight)
              end,
              Lower = function()
                return checkCFunc(__index.Lower)
              end,
              Raise = function()
                return checkCFunc(__index.Raise)
              end,
              RegisterAllEvents = function()
                return checkCFunc(__index.RegisterAllEvents)
              end,
              RegisterEvent = function()
                return checkCFunc(__index.RegisterEvent)
              end,
              RegisterForClicks = function()
                return checkCFunc(__index.RegisterForClicks)
              end,
              RegisterForDrag = function()
                return checkCFunc(__index.RegisterForDrag)
              end,
              RegisterForMouse = function()
                return checkCFunc(__index.RegisterForMouse)
              end,
              RegisterUnitEvent = function()
                return checkCFunc(__index.RegisterUnitEvent)
              end,
              RotateTextures = function()
                return checkCFunc(__index.RotateTextures)
              end,
              SetAllPoints = function()
                return checkCFunc(__index.SetAllPoints)
              end,
              SetAlpha = function()
                return checkCFunc(__index.SetAlpha)
              end,
              SetAttribute = function()
                return checkCFunc(__index.SetAttribute)
              end,
              SetAttributeNoHandler = function()
                return checkCFunc(__index.SetAttributeNoHandler)
              end,
              SetButtonState = function()
                return checkCFunc(__index.SetButtonState)
              end,
              SetChecked = function()
                return checkCFunc(__index.SetChecked)
              end,
              SetCheckedTexture = function()
                return checkCFunc(__index.SetCheckedTexture)
              end,
              SetClampRectInsets = function()
                return checkCFunc(__index.SetClampRectInsets)
              end,
              SetClampedToScreen = function()
                return checkCFunc(__index.SetClampedToScreen)
              end,
              SetClipsChildren = function()
                return checkCFunc(__index.SetClipsChildren)
              end,
              SetDepth = function()
                return checkCFunc(__index.SetDepth)
              end,
              SetDisabledAtlas = function()
                return checkCFunc(__index.SetDisabledAtlas)
              end,
              SetDisabledCheckedTexture = function()
                return checkCFunc(__index.SetDisabledCheckedTexture)
              end,
              SetDisabledFontObject = function()
                return checkCFunc(__index.SetDisabledFontObject)
              end,
              SetDisabledTexture = function()
                return checkCFunc(__index.SetDisabledTexture)
              end,
              SetDontSavePosition = function()
                return checkCFunc(__index.SetDontSavePosition)
              end,
              SetDrawLayerEnabled = function()
                return checkCFunc(__index.SetDrawLayerEnabled)
              end,
              SetEnabled = function()
                return checkCFunc(__index.SetEnabled)
              end,
              SetFixedFrameLevel = function()
                return checkCFunc(__index.SetFixedFrameLevel)
              end,
              SetFixedFrameStrata = function()
                return checkCFunc(__index.SetFixedFrameStrata)
              end,
              SetFlattensRenderLayers = function()
                return checkCFunc(__index.SetFlattensRenderLayers)
              end,
              SetFontString = function()
                return checkCFunc(__index.SetFontString)
              end,
              SetForbidden = function()
                return checkCFunc(__index.SetForbidden)
              end,
              SetFormattedText = function()
                return checkCFunc(__index.SetFormattedText)
              end,
              SetFrameBuffer = function()
                return checkCFunc(__index.SetFrameBuffer)
              end,
              SetFrameLevel = function()
                return checkCFunc(__index.SetFrameLevel)
              end,
              SetFrameStrata = function()
                return checkCFunc(__index.SetFrameStrata)
              end,
              SetHeight = function()
                return checkCFunc(__index.SetHeight)
              end,
              SetHighlightAtlas = function()
                return checkCFunc(__index.SetHighlightAtlas)
              end,
              SetHighlightFontObject = function()
                return checkCFunc(__index.SetHighlightFontObject)
              end,
              SetHighlightTexture = function()
                return checkCFunc(__index.SetHighlightTexture)
              end,
              SetHitRectInsets = function()
                return checkCFunc(__index.SetHitRectInsets)
              end,
              SetHyperlinksEnabled = function()
                return checkCFunc(__index.SetHyperlinksEnabled)
              end,
              SetID = function()
                return checkCFunc(__index.SetID)
              end,
              SetIgnoreParentAlpha = function()
                return checkCFunc(__index.SetIgnoreParentAlpha)
              end,
              SetIgnoreParentScale = function()
                return checkCFunc(__index.SetIgnoreParentScale)
              end,
              SetMaxResize = function()
                return checkCFunc(__index.SetMaxResize)
              end,
              SetMinResize = function()
                return checkCFunc(__index.SetMinResize)
              end,
              SetMotionScriptsWhileDisabled = function()
                return checkCFunc(__index.SetMotionScriptsWhileDisabled)
              end,
              SetMouseClickEnabled = function()
                return checkCFunc(__index.SetMouseClickEnabled)
              end,
              SetMouseMotionEnabled = function()
                return checkCFunc(__index.SetMouseMotionEnabled)
              end,
              SetMovable = function()
                return checkCFunc(__index.SetMovable)
              end,
              SetNormalAtlas = function()
                return checkCFunc(__index.SetNormalAtlas)
              end,
              SetNormalFontObject = function()
                return checkCFunc(__index.SetNormalFontObject)
              end,
              SetNormalTexture = function()
                return checkCFunc(__index.SetNormalTexture)
              end,
              SetParent = function()
                return checkCFunc(__index.SetParent)
              end,
              SetPoint = function()
                return checkCFunc(__index.SetPoint)
              end,
              SetPropagateKeyboardInput = function()
                return checkCFunc(__index.SetPropagateKeyboardInput)
              end,
              SetPushedAtlas = function()
                return checkCFunc(__index.SetPushedAtlas)
              end,
              SetPushedTextOffset = function()
                return checkCFunc(__index.SetPushedTextOffset)
              end,
              SetPushedTexture = function()
                return checkCFunc(__index.SetPushedTexture)
              end,
              SetResizable = function()
                return checkCFunc(__index.SetResizable)
              end,
              SetScale = function()
                return checkCFunc(__index.SetScale)
              end,
              SetScript = function()
                return checkCFunc(__index.SetScript)
              end,
              SetShown = function()
                return checkCFunc(__index.SetShown)
              end,
              SetSize = function()
                return checkCFunc(__index.SetSize)
              end,
              SetText = function()
                return checkCFunc(__index.SetText)
              end,
              SetToplevel = function()
                return checkCFunc(__index.SetToplevel)
              end,
              SetUserPlaced = function()
                return checkCFunc(__index.SetUserPlaced)
              end,
              SetWidth = function()
                return checkCFunc(__index.SetWidth)
              end,
              Show = function()
                return checkCFunc(__index.Show)
              end,
              StartMoving = function()
                return checkCFunc(__index.StartMoving)
              end,
              StartSizing = function()
                return checkCFunc(__index.StartSizing)
              end,
              StopAnimating = function()
                return checkCFunc(__index.StopAnimating)
              end,
              StopMovingOrSizing = function()
                return checkCFunc(__index.StopMovingOrSizing)
              end,
              UnlockHighlight = function()
                return checkCFunc(__index.UnlockHighlight)
              end,
              UnregisterAllEvents = function()
                return checkCFunc(__index.UnregisterAllEvents)
              end,
              UnregisterEvent = function()
                return checkCFunc(__index.UnregisterEvent)
              end,
            }
          end)
        end,
        Checkout = function()
          local function factory()
            return assertCreateFrame('Checkout')
          end
          return mkTests('BlizzardCheckout', factory, function(__index)
            return {
              AdjustPointsOffset = function()
                return checkCFunc(__index.AdjustPointsOffset)
              end,
              CanChangeAttribute = function()
                return checkCFunc(__index.CanChangeAttribute)
              end,
              CanChangeProtectedState = function()
                return checkCFunc(__index.CanChangeProtectedState)
              end,
              CancelOpenCheckout = function()
                return checkCFunc(__index.CancelOpenCheckout)
              end,
              ClearAllPoints = function()
                return checkCFunc(__index.ClearAllPoints)
              end,
              ClearFocus = function()
                return checkCFunc(__index.ClearFocus)
              end,
              ClearPointByName = function()
                return checkCFunc(__index.ClearPointByName)
              end,
              ClearPointsOffset = function()
                return checkCFunc(__index.ClearPointsOffset)
              end,
              CloseCheckout = function()
                return checkCFunc(__index.CloseCheckout)
              end,
              CopyExternalLink = function()
                return checkCFunc(__index.CopyExternalLink)
              end,
              CreateAnimationGroup = function()
                return checkCFunc(__index.CreateAnimationGroup)
              end,
              CreateFontString = function()
                return checkCFunc(__index.CreateFontString)
              end,
              CreateLine = function()
                return checkCFunc(__index.CreateLine)
              end,
              CreateMaskTexture = function()
                return checkCFunc(__index.CreateMaskTexture)
              end,
              CreateTexture = function()
                return checkCFunc(__index.CreateTexture)
              end,
              DesaturateHierarchy = function()
                return checkCFunc(__index.DesaturateHierarchy)
              end,
              DisableDrawLayer = function()
                return checkCFunc(__index.DisableDrawLayer)
              end,
              DoesClipChildren = function()
                return checkCFunc(__index.DoesClipChildren)
              end,
              EnableDrawLayer = function()
                return checkCFunc(__index.EnableDrawLayer)
              end,
              EnableGamePadButton = function()
                return checkCFunc(__index.EnableGamePadButton)
              end,
              EnableGamePadStick = function()
                return checkCFunc(__index.EnableGamePadStick)
              end,
              EnableKeyboard = function()
                return checkCFunc(__index.EnableKeyboard)
              end,
              EnableMouse = function()
                return checkCFunc(__index.EnableMouse)
              end,
              EnableMouseWheel = function()
                return checkCFunc(__index.EnableMouseWheel)
              end,
              ExecuteAttribute = function()
                return checkCFunc(__index.ExecuteAttribute)
              end,
              GetAlpha = function()
                return checkCFunc(__index.GetAlpha)
              end,
              GetAnimationGroups = function()
                return checkCFunc(__index.GetAnimationGroups)
              end,
              GetAttribute = function()
                return checkCFunc(__index.GetAttribute)
              end,
              GetBottom = function()
                return checkCFunc(__index.GetBottom)
              end,
              GetBoundsRect = function()
                return checkCFunc(__index.GetBoundsRect)
              end,
              GetCenter = function()
                return checkCFunc(__index.GetCenter)
              end,
              GetChildren = function()
                return checkCFunc(__index.GetChildren)
              end,
              GetClampRectInsets = function()
                return checkCFunc(__index.GetClampRectInsets)
              end,
              GetDebugName = function()
                return checkCFunc(__index.GetDebugName)
              end,
              GetDepth = function()
                return checkCFunc(__index.GetDepth)
              end,
              GetDontSavePosition = function()
                return checkCFunc(__index.GetDontSavePosition)
              end,
              GetEffectiveAlpha = function()
                return checkCFunc(__index.GetEffectiveAlpha)
              end,
              GetEffectiveDepth = function()
                return checkCFunc(__index.GetEffectiveDepth)
              end,
              GetEffectiveScale = function()
                return checkCFunc(__index.GetEffectiveScale)
              end,
              GetEffectivelyFlattensRenderLayers = function()
                return checkCFunc(__index.GetEffectivelyFlattensRenderLayers)
              end,
              GetFlattensRenderLayers = function()
                return checkCFunc(__index.GetFlattensRenderLayers)
              end,
              GetFrameLevel = function()
                return checkCFunc(__index.GetFrameLevel)
              end,
              GetFrameStrata = function()
                return checkCFunc(__index.GetFrameStrata)
              end,
              GetHeight = function()
                return checkCFunc(__index.GetHeight)
              end,
              GetHitRectInsets = function()
                return checkCFunc(__index.GetHitRectInsets)
              end,
              GetHyperlinksEnabled = function()
                return checkCFunc(__index.GetHyperlinksEnabled)
              end,
              GetID = function()
                return checkCFunc(__index.GetID)
              end,
              GetLeft = function()
                return checkCFunc(__index.GetLeft)
              end,
              GetMaxResize = function()
                return checkCFunc(__index.GetMaxResize)
              end,
              GetMinResize = function()
                return checkCFunc(__index.GetMinResize)
              end,
              GetName = function()
                return checkCFunc(__index.GetName)
              end,
              GetNumChildren = function()
                return checkCFunc(__index.GetNumChildren)
              end,
              GetNumPoints = function()
                return checkCFunc(__index.GetNumPoints)
              end,
              GetNumRegions = function()
                return checkCFunc(__index.GetNumRegions)
              end,
              GetObjectType = function()
                return checkCFunc(__index.GetObjectType)
              end,
              GetParent = function()
                return checkCFunc(__index.GetParent)
              end,
              GetPoint = function()
                return checkCFunc(__index.GetPoint)
              end,
              GetPointByName = function()
                return checkCFunc(__index.GetPointByName)
              end,
              GetPropagateKeyboardInput = function()
                return checkCFunc(__index.GetPropagateKeyboardInput)
              end,
              GetRect = function()
                return checkCFunc(__index.GetRect)
              end,
              GetRegions = function()
                return checkCFunc(__index.GetRegions)
              end,
              GetRight = function()
                return checkCFunc(__index.GetRight)
              end,
              GetScale = function()
                return checkCFunc(__index.GetScale)
              end,
              GetScaledRect = function()
                return checkCFunc(__index.GetScaledRect)
              end,
              GetScript = function()
                return checkCFunc(__index.GetScript)
              end,
              GetSize = function()
                return checkCFunc(__index.GetSize)
              end,
              GetSourceLocation = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetSourceLocation))
                  return
                end
                return checkCFunc(__index.GetSourceLocation)
              end,
              GetTop = function()
                return checkCFunc(__index.GetTop)
              end,
              GetWidth = function()
                return checkCFunc(__index.GetWidth)
              end,
              HasFixedFrameLevel = function()
                return checkCFunc(__index.HasFixedFrameLevel)
              end,
              HasFixedFrameStrata = function()
                return checkCFunc(__index.HasFixedFrameStrata)
              end,
              HasScript = function()
                return checkCFunc(__index.HasScript)
              end,
              Hide = function()
                return checkCFunc(__index.Hide)
              end,
              HookScript = function()
                return checkCFunc(__index.HookScript)
              end,
              IgnoreDepth = function()
                return checkCFunc(__index.IgnoreDepth)
              end,
              IsAnchoringRestricted = function()
                return checkCFunc(__index.IsAnchoringRestricted)
              end,
              IsClampedToScreen = function()
                return checkCFunc(__index.IsClampedToScreen)
              end,
              IsDragging = function()
                return checkCFunc(__index.IsDragging)
              end,
              IsEventRegistered = function()
                return checkCFunc(__index.IsEventRegistered)
              end,
              IsForbidden = function()
                return checkCFunc(__index.IsForbidden)
              end,
              IsGamePadButtonEnabled = function()
                return checkCFunc(__index.IsGamePadButtonEnabled)
              end,
              IsGamePadStickEnabled = function()
                return checkCFunc(__index.IsGamePadStickEnabled)
              end,
              IsIgnoringDepth = function()
                return checkCFunc(__index.IsIgnoringDepth)
              end,
              IsIgnoringParentAlpha = function()
                return checkCFunc(__index.IsIgnoringParentAlpha)
              end,
              IsIgnoringParentScale = function()
                return checkCFunc(__index.IsIgnoringParentScale)
              end,
              IsKeyboardEnabled = function()
                return checkCFunc(__index.IsKeyboardEnabled)
              end,
              IsMouseClickEnabled = function()
                return checkCFunc(__index.IsMouseClickEnabled)
              end,
              IsMouseEnabled = function()
                return checkCFunc(__index.IsMouseEnabled)
              end,
              IsMouseMotionEnabled = function()
                return checkCFunc(__index.IsMouseMotionEnabled)
              end,
              IsMouseOver = function()
                return checkCFunc(__index.IsMouseOver)
              end,
              IsMouseWheelEnabled = function()
                return checkCFunc(__index.IsMouseWheelEnabled)
              end,
              IsMovable = function()
                return checkCFunc(__index.IsMovable)
              end,
              IsObjectLoaded = function()
                return checkCFunc(__index.IsObjectLoaded)
              end,
              IsObjectType = function()
                return checkCFunc(__index.IsObjectType)
              end,
              IsProtected = function()
                return checkCFunc(__index.IsProtected)
              end,
              IsRectValid = function()
                return checkCFunc(__index.IsRectValid)
              end,
              IsResizable = function()
                return checkCFunc(__index.IsResizable)
              end,
              IsShown = function()
                return checkCFunc(__index.IsShown)
              end,
              IsToplevel = function()
                return checkCFunc(__index.IsToplevel)
              end,
              IsUserPlaced = function()
                return checkCFunc(__index.IsUserPlaced)
              end,
              IsVisible = function()
                return checkCFunc(__index.IsVisible)
              end,
              Lower = function()
                return checkCFunc(__index.Lower)
              end,
              OpenCheckout = function()
                return checkCFunc(__index.OpenCheckout)
              end,
              OpenExternalLink = function()
                return checkCFunc(__index.OpenExternalLink)
              end,
              Raise = function()
                return checkCFunc(__index.Raise)
              end,
              RegisterAllEvents = function()
                return checkCFunc(__index.RegisterAllEvents)
              end,
              RegisterEvent = function()
                return checkCFunc(__index.RegisterEvent)
              end,
              RegisterForDrag = function()
                return checkCFunc(__index.RegisterForDrag)
              end,
              RegisterUnitEvent = function()
                return checkCFunc(__index.RegisterUnitEvent)
              end,
              RotateTextures = function()
                return checkCFunc(__index.RotateTextures)
              end,
              SetAllPoints = function()
                return checkCFunc(__index.SetAllPoints)
              end,
              SetAlpha = function()
                return checkCFunc(__index.SetAlpha)
              end,
              SetAttribute = function()
                return checkCFunc(__index.SetAttribute)
              end,
              SetAttributeNoHandler = function()
                return checkCFunc(__index.SetAttributeNoHandler)
              end,
              SetClampRectInsets = function()
                return checkCFunc(__index.SetClampRectInsets)
              end,
              SetClampedToScreen = function()
                return checkCFunc(__index.SetClampedToScreen)
              end,
              SetClipsChildren = function()
                return checkCFunc(__index.SetClipsChildren)
              end,
              SetDepth = function()
                return checkCFunc(__index.SetDepth)
              end,
              SetDontSavePosition = function()
                return checkCFunc(__index.SetDontSavePosition)
              end,
              SetDrawLayerEnabled = function()
                return checkCFunc(__index.SetDrawLayerEnabled)
              end,
              SetFixedFrameLevel = function()
                return checkCFunc(__index.SetFixedFrameLevel)
              end,
              SetFixedFrameStrata = function()
                return checkCFunc(__index.SetFixedFrameStrata)
              end,
              SetFlattensRenderLayers = function()
                return checkCFunc(__index.SetFlattensRenderLayers)
              end,
              SetFocus = function()
                return checkCFunc(__index.SetFocus)
              end,
              SetForbidden = function()
                return checkCFunc(__index.SetForbidden)
              end,
              SetFrameBuffer = function()
                return checkCFunc(__index.SetFrameBuffer)
              end,
              SetFrameLevel = function()
                return checkCFunc(__index.SetFrameLevel)
              end,
              SetFrameStrata = function()
                return checkCFunc(__index.SetFrameStrata)
              end,
              SetHeight = function()
                return checkCFunc(__index.SetHeight)
              end,
              SetHitRectInsets = function()
                return checkCFunc(__index.SetHitRectInsets)
              end,
              SetHyperlinksEnabled = function()
                return checkCFunc(__index.SetHyperlinksEnabled)
              end,
              SetID = function()
                return checkCFunc(__index.SetID)
              end,
              SetIgnoreParentAlpha = function()
                return checkCFunc(__index.SetIgnoreParentAlpha)
              end,
              SetIgnoreParentScale = function()
                return checkCFunc(__index.SetIgnoreParentScale)
              end,
              SetMaxResize = function()
                return checkCFunc(__index.SetMaxResize)
              end,
              SetMinResize = function()
                return checkCFunc(__index.SetMinResize)
              end,
              SetMouseClickEnabled = function()
                return checkCFunc(__index.SetMouseClickEnabled)
              end,
              SetMouseMotionEnabled = function()
                return checkCFunc(__index.SetMouseMotionEnabled)
              end,
              SetMovable = function()
                return checkCFunc(__index.SetMovable)
              end,
              SetParent = function()
                return checkCFunc(__index.SetParent)
              end,
              SetPoint = function()
                return checkCFunc(__index.SetPoint)
              end,
              SetPropagateKeyboardInput = function()
                return checkCFunc(__index.SetPropagateKeyboardInput)
              end,
              SetResizable = function()
                return checkCFunc(__index.SetResizable)
              end,
              SetScale = function()
                return checkCFunc(__index.SetScale)
              end,
              SetScript = function()
                return checkCFunc(__index.SetScript)
              end,
              SetShown = function()
                return checkCFunc(__index.SetShown)
              end,
              SetSize = function()
                return checkCFunc(__index.SetSize)
              end,
              SetToplevel = function()
                return checkCFunc(__index.SetToplevel)
              end,
              SetUserPlaced = function()
                return checkCFunc(__index.SetUserPlaced)
              end,
              SetWidth = function()
                return checkCFunc(__index.SetWidth)
              end,
              SetZoom = function()
                return checkCFunc(__index.SetZoom)
              end,
              Show = function()
                return checkCFunc(__index.Show)
              end,
              StartMoving = function()
                return checkCFunc(__index.StartMoving)
              end,
              StartSizing = function()
                return checkCFunc(__index.StartSizing)
              end,
              StopAnimating = function()
                return checkCFunc(__index.StopAnimating)
              end,
              StopMovingOrSizing = function()
                return checkCFunc(__index.StopMovingOrSizing)
              end,
              UnregisterAllEvents = function()
                return checkCFunc(__index.UnregisterAllEvents)
              end,
              UnregisterEvent = function()
                return checkCFunc(__index.UnregisterEvent)
              end,
            }
          end)
        end,
        CinematicModel = function()
          local function factory()
            return assertCreateFrame('CinematicModel')
          end
          return mkTests('CinematicModel', factory, function(__index)
            return {
              AdjustPointsOffset = function()
                return checkCFunc(__index.AdjustPointsOffset)
              end,
              AdvanceTime = function()
                return checkCFunc(__index.AdvanceTime)
              end,
              ApplySpellVisualKit = function()
                return checkCFunc(__index.ApplySpellVisualKit)
              end,
              CanChangeAttribute = function()
                return checkCFunc(__index.CanChangeAttribute)
              end,
              CanChangeProtectedState = function()
                return checkCFunc(__index.CanChangeProtectedState)
              end,
              CanSetUnit = function()
                return checkCFunc(__index.CanSetUnit)
              end,
              ClearAllPoints = function()
                return checkCFunc(__index.ClearAllPoints)
              end,
              ClearFog = function()
                return checkCFunc(__index.ClearFog)
              end,
              ClearModel = function()
                return checkCFunc(__index.ClearModel)
              end,
              ClearPointByName = function()
                return checkCFunc(__index.ClearPointByName)
              end,
              ClearPointsOffset = function()
                return checkCFunc(__index.ClearPointsOffset)
              end,
              ClearTransform = function()
                return checkCFunc(__index.ClearTransform)
              end,
              CreateAnimationGroup = function()
                return checkCFunc(__index.CreateAnimationGroup)
              end,
              CreateFontString = function()
                return checkCFunc(__index.CreateFontString)
              end,
              CreateLine = function()
                return checkCFunc(__index.CreateLine)
              end,
              CreateMaskTexture = function()
                return checkCFunc(__index.CreateMaskTexture)
              end,
              CreateTexture = function()
                return checkCFunc(__index.CreateTexture)
              end,
              DesaturateHierarchy = function()
                return checkCFunc(__index.DesaturateHierarchy)
              end,
              DisableDrawLayer = function()
                return checkCFunc(__index.DisableDrawLayer)
              end,
              DoesClipChildren = function()
                return checkCFunc(__index.DoesClipChildren)
              end,
              EnableDrawLayer = function()
                return checkCFunc(__index.EnableDrawLayer)
              end,
              EnableGamePadButton = function()
                return checkCFunc(__index.EnableGamePadButton)
              end,
              EnableGamePadStick = function()
                return checkCFunc(__index.EnableGamePadStick)
              end,
              EnableKeyboard = function()
                return checkCFunc(__index.EnableKeyboard)
              end,
              EnableMouse = function()
                return checkCFunc(__index.EnableMouse)
              end,
              EnableMouseWheel = function()
                return checkCFunc(__index.EnableMouseWheel)
              end,
              EquipItem = function()
                return checkCFunc(__index.EquipItem)
              end,
              ExecuteAttribute = function()
                return checkCFunc(__index.ExecuteAttribute)
              end,
              FreezeAnimation = function()
                return checkCFunc(__index.FreezeAnimation)
              end,
              GetAlpha = function()
                return checkCFunc(__index.GetAlpha)
              end,
              GetAnimationGroups = function()
                return checkCFunc(__index.GetAnimationGroups)
              end,
              GetAttribute = function()
                return checkCFunc(__index.GetAttribute)
              end,
              GetBottom = function()
                return checkCFunc(__index.GetBottom)
              end,
              GetBoundsRect = function()
                return checkCFunc(__index.GetBoundsRect)
              end,
              GetCameraDistance = function()
                return checkCFunc(__index.GetCameraDistance)
              end,
              GetCameraFacing = function()
                return checkCFunc(__index.GetCameraFacing)
              end,
              GetCameraPosition = function()
                return checkCFunc(__index.GetCameraPosition)
              end,
              GetCameraRoll = function()
                return checkCFunc(__index.GetCameraRoll)
              end,
              GetCameraTarget = function()
                return checkCFunc(__index.GetCameraTarget)
              end,
              GetCenter = function()
                return checkCFunc(__index.GetCenter)
              end,
              GetChildren = function()
                return checkCFunc(__index.GetChildren)
              end,
              GetClampRectInsets = function()
                return checkCFunc(__index.GetClampRectInsets)
              end,
              GetDebugName = function()
                return checkCFunc(__index.GetDebugName)
              end,
              GetDepth = function()
                return checkCFunc(__index.GetDepth)
              end,
              GetDesaturation = function()
                return checkCFunc(__index.GetDesaturation)
              end,
              GetDisplayInfo = function()
                return checkCFunc(__index.GetDisplayInfo)
              end,
              GetDoBlend = function()
                return checkCFunc(__index.GetDoBlend)
              end,
              GetDontSavePosition = function()
                return checkCFunc(__index.GetDontSavePosition)
              end,
              GetEffectiveAlpha = function()
                return checkCFunc(__index.GetEffectiveAlpha)
              end,
              GetEffectiveDepth = function()
                return checkCFunc(__index.GetEffectiveDepth)
              end,
              GetEffectiveScale = function()
                return checkCFunc(__index.GetEffectiveScale)
              end,
              GetEffectivelyFlattensRenderLayers = function()
                return checkCFunc(__index.GetEffectivelyFlattensRenderLayers)
              end,
              GetFacing = function()
                return checkCFunc(__index.GetFacing)
              end,
              GetFlattensRenderLayers = function()
                return checkCFunc(__index.GetFlattensRenderLayers)
              end,
              GetFogColor = function()
                return checkCFunc(__index.GetFogColor)
              end,
              GetFogFar = function()
                return checkCFunc(__index.GetFogFar)
              end,
              GetFogNear = function()
                return checkCFunc(__index.GetFogNear)
              end,
              GetFrameLevel = function()
                return checkCFunc(__index.GetFrameLevel)
              end,
              GetFrameStrata = function()
                return checkCFunc(__index.GetFrameStrata)
              end,
              GetHeight = function()
                return checkCFunc(__index.GetHeight)
              end,
              GetHitRectInsets = function()
                return checkCFunc(__index.GetHitRectInsets)
              end,
              GetHyperlinksEnabled = function()
                return checkCFunc(__index.GetHyperlinksEnabled)
              end,
              GetID = function()
                return checkCFunc(__index.GetID)
              end,
              GetKeepModelOnHide = function()
                return checkCFunc(__index.GetKeepModelOnHide)
              end,
              GetLeft = function()
                return checkCFunc(__index.GetLeft)
              end,
              GetLight = function()
                return checkCFunc(__index.GetLight)
              end,
              GetMaxResize = function()
                return checkCFunc(__index.GetMaxResize)
              end,
              GetMinResize = function()
                return checkCFunc(__index.GetMinResize)
              end,
              GetModelAlpha = function()
                return checkCFunc(__index.GetModelAlpha)
              end,
              GetModelDrawLayer = function()
                return checkCFunc(__index.GetModelDrawLayer)
              end,
              GetModelFileID = function()
                return checkCFunc(__index.GetModelFileID)
              end,
              GetModelScale = function()
                return checkCFunc(__index.GetModelScale)
              end,
              GetName = function()
                return checkCFunc(__index.GetName)
              end,
              GetNumChildren = function()
                return checkCFunc(__index.GetNumChildren)
              end,
              GetNumPoints = function()
                return checkCFunc(__index.GetNumPoints)
              end,
              GetNumRegions = function()
                return checkCFunc(__index.GetNumRegions)
              end,
              GetObjectType = function()
                return checkCFunc(__index.GetObjectType)
              end,
              GetParent = function()
                return checkCFunc(__index.GetParent)
              end,
              GetPaused = function()
                return checkCFunc(__index.GetPaused)
              end,
              GetPitch = function()
                return checkCFunc(__index.GetPitch)
              end,
              GetPoint = function()
                return checkCFunc(__index.GetPoint)
              end,
              GetPointByName = function()
                return checkCFunc(__index.GetPointByName)
              end,
              GetPosition = function()
                return checkCFunc(__index.GetPosition)
              end,
              GetPropagateKeyboardInput = function()
                return checkCFunc(__index.GetPropagateKeyboardInput)
              end,
              GetRect = function()
                return checkCFunc(__index.GetRect)
              end,
              GetRegions = function()
                return checkCFunc(__index.GetRegions)
              end,
              GetRight = function()
                return checkCFunc(__index.GetRight)
              end,
              GetRoll = function()
                return checkCFunc(__index.GetRoll)
              end,
              GetScale = function()
                return checkCFunc(__index.GetScale)
              end,
              GetScaledRect = function()
                return checkCFunc(__index.GetScaledRect)
              end,
              GetScript = function()
                return checkCFunc(__index.GetScript)
              end,
              GetShadowEffect = function()
                return checkCFunc(__index.GetShadowEffect)
              end,
              GetSize = function()
                return checkCFunc(__index.GetSize)
              end,
              GetSourceLocation = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetSourceLocation))
                  return
                end
                return checkCFunc(__index.GetSourceLocation)
              end,
              GetTop = function()
                return checkCFunc(__index.GetTop)
              end,
              GetViewInsets = function()
                return checkCFunc(__index.GetViewInsets)
              end,
              GetViewTranslation = function()
                return checkCFunc(__index.GetViewTranslation)
              end,
              GetWidth = function()
                return checkCFunc(__index.GetWidth)
              end,
              GetWorldScale = function()
                return checkCFunc(__index.GetWorldScale)
              end,
              HasAnimation = function()
                return checkCFunc(__index.HasAnimation)
              end,
              HasAttachmentPoints = function()
                return checkCFunc(__index.HasAttachmentPoints)
              end,
              HasCustomCamera = function()
                return checkCFunc(__index.HasCustomCamera)
              end,
              HasFixedFrameLevel = function()
                return checkCFunc(__index.HasFixedFrameLevel)
              end,
              HasFixedFrameStrata = function()
                return checkCFunc(__index.HasFixedFrameStrata)
              end,
              HasScript = function()
                return checkCFunc(__index.HasScript)
              end,
              Hide = function()
                return checkCFunc(__index.Hide)
              end,
              HookScript = function()
                return checkCFunc(__index.HookScript)
              end,
              IgnoreDepth = function()
                return checkCFunc(__index.IgnoreDepth)
              end,
              InitializeCamera = function()
                return checkCFunc(__index.InitializeCamera)
              end,
              InitializePanCamera = function()
                return checkCFunc(__index.InitializePanCamera)
              end,
              IsAnchoringRestricted = function()
                return checkCFunc(__index.IsAnchoringRestricted)
              end,
              IsClampedToScreen = function()
                return checkCFunc(__index.IsClampedToScreen)
              end,
              IsDragging = function()
                return checkCFunc(__index.IsDragging)
              end,
              IsEventRegistered = function()
                return checkCFunc(__index.IsEventRegistered)
              end,
              IsForbidden = function()
                return checkCFunc(__index.IsForbidden)
              end,
              IsGamePadButtonEnabled = function()
                return checkCFunc(__index.IsGamePadButtonEnabled)
              end,
              IsGamePadStickEnabled = function()
                return checkCFunc(__index.IsGamePadStickEnabled)
              end,
              IsIgnoringDepth = function()
                return checkCFunc(__index.IsIgnoringDepth)
              end,
              IsIgnoringParentAlpha = function()
                return checkCFunc(__index.IsIgnoringParentAlpha)
              end,
              IsIgnoringParentScale = function()
                return checkCFunc(__index.IsIgnoringParentScale)
              end,
              IsKeyboardEnabled = function()
                return checkCFunc(__index.IsKeyboardEnabled)
              end,
              IsMouseClickEnabled = function()
                return checkCFunc(__index.IsMouseClickEnabled)
              end,
              IsMouseEnabled = function()
                return checkCFunc(__index.IsMouseEnabled)
              end,
              IsMouseMotionEnabled = function()
                return checkCFunc(__index.IsMouseMotionEnabled)
              end,
              IsMouseOver = function()
                return checkCFunc(__index.IsMouseOver)
              end,
              IsMouseWheelEnabled = function()
                return checkCFunc(__index.IsMouseWheelEnabled)
              end,
              IsMovable = function()
                return checkCFunc(__index.IsMovable)
              end,
              IsObjectLoaded = function()
                return checkCFunc(__index.IsObjectLoaded)
              end,
              IsObjectType = function()
                return checkCFunc(__index.IsObjectType)
              end,
              IsProtected = function()
                return checkCFunc(__index.IsProtected)
              end,
              IsRectValid = function()
                return checkCFunc(__index.IsRectValid)
              end,
              IsResizable = function()
                return checkCFunc(__index.IsResizable)
              end,
              IsShown = function()
                return checkCFunc(__index.IsShown)
              end,
              IsToplevel = function()
                return checkCFunc(__index.IsToplevel)
              end,
              IsUserPlaced = function()
                return checkCFunc(__index.IsUserPlaced)
              end,
              IsUsingModelCenterToTransform = function()
                return checkCFunc(__index.IsUsingModelCenterToTransform)
              end,
              IsVisible = function()
                return checkCFunc(__index.IsVisible)
              end,
              Lower = function()
                return checkCFunc(__index.Lower)
              end,
              MakeCurrentCameraCustom = function()
                return checkCFunc(__index.MakeCurrentCameraCustom)
              end,
              PlayAnimKit = function()
                return checkCFunc(__index.PlayAnimKit)
              end,
              Raise = function()
                return checkCFunc(__index.Raise)
              end,
              RefreshCamera = function()
                return checkCFunc(__index.RefreshCamera)
              end,
              RefreshUnit = function()
                return checkCFunc(__index.RefreshUnit)
              end,
              RegisterAllEvents = function()
                return checkCFunc(__index.RegisterAllEvents)
              end,
              RegisterEvent = function()
                return checkCFunc(__index.RegisterEvent)
              end,
              RegisterForDrag = function()
                return checkCFunc(__index.RegisterForDrag)
              end,
              RegisterUnitEvent = function()
                return checkCFunc(__index.RegisterUnitEvent)
              end,
              ReplaceIconTexture = function()
                return checkCFunc(__index.ReplaceIconTexture)
              end,
              RotateTextures = function()
                return checkCFunc(__index.RotateTextures)
              end,
              SetAllPoints = function()
                return checkCFunc(__index.SetAllPoints)
              end,
              SetAlpha = function()
                return checkCFunc(__index.SetAlpha)
              end,
              SetAnimOffset = function()
                return checkCFunc(__index.SetAnimOffset)
              end,
              SetAnimation = function()
                return checkCFunc(__index.SetAnimation)
              end,
              SetAttribute = function()
                return checkCFunc(__index.SetAttribute)
              end,
              SetAttributeNoHandler = function()
                return checkCFunc(__index.SetAttributeNoHandler)
              end,
              SetBarberShopAlternateForm = function()
                return checkCFunc(__index.SetBarberShopAlternateForm)
              end,
              SetCamDistanceScale = function()
                return checkCFunc(__index.SetCamDistanceScale)
              end,
              SetCamera = function()
                return checkCFunc(__index.SetCamera)
              end,
              SetCameraDistance = function()
                return checkCFunc(__index.SetCameraDistance)
              end,
              SetCameraFacing = function()
                return checkCFunc(__index.SetCameraFacing)
              end,
              SetCameraPosition = function()
                return checkCFunc(__index.SetCameraPosition)
              end,
              SetCameraRoll = function()
                return checkCFunc(__index.SetCameraRoll)
              end,
              SetCameraTarget = function()
                return checkCFunc(__index.SetCameraTarget)
              end,
              SetClampRectInsets = function()
                return checkCFunc(__index.SetClampRectInsets)
              end,
              SetClampedToScreen = function()
                return checkCFunc(__index.SetClampedToScreen)
              end,
              SetClipsChildren = function()
                return checkCFunc(__index.SetClipsChildren)
              end,
              SetCreature = function()
                return checkCFunc(__index.SetCreature)
              end,
              SetCreatureData = function()
                return checkCFunc(__index.SetCreatureData)
              end,
              SetCustomCamera = function()
                return checkCFunc(__index.SetCustomCamera)
              end,
              SetCustomRace = function()
                return checkCFunc(__index.SetCustomRace)
              end,
              SetDepth = function()
                return checkCFunc(__index.SetDepth)
              end,
              SetDesaturation = function()
                return checkCFunc(__index.SetDesaturation)
              end,
              SetDisplayInfo = function()
                return checkCFunc(__index.SetDisplayInfo)
              end,
              SetDoBlend = function()
                return checkCFunc(__index.SetDoBlend)
              end,
              SetDontSavePosition = function()
                return checkCFunc(__index.SetDontSavePosition)
              end,
              SetDrawLayerEnabled = function()
                return checkCFunc(__index.SetDrawLayerEnabled)
              end,
              SetFacing = function()
                return checkCFunc(__index.SetFacing)
              end,
              SetFacingLeft = function()
                return checkCFunc(__index.SetFacingLeft)
              end,
              SetFadeTimes = function()
                return checkCFunc(__index.SetFadeTimes)
              end,
              SetFixedFrameLevel = function()
                return checkCFunc(__index.SetFixedFrameLevel)
              end,
              SetFixedFrameStrata = function()
                return checkCFunc(__index.SetFixedFrameStrata)
              end,
              SetFlattensRenderLayers = function()
                return checkCFunc(__index.SetFlattensRenderLayers)
              end,
              SetFogColor = function()
                return checkCFunc(__index.SetFogColor)
              end,
              SetFogFar = function()
                return checkCFunc(__index.SetFogFar)
              end,
              SetFogNear = function()
                return checkCFunc(__index.SetFogNear)
              end,
              SetForbidden = function()
                return checkCFunc(__index.SetForbidden)
              end,
              SetFrameBuffer = function()
                return checkCFunc(__index.SetFrameBuffer)
              end,
              SetFrameLevel = function()
                return checkCFunc(__index.SetFrameLevel)
              end,
              SetFrameStrata = function()
                return checkCFunc(__index.SetFrameStrata)
              end,
              SetGlow = function()
                return checkCFunc(__index.SetGlow)
              end,
              SetHeight = function()
                return checkCFunc(__index.SetHeight)
              end,
              SetHeightFactor = function()
                return checkCFunc(__index.SetHeightFactor)
              end,
              SetHitRectInsets = function()
                return checkCFunc(__index.SetHitRectInsets)
              end,
              SetHyperlinksEnabled = function()
                return checkCFunc(__index.SetHyperlinksEnabled)
              end,
              SetID = function()
                return checkCFunc(__index.SetID)
              end,
              SetIgnoreParentAlpha = function()
                return checkCFunc(__index.SetIgnoreParentAlpha)
              end,
              SetIgnoreParentScale = function()
                return checkCFunc(__index.SetIgnoreParentScale)
              end,
              SetItem = function()
                return checkCFunc(__index.SetItem)
              end,
              SetItemAppearance = function()
                return checkCFunc(__index.SetItemAppearance)
              end,
              SetJumpInfo = function()
                return checkCFunc(__index.SetJumpInfo)
              end,
              SetKeepModelOnHide = function()
                return checkCFunc(__index.SetKeepModelOnHide)
              end,
              SetLight = function()
                return checkCFunc(__index.SetLight)
              end,
              SetMaxResize = function()
                return checkCFunc(__index.SetMaxResize)
              end,
              SetMinResize = function()
                return checkCFunc(__index.SetMinResize)
              end,
              SetModel = function()
                return checkCFunc(__index.SetModel)
              end,
              SetModelAlpha = function()
                return checkCFunc(__index.SetModelAlpha)
              end,
              SetModelDrawLayer = function()
                return checkCFunc(__index.SetModelDrawLayer)
              end,
              SetModelScale = function()
                return checkCFunc(__index.SetModelScale)
              end,
              SetMouseClickEnabled = function()
                return checkCFunc(__index.SetMouseClickEnabled)
              end,
              SetMouseMotionEnabled = function()
                return checkCFunc(__index.SetMouseMotionEnabled)
              end,
              SetMovable = function()
                return checkCFunc(__index.SetMovable)
              end,
              SetPanDistance = function()
                return checkCFunc(__index.SetPanDistance)
              end,
              SetParent = function()
                return checkCFunc(__index.SetParent)
              end,
              SetParticlesEnabled = function()
                return checkCFunc(__index.SetParticlesEnabled)
              end,
              SetPaused = function()
                return checkCFunc(__index.SetPaused)
              end,
              SetPitch = function()
                return checkCFunc(__index.SetPitch)
              end,
              SetPoint = function()
                return checkCFunc(__index.SetPoint)
              end,
              SetPortraitZoom = function()
                return checkCFunc(__index.SetPortraitZoom)
              end,
              SetPosition = function()
                return checkCFunc(__index.SetPosition)
              end,
              SetPropagateKeyboardInput = function()
                return checkCFunc(__index.SetPropagateKeyboardInput)
              end,
              SetResizable = function()
                return checkCFunc(__index.SetResizable)
              end,
              SetRoll = function()
                return checkCFunc(__index.SetRoll)
              end,
              SetRotation = function()
                return checkCFunc(__index.SetRotation)
              end,
              SetScale = function()
                return checkCFunc(__index.SetScale)
              end,
              SetScript = function()
                return checkCFunc(__index.SetScript)
              end,
              SetSequence = function()
                return checkCFunc(__index.SetSequence)
              end,
              SetSequenceTime = function()
                return checkCFunc(__index.SetSequenceTime)
              end,
              SetShadowEffect = function()
                return checkCFunc(__index.SetShadowEffect)
              end,
              SetShown = function()
                return checkCFunc(__index.SetShown)
              end,
              SetSize = function()
                return checkCFunc(__index.SetSize)
              end,
              SetSpellVisualKit = function()
                return checkCFunc(__index.SetSpellVisualKit)
              end,
              SetTargetDistance = function()
                return checkCFunc(__index.SetTargetDistance)
              end,
              SetToplevel = function()
                return checkCFunc(__index.SetToplevel)
              end,
              SetTransform = function()
                return checkCFunc(__index.SetTransform)
              end,
              SetUnit = function()
                return checkCFunc(__index.SetUnit)
              end,
              SetUserPlaced = function()
                return checkCFunc(__index.SetUserPlaced)
              end,
              SetViewInsets = function()
                return checkCFunc(__index.SetViewInsets)
              end,
              SetViewTranslation = function()
                return checkCFunc(__index.SetViewTranslation)
              end,
              SetWidth = function()
                return checkCFunc(__index.SetWidth)
              end,
              Show = function()
                return checkCFunc(__index.Show)
              end,
              StartMoving = function()
                return checkCFunc(__index.StartMoving)
              end,
              StartPan = function()
                return checkCFunc(__index.StartPan)
              end,
              StartSizing = function()
                return checkCFunc(__index.StartSizing)
              end,
              StopAnimKit = function()
                return checkCFunc(__index.StopAnimKit)
              end,
              StopAnimating = function()
                return checkCFunc(__index.StopAnimating)
              end,
              StopMovingOrSizing = function()
                return checkCFunc(__index.StopMovingOrSizing)
              end,
              StopPan = function()
                return checkCFunc(__index.StopPan)
              end,
              TransformCameraSpaceToModelSpace = function()
                return checkCFunc(__index.TransformCameraSpaceToModelSpace)
              end,
              UnequipItems = function()
                return checkCFunc(__index.UnequipItems)
              end,
              UnregisterAllEvents = function()
                return checkCFunc(__index.UnregisterAllEvents)
              end,
              UnregisterEvent = function()
                return checkCFunc(__index.UnregisterEvent)
              end,
              UseModelCenterToTransform = function()
                return checkCFunc(__index.UseModelCenterToTransform)
              end,
              ZeroCachedCenterXY = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.ZeroCachedCenterXY))
                  return
                end
                return checkCFunc(__index.ZeroCachedCenterXY)
              end,
            }
          end)
        end,
        ColorSelect = function()
          local function factory()
            return assertCreateFrame('ColorSelect')
          end
          return mkTests('ColorSelect', factory, function(__index)
            return {
              AdjustPointsOffset = function()
                return checkCFunc(__index.AdjustPointsOffset)
              end,
              CanChangeAttribute = function()
                return checkCFunc(__index.CanChangeAttribute)
              end,
              CanChangeProtectedState = function()
                return checkCFunc(__index.CanChangeProtectedState)
              end,
              ClearAllPoints = function()
                return checkCFunc(__index.ClearAllPoints)
              end,
              ClearPointByName = function()
                return checkCFunc(__index.ClearPointByName)
              end,
              ClearPointsOffset = function()
                return checkCFunc(__index.ClearPointsOffset)
              end,
              CreateAnimationGroup = function()
                return checkCFunc(__index.CreateAnimationGroup)
              end,
              CreateFontString = function()
                return checkCFunc(__index.CreateFontString)
              end,
              CreateLine = function()
                return checkCFunc(__index.CreateLine)
              end,
              CreateMaskTexture = function()
                return checkCFunc(__index.CreateMaskTexture)
              end,
              CreateTexture = function()
                return checkCFunc(__index.CreateTexture)
              end,
              DesaturateHierarchy = function()
                return checkCFunc(__index.DesaturateHierarchy)
              end,
              DisableDrawLayer = function()
                return checkCFunc(__index.DisableDrawLayer)
              end,
              DoesClipChildren = function()
                return checkCFunc(__index.DoesClipChildren)
              end,
              EnableDrawLayer = function()
                return checkCFunc(__index.EnableDrawLayer)
              end,
              EnableGamePadButton = function()
                return checkCFunc(__index.EnableGamePadButton)
              end,
              EnableGamePadStick = function()
                return checkCFunc(__index.EnableGamePadStick)
              end,
              EnableKeyboard = function()
                return checkCFunc(__index.EnableKeyboard)
              end,
              EnableMouse = function()
                return checkCFunc(__index.EnableMouse)
              end,
              EnableMouseWheel = function()
                return checkCFunc(__index.EnableMouseWheel)
              end,
              ExecuteAttribute = function()
                return checkCFunc(__index.ExecuteAttribute)
              end,
              GetAlpha = function()
                return checkCFunc(__index.GetAlpha)
              end,
              GetAnimationGroups = function()
                return checkCFunc(__index.GetAnimationGroups)
              end,
              GetAttribute = function()
                return checkCFunc(__index.GetAttribute)
              end,
              GetBottom = function()
                return checkCFunc(__index.GetBottom)
              end,
              GetBoundsRect = function()
                return checkCFunc(__index.GetBoundsRect)
              end,
              GetCenter = function()
                return checkCFunc(__index.GetCenter)
              end,
              GetChildren = function()
                return checkCFunc(__index.GetChildren)
              end,
              GetClampRectInsets = function()
                return checkCFunc(__index.GetClampRectInsets)
              end,
              GetColorHSV = function()
                return checkCFunc(__index.GetColorHSV)
              end,
              GetColorRGB = function()
                return checkCFunc(__index.GetColorRGB)
              end,
              GetColorValueTexture = function()
                return checkCFunc(__index.GetColorValueTexture)
              end,
              GetColorValueThumbTexture = function()
                return checkCFunc(__index.GetColorValueThumbTexture)
              end,
              GetColorWheelTexture = function()
                return checkCFunc(__index.GetColorWheelTexture)
              end,
              GetColorWheelThumbTexture = function()
                return checkCFunc(__index.GetColorWheelThumbTexture)
              end,
              GetDebugName = function()
                return checkCFunc(__index.GetDebugName)
              end,
              GetDepth = function()
                return checkCFunc(__index.GetDepth)
              end,
              GetDontSavePosition = function()
                return checkCFunc(__index.GetDontSavePosition)
              end,
              GetEffectiveAlpha = function()
                return checkCFunc(__index.GetEffectiveAlpha)
              end,
              GetEffectiveDepth = function()
                return checkCFunc(__index.GetEffectiveDepth)
              end,
              GetEffectiveScale = function()
                return checkCFunc(__index.GetEffectiveScale)
              end,
              GetEffectivelyFlattensRenderLayers = function()
                return checkCFunc(__index.GetEffectivelyFlattensRenderLayers)
              end,
              GetFlattensRenderLayers = function()
                return checkCFunc(__index.GetFlattensRenderLayers)
              end,
              GetFrameLevel = function()
                return checkCFunc(__index.GetFrameLevel)
              end,
              GetFrameStrata = function()
                return checkCFunc(__index.GetFrameStrata)
              end,
              GetHeight = function()
                return checkCFunc(__index.GetHeight)
              end,
              GetHitRectInsets = function()
                return checkCFunc(__index.GetHitRectInsets)
              end,
              GetHyperlinksEnabled = function()
                return checkCFunc(__index.GetHyperlinksEnabled)
              end,
              GetID = function()
                return checkCFunc(__index.GetID)
              end,
              GetLeft = function()
                return checkCFunc(__index.GetLeft)
              end,
              GetMaxResize = function()
                return checkCFunc(__index.GetMaxResize)
              end,
              GetMinResize = function()
                return checkCFunc(__index.GetMinResize)
              end,
              GetName = function()
                return checkCFunc(__index.GetName)
              end,
              GetNumChildren = function()
                return checkCFunc(__index.GetNumChildren)
              end,
              GetNumPoints = function()
                return checkCFunc(__index.GetNumPoints)
              end,
              GetNumRegions = function()
                return checkCFunc(__index.GetNumRegions)
              end,
              GetObjectType = function()
                return checkCFunc(__index.GetObjectType)
              end,
              GetParent = function()
                return checkCFunc(__index.GetParent)
              end,
              GetPoint = function()
                return checkCFunc(__index.GetPoint)
              end,
              GetPointByName = function()
                return checkCFunc(__index.GetPointByName)
              end,
              GetPropagateKeyboardInput = function()
                return checkCFunc(__index.GetPropagateKeyboardInput)
              end,
              GetRect = function()
                return checkCFunc(__index.GetRect)
              end,
              GetRegions = function()
                return checkCFunc(__index.GetRegions)
              end,
              GetRight = function()
                return checkCFunc(__index.GetRight)
              end,
              GetScale = function()
                return checkCFunc(__index.GetScale)
              end,
              GetScaledRect = function()
                return checkCFunc(__index.GetScaledRect)
              end,
              GetScript = function()
                return checkCFunc(__index.GetScript)
              end,
              GetSize = function()
                return checkCFunc(__index.GetSize)
              end,
              GetSourceLocation = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetSourceLocation))
                  return
                end
                return checkCFunc(__index.GetSourceLocation)
              end,
              GetTop = function()
                return checkCFunc(__index.GetTop)
              end,
              GetWidth = function()
                return checkCFunc(__index.GetWidth)
              end,
              HasFixedFrameLevel = function()
                return checkCFunc(__index.HasFixedFrameLevel)
              end,
              HasFixedFrameStrata = function()
                return checkCFunc(__index.HasFixedFrameStrata)
              end,
              HasScript = function()
                return checkCFunc(__index.HasScript)
              end,
              Hide = function()
                return checkCFunc(__index.Hide)
              end,
              HookScript = function()
                return checkCFunc(__index.HookScript)
              end,
              IgnoreDepth = function()
                return checkCFunc(__index.IgnoreDepth)
              end,
              IsAnchoringRestricted = function()
                return checkCFunc(__index.IsAnchoringRestricted)
              end,
              IsClampedToScreen = function()
                return checkCFunc(__index.IsClampedToScreen)
              end,
              IsDragging = function()
                return checkCFunc(__index.IsDragging)
              end,
              IsEventRegistered = function()
                return checkCFunc(__index.IsEventRegistered)
              end,
              IsForbidden = function()
                return checkCFunc(__index.IsForbidden)
              end,
              IsGamePadButtonEnabled = function()
                return checkCFunc(__index.IsGamePadButtonEnabled)
              end,
              IsGamePadStickEnabled = function()
                return checkCFunc(__index.IsGamePadStickEnabled)
              end,
              IsIgnoringDepth = function()
                return checkCFunc(__index.IsIgnoringDepth)
              end,
              IsIgnoringParentAlpha = function()
                return checkCFunc(__index.IsIgnoringParentAlpha)
              end,
              IsIgnoringParentScale = function()
                return checkCFunc(__index.IsIgnoringParentScale)
              end,
              IsKeyboardEnabled = function()
                return checkCFunc(__index.IsKeyboardEnabled)
              end,
              IsMouseClickEnabled = function()
                return checkCFunc(__index.IsMouseClickEnabled)
              end,
              IsMouseEnabled = function()
                return checkCFunc(__index.IsMouseEnabled)
              end,
              IsMouseMotionEnabled = function()
                return checkCFunc(__index.IsMouseMotionEnabled)
              end,
              IsMouseOver = function()
                return checkCFunc(__index.IsMouseOver)
              end,
              IsMouseWheelEnabled = function()
                return checkCFunc(__index.IsMouseWheelEnabled)
              end,
              IsMovable = function()
                return checkCFunc(__index.IsMovable)
              end,
              IsObjectLoaded = function()
                return checkCFunc(__index.IsObjectLoaded)
              end,
              IsObjectType = function()
                return checkCFunc(__index.IsObjectType)
              end,
              IsProtected = function()
                return checkCFunc(__index.IsProtected)
              end,
              IsRectValid = function()
                return checkCFunc(__index.IsRectValid)
              end,
              IsResizable = function()
                return checkCFunc(__index.IsResizable)
              end,
              IsShown = function()
                return checkCFunc(__index.IsShown)
              end,
              IsToplevel = function()
                return checkCFunc(__index.IsToplevel)
              end,
              IsUserPlaced = function()
                return checkCFunc(__index.IsUserPlaced)
              end,
              IsVisible = function()
                return checkCFunc(__index.IsVisible)
              end,
              Lower = function()
                return checkCFunc(__index.Lower)
              end,
              Raise = function()
                return checkCFunc(__index.Raise)
              end,
              RegisterAllEvents = function()
                return checkCFunc(__index.RegisterAllEvents)
              end,
              RegisterEvent = function()
                return checkCFunc(__index.RegisterEvent)
              end,
              RegisterForDrag = function()
                return checkCFunc(__index.RegisterForDrag)
              end,
              RegisterUnitEvent = function()
                return checkCFunc(__index.RegisterUnitEvent)
              end,
              RotateTextures = function()
                return checkCFunc(__index.RotateTextures)
              end,
              SetAllPoints = function()
                return checkCFunc(__index.SetAllPoints)
              end,
              SetAlpha = function()
                return checkCFunc(__index.SetAlpha)
              end,
              SetAttribute = function()
                return checkCFunc(__index.SetAttribute)
              end,
              SetAttributeNoHandler = function()
                return checkCFunc(__index.SetAttributeNoHandler)
              end,
              SetClampRectInsets = function()
                return checkCFunc(__index.SetClampRectInsets)
              end,
              SetClampedToScreen = function()
                return checkCFunc(__index.SetClampedToScreen)
              end,
              SetClipsChildren = function()
                return checkCFunc(__index.SetClipsChildren)
              end,
              SetColorHSV = function()
                return checkCFunc(__index.SetColorHSV)
              end,
              SetColorRGB = function()
                return checkCFunc(__index.SetColorRGB)
              end,
              SetColorValueTexture = function()
                return checkCFunc(__index.SetColorValueTexture)
              end,
              SetColorValueThumbTexture = function()
                return checkCFunc(__index.SetColorValueThumbTexture)
              end,
              SetColorWheelTexture = function()
                return checkCFunc(__index.SetColorWheelTexture)
              end,
              SetColorWheelThumbTexture = function()
                return checkCFunc(__index.SetColorWheelThumbTexture)
              end,
              SetDepth = function()
                return checkCFunc(__index.SetDepth)
              end,
              SetDontSavePosition = function()
                return checkCFunc(__index.SetDontSavePosition)
              end,
              SetDrawLayerEnabled = function()
                return checkCFunc(__index.SetDrawLayerEnabled)
              end,
              SetFixedFrameLevel = function()
                return checkCFunc(__index.SetFixedFrameLevel)
              end,
              SetFixedFrameStrata = function()
                return checkCFunc(__index.SetFixedFrameStrata)
              end,
              SetFlattensRenderLayers = function()
                return checkCFunc(__index.SetFlattensRenderLayers)
              end,
              SetForbidden = function()
                return checkCFunc(__index.SetForbidden)
              end,
              SetFrameBuffer = function()
                return checkCFunc(__index.SetFrameBuffer)
              end,
              SetFrameLevel = function()
                return checkCFunc(__index.SetFrameLevel)
              end,
              SetFrameStrata = function()
                return checkCFunc(__index.SetFrameStrata)
              end,
              SetHeight = function()
                return checkCFunc(__index.SetHeight)
              end,
              SetHitRectInsets = function()
                return checkCFunc(__index.SetHitRectInsets)
              end,
              SetHyperlinksEnabled = function()
                return checkCFunc(__index.SetHyperlinksEnabled)
              end,
              SetID = function()
                return checkCFunc(__index.SetID)
              end,
              SetIgnoreParentAlpha = function()
                return checkCFunc(__index.SetIgnoreParentAlpha)
              end,
              SetIgnoreParentScale = function()
                return checkCFunc(__index.SetIgnoreParentScale)
              end,
              SetMaxResize = function()
                return checkCFunc(__index.SetMaxResize)
              end,
              SetMinResize = function()
                return checkCFunc(__index.SetMinResize)
              end,
              SetMouseClickEnabled = function()
                return checkCFunc(__index.SetMouseClickEnabled)
              end,
              SetMouseMotionEnabled = function()
                return checkCFunc(__index.SetMouseMotionEnabled)
              end,
              SetMovable = function()
                return checkCFunc(__index.SetMovable)
              end,
              SetParent = function()
                return checkCFunc(__index.SetParent)
              end,
              SetPoint = function()
                return checkCFunc(__index.SetPoint)
              end,
              SetPropagateKeyboardInput = function()
                return checkCFunc(__index.SetPropagateKeyboardInput)
              end,
              SetResizable = function()
                return checkCFunc(__index.SetResizable)
              end,
              SetScale = function()
                return checkCFunc(__index.SetScale)
              end,
              SetScript = function()
                return checkCFunc(__index.SetScript)
              end,
              SetShown = function()
                return checkCFunc(__index.SetShown)
              end,
              SetSize = function()
                return checkCFunc(__index.SetSize)
              end,
              SetToplevel = function()
                return checkCFunc(__index.SetToplevel)
              end,
              SetUserPlaced = function()
                return checkCFunc(__index.SetUserPlaced)
              end,
              SetWidth = function()
                return checkCFunc(__index.SetWidth)
              end,
              Show = function()
                return checkCFunc(__index.Show)
              end,
              StartMoving = function()
                return checkCFunc(__index.StartMoving)
              end,
              StartSizing = function()
                return checkCFunc(__index.StartSizing)
              end,
              StopAnimating = function()
                return checkCFunc(__index.StopAnimating)
              end,
              StopMovingOrSizing = function()
                return checkCFunc(__index.StopMovingOrSizing)
              end,
              UnregisterAllEvents = function()
                return checkCFunc(__index.UnregisterAllEvents)
              end,
              UnregisterEvent = function()
                return checkCFunc(__index.UnregisterEvent)
              end,
            }
          end)
        end,
        ControlPoint = function()
          assertCreateFrameFails('ControlPoint')
        end,
        Cooldown = function()
          local function factory()
            return assertCreateFrame('Cooldown')
          end
          return mkTests('Cooldown', factory, function(__index)
            return {
              AdjustPointsOffset = function()
                return checkCFunc(__index.AdjustPointsOffset)
              end,
              CanChangeAttribute = function()
                return checkCFunc(__index.CanChangeAttribute)
              end,
              CanChangeProtectedState = function()
                return checkCFunc(__index.CanChangeProtectedState)
              end,
              Clear = function()
                return checkCFunc(__index.Clear)
              end,
              ClearAllPoints = function()
                return checkCFunc(__index.ClearAllPoints)
              end,
              ClearPointByName = function()
                return checkCFunc(__index.ClearPointByName)
              end,
              ClearPointsOffset = function()
                return checkCFunc(__index.ClearPointsOffset)
              end,
              CreateAnimationGroup = function()
                return checkCFunc(__index.CreateAnimationGroup)
              end,
              CreateFontString = function()
                return checkCFunc(__index.CreateFontString)
              end,
              CreateLine = function()
                return checkCFunc(__index.CreateLine)
              end,
              CreateMaskTexture = function()
                return checkCFunc(__index.CreateMaskTexture)
              end,
              CreateTexture = function()
                return checkCFunc(__index.CreateTexture)
              end,
              DesaturateHierarchy = function()
                return checkCFunc(__index.DesaturateHierarchy)
              end,
              DisableDrawLayer = function()
                return checkCFunc(__index.DisableDrawLayer)
              end,
              DoesClipChildren = function()
                return checkCFunc(__index.DoesClipChildren)
              end,
              EnableDrawLayer = function()
                return checkCFunc(__index.EnableDrawLayer)
              end,
              EnableGamePadButton = function()
                return checkCFunc(__index.EnableGamePadButton)
              end,
              EnableGamePadStick = function()
                return checkCFunc(__index.EnableGamePadStick)
              end,
              EnableKeyboard = function()
                return checkCFunc(__index.EnableKeyboard)
              end,
              EnableMouse = function()
                return checkCFunc(__index.EnableMouse)
              end,
              EnableMouseWheel = function()
                return checkCFunc(__index.EnableMouseWheel)
              end,
              ExecuteAttribute = function()
                return checkCFunc(__index.ExecuteAttribute)
              end,
              GetAlpha = function()
                return checkCFunc(__index.GetAlpha)
              end,
              GetAnimationGroups = function()
                return checkCFunc(__index.GetAnimationGroups)
              end,
              GetAttribute = function()
                return checkCFunc(__index.GetAttribute)
              end,
              GetBottom = function()
                return checkCFunc(__index.GetBottom)
              end,
              GetBoundsRect = function()
                return checkCFunc(__index.GetBoundsRect)
              end,
              GetCenter = function()
                return checkCFunc(__index.GetCenter)
              end,
              GetChildren = function()
                return checkCFunc(__index.GetChildren)
              end,
              GetClampRectInsets = function()
                return checkCFunc(__index.GetClampRectInsets)
              end,
              GetCooldownDisplayDuration = function()
                return checkCFunc(__index.GetCooldownDisplayDuration)
              end,
              GetCooldownDuration = function()
                return checkCFunc(__index.GetCooldownDuration)
              end,
              GetCooldownTimes = function()
                return checkCFunc(__index.GetCooldownTimes)
              end,
              GetDebugName = function()
                return checkCFunc(__index.GetDebugName)
              end,
              GetDepth = function()
                return checkCFunc(__index.GetDepth)
              end,
              GetDontSavePosition = function()
                return checkCFunc(__index.GetDontSavePosition)
              end,
              GetDrawBling = function()
                return checkCFunc(__index.GetDrawBling)
              end,
              GetDrawEdge = function()
                return checkCFunc(__index.GetDrawEdge)
              end,
              GetDrawSwipe = function()
                return checkCFunc(__index.GetDrawSwipe)
              end,
              GetEdgeScale = function()
                return checkCFunc(__index.GetEdgeScale)
              end,
              GetEffectiveAlpha = function()
                return checkCFunc(__index.GetEffectiveAlpha)
              end,
              GetEffectiveDepth = function()
                return checkCFunc(__index.GetEffectiveDepth)
              end,
              GetEffectiveScale = function()
                return checkCFunc(__index.GetEffectiveScale)
              end,
              GetEffectivelyFlattensRenderLayers = function()
                return checkCFunc(__index.GetEffectivelyFlattensRenderLayers)
              end,
              GetFlattensRenderLayers = function()
                return checkCFunc(__index.GetFlattensRenderLayers)
              end,
              GetFrameLevel = function()
                return checkCFunc(__index.GetFrameLevel)
              end,
              GetFrameStrata = function()
                return checkCFunc(__index.GetFrameStrata)
              end,
              GetHeight = function()
                return checkCFunc(__index.GetHeight)
              end,
              GetHitRectInsets = function()
                return checkCFunc(__index.GetHitRectInsets)
              end,
              GetHyperlinksEnabled = function()
                return checkCFunc(__index.GetHyperlinksEnabled)
              end,
              GetID = function()
                return checkCFunc(__index.GetID)
              end,
              GetLeft = function()
                return checkCFunc(__index.GetLeft)
              end,
              GetMaxResize = function()
                return checkCFunc(__index.GetMaxResize)
              end,
              GetMinResize = function()
                return checkCFunc(__index.GetMinResize)
              end,
              GetName = function()
                return checkCFunc(__index.GetName)
              end,
              GetNumChildren = function()
                return checkCFunc(__index.GetNumChildren)
              end,
              GetNumPoints = function()
                return checkCFunc(__index.GetNumPoints)
              end,
              GetNumRegions = function()
                return checkCFunc(__index.GetNumRegions)
              end,
              GetObjectType = function()
                return checkCFunc(__index.GetObjectType)
              end,
              GetParent = function()
                return checkCFunc(__index.GetParent)
              end,
              GetPoint = function()
                return checkCFunc(__index.GetPoint)
              end,
              GetPointByName = function()
                return checkCFunc(__index.GetPointByName)
              end,
              GetPropagateKeyboardInput = function()
                return checkCFunc(__index.GetPropagateKeyboardInput)
              end,
              GetRect = function()
                return checkCFunc(__index.GetRect)
              end,
              GetRegions = function()
                return checkCFunc(__index.GetRegions)
              end,
              GetReverse = function()
                return checkCFunc(__index.GetReverse)
              end,
              GetRight = function()
                return checkCFunc(__index.GetRight)
              end,
              GetRotation = function()
                return checkCFunc(__index.GetRotation)
              end,
              GetScale = function()
                return checkCFunc(__index.GetScale)
              end,
              GetScaledRect = function()
                return checkCFunc(__index.GetScaledRect)
              end,
              GetScript = function()
                return checkCFunc(__index.GetScript)
              end,
              GetSize = function()
                return checkCFunc(__index.GetSize)
              end,
              GetSourceLocation = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetSourceLocation))
                  return
                end
                return checkCFunc(__index.GetSourceLocation)
              end,
              GetTop = function()
                return checkCFunc(__index.GetTop)
              end,
              GetWidth = function()
                return checkCFunc(__index.GetWidth)
              end,
              HasFixedFrameLevel = function()
                return checkCFunc(__index.HasFixedFrameLevel)
              end,
              HasFixedFrameStrata = function()
                return checkCFunc(__index.HasFixedFrameStrata)
              end,
              HasScript = function()
                return checkCFunc(__index.HasScript)
              end,
              Hide = function()
                return checkCFunc(__index.Hide)
              end,
              HookScript = function()
                return checkCFunc(__index.HookScript)
              end,
              IgnoreDepth = function()
                return checkCFunc(__index.IgnoreDepth)
              end,
              IsAnchoringRestricted = function()
                return checkCFunc(__index.IsAnchoringRestricted)
              end,
              IsClampedToScreen = function()
                return checkCFunc(__index.IsClampedToScreen)
              end,
              IsDragging = function()
                return checkCFunc(__index.IsDragging)
              end,
              IsEventRegistered = function()
                return checkCFunc(__index.IsEventRegistered)
              end,
              IsForbidden = function()
                return checkCFunc(__index.IsForbidden)
              end,
              IsGamePadButtonEnabled = function()
                return checkCFunc(__index.IsGamePadButtonEnabled)
              end,
              IsGamePadStickEnabled = function()
                return checkCFunc(__index.IsGamePadStickEnabled)
              end,
              IsIgnoringDepth = function()
                return checkCFunc(__index.IsIgnoringDepth)
              end,
              IsIgnoringParentAlpha = function()
                return checkCFunc(__index.IsIgnoringParentAlpha)
              end,
              IsIgnoringParentScale = function()
                return checkCFunc(__index.IsIgnoringParentScale)
              end,
              IsKeyboardEnabled = function()
                return checkCFunc(__index.IsKeyboardEnabled)
              end,
              IsMouseClickEnabled = function()
                return checkCFunc(__index.IsMouseClickEnabled)
              end,
              IsMouseEnabled = function()
                return checkCFunc(__index.IsMouseEnabled)
              end,
              IsMouseMotionEnabled = function()
                return checkCFunc(__index.IsMouseMotionEnabled)
              end,
              IsMouseOver = function()
                return checkCFunc(__index.IsMouseOver)
              end,
              IsMouseWheelEnabled = function()
                return checkCFunc(__index.IsMouseWheelEnabled)
              end,
              IsMovable = function()
                return checkCFunc(__index.IsMovable)
              end,
              IsObjectLoaded = function()
                return checkCFunc(__index.IsObjectLoaded)
              end,
              IsObjectType = function()
                return checkCFunc(__index.IsObjectType)
              end,
              IsPaused = function()
                return checkCFunc(__index.IsPaused)
              end,
              IsProtected = function()
                return checkCFunc(__index.IsProtected)
              end,
              IsRectValid = function()
                return checkCFunc(__index.IsRectValid)
              end,
              IsResizable = function()
                return checkCFunc(__index.IsResizable)
              end,
              IsShown = function()
                return checkCFunc(__index.IsShown)
              end,
              IsToplevel = function()
                return checkCFunc(__index.IsToplevel)
              end,
              IsUserPlaced = function()
                return checkCFunc(__index.IsUserPlaced)
              end,
              IsVisible = function()
                return checkCFunc(__index.IsVisible)
              end,
              Lower = function()
                return checkCFunc(__index.Lower)
              end,
              Pause = function()
                return checkCFunc(__index.Pause)
              end,
              Raise = function()
                return checkCFunc(__index.Raise)
              end,
              RegisterAllEvents = function()
                return checkCFunc(__index.RegisterAllEvents)
              end,
              RegisterEvent = function()
                return checkCFunc(__index.RegisterEvent)
              end,
              RegisterForDrag = function()
                return checkCFunc(__index.RegisterForDrag)
              end,
              RegisterUnitEvent = function()
                return checkCFunc(__index.RegisterUnitEvent)
              end,
              Resume = function()
                return checkCFunc(__index.Resume)
              end,
              RotateTextures = function()
                return checkCFunc(__index.RotateTextures)
              end,
              SetAllPoints = function()
                return checkCFunc(__index.SetAllPoints)
              end,
              SetAlpha = function()
                return checkCFunc(__index.SetAlpha)
              end,
              SetAttribute = function()
                return checkCFunc(__index.SetAttribute)
              end,
              SetAttributeNoHandler = function()
                return checkCFunc(__index.SetAttributeNoHandler)
              end,
              SetBlingTexture = function()
                return checkCFunc(__index.SetBlingTexture)
              end,
              SetClampRectInsets = function()
                return checkCFunc(__index.SetClampRectInsets)
              end,
              SetClampedToScreen = function()
                return checkCFunc(__index.SetClampedToScreen)
              end,
              SetClipsChildren = function()
                return checkCFunc(__index.SetClipsChildren)
              end,
              SetCooldown = function()
                return checkCFunc(__index.SetCooldown)
              end,
              SetCooldownDuration = function()
                return checkCFunc(__index.SetCooldownDuration)
              end,
              SetCooldownUNIX = function()
                return checkCFunc(__index.SetCooldownUNIX)
              end,
              SetCountdownAbbrevThreshold = function()
                return checkCFunc(__index.SetCountdownAbbrevThreshold)
              end,
              SetCountdownFont = function()
                return checkCFunc(__index.SetCountdownFont)
              end,
              SetDepth = function()
                return checkCFunc(__index.SetDepth)
              end,
              SetDontSavePosition = function()
                return checkCFunc(__index.SetDontSavePosition)
              end,
              SetDrawBling = function()
                return checkCFunc(__index.SetDrawBling)
              end,
              SetDrawEdge = function()
                return checkCFunc(__index.SetDrawEdge)
              end,
              SetDrawLayerEnabled = function()
                return checkCFunc(__index.SetDrawLayerEnabled)
              end,
              SetDrawSwipe = function()
                return checkCFunc(__index.SetDrawSwipe)
              end,
              SetEdgeScale = function()
                return checkCFunc(__index.SetEdgeScale)
              end,
              SetEdgeTexture = function()
                return checkCFunc(__index.SetEdgeTexture)
              end,
              SetFixedFrameLevel = function()
                return checkCFunc(__index.SetFixedFrameLevel)
              end,
              SetFixedFrameStrata = function()
                return checkCFunc(__index.SetFixedFrameStrata)
              end,
              SetFlattensRenderLayers = function()
                return checkCFunc(__index.SetFlattensRenderLayers)
              end,
              SetForbidden = function()
                return checkCFunc(__index.SetForbidden)
              end,
              SetFrameBuffer = function()
                return checkCFunc(__index.SetFrameBuffer)
              end,
              SetFrameLevel = function()
                return checkCFunc(__index.SetFrameLevel)
              end,
              SetFrameStrata = function()
                return checkCFunc(__index.SetFrameStrata)
              end,
              SetHeight = function()
                return checkCFunc(__index.SetHeight)
              end,
              SetHideCountdownNumbers = function()
                return checkCFunc(__index.SetHideCountdownNumbers)
              end,
              SetHitRectInsets = function()
                return checkCFunc(__index.SetHitRectInsets)
              end,
              SetHyperlinksEnabled = function()
                return checkCFunc(__index.SetHyperlinksEnabled)
              end,
              SetID = function()
                return checkCFunc(__index.SetID)
              end,
              SetIgnoreParentAlpha = function()
                return checkCFunc(__index.SetIgnoreParentAlpha)
              end,
              SetIgnoreParentScale = function()
                return checkCFunc(__index.SetIgnoreParentScale)
              end,
              SetMaxResize = function()
                return checkCFunc(__index.SetMaxResize)
              end,
              SetMinResize = function()
                return checkCFunc(__index.SetMinResize)
              end,
              SetMouseClickEnabled = function()
                return checkCFunc(__index.SetMouseClickEnabled)
              end,
              SetMouseMotionEnabled = function()
                return checkCFunc(__index.SetMouseMotionEnabled)
              end,
              SetMovable = function()
                return checkCFunc(__index.SetMovable)
              end,
              SetParent = function()
                return checkCFunc(__index.SetParent)
              end,
              SetPoint = function()
                return checkCFunc(__index.SetPoint)
              end,
              SetPropagateKeyboardInput = function()
                return checkCFunc(__index.SetPropagateKeyboardInput)
              end,
              SetResizable = function()
                return checkCFunc(__index.SetResizable)
              end,
              SetReverse = function()
                return checkCFunc(__index.SetReverse)
              end,
              SetRotation = function()
                return checkCFunc(__index.SetRotation)
              end,
              SetScale = function()
                return checkCFunc(__index.SetScale)
              end,
              SetScript = function()
                return checkCFunc(__index.SetScript)
              end,
              SetShown = function()
                return checkCFunc(__index.SetShown)
              end,
              SetSize = function()
                return checkCFunc(__index.SetSize)
              end,
              SetSwipeColor = function()
                return checkCFunc(__index.SetSwipeColor)
              end,
              SetSwipeTexture = function()
                return checkCFunc(__index.SetSwipeTexture)
              end,
              SetToplevel = function()
                return checkCFunc(__index.SetToplevel)
              end,
              SetUseCircularEdge = function()
                return checkCFunc(__index.SetUseCircularEdge)
              end,
              SetUserPlaced = function()
                return checkCFunc(__index.SetUserPlaced)
              end,
              SetWidth = function()
                return checkCFunc(__index.SetWidth)
              end,
              Show = function()
                return checkCFunc(__index.Show)
              end,
              StartMoving = function()
                return checkCFunc(__index.StartMoving)
              end,
              StartSizing = function()
                return checkCFunc(__index.StartSizing)
              end,
              StopAnimating = function()
                return checkCFunc(__index.StopAnimating)
              end,
              StopMovingOrSizing = function()
                return checkCFunc(__index.StopMovingOrSizing)
              end,
              UnregisterAllEvents = function()
                return checkCFunc(__index.UnregisterAllEvents)
              end,
              UnregisterEvent = function()
                return checkCFunc(__index.UnregisterEvent)
              end,
            }
          end)
        end,
        DressUpModel = function()
          local function factory()
            return assertCreateFrame('DressUpModel')
          end
          return mkTests('DressUpModel', factory, function(__index)
            return {
              AdjustPointsOffset = function()
                return checkCFunc(__index.AdjustPointsOffset)
              end,
              AdvanceTime = function()
                return checkCFunc(__index.AdvanceTime)
              end,
              ApplySpellVisualKit = function()
                return checkCFunc(__index.ApplySpellVisualKit)
              end,
              CanChangeAttribute = function()
                return checkCFunc(__index.CanChangeAttribute)
              end,
              CanChangeProtectedState = function()
                return checkCFunc(__index.CanChangeProtectedState)
              end,
              CanSetUnit = function()
                return checkCFunc(__index.CanSetUnit)
              end,
              ClearAllPoints = function()
                return checkCFunc(__index.ClearAllPoints)
              end,
              ClearFog = function()
                return checkCFunc(__index.ClearFog)
              end,
              ClearModel = function()
                return checkCFunc(__index.ClearModel)
              end,
              ClearPointByName = function()
                return checkCFunc(__index.ClearPointByName)
              end,
              ClearPointsOffset = function()
                return checkCFunc(__index.ClearPointsOffset)
              end,
              ClearTransform = function()
                return checkCFunc(__index.ClearTransform)
              end,
              CreateAnimationGroup = function()
                return checkCFunc(__index.CreateAnimationGroup)
              end,
              CreateFontString = function()
                return checkCFunc(__index.CreateFontString)
              end,
              CreateLine = function()
                return checkCFunc(__index.CreateLine)
              end,
              CreateMaskTexture = function()
                return checkCFunc(__index.CreateMaskTexture)
              end,
              CreateTexture = function()
                return checkCFunc(__index.CreateTexture)
              end,
              DesaturateHierarchy = function()
                return checkCFunc(__index.DesaturateHierarchy)
              end,
              DisableDrawLayer = function()
                return checkCFunc(__index.DisableDrawLayer)
              end,
              DoesClipChildren = function()
                return checkCFunc(__index.DoesClipChildren)
              end,
              Dress = function()
                return checkCFunc(__index.Dress)
              end,
              EnableDrawLayer = function()
                return checkCFunc(__index.EnableDrawLayer)
              end,
              EnableGamePadButton = function()
                return checkCFunc(__index.EnableGamePadButton)
              end,
              EnableGamePadStick = function()
                return checkCFunc(__index.EnableGamePadStick)
              end,
              EnableKeyboard = function()
                return checkCFunc(__index.EnableKeyboard)
              end,
              EnableMouse = function()
                return checkCFunc(__index.EnableMouse)
              end,
              EnableMouseWheel = function()
                return checkCFunc(__index.EnableMouseWheel)
              end,
              ExecuteAttribute = function()
                return checkCFunc(__index.ExecuteAttribute)
              end,
              FreezeAnimation = function()
                return checkCFunc(__index.FreezeAnimation)
              end,
              GetAlpha = function()
                return checkCFunc(__index.GetAlpha)
              end,
              GetAnimationGroups = function()
                return checkCFunc(__index.GetAnimationGroups)
              end,
              GetAttribute = function()
                return checkCFunc(__index.GetAttribute)
              end,
              GetAutoDress = function()
                return checkCFunc(__index.GetAutoDress)
              end,
              GetBottom = function()
                return checkCFunc(__index.GetBottom)
              end,
              GetBoundsRect = function()
                return checkCFunc(__index.GetBoundsRect)
              end,
              GetCameraDistance = function()
                return checkCFunc(__index.GetCameraDistance)
              end,
              GetCameraFacing = function()
                return checkCFunc(__index.GetCameraFacing)
              end,
              GetCameraPosition = function()
                return checkCFunc(__index.GetCameraPosition)
              end,
              GetCameraRoll = function()
                return checkCFunc(__index.GetCameraRoll)
              end,
              GetCameraTarget = function()
                return checkCFunc(__index.GetCameraTarget)
              end,
              GetCenter = function()
                return checkCFunc(__index.GetCenter)
              end,
              GetChildren = function()
                return checkCFunc(__index.GetChildren)
              end,
              GetClampRectInsets = function()
                return checkCFunc(__index.GetClampRectInsets)
              end,
              GetDebugName = function()
                return checkCFunc(__index.GetDebugName)
              end,
              GetDepth = function()
                return checkCFunc(__index.GetDepth)
              end,
              GetDesaturation = function()
                return checkCFunc(__index.GetDesaturation)
              end,
              GetDisplayInfo = function()
                return checkCFunc(__index.GetDisplayInfo)
              end,
              GetDoBlend = function()
                return checkCFunc(__index.GetDoBlend)
              end,
              GetDontSavePosition = function()
                return checkCFunc(__index.GetDontSavePosition)
              end,
              GetEffectiveAlpha = function()
                return checkCFunc(__index.GetEffectiveAlpha)
              end,
              GetEffectiveDepth = function()
                return checkCFunc(__index.GetEffectiveDepth)
              end,
              GetEffectiveScale = function()
                return checkCFunc(__index.GetEffectiveScale)
              end,
              GetEffectivelyFlattensRenderLayers = function()
                return checkCFunc(__index.GetEffectivelyFlattensRenderLayers)
              end,
              GetFacing = function()
                return checkCFunc(__index.GetFacing)
              end,
              GetFlattensRenderLayers = function()
                return checkCFunc(__index.GetFlattensRenderLayers)
              end,
              GetFogColor = function()
                return checkCFunc(__index.GetFogColor)
              end,
              GetFogFar = function()
                return checkCFunc(__index.GetFogFar)
              end,
              GetFogNear = function()
                return checkCFunc(__index.GetFogNear)
              end,
              GetFrameLevel = function()
                return checkCFunc(__index.GetFrameLevel)
              end,
              GetFrameStrata = function()
                return checkCFunc(__index.GetFrameStrata)
              end,
              GetHeight = function()
                return checkCFunc(__index.GetHeight)
              end,
              GetHitRectInsets = function()
                return checkCFunc(__index.GetHitRectInsets)
              end,
              GetHyperlinksEnabled = function()
                return checkCFunc(__index.GetHyperlinksEnabled)
              end,
              GetID = function()
                return checkCFunc(__index.GetID)
              end,
              GetItemTransmogInfo = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetItemTransmogInfo))
                  return
                end
                return checkCFunc(__index.GetItemTransmogInfo)
              end,
              GetItemTransmogInfoList = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetItemTransmogInfoList))
                  return
                end
                return checkCFunc(__index.GetItemTransmogInfoList)
              end,
              GetKeepModelOnHide = function()
                return checkCFunc(__index.GetKeepModelOnHide)
              end,
              GetLeft = function()
                return checkCFunc(__index.GetLeft)
              end,
              GetLight = function()
                return checkCFunc(__index.GetLight)
              end,
              GetMaxResize = function()
                return checkCFunc(__index.GetMaxResize)
              end,
              GetMinResize = function()
                return checkCFunc(__index.GetMinResize)
              end,
              GetModelAlpha = function()
                return checkCFunc(__index.GetModelAlpha)
              end,
              GetModelDrawLayer = function()
                return checkCFunc(__index.GetModelDrawLayer)
              end,
              GetModelFileID = function()
                return checkCFunc(__index.GetModelFileID)
              end,
              GetModelScale = function()
                return checkCFunc(__index.GetModelScale)
              end,
              GetName = function()
                return checkCFunc(__index.GetName)
              end,
              GetNumChildren = function()
                return checkCFunc(__index.GetNumChildren)
              end,
              GetNumPoints = function()
                return checkCFunc(__index.GetNumPoints)
              end,
              GetNumRegions = function()
                return checkCFunc(__index.GetNumRegions)
              end,
              GetObeyHideInTransmogFlag = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetObeyHideInTransmogFlag))
                  return
                end
                return checkCFunc(__index.GetObeyHideInTransmogFlag)
              end,
              GetObjectType = function()
                return checkCFunc(__index.GetObjectType)
              end,
              GetParent = function()
                return checkCFunc(__index.GetParent)
              end,
              GetPaused = function()
                return checkCFunc(__index.GetPaused)
              end,
              GetPitch = function()
                return checkCFunc(__index.GetPitch)
              end,
              GetPoint = function()
                return checkCFunc(__index.GetPoint)
              end,
              GetPointByName = function()
                return checkCFunc(__index.GetPointByName)
              end,
              GetPosition = function()
                return checkCFunc(__index.GetPosition)
              end,
              GetPropagateKeyboardInput = function()
                return checkCFunc(__index.GetPropagateKeyboardInput)
              end,
              GetRect = function()
                return checkCFunc(__index.GetRect)
              end,
              GetRegions = function()
                return checkCFunc(__index.GetRegions)
              end,
              GetRight = function()
                return checkCFunc(__index.GetRight)
              end,
              GetRoll = function()
                return checkCFunc(__index.GetRoll)
              end,
              GetScale = function()
                return checkCFunc(__index.GetScale)
              end,
              GetScaledRect = function()
                return checkCFunc(__index.GetScaledRect)
              end,
              GetScript = function()
                return checkCFunc(__index.GetScript)
              end,
              GetShadowEffect = function()
                return checkCFunc(__index.GetShadowEffect)
              end,
              GetSheathed = function()
                return checkCFunc(__index.GetSheathed)
              end,
              GetSize = function()
                return checkCFunc(__index.GetSize)
              end,
              GetSourceLocation = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetSourceLocation))
                  return
                end
                return checkCFunc(__index.GetSourceLocation)
              end,
              GetTop = function()
                return checkCFunc(__index.GetTop)
              end,
              GetUseTransmogChoices = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetUseTransmogChoices))
                  return
                end
                return checkCFunc(__index.GetUseTransmogChoices)
              end,
              GetUseTransmogSkin = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetUseTransmogSkin))
                  return
                end
                return checkCFunc(__index.GetUseTransmogSkin)
              end,
              GetViewInsets = function()
                return checkCFunc(__index.GetViewInsets)
              end,
              GetViewTranslation = function()
                return checkCFunc(__index.GetViewTranslation)
              end,
              GetWidth = function()
                return checkCFunc(__index.GetWidth)
              end,
              GetWorldScale = function()
                return checkCFunc(__index.GetWorldScale)
              end,
              HasAnimation = function()
                return checkCFunc(__index.HasAnimation)
              end,
              HasAttachmentPoints = function()
                return checkCFunc(__index.HasAttachmentPoints)
              end,
              HasCustomCamera = function()
                return checkCFunc(__index.HasCustomCamera)
              end,
              HasFixedFrameLevel = function()
                return checkCFunc(__index.HasFixedFrameLevel)
              end,
              HasFixedFrameStrata = function()
                return checkCFunc(__index.HasFixedFrameStrata)
              end,
              HasScript = function()
                return checkCFunc(__index.HasScript)
              end,
              Hide = function()
                return checkCFunc(__index.Hide)
              end,
              HookScript = function()
                return checkCFunc(__index.HookScript)
              end,
              IgnoreDepth = function()
                return checkCFunc(__index.IgnoreDepth)
              end,
              IsAnchoringRestricted = function()
                return checkCFunc(__index.IsAnchoringRestricted)
              end,
              IsClampedToScreen = function()
                return checkCFunc(__index.IsClampedToScreen)
              end,
              IsDragging = function()
                return checkCFunc(__index.IsDragging)
              end,
              IsEventRegistered = function()
                return checkCFunc(__index.IsEventRegistered)
              end,
              IsForbidden = function()
                return checkCFunc(__index.IsForbidden)
              end,
              IsGamePadButtonEnabled = function()
                return checkCFunc(__index.IsGamePadButtonEnabled)
              end,
              IsGamePadStickEnabled = function()
                return checkCFunc(__index.IsGamePadStickEnabled)
              end,
              IsIgnoringDepth = function()
                return checkCFunc(__index.IsIgnoringDepth)
              end,
              IsIgnoringParentAlpha = function()
                return checkCFunc(__index.IsIgnoringParentAlpha)
              end,
              IsIgnoringParentScale = function()
                return checkCFunc(__index.IsIgnoringParentScale)
              end,
              IsKeyboardEnabled = function()
                return checkCFunc(__index.IsKeyboardEnabled)
              end,
              IsMouseClickEnabled = function()
                return checkCFunc(__index.IsMouseClickEnabled)
              end,
              IsMouseEnabled = function()
                return checkCFunc(__index.IsMouseEnabled)
              end,
              IsMouseMotionEnabled = function()
                return checkCFunc(__index.IsMouseMotionEnabled)
              end,
              IsMouseOver = function()
                return checkCFunc(__index.IsMouseOver)
              end,
              IsMouseWheelEnabled = function()
                return checkCFunc(__index.IsMouseWheelEnabled)
              end,
              IsMovable = function()
                return checkCFunc(__index.IsMovable)
              end,
              IsObjectLoaded = function()
                return checkCFunc(__index.IsObjectLoaded)
              end,
              IsObjectType = function()
                return checkCFunc(__index.IsObjectType)
              end,
              IsProtected = function()
                return checkCFunc(__index.IsProtected)
              end,
              IsRectValid = function()
                return checkCFunc(__index.IsRectValid)
              end,
              IsResizable = function()
                return checkCFunc(__index.IsResizable)
              end,
              IsShown = function()
                return checkCFunc(__index.IsShown)
              end,
              IsToplevel = function()
                return checkCFunc(__index.IsToplevel)
              end,
              IsUserPlaced = function()
                return checkCFunc(__index.IsUserPlaced)
              end,
              IsUsingModelCenterToTransform = function()
                return checkCFunc(__index.IsUsingModelCenterToTransform)
              end,
              IsVisible = function()
                return checkCFunc(__index.IsVisible)
              end,
              Lower = function()
                return checkCFunc(__index.Lower)
              end,
              MakeCurrentCameraCustom = function()
                return checkCFunc(__index.MakeCurrentCameraCustom)
              end,
              PlayAnimKit = function()
                return checkCFunc(__index.PlayAnimKit)
              end,
              Raise = function()
                return checkCFunc(__index.Raise)
              end,
              RefreshCamera = function()
                return checkCFunc(__index.RefreshCamera)
              end,
              RefreshUnit = function()
                return checkCFunc(__index.RefreshUnit)
              end,
              RegisterAllEvents = function()
                return checkCFunc(__index.RegisterAllEvents)
              end,
              RegisterEvent = function()
                return checkCFunc(__index.RegisterEvent)
              end,
              RegisterForDrag = function()
                return checkCFunc(__index.RegisterForDrag)
              end,
              RegisterUnitEvent = function()
                return checkCFunc(__index.RegisterUnitEvent)
              end,
              ReplaceIconTexture = function()
                return checkCFunc(__index.ReplaceIconTexture)
              end,
              RotateTextures = function()
                return checkCFunc(__index.RotateTextures)
              end,
              SetAllPoints = function()
                return checkCFunc(__index.SetAllPoints)
              end,
              SetAlpha = function()
                return checkCFunc(__index.SetAlpha)
              end,
              SetAnimation = function()
                return checkCFunc(__index.SetAnimation)
              end,
              SetAttribute = function()
                return checkCFunc(__index.SetAttribute)
              end,
              SetAttributeNoHandler = function()
                return checkCFunc(__index.SetAttributeNoHandler)
              end,
              SetAutoDress = function()
                return checkCFunc(__index.SetAutoDress)
              end,
              SetBarberShopAlternateForm = function()
                return checkCFunc(__index.SetBarberShopAlternateForm)
              end,
              SetCamDistanceScale = function()
                return checkCFunc(__index.SetCamDistanceScale)
              end,
              SetCamera = function()
                return checkCFunc(__index.SetCamera)
              end,
              SetCameraDistance = function()
                return checkCFunc(__index.SetCameraDistance)
              end,
              SetCameraFacing = function()
                return checkCFunc(__index.SetCameraFacing)
              end,
              SetCameraPosition = function()
                return checkCFunc(__index.SetCameraPosition)
              end,
              SetCameraRoll = function()
                return checkCFunc(__index.SetCameraRoll)
              end,
              SetCameraTarget = function()
                return checkCFunc(__index.SetCameraTarget)
              end,
              SetClampRectInsets = function()
                return checkCFunc(__index.SetClampRectInsets)
              end,
              SetClampedToScreen = function()
                return checkCFunc(__index.SetClampedToScreen)
              end,
              SetClipsChildren = function()
                return checkCFunc(__index.SetClipsChildren)
              end,
              SetCreature = function()
                return checkCFunc(__index.SetCreature)
              end,
              SetCustomCamera = function()
                return checkCFunc(__index.SetCustomCamera)
              end,
              SetCustomRace = function()
                return checkCFunc(__index.SetCustomRace)
              end,
              SetDepth = function()
                return checkCFunc(__index.SetDepth)
              end,
              SetDesaturation = function()
                return checkCFunc(__index.SetDesaturation)
              end,
              SetDisplayInfo = function()
                return checkCFunc(__index.SetDisplayInfo)
              end,
              SetDoBlend = function()
                return checkCFunc(__index.SetDoBlend)
              end,
              SetDontSavePosition = function()
                return checkCFunc(__index.SetDontSavePosition)
              end,
              SetDrawLayerEnabled = function()
                return checkCFunc(__index.SetDrawLayerEnabled)
              end,
              SetFacing = function()
                return checkCFunc(__index.SetFacing)
              end,
              SetFixedFrameLevel = function()
                return checkCFunc(__index.SetFixedFrameLevel)
              end,
              SetFixedFrameStrata = function()
                return checkCFunc(__index.SetFixedFrameStrata)
              end,
              SetFlattensRenderLayers = function()
                return checkCFunc(__index.SetFlattensRenderLayers)
              end,
              SetFogColor = function()
                return checkCFunc(__index.SetFogColor)
              end,
              SetFogFar = function()
                return checkCFunc(__index.SetFogFar)
              end,
              SetFogNear = function()
                return checkCFunc(__index.SetFogNear)
              end,
              SetForbidden = function()
                return checkCFunc(__index.SetForbidden)
              end,
              SetFrameBuffer = function()
                return checkCFunc(__index.SetFrameBuffer)
              end,
              SetFrameLevel = function()
                return checkCFunc(__index.SetFrameLevel)
              end,
              SetFrameStrata = function()
                return checkCFunc(__index.SetFrameStrata)
              end,
              SetGlow = function()
                return checkCFunc(__index.SetGlow)
              end,
              SetHeight = function()
                return checkCFunc(__index.SetHeight)
              end,
              SetHitRectInsets = function()
                return checkCFunc(__index.SetHitRectInsets)
              end,
              SetHyperlinksEnabled = function()
                return checkCFunc(__index.SetHyperlinksEnabled)
              end,
              SetID = function()
                return checkCFunc(__index.SetID)
              end,
              SetIgnoreParentAlpha = function()
                return checkCFunc(__index.SetIgnoreParentAlpha)
              end,
              SetIgnoreParentScale = function()
                return checkCFunc(__index.SetIgnoreParentScale)
              end,
              SetItem = function()
                return checkCFunc(__index.SetItem)
              end,
              SetItemAppearance = function()
                return checkCFunc(__index.SetItemAppearance)
              end,
              SetItemTransmogInfo = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetItemTransmogInfo))
                  return
                end
                return checkCFunc(__index.SetItemTransmogInfo)
              end,
              SetKeepModelOnHide = function()
                return checkCFunc(__index.SetKeepModelOnHide)
              end,
              SetLight = function()
                return checkCFunc(__index.SetLight)
              end,
              SetMaxResize = function()
                return checkCFunc(__index.SetMaxResize)
              end,
              SetMinResize = function()
                return checkCFunc(__index.SetMinResize)
              end,
              SetModel = function()
                return checkCFunc(__index.SetModel)
              end,
              SetModelAlpha = function()
                return checkCFunc(__index.SetModelAlpha)
              end,
              SetModelDrawLayer = function()
                return checkCFunc(__index.SetModelDrawLayer)
              end,
              SetModelScale = function()
                return checkCFunc(__index.SetModelScale)
              end,
              SetMouseClickEnabled = function()
                return checkCFunc(__index.SetMouseClickEnabled)
              end,
              SetMouseMotionEnabled = function()
                return checkCFunc(__index.SetMouseMotionEnabled)
              end,
              SetMovable = function()
                return checkCFunc(__index.SetMovable)
              end,
              SetObeyHideInTransmogFlag = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetObeyHideInTransmogFlag))
                  return
                end
                return checkCFunc(__index.SetObeyHideInTransmogFlag)
              end,
              SetParent = function()
                return checkCFunc(__index.SetParent)
              end,
              SetParticlesEnabled = function()
                return checkCFunc(__index.SetParticlesEnabled)
              end,
              SetPaused = function()
                return checkCFunc(__index.SetPaused)
              end,
              SetPitch = function()
                return checkCFunc(__index.SetPitch)
              end,
              SetPoint = function()
                return checkCFunc(__index.SetPoint)
              end,
              SetPortraitZoom = function()
                return checkCFunc(__index.SetPortraitZoom)
              end,
              SetPosition = function()
                return checkCFunc(__index.SetPosition)
              end,
              SetPropagateKeyboardInput = function()
                return checkCFunc(__index.SetPropagateKeyboardInput)
              end,
              SetResizable = function()
                return checkCFunc(__index.SetResizable)
              end,
              SetRoll = function()
                return checkCFunc(__index.SetRoll)
              end,
              SetRotation = function()
                return checkCFunc(__index.SetRotation)
              end,
              SetScale = function()
                return checkCFunc(__index.SetScale)
              end,
              SetScript = function()
                return checkCFunc(__index.SetScript)
              end,
              SetSequence = function()
                return checkCFunc(__index.SetSequence)
              end,
              SetSequenceTime = function()
                return checkCFunc(__index.SetSequenceTime)
              end,
              SetShadowEffect = function()
                return checkCFunc(__index.SetShadowEffect)
              end,
              SetSheathed = function()
                return checkCFunc(__index.SetSheathed)
              end,
              SetShown = function()
                return checkCFunc(__index.SetShown)
              end,
              SetSize = function()
                return checkCFunc(__index.SetSize)
              end,
              SetToplevel = function()
                return checkCFunc(__index.SetToplevel)
              end,
              SetTransform = function()
                return checkCFunc(__index.SetTransform)
              end,
              SetUnit = function()
                return checkCFunc(__index.SetUnit)
              end,
              SetUseTransmogChoices = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetUseTransmogChoices))
                  return
                end
                return checkCFunc(__index.SetUseTransmogChoices)
              end,
              SetUseTransmogSkin = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetUseTransmogSkin))
                  return
                end
                return checkCFunc(__index.SetUseTransmogSkin)
              end,
              SetUserPlaced = function()
                return checkCFunc(__index.SetUserPlaced)
              end,
              SetViewInsets = function()
                return checkCFunc(__index.SetViewInsets)
              end,
              SetViewTranslation = function()
                return checkCFunc(__index.SetViewTranslation)
              end,
              SetWidth = function()
                return checkCFunc(__index.SetWidth)
              end,
              Show = function()
                return checkCFunc(__index.Show)
              end,
              StartMoving = function()
                return checkCFunc(__index.StartMoving)
              end,
              StartSizing = function()
                return checkCFunc(__index.StartSizing)
              end,
              StopAnimKit = function()
                return checkCFunc(__index.StopAnimKit)
              end,
              StopAnimating = function()
                return checkCFunc(__index.StopAnimating)
              end,
              StopMovingOrSizing = function()
                return checkCFunc(__index.StopMovingOrSizing)
              end,
              TransformCameraSpaceToModelSpace = function()
                return checkCFunc(__index.TransformCameraSpaceToModelSpace)
              end,
              TryOn = function()
                return checkCFunc(__index.TryOn)
              end,
              Undress = function()
                return checkCFunc(__index.Undress)
              end,
              UndressSlot = function()
                return checkCFunc(__index.UndressSlot)
              end,
              UnregisterAllEvents = function()
                return checkCFunc(__index.UnregisterAllEvents)
              end,
              UnregisterEvent = function()
                return checkCFunc(__index.UnregisterEvent)
              end,
              UseModelCenterToTransform = function()
                return checkCFunc(__index.UseModelCenterToTransform)
              end,
              ZeroCachedCenterXY = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.ZeroCachedCenterXY))
                  return
                end
                return checkCFunc(__index.ZeroCachedCenterXY)
              end,
            }
          end)
        end,
        EditBox = function()
          local function factory()
            return assertCreateFrame('EditBox')
          end
          return mkTests('EditBox', factory, function(__index)
            return {
              AddHistoryLine = function()
                return checkCFunc(__index.AddHistoryLine)
              end,
              AdjustPointsOffset = function()
                return checkCFunc(__index.AdjustPointsOffset)
              end,
              CanChangeAttribute = function()
                return checkCFunc(__index.CanChangeAttribute)
              end,
              CanChangeProtectedState = function()
                return checkCFunc(__index.CanChangeProtectedState)
              end,
              ClearAllPoints = function()
                return checkCFunc(__index.ClearAllPoints)
              end,
              ClearFocus = function()
                return checkCFunc(__index.ClearFocus)
              end,
              ClearHighlightText = function()
                return checkCFunc(__index.ClearHighlightText)
              end,
              ClearHistory = function()
                return checkCFunc(__index.ClearHistory)
              end,
              ClearPointByName = function()
                return checkCFunc(__index.ClearPointByName)
              end,
              ClearPointsOffset = function()
                return checkCFunc(__index.ClearPointsOffset)
              end,
              CreateAnimationGroup = function()
                return checkCFunc(__index.CreateAnimationGroup)
              end,
              CreateFontString = function()
                return checkCFunc(__index.CreateFontString)
              end,
              CreateLine = function()
                return checkCFunc(__index.CreateLine)
              end,
              CreateMaskTexture = function()
                return checkCFunc(__index.CreateMaskTexture)
              end,
              CreateTexture = function()
                return checkCFunc(__index.CreateTexture)
              end,
              DesaturateHierarchy = function()
                return checkCFunc(__index.DesaturateHierarchy)
              end,
              Disable = function()
                return checkCFunc(__index.Disable)
              end,
              DisableDrawLayer = function()
                return checkCFunc(__index.DisableDrawLayer)
              end,
              DoesClipChildren = function()
                return checkCFunc(__index.DoesClipChildren)
              end,
              Enable = function()
                return checkCFunc(__index.Enable)
              end,
              EnableDrawLayer = function()
                return checkCFunc(__index.EnableDrawLayer)
              end,
              EnableGamePadButton = function()
                return checkCFunc(__index.EnableGamePadButton)
              end,
              EnableGamePadStick = function()
                return checkCFunc(__index.EnableGamePadStick)
              end,
              EnableKeyboard = function()
                return checkCFunc(__index.EnableKeyboard)
              end,
              EnableMouse = function()
                return checkCFunc(__index.EnableMouse)
              end,
              EnableMouseWheel = function()
                return checkCFunc(__index.EnableMouseWheel)
              end,
              ExecuteAttribute = function()
                return checkCFunc(__index.ExecuteAttribute)
              end,
              GetAlpha = function()
                return checkCFunc(__index.GetAlpha)
              end,
              GetAltArrowKeyMode = function()
                return checkCFunc(__index.GetAltArrowKeyMode)
              end,
              GetAnimationGroups = function()
                return checkCFunc(__index.GetAnimationGroups)
              end,
              GetAttribute = function()
                return checkCFunc(__index.GetAttribute)
              end,
              GetBlinkSpeed = function()
                return checkCFunc(__index.GetBlinkSpeed)
              end,
              GetBottom = function()
                return checkCFunc(__index.GetBottom)
              end,
              GetBoundsRect = function()
                return checkCFunc(__index.GetBoundsRect)
              end,
              GetCenter = function()
                return checkCFunc(__index.GetCenter)
              end,
              GetChildren = function()
                return checkCFunc(__index.GetChildren)
              end,
              GetClampRectInsets = function()
                return checkCFunc(__index.GetClampRectInsets)
              end,
              GetCursorPosition = function()
                return checkCFunc(__index.GetCursorPosition)
              end,
              GetDebugName = function()
                return checkCFunc(__index.GetDebugName)
              end,
              GetDepth = function()
                return checkCFunc(__index.GetDepth)
              end,
              GetDisplayText = function()
                return checkCFunc(__index.GetDisplayText)
              end,
              GetDontSavePosition = function()
                return checkCFunc(__index.GetDontSavePosition)
              end,
              GetEffectiveAlpha = function()
                return checkCFunc(__index.GetEffectiveAlpha)
              end,
              GetEffectiveDepth = function()
                return checkCFunc(__index.GetEffectiveDepth)
              end,
              GetEffectiveScale = function()
                return checkCFunc(__index.GetEffectiveScale)
              end,
              GetEffectivelyFlattensRenderLayers = function()
                return checkCFunc(__index.GetEffectivelyFlattensRenderLayers)
              end,
              GetFlattensRenderLayers = function()
                return checkCFunc(__index.GetFlattensRenderLayers)
              end,
              GetFont = function()
                return checkCFunc(__index.GetFont)
              end,
              GetFontObject = function()
                return checkCFunc(__index.GetFontObject)
              end,
              GetFrameLevel = function()
                return checkCFunc(__index.GetFrameLevel)
              end,
              GetFrameStrata = function()
                return checkCFunc(__index.GetFrameStrata)
              end,
              GetHeight = function()
                return checkCFunc(__index.GetHeight)
              end,
              GetHighlightColor = function()
                return checkCFunc(__index.GetHighlightColor)
              end,
              GetHistoryLines = function()
                return checkCFunc(__index.GetHistoryLines)
              end,
              GetHitRectInsets = function()
                return checkCFunc(__index.GetHitRectInsets)
              end,
              GetHyperlinksEnabled = function()
                return checkCFunc(__index.GetHyperlinksEnabled)
              end,
              GetID = function()
                return checkCFunc(__index.GetID)
              end,
              GetIndentedWordWrap = function()
                return checkCFunc(__index.GetIndentedWordWrap)
              end,
              GetInputLanguage = function()
                return checkCFunc(__index.GetInputLanguage)
              end,
              GetJustifyH = function()
                return checkCFunc(__index.GetJustifyH)
              end,
              GetJustifyV = function()
                return checkCFunc(__index.GetJustifyV)
              end,
              GetLeft = function()
                return checkCFunc(__index.GetLeft)
              end,
              GetMaxBytes = function()
                return checkCFunc(__index.GetMaxBytes)
              end,
              GetMaxLetters = function()
                return checkCFunc(__index.GetMaxLetters)
              end,
              GetMaxResize = function()
                return checkCFunc(__index.GetMaxResize)
              end,
              GetMinResize = function()
                return checkCFunc(__index.GetMinResize)
              end,
              GetName = function()
                return checkCFunc(__index.GetName)
              end,
              GetNumChildren = function()
                return checkCFunc(__index.GetNumChildren)
              end,
              GetNumLetters = function()
                return checkCFunc(__index.GetNumLetters)
              end,
              GetNumPoints = function()
                return checkCFunc(__index.GetNumPoints)
              end,
              GetNumRegions = function()
                return checkCFunc(__index.GetNumRegions)
              end,
              GetNumber = function()
                return checkCFunc(__index.GetNumber)
              end,
              GetObjectType = function()
                return checkCFunc(__index.GetObjectType)
              end,
              GetParent = function()
                return checkCFunc(__index.GetParent)
              end,
              GetPoint = function()
                return checkCFunc(__index.GetPoint)
              end,
              GetPointByName = function()
                return checkCFunc(__index.GetPointByName)
              end,
              GetPropagateKeyboardInput = function()
                return checkCFunc(__index.GetPropagateKeyboardInput)
              end,
              GetRect = function()
                return checkCFunc(__index.GetRect)
              end,
              GetRegions = function()
                return checkCFunc(__index.GetRegions)
              end,
              GetRight = function()
                return checkCFunc(__index.GetRight)
              end,
              GetScale = function()
                return checkCFunc(__index.GetScale)
              end,
              GetScaledRect = function()
                return checkCFunc(__index.GetScaledRect)
              end,
              GetScript = function()
                return checkCFunc(__index.GetScript)
              end,
              GetShadowColor = function()
                return checkCFunc(__index.GetShadowColor)
              end,
              GetShadowOffset = function()
                return checkCFunc(__index.GetShadowOffset)
              end,
              GetSize = function()
                return checkCFunc(__index.GetSize)
              end,
              GetSourceLocation = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetSourceLocation))
                  return
                end
                return checkCFunc(__index.GetSourceLocation)
              end,
              GetSpacing = function()
                return checkCFunc(__index.GetSpacing)
              end,
              GetText = function()
                return checkCFunc(__index.GetText)
              end,
              GetTextColor = function()
                return checkCFunc(__index.GetTextColor)
              end,
              GetTextInsets = function()
                return checkCFunc(__index.GetTextInsets)
              end,
              GetTop = function()
                return checkCFunc(__index.GetTop)
              end,
              GetUTF8CursorPosition = function()
                return checkCFunc(__index.GetUTF8CursorPosition)
              end,
              GetVisibleTextByteLimit = function()
                return checkCFunc(__index.GetVisibleTextByteLimit)
              end,
              GetWidth = function()
                return checkCFunc(__index.GetWidth)
              end,
              HasFixedFrameLevel = function()
                return checkCFunc(__index.HasFixedFrameLevel)
              end,
              HasFixedFrameStrata = function()
                return checkCFunc(__index.HasFixedFrameStrata)
              end,
              HasFocus = function()
                return checkCFunc(__index.HasFocus)
              end,
              HasScript = function()
                return checkCFunc(__index.HasScript)
              end,
              Hide = function()
                return checkCFunc(__index.Hide)
              end,
              HighlightText = function()
                return checkCFunc(__index.HighlightText)
              end,
              HookScript = function()
                return checkCFunc(__index.HookScript)
              end,
              IgnoreDepth = function()
                return checkCFunc(__index.IgnoreDepth)
              end,
              Insert = function()
                return checkCFunc(__index.Insert)
              end,
              IsAnchoringRestricted = function()
                return checkCFunc(__index.IsAnchoringRestricted)
              end,
              IsAutoFocus = function()
                return checkCFunc(__index.IsAutoFocus)
              end,
              IsClampedToScreen = function()
                return checkCFunc(__index.IsClampedToScreen)
              end,
              IsCountInvisibleLetters = function()
                return checkCFunc(__index.IsCountInvisibleLetters)
              end,
              IsDragging = function()
                return checkCFunc(__index.IsDragging)
              end,
              IsEnabled = function()
                return checkCFunc(__index.IsEnabled)
              end,
              IsEventRegistered = function()
                return checkCFunc(__index.IsEventRegistered)
              end,
              IsForbidden = function()
                return checkCFunc(__index.IsForbidden)
              end,
              IsGamePadButtonEnabled = function()
                return checkCFunc(__index.IsGamePadButtonEnabled)
              end,
              IsGamePadStickEnabled = function()
                return checkCFunc(__index.IsGamePadStickEnabled)
              end,
              IsIgnoringDepth = function()
                return checkCFunc(__index.IsIgnoringDepth)
              end,
              IsIgnoringParentAlpha = function()
                return checkCFunc(__index.IsIgnoringParentAlpha)
              end,
              IsIgnoringParentScale = function()
                return checkCFunc(__index.IsIgnoringParentScale)
              end,
              IsInIMECompositionMode = function()
                return checkCFunc(__index.IsInIMECompositionMode)
              end,
              IsKeyboardEnabled = function()
                return checkCFunc(__index.IsKeyboardEnabled)
              end,
              IsMouseClickEnabled = function()
                return checkCFunc(__index.IsMouseClickEnabled)
              end,
              IsMouseEnabled = function()
                return checkCFunc(__index.IsMouseEnabled)
              end,
              IsMouseMotionEnabled = function()
                return checkCFunc(__index.IsMouseMotionEnabled)
              end,
              IsMouseOver = function()
                return checkCFunc(__index.IsMouseOver)
              end,
              IsMouseWheelEnabled = function()
                return checkCFunc(__index.IsMouseWheelEnabled)
              end,
              IsMovable = function()
                return checkCFunc(__index.IsMovable)
              end,
              IsMultiLine = function()
                return checkCFunc(__index.IsMultiLine)
              end,
              IsNumeric = function()
                return checkCFunc(__index.IsNumeric)
              end,
              IsObjectLoaded = function()
                return checkCFunc(__index.IsObjectLoaded)
              end,
              IsObjectType = function()
                return checkCFunc(__index.IsObjectType)
              end,
              IsPassword = function()
                return checkCFunc(__index.IsPassword)
              end,
              IsProtected = function()
                return checkCFunc(__index.IsProtected)
              end,
              IsRectValid = function()
                return checkCFunc(__index.IsRectValid)
              end,
              IsResizable = function()
                return checkCFunc(__index.IsResizable)
              end,
              IsSecureText = function()
                return checkCFunc(__index.IsSecureText)
              end,
              IsShown = function()
                return checkCFunc(__index.IsShown)
              end,
              IsToplevel = function()
                return checkCFunc(__index.IsToplevel)
              end,
              IsUserPlaced = function()
                return checkCFunc(__index.IsUserPlaced)
              end,
              IsVisible = function()
                return checkCFunc(__index.IsVisible)
              end,
              Lower = function()
                return checkCFunc(__index.Lower)
              end,
              Raise = function()
                return checkCFunc(__index.Raise)
              end,
              RegisterAllEvents = function()
                return checkCFunc(__index.RegisterAllEvents)
              end,
              RegisterEvent = function()
                return checkCFunc(__index.RegisterEvent)
              end,
              RegisterForDrag = function()
                return checkCFunc(__index.RegisterForDrag)
              end,
              RegisterUnitEvent = function()
                return checkCFunc(__index.RegisterUnitEvent)
              end,
              RotateTextures = function()
                return checkCFunc(__index.RotateTextures)
              end,
              SetAllPoints = function()
                return checkCFunc(__index.SetAllPoints)
              end,
              SetAlpha = function()
                return checkCFunc(__index.SetAlpha)
              end,
              SetAltArrowKeyMode = function()
                return checkCFunc(__index.SetAltArrowKeyMode)
              end,
              SetAttribute = function()
                return checkCFunc(__index.SetAttribute)
              end,
              SetAttributeNoHandler = function()
                return checkCFunc(__index.SetAttributeNoHandler)
              end,
              SetAutoFocus = function()
                return checkCFunc(__index.SetAutoFocus)
              end,
              SetBlinkSpeed = function()
                return checkCFunc(__index.SetBlinkSpeed)
              end,
              SetClampRectInsets = function()
                return checkCFunc(__index.SetClampRectInsets)
              end,
              SetClampedToScreen = function()
                return checkCFunc(__index.SetClampedToScreen)
              end,
              SetClipsChildren = function()
                return checkCFunc(__index.SetClipsChildren)
              end,
              SetCountInvisibleLetters = function()
                return checkCFunc(__index.SetCountInvisibleLetters)
              end,
              SetCursorPosition = function()
                return checkCFunc(__index.SetCursorPosition)
              end,
              SetDepth = function()
                return checkCFunc(__index.SetDepth)
              end,
              SetDontSavePosition = function()
                return checkCFunc(__index.SetDontSavePosition)
              end,
              SetDrawLayerEnabled = function()
                return checkCFunc(__index.SetDrawLayerEnabled)
              end,
              SetEnabled = function()
                return checkCFunc(__index.SetEnabled)
              end,
              SetFixedFrameLevel = function()
                return checkCFunc(__index.SetFixedFrameLevel)
              end,
              SetFixedFrameStrata = function()
                return checkCFunc(__index.SetFixedFrameStrata)
              end,
              SetFlattensRenderLayers = function()
                return checkCFunc(__index.SetFlattensRenderLayers)
              end,
              SetFocus = function()
                return checkCFunc(__index.SetFocus)
              end,
              SetFont = function()
                return checkCFunc(__index.SetFont)
              end,
              SetFontObject = function()
                return checkCFunc(__index.SetFontObject)
              end,
              SetForbidden = function()
                return checkCFunc(__index.SetForbidden)
              end,
              SetFrameBuffer = function()
                return checkCFunc(__index.SetFrameBuffer)
              end,
              SetFrameLevel = function()
                return checkCFunc(__index.SetFrameLevel)
              end,
              SetFrameStrata = function()
                return checkCFunc(__index.SetFrameStrata)
              end,
              SetHeight = function()
                return checkCFunc(__index.SetHeight)
              end,
              SetHighlightColor = function()
                return checkCFunc(__index.SetHighlightColor)
              end,
              SetHistoryLines = function()
                return checkCFunc(__index.SetHistoryLines)
              end,
              SetHitRectInsets = function()
                return checkCFunc(__index.SetHitRectInsets)
              end,
              SetHyperlinksEnabled = function()
                return checkCFunc(__index.SetHyperlinksEnabled)
              end,
              SetID = function()
                return checkCFunc(__index.SetID)
              end,
              SetIgnoreParentAlpha = function()
                return checkCFunc(__index.SetIgnoreParentAlpha)
              end,
              SetIgnoreParentScale = function()
                return checkCFunc(__index.SetIgnoreParentScale)
              end,
              SetIndentedWordWrap = function()
                return checkCFunc(__index.SetIndentedWordWrap)
              end,
              SetJustifyH = function()
                return checkCFunc(__index.SetJustifyH)
              end,
              SetJustifyV = function()
                return checkCFunc(__index.SetJustifyV)
              end,
              SetMaxBytes = function()
                return checkCFunc(__index.SetMaxBytes)
              end,
              SetMaxLetters = function()
                return checkCFunc(__index.SetMaxLetters)
              end,
              SetMaxResize = function()
                return checkCFunc(__index.SetMaxResize)
              end,
              SetMinResize = function()
                return checkCFunc(__index.SetMinResize)
              end,
              SetMouseClickEnabled = function()
                return checkCFunc(__index.SetMouseClickEnabled)
              end,
              SetMouseMotionEnabled = function()
                return checkCFunc(__index.SetMouseMotionEnabled)
              end,
              SetMovable = function()
                return checkCFunc(__index.SetMovable)
              end,
              SetMultiLine = function()
                return checkCFunc(__index.SetMultiLine)
              end,
              SetNumber = function()
                return checkCFunc(__index.SetNumber)
              end,
              SetNumeric = function()
                return checkCFunc(__index.SetNumeric)
              end,
              SetParent = function()
                return checkCFunc(__index.SetParent)
              end,
              SetPassword = function()
                return checkCFunc(__index.SetPassword)
              end,
              SetPoint = function()
                return checkCFunc(__index.SetPoint)
              end,
              SetPropagateKeyboardInput = function()
                return checkCFunc(__index.SetPropagateKeyboardInput)
              end,
              SetResizable = function()
                return checkCFunc(__index.SetResizable)
              end,
              SetScale = function()
                return checkCFunc(__index.SetScale)
              end,
              SetScript = function()
                return checkCFunc(__index.SetScript)
              end,
              SetSecureText = function()
                return checkCFunc(__index.SetSecureText)
              end,
              SetSecurityDisablePaste = function()
                return checkCFunc(__index.SetSecurityDisablePaste)
              end,
              SetSecurityDisableSetText = function()
                return checkCFunc(__index.SetSecurityDisableSetText)
              end,
              SetShadowColor = function()
                return checkCFunc(__index.SetShadowColor)
              end,
              SetShadowOffset = function()
                return checkCFunc(__index.SetShadowOffset)
              end,
              SetShown = function()
                return checkCFunc(__index.SetShown)
              end,
              SetSize = function()
                return checkCFunc(__index.SetSize)
              end,
              SetSpacing = function()
                return checkCFunc(__index.SetSpacing)
              end,
              SetText = function()
                return checkCFunc(__index.SetText)
              end,
              SetTextColor = function()
                return checkCFunc(__index.SetTextColor)
              end,
              SetTextInsets = function()
                return checkCFunc(__index.SetTextInsets)
              end,
              SetToplevel = function()
                return checkCFunc(__index.SetToplevel)
              end,
              SetUserPlaced = function()
                return checkCFunc(__index.SetUserPlaced)
              end,
              SetVisibleTextByteLimit = function()
                return checkCFunc(__index.SetVisibleTextByteLimit)
              end,
              SetWidth = function()
                return checkCFunc(__index.SetWidth)
              end,
              Show = function()
                return checkCFunc(__index.Show)
              end,
              StartMoving = function()
                return checkCFunc(__index.StartMoving)
              end,
              StartSizing = function()
                return checkCFunc(__index.StartSizing)
              end,
              StopAnimating = function()
                return checkCFunc(__index.StopAnimating)
              end,
              StopMovingOrSizing = function()
                return checkCFunc(__index.StopMovingOrSizing)
              end,
              ToggleInputLanguage = function()
                return checkCFunc(__index.ToggleInputLanguage)
              end,
              UnregisterAllEvents = function()
                return checkCFunc(__index.UnregisterAllEvents)
              end,
              UnregisterEvent = function()
                return checkCFunc(__index.UnregisterEvent)
              end,
            }
          end)
        end,
        FogOfWarFrame = function()
          local function factory()
            return assertCreateFrame('FogOfWarFrame')
          end
          return mkTests('FogOfWarFrame', factory, function(__index)
            return {
              AdjustPointsOffset = function()
                return checkCFunc(__index.AdjustPointsOffset)
              end,
              CanChangeAttribute = function()
                return checkCFunc(__index.CanChangeAttribute)
              end,
              CanChangeProtectedState = function()
                return checkCFunc(__index.CanChangeProtectedState)
              end,
              ClearAllPoints = function()
                return checkCFunc(__index.ClearAllPoints)
              end,
              ClearPointByName = function()
                return checkCFunc(__index.ClearPointByName)
              end,
              ClearPointsOffset = function()
                return checkCFunc(__index.ClearPointsOffset)
              end,
              CreateAnimationGroup = function()
                return checkCFunc(__index.CreateAnimationGroup)
              end,
              CreateFontString = function()
                return checkCFunc(__index.CreateFontString)
              end,
              CreateLine = function()
                return checkCFunc(__index.CreateLine)
              end,
              CreateMaskTexture = function()
                return checkCFunc(__index.CreateMaskTexture)
              end,
              CreateTexture = function()
                return checkCFunc(__index.CreateTexture)
              end,
              DesaturateHierarchy = function()
                return checkCFunc(__index.DesaturateHierarchy)
              end,
              DisableDrawLayer = function()
                return checkCFunc(__index.DisableDrawLayer)
              end,
              DoesClipChildren = function()
                return checkCFunc(__index.DoesClipChildren)
              end,
              EnableDrawLayer = function()
                return checkCFunc(__index.EnableDrawLayer)
              end,
              EnableGamePadButton = function()
                return checkCFunc(__index.EnableGamePadButton)
              end,
              EnableGamePadStick = function()
                return checkCFunc(__index.EnableGamePadStick)
              end,
              EnableKeyboard = function()
                return checkCFunc(__index.EnableKeyboard)
              end,
              EnableMouse = function()
                return checkCFunc(__index.EnableMouse)
              end,
              EnableMouseWheel = function()
                return checkCFunc(__index.EnableMouseWheel)
              end,
              ExecuteAttribute = function()
                return checkCFunc(__index.ExecuteAttribute)
              end,
              GetAlpha = function()
                return checkCFunc(__index.GetAlpha)
              end,
              GetAnimationGroups = function()
                return checkCFunc(__index.GetAnimationGroups)
              end,
              GetAttribute = function()
                return checkCFunc(__index.GetAttribute)
              end,
              GetBottom = function()
                return checkCFunc(__index.GetBottom)
              end,
              GetBoundsRect = function()
                return checkCFunc(__index.GetBoundsRect)
              end,
              GetCenter = function()
                return checkCFunc(__index.GetCenter)
              end,
              GetChildren = function()
                return checkCFunc(__index.GetChildren)
              end,
              GetClampRectInsets = function()
                return checkCFunc(__index.GetClampRectInsets)
              end,
              GetDebugName = function()
                return checkCFunc(__index.GetDebugName)
              end,
              GetDepth = function()
                return checkCFunc(__index.GetDepth)
              end,
              GetDontSavePosition = function()
                return checkCFunc(__index.GetDontSavePosition)
              end,
              GetEffectiveAlpha = function()
                return checkCFunc(__index.GetEffectiveAlpha)
              end,
              GetEffectiveDepth = function()
                return checkCFunc(__index.GetEffectiveDepth)
              end,
              GetEffectiveScale = function()
                return checkCFunc(__index.GetEffectiveScale)
              end,
              GetEffectivelyFlattensRenderLayers = function()
                return checkCFunc(__index.GetEffectivelyFlattensRenderLayers)
              end,
              GetFlattensRenderLayers = function()
                return checkCFunc(__index.GetFlattensRenderLayers)
              end,
              GetFogOfWarBackgroundAtlas = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetFogOfWarBackgroundAtlas))
                  return
                end
                return checkCFunc(__index.GetFogOfWarBackgroundAtlas)
              end,
              GetFogOfWarBackgroundTexture = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetFogOfWarBackgroundTexture))
                  return
                end
                return checkCFunc(__index.GetFogOfWarBackgroundTexture)
              end,
              GetFogOfWarMaskAtlas = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetFogOfWarMaskAtlas))
                  return
                end
                return checkCFunc(__index.GetFogOfWarMaskAtlas)
              end,
              GetFogOfWarMaskTexture = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetFogOfWarMaskTexture))
                  return
                end
                return checkCFunc(__index.GetFogOfWarMaskTexture)
              end,
              GetFrameLevel = function()
                return checkCFunc(__index.GetFrameLevel)
              end,
              GetFrameStrata = function()
                return checkCFunc(__index.GetFrameStrata)
              end,
              GetHeight = function()
                return checkCFunc(__index.GetHeight)
              end,
              GetHitRectInsets = function()
                return checkCFunc(__index.GetHitRectInsets)
              end,
              GetHyperlinksEnabled = function()
                return checkCFunc(__index.GetHyperlinksEnabled)
              end,
              GetID = function()
                return checkCFunc(__index.GetID)
              end,
              GetLeft = function()
                return checkCFunc(__index.GetLeft)
              end,
              GetMaskScalar = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetMaskScalar))
                  return
                end
                return checkCFunc(__index.GetMaskScalar)
              end,
              GetMaxResize = function()
                return checkCFunc(__index.GetMaxResize)
              end,
              GetMinResize = function()
                return checkCFunc(__index.GetMinResize)
              end,
              GetName = function()
                return checkCFunc(__index.GetName)
              end,
              GetNumChildren = function()
                return checkCFunc(__index.GetNumChildren)
              end,
              GetNumPoints = function()
                return checkCFunc(__index.GetNumPoints)
              end,
              GetNumRegions = function()
                return checkCFunc(__index.GetNumRegions)
              end,
              GetObjectType = function()
                return checkCFunc(__index.GetObjectType)
              end,
              GetParent = function()
                return checkCFunc(__index.GetParent)
              end,
              GetPoint = function()
                return checkCFunc(__index.GetPoint)
              end,
              GetPointByName = function()
                return checkCFunc(__index.GetPointByName)
              end,
              GetPropagateKeyboardInput = function()
                return checkCFunc(__index.GetPropagateKeyboardInput)
              end,
              GetRect = function()
                return checkCFunc(__index.GetRect)
              end,
              GetRegions = function()
                return checkCFunc(__index.GetRegions)
              end,
              GetRight = function()
                return checkCFunc(__index.GetRight)
              end,
              GetScale = function()
                return checkCFunc(__index.GetScale)
              end,
              GetScaledRect = function()
                return checkCFunc(__index.GetScaledRect)
              end,
              GetScript = function()
                return checkCFunc(__index.GetScript)
              end,
              GetSize = function()
                return checkCFunc(__index.GetSize)
              end,
              GetSourceLocation = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetSourceLocation))
                  return
                end
                return checkCFunc(__index.GetSourceLocation)
              end,
              GetTop = function()
                return checkCFunc(__index.GetTop)
              end,
              GetUiMapID = function()
                return checkCFunc(__index.GetUiMapID)
              end,
              GetWidth = function()
                return checkCFunc(__index.GetWidth)
              end,
              HasFixedFrameLevel = function()
                return checkCFunc(__index.HasFixedFrameLevel)
              end,
              HasFixedFrameStrata = function()
                return checkCFunc(__index.HasFixedFrameStrata)
              end,
              HasScript = function()
                return checkCFunc(__index.HasScript)
              end,
              Hide = function()
                return checkCFunc(__index.Hide)
              end,
              HookScript = function()
                return checkCFunc(__index.HookScript)
              end,
              IgnoreDepth = function()
                return checkCFunc(__index.IgnoreDepth)
              end,
              IsAnchoringRestricted = function()
                return checkCFunc(__index.IsAnchoringRestricted)
              end,
              IsClampedToScreen = function()
                return checkCFunc(__index.IsClampedToScreen)
              end,
              IsDragging = function()
                return checkCFunc(__index.IsDragging)
              end,
              IsEventRegistered = function()
                return checkCFunc(__index.IsEventRegistered)
              end,
              IsForbidden = function()
                return checkCFunc(__index.IsForbidden)
              end,
              IsGamePadButtonEnabled = function()
                return checkCFunc(__index.IsGamePadButtonEnabled)
              end,
              IsGamePadStickEnabled = function()
                return checkCFunc(__index.IsGamePadStickEnabled)
              end,
              IsIgnoringDepth = function()
                return checkCFunc(__index.IsIgnoringDepth)
              end,
              IsIgnoringParentAlpha = function()
                return checkCFunc(__index.IsIgnoringParentAlpha)
              end,
              IsIgnoringParentScale = function()
                return checkCFunc(__index.IsIgnoringParentScale)
              end,
              IsKeyboardEnabled = function()
                return checkCFunc(__index.IsKeyboardEnabled)
              end,
              IsMouseClickEnabled = function()
                return checkCFunc(__index.IsMouseClickEnabled)
              end,
              IsMouseEnabled = function()
                return checkCFunc(__index.IsMouseEnabled)
              end,
              IsMouseMotionEnabled = function()
                return checkCFunc(__index.IsMouseMotionEnabled)
              end,
              IsMouseOver = function()
                return checkCFunc(__index.IsMouseOver)
              end,
              IsMouseWheelEnabled = function()
                return checkCFunc(__index.IsMouseWheelEnabled)
              end,
              IsMovable = function()
                return checkCFunc(__index.IsMovable)
              end,
              IsObjectLoaded = function()
                return checkCFunc(__index.IsObjectLoaded)
              end,
              IsObjectType = function()
                return checkCFunc(__index.IsObjectType)
              end,
              IsProtected = function()
                return checkCFunc(__index.IsProtected)
              end,
              IsRectValid = function()
                return checkCFunc(__index.IsRectValid)
              end,
              IsResizable = function()
                return checkCFunc(__index.IsResizable)
              end,
              IsShown = function()
                return checkCFunc(__index.IsShown)
              end,
              IsToplevel = function()
                return checkCFunc(__index.IsToplevel)
              end,
              IsUserPlaced = function()
                return checkCFunc(__index.IsUserPlaced)
              end,
              IsVisible = function()
                return checkCFunc(__index.IsVisible)
              end,
              Lower = function()
                return checkCFunc(__index.Lower)
              end,
              Raise = function()
                return checkCFunc(__index.Raise)
              end,
              RegisterAllEvents = function()
                return checkCFunc(__index.RegisterAllEvents)
              end,
              RegisterEvent = function()
                return checkCFunc(__index.RegisterEvent)
              end,
              RegisterForDrag = function()
                return checkCFunc(__index.RegisterForDrag)
              end,
              RegisterUnitEvent = function()
                return checkCFunc(__index.RegisterUnitEvent)
              end,
              RotateTextures = function()
                return checkCFunc(__index.RotateTextures)
              end,
              SetAllPoints = function()
                return checkCFunc(__index.SetAllPoints)
              end,
              SetAlpha = function()
                return checkCFunc(__index.SetAlpha)
              end,
              SetAttribute = function()
                return checkCFunc(__index.SetAttribute)
              end,
              SetAttributeNoHandler = function()
                return checkCFunc(__index.SetAttributeNoHandler)
              end,
              SetClampRectInsets = function()
                return checkCFunc(__index.SetClampRectInsets)
              end,
              SetClampedToScreen = function()
                return checkCFunc(__index.SetClampedToScreen)
              end,
              SetClipsChildren = function()
                return checkCFunc(__index.SetClipsChildren)
              end,
              SetDepth = function()
                return checkCFunc(__index.SetDepth)
              end,
              SetDontSavePosition = function()
                return checkCFunc(__index.SetDontSavePosition)
              end,
              SetDrawLayerEnabled = function()
                return checkCFunc(__index.SetDrawLayerEnabled)
              end,
              SetFixedFrameLevel = function()
                return checkCFunc(__index.SetFixedFrameLevel)
              end,
              SetFixedFrameStrata = function()
                return checkCFunc(__index.SetFixedFrameStrata)
              end,
              SetFlattensRenderLayers = function()
                return checkCFunc(__index.SetFlattensRenderLayers)
              end,
              SetFogOfWarBackgroundAtlas = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetFogOfWarBackgroundAtlas))
                  return
                end
                return checkCFunc(__index.SetFogOfWarBackgroundAtlas)
              end,
              SetFogOfWarBackgroundTexture = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetFogOfWarBackgroundTexture))
                  return
                end
                return checkCFunc(__index.SetFogOfWarBackgroundTexture)
              end,
              SetFogOfWarMaskAtlas = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetFogOfWarMaskAtlas))
                  return
                end
                return checkCFunc(__index.SetFogOfWarMaskAtlas)
              end,
              SetFogOfWarMaskTexture = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetFogOfWarMaskTexture))
                  return
                end
                return checkCFunc(__index.SetFogOfWarMaskTexture)
              end,
              SetForbidden = function()
                return checkCFunc(__index.SetForbidden)
              end,
              SetFrameBuffer = function()
                return checkCFunc(__index.SetFrameBuffer)
              end,
              SetFrameLevel = function()
                return checkCFunc(__index.SetFrameLevel)
              end,
              SetFrameStrata = function()
                return checkCFunc(__index.SetFrameStrata)
              end,
              SetHeight = function()
                return checkCFunc(__index.SetHeight)
              end,
              SetHitRectInsets = function()
                return checkCFunc(__index.SetHitRectInsets)
              end,
              SetHyperlinksEnabled = function()
                return checkCFunc(__index.SetHyperlinksEnabled)
              end,
              SetID = function()
                return checkCFunc(__index.SetID)
              end,
              SetIgnoreParentAlpha = function()
                return checkCFunc(__index.SetIgnoreParentAlpha)
              end,
              SetIgnoreParentScale = function()
                return checkCFunc(__index.SetIgnoreParentScale)
              end,
              SetMaskScalar = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetMaskScalar))
                  return
                end
                return checkCFunc(__index.SetMaskScalar)
              end,
              SetMaxResize = function()
                return checkCFunc(__index.SetMaxResize)
              end,
              SetMinResize = function()
                return checkCFunc(__index.SetMinResize)
              end,
              SetMouseClickEnabled = function()
                return checkCFunc(__index.SetMouseClickEnabled)
              end,
              SetMouseMotionEnabled = function()
                return checkCFunc(__index.SetMouseMotionEnabled)
              end,
              SetMovable = function()
                return checkCFunc(__index.SetMovable)
              end,
              SetParent = function()
                return checkCFunc(__index.SetParent)
              end,
              SetPoint = function()
                return checkCFunc(__index.SetPoint)
              end,
              SetPropagateKeyboardInput = function()
                return checkCFunc(__index.SetPropagateKeyboardInput)
              end,
              SetResizable = function()
                return checkCFunc(__index.SetResizable)
              end,
              SetScale = function()
                return checkCFunc(__index.SetScale)
              end,
              SetScript = function()
                return checkCFunc(__index.SetScript)
              end,
              SetShown = function()
                return checkCFunc(__index.SetShown)
              end,
              SetSize = function()
                return checkCFunc(__index.SetSize)
              end,
              SetToplevel = function()
                return checkCFunc(__index.SetToplevel)
              end,
              SetUiMapID = function()
                return checkCFunc(__index.SetUiMapID)
              end,
              SetUserPlaced = function()
                return checkCFunc(__index.SetUserPlaced)
              end,
              SetWidth = function()
                return checkCFunc(__index.SetWidth)
              end,
              Show = function()
                return checkCFunc(__index.Show)
              end,
              StartMoving = function()
                return checkCFunc(__index.StartMoving)
              end,
              StartSizing = function()
                return checkCFunc(__index.StartSizing)
              end,
              StopAnimating = function()
                return checkCFunc(__index.StopAnimating)
              end,
              StopMovingOrSizing = function()
                return checkCFunc(__index.StopMovingOrSizing)
              end,
              UnregisterAllEvents = function()
                return checkCFunc(__index.UnregisterAllEvents)
              end,
              UnregisterEvent = function()
                return checkCFunc(__index.UnregisterEvent)
              end,
            }
          end)
        end,
        Font = function()
          assertCreateFrameFails('Font')
        end,
        FontInstance = function()
          assertCreateFrameFails('FontInstance')
        end,
        FontString = function()
          local function factory()
            return CreateFrame('Frame'):CreateFontString()
          end
          return mkTests('FontString', factory, function(__index)
            return {
              AdjustPointsOffset = function()
                return checkCFunc(__index.AdjustPointsOffset)
              end,
              CalculateScreenAreaFromCharacterSpan = function()
                return checkCFunc(__index.CalculateScreenAreaFromCharacterSpan)
              end,
              CanChangeProtectedState = function()
                return checkCFunc(__index.CanChangeProtectedState)
              end,
              CanNonSpaceWrap = function()
                return checkCFunc(__index.CanNonSpaceWrap)
              end,
              CanWordWrap = function()
                return checkCFunc(__index.CanWordWrap)
              end,
              ClearAllPoints = function()
                return checkCFunc(__index.ClearAllPoints)
              end,
              ClearPointByName = function()
                return checkCFunc(__index.ClearPointByName)
              end,
              ClearPointsOffset = function()
                return checkCFunc(__index.ClearPointsOffset)
              end,
              CreateAnimationGroup = function()
                return checkCFunc(__index.CreateAnimationGroup)
              end,
              FindCharacterIndexAtCoordinate = function()
                return checkCFunc(__index.FindCharacterIndexAtCoordinate)
              end,
              GetAlpha = function()
                return checkCFunc(__index.GetAlpha)
              end,
              GetAnimationGroups = function()
                return checkCFunc(__index.GetAnimationGroups)
              end,
              GetBottom = function()
                return checkCFunc(__index.GetBottom)
              end,
              GetCenter = function()
                return checkCFunc(__index.GetCenter)
              end,
              GetDebugName = function()
                return checkCFunc(__index.GetDebugName)
              end,
              GetDrawLayer = function()
                return checkCFunc(__index.GetDrawLayer)
              end,
              GetEffectiveScale = function()
                return checkCFunc(__index.GetEffectiveScale)
              end,
              GetFieldSize = function()
                return checkCFunc(__index.GetFieldSize)
              end,
              GetFont = function()
                return checkCFunc(__index.GetFont)
              end,
              GetFontObject = function()
                return checkCFunc(__index.GetFontObject)
              end,
              GetHeight = function()
                return checkCFunc(__index.GetHeight)
              end,
              GetIndentedWordWrap = function()
                return checkCFunc(__index.GetIndentedWordWrap)
              end,
              GetJustifyH = function()
                return checkCFunc(__index.GetJustifyH)
              end,
              GetJustifyV = function()
                return checkCFunc(__index.GetJustifyV)
              end,
              GetLeft = function()
                return checkCFunc(__index.GetLeft)
              end,
              GetLineHeight = function()
                return checkCFunc(__index.GetLineHeight)
              end,
              GetMaxLines = function()
                return checkCFunc(__index.GetMaxLines)
              end,
              GetName = function()
                return checkCFunc(__index.GetName)
              end,
              GetNumLines = function()
                return checkCFunc(__index.GetNumLines)
              end,
              GetNumPoints = function()
                return checkCFunc(__index.GetNumPoints)
              end,
              GetObjectType = function()
                return checkCFunc(__index.GetObjectType)
              end,
              GetParent = function()
                return checkCFunc(__index.GetParent)
              end,
              GetPoint = function()
                return checkCFunc(__index.GetPoint)
              end,
              GetPointByName = function()
                return checkCFunc(__index.GetPointByName)
              end,
              GetRect = function()
                return checkCFunc(__index.GetRect)
              end,
              GetRight = function()
                return checkCFunc(__index.GetRight)
              end,
              GetScale = function()
                return checkCFunc(__index.GetScale)
              end,
              GetScaledRect = function()
                return checkCFunc(__index.GetScaledRect)
              end,
              GetShadowColor = function()
                return checkCFunc(__index.GetShadowColor)
              end,
              GetShadowOffset = function()
                return checkCFunc(__index.GetShadowOffset)
              end,
              GetSize = function()
                return checkCFunc(__index.GetSize)
              end,
              GetSourceLocation = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetSourceLocation))
                  return
                end
                return checkCFunc(__index.GetSourceLocation)
              end,
              GetSpacing = function()
                return checkCFunc(__index.GetSpacing)
              end,
              GetStringHeight = function()
                return checkCFunc(__index.GetStringHeight)
              end,
              GetStringWidth = function()
                return checkCFunc(__index.GetStringWidth)
              end,
              GetText = function()
                return checkCFunc(__index.GetText)
              end,
              GetTextColor = function()
                return checkCFunc(__index.GetTextColor)
              end,
              GetTextScale = function()
                return checkCFunc(__index.GetTextScale)
              end,
              GetTop = function()
                return checkCFunc(__index.GetTop)
              end,
              GetUnboundedStringWidth = function()
                return checkCFunc(__index.GetUnboundedStringWidth)
              end,
              GetWidth = function()
                return checkCFunc(__index.GetWidth)
              end,
              GetWrappedWidth = function()
                return checkCFunc(__index.GetWrappedWidth)
              end,
              Hide = function()
                return checkCFunc(__index.Hide)
              end,
              IsAnchoringRestricted = function()
                return checkCFunc(__index.IsAnchoringRestricted)
              end,
              IsDragging = function()
                return checkCFunc(__index.IsDragging)
              end,
              IsForbidden = function()
                return checkCFunc(__index.IsForbidden)
              end,
              IsIgnoringParentAlpha = function()
                return checkCFunc(__index.IsIgnoringParentAlpha)
              end,
              IsIgnoringParentScale = function()
                return checkCFunc(__index.IsIgnoringParentScale)
              end,
              IsMouseOver = function()
                return checkCFunc(__index.IsMouseOver)
              end,
              IsObjectLoaded = function()
                return checkCFunc(__index.IsObjectLoaded)
              end,
              IsObjectType = function()
                return checkCFunc(__index.IsObjectType)
              end,
              IsProtected = function()
                return checkCFunc(__index.IsProtected)
              end,
              IsRectValid = function()
                return checkCFunc(__index.IsRectValid)
              end,
              IsShown = function()
                return checkCFunc(__index.IsShown)
              end,
              IsTruncated = function()
                return checkCFunc(__index.IsTruncated)
              end,
              IsVisible = function()
                return checkCFunc(__index.IsVisible)
              end,
              SetAllPoints = function()
                return checkCFunc(__index.SetAllPoints)
              end,
              SetAlpha = function()
                return checkCFunc(__index.SetAlpha)
              end,
              SetAlphaGradient = function()
                return checkCFunc(__index.SetAlphaGradient)
              end,
              SetDrawLayer = function()
                return checkCFunc(__index.SetDrawLayer)
              end,
              SetFixedColor = function()
                return checkCFunc(__index.SetFixedColor)
              end,
              SetFont = function()
                return checkCFunc(__index.SetFont)
              end,
              SetFontObject = function()
                return checkCFunc(__index.SetFontObject)
              end,
              SetForbidden = function()
                return checkCFunc(__index.SetForbidden)
              end,
              SetFormattedText = function()
                return checkCFunc(__index.SetFormattedText)
              end,
              SetHeight = function()
                return checkCFunc(__index.SetHeight)
              end,
              SetIgnoreParentAlpha = function()
                return checkCFunc(__index.SetIgnoreParentAlpha)
              end,
              SetIgnoreParentScale = function()
                return checkCFunc(__index.SetIgnoreParentScale)
              end,
              SetIndentedWordWrap = function()
                return checkCFunc(__index.SetIndentedWordWrap)
              end,
              SetJustifyH = function()
                return checkCFunc(__index.SetJustifyH)
              end,
              SetJustifyV = function()
                return checkCFunc(__index.SetJustifyV)
              end,
              SetMaxLines = function()
                return checkCFunc(__index.SetMaxLines)
              end,
              SetNonSpaceWrap = function()
                return checkCFunc(__index.SetNonSpaceWrap)
              end,
              SetParent = function()
                return checkCFunc(__index.SetParent)
              end,
              SetPoint = function()
                return checkCFunc(__index.SetPoint)
              end,
              SetScale = function()
                return checkCFunc(__index.SetScale)
              end,
              SetShadowColor = function()
                return checkCFunc(__index.SetShadowColor)
              end,
              SetShadowOffset = function()
                return checkCFunc(__index.SetShadowOffset)
              end,
              SetShown = function()
                return checkCFunc(__index.SetShown)
              end,
              SetSize = function()
                return checkCFunc(__index.SetSize)
              end,
              SetSpacing = function()
                return checkCFunc(__index.SetSpacing)
              end,
              SetText = function()
                return checkCFunc(__index.SetText)
              end,
              SetTextColor = function()
                return checkCFunc(__index.SetTextColor)
              end,
              SetTextHeight = function()
                return checkCFunc(__index.SetTextHeight)
              end,
              SetTextScale = function()
                return checkCFunc(__index.SetTextScale)
              end,
              SetVertexColor = function()
                return checkCFunc(__index.SetVertexColor)
              end,
              SetWidth = function()
                return checkCFunc(__index.SetWidth)
              end,
              SetWordWrap = function()
                return checkCFunc(__index.SetWordWrap)
              end,
              Show = function()
                return checkCFunc(__index.Show)
              end,
              StopAnimating = function()
                return checkCFunc(__index.StopAnimating)
              end,
            }
          end)
        end,
        Frame = function()
          local function factory()
            return assertCreateFrame('Frame')
          end
          return mkTests('Frame', factory, function(__index)
            return {
              AdjustPointsOffset = function()
                return checkCFunc(__index.AdjustPointsOffset)
              end,
              CanChangeAttribute = function()
                return checkCFunc(__index.CanChangeAttribute)
              end,
              CanChangeProtectedState = function()
                return checkCFunc(__index.CanChangeProtectedState)
              end,
              ClearAllPoints = function()
                return checkCFunc(__index.ClearAllPoints)
              end,
              ClearPointByName = function()
                return checkCFunc(__index.ClearPointByName)
              end,
              ClearPointsOffset = function()
                return checkCFunc(__index.ClearPointsOffset)
              end,
              CreateAnimationGroup = function()
                return checkCFunc(__index.CreateAnimationGroup)
              end,
              CreateFontString = function()
                return checkCFunc(__index.CreateFontString)
              end,
              CreateLine = function()
                return checkCFunc(__index.CreateLine)
              end,
              CreateMaskTexture = function()
                return checkCFunc(__index.CreateMaskTexture)
              end,
              CreateTexture = function()
                return checkCFunc(__index.CreateTexture)
              end,
              DesaturateHierarchy = function()
                return checkCFunc(__index.DesaturateHierarchy)
              end,
              DisableDrawLayer = function()
                return checkCFunc(__index.DisableDrawLayer)
              end,
              DoesClipChildren = function()
                return checkCFunc(__index.DoesClipChildren)
              end,
              EnableDrawLayer = function()
                return checkCFunc(__index.EnableDrawLayer)
              end,
              EnableGamePadButton = function()
                return checkCFunc(__index.EnableGamePadButton)
              end,
              EnableGamePadStick = function()
                return checkCFunc(__index.EnableGamePadStick)
              end,
              EnableKeyboard = function()
                return checkCFunc(__index.EnableKeyboard)
              end,
              EnableMouse = function()
                return checkCFunc(__index.EnableMouse)
              end,
              EnableMouseWheel = function()
                return checkCFunc(__index.EnableMouseWheel)
              end,
              ExecuteAttribute = function()
                return checkCFunc(__index.ExecuteAttribute)
              end,
              GetAlpha = function()
                return checkCFunc(__index.GetAlpha)
              end,
              GetAnimationGroups = function()
                return checkCFunc(__index.GetAnimationGroups)
              end,
              GetAttribute = function()
                return checkCFunc(__index.GetAttribute)
              end,
              GetBottom = function()
                return checkCFunc(__index.GetBottom)
              end,
              GetBoundsRect = function()
                return checkCFunc(__index.GetBoundsRect)
              end,
              GetCenter = function()
                return checkCFunc(__index.GetCenter)
              end,
              GetChildren = function()
                return checkCFunc(__index.GetChildren)
              end,
              GetClampRectInsets = function()
                return checkCFunc(__index.GetClampRectInsets)
              end,
              GetDebugName = function()
                return checkCFunc(__index.GetDebugName)
              end,
              GetDepth = function()
                return checkCFunc(__index.GetDepth)
              end,
              GetDontSavePosition = function()
                return checkCFunc(__index.GetDontSavePosition)
              end,
              GetEffectiveAlpha = function()
                return checkCFunc(__index.GetEffectiveAlpha)
              end,
              GetEffectiveDepth = function()
                return checkCFunc(__index.GetEffectiveDepth)
              end,
              GetEffectiveScale = function()
                return checkCFunc(__index.GetEffectiveScale)
              end,
              GetEffectivelyFlattensRenderLayers = function()
                return checkCFunc(__index.GetEffectivelyFlattensRenderLayers)
              end,
              GetFlattensRenderLayers = function()
                return checkCFunc(__index.GetFlattensRenderLayers)
              end,
              GetFrameLevel = function()
                return checkCFunc(__index.GetFrameLevel)
              end,
              GetFrameStrata = function()
                return checkCFunc(__index.GetFrameStrata)
              end,
              GetHeight = function()
                return checkCFunc(__index.GetHeight)
              end,
              GetHitRectInsets = function()
                return checkCFunc(__index.GetHitRectInsets)
              end,
              GetHyperlinksEnabled = function()
                return checkCFunc(__index.GetHyperlinksEnabled)
              end,
              GetID = function()
                return checkCFunc(__index.GetID)
              end,
              GetLeft = function()
                return checkCFunc(__index.GetLeft)
              end,
              GetMaxResize = function()
                return checkCFunc(__index.GetMaxResize)
              end,
              GetMinResize = function()
                return checkCFunc(__index.GetMinResize)
              end,
              GetName = function()
                return checkCFunc(__index.GetName)
              end,
              GetNumChildren = function()
                return checkCFunc(__index.GetNumChildren)
              end,
              GetNumPoints = function()
                return checkCFunc(__index.GetNumPoints)
              end,
              GetNumRegions = function()
                return checkCFunc(__index.GetNumRegions)
              end,
              GetObjectType = function()
                return checkCFunc(__index.GetObjectType)
              end,
              GetParent = function()
                return checkCFunc(__index.GetParent)
              end,
              GetPoint = function()
                return checkCFunc(__index.GetPoint)
              end,
              GetPointByName = function()
                return checkCFunc(__index.GetPointByName)
              end,
              GetPropagateKeyboardInput = function()
                return checkCFunc(__index.GetPropagateKeyboardInput)
              end,
              GetRect = function()
                return checkCFunc(__index.GetRect)
              end,
              GetRegions = function()
                return checkCFunc(__index.GetRegions)
              end,
              GetRight = function()
                return checkCFunc(__index.GetRight)
              end,
              GetScale = function()
                return checkCFunc(__index.GetScale)
              end,
              GetScaledRect = function()
                return checkCFunc(__index.GetScaledRect)
              end,
              GetScript = function()
                return checkCFunc(__index.GetScript)
              end,
              GetSize = function()
                return checkCFunc(__index.GetSize)
              end,
              GetSourceLocation = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetSourceLocation))
                  return
                end
                return checkCFunc(__index.GetSourceLocation)
              end,
              GetTop = function()
                return checkCFunc(__index.GetTop)
              end,
              GetWidth = function()
                return checkCFunc(__index.GetWidth)
              end,
              HasFixedFrameLevel = function()
                return checkCFunc(__index.HasFixedFrameLevel)
              end,
              HasFixedFrameStrata = function()
                return checkCFunc(__index.HasFixedFrameStrata)
              end,
              HasScript = function()
                return checkCFunc(__index.HasScript)
              end,
              Hide = function()
                return checkCFunc(__index.Hide)
              end,
              HookScript = function()
                return checkCFunc(__index.HookScript)
              end,
              IgnoreDepth = function()
                return checkCFunc(__index.IgnoreDepth)
              end,
              IsAnchoringRestricted = function()
                return checkCFunc(__index.IsAnchoringRestricted)
              end,
              IsClampedToScreen = function()
                return checkCFunc(__index.IsClampedToScreen)
              end,
              IsDragging = function()
                return checkCFunc(__index.IsDragging)
              end,
              IsEventRegistered = function()
                return checkCFunc(__index.IsEventRegistered)
              end,
              IsForbidden = function()
                return checkCFunc(__index.IsForbidden)
              end,
              IsGamePadButtonEnabled = function()
                return checkCFunc(__index.IsGamePadButtonEnabled)
              end,
              IsGamePadStickEnabled = function()
                return checkCFunc(__index.IsGamePadStickEnabled)
              end,
              IsIgnoringDepth = function()
                return checkCFunc(__index.IsIgnoringDepth)
              end,
              IsIgnoringParentAlpha = function()
                return checkCFunc(__index.IsIgnoringParentAlpha)
              end,
              IsIgnoringParentScale = function()
                return checkCFunc(__index.IsIgnoringParentScale)
              end,
              IsKeyboardEnabled = function()
                return checkCFunc(__index.IsKeyboardEnabled)
              end,
              IsMouseClickEnabled = function()
                return checkCFunc(__index.IsMouseClickEnabled)
              end,
              IsMouseEnabled = function()
                return checkCFunc(__index.IsMouseEnabled)
              end,
              IsMouseMotionEnabled = function()
                return checkCFunc(__index.IsMouseMotionEnabled)
              end,
              IsMouseOver = function()
                return checkCFunc(__index.IsMouseOver)
              end,
              IsMouseWheelEnabled = function()
                return checkCFunc(__index.IsMouseWheelEnabled)
              end,
              IsMovable = function()
                return checkCFunc(__index.IsMovable)
              end,
              IsObjectLoaded = function()
                return checkCFunc(__index.IsObjectLoaded)
              end,
              IsObjectType = function()
                return checkCFunc(__index.IsObjectType)
              end,
              IsProtected = function()
                return checkCFunc(__index.IsProtected)
              end,
              IsRectValid = function()
                return checkCFunc(__index.IsRectValid)
              end,
              IsResizable = function()
                return checkCFunc(__index.IsResizable)
              end,
              IsShown = function()
                return checkCFunc(__index.IsShown)
              end,
              IsToplevel = function()
                return checkCFunc(__index.IsToplevel)
              end,
              IsUserPlaced = function()
                return checkCFunc(__index.IsUserPlaced)
              end,
              IsVisible = function()
                return checkCFunc(__index.IsVisible)
              end,
              Lower = function()
                return checkCFunc(__index.Lower)
              end,
              Raise = function()
                return checkCFunc(__index.Raise)
              end,
              RegisterAllEvents = function()
                return checkCFunc(__index.RegisterAllEvents)
              end,
              RegisterEvent = function()
                return checkCFunc(__index.RegisterEvent)
              end,
              RegisterForDrag = function()
                return checkCFunc(__index.RegisterForDrag)
              end,
              RegisterUnitEvent = function()
                return checkCFunc(__index.RegisterUnitEvent)
              end,
              RotateTextures = function()
                return checkCFunc(__index.RotateTextures)
              end,
              SetAllPoints = function()
                return checkCFunc(__index.SetAllPoints)
              end,
              SetAlpha = function()
                return checkCFunc(__index.SetAlpha)
              end,
              SetAttribute = function()
                return checkCFunc(__index.SetAttribute)
              end,
              SetAttributeNoHandler = function()
                return checkCFunc(__index.SetAttributeNoHandler)
              end,
              SetClampRectInsets = function()
                return checkCFunc(__index.SetClampRectInsets)
              end,
              SetClampedToScreen = function()
                return checkCFunc(__index.SetClampedToScreen)
              end,
              SetClipsChildren = function()
                return checkCFunc(__index.SetClipsChildren)
              end,
              SetDepth = function()
                return checkCFunc(__index.SetDepth)
              end,
              SetDontSavePosition = function()
                return checkCFunc(__index.SetDontSavePosition)
              end,
              SetDrawLayerEnabled = function()
                return checkCFunc(__index.SetDrawLayerEnabled)
              end,
              SetFixedFrameLevel = function()
                return checkCFunc(__index.SetFixedFrameLevel)
              end,
              SetFixedFrameStrata = function()
                return checkCFunc(__index.SetFixedFrameStrata)
              end,
              SetFlattensRenderLayers = function()
                return checkCFunc(__index.SetFlattensRenderLayers)
              end,
              SetForbidden = function()
                return checkCFunc(__index.SetForbidden)
              end,
              SetFrameBuffer = function()
                return checkCFunc(__index.SetFrameBuffer)
              end,
              SetFrameLevel = function()
                return checkCFunc(__index.SetFrameLevel)
              end,
              SetFrameStrata = function()
                return checkCFunc(__index.SetFrameStrata)
              end,
              SetHeight = function()
                return checkCFunc(__index.SetHeight)
              end,
              SetHitRectInsets = function()
                return checkCFunc(__index.SetHitRectInsets)
              end,
              SetHyperlinksEnabled = function()
                return checkCFunc(__index.SetHyperlinksEnabled)
              end,
              SetID = function()
                return checkCFunc(__index.SetID)
              end,
              SetIgnoreParentAlpha = function()
                return checkCFunc(__index.SetIgnoreParentAlpha)
              end,
              SetIgnoreParentScale = function()
                return checkCFunc(__index.SetIgnoreParentScale)
              end,
              SetMaxResize = function()
                return checkCFunc(__index.SetMaxResize)
              end,
              SetMinResize = function()
                return checkCFunc(__index.SetMinResize)
              end,
              SetMouseClickEnabled = function()
                return checkCFunc(__index.SetMouseClickEnabled)
              end,
              SetMouseMotionEnabled = function()
                return checkCFunc(__index.SetMouseMotionEnabled)
              end,
              SetMovable = function()
                return checkCFunc(__index.SetMovable)
              end,
              SetParent = function()
                return checkCFunc(__index.SetParent)
              end,
              SetPoint = function()
                return checkCFunc(__index.SetPoint)
              end,
              SetPropagateKeyboardInput = function()
                return checkCFunc(__index.SetPropagateKeyboardInput)
              end,
              SetResizable = function()
                return checkCFunc(__index.SetResizable)
              end,
              SetScale = function()
                return checkCFunc(__index.SetScale)
              end,
              SetScript = function()
                return checkCFunc(__index.SetScript)
              end,
              SetShown = function()
                return checkCFunc(__index.SetShown)
              end,
              SetSize = function()
                return checkCFunc(__index.SetSize)
              end,
              SetToplevel = function()
                return checkCFunc(__index.SetToplevel)
              end,
              SetUserPlaced = function()
                return checkCFunc(__index.SetUserPlaced)
              end,
              SetWidth = function()
                return checkCFunc(__index.SetWidth)
              end,
              Show = function()
                return checkCFunc(__index.Show)
              end,
              StartMoving = function()
                return checkCFunc(__index.StartMoving)
              end,
              StartSizing = function()
                return checkCFunc(__index.StartSizing)
              end,
              StopAnimating = function()
                return checkCFunc(__index.StopAnimating)
              end,
              StopMovingOrSizing = function()
                return checkCFunc(__index.StopMovingOrSizing)
              end,
              UnregisterAllEvents = function()
                return checkCFunc(__index.UnregisterAllEvents)
              end,
              UnregisterEvent = function()
                return checkCFunc(__index.UnregisterEvent)
              end,
            }
          end)
        end,
        GameTooltip = function()
          local function factory()
            return assertCreateFrame('GameTooltip')
          end
          return mkTests('GameTooltip', factory, function(__index)
            return {
              AddAtlas = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.AddAtlas))
                  return
                end
                return checkCFunc(__index.AddAtlas)
              end,
              AddDoubleLine = function()
                return checkCFunc(__index.AddDoubleLine)
              end,
              AddFontStrings = function()
                return checkCFunc(__index.AddFontStrings)
              end,
              AddLine = function()
                return checkCFunc(__index.AddLine)
              end,
              AddSpellByID = function()
                return checkCFunc(__index.AddSpellByID)
              end,
              AddTexture = function()
                return checkCFunc(__index.AddTexture)
              end,
              AdjustPointsOffset = function()
                return checkCFunc(__index.AdjustPointsOffset)
              end,
              AdvanceSecondaryCompareItem = function()
                return checkCFunc(__index.AdvanceSecondaryCompareItem)
              end,
              AppendText = function()
                return checkCFunc(__index.AppendText)
              end,
              CanChangeAttribute = function()
                return checkCFunc(__index.CanChangeAttribute)
              end,
              CanChangeProtectedState = function()
                return checkCFunc(__index.CanChangeProtectedState)
              end,
              ClearAllPoints = function()
                return checkCFunc(__index.ClearAllPoints)
              end,
              ClearLines = function()
                return checkCFunc(__index.ClearLines)
              end,
              ClearPointByName = function()
                return checkCFunc(__index.ClearPointByName)
              end,
              ClearPointsOffset = function()
                return checkCFunc(__index.ClearPointsOffset)
              end,
              CopyTooltip = function()
                return checkCFunc(__index.CopyTooltip)
              end,
              CreateAnimationGroup = function()
                return checkCFunc(__index.CreateAnimationGroup)
              end,
              CreateFontString = function()
                return checkCFunc(__index.CreateFontString)
              end,
              CreateLine = function()
                return checkCFunc(__index.CreateLine)
              end,
              CreateMaskTexture = function()
                return checkCFunc(__index.CreateMaskTexture)
              end,
              CreateTexture = function()
                return checkCFunc(__index.CreateTexture)
              end,
              DesaturateHierarchy = function()
                return checkCFunc(__index.DesaturateHierarchy)
              end,
              DisableDrawLayer = function()
                return checkCFunc(__index.DisableDrawLayer)
              end,
              DoesClipChildren = function()
                return checkCFunc(__index.DoesClipChildren)
              end,
              EnableDrawLayer = function()
                return checkCFunc(__index.EnableDrawLayer)
              end,
              EnableGamePadButton = function()
                return checkCFunc(__index.EnableGamePadButton)
              end,
              EnableGamePadStick = function()
                return checkCFunc(__index.EnableGamePadStick)
              end,
              EnableKeyboard = function()
                return checkCFunc(__index.EnableKeyboard)
              end,
              EnableMouse = function()
                return checkCFunc(__index.EnableMouse)
              end,
              EnableMouseWheel = function()
                return checkCFunc(__index.EnableMouseWheel)
              end,
              ExecuteAttribute = function()
                return checkCFunc(__index.ExecuteAttribute)
              end,
              FadeOut = function()
                return checkCFunc(__index.FadeOut)
              end,
              GetAlpha = function()
                return checkCFunc(__index.GetAlpha)
              end,
              GetAnchorType = function()
                return checkCFunc(__index.GetAnchorType)
              end,
              GetAnimationGroups = function()
                return checkCFunc(__index.GetAnimationGroups)
              end,
              GetAttribute = function()
                return checkCFunc(__index.GetAttribute)
              end,
              GetAzeritePowerID = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetAzeritePowerID))
                  return
                end
                return checkCFunc(__index.GetAzeritePowerID)
              end,
              GetBottom = function()
                return checkCFunc(__index.GetBottom)
              end,
              GetBoundsRect = function()
                return checkCFunc(__index.GetBoundsRect)
              end,
              GetCenter = function()
                return checkCFunc(__index.GetCenter)
              end,
              GetChildren = function()
                return checkCFunc(__index.GetChildren)
              end,
              GetClampRectInsets = function()
                return checkCFunc(__index.GetClampRectInsets)
              end,
              GetCustomLineSpacing = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetCustomLineSpacing))
                  return
                end
                return checkCFunc(__index.GetCustomLineSpacing)
              end,
              GetDebugName = function()
                return checkCFunc(__index.GetDebugName)
              end,
              GetDepth = function()
                return checkCFunc(__index.GetDepth)
              end,
              GetDontSavePosition = function()
                return checkCFunc(__index.GetDontSavePosition)
              end,
              GetEffectiveAlpha = function()
                return checkCFunc(__index.GetEffectiveAlpha)
              end,
              GetEffectiveDepth = function()
                return checkCFunc(__index.GetEffectiveDepth)
              end,
              GetEffectiveScale = function()
                return checkCFunc(__index.GetEffectiveScale)
              end,
              GetEffectivelyFlattensRenderLayers = function()
                return checkCFunc(__index.GetEffectivelyFlattensRenderLayers)
              end,
              GetFlattensRenderLayers = function()
                return checkCFunc(__index.GetFlattensRenderLayers)
              end,
              GetFrameLevel = function()
                return checkCFunc(__index.GetFrameLevel)
              end,
              GetFrameStrata = function()
                return checkCFunc(__index.GetFrameStrata)
              end,
              GetHeight = function()
                return checkCFunc(__index.GetHeight)
              end,
              GetHitRectInsets = function()
                return checkCFunc(__index.GetHitRectInsets)
              end,
              GetHyperlinksEnabled = function()
                return checkCFunc(__index.GetHyperlinksEnabled)
              end,
              GetID = function()
                return checkCFunc(__index.GetID)
              end,
              GetItem = function()
                return checkCFunc(__index.GetItem)
              end,
              GetLeft = function()
                return checkCFunc(__index.GetLeft)
              end,
              GetMaxResize = function()
                return checkCFunc(__index.GetMaxResize)
              end,
              GetMinResize = function()
                return checkCFunc(__index.GetMinResize)
              end,
              GetMinimumWidth = function()
                return checkCFunc(__index.GetMinimumWidth)
              end,
              GetName = function()
                return checkCFunc(__index.GetName)
              end,
              GetNumChildren = function()
                return checkCFunc(__index.GetNumChildren)
              end,
              GetNumPoints = function()
                return checkCFunc(__index.GetNumPoints)
              end,
              GetNumRegions = function()
                return checkCFunc(__index.GetNumRegions)
              end,
              GetObjectType = function()
                return checkCFunc(__index.GetObjectType)
              end,
              GetOwner = function()
                return checkCFunc(__index.GetOwner)
              end,
              GetPadding = function()
                return checkCFunc(__index.GetPadding)
              end,
              GetParent = function()
                return checkCFunc(__index.GetParent)
              end,
              GetPoint = function()
                return checkCFunc(__index.GetPoint)
              end,
              GetPointByName = function()
                return checkCFunc(__index.GetPointByName)
              end,
              GetPropagateKeyboardInput = function()
                return checkCFunc(__index.GetPropagateKeyboardInput)
              end,
              GetRect = function()
                return checkCFunc(__index.GetRect)
              end,
              GetRegions = function()
                return checkCFunc(__index.GetRegions)
              end,
              GetRight = function()
                return checkCFunc(__index.GetRight)
              end,
              GetScale = function()
                return checkCFunc(__index.GetScale)
              end,
              GetScaledRect = function()
                return checkCFunc(__index.GetScaledRect)
              end,
              GetScript = function()
                return checkCFunc(__index.GetScript)
              end,
              GetSize = function()
                return checkCFunc(__index.GetSize)
              end,
              GetSourceLocation = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetSourceLocation))
                  return
                end
                return checkCFunc(__index.GetSourceLocation)
              end,
              GetSpell = function()
                return checkCFunc(__index.GetSpell)
              end,
              GetTop = function()
                return checkCFunc(__index.GetTop)
              end,
              GetUnit = function()
                return checkCFunc(__index.GetUnit)
              end,
              GetWidth = function()
                return checkCFunc(__index.GetWidth)
              end,
              HasFixedFrameLevel = function()
                return checkCFunc(__index.HasFixedFrameLevel)
              end,
              HasFixedFrameStrata = function()
                return checkCFunc(__index.HasFixedFrameStrata)
              end,
              HasScript = function()
                return checkCFunc(__index.HasScript)
              end,
              Hide = function()
                return checkCFunc(__index.Hide)
              end,
              HookScript = function()
                return checkCFunc(__index.HookScript)
              end,
              IgnoreDepth = function()
                return checkCFunc(__index.IgnoreDepth)
              end,
              IsAnchoringRestricted = function()
                return checkCFunc(__index.IsAnchoringRestricted)
              end,
              IsClampedToScreen = function()
                return checkCFunc(__index.IsClampedToScreen)
              end,
              IsDragging = function()
                return checkCFunc(__index.IsDragging)
              end,
              IsEquippedItem = function()
                return checkCFunc(__index.IsEquippedItem)
              end,
              IsEventRegistered = function()
                return checkCFunc(__index.IsEventRegistered)
              end,
              IsForbidden = function()
                return checkCFunc(__index.IsForbidden)
              end,
              IsGamePadButtonEnabled = function()
                return checkCFunc(__index.IsGamePadButtonEnabled)
              end,
              IsGamePadStickEnabled = function()
                return checkCFunc(__index.IsGamePadStickEnabled)
              end,
              IsIgnoringDepth = function()
                return checkCFunc(__index.IsIgnoringDepth)
              end,
              IsIgnoringParentAlpha = function()
                return checkCFunc(__index.IsIgnoringParentAlpha)
              end,
              IsIgnoringParentScale = function()
                return checkCFunc(__index.IsIgnoringParentScale)
              end,
              IsKeyboardEnabled = function()
                return checkCFunc(__index.IsKeyboardEnabled)
              end,
              IsMouseClickEnabled = function()
                return checkCFunc(__index.IsMouseClickEnabled)
              end,
              IsMouseEnabled = function()
                return checkCFunc(__index.IsMouseEnabled)
              end,
              IsMouseMotionEnabled = function()
                return checkCFunc(__index.IsMouseMotionEnabled)
              end,
              IsMouseOver = function()
                return checkCFunc(__index.IsMouseOver)
              end,
              IsMouseWheelEnabled = function()
                return checkCFunc(__index.IsMouseWheelEnabled)
              end,
              IsMovable = function()
                return checkCFunc(__index.IsMovable)
              end,
              IsObjectLoaded = function()
                return checkCFunc(__index.IsObjectLoaded)
              end,
              IsObjectType = function()
                return checkCFunc(__index.IsObjectType)
              end,
              IsOwned = function()
                return checkCFunc(__index.IsOwned)
              end,
              IsProtected = function()
                return checkCFunc(__index.IsProtected)
              end,
              IsRectValid = function()
                return checkCFunc(__index.IsRectValid)
              end,
              IsResizable = function()
                return checkCFunc(__index.IsResizable)
              end,
              IsShown = function()
                return checkCFunc(__index.IsShown)
              end,
              IsToplevel = function()
                return checkCFunc(__index.IsToplevel)
              end,
              IsUnit = function()
                return checkCFunc(__index.IsUnit)
              end,
              IsUserPlaced = function()
                return checkCFunc(__index.IsUserPlaced)
              end,
              IsVisible = function()
                return checkCFunc(__index.IsVisible)
              end,
              Lower = function()
                return checkCFunc(__index.Lower)
              end,
              NumLines = function()
                return checkCFunc(__index.NumLines)
              end,
              Raise = function()
                return checkCFunc(__index.Raise)
              end,
              RegisterAllEvents = function()
                return checkCFunc(__index.RegisterAllEvents)
              end,
              RegisterEvent = function()
                return checkCFunc(__index.RegisterEvent)
              end,
              RegisterForDrag = function()
                return checkCFunc(__index.RegisterForDrag)
              end,
              RegisterUnitEvent = function()
                return checkCFunc(__index.RegisterUnitEvent)
              end,
              ResetSecondaryCompareItem = function()
                return checkCFunc(__index.ResetSecondaryCompareItem)
              end,
              RotateTextures = function()
                return checkCFunc(__index.RotateTextures)
              end,
              SetAchievementByID = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetAchievementByID))
                  return
                end
                return checkCFunc(__index.SetAchievementByID)
              end,
              SetAction = function()
                return checkCFunc(__index.SetAction)
              end,
              SetAllPoints = function()
                return checkCFunc(__index.SetAllPoints)
              end,
              SetAllowShowWithNoLines = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetAllowShowWithNoLines))
                  return
                end
                return checkCFunc(__index.SetAllowShowWithNoLines)
              end,
              SetAlpha = function()
                return checkCFunc(__index.SetAlpha)
              end,
              SetAnchorType = function()
                return checkCFunc(__index.SetAnchorType)
              end,
              SetArtifactItem = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetArtifactItem))
                  return
                end
                return checkCFunc(__index.SetArtifactItem)
              end,
              SetArtifactPowerByID = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetArtifactPowerByID))
                  return
                end
                return checkCFunc(__index.SetArtifactPowerByID)
              end,
              SetAttribute = function()
                return checkCFunc(__index.SetAttribute)
              end,
              SetAttributeNoHandler = function()
                return checkCFunc(__index.SetAttributeNoHandler)
              end,
              SetAuctionItem = function()
                if badProduct('wow_classic,wow_classic_beta,wow_classic_ptr,wow_classic_era,wow_classic_era_ptr') then
                  assertEquals('nil', type(__index.SetAuctionItem))
                  return
                end
                return checkCFunc(__index.SetAuctionItem)
              end,
              SetAuctionSellItem = function()
                if badProduct('wow_classic,wow_classic_beta,wow_classic_ptr,wow_classic_era,wow_classic_era_ptr') then
                  assertEquals('nil', type(__index.SetAuctionSellItem))
                  return
                end
                return checkCFunc(__index.SetAuctionSellItem)
              end,
              SetAzeriteEssence = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetAzeriteEssence))
                  return
                end
                return checkCFunc(__index.SetAzeriteEssence)
              end,
              SetAzeriteEssenceSlot = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetAzeriteEssenceSlot))
                  return
                end
                return checkCFunc(__index.SetAzeriteEssenceSlot)
              end,
              SetAzeritePower = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetAzeritePower))
                  return
                end
                return checkCFunc(__index.SetAzeritePower)
              end,
              SetBackpackToken = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetBackpackToken))
                  return
                end
                return checkCFunc(__index.SetBackpackToken)
              end,
              SetBagItem = function()
                return checkCFunc(__index.SetBagItem)
              end,
              SetBagItemChild = function()
                return checkCFunc(__index.SetBagItemChild)
              end,
              SetBuybackItem = function()
                return checkCFunc(__index.SetBuybackItem)
              end,
              SetClampRectInsets = function()
                return checkCFunc(__index.SetClampRectInsets)
              end,
              SetClampedToScreen = function()
                return checkCFunc(__index.SetClampedToScreen)
              end,
              SetClipsChildren = function()
                return checkCFunc(__index.SetClipsChildren)
              end,
              SetCompanionPet = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetCompanionPet))
                  return
                end
                return checkCFunc(__index.SetCompanionPet)
              end,
              SetCompareAzeritePower = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetCompareAzeritePower))
                  return
                end
                return checkCFunc(__index.SetCompareAzeritePower)
              end,
              SetCompareItem = function()
                return checkCFunc(__index.SetCompareItem)
              end,
              SetConduit = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetConduit))
                  return
                end
                return checkCFunc(__index.SetConduit)
              end,
              SetCraftItem = function()
                if badProduct('wow_classic,wow_classic_beta,wow_classic_ptr,wow_classic_era,wow_classic_era_ptr') then
                  assertEquals('nil', type(__index.SetCraftItem))
                  return
                end
                return checkCFunc(__index.SetCraftItem)
              end,
              SetCraftSpell = function()
                if badProduct('wow_classic,wow_classic_beta,wow_classic_ptr,wow_classic_era,wow_classic_era_ptr') then
                  assertEquals('nil', type(__index.SetCraftSpell))
                  return
                end
                return checkCFunc(__index.SetCraftSpell)
              end,
              SetCurrencyByID = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetCurrencyByID))
                  return
                end
                return checkCFunc(__index.SetCurrencyByID)
              end,
              SetCurrencyToken = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetCurrencyToken))
                  return
                end
                return checkCFunc(__index.SetCurrencyToken)
              end,
              SetCurrencyTokenByID = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetCurrencyTokenByID))
                  return
                end
                return checkCFunc(__index.SetCurrencyTokenByID)
              end,
              SetCustomLineSpacing = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetCustomLineSpacing))
                  return
                end
                return checkCFunc(__index.SetCustomLineSpacing)
              end,
              SetDepth = function()
                return checkCFunc(__index.SetDepth)
              end,
              SetDontSavePosition = function()
                return checkCFunc(__index.SetDontSavePosition)
              end,
              SetDrawLayerEnabled = function()
                return checkCFunc(__index.SetDrawLayerEnabled)
              end,
              SetEnhancedConduit = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetEnhancedConduit))
                  return
                end
                return checkCFunc(__index.SetEnhancedConduit)
              end,
              SetEquipmentSet = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetEquipmentSet))
                  return
                end
                return checkCFunc(__index.SetEquipmentSet)
              end,
              SetExistingSocketGem = function()
                return checkCFunc(__index.SetExistingSocketGem)
              end,
              SetFixedFrameLevel = function()
                return checkCFunc(__index.SetFixedFrameLevel)
              end,
              SetFixedFrameStrata = function()
                return checkCFunc(__index.SetFixedFrameStrata)
              end,
              SetFlattensRenderLayers = function()
                return checkCFunc(__index.SetFlattensRenderLayers)
              end,
              SetForbidden = function()
                return checkCFunc(__index.SetForbidden)
              end,
              SetFrameBuffer = function()
                return checkCFunc(__index.SetFrameBuffer)
              end,
              SetFrameLevel = function()
                return checkCFunc(__index.SetFrameLevel)
              end,
              SetFrameStack = function()
                return checkCFunc(__index.SetFrameStack)
              end,
              SetFrameStrata = function()
                return checkCFunc(__index.SetFrameStrata)
              end,
              SetGuildBankItem = function()
                return checkCFunc(__index.SetGuildBankItem)
              end,
              SetHeight = function()
                return checkCFunc(__index.SetHeight)
              end,
              SetHeirloomByItemID = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetHeirloomByItemID))
                  return
                end
                return checkCFunc(__index.SetHeirloomByItemID)
              end,
              SetHitRectInsets = function()
                return checkCFunc(__index.SetHitRectInsets)
              end,
              SetHyperlink = function()
                return checkCFunc(__index.SetHyperlink)
              end,
              SetHyperlinksEnabled = function()
                return checkCFunc(__index.SetHyperlinksEnabled)
              end,
              SetID = function()
                return checkCFunc(__index.SetID)
              end,
              SetIgnoreParentAlpha = function()
                return checkCFunc(__index.SetIgnoreParentAlpha)
              end,
              SetIgnoreParentScale = function()
                return checkCFunc(__index.SetIgnoreParentScale)
              end,
              SetInboxItem = function()
                return checkCFunc(__index.SetInboxItem)
              end,
              SetInstanceLockEncountersComplete = function()
                return checkCFunc(__index.SetInstanceLockEncountersComplete)
              end,
              SetInventoryItem = function()
                return checkCFunc(__index.SetInventoryItem)
              end,
              SetInventoryItemByID = function()
                return checkCFunc(__index.SetInventoryItemByID)
              end,
              SetItemByID = function()
                return checkCFunc(__index.SetItemByID)
              end,
              SetItemKey = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetItemKey))
                  return
                end
                return checkCFunc(__index.SetItemKey)
              end,
              SetLFGDungeonReward = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetLFGDungeonReward))
                  return
                end
                return checkCFunc(__index.SetLFGDungeonReward)
              end,
              SetLFGDungeonShortageReward = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetLFGDungeonShortageReward))
                  return
                end
                return checkCFunc(__index.SetLFGDungeonShortageReward)
              end,
              SetLootCurrency = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetLootCurrency))
                  return
                end
                return checkCFunc(__index.SetLootCurrency)
              end,
              SetLootItem = function()
                return checkCFunc(__index.SetLootItem)
              end,
              SetLootRollItem = function()
                return checkCFunc(__index.SetLootRollItem)
              end,
              SetMaxResize = function()
                return checkCFunc(__index.SetMaxResize)
              end,
              SetMerchantCostItem = function()
                return checkCFunc(__index.SetMerchantCostItem)
              end,
              SetMerchantItem = function()
                return checkCFunc(__index.SetMerchantItem)
              end,
              SetMinResize = function()
                return checkCFunc(__index.SetMinResize)
              end,
              SetMinimumWidth = function()
                return checkCFunc(__index.SetMinimumWidth)
              end,
              SetMountBySpellID = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetMountBySpellID))
                  return
                end
                return checkCFunc(__index.SetMountBySpellID)
              end,
              SetMouseClickEnabled = function()
                return checkCFunc(__index.SetMouseClickEnabled)
              end,
              SetMouseMotionEnabled = function()
                return checkCFunc(__index.SetMouseMotionEnabled)
              end,
              SetMovable = function()
                return checkCFunc(__index.SetMovable)
              end,
              SetOwnedItemByID = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetOwnedItemByID))
                  return
                end
                return checkCFunc(__index.SetOwnedItemByID)
              end,
              SetOwner = function()
                return checkCFunc(__index.SetOwner)
              end,
              SetPadding = function()
                return checkCFunc(__index.SetPadding)
              end,
              SetParent = function()
                return checkCFunc(__index.SetParent)
              end,
              SetPetAction = function()
                return checkCFunc(__index.SetPetAction)
              end,
              SetPoint = function()
                return checkCFunc(__index.SetPoint)
              end,
              SetPossession = function()
                return checkCFunc(__index.SetPossession)
              end,
              SetPropagateKeyboardInput = function()
                return checkCFunc(__index.SetPropagateKeyboardInput)
              end,
              SetPvpBrawl = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetPvpBrawl))
                  return
                end
                return checkCFunc(__index.SetPvpBrawl)
              end,
              SetPvpTalent = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetPvpTalent))
                  return
                end
                return checkCFunc(__index.SetPvpTalent)
              end,
              SetQuestCurrency = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetQuestCurrency))
                  return
                end
                return checkCFunc(__index.SetQuestCurrency)
              end,
              SetQuestItem = function()
                return checkCFunc(__index.SetQuestItem)
              end,
              SetQuestLogCurrency = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetQuestLogCurrency))
                  return
                end
                return checkCFunc(__index.SetQuestLogCurrency)
              end,
              SetQuestLogItem = function()
                return checkCFunc(__index.SetQuestLogItem)
              end,
              SetQuestLogRewardSpell = function()
                return checkCFunc(__index.SetQuestLogRewardSpell)
              end,
              SetQuestLogSpecialItem = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetQuestLogSpecialItem))
                  return
                end
                return checkCFunc(__index.SetQuestLogSpecialItem)
              end,
              SetQuestPartyProgress = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetQuestPartyProgress))
                  return
                end
                return checkCFunc(__index.SetQuestPartyProgress)
              end,
              SetQuestRewardSpell = function()
                return checkCFunc(__index.SetQuestRewardSpell)
              end,
              SetRecipeRankInfo = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetRecipeRankInfo))
                  return
                end
                return checkCFunc(__index.SetRecipeRankInfo)
              end,
              SetRecipeReagentItem = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetRecipeReagentItem))
                  return
                end
                return checkCFunc(__index.SetRecipeReagentItem)
              end,
              SetRecipeResultItem = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetRecipeResultItem))
                  return
                end
                return checkCFunc(__index.SetRecipeResultItem)
              end,
              SetResizable = function()
                return checkCFunc(__index.SetResizable)
              end,
              SetRuneforgeResultItem = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetRuneforgeResultItem))
                  return
                end
                return checkCFunc(__index.SetRuneforgeResultItem)
              end,
              SetScale = function()
                return checkCFunc(__index.SetScale)
              end,
              SetScript = function()
                return checkCFunc(__index.SetScript)
              end,
              SetSendMailItem = function()
                return checkCFunc(__index.SetSendMailItem)
              end,
              SetShapeshift = function()
                return checkCFunc(__index.SetShapeshift)
              end,
              SetShown = function()
                return checkCFunc(__index.SetShown)
              end,
              SetShrinkToFitWrapped = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetShrinkToFitWrapped))
                  return
                end
                return checkCFunc(__index.SetShrinkToFitWrapped)
              end,
              SetSize = function()
                return checkCFunc(__index.SetSize)
              end,
              SetSocketGem = function()
                return checkCFunc(__index.SetSocketGem)
              end,
              SetSocketedItem = function()
                return checkCFunc(__index.SetSocketedItem)
              end,
              SetSocketedRelic = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetSocketedRelic))
                  return
                end
                return checkCFunc(__index.SetSocketedRelic)
              end,
              SetSpecialPvpBrawl = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetSpecialPvpBrawl))
                  return
                end
                return checkCFunc(__index.SetSpecialPvpBrawl)
              end,
              SetSpellBookItem = function()
                return checkCFunc(__index.SetSpellBookItem)
              end,
              SetSpellByID = function()
                return checkCFunc(__index.SetSpellByID)
              end,
              SetTalent = function()
                return checkCFunc(__index.SetTalent)
              end,
              SetText = function()
                return checkCFunc(__index.SetText)
              end,
              SetToplevel = function()
                return checkCFunc(__index.SetToplevel)
              end,
              SetTotem = function()
                return checkCFunc(__index.SetTotem)
              end,
              SetToyByItemID = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetToyByItemID))
                  return
                end
                return checkCFunc(__index.SetToyByItemID)
              end,
              SetTrackingSpell = function()
                if badProduct('wow_classic,wow_classic_beta,wow_classic_ptr,wow_classic_era,wow_classic_era_ptr') then
                  assertEquals('nil', type(__index.SetTrackingSpell))
                  return
                end
                return checkCFunc(__index.SetTrackingSpell)
              end,
              SetTradePlayerItem = function()
                return checkCFunc(__index.SetTradePlayerItem)
              end,
              SetTradeSkillItem = function()
                if badProduct('wow_classic,wow_classic_beta,wow_classic_ptr,wow_classic_era,wow_classic_era_ptr') then
                  assertEquals('nil', type(__index.SetTradeSkillItem))
                  return
                end
                return checkCFunc(__index.SetTradeSkillItem)
              end,
              SetTradeTargetItem = function()
                return checkCFunc(__index.SetTradeTargetItem)
              end,
              SetTrainerService = function()
                return checkCFunc(__index.SetTrainerService)
              end,
              SetTransmogrifyItem = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetTransmogrifyItem))
                  return
                end
                return checkCFunc(__index.SetTransmogrifyItem)
              end,
              SetUnit = function()
                return checkCFunc(__index.SetUnit)
              end,
              SetUnitAura = function()
                return checkCFunc(__index.SetUnitAura)
              end,
              SetUnitBuff = function()
                return checkCFunc(__index.SetUnitBuff)
              end,
              SetUnitDebuff = function()
                return checkCFunc(__index.SetUnitDebuff)
              end,
              SetUpgradeItem = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetUpgradeItem))
                  return
                end
                return checkCFunc(__index.SetUpgradeItem)
              end,
              SetUserPlaced = function()
                return checkCFunc(__index.SetUserPlaced)
              end,
              SetVoidDepositItem = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetVoidDepositItem))
                  return
                end
                return checkCFunc(__index.SetVoidDepositItem)
              end,
              SetVoidItem = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetVoidItem))
                  return
                end
                return checkCFunc(__index.SetVoidItem)
              end,
              SetVoidWithdrawalItem = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetVoidWithdrawalItem))
                  return
                end
                return checkCFunc(__index.SetVoidWithdrawalItem)
              end,
              SetWeeklyReward = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetWeeklyReward))
                  return
                end
                return checkCFunc(__index.SetWeeklyReward)
              end,
              SetWidth = function()
                return checkCFunc(__index.SetWidth)
              end,
              Show = function()
                return checkCFunc(__index.Show)
              end,
              StartMoving = function()
                return checkCFunc(__index.StartMoving)
              end,
              StartSizing = function()
                return checkCFunc(__index.StartSizing)
              end,
              StopAnimating = function()
                return checkCFunc(__index.StopAnimating)
              end,
              StopMovingOrSizing = function()
                return checkCFunc(__index.StopMovingOrSizing)
              end,
              UnregisterAllEvents = function()
                return checkCFunc(__index.UnregisterAllEvents)
              end,
              UnregisterEvent = function()
                return checkCFunc(__index.UnregisterEvent)
              end,
            }
          end)
        end,
        LayeredRegion = function()
          assertCreateFrameFails('LayeredRegion')
        end,
        Line = function()
          assertCreateFrameFails('Line')
        end,
        LineScale = function()
          assertCreateFrameFails('LineScale')
        end,
        LineTranslation = function()
          assertCreateFrameFails('LineTranslation')
        end,
        MaskTexture = function()
          assertCreateFrameFails('MaskTexture')
        end,
        MessageFrame = function()
          local function factory()
            return assertCreateFrame('MessageFrame')
          end
          return mkTests('MessageFrame', factory, function(__index)
            return {
              AddMessage = function()
                return checkCFunc(__index.AddMessage)
              end,
              AdjustPointsOffset = function()
                return checkCFunc(__index.AdjustPointsOffset)
              end,
              CanChangeAttribute = function()
                return checkCFunc(__index.CanChangeAttribute)
              end,
              CanChangeProtectedState = function()
                return checkCFunc(__index.CanChangeProtectedState)
              end,
              Clear = function()
                return checkCFunc(__index.Clear)
              end,
              ClearAllPoints = function()
                return checkCFunc(__index.ClearAllPoints)
              end,
              ClearPointByName = function()
                return checkCFunc(__index.ClearPointByName)
              end,
              ClearPointsOffset = function()
                return checkCFunc(__index.ClearPointsOffset)
              end,
              CreateAnimationGroup = function()
                return checkCFunc(__index.CreateAnimationGroup)
              end,
              CreateFontString = function()
                return checkCFunc(__index.CreateFontString)
              end,
              CreateLine = function()
                return checkCFunc(__index.CreateLine)
              end,
              CreateMaskTexture = function()
                return checkCFunc(__index.CreateMaskTexture)
              end,
              CreateTexture = function()
                return checkCFunc(__index.CreateTexture)
              end,
              DesaturateHierarchy = function()
                return checkCFunc(__index.DesaturateHierarchy)
              end,
              DisableDrawLayer = function()
                return checkCFunc(__index.DisableDrawLayer)
              end,
              DoesClipChildren = function()
                return checkCFunc(__index.DoesClipChildren)
              end,
              EnableDrawLayer = function()
                return checkCFunc(__index.EnableDrawLayer)
              end,
              EnableGamePadButton = function()
                return checkCFunc(__index.EnableGamePadButton)
              end,
              EnableGamePadStick = function()
                return checkCFunc(__index.EnableGamePadStick)
              end,
              EnableKeyboard = function()
                return checkCFunc(__index.EnableKeyboard)
              end,
              EnableMouse = function()
                return checkCFunc(__index.EnableMouse)
              end,
              EnableMouseWheel = function()
                return checkCFunc(__index.EnableMouseWheel)
              end,
              ExecuteAttribute = function()
                return checkCFunc(__index.ExecuteAttribute)
              end,
              GetAlpha = function()
                return checkCFunc(__index.GetAlpha)
              end,
              GetAnimationGroups = function()
                return checkCFunc(__index.GetAnimationGroups)
              end,
              GetAttribute = function()
                return checkCFunc(__index.GetAttribute)
              end,
              GetBottom = function()
                return checkCFunc(__index.GetBottom)
              end,
              GetBoundsRect = function()
                return checkCFunc(__index.GetBoundsRect)
              end,
              GetCenter = function()
                return checkCFunc(__index.GetCenter)
              end,
              GetChildren = function()
                return checkCFunc(__index.GetChildren)
              end,
              GetClampRectInsets = function()
                return checkCFunc(__index.GetClampRectInsets)
              end,
              GetDebugName = function()
                return checkCFunc(__index.GetDebugName)
              end,
              GetDepth = function()
                return checkCFunc(__index.GetDepth)
              end,
              GetDontSavePosition = function()
                return checkCFunc(__index.GetDontSavePosition)
              end,
              GetEffectiveAlpha = function()
                return checkCFunc(__index.GetEffectiveAlpha)
              end,
              GetEffectiveDepth = function()
                return checkCFunc(__index.GetEffectiveDepth)
              end,
              GetEffectiveScale = function()
                return checkCFunc(__index.GetEffectiveScale)
              end,
              GetEffectivelyFlattensRenderLayers = function()
                return checkCFunc(__index.GetEffectivelyFlattensRenderLayers)
              end,
              GetFadeDuration = function()
                return checkCFunc(__index.GetFadeDuration)
              end,
              GetFadePower = function()
                return checkCFunc(__index.GetFadePower)
              end,
              GetFading = function()
                return checkCFunc(__index.GetFading)
              end,
              GetFlattensRenderLayers = function()
                return checkCFunc(__index.GetFlattensRenderLayers)
              end,
              GetFont = function()
                return checkCFunc(__index.GetFont)
              end,
              GetFontObject = function()
                return checkCFunc(__index.GetFontObject)
              end,
              GetFontStringByID = function()
                return checkCFunc(__index.GetFontStringByID)
              end,
              GetFrameLevel = function()
                return checkCFunc(__index.GetFrameLevel)
              end,
              GetFrameStrata = function()
                return checkCFunc(__index.GetFrameStrata)
              end,
              GetHeight = function()
                return checkCFunc(__index.GetHeight)
              end,
              GetHitRectInsets = function()
                return checkCFunc(__index.GetHitRectInsets)
              end,
              GetHyperlinksEnabled = function()
                return checkCFunc(__index.GetHyperlinksEnabled)
              end,
              GetID = function()
                return checkCFunc(__index.GetID)
              end,
              GetIndentedWordWrap = function()
                return checkCFunc(__index.GetIndentedWordWrap)
              end,
              GetInsertMode = function()
                return checkCFunc(__index.GetInsertMode)
              end,
              GetJustifyH = function()
                return checkCFunc(__index.GetJustifyH)
              end,
              GetJustifyV = function()
                return checkCFunc(__index.GetJustifyV)
              end,
              GetLeft = function()
                return checkCFunc(__index.GetLeft)
              end,
              GetMaxResize = function()
                return checkCFunc(__index.GetMaxResize)
              end,
              GetMinResize = function()
                return checkCFunc(__index.GetMinResize)
              end,
              GetName = function()
                return checkCFunc(__index.GetName)
              end,
              GetNumChildren = function()
                return checkCFunc(__index.GetNumChildren)
              end,
              GetNumPoints = function()
                return checkCFunc(__index.GetNumPoints)
              end,
              GetNumRegions = function()
                return checkCFunc(__index.GetNumRegions)
              end,
              GetObjectType = function()
                return checkCFunc(__index.GetObjectType)
              end,
              GetParent = function()
                return checkCFunc(__index.GetParent)
              end,
              GetPoint = function()
                return checkCFunc(__index.GetPoint)
              end,
              GetPointByName = function()
                return checkCFunc(__index.GetPointByName)
              end,
              GetPropagateKeyboardInput = function()
                return checkCFunc(__index.GetPropagateKeyboardInput)
              end,
              GetRect = function()
                return checkCFunc(__index.GetRect)
              end,
              GetRegions = function()
                return checkCFunc(__index.GetRegions)
              end,
              GetRight = function()
                return checkCFunc(__index.GetRight)
              end,
              GetScale = function()
                return checkCFunc(__index.GetScale)
              end,
              GetScaledRect = function()
                return checkCFunc(__index.GetScaledRect)
              end,
              GetScript = function()
                return checkCFunc(__index.GetScript)
              end,
              GetShadowColor = function()
                return checkCFunc(__index.GetShadowColor)
              end,
              GetShadowOffset = function()
                return checkCFunc(__index.GetShadowOffset)
              end,
              GetSize = function()
                return checkCFunc(__index.GetSize)
              end,
              GetSourceLocation = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetSourceLocation))
                  return
                end
                return checkCFunc(__index.GetSourceLocation)
              end,
              GetSpacing = function()
                return checkCFunc(__index.GetSpacing)
              end,
              GetTextColor = function()
                return checkCFunc(__index.GetTextColor)
              end,
              GetTimeVisible = function()
                return checkCFunc(__index.GetTimeVisible)
              end,
              GetTop = function()
                return checkCFunc(__index.GetTop)
              end,
              GetWidth = function()
                return checkCFunc(__index.GetWidth)
              end,
              HasFixedFrameLevel = function()
                return checkCFunc(__index.HasFixedFrameLevel)
              end,
              HasFixedFrameStrata = function()
                return checkCFunc(__index.HasFixedFrameStrata)
              end,
              HasMessageByID = function()
                return checkCFunc(__index.HasMessageByID)
              end,
              HasScript = function()
                return checkCFunc(__index.HasScript)
              end,
              Hide = function()
                return checkCFunc(__index.Hide)
              end,
              HookScript = function()
                return checkCFunc(__index.HookScript)
              end,
              IgnoreDepth = function()
                return checkCFunc(__index.IgnoreDepth)
              end,
              IsAnchoringRestricted = function()
                return checkCFunc(__index.IsAnchoringRestricted)
              end,
              IsClampedToScreen = function()
                return checkCFunc(__index.IsClampedToScreen)
              end,
              IsDragging = function()
                return checkCFunc(__index.IsDragging)
              end,
              IsEventRegistered = function()
                return checkCFunc(__index.IsEventRegistered)
              end,
              IsForbidden = function()
                return checkCFunc(__index.IsForbidden)
              end,
              IsGamePadButtonEnabled = function()
                return checkCFunc(__index.IsGamePadButtonEnabled)
              end,
              IsGamePadStickEnabled = function()
                return checkCFunc(__index.IsGamePadStickEnabled)
              end,
              IsIgnoringDepth = function()
                return checkCFunc(__index.IsIgnoringDepth)
              end,
              IsIgnoringParentAlpha = function()
                return checkCFunc(__index.IsIgnoringParentAlpha)
              end,
              IsIgnoringParentScale = function()
                return checkCFunc(__index.IsIgnoringParentScale)
              end,
              IsKeyboardEnabled = function()
                return checkCFunc(__index.IsKeyboardEnabled)
              end,
              IsMouseClickEnabled = function()
                return checkCFunc(__index.IsMouseClickEnabled)
              end,
              IsMouseEnabled = function()
                return checkCFunc(__index.IsMouseEnabled)
              end,
              IsMouseMotionEnabled = function()
                return checkCFunc(__index.IsMouseMotionEnabled)
              end,
              IsMouseOver = function()
                return checkCFunc(__index.IsMouseOver)
              end,
              IsMouseWheelEnabled = function()
                return checkCFunc(__index.IsMouseWheelEnabled)
              end,
              IsMovable = function()
                return checkCFunc(__index.IsMovable)
              end,
              IsObjectLoaded = function()
                return checkCFunc(__index.IsObjectLoaded)
              end,
              IsObjectType = function()
                return checkCFunc(__index.IsObjectType)
              end,
              IsProtected = function()
                return checkCFunc(__index.IsProtected)
              end,
              IsRectValid = function()
                return checkCFunc(__index.IsRectValid)
              end,
              IsResizable = function()
                return checkCFunc(__index.IsResizable)
              end,
              IsShown = function()
                return checkCFunc(__index.IsShown)
              end,
              IsToplevel = function()
                return checkCFunc(__index.IsToplevel)
              end,
              IsUserPlaced = function()
                return checkCFunc(__index.IsUserPlaced)
              end,
              IsVisible = function()
                return checkCFunc(__index.IsVisible)
              end,
              Lower = function()
                return checkCFunc(__index.Lower)
              end,
              Raise = function()
                return checkCFunc(__index.Raise)
              end,
              RegisterAllEvents = function()
                return checkCFunc(__index.RegisterAllEvents)
              end,
              RegisterEvent = function()
                return checkCFunc(__index.RegisterEvent)
              end,
              RegisterForDrag = function()
                return checkCFunc(__index.RegisterForDrag)
              end,
              RegisterUnitEvent = function()
                return checkCFunc(__index.RegisterUnitEvent)
              end,
              ResetMessageFadeByID = function()
                return checkCFunc(__index.ResetMessageFadeByID)
              end,
              RotateTextures = function()
                return checkCFunc(__index.RotateTextures)
              end,
              SetAllPoints = function()
                return checkCFunc(__index.SetAllPoints)
              end,
              SetAlpha = function()
                return checkCFunc(__index.SetAlpha)
              end,
              SetAttribute = function()
                return checkCFunc(__index.SetAttribute)
              end,
              SetAttributeNoHandler = function()
                return checkCFunc(__index.SetAttributeNoHandler)
              end,
              SetClampRectInsets = function()
                return checkCFunc(__index.SetClampRectInsets)
              end,
              SetClampedToScreen = function()
                return checkCFunc(__index.SetClampedToScreen)
              end,
              SetClipsChildren = function()
                return checkCFunc(__index.SetClipsChildren)
              end,
              SetDepth = function()
                return checkCFunc(__index.SetDepth)
              end,
              SetDontSavePosition = function()
                return checkCFunc(__index.SetDontSavePosition)
              end,
              SetDrawLayerEnabled = function()
                return checkCFunc(__index.SetDrawLayerEnabled)
              end,
              SetFadeDuration = function()
                return checkCFunc(__index.SetFadeDuration)
              end,
              SetFadePower = function()
                return checkCFunc(__index.SetFadePower)
              end,
              SetFading = function()
                return checkCFunc(__index.SetFading)
              end,
              SetFixedFrameLevel = function()
                return checkCFunc(__index.SetFixedFrameLevel)
              end,
              SetFixedFrameStrata = function()
                return checkCFunc(__index.SetFixedFrameStrata)
              end,
              SetFlattensRenderLayers = function()
                return checkCFunc(__index.SetFlattensRenderLayers)
              end,
              SetFont = function()
                return checkCFunc(__index.SetFont)
              end,
              SetFontObject = function()
                return checkCFunc(__index.SetFontObject)
              end,
              SetForbidden = function()
                return checkCFunc(__index.SetForbidden)
              end,
              SetFrameBuffer = function()
                return checkCFunc(__index.SetFrameBuffer)
              end,
              SetFrameLevel = function()
                return checkCFunc(__index.SetFrameLevel)
              end,
              SetFrameStrata = function()
                return checkCFunc(__index.SetFrameStrata)
              end,
              SetHeight = function()
                return checkCFunc(__index.SetHeight)
              end,
              SetHitRectInsets = function()
                return checkCFunc(__index.SetHitRectInsets)
              end,
              SetHyperlinksEnabled = function()
                return checkCFunc(__index.SetHyperlinksEnabled)
              end,
              SetID = function()
                return checkCFunc(__index.SetID)
              end,
              SetIgnoreParentAlpha = function()
                return checkCFunc(__index.SetIgnoreParentAlpha)
              end,
              SetIgnoreParentScale = function()
                return checkCFunc(__index.SetIgnoreParentScale)
              end,
              SetIndentedWordWrap = function()
                return checkCFunc(__index.SetIndentedWordWrap)
              end,
              SetInsertMode = function()
                return checkCFunc(__index.SetInsertMode)
              end,
              SetJustifyH = function()
                return checkCFunc(__index.SetJustifyH)
              end,
              SetJustifyV = function()
                return checkCFunc(__index.SetJustifyV)
              end,
              SetMaxResize = function()
                return checkCFunc(__index.SetMaxResize)
              end,
              SetMinResize = function()
                return checkCFunc(__index.SetMinResize)
              end,
              SetMouseClickEnabled = function()
                return checkCFunc(__index.SetMouseClickEnabled)
              end,
              SetMouseMotionEnabled = function()
                return checkCFunc(__index.SetMouseMotionEnabled)
              end,
              SetMovable = function()
                return checkCFunc(__index.SetMovable)
              end,
              SetParent = function()
                return checkCFunc(__index.SetParent)
              end,
              SetPoint = function()
                return checkCFunc(__index.SetPoint)
              end,
              SetPropagateKeyboardInput = function()
                return checkCFunc(__index.SetPropagateKeyboardInput)
              end,
              SetResizable = function()
                return checkCFunc(__index.SetResizable)
              end,
              SetScale = function()
                return checkCFunc(__index.SetScale)
              end,
              SetScript = function()
                return checkCFunc(__index.SetScript)
              end,
              SetShadowColor = function()
                return checkCFunc(__index.SetShadowColor)
              end,
              SetShadowOffset = function()
                return checkCFunc(__index.SetShadowOffset)
              end,
              SetShown = function()
                return checkCFunc(__index.SetShown)
              end,
              SetSize = function()
                return checkCFunc(__index.SetSize)
              end,
              SetSpacing = function()
                return checkCFunc(__index.SetSpacing)
              end,
              SetTextColor = function()
                return checkCFunc(__index.SetTextColor)
              end,
              SetTimeVisible = function()
                return checkCFunc(__index.SetTimeVisible)
              end,
              SetToplevel = function()
                return checkCFunc(__index.SetToplevel)
              end,
              SetUserPlaced = function()
                return checkCFunc(__index.SetUserPlaced)
              end,
              SetWidth = function()
                return checkCFunc(__index.SetWidth)
              end,
              Show = function()
                return checkCFunc(__index.Show)
              end,
              StartMoving = function()
                return checkCFunc(__index.StartMoving)
              end,
              StartSizing = function()
                return checkCFunc(__index.StartSizing)
              end,
              StopAnimating = function()
                return checkCFunc(__index.StopAnimating)
              end,
              StopMovingOrSizing = function()
                return checkCFunc(__index.StopMovingOrSizing)
              end,
              UnregisterAllEvents = function()
                return checkCFunc(__index.UnregisterAllEvents)
              end,
              UnregisterEvent = function()
                return checkCFunc(__index.UnregisterEvent)
              end,
            }
          end)
        end,
        Model = function()
          local function factory()
            return assertCreateFrame('Model')
          end
          return mkTests('Model', factory, function(__index)
            return {
              AdjustPointsOffset = function()
                return checkCFunc(__index.AdjustPointsOffset)
              end,
              AdvanceTime = function()
                return checkCFunc(__index.AdvanceTime)
              end,
              CanChangeAttribute = function()
                return checkCFunc(__index.CanChangeAttribute)
              end,
              CanChangeProtectedState = function()
                return checkCFunc(__index.CanChangeProtectedState)
              end,
              ClearAllPoints = function()
                return checkCFunc(__index.ClearAllPoints)
              end,
              ClearFog = function()
                return checkCFunc(__index.ClearFog)
              end,
              ClearModel = function()
                return checkCFunc(__index.ClearModel)
              end,
              ClearPointByName = function()
                return checkCFunc(__index.ClearPointByName)
              end,
              ClearPointsOffset = function()
                return checkCFunc(__index.ClearPointsOffset)
              end,
              ClearTransform = function()
                return checkCFunc(__index.ClearTransform)
              end,
              CreateAnimationGroup = function()
                return checkCFunc(__index.CreateAnimationGroup)
              end,
              CreateFontString = function()
                return checkCFunc(__index.CreateFontString)
              end,
              CreateLine = function()
                return checkCFunc(__index.CreateLine)
              end,
              CreateMaskTexture = function()
                return checkCFunc(__index.CreateMaskTexture)
              end,
              CreateTexture = function()
                return checkCFunc(__index.CreateTexture)
              end,
              DesaturateHierarchy = function()
                return checkCFunc(__index.DesaturateHierarchy)
              end,
              DisableDrawLayer = function()
                return checkCFunc(__index.DisableDrawLayer)
              end,
              DoesClipChildren = function()
                return checkCFunc(__index.DoesClipChildren)
              end,
              EnableDrawLayer = function()
                return checkCFunc(__index.EnableDrawLayer)
              end,
              EnableGamePadButton = function()
                return checkCFunc(__index.EnableGamePadButton)
              end,
              EnableGamePadStick = function()
                return checkCFunc(__index.EnableGamePadStick)
              end,
              EnableKeyboard = function()
                return checkCFunc(__index.EnableKeyboard)
              end,
              EnableMouse = function()
                return checkCFunc(__index.EnableMouse)
              end,
              EnableMouseWheel = function()
                return checkCFunc(__index.EnableMouseWheel)
              end,
              ExecuteAttribute = function()
                return checkCFunc(__index.ExecuteAttribute)
              end,
              GetAlpha = function()
                return checkCFunc(__index.GetAlpha)
              end,
              GetAnimationGroups = function()
                return checkCFunc(__index.GetAnimationGroups)
              end,
              GetAttribute = function()
                return checkCFunc(__index.GetAttribute)
              end,
              GetBottom = function()
                return checkCFunc(__index.GetBottom)
              end,
              GetBoundsRect = function()
                return checkCFunc(__index.GetBoundsRect)
              end,
              GetCameraDistance = function()
                return checkCFunc(__index.GetCameraDistance)
              end,
              GetCameraFacing = function()
                return checkCFunc(__index.GetCameraFacing)
              end,
              GetCameraPosition = function()
                return checkCFunc(__index.GetCameraPosition)
              end,
              GetCameraRoll = function()
                return checkCFunc(__index.GetCameraRoll)
              end,
              GetCameraTarget = function()
                return checkCFunc(__index.GetCameraTarget)
              end,
              GetCenter = function()
                return checkCFunc(__index.GetCenter)
              end,
              GetChildren = function()
                return checkCFunc(__index.GetChildren)
              end,
              GetClampRectInsets = function()
                return checkCFunc(__index.GetClampRectInsets)
              end,
              GetDebugName = function()
                return checkCFunc(__index.GetDebugName)
              end,
              GetDepth = function()
                return checkCFunc(__index.GetDepth)
              end,
              GetDesaturation = function()
                return checkCFunc(__index.GetDesaturation)
              end,
              GetDontSavePosition = function()
                return checkCFunc(__index.GetDontSavePosition)
              end,
              GetEffectiveAlpha = function()
                return checkCFunc(__index.GetEffectiveAlpha)
              end,
              GetEffectiveDepth = function()
                return checkCFunc(__index.GetEffectiveDepth)
              end,
              GetEffectiveScale = function()
                return checkCFunc(__index.GetEffectiveScale)
              end,
              GetEffectivelyFlattensRenderLayers = function()
                return checkCFunc(__index.GetEffectivelyFlattensRenderLayers)
              end,
              GetFacing = function()
                return checkCFunc(__index.GetFacing)
              end,
              GetFlattensRenderLayers = function()
                return checkCFunc(__index.GetFlattensRenderLayers)
              end,
              GetFogColor = function()
                return checkCFunc(__index.GetFogColor)
              end,
              GetFogFar = function()
                return checkCFunc(__index.GetFogFar)
              end,
              GetFogNear = function()
                return checkCFunc(__index.GetFogNear)
              end,
              GetFrameLevel = function()
                return checkCFunc(__index.GetFrameLevel)
              end,
              GetFrameStrata = function()
                return checkCFunc(__index.GetFrameStrata)
              end,
              GetHeight = function()
                return checkCFunc(__index.GetHeight)
              end,
              GetHitRectInsets = function()
                return checkCFunc(__index.GetHitRectInsets)
              end,
              GetHyperlinksEnabled = function()
                return checkCFunc(__index.GetHyperlinksEnabled)
              end,
              GetID = function()
                return checkCFunc(__index.GetID)
              end,
              GetLeft = function()
                return checkCFunc(__index.GetLeft)
              end,
              GetLight = function()
                return checkCFunc(__index.GetLight)
              end,
              GetMaxResize = function()
                return checkCFunc(__index.GetMaxResize)
              end,
              GetMinResize = function()
                return checkCFunc(__index.GetMinResize)
              end,
              GetModelAlpha = function()
                return checkCFunc(__index.GetModelAlpha)
              end,
              GetModelDrawLayer = function()
                return checkCFunc(__index.GetModelDrawLayer)
              end,
              GetModelFileID = function()
                return checkCFunc(__index.GetModelFileID)
              end,
              GetModelScale = function()
                return checkCFunc(__index.GetModelScale)
              end,
              GetName = function()
                return checkCFunc(__index.GetName)
              end,
              GetNumChildren = function()
                return checkCFunc(__index.GetNumChildren)
              end,
              GetNumPoints = function()
                return checkCFunc(__index.GetNumPoints)
              end,
              GetNumRegions = function()
                return checkCFunc(__index.GetNumRegions)
              end,
              GetObjectType = function()
                return checkCFunc(__index.GetObjectType)
              end,
              GetParent = function()
                return checkCFunc(__index.GetParent)
              end,
              GetPaused = function()
                return checkCFunc(__index.GetPaused)
              end,
              GetPitch = function()
                return checkCFunc(__index.GetPitch)
              end,
              GetPoint = function()
                return checkCFunc(__index.GetPoint)
              end,
              GetPointByName = function()
                return checkCFunc(__index.GetPointByName)
              end,
              GetPosition = function()
                return checkCFunc(__index.GetPosition)
              end,
              GetPropagateKeyboardInput = function()
                return checkCFunc(__index.GetPropagateKeyboardInput)
              end,
              GetRect = function()
                return checkCFunc(__index.GetRect)
              end,
              GetRegions = function()
                return checkCFunc(__index.GetRegions)
              end,
              GetRight = function()
                return checkCFunc(__index.GetRight)
              end,
              GetRoll = function()
                return checkCFunc(__index.GetRoll)
              end,
              GetScale = function()
                return checkCFunc(__index.GetScale)
              end,
              GetScaledRect = function()
                return checkCFunc(__index.GetScaledRect)
              end,
              GetScript = function()
                return checkCFunc(__index.GetScript)
              end,
              GetShadowEffect = function()
                return checkCFunc(__index.GetShadowEffect)
              end,
              GetSize = function()
                return checkCFunc(__index.GetSize)
              end,
              GetSourceLocation = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetSourceLocation))
                  return
                end
                return checkCFunc(__index.GetSourceLocation)
              end,
              GetTop = function()
                return checkCFunc(__index.GetTop)
              end,
              GetViewInsets = function()
                return checkCFunc(__index.GetViewInsets)
              end,
              GetViewTranslation = function()
                return checkCFunc(__index.GetViewTranslation)
              end,
              GetWidth = function()
                return checkCFunc(__index.GetWidth)
              end,
              GetWorldScale = function()
                return checkCFunc(__index.GetWorldScale)
              end,
              HasAttachmentPoints = function()
                return checkCFunc(__index.HasAttachmentPoints)
              end,
              HasCustomCamera = function()
                return checkCFunc(__index.HasCustomCamera)
              end,
              HasFixedFrameLevel = function()
                return checkCFunc(__index.HasFixedFrameLevel)
              end,
              HasFixedFrameStrata = function()
                return checkCFunc(__index.HasFixedFrameStrata)
              end,
              HasScript = function()
                return checkCFunc(__index.HasScript)
              end,
              Hide = function()
                return checkCFunc(__index.Hide)
              end,
              HookScript = function()
                return checkCFunc(__index.HookScript)
              end,
              IgnoreDepth = function()
                return checkCFunc(__index.IgnoreDepth)
              end,
              IsAnchoringRestricted = function()
                return checkCFunc(__index.IsAnchoringRestricted)
              end,
              IsClampedToScreen = function()
                return checkCFunc(__index.IsClampedToScreen)
              end,
              IsDragging = function()
                return checkCFunc(__index.IsDragging)
              end,
              IsEventRegistered = function()
                return checkCFunc(__index.IsEventRegistered)
              end,
              IsForbidden = function()
                return checkCFunc(__index.IsForbidden)
              end,
              IsGamePadButtonEnabled = function()
                return checkCFunc(__index.IsGamePadButtonEnabled)
              end,
              IsGamePadStickEnabled = function()
                return checkCFunc(__index.IsGamePadStickEnabled)
              end,
              IsIgnoringDepth = function()
                return checkCFunc(__index.IsIgnoringDepth)
              end,
              IsIgnoringParentAlpha = function()
                return checkCFunc(__index.IsIgnoringParentAlpha)
              end,
              IsIgnoringParentScale = function()
                return checkCFunc(__index.IsIgnoringParentScale)
              end,
              IsKeyboardEnabled = function()
                return checkCFunc(__index.IsKeyboardEnabled)
              end,
              IsMouseClickEnabled = function()
                return checkCFunc(__index.IsMouseClickEnabled)
              end,
              IsMouseEnabled = function()
                return checkCFunc(__index.IsMouseEnabled)
              end,
              IsMouseMotionEnabled = function()
                return checkCFunc(__index.IsMouseMotionEnabled)
              end,
              IsMouseOver = function()
                return checkCFunc(__index.IsMouseOver)
              end,
              IsMouseWheelEnabled = function()
                return checkCFunc(__index.IsMouseWheelEnabled)
              end,
              IsMovable = function()
                return checkCFunc(__index.IsMovable)
              end,
              IsObjectLoaded = function()
                return checkCFunc(__index.IsObjectLoaded)
              end,
              IsObjectType = function()
                return checkCFunc(__index.IsObjectType)
              end,
              IsProtected = function()
                return checkCFunc(__index.IsProtected)
              end,
              IsRectValid = function()
                return checkCFunc(__index.IsRectValid)
              end,
              IsResizable = function()
                return checkCFunc(__index.IsResizable)
              end,
              IsShown = function()
                return checkCFunc(__index.IsShown)
              end,
              IsToplevel = function()
                return checkCFunc(__index.IsToplevel)
              end,
              IsUserPlaced = function()
                return checkCFunc(__index.IsUserPlaced)
              end,
              IsUsingModelCenterToTransform = function()
                return checkCFunc(__index.IsUsingModelCenterToTransform)
              end,
              IsVisible = function()
                return checkCFunc(__index.IsVisible)
              end,
              Lower = function()
                return checkCFunc(__index.Lower)
              end,
              MakeCurrentCameraCustom = function()
                return checkCFunc(__index.MakeCurrentCameraCustom)
              end,
              Raise = function()
                return checkCFunc(__index.Raise)
              end,
              RegisterAllEvents = function()
                return checkCFunc(__index.RegisterAllEvents)
              end,
              RegisterEvent = function()
                return checkCFunc(__index.RegisterEvent)
              end,
              RegisterForDrag = function()
                return checkCFunc(__index.RegisterForDrag)
              end,
              RegisterUnitEvent = function()
                return checkCFunc(__index.RegisterUnitEvent)
              end,
              ReplaceIconTexture = function()
                return checkCFunc(__index.ReplaceIconTexture)
              end,
              RotateTextures = function()
                return checkCFunc(__index.RotateTextures)
              end,
              SetAllPoints = function()
                return checkCFunc(__index.SetAllPoints)
              end,
              SetAlpha = function()
                return checkCFunc(__index.SetAlpha)
              end,
              SetAttribute = function()
                return checkCFunc(__index.SetAttribute)
              end,
              SetAttributeNoHandler = function()
                return checkCFunc(__index.SetAttributeNoHandler)
              end,
              SetCamera = function()
                return checkCFunc(__index.SetCamera)
              end,
              SetCameraDistance = function()
                return checkCFunc(__index.SetCameraDistance)
              end,
              SetCameraFacing = function()
                return checkCFunc(__index.SetCameraFacing)
              end,
              SetCameraPosition = function()
                return checkCFunc(__index.SetCameraPosition)
              end,
              SetCameraRoll = function()
                return checkCFunc(__index.SetCameraRoll)
              end,
              SetCameraTarget = function()
                return checkCFunc(__index.SetCameraTarget)
              end,
              SetClampRectInsets = function()
                return checkCFunc(__index.SetClampRectInsets)
              end,
              SetClampedToScreen = function()
                return checkCFunc(__index.SetClampedToScreen)
              end,
              SetClipsChildren = function()
                return checkCFunc(__index.SetClipsChildren)
              end,
              SetCustomCamera = function()
                return checkCFunc(__index.SetCustomCamera)
              end,
              SetDepth = function()
                return checkCFunc(__index.SetDepth)
              end,
              SetDesaturation = function()
                return checkCFunc(__index.SetDesaturation)
              end,
              SetDontSavePosition = function()
                return checkCFunc(__index.SetDontSavePosition)
              end,
              SetDrawLayerEnabled = function()
                return checkCFunc(__index.SetDrawLayerEnabled)
              end,
              SetFacing = function()
                return checkCFunc(__index.SetFacing)
              end,
              SetFixedFrameLevel = function()
                return checkCFunc(__index.SetFixedFrameLevel)
              end,
              SetFixedFrameStrata = function()
                return checkCFunc(__index.SetFixedFrameStrata)
              end,
              SetFlattensRenderLayers = function()
                return checkCFunc(__index.SetFlattensRenderLayers)
              end,
              SetFogColor = function()
                return checkCFunc(__index.SetFogColor)
              end,
              SetFogFar = function()
                return checkCFunc(__index.SetFogFar)
              end,
              SetFogNear = function()
                return checkCFunc(__index.SetFogNear)
              end,
              SetForbidden = function()
                return checkCFunc(__index.SetForbidden)
              end,
              SetFrameBuffer = function()
                return checkCFunc(__index.SetFrameBuffer)
              end,
              SetFrameLevel = function()
                return checkCFunc(__index.SetFrameLevel)
              end,
              SetFrameStrata = function()
                return checkCFunc(__index.SetFrameStrata)
              end,
              SetGlow = function()
                return checkCFunc(__index.SetGlow)
              end,
              SetHeight = function()
                return checkCFunc(__index.SetHeight)
              end,
              SetHitRectInsets = function()
                return checkCFunc(__index.SetHitRectInsets)
              end,
              SetHyperlinksEnabled = function()
                return checkCFunc(__index.SetHyperlinksEnabled)
              end,
              SetID = function()
                return checkCFunc(__index.SetID)
              end,
              SetIgnoreParentAlpha = function()
                return checkCFunc(__index.SetIgnoreParentAlpha)
              end,
              SetIgnoreParentScale = function()
                return checkCFunc(__index.SetIgnoreParentScale)
              end,
              SetLight = function()
                return checkCFunc(__index.SetLight)
              end,
              SetMaxResize = function()
                return checkCFunc(__index.SetMaxResize)
              end,
              SetMinResize = function()
                return checkCFunc(__index.SetMinResize)
              end,
              SetModel = function()
                return checkCFunc(__index.SetModel)
              end,
              SetModelAlpha = function()
                return checkCFunc(__index.SetModelAlpha)
              end,
              SetModelDrawLayer = function()
                return checkCFunc(__index.SetModelDrawLayer)
              end,
              SetModelScale = function()
                return checkCFunc(__index.SetModelScale)
              end,
              SetMouseClickEnabled = function()
                return checkCFunc(__index.SetMouseClickEnabled)
              end,
              SetMouseMotionEnabled = function()
                return checkCFunc(__index.SetMouseMotionEnabled)
              end,
              SetMovable = function()
                return checkCFunc(__index.SetMovable)
              end,
              SetParent = function()
                return checkCFunc(__index.SetParent)
              end,
              SetParticlesEnabled = function()
                return checkCFunc(__index.SetParticlesEnabled)
              end,
              SetPaused = function()
                return checkCFunc(__index.SetPaused)
              end,
              SetPitch = function()
                return checkCFunc(__index.SetPitch)
              end,
              SetPoint = function()
                return checkCFunc(__index.SetPoint)
              end,
              SetPosition = function()
                return checkCFunc(__index.SetPosition)
              end,
              SetPropagateKeyboardInput = function()
                return checkCFunc(__index.SetPropagateKeyboardInput)
              end,
              SetResizable = function()
                return checkCFunc(__index.SetResizable)
              end,
              SetRoll = function()
                return checkCFunc(__index.SetRoll)
              end,
              SetScale = function()
                return checkCFunc(__index.SetScale)
              end,
              SetScript = function()
                return checkCFunc(__index.SetScript)
              end,
              SetSequence = function()
                return checkCFunc(__index.SetSequence)
              end,
              SetSequenceTime = function()
                return checkCFunc(__index.SetSequenceTime)
              end,
              SetShadowEffect = function()
                return checkCFunc(__index.SetShadowEffect)
              end,
              SetShown = function()
                return checkCFunc(__index.SetShown)
              end,
              SetSize = function()
                return checkCFunc(__index.SetSize)
              end,
              SetToplevel = function()
                return checkCFunc(__index.SetToplevel)
              end,
              SetTransform = function()
                return checkCFunc(__index.SetTransform)
              end,
              SetUserPlaced = function()
                return checkCFunc(__index.SetUserPlaced)
              end,
              SetViewInsets = function()
                return checkCFunc(__index.SetViewInsets)
              end,
              SetViewTranslation = function()
                return checkCFunc(__index.SetViewTranslation)
              end,
              SetWidth = function()
                return checkCFunc(__index.SetWidth)
              end,
              Show = function()
                return checkCFunc(__index.Show)
              end,
              StartMoving = function()
                return checkCFunc(__index.StartMoving)
              end,
              StartSizing = function()
                return checkCFunc(__index.StartSizing)
              end,
              StopAnimating = function()
                return checkCFunc(__index.StopAnimating)
              end,
              StopMovingOrSizing = function()
                return checkCFunc(__index.StopMovingOrSizing)
              end,
              TransformCameraSpaceToModelSpace = function()
                return checkCFunc(__index.TransformCameraSpaceToModelSpace)
              end,
              UnregisterAllEvents = function()
                return checkCFunc(__index.UnregisterAllEvents)
              end,
              UnregisterEvent = function()
                return checkCFunc(__index.UnregisterEvent)
              end,
              UseModelCenterToTransform = function()
                return checkCFunc(__index.UseModelCenterToTransform)
              end,
            }
          end)
        end,
        ModelScene = function()
          local function factory()
            return assertCreateFrame('ModelScene')
          end
          return mkTests('ModelScene', factory, function(__index)
            return {
              AdjustPointsOffset = function()
                return checkCFunc(__index.AdjustPointsOffset)
              end,
              CanChangeAttribute = function()
                return checkCFunc(__index.CanChangeAttribute)
              end,
              CanChangeProtectedState = function()
                return checkCFunc(__index.CanChangeProtectedState)
              end,
              ClearAllPoints = function()
                return checkCFunc(__index.ClearAllPoints)
              end,
              ClearFog = function()
                return checkCFunc(__index.ClearFog)
              end,
              ClearPointByName = function()
                return checkCFunc(__index.ClearPointByName)
              end,
              ClearPointsOffset = function()
                return checkCFunc(__index.ClearPointsOffset)
              end,
              CreateActor = function()
                return checkCFunc(__index.CreateActor)
              end,
              CreateAnimationGroup = function()
                return checkCFunc(__index.CreateAnimationGroup)
              end,
              CreateFontString = function()
                return checkCFunc(__index.CreateFontString)
              end,
              CreateLine = function()
                return checkCFunc(__index.CreateLine)
              end,
              CreateMaskTexture = function()
                return checkCFunc(__index.CreateMaskTexture)
              end,
              CreateTexture = function()
                return checkCFunc(__index.CreateTexture)
              end,
              DesaturateHierarchy = function()
                return checkCFunc(__index.DesaturateHierarchy)
              end,
              DisableDrawLayer = function()
                return checkCFunc(__index.DisableDrawLayer)
              end,
              DoesClipChildren = function()
                return checkCFunc(__index.DoesClipChildren)
              end,
              EnableDrawLayer = function()
                return checkCFunc(__index.EnableDrawLayer)
              end,
              EnableGamePadButton = function()
                return checkCFunc(__index.EnableGamePadButton)
              end,
              EnableGamePadStick = function()
                return checkCFunc(__index.EnableGamePadStick)
              end,
              EnableKeyboard = function()
                return checkCFunc(__index.EnableKeyboard)
              end,
              EnableMouse = function()
                return checkCFunc(__index.EnableMouse)
              end,
              EnableMouseWheel = function()
                return checkCFunc(__index.EnableMouseWheel)
              end,
              ExecuteAttribute = function()
                return checkCFunc(__index.ExecuteAttribute)
              end,
              GetActorAtIndex = function()
                return checkCFunc(__index.GetActorAtIndex)
              end,
              GetAlpha = function()
                return checkCFunc(__index.GetAlpha)
              end,
              GetAnimationGroups = function()
                return checkCFunc(__index.GetAnimationGroups)
              end,
              GetAttribute = function()
                return checkCFunc(__index.GetAttribute)
              end,
              GetBottom = function()
                return checkCFunc(__index.GetBottom)
              end,
              GetBoundsRect = function()
                return checkCFunc(__index.GetBoundsRect)
              end,
              GetCameraFarClip = function()
                return checkCFunc(__index.GetCameraFarClip)
              end,
              GetCameraFieldOfView = function()
                return checkCFunc(__index.GetCameraFieldOfView)
              end,
              GetCameraForward = function()
                return checkCFunc(__index.GetCameraForward)
              end,
              GetCameraNearClip = function()
                return checkCFunc(__index.GetCameraNearClip)
              end,
              GetCameraPosition = function()
                return checkCFunc(__index.GetCameraPosition)
              end,
              GetCameraRight = function()
                return checkCFunc(__index.GetCameraRight)
              end,
              GetCameraUp = function()
                return checkCFunc(__index.GetCameraUp)
              end,
              GetCenter = function()
                return checkCFunc(__index.GetCenter)
              end,
              GetChildren = function()
                return checkCFunc(__index.GetChildren)
              end,
              GetClampRectInsets = function()
                return checkCFunc(__index.GetClampRectInsets)
              end,
              GetDebugName = function()
                return checkCFunc(__index.GetDebugName)
              end,
              GetDepth = function()
                return checkCFunc(__index.GetDepth)
              end,
              GetDontSavePosition = function()
                return checkCFunc(__index.GetDontSavePosition)
              end,
              GetDrawLayer = function()
                return checkCFunc(__index.GetDrawLayer)
              end,
              GetEffectiveAlpha = function()
                return checkCFunc(__index.GetEffectiveAlpha)
              end,
              GetEffectiveDepth = function()
                return checkCFunc(__index.GetEffectiveDepth)
              end,
              GetEffectiveScale = function()
                return checkCFunc(__index.GetEffectiveScale)
              end,
              GetEffectivelyFlattensRenderLayers = function()
                return checkCFunc(__index.GetEffectivelyFlattensRenderLayers)
              end,
              GetFlattensRenderLayers = function()
                return checkCFunc(__index.GetFlattensRenderLayers)
              end,
              GetFogColor = function()
                return checkCFunc(__index.GetFogColor)
              end,
              GetFogFar = function()
                return checkCFunc(__index.GetFogFar)
              end,
              GetFogNear = function()
                return checkCFunc(__index.GetFogNear)
              end,
              GetFrameLevel = function()
                return checkCFunc(__index.GetFrameLevel)
              end,
              GetFrameStrata = function()
                return checkCFunc(__index.GetFrameStrata)
              end,
              GetHeight = function()
                return checkCFunc(__index.GetHeight)
              end,
              GetHitRectInsets = function()
                return checkCFunc(__index.GetHitRectInsets)
              end,
              GetHyperlinksEnabled = function()
                return checkCFunc(__index.GetHyperlinksEnabled)
              end,
              GetID = function()
                return checkCFunc(__index.GetID)
              end,
              GetLeft = function()
                return checkCFunc(__index.GetLeft)
              end,
              GetLightAmbientColor = function()
                return checkCFunc(__index.GetLightAmbientColor)
              end,
              GetLightDiffuseColor = function()
                return checkCFunc(__index.GetLightDiffuseColor)
              end,
              GetLightDirection = function()
                return checkCFunc(__index.GetLightDirection)
              end,
              GetLightPosition = function()
                return checkCFunc(__index.GetLightPosition)
              end,
              GetLightType = function()
                return checkCFunc(__index.GetLightType)
              end,
              GetMaxResize = function()
                return checkCFunc(__index.GetMaxResize)
              end,
              GetMinResize = function()
                return checkCFunc(__index.GetMinResize)
              end,
              GetName = function()
                return checkCFunc(__index.GetName)
              end,
              GetNumActors = function()
                return checkCFunc(__index.GetNumActors)
              end,
              GetNumChildren = function()
                return checkCFunc(__index.GetNumChildren)
              end,
              GetNumPoints = function()
                return checkCFunc(__index.GetNumPoints)
              end,
              GetNumRegions = function()
                return checkCFunc(__index.GetNumRegions)
              end,
              GetObjectType = function()
                return checkCFunc(__index.GetObjectType)
              end,
              GetParent = function()
                return checkCFunc(__index.GetParent)
              end,
              GetPoint = function()
                return checkCFunc(__index.GetPoint)
              end,
              GetPointByName = function()
                return checkCFunc(__index.GetPointByName)
              end,
              GetPropagateKeyboardInput = function()
                return checkCFunc(__index.GetPropagateKeyboardInput)
              end,
              GetRect = function()
                return checkCFunc(__index.GetRect)
              end,
              GetRegions = function()
                return checkCFunc(__index.GetRegions)
              end,
              GetRight = function()
                return checkCFunc(__index.GetRight)
              end,
              GetScale = function()
                return checkCFunc(__index.GetScale)
              end,
              GetScaledRect = function()
                return checkCFunc(__index.GetScaledRect)
              end,
              GetScript = function()
                return checkCFunc(__index.GetScript)
              end,
              GetSize = function()
                return checkCFunc(__index.GetSize)
              end,
              GetSourceLocation = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetSourceLocation))
                  return
                end
                return checkCFunc(__index.GetSourceLocation)
              end,
              GetTop = function()
                return checkCFunc(__index.GetTop)
              end,
              GetViewInsets = function()
                return checkCFunc(__index.GetViewInsets)
              end,
              GetViewTranslation = function()
                return checkCFunc(__index.GetViewTranslation)
              end,
              GetWidth = function()
                return checkCFunc(__index.GetWidth)
              end,
              HasFixedFrameLevel = function()
                return checkCFunc(__index.HasFixedFrameLevel)
              end,
              HasFixedFrameStrata = function()
                return checkCFunc(__index.HasFixedFrameStrata)
              end,
              HasScript = function()
                return checkCFunc(__index.HasScript)
              end,
              Hide = function()
                return checkCFunc(__index.Hide)
              end,
              HookScript = function()
                return checkCFunc(__index.HookScript)
              end,
              IgnoreDepth = function()
                return checkCFunc(__index.IgnoreDepth)
              end,
              IsAnchoringRestricted = function()
                return checkCFunc(__index.IsAnchoringRestricted)
              end,
              IsClampedToScreen = function()
                return checkCFunc(__index.IsClampedToScreen)
              end,
              IsDragging = function()
                return checkCFunc(__index.IsDragging)
              end,
              IsEventRegistered = function()
                return checkCFunc(__index.IsEventRegistered)
              end,
              IsForbidden = function()
                return checkCFunc(__index.IsForbidden)
              end,
              IsGamePadButtonEnabled = function()
                return checkCFunc(__index.IsGamePadButtonEnabled)
              end,
              IsGamePadStickEnabled = function()
                return checkCFunc(__index.IsGamePadStickEnabled)
              end,
              IsIgnoringDepth = function()
                return checkCFunc(__index.IsIgnoringDepth)
              end,
              IsIgnoringParentAlpha = function()
                return checkCFunc(__index.IsIgnoringParentAlpha)
              end,
              IsIgnoringParentScale = function()
                return checkCFunc(__index.IsIgnoringParentScale)
              end,
              IsKeyboardEnabled = function()
                return checkCFunc(__index.IsKeyboardEnabled)
              end,
              IsLightVisible = function()
                return checkCFunc(__index.IsLightVisible)
              end,
              IsMouseClickEnabled = function()
                return checkCFunc(__index.IsMouseClickEnabled)
              end,
              IsMouseEnabled = function()
                return checkCFunc(__index.IsMouseEnabled)
              end,
              IsMouseMotionEnabled = function()
                return checkCFunc(__index.IsMouseMotionEnabled)
              end,
              IsMouseOver = function()
                return checkCFunc(__index.IsMouseOver)
              end,
              IsMouseWheelEnabled = function()
                return checkCFunc(__index.IsMouseWheelEnabled)
              end,
              IsMovable = function()
                return checkCFunc(__index.IsMovable)
              end,
              IsObjectLoaded = function()
                return checkCFunc(__index.IsObjectLoaded)
              end,
              IsObjectType = function()
                return checkCFunc(__index.IsObjectType)
              end,
              IsProtected = function()
                return checkCFunc(__index.IsProtected)
              end,
              IsRectValid = function()
                return checkCFunc(__index.IsRectValid)
              end,
              IsResizable = function()
                return checkCFunc(__index.IsResizable)
              end,
              IsShown = function()
                return checkCFunc(__index.IsShown)
              end,
              IsToplevel = function()
                return checkCFunc(__index.IsToplevel)
              end,
              IsUserPlaced = function()
                return checkCFunc(__index.IsUserPlaced)
              end,
              IsVisible = function()
                return checkCFunc(__index.IsVisible)
              end,
              Lower = function()
                return checkCFunc(__index.Lower)
              end,
              Project3DPointTo2D = function()
                return checkCFunc(__index.Project3DPointTo2D)
              end,
              Raise = function()
                return checkCFunc(__index.Raise)
              end,
              RegisterAllEvents = function()
                return checkCFunc(__index.RegisterAllEvents)
              end,
              RegisterEvent = function()
                return checkCFunc(__index.RegisterEvent)
              end,
              RegisterForDrag = function()
                return checkCFunc(__index.RegisterForDrag)
              end,
              RegisterUnitEvent = function()
                return checkCFunc(__index.RegisterUnitEvent)
              end,
              RotateTextures = function()
                return checkCFunc(__index.RotateTextures)
              end,
              SetAllPoints = function()
                return checkCFunc(__index.SetAllPoints)
              end,
              SetAlpha = function()
                return checkCFunc(__index.SetAlpha)
              end,
              SetAttribute = function()
                return checkCFunc(__index.SetAttribute)
              end,
              SetAttributeNoHandler = function()
                return checkCFunc(__index.SetAttributeNoHandler)
              end,
              SetCameraFarClip = function()
                return checkCFunc(__index.SetCameraFarClip)
              end,
              SetCameraFieldOfView = function()
                return checkCFunc(__index.SetCameraFieldOfView)
              end,
              SetCameraNearClip = function()
                return checkCFunc(__index.SetCameraNearClip)
              end,
              SetCameraOrientationByAxisVectors = function()
                return checkCFunc(__index.SetCameraOrientationByAxisVectors)
              end,
              SetCameraOrientationByYawPitchRoll = function()
                return checkCFunc(__index.SetCameraOrientationByYawPitchRoll)
              end,
              SetCameraPosition = function()
                return checkCFunc(__index.SetCameraPosition)
              end,
              SetClampRectInsets = function()
                return checkCFunc(__index.SetClampRectInsets)
              end,
              SetClampedToScreen = function()
                return checkCFunc(__index.SetClampedToScreen)
              end,
              SetClipsChildren = function()
                return checkCFunc(__index.SetClipsChildren)
              end,
              SetDepth = function()
                return checkCFunc(__index.SetDepth)
              end,
              SetDesaturation = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetDesaturation))
                  return
                end
                return checkCFunc(__index.SetDesaturation)
              end,
              SetDontSavePosition = function()
                return checkCFunc(__index.SetDontSavePosition)
              end,
              SetDrawLayer = function()
                return checkCFunc(__index.SetDrawLayer)
              end,
              SetDrawLayerEnabled = function()
                return checkCFunc(__index.SetDrawLayerEnabled)
              end,
              SetFixedFrameLevel = function()
                return checkCFunc(__index.SetFixedFrameLevel)
              end,
              SetFixedFrameStrata = function()
                return checkCFunc(__index.SetFixedFrameStrata)
              end,
              SetFlattensRenderLayers = function()
                return checkCFunc(__index.SetFlattensRenderLayers)
              end,
              SetFogColor = function()
                return checkCFunc(__index.SetFogColor)
              end,
              SetFogFar = function()
                return checkCFunc(__index.SetFogFar)
              end,
              SetFogNear = function()
                return checkCFunc(__index.SetFogNear)
              end,
              SetForbidden = function()
                return checkCFunc(__index.SetForbidden)
              end,
              SetFrameBuffer = function()
                return checkCFunc(__index.SetFrameBuffer)
              end,
              SetFrameLevel = function()
                return checkCFunc(__index.SetFrameLevel)
              end,
              SetFrameStrata = function()
                return checkCFunc(__index.SetFrameStrata)
              end,
              SetHeight = function()
                return checkCFunc(__index.SetHeight)
              end,
              SetHitRectInsets = function()
                return checkCFunc(__index.SetHitRectInsets)
              end,
              SetHyperlinksEnabled = function()
                return checkCFunc(__index.SetHyperlinksEnabled)
              end,
              SetID = function()
                return checkCFunc(__index.SetID)
              end,
              SetIgnoreParentAlpha = function()
                return checkCFunc(__index.SetIgnoreParentAlpha)
              end,
              SetIgnoreParentScale = function()
                return checkCFunc(__index.SetIgnoreParentScale)
              end,
              SetLightAmbientColor = function()
                return checkCFunc(__index.SetLightAmbientColor)
              end,
              SetLightDiffuseColor = function()
                return checkCFunc(__index.SetLightDiffuseColor)
              end,
              SetLightDirection = function()
                return checkCFunc(__index.SetLightDirection)
              end,
              SetLightPosition = function()
                return checkCFunc(__index.SetLightPosition)
              end,
              SetLightType = function()
                return checkCFunc(__index.SetLightType)
              end,
              SetLightVisible = function()
                return checkCFunc(__index.SetLightVisible)
              end,
              SetMaxResize = function()
                return checkCFunc(__index.SetMaxResize)
              end,
              SetMinResize = function()
                return checkCFunc(__index.SetMinResize)
              end,
              SetMouseClickEnabled = function()
                return checkCFunc(__index.SetMouseClickEnabled)
              end,
              SetMouseMotionEnabled = function()
                return checkCFunc(__index.SetMouseMotionEnabled)
              end,
              SetMovable = function()
                return checkCFunc(__index.SetMovable)
              end,
              SetParent = function()
                return checkCFunc(__index.SetParent)
              end,
              SetPaused = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.SetPaused))
                  return
                end
                return checkCFunc(__index.SetPaused)
              end,
              SetPoint = function()
                return checkCFunc(__index.SetPoint)
              end,
              SetPropagateKeyboardInput = function()
                return checkCFunc(__index.SetPropagateKeyboardInput)
              end,
              SetResizable = function()
                return checkCFunc(__index.SetResizable)
              end,
              SetScale = function()
                return checkCFunc(__index.SetScale)
              end,
              SetScript = function()
                return checkCFunc(__index.SetScript)
              end,
              SetShown = function()
                return checkCFunc(__index.SetShown)
              end,
              SetSize = function()
                return checkCFunc(__index.SetSize)
              end,
              SetToplevel = function()
                return checkCFunc(__index.SetToplevel)
              end,
              SetUserPlaced = function()
                return checkCFunc(__index.SetUserPlaced)
              end,
              SetViewInsets = function()
                return checkCFunc(__index.SetViewInsets)
              end,
              SetViewTranslation = function()
                return checkCFunc(__index.SetViewTranslation)
              end,
              SetWidth = function()
                return checkCFunc(__index.SetWidth)
              end,
              Show = function()
                return checkCFunc(__index.Show)
              end,
              StartMoving = function()
                return checkCFunc(__index.StartMoving)
              end,
              StartSizing = function()
                return checkCFunc(__index.StartSizing)
              end,
              StopAnimating = function()
                return checkCFunc(__index.StopAnimating)
              end,
              StopMovingOrSizing = function()
                return checkCFunc(__index.StopMovingOrSizing)
              end,
              TakeActor = function()
                return checkCFunc(__index.TakeActor)
              end,
              UnregisterAllEvents = function()
                return checkCFunc(__index.UnregisterAllEvents)
              end,
              UnregisterEvent = function()
                return checkCFunc(__index.UnregisterEvent)
              end,
            }
          end)
        end,
        MovieFrame = function()
          local function factory()
            return assertCreateFrame('MovieFrame')
          end
          return mkTests('MovieFrame', factory, function(__index)
            return {
              AdjustPointsOffset = function()
                return checkCFunc(__index.AdjustPointsOffset)
              end,
              CanChangeAttribute = function()
                return checkCFunc(__index.CanChangeAttribute)
              end,
              CanChangeProtectedState = function()
                return checkCFunc(__index.CanChangeProtectedState)
              end,
              ClearAllPoints = function()
                return checkCFunc(__index.ClearAllPoints)
              end,
              ClearPointByName = function()
                return checkCFunc(__index.ClearPointByName)
              end,
              ClearPointsOffset = function()
                return checkCFunc(__index.ClearPointsOffset)
              end,
              CreateAnimationGroup = function()
                return checkCFunc(__index.CreateAnimationGroup)
              end,
              CreateFontString = function()
                return checkCFunc(__index.CreateFontString)
              end,
              CreateLine = function()
                return checkCFunc(__index.CreateLine)
              end,
              CreateMaskTexture = function()
                return checkCFunc(__index.CreateMaskTexture)
              end,
              CreateTexture = function()
                return checkCFunc(__index.CreateTexture)
              end,
              DesaturateHierarchy = function()
                return checkCFunc(__index.DesaturateHierarchy)
              end,
              DisableDrawLayer = function()
                return checkCFunc(__index.DisableDrawLayer)
              end,
              DoesClipChildren = function()
                return checkCFunc(__index.DoesClipChildren)
              end,
              EnableDrawLayer = function()
                return checkCFunc(__index.EnableDrawLayer)
              end,
              EnableGamePadButton = function()
                return checkCFunc(__index.EnableGamePadButton)
              end,
              EnableGamePadStick = function()
                return checkCFunc(__index.EnableGamePadStick)
              end,
              EnableKeyboard = function()
                return checkCFunc(__index.EnableKeyboard)
              end,
              EnableMouse = function()
                return checkCFunc(__index.EnableMouse)
              end,
              EnableMouseWheel = function()
                return checkCFunc(__index.EnableMouseWheel)
              end,
              EnableSubtitles = function()
                return checkCFunc(__index.EnableSubtitles)
              end,
              ExecuteAttribute = function()
                return checkCFunc(__index.ExecuteAttribute)
              end,
              GetAlpha = function()
                return checkCFunc(__index.GetAlpha)
              end,
              GetAnimationGroups = function()
                return checkCFunc(__index.GetAnimationGroups)
              end,
              GetAttribute = function()
                return checkCFunc(__index.GetAttribute)
              end,
              GetBottom = function()
                return checkCFunc(__index.GetBottom)
              end,
              GetBoundsRect = function()
                return checkCFunc(__index.GetBoundsRect)
              end,
              GetCenter = function()
                return checkCFunc(__index.GetCenter)
              end,
              GetChildren = function()
                return checkCFunc(__index.GetChildren)
              end,
              GetClampRectInsets = function()
                return checkCFunc(__index.GetClampRectInsets)
              end,
              GetDebugName = function()
                return checkCFunc(__index.GetDebugName)
              end,
              GetDepth = function()
                return checkCFunc(__index.GetDepth)
              end,
              GetDontSavePosition = function()
                return checkCFunc(__index.GetDontSavePosition)
              end,
              GetEffectiveAlpha = function()
                return checkCFunc(__index.GetEffectiveAlpha)
              end,
              GetEffectiveDepth = function()
                return checkCFunc(__index.GetEffectiveDepth)
              end,
              GetEffectiveScale = function()
                return checkCFunc(__index.GetEffectiveScale)
              end,
              GetEffectivelyFlattensRenderLayers = function()
                return checkCFunc(__index.GetEffectivelyFlattensRenderLayers)
              end,
              GetFlattensRenderLayers = function()
                return checkCFunc(__index.GetFlattensRenderLayers)
              end,
              GetFrameLevel = function()
                return checkCFunc(__index.GetFrameLevel)
              end,
              GetFrameStrata = function()
                return checkCFunc(__index.GetFrameStrata)
              end,
              GetHeight = function()
                return checkCFunc(__index.GetHeight)
              end,
              GetHitRectInsets = function()
                return checkCFunc(__index.GetHitRectInsets)
              end,
              GetHyperlinksEnabled = function()
                return checkCFunc(__index.GetHyperlinksEnabled)
              end,
              GetID = function()
                return checkCFunc(__index.GetID)
              end,
              GetLeft = function()
                return checkCFunc(__index.GetLeft)
              end,
              GetMaxResize = function()
                return checkCFunc(__index.GetMaxResize)
              end,
              GetMinResize = function()
                return checkCFunc(__index.GetMinResize)
              end,
              GetName = function()
                return checkCFunc(__index.GetName)
              end,
              GetNumChildren = function()
                return checkCFunc(__index.GetNumChildren)
              end,
              GetNumPoints = function()
                return checkCFunc(__index.GetNumPoints)
              end,
              GetNumRegions = function()
                return checkCFunc(__index.GetNumRegions)
              end,
              GetObjectType = function()
                return checkCFunc(__index.GetObjectType)
              end,
              GetParent = function()
                return checkCFunc(__index.GetParent)
              end,
              GetPoint = function()
                return checkCFunc(__index.GetPoint)
              end,
              GetPointByName = function()
                return checkCFunc(__index.GetPointByName)
              end,
              GetPropagateKeyboardInput = function()
                return checkCFunc(__index.GetPropagateKeyboardInput)
              end,
              GetRect = function()
                return checkCFunc(__index.GetRect)
              end,
              GetRegions = function()
                return checkCFunc(__index.GetRegions)
              end,
              GetRight = function()
                return checkCFunc(__index.GetRight)
              end,
              GetScale = function()
                return checkCFunc(__index.GetScale)
              end,
              GetScaledRect = function()
                return checkCFunc(__index.GetScaledRect)
              end,
              GetScript = function()
                return checkCFunc(__index.GetScript)
              end,
              GetSize = function()
                return checkCFunc(__index.GetSize)
              end,
              GetSourceLocation = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetSourceLocation))
                  return
                end
                return checkCFunc(__index.GetSourceLocation)
              end,
              GetTop = function()
                return checkCFunc(__index.GetTop)
              end,
              GetWidth = function()
                return checkCFunc(__index.GetWidth)
              end,
              HasFixedFrameLevel = function()
                return checkCFunc(__index.HasFixedFrameLevel)
              end,
              HasFixedFrameStrata = function()
                return checkCFunc(__index.HasFixedFrameStrata)
              end,
              HasScript = function()
                return checkCFunc(__index.HasScript)
              end,
              Hide = function()
                return checkCFunc(__index.Hide)
              end,
              HookScript = function()
                return checkCFunc(__index.HookScript)
              end,
              IgnoreDepth = function()
                return checkCFunc(__index.IgnoreDepth)
              end,
              IsAnchoringRestricted = function()
                return checkCFunc(__index.IsAnchoringRestricted)
              end,
              IsClampedToScreen = function()
                return checkCFunc(__index.IsClampedToScreen)
              end,
              IsDragging = function()
                return checkCFunc(__index.IsDragging)
              end,
              IsEventRegistered = function()
                return checkCFunc(__index.IsEventRegistered)
              end,
              IsForbidden = function()
                return checkCFunc(__index.IsForbidden)
              end,
              IsGamePadButtonEnabled = function()
                return checkCFunc(__index.IsGamePadButtonEnabled)
              end,
              IsGamePadStickEnabled = function()
                return checkCFunc(__index.IsGamePadStickEnabled)
              end,
              IsIgnoringDepth = function()
                return checkCFunc(__index.IsIgnoringDepth)
              end,
              IsIgnoringParentAlpha = function()
                return checkCFunc(__index.IsIgnoringParentAlpha)
              end,
              IsIgnoringParentScale = function()
                return checkCFunc(__index.IsIgnoringParentScale)
              end,
              IsKeyboardEnabled = function()
                return checkCFunc(__index.IsKeyboardEnabled)
              end,
              IsMouseClickEnabled = function()
                return checkCFunc(__index.IsMouseClickEnabled)
              end,
              IsMouseEnabled = function()
                return checkCFunc(__index.IsMouseEnabled)
              end,
              IsMouseMotionEnabled = function()
                return checkCFunc(__index.IsMouseMotionEnabled)
              end,
              IsMouseOver = function()
                return checkCFunc(__index.IsMouseOver)
              end,
              IsMouseWheelEnabled = function()
                return checkCFunc(__index.IsMouseWheelEnabled)
              end,
              IsMovable = function()
                return checkCFunc(__index.IsMovable)
              end,
              IsObjectLoaded = function()
                return checkCFunc(__index.IsObjectLoaded)
              end,
              IsObjectType = function()
                return checkCFunc(__index.IsObjectType)
              end,
              IsProtected = function()
                return checkCFunc(__index.IsProtected)
              end,
              IsRectValid = function()
                return checkCFunc(__index.IsRectValid)
              end,
              IsResizable = function()
                return checkCFunc(__index.IsResizable)
              end,
              IsShown = function()
                return checkCFunc(__index.IsShown)
              end,
              IsToplevel = function()
                return checkCFunc(__index.IsToplevel)
              end,
              IsUserPlaced = function()
                return checkCFunc(__index.IsUserPlaced)
              end,
              IsVisible = function()
                return checkCFunc(__index.IsVisible)
              end,
              Lower = function()
                return checkCFunc(__index.Lower)
              end,
              Raise = function()
                return checkCFunc(__index.Raise)
              end,
              RegisterAllEvents = function()
                return checkCFunc(__index.RegisterAllEvents)
              end,
              RegisterEvent = function()
                return checkCFunc(__index.RegisterEvent)
              end,
              RegisterForDrag = function()
                return checkCFunc(__index.RegisterForDrag)
              end,
              RegisterUnitEvent = function()
                return checkCFunc(__index.RegisterUnitEvent)
              end,
              RotateTextures = function()
                return checkCFunc(__index.RotateTextures)
              end,
              SetAllPoints = function()
                return checkCFunc(__index.SetAllPoints)
              end,
              SetAlpha = function()
                return checkCFunc(__index.SetAlpha)
              end,
              SetAttribute = function()
                return checkCFunc(__index.SetAttribute)
              end,
              SetAttributeNoHandler = function()
                return checkCFunc(__index.SetAttributeNoHandler)
              end,
              SetClampRectInsets = function()
                return checkCFunc(__index.SetClampRectInsets)
              end,
              SetClampedToScreen = function()
                return checkCFunc(__index.SetClampedToScreen)
              end,
              SetClipsChildren = function()
                return checkCFunc(__index.SetClipsChildren)
              end,
              SetDepth = function()
                return checkCFunc(__index.SetDepth)
              end,
              SetDontSavePosition = function()
                return checkCFunc(__index.SetDontSavePosition)
              end,
              SetDrawLayerEnabled = function()
                return checkCFunc(__index.SetDrawLayerEnabled)
              end,
              SetFixedFrameLevel = function()
                return checkCFunc(__index.SetFixedFrameLevel)
              end,
              SetFixedFrameStrata = function()
                return checkCFunc(__index.SetFixedFrameStrata)
              end,
              SetFlattensRenderLayers = function()
                return checkCFunc(__index.SetFlattensRenderLayers)
              end,
              SetForbidden = function()
                return checkCFunc(__index.SetForbidden)
              end,
              SetFrameBuffer = function()
                return checkCFunc(__index.SetFrameBuffer)
              end,
              SetFrameLevel = function()
                return checkCFunc(__index.SetFrameLevel)
              end,
              SetFrameStrata = function()
                return checkCFunc(__index.SetFrameStrata)
              end,
              SetHeight = function()
                return checkCFunc(__index.SetHeight)
              end,
              SetHitRectInsets = function()
                return checkCFunc(__index.SetHitRectInsets)
              end,
              SetHyperlinksEnabled = function()
                return checkCFunc(__index.SetHyperlinksEnabled)
              end,
              SetID = function()
                return checkCFunc(__index.SetID)
              end,
              SetIgnoreParentAlpha = function()
                return checkCFunc(__index.SetIgnoreParentAlpha)
              end,
              SetIgnoreParentScale = function()
                return checkCFunc(__index.SetIgnoreParentScale)
              end,
              SetMaxResize = function()
                return checkCFunc(__index.SetMaxResize)
              end,
              SetMinResize = function()
                return checkCFunc(__index.SetMinResize)
              end,
              SetMouseClickEnabled = function()
                return checkCFunc(__index.SetMouseClickEnabled)
              end,
              SetMouseMotionEnabled = function()
                return checkCFunc(__index.SetMouseMotionEnabled)
              end,
              SetMovable = function()
                return checkCFunc(__index.SetMovable)
              end,
              SetParent = function()
                return checkCFunc(__index.SetParent)
              end,
              SetPoint = function()
                return checkCFunc(__index.SetPoint)
              end,
              SetPropagateKeyboardInput = function()
                return checkCFunc(__index.SetPropagateKeyboardInput)
              end,
              SetResizable = function()
                return checkCFunc(__index.SetResizable)
              end,
              SetScale = function()
                return checkCFunc(__index.SetScale)
              end,
              SetScript = function()
                return checkCFunc(__index.SetScript)
              end,
              SetShown = function()
                return checkCFunc(__index.SetShown)
              end,
              SetSize = function()
                return checkCFunc(__index.SetSize)
              end,
              SetToplevel = function()
                return checkCFunc(__index.SetToplevel)
              end,
              SetUserPlaced = function()
                return checkCFunc(__index.SetUserPlaced)
              end,
              SetWidth = function()
                return checkCFunc(__index.SetWidth)
              end,
              Show = function()
                return checkCFunc(__index.Show)
              end,
              StartMovie = function()
                return checkCFunc(__index.StartMovie)
              end,
              StartMoving = function()
                return checkCFunc(__index.StartMoving)
              end,
              StartSizing = function()
                return checkCFunc(__index.StartSizing)
              end,
              StopAnimating = function()
                return checkCFunc(__index.StopAnimating)
              end,
              StopMovie = function()
                return checkCFunc(__index.StopMovie)
              end,
              StopMovingOrSizing = function()
                return checkCFunc(__index.StopMovingOrSizing)
              end,
              UnregisterAllEvents = function()
                return checkCFunc(__index.UnregisterAllEvents)
              end,
              UnregisterEvent = function()
                return checkCFunc(__index.UnregisterEvent)
              end,
            }
          end)
        end,
        OffScreenFrame = function()
          local function factory()
            return assertCreateFrame('OffScreenFrame')
          end
          return mkTests('OffScreenFrame', factory, function(__index)
            return {
              AdjustPointsOffset = function()
                return checkCFunc(__index.AdjustPointsOffset)
              end,
              ApplySnapshot = function()
                return checkCFunc(__index.ApplySnapshot)
              end,
              CanChangeAttribute = function()
                return checkCFunc(__index.CanChangeAttribute)
              end,
              CanChangeProtectedState = function()
                return checkCFunc(__index.CanChangeProtectedState)
              end,
              ClearAllPoints = function()
                return checkCFunc(__index.ClearAllPoints)
              end,
              ClearPointByName = function()
                return checkCFunc(__index.ClearPointByName)
              end,
              ClearPointsOffset = function()
                return checkCFunc(__index.ClearPointsOffset)
              end,
              CreateAnimationGroup = function()
                return checkCFunc(__index.CreateAnimationGroup)
              end,
              CreateFontString = function()
                return checkCFunc(__index.CreateFontString)
              end,
              CreateLine = function()
                return checkCFunc(__index.CreateLine)
              end,
              CreateMaskTexture = function()
                return checkCFunc(__index.CreateMaskTexture)
              end,
              CreateTexture = function()
                return checkCFunc(__index.CreateTexture)
              end,
              DesaturateHierarchy = function()
                return checkCFunc(__index.DesaturateHierarchy)
              end,
              DisableDrawLayer = function()
                return checkCFunc(__index.DisableDrawLayer)
              end,
              DoesClipChildren = function()
                return checkCFunc(__index.DoesClipChildren)
              end,
              EnableDrawLayer = function()
                return checkCFunc(__index.EnableDrawLayer)
              end,
              EnableGamePadButton = function()
                return checkCFunc(__index.EnableGamePadButton)
              end,
              EnableGamePadStick = function()
                return checkCFunc(__index.EnableGamePadStick)
              end,
              EnableKeyboard = function()
                return checkCFunc(__index.EnableKeyboard)
              end,
              EnableMouse = function()
                return checkCFunc(__index.EnableMouse)
              end,
              EnableMouseWheel = function()
                return checkCFunc(__index.EnableMouseWheel)
              end,
              ExecuteAttribute = function()
                return checkCFunc(__index.ExecuteAttribute)
              end,
              Flush = function()
                return checkCFunc(__index.Flush)
              end,
              GetAlpha = function()
                return checkCFunc(__index.GetAlpha)
              end,
              GetAnimationGroups = function()
                return checkCFunc(__index.GetAnimationGroups)
              end,
              GetAttribute = function()
                return checkCFunc(__index.GetAttribute)
              end,
              GetBottom = function()
                return checkCFunc(__index.GetBottom)
              end,
              GetBoundsRect = function()
                return checkCFunc(__index.GetBoundsRect)
              end,
              GetCenter = function()
                return checkCFunc(__index.GetCenter)
              end,
              GetChildren = function()
                return checkCFunc(__index.GetChildren)
              end,
              GetClampRectInsets = function()
                return checkCFunc(__index.GetClampRectInsets)
              end,
              GetDebugName = function()
                return checkCFunc(__index.GetDebugName)
              end,
              GetDepth = function()
                return checkCFunc(__index.GetDepth)
              end,
              GetDontSavePosition = function()
                return checkCFunc(__index.GetDontSavePosition)
              end,
              GetEffectiveAlpha = function()
                return checkCFunc(__index.GetEffectiveAlpha)
              end,
              GetEffectiveDepth = function()
                return checkCFunc(__index.GetEffectiveDepth)
              end,
              GetEffectiveScale = function()
                return checkCFunc(__index.GetEffectiveScale)
              end,
              GetEffectivelyFlattensRenderLayers = function()
                return checkCFunc(__index.GetEffectivelyFlattensRenderLayers)
              end,
              GetFlattensRenderLayers = function()
                return checkCFunc(__index.GetFlattensRenderLayers)
              end,
              GetFrameLevel = function()
                return checkCFunc(__index.GetFrameLevel)
              end,
              GetFrameStrata = function()
                return checkCFunc(__index.GetFrameStrata)
              end,
              GetHeight = function()
                return checkCFunc(__index.GetHeight)
              end,
              GetHitRectInsets = function()
                return checkCFunc(__index.GetHitRectInsets)
              end,
              GetHyperlinksEnabled = function()
                return checkCFunc(__index.GetHyperlinksEnabled)
              end,
              GetID = function()
                return checkCFunc(__index.GetID)
              end,
              GetLeft = function()
                return checkCFunc(__index.GetLeft)
              end,
              GetMaxResize = function()
                return checkCFunc(__index.GetMaxResize)
              end,
              GetMaxSnapshots = function()
                return checkCFunc(__index.GetMaxSnapshots)
              end,
              GetMinResize = function()
                return checkCFunc(__index.GetMinResize)
              end,
              GetName = function()
                return checkCFunc(__index.GetName)
              end,
              GetNumChildren = function()
                return checkCFunc(__index.GetNumChildren)
              end,
              GetNumPoints = function()
                return checkCFunc(__index.GetNumPoints)
              end,
              GetNumRegions = function()
                return checkCFunc(__index.GetNumRegions)
              end,
              GetObjectType = function()
                return checkCFunc(__index.GetObjectType)
              end,
              GetParent = function()
                return checkCFunc(__index.GetParent)
              end,
              GetPoint = function()
                return checkCFunc(__index.GetPoint)
              end,
              GetPointByName = function()
                return checkCFunc(__index.GetPointByName)
              end,
              GetPropagateKeyboardInput = function()
                return checkCFunc(__index.GetPropagateKeyboardInput)
              end,
              GetRect = function()
                return checkCFunc(__index.GetRect)
              end,
              GetRegions = function()
                return checkCFunc(__index.GetRegions)
              end,
              GetRight = function()
                return checkCFunc(__index.GetRight)
              end,
              GetScale = function()
                return checkCFunc(__index.GetScale)
              end,
              GetScaledRect = function()
                return checkCFunc(__index.GetScaledRect)
              end,
              GetScript = function()
                return checkCFunc(__index.GetScript)
              end,
              GetSize = function()
                return checkCFunc(__index.GetSize)
              end,
              GetSourceLocation = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetSourceLocation))
                  return
                end
                return checkCFunc(__index.GetSourceLocation)
              end,
              GetTop = function()
                return checkCFunc(__index.GetTop)
              end,
              GetWidth = function()
                return checkCFunc(__index.GetWidth)
              end,
              HasFixedFrameLevel = function()
                return checkCFunc(__index.HasFixedFrameLevel)
              end,
              HasFixedFrameStrata = function()
                return checkCFunc(__index.HasFixedFrameStrata)
              end,
              HasScript = function()
                return checkCFunc(__index.HasScript)
              end,
              Hide = function()
                return checkCFunc(__index.Hide)
              end,
              HookScript = function()
                return checkCFunc(__index.HookScript)
              end,
              IgnoreDepth = function()
                return checkCFunc(__index.IgnoreDepth)
              end,
              IsAnchoringRestricted = function()
                return checkCFunc(__index.IsAnchoringRestricted)
              end,
              IsClampedToScreen = function()
                return checkCFunc(__index.IsClampedToScreen)
              end,
              IsDragging = function()
                return checkCFunc(__index.IsDragging)
              end,
              IsEventRegistered = function()
                return checkCFunc(__index.IsEventRegistered)
              end,
              IsForbidden = function()
                return checkCFunc(__index.IsForbidden)
              end,
              IsGamePadButtonEnabled = function()
                return checkCFunc(__index.IsGamePadButtonEnabled)
              end,
              IsGamePadStickEnabled = function()
                return checkCFunc(__index.IsGamePadStickEnabled)
              end,
              IsIgnoringDepth = function()
                return checkCFunc(__index.IsIgnoringDepth)
              end,
              IsIgnoringParentAlpha = function()
                return checkCFunc(__index.IsIgnoringParentAlpha)
              end,
              IsIgnoringParentScale = function()
                return checkCFunc(__index.IsIgnoringParentScale)
              end,
              IsKeyboardEnabled = function()
                return checkCFunc(__index.IsKeyboardEnabled)
              end,
              IsMouseClickEnabled = function()
                return checkCFunc(__index.IsMouseClickEnabled)
              end,
              IsMouseEnabled = function()
                return checkCFunc(__index.IsMouseEnabled)
              end,
              IsMouseMotionEnabled = function()
                return checkCFunc(__index.IsMouseMotionEnabled)
              end,
              IsMouseOver = function()
                return checkCFunc(__index.IsMouseOver)
              end,
              IsMouseWheelEnabled = function()
                return checkCFunc(__index.IsMouseWheelEnabled)
              end,
              IsMovable = function()
                return checkCFunc(__index.IsMovable)
              end,
              IsObjectLoaded = function()
                return checkCFunc(__index.IsObjectLoaded)
              end,
              IsObjectType = function()
                return checkCFunc(__index.IsObjectType)
              end,
              IsProtected = function()
                return checkCFunc(__index.IsProtected)
              end,
              IsRectValid = function()
                return checkCFunc(__index.IsRectValid)
              end,
              IsResizable = function()
                return checkCFunc(__index.IsResizable)
              end,
              IsShown = function()
                return checkCFunc(__index.IsShown)
              end,
              IsSnapshotValid = function()
                return checkCFunc(__index.IsSnapshotValid)
              end,
              IsToplevel = function()
                return checkCFunc(__index.IsToplevel)
              end,
              IsUserPlaced = function()
                return checkCFunc(__index.IsUserPlaced)
              end,
              IsVisible = function()
                return checkCFunc(__index.IsVisible)
              end,
              Lower = function()
                return checkCFunc(__index.Lower)
              end,
              Raise = function()
                return checkCFunc(__index.Raise)
              end,
              RegisterAllEvents = function()
                return checkCFunc(__index.RegisterAllEvents)
              end,
              RegisterEvent = function()
                return checkCFunc(__index.RegisterEvent)
              end,
              RegisterForDrag = function()
                return checkCFunc(__index.RegisterForDrag)
              end,
              RegisterUnitEvent = function()
                return checkCFunc(__index.RegisterUnitEvent)
              end,
              RotateTextures = function()
                return checkCFunc(__index.RotateTextures)
              end,
              SetAllPoints = function()
                return checkCFunc(__index.SetAllPoints)
              end,
              SetAlpha = function()
                return checkCFunc(__index.SetAlpha)
              end,
              SetAttribute = function()
                return checkCFunc(__index.SetAttribute)
              end,
              SetAttributeNoHandler = function()
                return checkCFunc(__index.SetAttributeNoHandler)
              end,
              SetClampRectInsets = function()
                return checkCFunc(__index.SetClampRectInsets)
              end,
              SetClampedToScreen = function()
                return checkCFunc(__index.SetClampedToScreen)
              end,
              SetClipsChildren = function()
                return checkCFunc(__index.SetClipsChildren)
              end,
              SetDepth = function()
                return checkCFunc(__index.SetDepth)
              end,
              SetDontSavePosition = function()
                return checkCFunc(__index.SetDontSavePosition)
              end,
              SetDrawLayerEnabled = function()
                return checkCFunc(__index.SetDrawLayerEnabled)
              end,
              SetFixedFrameLevel = function()
                return checkCFunc(__index.SetFixedFrameLevel)
              end,
              SetFixedFrameStrata = function()
                return checkCFunc(__index.SetFixedFrameStrata)
              end,
              SetFlattensRenderLayers = function()
                return checkCFunc(__index.SetFlattensRenderLayers)
              end,
              SetForbidden = function()
                return checkCFunc(__index.SetForbidden)
              end,
              SetFrameBuffer = function()
                return checkCFunc(__index.SetFrameBuffer)
              end,
              SetFrameLevel = function()
                return checkCFunc(__index.SetFrameLevel)
              end,
              SetFrameStrata = function()
                return checkCFunc(__index.SetFrameStrata)
              end,
              SetHeight = function()
                return checkCFunc(__index.SetHeight)
              end,
              SetHitRectInsets = function()
                return checkCFunc(__index.SetHitRectInsets)
              end,
              SetHyperlinksEnabled = function()
                return checkCFunc(__index.SetHyperlinksEnabled)
              end,
              SetID = function()
                return checkCFunc(__index.SetID)
              end,
              SetIgnoreParentAlpha = function()
                return checkCFunc(__index.SetIgnoreParentAlpha)
              end,
              SetIgnoreParentScale = function()
                return checkCFunc(__index.SetIgnoreParentScale)
              end,
              SetMaxResize = function()
                return checkCFunc(__index.SetMaxResize)
              end,
              SetMaxSnapshots = function()
                return checkCFunc(__index.SetMaxSnapshots)
              end,
              SetMinResize = function()
                return checkCFunc(__index.SetMinResize)
              end,
              SetMouseClickEnabled = function()
                return checkCFunc(__index.SetMouseClickEnabled)
              end,
              SetMouseMotionEnabled = function()
                return checkCFunc(__index.SetMouseMotionEnabled)
              end,
              SetMovable = function()
                return checkCFunc(__index.SetMovable)
              end,
              SetParent = function()
                return checkCFunc(__index.SetParent)
              end,
              SetPoint = function()
                return checkCFunc(__index.SetPoint)
              end,
              SetPropagateKeyboardInput = function()
                return checkCFunc(__index.SetPropagateKeyboardInput)
              end,
              SetResizable = function()
                return checkCFunc(__index.SetResizable)
              end,
              SetScale = function()
                return checkCFunc(__index.SetScale)
              end,
              SetScript = function()
                return checkCFunc(__index.SetScript)
              end,
              SetShown = function()
                return checkCFunc(__index.SetShown)
              end,
              SetSize = function()
                return checkCFunc(__index.SetSize)
              end,
              SetToplevel = function()
                return checkCFunc(__index.SetToplevel)
              end,
              SetUserPlaced = function()
                return checkCFunc(__index.SetUserPlaced)
              end,
              SetWidth = function()
                return checkCFunc(__index.SetWidth)
              end,
              Show = function()
                return checkCFunc(__index.Show)
              end,
              StartMoving = function()
                return checkCFunc(__index.StartMoving)
              end,
              StartSizing = function()
                return checkCFunc(__index.StartSizing)
              end,
              StopAnimating = function()
                return checkCFunc(__index.StopAnimating)
              end,
              StopMovingOrSizing = function()
                return checkCFunc(__index.StopMovingOrSizing)
              end,
              TakeSnapshot = function()
                return checkCFunc(__index.TakeSnapshot)
              end,
              UnregisterAllEvents = function()
                return checkCFunc(__index.UnregisterAllEvents)
              end,
              UnregisterEvent = function()
                return checkCFunc(__index.UnregisterEvent)
              end,
              UsesNPOT = function()
                return checkCFunc(__index.UsesNPOT)
              end,
            }
          end)
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
          local function factory()
            return assertCreateFrame('PlayerModel')
          end
          return mkTests('PlayerModel', factory, function(__index)
            return {
              AdjustPointsOffset = function()
                return checkCFunc(__index.AdjustPointsOffset)
              end,
              AdvanceTime = function()
                return checkCFunc(__index.AdvanceTime)
              end,
              ApplySpellVisualKit = function()
                return checkCFunc(__index.ApplySpellVisualKit)
              end,
              CanChangeAttribute = function()
                return checkCFunc(__index.CanChangeAttribute)
              end,
              CanChangeProtectedState = function()
                return checkCFunc(__index.CanChangeProtectedState)
              end,
              CanSetUnit = function()
                return checkCFunc(__index.CanSetUnit)
              end,
              ClearAllPoints = function()
                return checkCFunc(__index.ClearAllPoints)
              end,
              ClearFog = function()
                return checkCFunc(__index.ClearFog)
              end,
              ClearModel = function()
                return checkCFunc(__index.ClearModel)
              end,
              ClearPointByName = function()
                return checkCFunc(__index.ClearPointByName)
              end,
              ClearPointsOffset = function()
                return checkCFunc(__index.ClearPointsOffset)
              end,
              ClearTransform = function()
                return checkCFunc(__index.ClearTransform)
              end,
              CreateAnimationGroup = function()
                return checkCFunc(__index.CreateAnimationGroup)
              end,
              CreateFontString = function()
                return checkCFunc(__index.CreateFontString)
              end,
              CreateLine = function()
                return checkCFunc(__index.CreateLine)
              end,
              CreateMaskTexture = function()
                return checkCFunc(__index.CreateMaskTexture)
              end,
              CreateTexture = function()
                return checkCFunc(__index.CreateTexture)
              end,
              DesaturateHierarchy = function()
                return checkCFunc(__index.DesaturateHierarchy)
              end,
              DisableDrawLayer = function()
                return checkCFunc(__index.DisableDrawLayer)
              end,
              DoesClipChildren = function()
                return checkCFunc(__index.DoesClipChildren)
              end,
              EnableDrawLayer = function()
                return checkCFunc(__index.EnableDrawLayer)
              end,
              EnableGamePadButton = function()
                return checkCFunc(__index.EnableGamePadButton)
              end,
              EnableGamePadStick = function()
                return checkCFunc(__index.EnableGamePadStick)
              end,
              EnableKeyboard = function()
                return checkCFunc(__index.EnableKeyboard)
              end,
              EnableMouse = function()
                return checkCFunc(__index.EnableMouse)
              end,
              EnableMouseWheel = function()
                return checkCFunc(__index.EnableMouseWheel)
              end,
              ExecuteAttribute = function()
                return checkCFunc(__index.ExecuteAttribute)
              end,
              FreezeAnimation = function()
                return checkCFunc(__index.FreezeAnimation)
              end,
              GetAlpha = function()
                return checkCFunc(__index.GetAlpha)
              end,
              GetAnimationGroups = function()
                return checkCFunc(__index.GetAnimationGroups)
              end,
              GetAttribute = function()
                return checkCFunc(__index.GetAttribute)
              end,
              GetBottom = function()
                return checkCFunc(__index.GetBottom)
              end,
              GetBoundsRect = function()
                return checkCFunc(__index.GetBoundsRect)
              end,
              GetCameraDistance = function()
                return checkCFunc(__index.GetCameraDistance)
              end,
              GetCameraFacing = function()
                return checkCFunc(__index.GetCameraFacing)
              end,
              GetCameraPosition = function()
                return checkCFunc(__index.GetCameraPosition)
              end,
              GetCameraRoll = function()
                return checkCFunc(__index.GetCameraRoll)
              end,
              GetCameraTarget = function()
                return checkCFunc(__index.GetCameraTarget)
              end,
              GetCenter = function()
                return checkCFunc(__index.GetCenter)
              end,
              GetChildren = function()
                return checkCFunc(__index.GetChildren)
              end,
              GetClampRectInsets = function()
                return checkCFunc(__index.GetClampRectInsets)
              end,
              GetDebugName = function()
                return checkCFunc(__index.GetDebugName)
              end,
              GetDepth = function()
                return checkCFunc(__index.GetDepth)
              end,
              GetDesaturation = function()
                return checkCFunc(__index.GetDesaturation)
              end,
              GetDisplayInfo = function()
                return checkCFunc(__index.GetDisplayInfo)
              end,
              GetDoBlend = function()
                return checkCFunc(__index.GetDoBlend)
              end,
              GetDontSavePosition = function()
                return checkCFunc(__index.GetDontSavePosition)
              end,
              GetEffectiveAlpha = function()
                return checkCFunc(__index.GetEffectiveAlpha)
              end,
              GetEffectiveDepth = function()
                return checkCFunc(__index.GetEffectiveDepth)
              end,
              GetEffectiveScale = function()
                return checkCFunc(__index.GetEffectiveScale)
              end,
              GetEffectivelyFlattensRenderLayers = function()
                return checkCFunc(__index.GetEffectivelyFlattensRenderLayers)
              end,
              GetFacing = function()
                return checkCFunc(__index.GetFacing)
              end,
              GetFlattensRenderLayers = function()
                return checkCFunc(__index.GetFlattensRenderLayers)
              end,
              GetFogColor = function()
                return checkCFunc(__index.GetFogColor)
              end,
              GetFogFar = function()
                return checkCFunc(__index.GetFogFar)
              end,
              GetFogNear = function()
                return checkCFunc(__index.GetFogNear)
              end,
              GetFrameLevel = function()
                return checkCFunc(__index.GetFrameLevel)
              end,
              GetFrameStrata = function()
                return checkCFunc(__index.GetFrameStrata)
              end,
              GetHeight = function()
                return checkCFunc(__index.GetHeight)
              end,
              GetHitRectInsets = function()
                return checkCFunc(__index.GetHitRectInsets)
              end,
              GetHyperlinksEnabled = function()
                return checkCFunc(__index.GetHyperlinksEnabled)
              end,
              GetID = function()
                return checkCFunc(__index.GetID)
              end,
              GetKeepModelOnHide = function()
                return checkCFunc(__index.GetKeepModelOnHide)
              end,
              GetLeft = function()
                return checkCFunc(__index.GetLeft)
              end,
              GetLight = function()
                return checkCFunc(__index.GetLight)
              end,
              GetMaxResize = function()
                return checkCFunc(__index.GetMaxResize)
              end,
              GetMinResize = function()
                return checkCFunc(__index.GetMinResize)
              end,
              GetModelAlpha = function()
                return checkCFunc(__index.GetModelAlpha)
              end,
              GetModelDrawLayer = function()
                return checkCFunc(__index.GetModelDrawLayer)
              end,
              GetModelFileID = function()
                return checkCFunc(__index.GetModelFileID)
              end,
              GetModelScale = function()
                return checkCFunc(__index.GetModelScale)
              end,
              GetName = function()
                return checkCFunc(__index.GetName)
              end,
              GetNumChildren = function()
                return checkCFunc(__index.GetNumChildren)
              end,
              GetNumPoints = function()
                return checkCFunc(__index.GetNumPoints)
              end,
              GetNumRegions = function()
                return checkCFunc(__index.GetNumRegions)
              end,
              GetObjectType = function()
                return checkCFunc(__index.GetObjectType)
              end,
              GetParent = function()
                return checkCFunc(__index.GetParent)
              end,
              GetPaused = function()
                return checkCFunc(__index.GetPaused)
              end,
              GetPitch = function()
                return checkCFunc(__index.GetPitch)
              end,
              GetPoint = function()
                return checkCFunc(__index.GetPoint)
              end,
              GetPointByName = function()
                return checkCFunc(__index.GetPointByName)
              end,
              GetPosition = function()
                return checkCFunc(__index.GetPosition)
              end,
              GetPropagateKeyboardInput = function()
                return checkCFunc(__index.GetPropagateKeyboardInput)
              end,
              GetRect = function()
                return checkCFunc(__index.GetRect)
              end,
              GetRegions = function()
                return checkCFunc(__index.GetRegions)
              end,
              GetRight = function()
                return checkCFunc(__index.GetRight)
              end,
              GetRoll = function()
                return checkCFunc(__index.GetRoll)
              end,
              GetScale = function()
                return checkCFunc(__index.GetScale)
              end,
              GetScaledRect = function()
                return checkCFunc(__index.GetScaledRect)
              end,
              GetScript = function()
                return checkCFunc(__index.GetScript)
              end,
              GetShadowEffect = function()
                return checkCFunc(__index.GetShadowEffect)
              end,
              GetSize = function()
                return checkCFunc(__index.GetSize)
              end,
              GetSourceLocation = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetSourceLocation))
                  return
                end
                return checkCFunc(__index.GetSourceLocation)
              end,
              GetTop = function()
                return checkCFunc(__index.GetTop)
              end,
              GetViewInsets = function()
                return checkCFunc(__index.GetViewInsets)
              end,
              GetViewTranslation = function()
                return checkCFunc(__index.GetViewTranslation)
              end,
              GetWidth = function()
                return checkCFunc(__index.GetWidth)
              end,
              GetWorldScale = function()
                return checkCFunc(__index.GetWorldScale)
              end,
              HasAnimation = function()
                return checkCFunc(__index.HasAnimation)
              end,
              HasAttachmentPoints = function()
                return checkCFunc(__index.HasAttachmentPoints)
              end,
              HasCustomCamera = function()
                return checkCFunc(__index.HasCustomCamera)
              end,
              HasFixedFrameLevel = function()
                return checkCFunc(__index.HasFixedFrameLevel)
              end,
              HasFixedFrameStrata = function()
                return checkCFunc(__index.HasFixedFrameStrata)
              end,
              HasScript = function()
                return checkCFunc(__index.HasScript)
              end,
              Hide = function()
                return checkCFunc(__index.Hide)
              end,
              HookScript = function()
                return checkCFunc(__index.HookScript)
              end,
              IgnoreDepth = function()
                return checkCFunc(__index.IgnoreDepth)
              end,
              IsAnchoringRestricted = function()
                return checkCFunc(__index.IsAnchoringRestricted)
              end,
              IsClampedToScreen = function()
                return checkCFunc(__index.IsClampedToScreen)
              end,
              IsDragging = function()
                return checkCFunc(__index.IsDragging)
              end,
              IsEventRegistered = function()
                return checkCFunc(__index.IsEventRegistered)
              end,
              IsForbidden = function()
                return checkCFunc(__index.IsForbidden)
              end,
              IsGamePadButtonEnabled = function()
                return checkCFunc(__index.IsGamePadButtonEnabled)
              end,
              IsGamePadStickEnabled = function()
                return checkCFunc(__index.IsGamePadStickEnabled)
              end,
              IsIgnoringDepth = function()
                return checkCFunc(__index.IsIgnoringDepth)
              end,
              IsIgnoringParentAlpha = function()
                return checkCFunc(__index.IsIgnoringParentAlpha)
              end,
              IsIgnoringParentScale = function()
                return checkCFunc(__index.IsIgnoringParentScale)
              end,
              IsKeyboardEnabled = function()
                return checkCFunc(__index.IsKeyboardEnabled)
              end,
              IsMouseClickEnabled = function()
                return checkCFunc(__index.IsMouseClickEnabled)
              end,
              IsMouseEnabled = function()
                return checkCFunc(__index.IsMouseEnabled)
              end,
              IsMouseMotionEnabled = function()
                return checkCFunc(__index.IsMouseMotionEnabled)
              end,
              IsMouseOver = function()
                return checkCFunc(__index.IsMouseOver)
              end,
              IsMouseWheelEnabled = function()
                return checkCFunc(__index.IsMouseWheelEnabled)
              end,
              IsMovable = function()
                return checkCFunc(__index.IsMovable)
              end,
              IsObjectLoaded = function()
                return checkCFunc(__index.IsObjectLoaded)
              end,
              IsObjectType = function()
                return checkCFunc(__index.IsObjectType)
              end,
              IsProtected = function()
                return checkCFunc(__index.IsProtected)
              end,
              IsRectValid = function()
                return checkCFunc(__index.IsRectValid)
              end,
              IsResizable = function()
                return checkCFunc(__index.IsResizable)
              end,
              IsShown = function()
                return checkCFunc(__index.IsShown)
              end,
              IsToplevel = function()
                return checkCFunc(__index.IsToplevel)
              end,
              IsUserPlaced = function()
                return checkCFunc(__index.IsUserPlaced)
              end,
              IsUsingModelCenterToTransform = function()
                return checkCFunc(__index.IsUsingModelCenterToTransform)
              end,
              IsVisible = function()
                return checkCFunc(__index.IsVisible)
              end,
              Lower = function()
                return checkCFunc(__index.Lower)
              end,
              MakeCurrentCameraCustom = function()
                return checkCFunc(__index.MakeCurrentCameraCustom)
              end,
              PlayAnimKit = function()
                return checkCFunc(__index.PlayAnimKit)
              end,
              Raise = function()
                return checkCFunc(__index.Raise)
              end,
              RefreshCamera = function()
                return checkCFunc(__index.RefreshCamera)
              end,
              RefreshUnit = function()
                return checkCFunc(__index.RefreshUnit)
              end,
              RegisterAllEvents = function()
                return checkCFunc(__index.RegisterAllEvents)
              end,
              RegisterEvent = function()
                return checkCFunc(__index.RegisterEvent)
              end,
              RegisterForDrag = function()
                return checkCFunc(__index.RegisterForDrag)
              end,
              RegisterUnitEvent = function()
                return checkCFunc(__index.RegisterUnitEvent)
              end,
              ReplaceIconTexture = function()
                return checkCFunc(__index.ReplaceIconTexture)
              end,
              RotateTextures = function()
                return checkCFunc(__index.RotateTextures)
              end,
              SetAllPoints = function()
                return checkCFunc(__index.SetAllPoints)
              end,
              SetAlpha = function()
                return checkCFunc(__index.SetAlpha)
              end,
              SetAnimation = function()
                return checkCFunc(__index.SetAnimation)
              end,
              SetAttribute = function()
                return checkCFunc(__index.SetAttribute)
              end,
              SetAttributeNoHandler = function()
                return checkCFunc(__index.SetAttributeNoHandler)
              end,
              SetBarberShopAlternateForm = function()
                return checkCFunc(__index.SetBarberShopAlternateForm)
              end,
              SetCamDistanceScale = function()
                return checkCFunc(__index.SetCamDistanceScale)
              end,
              SetCamera = function()
                return checkCFunc(__index.SetCamera)
              end,
              SetCameraDistance = function()
                return checkCFunc(__index.SetCameraDistance)
              end,
              SetCameraFacing = function()
                return checkCFunc(__index.SetCameraFacing)
              end,
              SetCameraPosition = function()
                return checkCFunc(__index.SetCameraPosition)
              end,
              SetCameraRoll = function()
                return checkCFunc(__index.SetCameraRoll)
              end,
              SetCameraTarget = function()
                return checkCFunc(__index.SetCameraTarget)
              end,
              SetClampRectInsets = function()
                return checkCFunc(__index.SetClampRectInsets)
              end,
              SetClampedToScreen = function()
                return checkCFunc(__index.SetClampedToScreen)
              end,
              SetClipsChildren = function()
                return checkCFunc(__index.SetClipsChildren)
              end,
              SetCreature = function()
                return checkCFunc(__index.SetCreature)
              end,
              SetCustomCamera = function()
                return checkCFunc(__index.SetCustomCamera)
              end,
              SetCustomRace = function()
                return checkCFunc(__index.SetCustomRace)
              end,
              SetDepth = function()
                return checkCFunc(__index.SetDepth)
              end,
              SetDesaturation = function()
                return checkCFunc(__index.SetDesaturation)
              end,
              SetDisplayInfo = function()
                return checkCFunc(__index.SetDisplayInfo)
              end,
              SetDoBlend = function()
                return checkCFunc(__index.SetDoBlend)
              end,
              SetDontSavePosition = function()
                return checkCFunc(__index.SetDontSavePosition)
              end,
              SetDrawLayerEnabled = function()
                return checkCFunc(__index.SetDrawLayerEnabled)
              end,
              SetFacing = function()
                return checkCFunc(__index.SetFacing)
              end,
              SetFixedFrameLevel = function()
                return checkCFunc(__index.SetFixedFrameLevel)
              end,
              SetFixedFrameStrata = function()
                return checkCFunc(__index.SetFixedFrameStrata)
              end,
              SetFlattensRenderLayers = function()
                return checkCFunc(__index.SetFlattensRenderLayers)
              end,
              SetFogColor = function()
                return checkCFunc(__index.SetFogColor)
              end,
              SetFogFar = function()
                return checkCFunc(__index.SetFogFar)
              end,
              SetFogNear = function()
                return checkCFunc(__index.SetFogNear)
              end,
              SetForbidden = function()
                return checkCFunc(__index.SetForbidden)
              end,
              SetFrameBuffer = function()
                return checkCFunc(__index.SetFrameBuffer)
              end,
              SetFrameLevel = function()
                return checkCFunc(__index.SetFrameLevel)
              end,
              SetFrameStrata = function()
                return checkCFunc(__index.SetFrameStrata)
              end,
              SetGlow = function()
                return checkCFunc(__index.SetGlow)
              end,
              SetHeight = function()
                return checkCFunc(__index.SetHeight)
              end,
              SetHitRectInsets = function()
                return checkCFunc(__index.SetHitRectInsets)
              end,
              SetHyperlinksEnabled = function()
                return checkCFunc(__index.SetHyperlinksEnabled)
              end,
              SetID = function()
                return checkCFunc(__index.SetID)
              end,
              SetIgnoreParentAlpha = function()
                return checkCFunc(__index.SetIgnoreParentAlpha)
              end,
              SetIgnoreParentScale = function()
                return checkCFunc(__index.SetIgnoreParentScale)
              end,
              SetItem = function()
                return checkCFunc(__index.SetItem)
              end,
              SetItemAppearance = function()
                return checkCFunc(__index.SetItemAppearance)
              end,
              SetKeepModelOnHide = function()
                return checkCFunc(__index.SetKeepModelOnHide)
              end,
              SetLight = function()
                return checkCFunc(__index.SetLight)
              end,
              SetMaxResize = function()
                return checkCFunc(__index.SetMaxResize)
              end,
              SetMinResize = function()
                return checkCFunc(__index.SetMinResize)
              end,
              SetModel = function()
                return checkCFunc(__index.SetModel)
              end,
              SetModelAlpha = function()
                return checkCFunc(__index.SetModelAlpha)
              end,
              SetModelDrawLayer = function()
                return checkCFunc(__index.SetModelDrawLayer)
              end,
              SetModelScale = function()
                return checkCFunc(__index.SetModelScale)
              end,
              SetMouseClickEnabled = function()
                return checkCFunc(__index.SetMouseClickEnabled)
              end,
              SetMouseMotionEnabled = function()
                return checkCFunc(__index.SetMouseMotionEnabled)
              end,
              SetMovable = function()
                return checkCFunc(__index.SetMovable)
              end,
              SetParent = function()
                return checkCFunc(__index.SetParent)
              end,
              SetParticlesEnabled = function()
                return checkCFunc(__index.SetParticlesEnabled)
              end,
              SetPaused = function()
                return checkCFunc(__index.SetPaused)
              end,
              SetPitch = function()
                return checkCFunc(__index.SetPitch)
              end,
              SetPoint = function()
                return checkCFunc(__index.SetPoint)
              end,
              SetPortraitZoom = function()
                return checkCFunc(__index.SetPortraitZoom)
              end,
              SetPosition = function()
                return checkCFunc(__index.SetPosition)
              end,
              SetPropagateKeyboardInput = function()
                return checkCFunc(__index.SetPropagateKeyboardInput)
              end,
              SetResizable = function()
                return checkCFunc(__index.SetResizable)
              end,
              SetRoll = function()
                return checkCFunc(__index.SetRoll)
              end,
              SetRotation = function()
                return checkCFunc(__index.SetRotation)
              end,
              SetScale = function()
                return checkCFunc(__index.SetScale)
              end,
              SetScript = function()
                return checkCFunc(__index.SetScript)
              end,
              SetSequence = function()
                return checkCFunc(__index.SetSequence)
              end,
              SetSequenceTime = function()
                return checkCFunc(__index.SetSequenceTime)
              end,
              SetShadowEffect = function()
                return checkCFunc(__index.SetShadowEffect)
              end,
              SetShown = function()
                return checkCFunc(__index.SetShown)
              end,
              SetSize = function()
                return checkCFunc(__index.SetSize)
              end,
              SetToplevel = function()
                return checkCFunc(__index.SetToplevel)
              end,
              SetTransform = function()
                return checkCFunc(__index.SetTransform)
              end,
              SetUnit = function()
                return checkCFunc(__index.SetUnit)
              end,
              SetUserPlaced = function()
                return checkCFunc(__index.SetUserPlaced)
              end,
              SetViewInsets = function()
                return checkCFunc(__index.SetViewInsets)
              end,
              SetViewTranslation = function()
                return checkCFunc(__index.SetViewTranslation)
              end,
              SetWidth = function()
                return checkCFunc(__index.SetWidth)
              end,
              Show = function()
                return checkCFunc(__index.Show)
              end,
              StartMoving = function()
                return checkCFunc(__index.StartMoving)
              end,
              StartSizing = function()
                return checkCFunc(__index.StartSizing)
              end,
              StopAnimKit = function()
                return checkCFunc(__index.StopAnimKit)
              end,
              StopAnimating = function()
                return checkCFunc(__index.StopAnimating)
              end,
              StopMovingOrSizing = function()
                return checkCFunc(__index.StopMovingOrSizing)
              end,
              TransformCameraSpaceToModelSpace = function()
                return checkCFunc(__index.TransformCameraSpaceToModelSpace)
              end,
              UnregisterAllEvents = function()
                return checkCFunc(__index.UnregisterAllEvents)
              end,
              UnregisterEvent = function()
                return checkCFunc(__index.UnregisterEvent)
              end,
              UseModelCenterToTransform = function()
                return checkCFunc(__index.UseModelCenterToTransform)
              end,
              ZeroCachedCenterXY = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.ZeroCachedCenterXY))
                  return
                end
                return checkCFunc(__index.ZeroCachedCenterXY)
              end,
            }
          end)
        end,
        QuestPOIFrame = function()
          if badProduct('wow,wow_beta,wowt') then
            assertCreateFrameFails('QuestPOIFrame')
            return
          end
          local function factory()
            return assertCreateFrame('QuestPOIFrame')
          end
          return mkTests('QuestPOIFrame', factory, function(__index)
            return {
              AdjustPointsOffset = function()
                return checkCFunc(__index.AdjustPointsOffset)
              end,
              CanChangeAttribute = function()
                return checkCFunc(__index.CanChangeAttribute)
              end,
              CanChangeProtectedState = function()
                return checkCFunc(__index.CanChangeProtectedState)
              end,
              ClearAllPoints = function()
                return checkCFunc(__index.ClearAllPoints)
              end,
              ClearPointByName = function()
                return checkCFunc(__index.ClearPointByName)
              end,
              ClearPointsOffset = function()
                return checkCFunc(__index.ClearPointsOffset)
              end,
              CreateAnimationGroup = function()
                return checkCFunc(__index.CreateAnimationGroup)
              end,
              CreateFontString = function()
                return checkCFunc(__index.CreateFontString)
              end,
              CreateLine = function()
                return checkCFunc(__index.CreateLine)
              end,
              CreateMaskTexture = function()
                return checkCFunc(__index.CreateMaskTexture)
              end,
              CreateTexture = function()
                return checkCFunc(__index.CreateTexture)
              end,
              DesaturateHierarchy = function()
                return checkCFunc(__index.DesaturateHierarchy)
              end,
              DisableDrawLayer = function()
                return checkCFunc(__index.DisableDrawLayer)
              end,
              DoesClipChildren = function()
                return checkCFunc(__index.DoesClipChildren)
              end,
              DrawAll = function()
                return checkCFunc(__index.DrawAll)
              end,
              DrawBlob = function()
                return checkCFunc(__index.DrawBlob)
              end,
              DrawNone = function()
                return checkCFunc(__index.DrawNone)
              end,
              EnableDrawLayer = function()
                return checkCFunc(__index.EnableDrawLayer)
              end,
              EnableGamePadButton = function()
                return checkCFunc(__index.EnableGamePadButton)
              end,
              EnableGamePadStick = function()
                return checkCFunc(__index.EnableGamePadStick)
              end,
              EnableKeyboard = function()
                return checkCFunc(__index.EnableKeyboard)
              end,
              EnableMerging = function()
                return checkCFunc(__index.EnableMerging)
              end,
              EnableMouse = function()
                return checkCFunc(__index.EnableMouse)
              end,
              EnableMouseWheel = function()
                return checkCFunc(__index.EnableMouseWheel)
              end,
              EnableSmoothing = function()
                return checkCFunc(__index.EnableSmoothing)
              end,
              ExecuteAttribute = function()
                return checkCFunc(__index.ExecuteAttribute)
              end,
              GetAlpha = function()
                return checkCFunc(__index.GetAlpha)
              end,
              GetAnimationGroups = function()
                return checkCFunc(__index.GetAnimationGroups)
              end,
              GetAttribute = function()
                return checkCFunc(__index.GetAttribute)
              end,
              GetBottom = function()
                return checkCFunc(__index.GetBottom)
              end,
              GetBoundsRect = function()
                return checkCFunc(__index.GetBoundsRect)
              end,
              GetCenter = function()
                return checkCFunc(__index.GetCenter)
              end,
              GetChildren = function()
                return checkCFunc(__index.GetChildren)
              end,
              GetClampRectInsets = function()
                return checkCFunc(__index.GetClampRectInsets)
              end,
              GetDebugName = function()
                return checkCFunc(__index.GetDebugName)
              end,
              GetDepth = function()
                return checkCFunc(__index.GetDepth)
              end,
              GetDontSavePosition = function()
                return checkCFunc(__index.GetDontSavePosition)
              end,
              GetEffectiveAlpha = function()
                return checkCFunc(__index.GetEffectiveAlpha)
              end,
              GetEffectiveDepth = function()
                return checkCFunc(__index.GetEffectiveDepth)
              end,
              GetEffectiveScale = function()
                return checkCFunc(__index.GetEffectiveScale)
              end,
              GetEffectivelyFlattensRenderLayers = function()
                return checkCFunc(__index.GetEffectivelyFlattensRenderLayers)
              end,
              GetFlattensRenderLayers = function()
                return checkCFunc(__index.GetFlattensRenderLayers)
              end,
              GetFrameLevel = function()
                return checkCFunc(__index.GetFrameLevel)
              end,
              GetFrameStrata = function()
                return checkCFunc(__index.GetFrameStrata)
              end,
              GetHeight = function()
                return checkCFunc(__index.GetHeight)
              end,
              GetHitRectInsets = function()
                return checkCFunc(__index.GetHitRectInsets)
              end,
              GetHyperlinksEnabled = function()
                return checkCFunc(__index.GetHyperlinksEnabled)
              end,
              GetID = function()
                return checkCFunc(__index.GetID)
              end,
              GetLeft = function()
                return checkCFunc(__index.GetLeft)
              end,
              GetMapID = function()
                return checkCFunc(__index.GetMapID)
              end,
              GetMaxResize = function()
                return checkCFunc(__index.GetMaxResize)
              end,
              GetMinResize = function()
                return checkCFunc(__index.GetMinResize)
              end,
              GetName = function()
                return checkCFunc(__index.GetName)
              end,
              GetNumChildren = function()
                return checkCFunc(__index.GetNumChildren)
              end,
              GetNumPoints = function()
                return checkCFunc(__index.GetNumPoints)
              end,
              GetNumRegions = function()
                return checkCFunc(__index.GetNumRegions)
              end,
              GetNumTooltips = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetNumTooltips))
                  return
                end
                return checkCFunc(__index.GetNumTooltips)
              end,
              GetObjectType = function()
                return checkCFunc(__index.GetObjectType)
              end,
              GetParent = function()
                return checkCFunc(__index.GetParent)
              end,
              GetPoint = function()
                return checkCFunc(__index.GetPoint)
              end,
              GetPointByName = function()
                return checkCFunc(__index.GetPointByName)
              end,
              GetPropagateKeyboardInput = function()
                return checkCFunc(__index.GetPropagateKeyboardInput)
              end,
              GetRect = function()
                return checkCFunc(__index.GetRect)
              end,
              GetRegions = function()
                return checkCFunc(__index.GetRegions)
              end,
              GetRight = function()
                return checkCFunc(__index.GetRight)
              end,
              GetScale = function()
                return checkCFunc(__index.GetScale)
              end,
              GetScaledRect = function()
                return checkCFunc(__index.GetScaledRect)
              end,
              GetScript = function()
                return checkCFunc(__index.GetScript)
              end,
              GetSize = function()
                return checkCFunc(__index.GetSize)
              end,
              GetSourceLocation = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetSourceLocation))
                  return
                end
                return checkCFunc(__index.GetSourceLocation)
              end,
              GetTooltipIndex = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetTooltipIndex))
                  return
                end
                return checkCFunc(__index.GetTooltipIndex)
              end,
              GetTop = function()
                return checkCFunc(__index.GetTop)
              end,
              GetWidth = function()
                return checkCFunc(__index.GetWidth)
              end,
              HasFixedFrameLevel = function()
                return checkCFunc(__index.HasFixedFrameLevel)
              end,
              HasFixedFrameStrata = function()
                return checkCFunc(__index.HasFixedFrameStrata)
              end,
              HasScript = function()
                return checkCFunc(__index.HasScript)
              end,
              Hide = function()
                return checkCFunc(__index.Hide)
              end,
              HookScript = function()
                return checkCFunc(__index.HookScript)
              end,
              IgnoreDepth = function()
                return checkCFunc(__index.IgnoreDepth)
              end,
              IsAnchoringRestricted = function()
                return checkCFunc(__index.IsAnchoringRestricted)
              end,
              IsClampedToScreen = function()
                return checkCFunc(__index.IsClampedToScreen)
              end,
              IsDragging = function()
                return checkCFunc(__index.IsDragging)
              end,
              IsEventRegistered = function()
                return checkCFunc(__index.IsEventRegistered)
              end,
              IsForbidden = function()
                return checkCFunc(__index.IsForbidden)
              end,
              IsGamePadButtonEnabled = function()
                return checkCFunc(__index.IsGamePadButtonEnabled)
              end,
              IsGamePadStickEnabled = function()
                return checkCFunc(__index.IsGamePadStickEnabled)
              end,
              IsIgnoringDepth = function()
                return checkCFunc(__index.IsIgnoringDepth)
              end,
              IsIgnoringParentAlpha = function()
                return checkCFunc(__index.IsIgnoringParentAlpha)
              end,
              IsIgnoringParentScale = function()
                return checkCFunc(__index.IsIgnoringParentScale)
              end,
              IsKeyboardEnabled = function()
                return checkCFunc(__index.IsKeyboardEnabled)
              end,
              IsMouseClickEnabled = function()
                return checkCFunc(__index.IsMouseClickEnabled)
              end,
              IsMouseEnabled = function()
                return checkCFunc(__index.IsMouseEnabled)
              end,
              IsMouseMotionEnabled = function()
                return checkCFunc(__index.IsMouseMotionEnabled)
              end,
              IsMouseOver = function()
                return checkCFunc(__index.IsMouseOver)
              end,
              IsMouseWheelEnabled = function()
                return checkCFunc(__index.IsMouseWheelEnabled)
              end,
              IsMovable = function()
                return checkCFunc(__index.IsMovable)
              end,
              IsObjectLoaded = function()
                return checkCFunc(__index.IsObjectLoaded)
              end,
              IsObjectType = function()
                return checkCFunc(__index.IsObjectType)
              end,
              IsProtected = function()
                return checkCFunc(__index.IsProtected)
              end,
              IsRectValid = function()
                return checkCFunc(__index.IsRectValid)
              end,
              IsResizable = function()
                return checkCFunc(__index.IsResizable)
              end,
              IsShown = function()
                return checkCFunc(__index.IsShown)
              end,
              IsToplevel = function()
                return checkCFunc(__index.IsToplevel)
              end,
              IsUserPlaced = function()
                return checkCFunc(__index.IsUserPlaced)
              end,
              IsVisible = function()
                return checkCFunc(__index.IsVisible)
              end,
              Lower = function()
                return checkCFunc(__index.Lower)
              end,
              Raise = function()
                return checkCFunc(__index.Raise)
              end,
              RegisterAllEvents = function()
                return checkCFunc(__index.RegisterAllEvents)
              end,
              RegisterEvent = function()
                return checkCFunc(__index.RegisterEvent)
              end,
              RegisterForDrag = function()
                return checkCFunc(__index.RegisterForDrag)
              end,
              RegisterUnitEvent = function()
                return checkCFunc(__index.RegisterUnitEvent)
              end,
              RotateTextures = function()
                return checkCFunc(__index.RotateTextures)
              end,
              SetAllPoints = function()
                return checkCFunc(__index.SetAllPoints)
              end,
              SetAlpha = function()
                return checkCFunc(__index.SetAlpha)
              end,
              SetAttribute = function()
                return checkCFunc(__index.SetAttribute)
              end,
              SetAttributeNoHandler = function()
                return checkCFunc(__index.SetAttributeNoHandler)
              end,
              SetBorderAlpha = function()
                return checkCFunc(__index.SetBorderAlpha)
              end,
              SetBorderScalar = function()
                return checkCFunc(__index.SetBorderScalar)
              end,
              SetBorderTexture = function()
                return checkCFunc(__index.SetBorderTexture)
              end,
              SetClampRectInsets = function()
                return checkCFunc(__index.SetClampRectInsets)
              end,
              SetClampedToScreen = function()
                return checkCFunc(__index.SetClampedToScreen)
              end,
              SetClipsChildren = function()
                return checkCFunc(__index.SetClipsChildren)
              end,
              SetDepth = function()
                return checkCFunc(__index.SetDepth)
              end,
              SetDontSavePosition = function()
                return checkCFunc(__index.SetDontSavePosition)
              end,
              SetDrawLayerEnabled = function()
                return checkCFunc(__index.SetDrawLayerEnabled)
              end,
              SetFillAlpha = function()
                return checkCFunc(__index.SetFillAlpha)
              end,
              SetFillTexture = function()
                return checkCFunc(__index.SetFillTexture)
              end,
              SetFixedFrameLevel = function()
                return checkCFunc(__index.SetFixedFrameLevel)
              end,
              SetFixedFrameStrata = function()
                return checkCFunc(__index.SetFixedFrameStrata)
              end,
              SetFlattensRenderLayers = function()
                return checkCFunc(__index.SetFlattensRenderLayers)
              end,
              SetForbidden = function()
                return checkCFunc(__index.SetForbidden)
              end,
              SetFrameBuffer = function()
                return checkCFunc(__index.SetFrameBuffer)
              end,
              SetFrameLevel = function()
                return checkCFunc(__index.SetFrameLevel)
              end,
              SetFrameStrata = function()
                return checkCFunc(__index.SetFrameStrata)
              end,
              SetHeight = function()
                return checkCFunc(__index.SetHeight)
              end,
              SetHitRectInsets = function()
                return checkCFunc(__index.SetHitRectInsets)
              end,
              SetHyperlinksEnabled = function()
                return checkCFunc(__index.SetHyperlinksEnabled)
              end,
              SetID = function()
                return checkCFunc(__index.SetID)
              end,
              SetIgnoreParentAlpha = function()
                return checkCFunc(__index.SetIgnoreParentAlpha)
              end,
              SetIgnoreParentScale = function()
                return checkCFunc(__index.SetIgnoreParentScale)
              end,
              SetMapID = function()
                return checkCFunc(__index.SetMapID)
              end,
              SetMaxResize = function()
                return checkCFunc(__index.SetMaxResize)
              end,
              SetMergeThreshold = function()
                return checkCFunc(__index.SetMergeThreshold)
              end,
              SetMinResize = function()
                return checkCFunc(__index.SetMinResize)
              end,
              SetMouseClickEnabled = function()
                return checkCFunc(__index.SetMouseClickEnabled)
              end,
              SetMouseMotionEnabled = function()
                return checkCFunc(__index.SetMouseMotionEnabled)
              end,
              SetMovable = function()
                return checkCFunc(__index.SetMovable)
              end,
              SetNumSplinePoints = function()
                return checkCFunc(__index.SetNumSplinePoints)
              end,
              SetParent = function()
                return checkCFunc(__index.SetParent)
              end,
              SetPoint = function()
                return checkCFunc(__index.SetPoint)
              end,
              SetPropagateKeyboardInput = function()
                return checkCFunc(__index.SetPropagateKeyboardInput)
              end,
              SetResizable = function()
                return checkCFunc(__index.SetResizable)
              end,
              SetScale = function()
                return checkCFunc(__index.SetScale)
              end,
              SetScript = function()
                return checkCFunc(__index.SetScript)
              end,
              SetShown = function()
                return checkCFunc(__index.SetShown)
              end,
              SetSize = function()
                return checkCFunc(__index.SetSize)
              end,
              SetToplevel = function()
                return checkCFunc(__index.SetToplevel)
              end,
              SetUserPlaced = function()
                return checkCFunc(__index.SetUserPlaced)
              end,
              SetWidth = function()
                return checkCFunc(__index.SetWidth)
              end,
              Show = function()
                return checkCFunc(__index.Show)
              end,
              StartMoving = function()
                return checkCFunc(__index.StartMoving)
              end,
              StartSizing = function()
                return checkCFunc(__index.StartSizing)
              end,
              StopAnimating = function()
                return checkCFunc(__index.StopAnimating)
              end,
              StopMovingOrSizing = function()
                return checkCFunc(__index.StopMovingOrSizing)
              end,
              UnregisterAllEvents = function()
                return checkCFunc(__index.UnregisterAllEvents)
              end,
              UnregisterEvent = function()
                return checkCFunc(__index.UnregisterEvent)
              end,
              UpdateMouseOverTooltip = function()
                return checkCFunc(__index.UpdateMouseOverTooltip)
              end,
            }
          end)
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
          if badProduct('wow,wow_beta,wowt') then
            assertCreateFrameFails('ScenarioPOIFrame')
            return
          end
          local function factory()
            return assertCreateFrame('ScenarioPOIFrame')
          end
          return mkTests('ScenarioPOIFrame', factory, function(__index)
            return {
              AdjustPointsOffset = function()
                return checkCFunc(__index.AdjustPointsOffset)
              end,
              CanChangeAttribute = function()
                return checkCFunc(__index.CanChangeAttribute)
              end,
              CanChangeProtectedState = function()
                return checkCFunc(__index.CanChangeProtectedState)
              end,
              ClearAllPoints = function()
                return checkCFunc(__index.ClearAllPoints)
              end,
              ClearPointByName = function()
                return checkCFunc(__index.ClearPointByName)
              end,
              ClearPointsOffset = function()
                return checkCFunc(__index.ClearPointsOffset)
              end,
              CreateAnimationGroup = function()
                return checkCFunc(__index.CreateAnimationGroup)
              end,
              CreateFontString = function()
                return checkCFunc(__index.CreateFontString)
              end,
              CreateLine = function()
                return checkCFunc(__index.CreateLine)
              end,
              CreateMaskTexture = function()
                return checkCFunc(__index.CreateMaskTexture)
              end,
              CreateTexture = function()
                return checkCFunc(__index.CreateTexture)
              end,
              DesaturateHierarchy = function()
                return checkCFunc(__index.DesaturateHierarchy)
              end,
              DisableDrawLayer = function()
                return checkCFunc(__index.DisableDrawLayer)
              end,
              DoesClipChildren = function()
                return checkCFunc(__index.DoesClipChildren)
              end,
              DrawAll = function()
                return checkCFunc(__index.DrawAll)
              end,
              DrawBlob = function()
                return checkCFunc(__index.DrawBlob)
              end,
              DrawNone = function()
                return checkCFunc(__index.DrawNone)
              end,
              EnableDrawLayer = function()
                return checkCFunc(__index.EnableDrawLayer)
              end,
              EnableGamePadButton = function()
                return checkCFunc(__index.EnableGamePadButton)
              end,
              EnableGamePadStick = function()
                return checkCFunc(__index.EnableGamePadStick)
              end,
              EnableKeyboard = function()
                return checkCFunc(__index.EnableKeyboard)
              end,
              EnableMerging = function()
                return checkCFunc(__index.EnableMerging)
              end,
              EnableMouse = function()
                return checkCFunc(__index.EnableMouse)
              end,
              EnableMouseWheel = function()
                return checkCFunc(__index.EnableMouseWheel)
              end,
              EnableSmoothing = function()
                return checkCFunc(__index.EnableSmoothing)
              end,
              ExecuteAttribute = function()
                return checkCFunc(__index.ExecuteAttribute)
              end,
              GetAlpha = function()
                return checkCFunc(__index.GetAlpha)
              end,
              GetAnimationGroups = function()
                return checkCFunc(__index.GetAnimationGroups)
              end,
              GetAttribute = function()
                return checkCFunc(__index.GetAttribute)
              end,
              GetBottom = function()
                return checkCFunc(__index.GetBottom)
              end,
              GetBoundsRect = function()
                return checkCFunc(__index.GetBoundsRect)
              end,
              GetCenter = function()
                return checkCFunc(__index.GetCenter)
              end,
              GetChildren = function()
                return checkCFunc(__index.GetChildren)
              end,
              GetClampRectInsets = function()
                return checkCFunc(__index.GetClampRectInsets)
              end,
              GetDebugName = function()
                return checkCFunc(__index.GetDebugName)
              end,
              GetDepth = function()
                return checkCFunc(__index.GetDepth)
              end,
              GetDontSavePosition = function()
                return checkCFunc(__index.GetDontSavePosition)
              end,
              GetEffectiveAlpha = function()
                return checkCFunc(__index.GetEffectiveAlpha)
              end,
              GetEffectiveDepth = function()
                return checkCFunc(__index.GetEffectiveDepth)
              end,
              GetEffectiveScale = function()
                return checkCFunc(__index.GetEffectiveScale)
              end,
              GetEffectivelyFlattensRenderLayers = function()
                return checkCFunc(__index.GetEffectivelyFlattensRenderLayers)
              end,
              GetFlattensRenderLayers = function()
                return checkCFunc(__index.GetFlattensRenderLayers)
              end,
              GetFrameLevel = function()
                return checkCFunc(__index.GetFrameLevel)
              end,
              GetFrameStrata = function()
                return checkCFunc(__index.GetFrameStrata)
              end,
              GetHeight = function()
                return checkCFunc(__index.GetHeight)
              end,
              GetHitRectInsets = function()
                return checkCFunc(__index.GetHitRectInsets)
              end,
              GetHyperlinksEnabled = function()
                return checkCFunc(__index.GetHyperlinksEnabled)
              end,
              GetID = function()
                return checkCFunc(__index.GetID)
              end,
              GetLeft = function()
                return checkCFunc(__index.GetLeft)
              end,
              GetMapID = function()
                return checkCFunc(__index.GetMapID)
              end,
              GetMaxResize = function()
                return checkCFunc(__index.GetMaxResize)
              end,
              GetMinResize = function()
                return checkCFunc(__index.GetMinResize)
              end,
              GetName = function()
                return checkCFunc(__index.GetName)
              end,
              GetNumChildren = function()
                return checkCFunc(__index.GetNumChildren)
              end,
              GetNumPoints = function()
                return checkCFunc(__index.GetNumPoints)
              end,
              GetNumRegions = function()
                return checkCFunc(__index.GetNumRegions)
              end,
              GetObjectType = function()
                return checkCFunc(__index.GetObjectType)
              end,
              GetParent = function()
                return checkCFunc(__index.GetParent)
              end,
              GetPoint = function()
                return checkCFunc(__index.GetPoint)
              end,
              GetPointByName = function()
                return checkCFunc(__index.GetPointByName)
              end,
              GetPropagateKeyboardInput = function()
                return checkCFunc(__index.GetPropagateKeyboardInput)
              end,
              GetRect = function()
                return checkCFunc(__index.GetRect)
              end,
              GetRegions = function()
                return checkCFunc(__index.GetRegions)
              end,
              GetRight = function()
                return checkCFunc(__index.GetRight)
              end,
              GetScale = function()
                return checkCFunc(__index.GetScale)
              end,
              GetScaledRect = function()
                return checkCFunc(__index.GetScaledRect)
              end,
              GetScenarioTooltipText = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetScenarioTooltipText))
                  return
                end
                return checkCFunc(__index.GetScenarioTooltipText)
              end,
              GetScript = function()
                return checkCFunc(__index.GetScript)
              end,
              GetSize = function()
                return checkCFunc(__index.GetSize)
              end,
              GetSourceLocation = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetSourceLocation))
                  return
                end
                return checkCFunc(__index.GetSourceLocation)
              end,
              GetTop = function()
                return checkCFunc(__index.GetTop)
              end,
              GetWidth = function()
                return checkCFunc(__index.GetWidth)
              end,
              HasFixedFrameLevel = function()
                return checkCFunc(__index.HasFixedFrameLevel)
              end,
              HasFixedFrameStrata = function()
                return checkCFunc(__index.HasFixedFrameStrata)
              end,
              HasScript = function()
                return checkCFunc(__index.HasScript)
              end,
              Hide = function()
                return checkCFunc(__index.Hide)
              end,
              HookScript = function()
                return checkCFunc(__index.HookScript)
              end,
              IgnoreDepth = function()
                return checkCFunc(__index.IgnoreDepth)
              end,
              IsAnchoringRestricted = function()
                return checkCFunc(__index.IsAnchoringRestricted)
              end,
              IsClampedToScreen = function()
                return checkCFunc(__index.IsClampedToScreen)
              end,
              IsDragging = function()
                return checkCFunc(__index.IsDragging)
              end,
              IsEventRegistered = function()
                return checkCFunc(__index.IsEventRegistered)
              end,
              IsForbidden = function()
                return checkCFunc(__index.IsForbidden)
              end,
              IsGamePadButtonEnabled = function()
                return checkCFunc(__index.IsGamePadButtonEnabled)
              end,
              IsGamePadStickEnabled = function()
                return checkCFunc(__index.IsGamePadStickEnabled)
              end,
              IsIgnoringDepth = function()
                return checkCFunc(__index.IsIgnoringDepth)
              end,
              IsIgnoringParentAlpha = function()
                return checkCFunc(__index.IsIgnoringParentAlpha)
              end,
              IsIgnoringParentScale = function()
                return checkCFunc(__index.IsIgnoringParentScale)
              end,
              IsKeyboardEnabled = function()
                return checkCFunc(__index.IsKeyboardEnabled)
              end,
              IsMouseClickEnabled = function()
                return checkCFunc(__index.IsMouseClickEnabled)
              end,
              IsMouseEnabled = function()
                return checkCFunc(__index.IsMouseEnabled)
              end,
              IsMouseMotionEnabled = function()
                return checkCFunc(__index.IsMouseMotionEnabled)
              end,
              IsMouseOver = function()
                return checkCFunc(__index.IsMouseOver)
              end,
              IsMouseWheelEnabled = function()
                return checkCFunc(__index.IsMouseWheelEnabled)
              end,
              IsMovable = function()
                return checkCFunc(__index.IsMovable)
              end,
              IsObjectLoaded = function()
                return checkCFunc(__index.IsObjectLoaded)
              end,
              IsObjectType = function()
                return checkCFunc(__index.IsObjectType)
              end,
              IsProtected = function()
                return checkCFunc(__index.IsProtected)
              end,
              IsRectValid = function()
                return checkCFunc(__index.IsRectValid)
              end,
              IsResizable = function()
                return checkCFunc(__index.IsResizable)
              end,
              IsShown = function()
                return checkCFunc(__index.IsShown)
              end,
              IsToplevel = function()
                return checkCFunc(__index.IsToplevel)
              end,
              IsUserPlaced = function()
                return checkCFunc(__index.IsUserPlaced)
              end,
              IsVisible = function()
                return checkCFunc(__index.IsVisible)
              end,
              Lower = function()
                return checkCFunc(__index.Lower)
              end,
              Raise = function()
                return checkCFunc(__index.Raise)
              end,
              RegisterAllEvents = function()
                return checkCFunc(__index.RegisterAllEvents)
              end,
              RegisterEvent = function()
                return checkCFunc(__index.RegisterEvent)
              end,
              RegisterForDrag = function()
                return checkCFunc(__index.RegisterForDrag)
              end,
              RegisterUnitEvent = function()
                return checkCFunc(__index.RegisterUnitEvent)
              end,
              RotateTextures = function()
                return checkCFunc(__index.RotateTextures)
              end,
              SetAllPoints = function()
                return checkCFunc(__index.SetAllPoints)
              end,
              SetAlpha = function()
                return checkCFunc(__index.SetAlpha)
              end,
              SetAttribute = function()
                return checkCFunc(__index.SetAttribute)
              end,
              SetAttributeNoHandler = function()
                return checkCFunc(__index.SetAttributeNoHandler)
              end,
              SetBorderAlpha = function()
                return checkCFunc(__index.SetBorderAlpha)
              end,
              SetBorderScalar = function()
                return checkCFunc(__index.SetBorderScalar)
              end,
              SetBorderTexture = function()
                return checkCFunc(__index.SetBorderTexture)
              end,
              SetClampRectInsets = function()
                return checkCFunc(__index.SetClampRectInsets)
              end,
              SetClampedToScreen = function()
                return checkCFunc(__index.SetClampedToScreen)
              end,
              SetClipsChildren = function()
                return checkCFunc(__index.SetClipsChildren)
              end,
              SetDepth = function()
                return checkCFunc(__index.SetDepth)
              end,
              SetDontSavePosition = function()
                return checkCFunc(__index.SetDontSavePosition)
              end,
              SetDrawLayerEnabled = function()
                return checkCFunc(__index.SetDrawLayerEnabled)
              end,
              SetFillAlpha = function()
                return checkCFunc(__index.SetFillAlpha)
              end,
              SetFillTexture = function()
                return checkCFunc(__index.SetFillTexture)
              end,
              SetFixedFrameLevel = function()
                return checkCFunc(__index.SetFixedFrameLevel)
              end,
              SetFixedFrameStrata = function()
                return checkCFunc(__index.SetFixedFrameStrata)
              end,
              SetFlattensRenderLayers = function()
                return checkCFunc(__index.SetFlattensRenderLayers)
              end,
              SetForbidden = function()
                return checkCFunc(__index.SetForbidden)
              end,
              SetFrameBuffer = function()
                return checkCFunc(__index.SetFrameBuffer)
              end,
              SetFrameLevel = function()
                return checkCFunc(__index.SetFrameLevel)
              end,
              SetFrameStrata = function()
                return checkCFunc(__index.SetFrameStrata)
              end,
              SetHeight = function()
                return checkCFunc(__index.SetHeight)
              end,
              SetHitRectInsets = function()
                return checkCFunc(__index.SetHitRectInsets)
              end,
              SetHyperlinksEnabled = function()
                return checkCFunc(__index.SetHyperlinksEnabled)
              end,
              SetID = function()
                return checkCFunc(__index.SetID)
              end,
              SetIgnoreParentAlpha = function()
                return checkCFunc(__index.SetIgnoreParentAlpha)
              end,
              SetIgnoreParentScale = function()
                return checkCFunc(__index.SetIgnoreParentScale)
              end,
              SetMapID = function()
                return checkCFunc(__index.SetMapID)
              end,
              SetMaxResize = function()
                return checkCFunc(__index.SetMaxResize)
              end,
              SetMergeThreshold = function()
                return checkCFunc(__index.SetMergeThreshold)
              end,
              SetMinResize = function()
                return checkCFunc(__index.SetMinResize)
              end,
              SetMouseClickEnabled = function()
                return checkCFunc(__index.SetMouseClickEnabled)
              end,
              SetMouseMotionEnabled = function()
                return checkCFunc(__index.SetMouseMotionEnabled)
              end,
              SetMovable = function()
                return checkCFunc(__index.SetMovable)
              end,
              SetNumSplinePoints = function()
                return checkCFunc(__index.SetNumSplinePoints)
              end,
              SetParent = function()
                return checkCFunc(__index.SetParent)
              end,
              SetPoint = function()
                return checkCFunc(__index.SetPoint)
              end,
              SetPropagateKeyboardInput = function()
                return checkCFunc(__index.SetPropagateKeyboardInput)
              end,
              SetResizable = function()
                return checkCFunc(__index.SetResizable)
              end,
              SetScale = function()
                return checkCFunc(__index.SetScale)
              end,
              SetScript = function()
                return checkCFunc(__index.SetScript)
              end,
              SetShown = function()
                return checkCFunc(__index.SetShown)
              end,
              SetSize = function()
                return checkCFunc(__index.SetSize)
              end,
              SetToplevel = function()
                return checkCFunc(__index.SetToplevel)
              end,
              SetUserPlaced = function()
                return checkCFunc(__index.SetUserPlaced)
              end,
              SetWidth = function()
                return checkCFunc(__index.SetWidth)
              end,
              Show = function()
                return checkCFunc(__index.Show)
              end,
              StartMoving = function()
                return checkCFunc(__index.StartMoving)
              end,
              StartSizing = function()
                return checkCFunc(__index.StartSizing)
              end,
              StopAnimating = function()
                return checkCFunc(__index.StopAnimating)
              end,
              StopMovingOrSizing = function()
                return checkCFunc(__index.StopMovingOrSizing)
              end,
              UnregisterAllEvents = function()
                return checkCFunc(__index.UnregisterAllEvents)
              end,
              UnregisterEvent = function()
                return checkCFunc(__index.UnregisterEvent)
              end,
              UpdateMouseOverTooltip = function()
                return checkCFunc(__index.UpdateMouseOverTooltip)
              end,
            }
          end)
        end,
        ScriptObject = function()
          assertCreateFrameFails('ScriptObject')
        end,
        ScrollFrame = function()
          local function factory()
            return assertCreateFrame('ScrollFrame')
          end
          return mkTests('ScrollFrame', factory, function(__index)
            return {
              AdjustPointsOffset = function()
                return checkCFunc(__index.AdjustPointsOffset)
              end,
              CanChangeAttribute = function()
                return checkCFunc(__index.CanChangeAttribute)
              end,
              CanChangeProtectedState = function()
                return checkCFunc(__index.CanChangeProtectedState)
              end,
              ClearAllPoints = function()
                return checkCFunc(__index.ClearAllPoints)
              end,
              ClearPointByName = function()
                return checkCFunc(__index.ClearPointByName)
              end,
              ClearPointsOffset = function()
                return checkCFunc(__index.ClearPointsOffset)
              end,
              CreateAnimationGroup = function()
                return checkCFunc(__index.CreateAnimationGroup)
              end,
              CreateFontString = function()
                return checkCFunc(__index.CreateFontString)
              end,
              CreateLine = function()
                return checkCFunc(__index.CreateLine)
              end,
              CreateMaskTexture = function()
                return checkCFunc(__index.CreateMaskTexture)
              end,
              CreateTexture = function()
                return checkCFunc(__index.CreateTexture)
              end,
              DesaturateHierarchy = function()
                return checkCFunc(__index.DesaturateHierarchy)
              end,
              DisableDrawLayer = function()
                return checkCFunc(__index.DisableDrawLayer)
              end,
              DoesClipChildren = function()
                return checkCFunc(__index.DoesClipChildren)
              end,
              EnableDrawLayer = function()
                return checkCFunc(__index.EnableDrawLayer)
              end,
              EnableGamePadButton = function()
                return checkCFunc(__index.EnableGamePadButton)
              end,
              EnableGamePadStick = function()
                return checkCFunc(__index.EnableGamePadStick)
              end,
              EnableKeyboard = function()
                return checkCFunc(__index.EnableKeyboard)
              end,
              EnableMouse = function()
                return checkCFunc(__index.EnableMouse)
              end,
              EnableMouseWheel = function()
                return checkCFunc(__index.EnableMouseWheel)
              end,
              ExecuteAttribute = function()
                return checkCFunc(__index.ExecuteAttribute)
              end,
              GetAlpha = function()
                return checkCFunc(__index.GetAlpha)
              end,
              GetAnimationGroups = function()
                return checkCFunc(__index.GetAnimationGroups)
              end,
              GetAttribute = function()
                return checkCFunc(__index.GetAttribute)
              end,
              GetBottom = function()
                return checkCFunc(__index.GetBottom)
              end,
              GetBoundsRect = function()
                return checkCFunc(__index.GetBoundsRect)
              end,
              GetCenter = function()
                return checkCFunc(__index.GetCenter)
              end,
              GetChildren = function()
                return checkCFunc(__index.GetChildren)
              end,
              GetClampRectInsets = function()
                return checkCFunc(__index.GetClampRectInsets)
              end,
              GetDebugName = function()
                return checkCFunc(__index.GetDebugName)
              end,
              GetDepth = function()
                return checkCFunc(__index.GetDepth)
              end,
              GetDontSavePosition = function()
                return checkCFunc(__index.GetDontSavePosition)
              end,
              GetEffectiveAlpha = function()
                return checkCFunc(__index.GetEffectiveAlpha)
              end,
              GetEffectiveDepth = function()
                return checkCFunc(__index.GetEffectiveDepth)
              end,
              GetEffectiveScale = function()
                return checkCFunc(__index.GetEffectiveScale)
              end,
              GetEffectivelyFlattensRenderLayers = function()
                return checkCFunc(__index.GetEffectivelyFlattensRenderLayers)
              end,
              GetFlattensRenderLayers = function()
                return checkCFunc(__index.GetFlattensRenderLayers)
              end,
              GetFrameLevel = function()
                return checkCFunc(__index.GetFrameLevel)
              end,
              GetFrameStrata = function()
                return checkCFunc(__index.GetFrameStrata)
              end,
              GetHeight = function()
                return checkCFunc(__index.GetHeight)
              end,
              GetHitRectInsets = function()
                return checkCFunc(__index.GetHitRectInsets)
              end,
              GetHorizontalScroll = function()
                return checkCFunc(__index.GetHorizontalScroll)
              end,
              GetHorizontalScrollRange = function()
                return checkCFunc(__index.GetHorizontalScrollRange)
              end,
              GetHyperlinksEnabled = function()
                return checkCFunc(__index.GetHyperlinksEnabled)
              end,
              GetID = function()
                return checkCFunc(__index.GetID)
              end,
              GetLeft = function()
                return checkCFunc(__index.GetLeft)
              end,
              GetMaxResize = function()
                return checkCFunc(__index.GetMaxResize)
              end,
              GetMinResize = function()
                return checkCFunc(__index.GetMinResize)
              end,
              GetName = function()
                return checkCFunc(__index.GetName)
              end,
              GetNumChildren = function()
                return checkCFunc(__index.GetNumChildren)
              end,
              GetNumPoints = function()
                return checkCFunc(__index.GetNumPoints)
              end,
              GetNumRegions = function()
                return checkCFunc(__index.GetNumRegions)
              end,
              GetObjectType = function()
                return checkCFunc(__index.GetObjectType)
              end,
              GetParent = function()
                return checkCFunc(__index.GetParent)
              end,
              GetPoint = function()
                return checkCFunc(__index.GetPoint)
              end,
              GetPointByName = function()
                return checkCFunc(__index.GetPointByName)
              end,
              GetPropagateKeyboardInput = function()
                return checkCFunc(__index.GetPropagateKeyboardInput)
              end,
              GetRect = function()
                return checkCFunc(__index.GetRect)
              end,
              GetRegions = function()
                return checkCFunc(__index.GetRegions)
              end,
              GetRight = function()
                return checkCFunc(__index.GetRight)
              end,
              GetScale = function()
                return checkCFunc(__index.GetScale)
              end,
              GetScaledRect = function()
                return checkCFunc(__index.GetScaledRect)
              end,
              GetScript = function()
                return checkCFunc(__index.GetScript)
              end,
              GetScrollChild = function()
                return checkCFunc(__index.GetScrollChild)
              end,
              GetSize = function()
                return checkCFunc(__index.GetSize)
              end,
              GetSourceLocation = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetSourceLocation))
                  return
                end
                return checkCFunc(__index.GetSourceLocation)
              end,
              GetTop = function()
                return checkCFunc(__index.GetTop)
              end,
              GetVerticalScroll = function()
                return checkCFunc(__index.GetVerticalScroll)
              end,
              GetVerticalScrollRange = function()
                return checkCFunc(__index.GetVerticalScrollRange)
              end,
              GetWidth = function()
                return checkCFunc(__index.GetWidth)
              end,
              HasFixedFrameLevel = function()
                return checkCFunc(__index.HasFixedFrameLevel)
              end,
              HasFixedFrameStrata = function()
                return checkCFunc(__index.HasFixedFrameStrata)
              end,
              HasScript = function()
                return checkCFunc(__index.HasScript)
              end,
              Hide = function()
                return checkCFunc(__index.Hide)
              end,
              HookScript = function()
                return checkCFunc(__index.HookScript)
              end,
              IgnoreDepth = function()
                return checkCFunc(__index.IgnoreDepth)
              end,
              IsAnchoringRestricted = function()
                return checkCFunc(__index.IsAnchoringRestricted)
              end,
              IsClampedToScreen = function()
                return checkCFunc(__index.IsClampedToScreen)
              end,
              IsDragging = function()
                return checkCFunc(__index.IsDragging)
              end,
              IsEventRegistered = function()
                return checkCFunc(__index.IsEventRegistered)
              end,
              IsForbidden = function()
                return checkCFunc(__index.IsForbidden)
              end,
              IsGamePadButtonEnabled = function()
                return checkCFunc(__index.IsGamePadButtonEnabled)
              end,
              IsGamePadStickEnabled = function()
                return checkCFunc(__index.IsGamePadStickEnabled)
              end,
              IsIgnoringDepth = function()
                return checkCFunc(__index.IsIgnoringDepth)
              end,
              IsIgnoringParentAlpha = function()
                return checkCFunc(__index.IsIgnoringParentAlpha)
              end,
              IsIgnoringParentScale = function()
                return checkCFunc(__index.IsIgnoringParentScale)
              end,
              IsKeyboardEnabled = function()
                return checkCFunc(__index.IsKeyboardEnabled)
              end,
              IsMouseClickEnabled = function()
                return checkCFunc(__index.IsMouseClickEnabled)
              end,
              IsMouseEnabled = function()
                return checkCFunc(__index.IsMouseEnabled)
              end,
              IsMouseMotionEnabled = function()
                return checkCFunc(__index.IsMouseMotionEnabled)
              end,
              IsMouseOver = function()
                return checkCFunc(__index.IsMouseOver)
              end,
              IsMouseWheelEnabled = function()
                return checkCFunc(__index.IsMouseWheelEnabled)
              end,
              IsMovable = function()
                return checkCFunc(__index.IsMovable)
              end,
              IsObjectLoaded = function()
                return checkCFunc(__index.IsObjectLoaded)
              end,
              IsObjectType = function()
                return checkCFunc(__index.IsObjectType)
              end,
              IsProtected = function()
                return checkCFunc(__index.IsProtected)
              end,
              IsRectValid = function()
                return checkCFunc(__index.IsRectValid)
              end,
              IsResizable = function()
                return checkCFunc(__index.IsResizable)
              end,
              IsShown = function()
                return checkCFunc(__index.IsShown)
              end,
              IsToplevel = function()
                return checkCFunc(__index.IsToplevel)
              end,
              IsUserPlaced = function()
                return checkCFunc(__index.IsUserPlaced)
              end,
              IsVisible = function()
                return checkCFunc(__index.IsVisible)
              end,
              Lower = function()
                return checkCFunc(__index.Lower)
              end,
              Raise = function()
                return checkCFunc(__index.Raise)
              end,
              RegisterAllEvents = function()
                return checkCFunc(__index.RegisterAllEvents)
              end,
              RegisterEvent = function()
                return checkCFunc(__index.RegisterEvent)
              end,
              RegisterForDrag = function()
                return checkCFunc(__index.RegisterForDrag)
              end,
              RegisterUnitEvent = function()
                return checkCFunc(__index.RegisterUnitEvent)
              end,
              RotateTextures = function()
                return checkCFunc(__index.RotateTextures)
              end,
              SetAllPoints = function()
                return checkCFunc(__index.SetAllPoints)
              end,
              SetAlpha = function()
                return checkCFunc(__index.SetAlpha)
              end,
              SetAttribute = function()
                return checkCFunc(__index.SetAttribute)
              end,
              SetAttributeNoHandler = function()
                return checkCFunc(__index.SetAttributeNoHandler)
              end,
              SetClampRectInsets = function()
                return checkCFunc(__index.SetClampRectInsets)
              end,
              SetClampedToScreen = function()
                return checkCFunc(__index.SetClampedToScreen)
              end,
              SetClipsChildren = function()
                return checkCFunc(__index.SetClipsChildren)
              end,
              SetDepth = function()
                return checkCFunc(__index.SetDepth)
              end,
              SetDontSavePosition = function()
                return checkCFunc(__index.SetDontSavePosition)
              end,
              SetDrawLayerEnabled = function()
                return checkCFunc(__index.SetDrawLayerEnabled)
              end,
              SetFixedFrameLevel = function()
                return checkCFunc(__index.SetFixedFrameLevel)
              end,
              SetFixedFrameStrata = function()
                return checkCFunc(__index.SetFixedFrameStrata)
              end,
              SetFlattensRenderLayers = function()
                return checkCFunc(__index.SetFlattensRenderLayers)
              end,
              SetForbidden = function()
                return checkCFunc(__index.SetForbidden)
              end,
              SetFrameBuffer = function()
                return checkCFunc(__index.SetFrameBuffer)
              end,
              SetFrameLevel = function()
                return checkCFunc(__index.SetFrameLevel)
              end,
              SetFrameStrata = function()
                return checkCFunc(__index.SetFrameStrata)
              end,
              SetHeight = function()
                return checkCFunc(__index.SetHeight)
              end,
              SetHitRectInsets = function()
                return checkCFunc(__index.SetHitRectInsets)
              end,
              SetHorizontalScroll = function()
                return checkCFunc(__index.SetHorizontalScroll)
              end,
              SetHyperlinksEnabled = function()
                return checkCFunc(__index.SetHyperlinksEnabled)
              end,
              SetID = function()
                return checkCFunc(__index.SetID)
              end,
              SetIgnoreParentAlpha = function()
                return checkCFunc(__index.SetIgnoreParentAlpha)
              end,
              SetIgnoreParentScale = function()
                return checkCFunc(__index.SetIgnoreParentScale)
              end,
              SetMaxResize = function()
                return checkCFunc(__index.SetMaxResize)
              end,
              SetMinResize = function()
                return checkCFunc(__index.SetMinResize)
              end,
              SetMouseClickEnabled = function()
                return checkCFunc(__index.SetMouseClickEnabled)
              end,
              SetMouseMotionEnabled = function()
                return checkCFunc(__index.SetMouseMotionEnabled)
              end,
              SetMovable = function()
                return checkCFunc(__index.SetMovable)
              end,
              SetParent = function()
                return checkCFunc(__index.SetParent)
              end,
              SetPoint = function()
                return checkCFunc(__index.SetPoint)
              end,
              SetPropagateKeyboardInput = function()
                return checkCFunc(__index.SetPropagateKeyboardInput)
              end,
              SetResizable = function()
                return checkCFunc(__index.SetResizable)
              end,
              SetScale = function()
                return checkCFunc(__index.SetScale)
              end,
              SetScript = function()
                return checkCFunc(__index.SetScript)
              end,
              SetScrollChild = function()
                return checkCFunc(__index.SetScrollChild)
              end,
              SetShown = function()
                return checkCFunc(__index.SetShown)
              end,
              SetSize = function()
                return checkCFunc(__index.SetSize)
              end,
              SetToplevel = function()
                return checkCFunc(__index.SetToplevel)
              end,
              SetUserPlaced = function()
                return checkCFunc(__index.SetUserPlaced)
              end,
              SetVerticalScroll = function()
                return checkCFunc(__index.SetVerticalScroll)
              end,
              SetWidth = function()
                return checkCFunc(__index.SetWidth)
              end,
              Show = function()
                return checkCFunc(__index.Show)
              end,
              StartMoving = function()
                return checkCFunc(__index.StartMoving)
              end,
              StartSizing = function()
                return checkCFunc(__index.StartSizing)
              end,
              StopAnimating = function()
                return checkCFunc(__index.StopAnimating)
              end,
              StopMovingOrSizing = function()
                return checkCFunc(__index.StopMovingOrSizing)
              end,
              UnregisterAllEvents = function()
                return checkCFunc(__index.UnregisterAllEvents)
              end,
              UnregisterEvent = function()
                return checkCFunc(__index.UnregisterEvent)
              end,
              UpdateScrollChildRect = function()
                return checkCFunc(__index.UpdateScrollChildRect)
              end,
            }
          end)
        end,
        SimpleHTML = function()
          local function factory()
            return assertCreateFrame('SimpleHTML')
          end
          return mkTests('SimpleHTML', factory, function(__index)
            return {
              AdjustPointsOffset = function()
                return checkCFunc(__index.AdjustPointsOffset)
              end,
              CanChangeAttribute = function()
                return checkCFunc(__index.CanChangeAttribute)
              end,
              CanChangeProtectedState = function()
                return checkCFunc(__index.CanChangeProtectedState)
              end,
              ClearAllPoints = function()
                return checkCFunc(__index.ClearAllPoints)
              end,
              ClearPointByName = function()
                return checkCFunc(__index.ClearPointByName)
              end,
              ClearPointsOffset = function()
                return checkCFunc(__index.ClearPointsOffset)
              end,
              CreateAnimationGroup = function()
                return checkCFunc(__index.CreateAnimationGroup)
              end,
              CreateFontString = function()
                return checkCFunc(__index.CreateFontString)
              end,
              CreateLine = function()
                return checkCFunc(__index.CreateLine)
              end,
              CreateMaskTexture = function()
                return checkCFunc(__index.CreateMaskTexture)
              end,
              CreateTexture = function()
                return checkCFunc(__index.CreateTexture)
              end,
              DesaturateHierarchy = function()
                return checkCFunc(__index.DesaturateHierarchy)
              end,
              DisableDrawLayer = function()
                return checkCFunc(__index.DisableDrawLayer)
              end,
              DoesClipChildren = function()
                return checkCFunc(__index.DoesClipChildren)
              end,
              EnableDrawLayer = function()
                return checkCFunc(__index.EnableDrawLayer)
              end,
              EnableGamePadButton = function()
                return checkCFunc(__index.EnableGamePadButton)
              end,
              EnableGamePadStick = function()
                return checkCFunc(__index.EnableGamePadStick)
              end,
              EnableKeyboard = function()
                return checkCFunc(__index.EnableKeyboard)
              end,
              EnableMouse = function()
                return checkCFunc(__index.EnableMouse)
              end,
              EnableMouseWheel = function()
                return checkCFunc(__index.EnableMouseWheel)
              end,
              ExecuteAttribute = function()
                return checkCFunc(__index.ExecuteAttribute)
              end,
              GetAlpha = function()
                return checkCFunc(__index.GetAlpha)
              end,
              GetAnimationGroups = function()
                return checkCFunc(__index.GetAnimationGroups)
              end,
              GetAttribute = function()
                return checkCFunc(__index.GetAttribute)
              end,
              GetBottom = function()
                return checkCFunc(__index.GetBottom)
              end,
              GetBoundsRect = function()
                return checkCFunc(__index.GetBoundsRect)
              end,
              GetCenter = function()
                return checkCFunc(__index.GetCenter)
              end,
              GetChildren = function()
                return checkCFunc(__index.GetChildren)
              end,
              GetClampRectInsets = function()
                return checkCFunc(__index.GetClampRectInsets)
              end,
              GetContentHeight = function()
                return checkCFunc(__index.GetContentHeight)
              end,
              GetDebugName = function()
                return checkCFunc(__index.GetDebugName)
              end,
              GetDepth = function()
                return checkCFunc(__index.GetDepth)
              end,
              GetDontSavePosition = function()
                return checkCFunc(__index.GetDontSavePosition)
              end,
              GetEffectiveAlpha = function()
                return checkCFunc(__index.GetEffectiveAlpha)
              end,
              GetEffectiveDepth = function()
                return checkCFunc(__index.GetEffectiveDepth)
              end,
              GetEffectiveScale = function()
                return checkCFunc(__index.GetEffectiveScale)
              end,
              GetEffectivelyFlattensRenderLayers = function()
                return checkCFunc(__index.GetEffectivelyFlattensRenderLayers)
              end,
              GetFlattensRenderLayers = function()
                return checkCFunc(__index.GetFlattensRenderLayers)
              end,
              GetFont = function()
                return checkCFunc(__index.GetFont)
              end,
              GetFontObject = function()
                return checkCFunc(__index.GetFontObject)
              end,
              GetFrameLevel = function()
                return checkCFunc(__index.GetFrameLevel)
              end,
              GetFrameStrata = function()
                return checkCFunc(__index.GetFrameStrata)
              end,
              GetHeight = function()
                return checkCFunc(__index.GetHeight)
              end,
              GetHitRectInsets = function()
                return checkCFunc(__index.GetHitRectInsets)
              end,
              GetHyperlinkFormat = function()
                return checkCFunc(__index.GetHyperlinkFormat)
              end,
              GetHyperlinksEnabled = function()
                return checkCFunc(__index.GetHyperlinksEnabled)
              end,
              GetID = function()
                return checkCFunc(__index.GetID)
              end,
              GetIndentedWordWrap = function()
                return checkCFunc(__index.GetIndentedWordWrap)
              end,
              GetJustifyH = function()
                return checkCFunc(__index.GetJustifyH)
              end,
              GetJustifyV = function()
                return checkCFunc(__index.GetJustifyV)
              end,
              GetLeft = function()
                return checkCFunc(__index.GetLeft)
              end,
              GetMaxResize = function()
                return checkCFunc(__index.GetMaxResize)
              end,
              GetMinResize = function()
                return checkCFunc(__index.GetMinResize)
              end,
              GetName = function()
                return checkCFunc(__index.GetName)
              end,
              GetNumChildren = function()
                return checkCFunc(__index.GetNumChildren)
              end,
              GetNumPoints = function()
                return checkCFunc(__index.GetNumPoints)
              end,
              GetNumRegions = function()
                return checkCFunc(__index.GetNumRegions)
              end,
              GetObjectType = function()
                return checkCFunc(__index.GetObjectType)
              end,
              GetParent = function()
                return checkCFunc(__index.GetParent)
              end,
              GetPoint = function()
                return checkCFunc(__index.GetPoint)
              end,
              GetPointByName = function()
                return checkCFunc(__index.GetPointByName)
              end,
              GetPropagateKeyboardInput = function()
                return checkCFunc(__index.GetPropagateKeyboardInput)
              end,
              GetRect = function()
                return checkCFunc(__index.GetRect)
              end,
              GetRegions = function()
                return checkCFunc(__index.GetRegions)
              end,
              GetRight = function()
                return checkCFunc(__index.GetRight)
              end,
              GetScale = function()
                return checkCFunc(__index.GetScale)
              end,
              GetScaledRect = function()
                return checkCFunc(__index.GetScaledRect)
              end,
              GetScript = function()
                return checkCFunc(__index.GetScript)
              end,
              GetShadowColor = function()
                return checkCFunc(__index.GetShadowColor)
              end,
              GetShadowOffset = function()
                return checkCFunc(__index.GetShadowOffset)
              end,
              GetSize = function()
                return checkCFunc(__index.GetSize)
              end,
              GetSourceLocation = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetSourceLocation))
                  return
                end
                return checkCFunc(__index.GetSourceLocation)
              end,
              GetSpacing = function()
                return checkCFunc(__index.GetSpacing)
              end,
              GetTextColor = function()
                return checkCFunc(__index.GetTextColor)
              end,
              GetTextData = function()
                return checkCFunc(__index.GetTextData)
              end,
              GetTop = function()
                return checkCFunc(__index.GetTop)
              end,
              GetWidth = function()
                return checkCFunc(__index.GetWidth)
              end,
              HasFixedFrameLevel = function()
                return checkCFunc(__index.HasFixedFrameLevel)
              end,
              HasFixedFrameStrata = function()
                return checkCFunc(__index.HasFixedFrameStrata)
              end,
              HasScript = function()
                return checkCFunc(__index.HasScript)
              end,
              Hide = function()
                return checkCFunc(__index.Hide)
              end,
              HookScript = function()
                return checkCFunc(__index.HookScript)
              end,
              IgnoreDepth = function()
                return checkCFunc(__index.IgnoreDepth)
              end,
              IsAnchoringRestricted = function()
                return checkCFunc(__index.IsAnchoringRestricted)
              end,
              IsClampedToScreen = function()
                return checkCFunc(__index.IsClampedToScreen)
              end,
              IsDragging = function()
                return checkCFunc(__index.IsDragging)
              end,
              IsEventRegistered = function()
                return checkCFunc(__index.IsEventRegistered)
              end,
              IsForbidden = function()
                return checkCFunc(__index.IsForbidden)
              end,
              IsGamePadButtonEnabled = function()
                return checkCFunc(__index.IsGamePadButtonEnabled)
              end,
              IsGamePadStickEnabled = function()
                return checkCFunc(__index.IsGamePadStickEnabled)
              end,
              IsIgnoringDepth = function()
                return checkCFunc(__index.IsIgnoringDepth)
              end,
              IsIgnoringParentAlpha = function()
                return checkCFunc(__index.IsIgnoringParentAlpha)
              end,
              IsIgnoringParentScale = function()
                return checkCFunc(__index.IsIgnoringParentScale)
              end,
              IsKeyboardEnabled = function()
                return checkCFunc(__index.IsKeyboardEnabled)
              end,
              IsMouseClickEnabled = function()
                return checkCFunc(__index.IsMouseClickEnabled)
              end,
              IsMouseEnabled = function()
                return checkCFunc(__index.IsMouseEnabled)
              end,
              IsMouseMotionEnabled = function()
                return checkCFunc(__index.IsMouseMotionEnabled)
              end,
              IsMouseOver = function()
                return checkCFunc(__index.IsMouseOver)
              end,
              IsMouseWheelEnabled = function()
                return checkCFunc(__index.IsMouseWheelEnabled)
              end,
              IsMovable = function()
                return checkCFunc(__index.IsMovable)
              end,
              IsObjectLoaded = function()
                return checkCFunc(__index.IsObjectLoaded)
              end,
              IsObjectType = function()
                return checkCFunc(__index.IsObjectType)
              end,
              IsProtected = function()
                return checkCFunc(__index.IsProtected)
              end,
              IsRectValid = function()
                return checkCFunc(__index.IsRectValid)
              end,
              IsResizable = function()
                return checkCFunc(__index.IsResizable)
              end,
              IsShown = function()
                return checkCFunc(__index.IsShown)
              end,
              IsToplevel = function()
                return checkCFunc(__index.IsToplevel)
              end,
              IsUserPlaced = function()
                return checkCFunc(__index.IsUserPlaced)
              end,
              IsVisible = function()
                return checkCFunc(__index.IsVisible)
              end,
              Lower = function()
                return checkCFunc(__index.Lower)
              end,
              Raise = function()
                return checkCFunc(__index.Raise)
              end,
              RegisterAllEvents = function()
                return checkCFunc(__index.RegisterAllEvents)
              end,
              RegisterEvent = function()
                return checkCFunc(__index.RegisterEvent)
              end,
              RegisterForDrag = function()
                return checkCFunc(__index.RegisterForDrag)
              end,
              RegisterUnitEvent = function()
                return checkCFunc(__index.RegisterUnitEvent)
              end,
              RotateTextures = function()
                return checkCFunc(__index.RotateTextures)
              end,
              SetAllPoints = function()
                return checkCFunc(__index.SetAllPoints)
              end,
              SetAlpha = function()
                return checkCFunc(__index.SetAlpha)
              end,
              SetAttribute = function()
                return checkCFunc(__index.SetAttribute)
              end,
              SetAttributeNoHandler = function()
                return checkCFunc(__index.SetAttributeNoHandler)
              end,
              SetClampRectInsets = function()
                return checkCFunc(__index.SetClampRectInsets)
              end,
              SetClampedToScreen = function()
                return checkCFunc(__index.SetClampedToScreen)
              end,
              SetClipsChildren = function()
                return checkCFunc(__index.SetClipsChildren)
              end,
              SetDepth = function()
                return checkCFunc(__index.SetDepth)
              end,
              SetDontSavePosition = function()
                return checkCFunc(__index.SetDontSavePosition)
              end,
              SetDrawLayerEnabled = function()
                return checkCFunc(__index.SetDrawLayerEnabled)
              end,
              SetFixedFrameLevel = function()
                return checkCFunc(__index.SetFixedFrameLevel)
              end,
              SetFixedFrameStrata = function()
                return checkCFunc(__index.SetFixedFrameStrata)
              end,
              SetFlattensRenderLayers = function()
                return checkCFunc(__index.SetFlattensRenderLayers)
              end,
              SetFont = function()
                return checkCFunc(__index.SetFont)
              end,
              SetFontObject = function()
                return checkCFunc(__index.SetFontObject)
              end,
              SetForbidden = function()
                return checkCFunc(__index.SetForbidden)
              end,
              SetFrameBuffer = function()
                return checkCFunc(__index.SetFrameBuffer)
              end,
              SetFrameLevel = function()
                return checkCFunc(__index.SetFrameLevel)
              end,
              SetFrameStrata = function()
                return checkCFunc(__index.SetFrameStrata)
              end,
              SetHeight = function()
                return checkCFunc(__index.SetHeight)
              end,
              SetHitRectInsets = function()
                return checkCFunc(__index.SetHitRectInsets)
              end,
              SetHyperlinkFormat = function()
                return checkCFunc(__index.SetHyperlinkFormat)
              end,
              SetHyperlinksEnabled = function()
                return checkCFunc(__index.SetHyperlinksEnabled)
              end,
              SetID = function()
                return checkCFunc(__index.SetID)
              end,
              SetIgnoreParentAlpha = function()
                return checkCFunc(__index.SetIgnoreParentAlpha)
              end,
              SetIgnoreParentScale = function()
                return checkCFunc(__index.SetIgnoreParentScale)
              end,
              SetIndentedWordWrap = function()
                return checkCFunc(__index.SetIndentedWordWrap)
              end,
              SetJustifyH = function()
                return checkCFunc(__index.SetJustifyH)
              end,
              SetJustifyV = function()
                return checkCFunc(__index.SetJustifyV)
              end,
              SetMaxResize = function()
                return checkCFunc(__index.SetMaxResize)
              end,
              SetMinResize = function()
                return checkCFunc(__index.SetMinResize)
              end,
              SetMouseClickEnabled = function()
                return checkCFunc(__index.SetMouseClickEnabled)
              end,
              SetMouseMotionEnabled = function()
                return checkCFunc(__index.SetMouseMotionEnabled)
              end,
              SetMovable = function()
                return checkCFunc(__index.SetMovable)
              end,
              SetParent = function()
                return checkCFunc(__index.SetParent)
              end,
              SetPoint = function()
                return checkCFunc(__index.SetPoint)
              end,
              SetPropagateKeyboardInput = function()
                return checkCFunc(__index.SetPropagateKeyboardInput)
              end,
              SetResizable = function()
                return checkCFunc(__index.SetResizable)
              end,
              SetScale = function()
                return checkCFunc(__index.SetScale)
              end,
              SetScript = function()
                return checkCFunc(__index.SetScript)
              end,
              SetShadowColor = function()
                return checkCFunc(__index.SetShadowColor)
              end,
              SetShadowOffset = function()
                return checkCFunc(__index.SetShadowOffset)
              end,
              SetShown = function()
                return checkCFunc(__index.SetShown)
              end,
              SetSize = function()
                return checkCFunc(__index.SetSize)
              end,
              SetSpacing = function()
                return checkCFunc(__index.SetSpacing)
              end,
              SetText = function()
                return checkCFunc(__index.SetText)
              end,
              SetTextColor = function()
                return checkCFunc(__index.SetTextColor)
              end,
              SetToplevel = function()
                return checkCFunc(__index.SetToplevel)
              end,
              SetUserPlaced = function()
                return checkCFunc(__index.SetUserPlaced)
              end,
              SetWidth = function()
                return checkCFunc(__index.SetWidth)
              end,
              Show = function()
                return checkCFunc(__index.Show)
              end,
              StartMoving = function()
                return checkCFunc(__index.StartMoving)
              end,
              StartSizing = function()
                return checkCFunc(__index.StartSizing)
              end,
              StopAnimating = function()
                return checkCFunc(__index.StopAnimating)
              end,
              StopMovingOrSizing = function()
                return checkCFunc(__index.StopMovingOrSizing)
              end,
              UnregisterAllEvents = function()
                return checkCFunc(__index.UnregisterAllEvents)
              end,
              UnregisterEvent = function()
                return checkCFunc(__index.UnregisterEvent)
              end,
            }
          end)
        end,
        Slider = function()
          local function factory()
            return assertCreateFrame('Slider')
          end
          return mkTests('Slider', factory, function(__index)
            return {
              AdjustPointsOffset = function()
                return checkCFunc(__index.AdjustPointsOffset)
              end,
              CanChangeAttribute = function()
                return checkCFunc(__index.CanChangeAttribute)
              end,
              CanChangeProtectedState = function()
                return checkCFunc(__index.CanChangeProtectedState)
              end,
              ClearAllPoints = function()
                return checkCFunc(__index.ClearAllPoints)
              end,
              ClearPointByName = function()
                return checkCFunc(__index.ClearPointByName)
              end,
              ClearPointsOffset = function()
                return checkCFunc(__index.ClearPointsOffset)
              end,
              CreateAnimationGroup = function()
                return checkCFunc(__index.CreateAnimationGroup)
              end,
              CreateFontString = function()
                return checkCFunc(__index.CreateFontString)
              end,
              CreateLine = function()
                return checkCFunc(__index.CreateLine)
              end,
              CreateMaskTexture = function()
                return checkCFunc(__index.CreateMaskTexture)
              end,
              CreateTexture = function()
                return checkCFunc(__index.CreateTexture)
              end,
              DesaturateHierarchy = function()
                return checkCFunc(__index.DesaturateHierarchy)
              end,
              Disable = function()
                return checkCFunc(__index.Disable)
              end,
              DisableDrawLayer = function()
                return checkCFunc(__index.DisableDrawLayer)
              end,
              DoesClipChildren = function()
                return checkCFunc(__index.DoesClipChildren)
              end,
              Enable = function()
                return checkCFunc(__index.Enable)
              end,
              EnableDrawLayer = function()
                return checkCFunc(__index.EnableDrawLayer)
              end,
              EnableGamePadButton = function()
                return checkCFunc(__index.EnableGamePadButton)
              end,
              EnableGamePadStick = function()
                return checkCFunc(__index.EnableGamePadStick)
              end,
              EnableKeyboard = function()
                return checkCFunc(__index.EnableKeyboard)
              end,
              EnableMouse = function()
                return checkCFunc(__index.EnableMouse)
              end,
              EnableMouseWheel = function()
                return checkCFunc(__index.EnableMouseWheel)
              end,
              ExecuteAttribute = function()
                return checkCFunc(__index.ExecuteAttribute)
              end,
              GetAlpha = function()
                return checkCFunc(__index.GetAlpha)
              end,
              GetAnimationGroups = function()
                return checkCFunc(__index.GetAnimationGroups)
              end,
              GetAttribute = function()
                return checkCFunc(__index.GetAttribute)
              end,
              GetBottom = function()
                return checkCFunc(__index.GetBottom)
              end,
              GetBoundsRect = function()
                return checkCFunc(__index.GetBoundsRect)
              end,
              GetCenter = function()
                return checkCFunc(__index.GetCenter)
              end,
              GetChildren = function()
                return checkCFunc(__index.GetChildren)
              end,
              GetClampRectInsets = function()
                return checkCFunc(__index.GetClampRectInsets)
              end,
              GetDebugName = function()
                return checkCFunc(__index.GetDebugName)
              end,
              GetDepth = function()
                return checkCFunc(__index.GetDepth)
              end,
              GetDontSavePosition = function()
                return checkCFunc(__index.GetDontSavePosition)
              end,
              GetEffectiveAlpha = function()
                return checkCFunc(__index.GetEffectiveAlpha)
              end,
              GetEffectiveDepth = function()
                return checkCFunc(__index.GetEffectiveDepth)
              end,
              GetEffectiveScale = function()
                return checkCFunc(__index.GetEffectiveScale)
              end,
              GetEffectivelyFlattensRenderLayers = function()
                return checkCFunc(__index.GetEffectivelyFlattensRenderLayers)
              end,
              GetFlattensRenderLayers = function()
                return checkCFunc(__index.GetFlattensRenderLayers)
              end,
              GetFrameLevel = function()
                return checkCFunc(__index.GetFrameLevel)
              end,
              GetFrameStrata = function()
                return checkCFunc(__index.GetFrameStrata)
              end,
              GetHeight = function()
                return checkCFunc(__index.GetHeight)
              end,
              GetHitRectInsets = function()
                return checkCFunc(__index.GetHitRectInsets)
              end,
              GetHyperlinksEnabled = function()
                return checkCFunc(__index.GetHyperlinksEnabled)
              end,
              GetID = function()
                return checkCFunc(__index.GetID)
              end,
              GetLeft = function()
                return checkCFunc(__index.GetLeft)
              end,
              GetMaxResize = function()
                return checkCFunc(__index.GetMaxResize)
              end,
              GetMinMaxValues = function()
                return checkCFunc(__index.GetMinMaxValues)
              end,
              GetMinResize = function()
                return checkCFunc(__index.GetMinResize)
              end,
              GetName = function()
                return checkCFunc(__index.GetName)
              end,
              GetNumChildren = function()
                return checkCFunc(__index.GetNumChildren)
              end,
              GetNumPoints = function()
                return checkCFunc(__index.GetNumPoints)
              end,
              GetNumRegions = function()
                return checkCFunc(__index.GetNumRegions)
              end,
              GetObeyStepOnDrag = function()
                return checkCFunc(__index.GetObeyStepOnDrag)
              end,
              GetObjectType = function()
                return checkCFunc(__index.GetObjectType)
              end,
              GetOrientation = function()
                return checkCFunc(__index.GetOrientation)
              end,
              GetParent = function()
                return checkCFunc(__index.GetParent)
              end,
              GetPoint = function()
                return checkCFunc(__index.GetPoint)
              end,
              GetPointByName = function()
                return checkCFunc(__index.GetPointByName)
              end,
              GetPropagateKeyboardInput = function()
                return checkCFunc(__index.GetPropagateKeyboardInput)
              end,
              GetRect = function()
                return checkCFunc(__index.GetRect)
              end,
              GetRegions = function()
                return checkCFunc(__index.GetRegions)
              end,
              GetRight = function()
                return checkCFunc(__index.GetRight)
              end,
              GetScale = function()
                return checkCFunc(__index.GetScale)
              end,
              GetScaledRect = function()
                return checkCFunc(__index.GetScaledRect)
              end,
              GetScript = function()
                return checkCFunc(__index.GetScript)
              end,
              GetSize = function()
                return checkCFunc(__index.GetSize)
              end,
              GetSourceLocation = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetSourceLocation))
                  return
                end
                return checkCFunc(__index.GetSourceLocation)
              end,
              GetStepsPerPage = function()
                return checkCFunc(__index.GetStepsPerPage)
              end,
              GetThumbTexture = function()
                return checkCFunc(__index.GetThumbTexture)
              end,
              GetTop = function()
                return checkCFunc(__index.GetTop)
              end,
              GetValue = function()
                return checkCFunc(__index.GetValue)
              end,
              GetValueStep = function()
                return checkCFunc(__index.GetValueStep)
              end,
              GetWidth = function()
                return checkCFunc(__index.GetWidth)
              end,
              HasFixedFrameLevel = function()
                return checkCFunc(__index.HasFixedFrameLevel)
              end,
              HasFixedFrameStrata = function()
                return checkCFunc(__index.HasFixedFrameStrata)
              end,
              HasScript = function()
                return checkCFunc(__index.HasScript)
              end,
              Hide = function()
                return checkCFunc(__index.Hide)
              end,
              HookScript = function()
                return checkCFunc(__index.HookScript)
              end,
              IgnoreDepth = function()
                return checkCFunc(__index.IgnoreDepth)
              end,
              IsAnchoringRestricted = function()
                return checkCFunc(__index.IsAnchoringRestricted)
              end,
              IsClampedToScreen = function()
                return checkCFunc(__index.IsClampedToScreen)
              end,
              IsDragging = function()
                return checkCFunc(__index.IsDragging)
              end,
              IsDraggingThumb = function()
                return checkCFunc(__index.IsDraggingThumb)
              end,
              IsEnabled = function()
                return checkCFunc(__index.IsEnabled)
              end,
              IsEventRegistered = function()
                return checkCFunc(__index.IsEventRegistered)
              end,
              IsForbidden = function()
                return checkCFunc(__index.IsForbidden)
              end,
              IsGamePadButtonEnabled = function()
                return checkCFunc(__index.IsGamePadButtonEnabled)
              end,
              IsGamePadStickEnabled = function()
                return checkCFunc(__index.IsGamePadStickEnabled)
              end,
              IsIgnoringDepth = function()
                return checkCFunc(__index.IsIgnoringDepth)
              end,
              IsIgnoringParentAlpha = function()
                return checkCFunc(__index.IsIgnoringParentAlpha)
              end,
              IsIgnoringParentScale = function()
                return checkCFunc(__index.IsIgnoringParentScale)
              end,
              IsKeyboardEnabled = function()
                return checkCFunc(__index.IsKeyboardEnabled)
              end,
              IsMouseClickEnabled = function()
                return checkCFunc(__index.IsMouseClickEnabled)
              end,
              IsMouseEnabled = function()
                return checkCFunc(__index.IsMouseEnabled)
              end,
              IsMouseMotionEnabled = function()
                return checkCFunc(__index.IsMouseMotionEnabled)
              end,
              IsMouseOver = function()
                return checkCFunc(__index.IsMouseOver)
              end,
              IsMouseWheelEnabled = function()
                return checkCFunc(__index.IsMouseWheelEnabled)
              end,
              IsMovable = function()
                return checkCFunc(__index.IsMovable)
              end,
              IsObjectLoaded = function()
                return checkCFunc(__index.IsObjectLoaded)
              end,
              IsObjectType = function()
                return checkCFunc(__index.IsObjectType)
              end,
              IsProtected = function()
                return checkCFunc(__index.IsProtected)
              end,
              IsRectValid = function()
                return checkCFunc(__index.IsRectValid)
              end,
              IsResizable = function()
                return checkCFunc(__index.IsResizable)
              end,
              IsShown = function()
                return checkCFunc(__index.IsShown)
              end,
              IsToplevel = function()
                return checkCFunc(__index.IsToplevel)
              end,
              IsUserPlaced = function()
                return checkCFunc(__index.IsUserPlaced)
              end,
              IsVisible = function()
                return checkCFunc(__index.IsVisible)
              end,
              Lower = function()
                return checkCFunc(__index.Lower)
              end,
              Raise = function()
                return checkCFunc(__index.Raise)
              end,
              RegisterAllEvents = function()
                return checkCFunc(__index.RegisterAllEvents)
              end,
              RegisterEvent = function()
                return checkCFunc(__index.RegisterEvent)
              end,
              RegisterForDrag = function()
                return checkCFunc(__index.RegisterForDrag)
              end,
              RegisterUnitEvent = function()
                return checkCFunc(__index.RegisterUnitEvent)
              end,
              RotateTextures = function()
                return checkCFunc(__index.RotateTextures)
              end,
              SetAllPoints = function()
                return checkCFunc(__index.SetAllPoints)
              end,
              SetAlpha = function()
                return checkCFunc(__index.SetAlpha)
              end,
              SetAttribute = function()
                return checkCFunc(__index.SetAttribute)
              end,
              SetAttributeNoHandler = function()
                return checkCFunc(__index.SetAttributeNoHandler)
              end,
              SetClampRectInsets = function()
                return checkCFunc(__index.SetClampRectInsets)
              end,
              SetClampedToScreen = function()
                return checkCFunc(__index.SetClampedToScreen)
              end,
              SetClipsChildren = function()
                return checkCFunc(__index.SetClipsChildren)
              end,
              SetDepth = function()
                return checkCFunc(__index.SetDepth)
              end,
              SetDontSavePosition = function()
                return checkCFunc(__index.SetDontSavePosition)
              end,
              SetDrawLayerEnabled = function()
                return checkCFunc(__index.SetDrawLayerEnabled)
              end,
              SetEnabled = function()
                return checkCFunc(__index.SetEnabled)
              end,
              SetFixedFrameLevel = function()
                return checkCFunc(__index.SetFixedFrameLevel)
              end,
              SetFixedFrameStrata = function()
                return checkCFunc(__index.SetFixedFrameStrata)
              end,
              SetFlattensRenderLayers = function()
                return checkCFunc(__index.SetFlattensRenderLayers)
              end,
              SetForbidden = function()
                return checkCFunc(__index.SetForbidden)
              end,
              SetFrameBuffer = function()
                return checkCFunc(__index.SetFrameBuffer)
              end,
              SetFrameLevel = function()
                return checkCFunc(__index.SetFrameLevel)
              end,
              SetFrameStrata = function()
                return checkCFunc(__index.SetFrameStrata)
              end,
              SetHeight = function()
                return checkCFunc(__index.SetHeight)
              end,
              SetHitRectInsets = function()
                return checkCFunc(__index.SetHitRectInsets)
              end,
              SetHyperlinksEnabled = function()
                return checkCFunc(__index.SetHyperlinksEnabled)
              end,
              SetID = function()
                return checkCFunc(__index.SetID)
              end,
              SetIgnoreParentAlpha = function()
                return checkCFunc(__index.SetIgnoreParentAlpha)
              end,
              SetIgnoreParentScale = function()
                return checkCFunc(__index.SetIgnoreParentScale)
              end,
              SetMaxResize = function()
                return checkCFunc(__index.SetMaxResize)
              end,
              SetMinMaxValues = function()
                return checkCFunc(__index.SetMinMaxValues)
              end,
              SetMinResize = function()
                return checkCFunc(__index.SetMinResize)
              end,
              SetMouseClickEnabled = function()
                return checkCFunc(__index.SetMouseClickEnabled)
              end,
              SetMouseMotionEnabled = function()
                return checkCFunc(__index.SetMouseMotionEnabled)
              end,
              SetMovable = function()
                return checkCFunc(__index.SetMovable)
              end,
              SetObeyStepOnDrag = function()
                return checkCFunc(__index.SetObeyStepOnDrag)
              end,
              SetOrientation = function()
                return checkCFunc(__index.SetOrientation)
              end,
              SetParent = function()
                return checkCFunc(__index.SetParent)
              end,
              SetPoint = function()
                return checkCFunc(__index.SetPoint)
              end,
              SetPropagateKeyboardInput = function()
                return checkCFunc(__index.SetPropagateKeyboardInput)
              end,
              SetResizable = function()
                return checkCFunc(__index.SetResizable)
              end,
              SetScale = function()
                return checkCFunc(__index.SetScale)
              end,
              SetScript = function()
                return checkCFunc(__index.SetScript)
              end,
              SetShown = function()
                return checkCFunc(__index.SetShown)
              end,
              SetSize = function()
                return checkCFunc(__index.SetSize)
              end,
              SetStepsPerPage = function()
                return checkCFunc(__index.SetStepsPerPage)
              end,
              SetThumbTexture = function()
                return checkCFunc(__index.SetThumbTexture)
              end,
              SetToplevel = function()
                return checkCFunc(__index.SetToplevel)
              end,
              SetUserPlaced = function()
                return checkCFunc(__index.SetUserPlaced)
              end,
              SetValue = function()
                return checkCFunc(__index.SetValue)
              end,
              SetValueStep = function()
                return checkCFunc(__index.SetValueStep)
              end,
              SetWidth = function()
                return checkCFunc(__index.SetWidth)
              end,
              Show = function()
                return checkCFunc(__index.Show)
              end,
              StartMoving = function()
                return checkCFunc(__index.StartMoving)
              end,
              StartSizing = function()
                return checkCFunc(__index.StartSizing)
              end,
              StopAnimating = function()
                return checkCFunc(__index.StopAnimating)
              end,
              StopMovingOrSizing = function()
                return checkCFunc(__index.StopMovingOrSizing)
              end,
              UnregisterAllEvents = function()
                return checkCFunc(__index.UnregisterAllEvents)
              end,
              UnregisterEvent = function()
                return checkCFunc(__index.UnregisterEvent)
              end,
            }
          end)
        end,
        StatusBar = function()
          local function factory()
            return assertCreateFrame('StatusBar')
          end
          return mkTests('StatusBar', factory, function(__index)
            return {
              AdjustPointsOffset = function()
                return checkCFunc(__index.AdjustPointsOffset)
              end,
              CanChangeAttribute = function()
                return checkCFunc(__index.CanChangeAttribute)
              end,
              CanChangeProtectedState = function()
                return checkCFunc(__index.CanChangeProtectedState)
              end,
              ClearAllPoints = function()
                return checkCFunc(__index.ClearAllPoints)
              end,
              ClearPointByName = function()
                return checkCFunc(__index.ClearPointByName)
              end,
              ClearPointsOffset = function()
                return checkCFunc(__index.ClearPointsOffset)
              end,
              CreateAnimationGroup = function()
                return checkCFunc(__index.CreateAnimationGroup)
              end,
              CreateFontString = function()
                return checkCFunc(__index.CreateFontString)
              end,
              CreateLine = function()
                return checkCFunc(__index.CreateLine)
              end,
              CreateMaskTexture = function()
                return checkCFunc(__index.CreateMaskTexture)
              end,
              CreateTexture = function()
                return checkCFunc(__index.CreateTexture)
              end,
              DesaturateHierarchy = function()
                return checkCFunc(__index.DesaturateHierarchy)
              end,
              DisableDrawLayer = function()
                return checkCFunc(__index.DisableDrawLayer)
              end,
              DoesClipChildren = function()
                return checkCFunc(__index.DoesClipChildren)
              end,
              EnableDrawLayer = function()
                return checkCFunc(__index.EnableDrawLayer)
              end,
              EnableGamePadButton = function()
                return checkCFunc(__index.EnableGamePadButton)
              end,
              EnableGamePadStick = function()
                return checkCFunc(__index.EnableGamePadStick)
              end,
              EnableKeyboard = function()
                return checkCFunc(__index.EnableKeyboard)
              end,
              EnableMouse = function()
                return checkCFunc(__index.EnableMouse)
              end,
              EnableMouseWheel = function()
                return checkCFunc(__index.EnableMouseWheel)
              end,
              ExecuteAttribute = function()
                return checkCFunc(__index.ExecuteAttribute)
              end,
              GetAlpha = function()
                return checkCFunc(__index.GetAlpha)
              end,
              GetAnimationGroups = function()
                return checkCFunc(__index.GetAnimationGroups)
              end,
              GetAttribute = function()
                return checkCFunc(__index.GetAttribute)
              end,
              GetBottom = function()
                return checkCFunc(__index.GetBottom)
              end,
              GetBoundsRect = function()
                return checkCFunc(__index.GetBoundsRect)
              end,
              GetCenter = function()
                return checkCFunc(__index.GetCenter)
              end,
              GetChildren = function()
                return checkCFunc(__index.GetChildren)
              end,
              GetClampRectInsets = function()
                return checkCFunc(__index.GetClampRectInsets)
              end,
              GetDebugName = function()
                return checkCFunc(__index.GetDebugName)
              end,
              GetDepth = function()
                return checkCFunc(__index.GetDepth)
              end,
              GetDontSavePosition = function()
                return checkCFunc(__index.GetDontSavePosition)
              end,
              GetEffectiveAlpha = function()
                return checkCFunc(__index.GetEffectiveAlpha)
              end,
              GetEffectiveDepth = function()
                return checkCFunc(__index.GetEffectiveDepth)
              end,
              GetEffectiveScale = function()
                return checkCFunc(__index.GetEffectiveScale)
              end,
              GetEffectivelyFlattensRenderLayers = function()
                return checkCFunc(__index.GetEffectivelyFlattensRenderLayers)
              end,
              GetFillStyle = function()
                return checkCFunc(__index.GetFillStyle)
              end,
              GetFlattensRenderLayers = function()
                return checkCFunc(__index.GetFlattensRenderLayers)
              end,
              GetFrameLevel = function()
                return checkCFunc(__index.GetFrameLevel)
              end,
              GetFrameStrata = function()
                return checkCFunc(__index.GetFrameStrata)
              end,
              GetHeight = function()
                return checkCFunc(__index.GetHeight)
              end,
              GetHitRectInsets = function()
                return checkCFunc(__index.GetHitRectInsets)
              end,
              GetHyperlinksEnabled = function()
                return checkCFunc(__index.GetHyperlinksEnabled)
              end,
              GetID = function()
                return checkCFunc(__index.GetID)
              end,
              GetLeft = function()
                return checkCFunc(__index.GetLeft)
              end,
              GetMaxResize = function()
                return checkCFunc(__index.GetMaxResize)
              end,
              GetMinMaxValues = function()
                return checkCFunc(__index.GetMinMaxValues)
              end,
              GetMinResize = function()
                return checkCFunc(__index.GetMinResize)
              end,
              GetName = function()
                return checkCFunc(__index.GetName)
              end,
              GetNumChildren = function()
                return checkCFunc(__index.GetNumChildren)
              end,
              GetNumPoints = function()
                return checkCFunc(__index.GetNumPoints)
              end,
              GetNumRegions = function()
                return checkCFunc(__index.GetNumRegions)
              end,
              GetObjectType = function()
                return checkCFunc(__index.GetObjectType)
              end,
              GetOrientation = function()
                return checkCFunc(__index.GetOrientation)
              end,
              GetParent = function()
                return checkCFunc(__index.GetParent)
              end,
              GetPoint = function()
                return checkCFunc(__index.GetPoint)
              end,
              GetPointByName = function()
                return checkCFunc(__index.GetPointByName)
              end,
              GetPropagateKeyboardInput = function()
                return checkCFunc(__index.GetPropagateKeyboardInput)
              end,
              GetRect = function()
                return checkCFunc(__index.GetRect)
              end,
              GetRegions = function()
                return checkCFunc(__index.GetRegions)
              end,
              GetReverseFill = function()
                return checkCFunc(__index.GetReverseFill)
              end,
              GetRight = function()
                return checkCFunc(__index.GetRight)
              end,
              GetRotatesTexture = function()
                return checkCFunc(__index.GetRotatesTexture)
              end,
              GetScale = function()
                return checkCFunc(__index.GetScale)
              end,
              GetScaledRect = function()
                return checkCFunc(__index.GetScaledRect)
              end,
              GetScript = function()
                return checkCFunc(__index.GetScript)
              end,
              GetSize = function()
                return checkCFunc(__index.GetSize)
              end,
              GetSourceLocation = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetSourceLocation))
                  return
                end
                return checkCFunc(__index.GetSourceLocation)
              end,
              GetStatusBarAtlas = function()
                return checkCFunc(__index.GetStatusBarAtlas)
              end,
              GetStatusBarColor = function()
                return checkCFunc(__index.GetStatusBarColor)
              end,
              GetStatusBarTexture = function()
                return checkCFunc(__index.GetStatusBarTexture)
              end,
              GetTop = function()
                return checkCFunc(__index.GetTop)
              end,
              GetValue = function()
                return checkCFunc(__index.GetValue)
              end,
              GetWidth = function()
                return checkCFunc(__index.GetWidth)
              end,
              HasFixedFrameLevel = function()
                return checkCFunc(__index.HasFixedFrameLevel)
              end,
              HasFixedFrameStrata = function()
                return checkCFunc(__index.HasFixedFrameStrata)
              end,
              HasScript = function()
                return checkCFunc(__index.HasScript)
              end,
              Hide = function()
                return checkCFunc(__index.Hide)
              end,
              HookScript = function()
                return checkCFunc(__index.HookScript)
              end,
              IgnoreDepth = function()
                return checkCFunc(__index.IgnoreDepth)
              end,
              IsAnchoringRestricted = function()
                return checkCFunc(__index.IsAnchoringRestricted)
              end,
              IsClampedToScreen = function()
                return checkCFunc(__index.IsClampedToScreen)
              end,
              IsDragging = function()
                return checkCFunc(__index.IsDragging)
              end,
              IsEventRegistered = function()
                return checkCFunc(__index.IsEventRegistered)
              end,
              IsForbidden = function()
                return checkCFunc(__index.IsForbidden)
              end,
              IsGamePadButtonEnabled = function()
                return checkCFunc(__index.IsGamePadButtonEnabled)
              end,
              IsGamePadStickEnabled = function()
                return checkCFunc(__index.IsGamePadStickEnabled)
              end,
              IsIgnoringDepth = function()
                return checkCFunc(__index.IsIgnoringDepth)
              end,
              IsIgnoringParentAlpha = function()
                return checkCFunc(__index.IsIgnoringParentAlpha)
              end,
              IsIgnoringParentScale = function()
                return checkCFunc(__index.IsIgnoringParentScale)
              end,
              IsKeyboardEnabled = function()
                return checkCFunc(__index.IsKeyboardEnabled)
              end,
              IsMouseClickEnabled = function()
                return checkCFunc(__index.IsMouseClickEnabled)
              end,
              IsMouseEnabled = function()
                return checkCFunc(__index.IsMouseEnabled)
              end,
              IsMouseMotionEnabled = function()
                return checkCFunc(__index.IsMouseMotionEnabled)
              end,
              IsMouseOver = function()
                return checkCFunc(__index.IsMouseOver)
              end,
              IsMouseWheelEnabled = function()
                return checkCFunc(__index.IsMouseWheelEnabled)
              end,
              IsMovable = function()
                return checkCFunc(__index.IsMovable)
              end,
              IsObjectLoaded = function()
                return checkCFunc(__index.IsObjectLoaded)
              end,
              IsObjectType = function()
                return checkCFunc(__index.IsObjectType)
              end,
              IsProtected = function()
                return checkCFunc(__index.IsProtected)
              end,
              IsRectValid = function()
                return checkCFunc(__index.IsRectValid)
              end,
              IsResizable = function()
                return checkCFunc(__index.IsResizable)
              end,
              IsShown = function()
                return checkCFunc(__index.IsShown)
              end,
              IsToplevel = function()
                return checkCFunc(__index.IsToplevel)
              end,
              IsUserPlaced = function()
                return checkCFunc(__index.IsUserPlaced)
              end,
              IsVisible = function()
                return checkCFunc(__index.IsVisible)
              end,
              Lower = function()
                return checkCFunc(__index.Lower)
              end,
              Raise = function()
                return checkCFunc(__index.Raise)
              end,
              RegisterAllEvents = function()
                return checkCFunc(__index.RegisterAllEvents)
              end,
              RegisterEvent = function()
                return checkCFunc(__index.RegisterEvent)
              end,
              RegisterForDrag = function()
                return checkCFunc(__index.RegisterForDrag)
              end,
              RegisterUnitEvent = function()
                return checkCFunc(__index.RegisterUnitEvent)
              end,
              RotateTextures = function()
                return checkCFunc(__index.RotateTextures)
              end,
              SetAllPoints = function()
                return checkCFunc(__index.SetAllPoints)
              end,
              SetAlpha = function()
                return checkCFunc(__index.SetAlpha)
              end,
              SetAttribute = function()
                return checkCFunc(__index.SetAttribute)
              end,
              SetAttributeNoHandler = function()
                return checkCFunc(__index.SetAttributeNoHandler)
              end,
              SetClampRectInsets = function()
                return checkCFunc(__index.SetClampRectInsets)
              end,
              SetClampedToScreen = function()
                return checkCFunc(__index.SetClampedToScreen)
              end,
              SetClipsChildren = function()
                return checkCFunc(__index.SetClipsChildren)
              end,
              SetDepth = function()
                return checkCFunc(__index.SetDepth)
              end,
              SetDontSavePosition = function()
                return checkCFunc(__index.SetDontSavePosition)
              end,
              SetDrawLayerEnabled = function()
                return checkCFunc(__index.SetDrawLayerEnabled)
              end,
              SetFillStyle = function()
                return checkCFunc(__index.SetFillStyle)
              end,
              SetFixedFrameLevel = function()
                return checkCFunc(__index.SetFixedFrameLevel)
              end,
              SetFixedFrameStrata = function()
                return checkCFunc(__index.SetFixedFrameStrata)
              end,
              SetFlattensRenderLayers = function()
                return checkCFunc(__index.SetFlattensRenderLayers)
              end,
              SetForbidden = function()
                return checkCFunc(__index.SetForbidden)
              end,
              SetFrameBuffer = function()
                return checkCFunc(__index.SetFrameBuffer)
              end,
              SetFrameLevel = function()
                return checkCFunc(__index.SetFrameLevel)
              end,
              SetFrameStrata = function()
                return checkCFunc(__index.SetFrameStrata)
              end,
              SetHeight = function()
                return checkCFunc(__index.SetHeight)
              end,
              SetHitRectInsets = function()
                return checkCFunc(__index.SetHitRectInsets)
              end,
              SetHyperlinksEnabled = function()
                return checkCFunc(__index.SetHyperlinksEnabled)
              end,
              SetID = function()
                return checkCFunc(__index.SetID)
              end,
              SetIgnoreParentAlpha = function()
                return checkCFunc(__index.SetIgnoreParentAlpha)
              end,
              SetIgnoreParentScale = function()
                return checkCFunc(__index.SetIgnoreParentScale)
              end,
              SetMaxResize = function()
                return checkCFunc(__index.SetMaxResize)
              end,
              SetMinMaxValues = function()
                return checkCFunc(__index.SetMinMaxValues)
              end,
              SetMinResize = function()
                return checkCFunc(__index.SetMinResize)
              end,
              SetMouseClickEnabled = function()
                return checkCFunc(__index.SetMouseClickEnabled)
              end,
              SetMouseMotionEnabled = function()
                return checkCFunc(__index.SetMouseMotionEnabled)
              end,
              SetMovable = function()
                return checkCFunc(__index.SetMovable)
              end,
              SetOrientation = function()
                return checkCFunc(__index.SetOrientation)
              end,
              SetParent = function()
                return checkCFunc(__index.SetParent)
              end,
              SetPoint = function()
                return checkCFunc(__index.SetPoint)
              end,
              SetPropagateKeyboardInput = function()
                return checkCFunc(__index.SetPropagateKeyboardInput)
              end,
              SetResizable = function()
                return checkCFunc(__index.SetResizable)
              end,
              SetReverseFill = function()
                return checkCFunc(__index.SetReverseFill)
              end,
              SetRotatesTexture = function()
                return checkCFunc(__index.SetRotatesTexture)
              end,
              SetScale = function()
                return checkCFunc(__index.SetScale)
              end,
              SetScript = function()
                return checkCFunc(__index.SetScript)
              end,
              SetShown = function()
                return checkCFunc(__index.SetShown)
              end,
              SetSize = function()
                return checkCFunc(__index.SetSize)
              end,
              SetStatusBarAtlas = function()
                return checkCFunc(__index.SetStatusBarAtlas)
              end,
              SetStatusBarColor = function()
                return checkCFunc(__index.SetStatusBarColor)
              end,
              SetStatusBarTexture = function()
                return checkCFunc(__index.SetStatusBarTexture)
              end,
              SetToplevel = function()
                return checkCFunc(__index.SetToplevel)
              end,
              SetUserPlaced = function()
                return checkCFunc(__index.SetUserPlaced)
              end,
              SetValue = function()
                return checkCFunc(__index.SetValue)
              end,
              SetWidth = function()
                return checkCFunc(__index.SetWidth)
              end,
              Show = function()
                return checkCFunc(__index.Show)
              end,
              StartMoving = function()
                return checkCFunc(__index.StartMoving)
              end,
              StartSizing = function()
                return checkCFunc(__index.StartSizing)
              end,
              StopAnimating = function()
                return checkCFunc(__index.StopAnimating)
              end,
              StopMovingOrSizing = function()
                return checkCFunc(__index.StopMovingOrSizing)
              end,
              UnregisterAllEvents = function()
                return checkCFunc(__index.UnregisterAllEvents)
              end,
              UnregisterEvent = function()
                return checkCFunc(__index.UnregisterEvent)
              end,
            }
          end)
        end,
        TabardModel = function()
          local function factory()
            return assertCreateFrame('TabardModel')
          end
          return mkTests('TabardModel', factory, function(__index)
            return {
              AdjustPointsOffset = function()
                return checkCFunc(__index.AdjustPointsOffset)
              end,
              AdvanceTime = function()
                return checkCFunc(__index.AdvanceTime)
              end,
              ApplySpellVisualKit = function()
                return checkCFunc(__index.ApplySpellVisualKit)
              end,
              CanChangeAttribute = function()
                return checkCFunc(__index.CanChangeAttribute)
              end,
              CanChangeProtectedState = function()
                return checkCFunc(__index.CanChangeProtectedState)
              end,
              CanSaveTabardNow = function()
                return checkCFunc(__index.CanSaveTabardNow)
              end,
              CanSetUnit = function()
                return checkCFunc(__index.CanSetUnit)
              end,
              ClearAllPoints = function()
                return checkCFunc(__index.ClearAllPoints)
              end,
              ClearFog = function()
                return checkCFunc(__index.ClearFog)
              end,
              ClearModel = function()
                return checkCFunc(__index.ClearModel)
              end,
              ClearPointByName = function()
                return checkCFunc(__index.ClearPointByName)
              end,
              ClearPointsOffset = function()
                return checkCFunc(__index.ClearPointsOffset)
              end,
              ClearTransform = function()
                return checkCFunc(__index.ClearTransform)
              end,
              CreateAnimationGroup = function()
                return checkCFunc(__index.CreateAnimationGroup)
              end,
              CreateFontString = function()
                return checkCFunc(__index.CreateFontString)
              end,
              CreateLine = function()
                return checkCFunc(__index.CreateLine)
              end,
              CreateMaskTexture = function()
                return checkCFunc(__index.CreateMaskTexture)
              end,
              CreateTexture = function()
                return checkCFunc(__index.CreateTexture)
              end,
              CycleVariation = function()
                return checkCFunc(__index.CycleVariation)
              end,
              DesaturateHierarchy = function()
                return checkCFunc(__index.DesaturateHierarchy)
              end,
              DisableDrawLayer = function()
                return checkCFunc(__index.DisableDrawLayer)
              end,
              DoesClipChildren = function()
                return checkCFunc(__index.DoesClipChildren)
              end,
              EnableDrawLayer = function()
                return checkCFunc(__index.EnableDrawLayer)
              end,
              EnableGamePadButton = function()
                return checkCFunc(__index.EnableGamePadButton)
              end,
              EnableGamePadStick = function()
                return checkCFunc(__index.EnableGamePadStick)
              end,
              EnableKeyboard = function()
                return checkCFunc(__index.EnableKeyboard)
              end,
              EnableMouse = function()
                return checkCFunc(__index.EnableMouse)
              end,
              EnableMouseWheel = function()
                return checkCFunc(__index.EnableMouseWheel)
              end,
              ExecuteAttribute = function()
                return checkCFunc(__index.ExecuteAttribute)
              end,
              FreezeAnimation = function()
                return checkCFunc(__index.FreezeAnimation)
              end,
              GetAlpha = function()
                return checkCFunc(__index.GetAlpha)
              end,
              GetAnimationGroups = function()
                return checkCFunc(__index.GetAnimationGroups)
              end,
              GetAttribute = function()
                return checkCFunc(__index.GetAttribute)
              end,
              GetBottom = function()
                return checkCFunc(__index.GetBottom)
              end,
              GetBoundsRect = function()
                return checkCFunc(__index.GetBoundsRect)
              end,
              GetCameraDistance = function()
                return checkCFunc(__index.GetCameraDistance)
              end,
              GetCameraFacing = function()
                return checkCFunc(__index.GetCameraFacing)
              end,
              GetCameraPosition = function()
                return checkCFunc(__index.GetCameraPosition)
              end,
              GetCameraRoll = function()
                return checkCFunc(__index.GetCameraRoll)
              end,
              GetCameraTarget = function()
                return checkCFunc(__index.GetCameraTarget)
              end,
              GetCenter = function()
                return checkCFunc(__index.GetCenter)
              end,
              GetChildren = function()
                return checkCFunc(__index.GetChildren)
              end,
              GetClampRectInsets = function()
                return checkCFunc(__index.GetClampRectInsets)
              end,
              GetDebugName = function()
                return checkCFunc(__index.GetDebugName)
              end,
              GetDepth = function()
                return checkCFunc(__index.GetDepth)
              end,
              GetDesaturation = function()
                return checkCFunc(__index.GetDesaturation)
              end,
              GetDisplayInfo = function()
                return checkCFunc(__index.GetDisplayInfo)
              end,
              GetDoBlend = function()
                return checkCFunc(__index.GetDoBlend)
              end,
              GetDontSavePosition = function()
                return checkCFunc(__index.GetDontSavePosition)
              end,
              GetEffectiveAlpha = function()
                return checkCFunc(__index.GetEffectiveAlpha)
              end,
              GetEffectiveDepth = function()
                return checkCFunc(__index.GetEffectiveDepth)
              end,
              GetEffectiveScale = function()
                return checkCFunc(__index.GetEffectiveScale)
              end,
              GetEffectivelyFlattensRenderLayers = function()
                return checkCFunc(__index.GetEffectivelyFlattensRenderLayers)
              end,
              GetFacing = function()
                return checkCFunc(__index.GetFacing)
              end,
              GetFlattensRenderLayers = function()
                return checkCFunc(__index.GetFlattensRenderLayers)
              end,
              GetFogColor = function()
                return checkCFunc(__index.GetFogColor)
              end,
              GetFogFar = function()
                return checkCFunc(__index.GetFogFar)
              end,
              GetFogNear = function()
                return checkCFunc(__index.GetFogNear)
              end,
              GetFrameLevel = function()
                return checkCFunc(__index.GetFrameLevel)
              end,
              GetFrameStrata = function()
                return checkCFunc(__index.GetFrameStrata)
              end,
              GetHeight = function()
                return checkCFunc(__index.GetHeight)
              end,
              GetHitRectInsets = function()
                return checkCFunc(__index.GetHitRectInsets)
              end,
              GetHyperlinksEnabled = function()
                return checkCFunc(__index.GetHyperlinksEnabled)
              end,
              GetID = function()
                return checkCFunc(__index.GetID)
              end,
              GetKeepModelOnHide = function()
                return checkCFunc(__index.GetKeepModelOnHide)
              end,
              GetLeft = function()
                return checkCFunc(__index.GetLeft)
              end,
              GetLight = function()
                return checkCFunc(__index.GetLight)
              end,
              GetLowerBackgroundFileName = function()
                return checkCFunc(__index.GetLowerBackgroundFileName)
              end,
              GetLowerEmblemFile = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetLowerEmblemFile))
                  return
                end
                return checkCFunc(__index.GetLowerEmblemFile)
              end,
              GetLowerEmblemFileName = function()
                if badProduct('wow_classic,wow_classic_beta,wow_classic_ptr,wow_classic_era,wow_classic_era_ptr') then
                  assertEquals('nil', type(__index.GetLowerEmblemFileName))
                  return
                end
                return checkCFunc(__index.GetLowerEmblemFileName)
              end,
              GetLowerEmblemTexture = function()
                return checkCFunc(__index.GetLowerEmblemTexture)
              end,
              GetMaxResize = function()
                return checkCFunc(__index.GetMaxResize)
              end,
              GetMinResize = function()
                return checkCFunc(__index.GetMinResize)
              end,
              GetModelAlpha = function()
                return checkCFunc(__index.GetModelAlpha)
              end,
              GetModelDrawLayer = function()
                return checkCFunc(__index.GetModelDrawLayer)
              end,
              GetModelFileID = function()
                return checkCFunc(__index.GetModelFileID)
              end,
              GetModelScale = function()
                return checkCFunc(__index.GetModelScale)
              end,
              GetName = function()
                return checkCFunc(__index.GetName)
              end,
              GetNumChildren = function()
                return checkCFunc(__index.GetNumChildren)
              end,
              GetNumPoints = function()
                return checkCFunc(__index.GetNumPoints)
              end,
              GetNumRegions = function()
                return checkCFunc(__index.GetNumRegions)
              end,
              GetObjectType = function()
                return checkCFunc(__index.GetObjectType)
              end,
              GetParent = function()
                return checkCFunc(__index.GetParent)
              end,
              GetPaused = function()
                return checkCFunc(__index.GetPaused)
              end,
              GetPitch = function()
                return checkCFunc(__index.GetPitch)
              end,
              GetPoint = function()
                return checkCFunc(__index.GetPoint)
              end,
              GetPointByName = function()
                return checkCFunc(__index.GetPointByName)
              end,
              GetPosition = function()
                return checkCFunc(__index.GetPosition)
              end,
              GetPropagateKeyboardInput = function()
                return checkCFunc(__index.GetPropagateKeyboardInput)
              end,
              GetRect = function()
                return checkCFunc(__index.GetRect)
              end,
              GetRegions = function()
                return checkCFunc(__index.GetRegions)
              end,
              GetRight = function()
                return checkCFunc(__index.GetRight)
              end,
              GetRoll = function()
                return checkCFunc(__index.GetRoll)
              end,
              GetScale = function()
                return checkCFunc(__index.GetScale)
              end,
              GetScaledRect = function()
                return checkCFunc(__index.GetScaledRect)
              end,
              GetScript = function()
                return checkCFunc(__index.GetScript)
              end,
              GetShadowEffect = function()
                return checkCFunc(__index.GetShadowEffect)
              end,
              GetSize = function()
                return checkCFunc(__index.GetSize)
              end,
              GetSourceLocation = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetSourceLocation))
                  return
                end
                return checkCFunc(__index.GetSourceLocation)
              end,
              GetTop = function()
                return checkCFunc(__index.GetTop)
              end,
              GetUpperBackgroundFileName = function()
                return checkCFunc(__index.GetUpperBackgroundFileName)
              end,
              GetUpperEmblemFile = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetUpperEmblemFile))
                  return
                end
                return checkCFunc(__index.GetUpperEmblemFile)
              end,
              GetUpperEmblemFileName = function()
                if badProduct('wow_classic,wow_classic_beta,wow_classic_ptr,wow_classic_era,wow_classic_era_ptr') then
                  assertEquals('nil', type(__index.GetUpperEmblemFileName))
                  return
                end
                return checkCFunc(__index.GetUpperEmblemFileName)
              end,
              GetUpperEmblemTexture = function()
                return checkCFunc(__index.GetUpperEmblemTexture)
              end,
              GetViewInsets = function()
                return checkCFunc(__index.GetViewInsets)
              end,
              GetViewTranslation = function()
                return checkCFunc(__index.GetViewTranslation)
              end,
              GetWidth = function()
                return checkCFunc(__index.GetWidth)
              end,
              GetWorldScale = function()
                return checkCFunc(__index.GetWorldScale)
              end,
              HasAnimation = function()
                return checkCFunc(__index.HasAnimation)
              end,
              HasAttachmentPoints = function()
                return checkCFunc(__index.HasAttachmentPoints)
              end,
              HasCustomCamera = function()
                return checkCFunc(__index.HasCustomCamera)
              end,
              HasFixedFrameLevel = function()
                return checkCFunc(__index.HasFixedFrameLevel)
              end,
              HasFixedFrameStrata = function()
                return checkCFunc(__index.HasFixedFrameStrata)
              end,
              HasScript = function()
                return checkCFunc(__index.HasScript)
              end,
              Hide = function()
                return checkCFunc(__index.Hide)
              end,
              HookScript = function()
                return checkCFunc(__index.HookScript)
              end,
              IgnoreDepth = function()
                return checkCFunc(__index.IgnoreDepth)
              end,
              InitializeTabardColors = function()
                return checkCFunc(__index.InitializeTabardColors)
              end,
              IsAnchoringRestricted = function()
                return checkCFunc(__index.IsAnchoringRestricted)
              end,
              IsClampedToScreen = function()
                return checkCFunc(__index.IsClampedToScreen)
              end,
              IsDragging = function()
                return checkCFunc(__index.IsDragging)
              end,
              IsEventRegistered = function()
                return checkCFunc(__index.IsEventRegistered)
              end,
              IsForbidden = function()
                return checkCFunc(__index.IsForbidden)
              end,
              IsGamePadButtonEnabled = function()
                return checkCFunc(__index.IsGamePadButtonEnabled)
              end,
              IsGamePadStickEnabled = function()
                return checkCFunc(__index.IsGamePadStickEnabled)
              end,
              IsIgnoringDepth = function()
                return checkCFunc(__index.IsIgnoringDepth)
              end,
              IsIgnoringParentAlpha = function()
                return checkCFunc(__index.IsIgnoringParentAlpha)
              end,
              IsIgnoringParentScale = function()
                return checkCFunc(__index.IsIgnoringParentScale)
              end,
              IsKeyboardEnabled = function()
                return checkCFunc(__index.IsKeyboardEnabled)
              end,
              IsMouseClickEnabled = function()
                return checkCFunc(__index.IsMouseClickEnabled)
              end,
              IsMouseEnabled = function()
                return checkCFunc(__index.IsMouseEnabled)
              end,
              IsMouseMotionEnabled = function()
                return checkCFunc(__index.IsMouseMotionEnabled)
              end,
              IsMouseOver = function()
                return checkCFunc(__index.IsMouseOver)
              end,
              IsMouseWheelEnabled = function()
                return checkCFunc(__index.IsMouseWheelEnabled)
              end,
              IsMovable = function()
                return checkCFunc(__index.IsMovable)
              end,
              IsObjectLoaded = function()
                return checkCFunc(__index.IsObjectLoaded)
              end,
              IsObjectType = function()
                return checkCFunc(__index.IsObjectType)
              end,
              IsProtected = function()
                return checkCFunc(__index.IsProtected)
              end,
              IsRectValid = function()
                return checkCFunc(__index.IsRectValid)
              end,
              IsResizable = function()
                return checkCFunc(__index.IsResizable)
              end,
              IsShown = function()
                return checkCFunc(__index.IsShown)
              end,
              IsToplevel = function()
                return checkCFunc(__index.IsToplevel)
              end,
              IsUserPlaced = function()
                return checkCFunc(__index.IsUserPlaced)
              end,
              IsUsingModelCenterToTransform = function()
                return checkCFunc(__index.IsUsingModelCenterToTransform)
              end,
              IsVisible = function()
                return checkCFunc(__index.IsVisible)
              end,
              Lower = function()
                return checkCFunc(__index.Lower)
              end,
              MakeCurrentCameraCustom = function()
                return checkCFunc(__index.MakeCurrentCameraCustom)
              end,
              PlayAnimKit = function()
                return checkCFunc(__index.PlayAnimKit)
              end,
              Raise = function()
                return checkCFunc(__index.Raise)
              end,
              RefreshCamera = function()
                return checkCFunc(__index.RefreshCamera)
              end,
              RefreshUnit = function()
                return checkCFunc(__index.RefreshUnit)
              end,
              RegisterAllEvents = function()
                return checkCFunc(__index.RegisterAllEvents)
              end,
              RegisterEvent = function()
                return checkCFunc(__index.RegisterEvent)
              end,
              RegisterForDrag = function()
                return checkCFunc(__index.RegisterForDrag)
              end,
              RegisterUnitEvent = function()
                return checkCFunc(__index.RegisterUnitEvent)
              end,
              ReplaceIconTexture = function()
                return checkCFunc(__index.ReplaceIconTexture)
              end,
              RotateTextures = function()
                return checkCFunc(__index.RotateTextures)
              end,
              Save = function()
                return checkCFunc(__index.Save)
              end,
              SetAllPoints = function()
                return checkCFunc(__index.SetAllPoints)
              end,
              SetAlpha = function()
                return checkCFunc(__index.SetAlpha)
              end,
              SetAnimation = function()
                return checkCFunc(__index.SetAnimation)
              end,
              SetAttribute = function()
                return checkCFunc(__index.SetAttribute)
              end,
              SetAttributeNoHandler = function()
                return checkCFunc(__index.SetAttributeNoHandler)
              end,
              SetBarberShopAlternateForm = function()
                return checkCFunc(__index.SetBarberShopAlternateForm)
              end,
              SetCamDistanceScale = function()
                return checkCFunc(__index.SetCamDistanceScale)
              end,
              SetCamera = function()
                return checkCFunc(__index.SetCamera)
              end,
              SetCameraDistance = function()
                return checkCFunc(__index.SetCameraDistance)
              end,
              SetCameraFacing = function()
                return checkCFunc(__index.SetCameraFacing)
              end,
              SetCameraPosition = function()
                return checkCFunc(__index.SetCameraPosition)
              end,
              SetCameraRoll = function()
                return checkCFunc(__index.SetCameraRoll)
              end,
              SetCameraTarget = function()
                return checkCFunc(__index.SetCameraTarget)
              end,
              SetClampRectInsets = function()
                return checkCFunc(__index.SetClampRectInsets)
              end,
              SetClampedToScreen = function()
                return checkCFunc(__index.SetClampedToScreen)
              end,
              SetClipsChildren = function()
                return checkCFunc(__index.SetClipsChildren)
              end,
              SetCreature = function()
                return checkCFunc(__index.SetCreature)
              end,
              SetCustomCamera = function()
                return checkCFunc(__index.SetCustomCamera)
              end,
              SetCustomRace = function()
                return checkCFunc(__index.SetCustomRace)
              end,
              SetDepth = function()
                return checkCFunc(__index.SetDepth)
              end,
              SetDesaturation = function()
                return checkCFunc(__index.SetDesaturation)
              end,
              SetDisplayInfo = function()
                return checkCFunc(__index.SetDisplayInfo)
              end,
              SetDoBlend = function()
                return checkCFunc(__index.SetDoBlend)
              end,
              SetDontSavePosition = function()
                return checkCFunc(__index.SetDontSavePosition)
              end,
              SetDrawLayerEnabled = function()
                return checkCFunc(__index.SetDrawLayerEnabled)
              end,
              SetFacing = function()
                return checkCFunc(__index.SetFacing)
              end,
              SetFixedFrameLevel = function()
                return checkCFunc(__index.SetFixedFrameLevel)
              end,
              SetFixedFrameStrata = function()
                return checkCFunc(__index.SetFixedFrameStrata)
              end,
              SetFlattensRenderLayers = function()
                return checkCFunc(__index.SetFlattensRenderLayers)
              end,
              SetFogColor = function()
                return checkCFunc(__index.SetFogColor)
              end,
              SetFogFar = function()
                return checkCFunc(__index.SetFogFar)
              end,
              SetFogNear = function()
                return checkCFunc(__index.SetFogNear)
              end,
              SetForbidden = function()
                return checkCFunc(__index.SetForbidden)
              end,
              SetFrameBuffer = function()
                return checkCFunc(__index.SetFrameBuffer)
              end,
              SetFrameLevel = function()
                return checkCFunc(__index.SetFrameLevel)
              end,
              SetFrameStrata = function()
                return checkCFunc(__index.SetFrameStrata)
              end,
              SetGlow = function()
                return checkCFunc(__index.SetGlow)
              end,
              SetHeight = function()
                return checkCFunc(__index.SetHeight)
              end,
              SetHitRectInsets = function()
                return checkCFunc(__index.SetHitRectInsets)
              end,
              SetHyperlinksEnabled = function()
                return checkCFunc(__index.SetHyperlinksEnabled)
              end,
              SetID = function()
                return checkCFunc(__index.SetID)
              end,
              SetIgnoreParentAlpha = function()
                return checkCFunc(__index.SetIgnoreParentAlpha)
              end,
              SetIgnoreParentScale = function()
                return checkCFunc(__index.SetIgnoreParentScale)
              end,
              SetItem = function()
                return checkCFunc(__index.SetItem)
              end,
              SetItemAppearance = function()
                return checkCFunc(__index.SetItemAppearance)
              end,
              SetKeepModelOnHide = function()
                return checkCFunc(__index.SetKeepModelOnHide)
              end,
              SetLight = function()
                return checkCFunc(__index.SetLight)
              end,
              SetMaxResize = function()
                return checkCFunc(__index.SetMaxResize)
              end,
              SetMinResize = function()
                return checkCFunc(__index.SetMinResize)
              end,
              SetModel = function()
                return checkCFunc(__index.SetModel)
              end,
              SetModelAlpha = function()
                return checkCFunc(__index.SetModelAlpha)
              end,
              SetModelDrawLayer = function()
                return checkCFunc(__index.SetModelDrawLayer)
              end,
              SetModelScale = function()
                return checkCFunc(__index.SetModelScale)
              end,
              SetMouseClickEnabled = function()
                return checkCFunc(__index.SetMouseClickEnabled)
              end,
              SetMouseMotionEnabled = function()
                return checkCFunc(__index.SetMouseMotionEnabled)
              end,
              SetMovable = function()
                return checkCFunc(__index.SetMovable)
              end,
              SetParent = function()
                return checkCFunc(__index.SetParent)
              end,
              SetParticlesEnabled = function()
                return checkCFunc(__index.SetParticlesEnabled)
              end,
              SetPaused = function()
                return checkCFunc(__index.SetPaused)
              end,
              SetPitch = function()
                return checkCFunc(__index.SetPitch)
              end,
              SetPoint = function()
                return checkCFunc(__index.SetPoint)
              end,
              SetPortraitZoom = function()
                return checkCFunc(__index.SetPortraitZoom)
              end,
              SetPosition = function()
                return checkCFunc(__index.SetPosition)
              end,
              SetPropagateKeyboardInput = function()
                return checkCFunc(__index.SetPropagateKeyboardInput)
              end,
              SetResizable = function()
                return checkCFunc(__index.SetResizable)
              end,
              SetRoll = function()
                return checkCFunc(__index.SetRoll)
              end,
              SetRotation = function()
                return checkCFunc(__index.SetRotation)
              end,
              SetScale = function()
                return checkCFunc(__index.SetScale)
              end,
              SetScript = function()
                return checkCFunc(__index.SetScript)
              end,
              SetSequence = function()
                return checkCFunc(__index.SetSequence)
              end,
              SetSequenceTime = function()
                return checkCFunc(__index.SetSequenceTime)
              end,
              SetShadowEffect = function()
                return checkCFunc(__index.SetShadowEffect)
              end,
              SetShown = function()
                return checkCFunc(__index.SetShown)
              end,
              SetSize = function()
                return checkCFunc(__index.SetSize)
              end,
              SetToplevel = function()
                return checkCFunc(__index.SetToplevel)
              end,
              SetTransform = function()
                return checkCFunc(__index.SetTransform)
              end,
              SetUnit = function()
                return checkCFunc(__index.SetUnit)
              end,
              SetUserPlaced = function()
                return checkCFunc(__index.SetUserPlaced)
              end,
              SetViewInsets = function()
                return checkCFunc(__index.SetViewInsets)
              end,
              SetViewTranslation = function()
                return checkCFunc(__index.SetViewTranslation)
              end,
              SetWidth = function()
                return checkCFunc(__index.SetWidth)
              end,
              Show = function()
                return checkCFunc(__index.Show)
              end,
              StartMoving = function()
                return checkCFunc(__index.StartMoving)
              end,
              StartSizing = function()
                return checkCFunc(__index.StartSizing)
              end,
              StopAnimKit = function()
                return checkCFunc(__index.StopAnimKit)
              end,
              StopAnimating = function()
                return checkCFunc(__index.StopAnimating)
              end,
              StopMovingOrSizing = function()
                return checkCFunc(__index.StopMovingOrSizing)
              end,
              TransformCameraSpaceToModelSpace = function()
                return checkCFunc(__index.TransformCameraSpaceToModelSpace)
              end,
              UnregisterAllEvents = function()
                return checkCFunc(__index.UnregisterAllEvents)
              end,
              UnregisterEvent = function()
                return checkCFunc(__index.UnregisterEvent)
              end,
              UseModelCenterToTransform = function()
                return checkCFunc(__index.UseModelCenterToTransform)
              end,
              ZeroCachedCenterXY = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.ZeroCachedCenterXY))
                  return
                end
                return checkCFunc(__index.ZeroCachedCenterXY)
              end,
            }
          end)
        end,
        Texture = function()
          local function factory()
            return CreateFrame('Frame'):CreateTexture()
          end
          return mkTests('Texture', factory, function(__index)
            return {
              AddMaskTexture = function()
                return checkCFunc(__index.AddMaskTexture)
              end,
              AdjustPointsOffset = function()
                return checkCFunc(__index.AdjustPointsOffset)
              end,
              CanChangeProtectedState = function()
                return checkCFunc(__index.CanChangeProtectedState)
              end,
              ClearAllPoints = function()
                return checkCFunc(__index.ClearAllPoints)
              end,
              ClearPointByName = function()
                return checkCFunc(__index.ClearPointByName)
              end,
              ClearPointsOffset = function()
                return checkCFunc(__index.ClearPointsOffset)
              end,
              CreateAnimationGroup = function()
                return checkCFunc(__index.CreateAnimationGroup)
              end,
              GetAlpha = function()
                return checkCFunc(__index.GetAlpha)
              end,
              GetAnimationGroups = function()
                return checkCFunc(__index.GetAnimationGroups)
              end,
              GetAtlas = function()
                return checkCFunc(__index.GetAtlas)
              end,
              GetBlendMode = function()
                return checkCFunc(__index.GetBlendMode)
              end,
              GetBottom = function()
                return checkCFunc(__index.GetBottom)
              end,
              GetCenter = function()
                return checkCFunc(__index.GetCenter)
              end,
              GetDebugName = function()
                return checkCFunc(__index.GetDebugName)
              end,
              GetDesaturation = function()
                return checkCFunc(__index.GetDesaturation)
              end,
              GetDrawLayer = function()
                return checkCFunc(__index.GetDrawLayer)
              end,
              GetEffectiveScale = function()
                return checkCFunc(__index.GetEffectiveScale)
              end,
              GetHeight = function()
                return checkCFunc(__index.GetHeight)
              end,
              GetHorizTile = function()
                return checkCFunc(__index.GetHorizTile)
              end,
              GetLeft = function()
                return checkCFunc(__index.GetLeft)
              end,
              GetMaskTexture = function()
                return checkCFunc(__index.GetMaskTexture)
              end,
              GetName = function()
                return checkCFunc(__index.GetName)
              end,
              GetNonBlocking = function()
                return checkCFunc(__index.GetNonBlocking)
              end,
              GetNumMaskTextures = function()
                return checkCFunc(__index.GetNumMaskTextures)
              end,
              GetNumPoints = function()
                return checkCFunc(__index.GetNumPoints)
              end,
              GetObjectType = function()
                return checkCFunc(__index.GetObjectType)
              end,
              GetParent = function()
                return checkCFunc(__index.GetParent)
              end,
              GetPoint = function()
                return checkCFunc(__index.GetPoint)
              end,
              GetPointByName = function()
                return checkCFunc(__index.GetPointByName)
              end,
              GetRect = function()
                return checkCFunc(__index.GetRect)
              end,
              GetRight = function()
                return checkCFunc(__index.GetRight)
              end,
              GetRotation = function()
                return checkCFunc(__index.GetRotation)
              end,
              GetScale = function()
                return checkCFunc(__index.GetScale)
              end,
              GetScaledRect = function()
                return checkCFunc(__index.GetScaledRect)
              end,
              GetSize = function()
                return checkCFunc(__index.GetSize)
              end,
              GetSourceLocation = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetSourceLocation))
                  return
                end
                return checkCFunc(__index.GetSourceLocation)
              end,
              GetTexCoord = function()
                return checkCFunc(__index.GetTexCoord)
              end,
              GetTexelSnappingBias = function()
                return checkCFunc(__index.GetTexelSnappingBias)
              end,
              GetTexture = function()
                return checkCFunc(__index.GetTexture)
              end,
              GetTextureFileID = function()
                return checkCFunc(__index.GetTextureFileID)
              end,
              GetTextureFilePath = function()
                return checkCFunc(__index.GetTextureFilePath)
              end,
              GetTop = function()
                return checkCFunc(__index.GetTop)
              end,
              GetVertTile = function()
                return checkCFunc(__index.GetVertTile)
              end,
              GetVertexColor = function()
                return checkCFunc(__index.GetVertexColor)
              end,
              GetVertexOffset = function()
                return checkCFunc(__index.GetVertexOffset)
              end,
              GetWidth = function()
                return checkCFunc(__index.GetWidth)
              end,
              Hide = function()
                return checkCFunc(__index.Hide)
              end,
              IsAnchoringRestricted = function()
                return checkCFunc(__index.IsAnchoringRestricted)
              end,
              IsDesaturated = function()
                return checkCFunc(__index.IsDesaturated)
              end,
              IsDragging = function()
                return checkCFunc(__index.IsDragging)
              end,
              IsForbidden = function()
                return checkCFunc(__index.IsForbidden)
              end,
              IsIgnoringParentAlpha = function()
                return checkCFunc(__index.IsIgnoringParentAlpha)
              end,
              IsIgnoringParentScale = function()
                return checkCFunc(__index.IsIgnoringParentScale)
              end,
              IsMouseOver = function()
                return checkCFunc(__index.IsMouseOver)
              end,
              IsObjectLoaded = function()
                return checkCFunc(__index.IsObjectLoaded)
              end,
              IsObjectType = function()
                return checkCFunc(__index.IsObjectType)
              end,
              IsProtected = function()
                return checkCFunc(__index.IsProtected)
              end,
              IsRectValid = function()
                return checkCFunc(__index.IsRectValid)
              end,
              IsShown = function()
                return checkCFunc(__index.IsShown)
              end,
              IsSnappingToPixelGrid = function()
                return checkCFunc(__index.IsSnappingToPixelGrid)
              end,
              IsVisible = function()
                return checkCFunc(__index.IsVisible)
              end,
              RemoveMaskTexture = function()
                return checkCFunc(__index.RemoveMaskTexture)
              end,
              SetAllPoints = function()
                return checkCFunc(__index.SetAllPoints)
              end,
              SetAlpha = function()
                return checkCFunc(__index.SetAlpha)
              end,
              SetAtlas = function()
                return checkCFunc(__index.SetAtlas)
              end,
              SetBlendMode = function()
                return checkCFunc(__index.SetBlendMode)
              end,
              SetColorTexture = function()
                return checkCFunc(__index.SetColorTexture)
              end,
              SetDesaturated = function()
                return checkCFunc(__index.SetDesaturated)
              end,
              SetDesaturation = function()
                return checkCFunc(__index.SetDesaturation)
              end,
              SetDrawLayer = function()
                return checkCFunc(__index.SetDrawLayer)
              end,
              SetForbidden = function()
                return checkCFunc(__index.SetForbidden)
              end,
              SetGradient = function()
                return checkCFunc(__index.SetGradient)
              end,
              SetGradientAlpha = function()
                return checkCFunc(__index.SetGradientAlpha)
              end,
              SetHeight = function()
                return checkCFunc(__index.SetHeight)
              end,
              SetHorizTile = function()
                return checkCFunc(__index.SetHorizTile)
              end,
              SetIgnoreParentAlpha = function()
                return checkCFunc(__index.SetIgnoreParentAlpha)
              end,
              SetIgnoreParentScale = function()
                return checkCFunc(__index.SetIgnoreParentScale)
              end,
              SetMask = function()
                return checkCFunc(__index.SetMask)
              end,
              SetNonBlocking = function()
                return checkCFunc(__index.SetNonBlocking)
              end,
              SetParent = function()
                return checkCFunc(__index.SetParent)
              end,
              SetPoint = function()
                return checkCFunc(__index.SetPoint)
              end,
              SetRotation = function()
                return checkCFunc(__index.SetRotation)
              end,
              SetScale = function()
                return checkCFunc(__index.SetScale)
              end,
              SetShown = function()
                return checkCFunc(__index.SetShown)
              end,
              SetSize = function()
                return checkCFunc(__index.SetSize)
              end,
              SetSnapToPixelGrid = function()
                return checkCFunc(__index.SetSnapToPixelGrid)
              end,
              SetTexCoord = function()
                return checkCFunc(__index.SetTexCoord)
              end,
              SetTexelSnappingBias = function()
                return checkCFunc(__index.SetTexelSnappingBias)
              end,
              SetTexture = function()
                return checkCFunc(__index.SetTexture)
              end,
              SetVertTile = function()
                return checkCFunc(__index.SetVertTile)
              end,
              SetVertexColor = function()
                return checkCFunc(__index.SetVertexColor)
              end,
              SetVertexOffset = function()
                return checkCFunc(__index.SetVertexOffset)
              end,
              SetWidth = function()
                return checkCFunc(__index.SetWidth)
              end,
              Show = function()
                return checkCFunc(__index.Show)
              end,
              StopAnimating = function()
                return checkCFunc(__index.StopAnimating)
              end,
            }
          end)
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
          local function factory()
            return assertCreateFrame('UnitPositionFrame')
          end
          return mkTests('UnitPositionFrame', factory, function(__index)
            return {
              AddUnit = function()
                return checkCFunc(__index.AddUnit)
              end,
              AddUnitAtlas = function()
                return checkCFunc(__index.AddUnitAtlas)
              end,
              AddUnitFileID = function()
                return checkCFunc(__index.AddUnitFileID)
              end,
              AdjustPointsOffset = function()
                return checkCFunc(__index.AdjustPointsOffset)
              end,
              CanChangeAttribute = function()
                return checkCFunc(__index.CanChangeAttribute)
              end,
              CanChangeProtectedState = function()
                return checkCFunc(__index.CanChangeProtectedState)
              end,
              ClearAllPoints = function()
                return checkCFunc(__index.ClearAllPoints)
              end,
              ClearPointByName = function()
                return checkCFunc(__index.ClearPointByName)
              end,
              ClearPointsOffset = function()
                return checkCFunc(__index.ClearPointsOffset)
              end,
              ClearUnits = function()
                return checkCFunc(__index.ClearUnits)
              end,
              CreateAnimationGroup = function()
                return checkCFunc(__index.CreateAnimationGroup)
              end,
              CreateFontString = function()
                return checkCFunc(__index.CreateFontString)
              end,
              CreateLine = function()
                return checkCFunc(__index.CreateLine)
              end,
              CreateMaskTexture = function()
                return checkCFunc(__index.CreateMaskTexture)
              end,
              CreateTexture = function()
                return checkCFunc(__index.CreateTexture)
              end,
              DesaturateHierarchy = function()
                return checkCFunc(__index.DesaturateHierarchy)
              end,
              DisableDrawLayer = function()
                return checkCFunc(__index.DisableDrawLayer)
              end,
              DoesClipChildren = function()
                return checkCFunc(__index.DoesClipChildren)
              end,
              EnableDrawLayer = function()
                return checkCFunc(__index.EnableDrawLayer)
              end,
              EnableGamePadButton = function()
                return checkCFunc(__index.EnableGamePadButton)
              end,
              EnableGamePadStick = function()
                return checkCFunc(__index.EnableGamePadStick)
              end,
              EnableKeyboard = function()
                return checkCFunc(__index.EnableKeyboard)
              end,
              EnableMouse = function()
                return checkCFunc(__index.EnableMouse)
              end,
              EnableMouseWheel = function()
                return checkCFunc(__index.EnableMouseWheel)
              end,
              ExecuteAttribute = function()
                return checkCFunc(__index.ExecuteAttribute)
              end,
              FinalizeUnits = function()
                return checkCFunc(__index.FinalizeUnits)
              end,
              GetAlpha = function()
                return checkCFunc(__index.GetAlpha)
              end,
              GetAnimationGroups = function()
                return checkCFunc(__index.GetAnimationGroups)
              end,
              GetAttribute = function()
                return checkCFunc(__index.GetAttribute)
              end,
              GetBottom = function()
                return checkCFunc(__index.GetBottom)
              end,
              GetBoundsRect = function()
                return checkCFunc(__index.GetBoundsRect)
              end,
              GetCenter = function()
                return checkCFunc(__index.GetCenter)
              end,
              GetChildren = function()
                return checkCFunc(__index.GetChildren)
              end,
              GetClampRectInsets = function()
                return checkCFunc(__index.GetClampRectInsets)
              end,
              GetDebugName = function()
                return checkCFunc(__index.GetDebugName)
              end,
              GetDepth = function()
                return checkCFunc(__index.GetDepth)
              end,
              GetDontSavePosition = function()
                return checkCFunc(__index.GetDontSavePosition)
              end,
              GetEffectiveAlpha = function()
                return checkCFunc(__index.GetEffectiveAlpha)
              end,
              GetEffectiveDepth = function()
                return checkCFunc(__index.GetEffectiveDepth)
              end,
              GetEffectiveScale = function()
                return checkCFunc(__index.GetEffectiveScale)
              end,
              GetEffectivelyFlattensRenderLayers = function()
                return checkCFunc(__index.GetEffectivelyFlattensRenderLayers)
              end,
              GetFlattensRenderLayers = function()
                return checkCFunc(__index.GetFlattensRenderLayers)
              end,
              GetFrameLevel = function()
                return checkCFunc(__index.GetFrameLevel)
              end,
              GetFrameStrata = function()
                return checkCFunc(__index.GetFrameStrata)
              end,
              GetHeight = function()
                return checkCFunc(__index.GetHeight)
              end,
              GetHitRectInsets = function()
                return checkCFunc(__index.GetHitRectInsets)
              end,
              GetHyperlinksEnabled = function()
                return checkCFunc(__index.GetHyperlinksEnabled)
              end,
              GetID = function()
                return checkCFunc(__index.GetID)
              end,
              GetLeft = function()
                return checkCFunc(__index.GetLeft)
              end,
              GetMaxResize = function()
                return checkCFunc(__index.GetMaxResize)
              end,
              GetMinResize = function()
                return checkCFunc(__index.GetMinResize)
              end,
              GetMouseOverUnits = function()
                return checkCFunc(__index.GetMouseOverUnits)
              end,
              GetName = function()
                return checkCFunc(__index.GetName)
              end,
              GetNumChildren = function()
                return checkCFunc(__index.GetNumChildren)
              end,
              GetNumPoints = function()
                return checkCFunc(__index.GetNumPoints)
              end,
              GetNumRegions = function()
                return checkCFunc(__index.GetNumRegions)
              end,
              GetObjectType = function()
                return checkCFunc(__index.GetObjectType)
              end,
              GetParent = function()
                return checkCFunc(__index.GetParent)
              end,
              GetPlayerPingScale = function()
                return checkCFunc(__index.GetPlayerPingScale)
              end,
              GetPoint = function()
                return checkCFunc(__index.GetPoint)
              end,
              GetPointByName = function()
                return checkCFunc(__index.GetPointByName)
              end,
              GetPropagateKeyboardInput = function()
                return checkCFunc(__index.GetPropagateKeyboardInput)
              end,
              GetRect = function()
                return checkCFunc(__index.GetRect)
              end,
              GetRegions = function()
                return checkCFunc(__index.GetRegions)
              end,
              GetRight = function()
                return checkCFunc(__index.GetRight)
              end,
              GetScale = function()
                return checkCFunc(__index.GetScale)
              end,
              GetScaledRect = function()
                return checkCFunc(__index.GetScaledRect)
              end,
              GetScript = function()
                return checkCFunc(__index.GetScript)
              end,
              GetSize = function()
                return checkCFunc(__index.GetSize)
              end,
              GetSourceLocation = function()
                if badProduct('wow,wow_beta,wowt') then
                  assertEquals('nil', type(__index.GetSourceLocation))
                  return
                end
                return checkCFunc(__index.GetSourceLocation)
              end,
              GetTop = function()
                return checkCFunc(__index.GetTop)
              end,
              GetUiMapID = function()
                return checkCFunc(__index.GetUiMapID)
              end,
              GetWidth = function()
                return checkCFunc(__index.GetWidth)
              end,
              HasFixedFrameLevel = function()
                return checkCFunc(__index.HasFixedFrameLevel)
              end,
              HasFixedFrameStrata = function()
                return checkCFunc(__index.HasFixedFrameStrata)
              end,
              HasScript = function()
                return checkCFunc(__index.HasScript)
              end,
              Hide = function()
                return checkCFunc(__index.Hide)
              end,
              HookScript = function()
                return checkCFunc(__index.HookScript)
              end,
              IgnoreDepth = function()
                return checkCFunc(__index.IgnoreDepth)
              end,
              IsAnchoringRestricted = function()
                return checkCFunc(__index.IsAnchoringRestricted)
              end,
              IsClampedToScreen = function()
                return checkCFunc(__index.IsClampedToScreen)
              end,
              IsDragging = function()
                return checkCFunc(__index.IsDragging)
              end,
              IsEventRegistered = function()
                return checkCFunc(__index.IsEventRegistered)
              end,
              IsForbidden = function()
                return checkCFunc(__index.IsForbidden)
              end,
              IsGamePadButtonEnabled = function()
                return checkCFunc(__index.IsGamePadButtonEnabled)
              end,
              IsGamePadStickEnabled = function()
                return checkCFunc(__index.IsGamePadStickEnabled)
              end,
              IsIgnoringDepth = function()
                return checkCFunc(__index.IsIgnoringDepth)
              end,
              IsIgnoringParentAlpha = function()
                return checkCFunc(__index.IsIgnoringParentAlpha)
              end,
              IsIgnoringParentScale = function()
                return checkCFunc(__index.IsIgnoringParentScale)
              end,
              IsKeyboardEnabled = function()
                return checkCFunc(__index.IsKeyboardEnabled)
              end,
              IsMouseClickEnabled = function()
                return checkCFunc(__index.IsMouseClickEnabled)
              end,
              IsMouseEnabled = function()
                return checkCFunc(__index.IsMouseEnabled)
              end,
              IsMouseMotionEnabled = function()
                return checkCFunc(__index.IsMouseMotionEnabled)
              end,
              IsMouseOver = function()
                return checkCFunc(__index.IsMouseOver)
              end,
              IsMouseWheelEnabled = function()
                return checkCFunc(__index.IsMouseWheelEnabled)
              end,
              IsMovable = function()
                return checkCFunc(__index.IsMovable)
              end,
              IsObjectLoaded = function()
                return checkCFunc(__index.IsObjectLoaded)
              end,
              IsObjectType = function()
                return checkCFunc(__index.IsObjectType)
              end,
              IsProtected = function()
                return checkCFunc(__index.IsProtected)
              end,
              IsRectValid = function()
                return checkCFunc(__index.IsRectValid)
              end,
              IsResizable = function()
                return checkCFunc(__index.IsResizable)
              end,
              IsShown = function()
                return checkCFunc(__index.IsShown)
              end,
              IsToplevel = function()
                return checkCFunc(__index.IsToplevel)
              end,
              IsUserPlaced = function()
                return checkCFunc(__index.IsUserPlaced)
              end,
              IsVisible = function()
                return checkCFunc(__index.IsVisible)
              end,
              Lower = function()
                return checkCFunc(__index.Lower)
              end,
              Raise = function()
                return checkCFunc(__index.Raise)
              end,
              RegisterAllEvents = function()
                return checkCFunc(__index.RegisterAllEvents)
              end,
              RegisterEvent = function()
                return checkCFunc(__index.RegisterEvent)
              end,
              RegisterForDrag = function()
                return checkCFunc(__index.RegisterForDrag)
              end,
              RegisterUnitEvent = function()
                return checkCFunc(__index.RegisterUnitEvent)
              end,
              RotateTextures = function()
                return checkCFunc(__index.RotateTextures)
              end,
              SetAllPoints = function()
                return checkCFunc(__index.SetAllPoints)
              end,
              SetAlpha = function()
                return checkCFunc(__index.SetAlpha)
              end,
              SetAttribute = function()
                return checkCFunc(__index.SetAttribute)
              end,
              SetAttributeNoHandler = function()
                return checkCFunc(__index.SetAttributeNoHandler)
              end,
              SetClampRectInsets = function()
                return checkCFunc(__index.SetClampRectInsets)
              end,
              SetClampedToScreen = function()
                return checkCFunc(__index.SetClampedToScreen)
              end,
              SetClipsChildren = function()
                return checkCFunc(__index.SetClipsChildren)
              end,
              SetDepth = function()
                return checkCFunc(__index.SetDepth)
              end,
              SetDontSavePosition = function()
                return checkCFunc(__index.SetDontSavePosition)
              end,
              SetDrawLayerEnabled = function()
                return checkCFunc(__index.SetDrawLayerEnabled)
              end,
              SetFixedFrameLevel = function()
                return checkCFunc(__index.SetFixedFrameLevel)
              end,
              SetFixedFrameStrata = function()
                return checkCFunc(__index.SetFixedFrameStrata)
              end,
              SetFlattensRenderLayers = function()
                return checkCFunc(__index.SetFlattensRenderLayers)
              end,
              SetForbidden = function()
                return checkCFunc(__index.SetForbidden)
              end,
              SetFrameBuffer = function()
                return checkCFunc(__index.SetFrameBuffer)
              end,
              SetFrameLevel = function()
                return checkCFunc(__index.SetFrameLevel)
              end,
              SetFrameStrata = function()
                return checkCFunc(__index.SetFrameStrata)
              end,
              SetHeight = function()
                return checkCFunc(__index.SetHeight)
              end,
              SetHitRectInsets = function()
                return checkCFunc(__index.SetHitRectInsets)
              end,
              SetHyperlinksEnabled = function()
                return checkCFunc(__index.SetHyperlinksEnabled)
              end,
              SetID = function()
                return checkCFunc(__index.SetID)
              end,
              SetIgnoreParentAlpha = function()
                return checkCFunc(__index.SetIgnoreParentAlpha)
              end,
              SetIgnoreParentScale = function()
                return checkCFunc(__index.SetIgnoreParentScale)
              end,
              SetMaxResize = function()
                return checkCFunc(__index.SetMaxResize)
              end,
              SetMinResize = function()
                return checkCFunc(__index.SetMinResize)
              end,
              SetMouseClickEnabled = function()
                return checkCFunc(__index.SetMouseClickEnabled)
              end,
              SetMouseMotionEnabled = function()
                return checkCFunc(__index.SetMouseMotionEnabled)
              end,
              SetMovable = function()
                return checkCFunc(__index.SetMovable)
              end,
              SetParent = function()
                return checkCFunc(__index.SetParent)
              end,
              SetPlayerPingScale = function()
                return checkCFunc(__index.SetPlayerPingScale)
              end,
              SetPlayerPingTexture = function()
                return checkCFunc(__index.SetPlayerPingTexture)
              end,
              SetPoint = function()
                return checkCFunc(__index.SetPoint)
              end,
              SetPropagateKeyboardInput = function()
                return checkCFunc(__index.SetPropagateKeyboardInput)
              end,
              SetResizable = function()
                return checkCFunc(__index.SetResizable)
              end,
              SetScale = function()
                return checkCFunc(__index.SetScale)
              end,
              SetScript = function()
                return checkCFunc(__index.SetScript)
              end,
              SetShown = function()
                return checkCFunc(__index.SetShown)
              end,
              SetSize = function()
                return checkCFunc(__index.SetSize)
              end,
              SetToplevel = function()
                return checkCFunc(__index.SetToplevel)
              end,
              SetUiMapID = function()
                return checkCFunc(__index.SetUiMapID)
              end,
              SetUnitColor = function()
                return checkCFunc(__index.SetUnitColor)
              end,
              SetUserPlaced = function()
                return checkCFunc(__index.SetUserPlaced)
              end,
              SetWidth = function()
                return checkCFunc(__index.SetWidth)
              end,
              Show = function()
                return checkCFunc(__index.Show)
              end,
              StartMoving = function()
                return checkCFunc(__index.StartMoving)
              end,
              StartPlayerPing = function()
                return checkCFunc(__index.StartPlayerPing)
              end,
              StartSizing = function()
                return checkCFunc(__index.StartSizing)
              end,
              StopAnimating = function()
                return checkCFunc(__index.StopAnimating)
              end,
              StopMovingOrSizing = function()
                return checkCFunc(__index.StopMovingOrSizing)
              end,
              StopPlayerPing = function()
                return checkCFunc(__index.StopPlayerPing)
              end,
              UnregisterAllEvents = function()
                return checkCFunc(__index.UnregisterAllEvents)
              end,
              UnregisterEvent = function()
                return checkCFunc(__index.UnregisterEvent)
              end,
            }
          end)
        end,
      }
    end,
  }
end
