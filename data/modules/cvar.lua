local cvarDefaults = {
  cameraSmoothStyle = '0',
  cameraSmoothTrackingStyle = '0',
  chatStyle = 'classic',
  lastTalkedToGM = '',
  minimapZoom = '1',
  NamePlateClassificationScale = '1',
  NamePlateHorizontalScale = '1',
  nameplateMotion = '0',
  NamePlateVerticalScale = '1',
  partyBackgroundOpacity = '1',
  spellActivationOverlayOpacity = '1',
  remoteTextToSpeechVoice = '1',
  timeMgrAlarmTime = '0',
  whisperMode = 'inline',
}

local cvars = {}

local function GetCVar(var)
  return cvars[var] or cvarDefaults[var]
end

return {
  api = {
    GetCVar = GetCVar,
    GetCVarBool = function(var)
      return GetCVar(var) == "1"
    end,
    GetCVarDefault = function(var)
      return cvarDefaults[var]
    end,
    RegisterCVar = function(var, value)
      cvars[var] = value
    end,
    SetCVar = function(var, value)
      cvars[var] = value
    end,
  },
  state = {
    current = cvars,
    defaults = cvarDefaults,
  }
}
