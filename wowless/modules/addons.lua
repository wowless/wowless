return function(datalua, envmodule, events, loader, loadercfg, log, sqlitedb)
  local addons = {}
  local tocversion = datalua.build.tocversion
  local function GetAddOnInfo(addon)
    if not addon then
      return 'FIXME', nil, nil, false, 'MISSING', 'INSECURE'
    else
      local name = addon.name
      local secure = addon.name:sub(1, 9) == 'Blizzard_' and 'SECURE' or 'INSECURE'
      return name, addon.attrs.Title or '', addon.attrs.Notes or '', true, '', secure
    end
  end

  local function GetAddOnInterfaceVersion(addon)
    if not addon then
      return 0
    end
    local v = addon.interface or 0
    return v <= tocversion and v or 0
  end

  local function GetNumAddOns()
    return #addons
  end

  local genv = envmodule.genv
  local secureenv = envmodule.secureenv
  local SendEvent = events.SendEvent

  local rootDir = loadercfg.rootDir
  local product = datalua.product
  assert(product, 'addons requires a product')
  local otherAddonDirs = loadercfg.otherAddonDirs or {}

  local path = require('path')
  local util = require('wowless.util')
  local readFile = util.readfile

  local build = datalua.build
  local gametype = build.gametype
  local family = require('runtime.gametypes')[gametype].family
  local tocutil = require('wowless.toc')
  local tocsuffixes = tocutil.suffixes[gametype]

  local function parseToc(tocFile, content)
    local dir = path.dirname(tocFile)
    local toc = tocutil.parse(gametype, content)
    for i, f in ipairs(toc.files) do
      toc.files[i] = path.join(dir, f)
    end
    return toc
  end

  local function resolveTocDir(tocDir)
    log(1, 'resolving %s', tocDir)
    local base = path.basename(tocDir)
    for _, suffix in ipairs(tocsuffixes) do
      local tocFile = path.join(tocDir, base .. suffix .. '.toc')
      local success, content = pcall(readFile, tocFile)
      if success then
        log(1, 'using toc %s', tocFile)
        return parseToc(tocFile, content)
      end
    end
    log(1, 'no valid toc for %s', tocDir)
    return nil
  end

  local function resolveBindingsXml(tocDir)
    log(1, 'resolving bindings for %s', tocDir)
    for _, suffix in ipairs(tocsuffixes) do
      local bindingsFile = path.join(tocDir, 'Bindings' .. suffix .. '.xml')
      local success, content = pcall(readFile, bindingsFile)
      if success then
        log(1, 'using bindings %s', bindingsFile)
        return bindingsFile, content
      end
    end
    log(1, 'no valid bindings for %s', tocDir)
    return nil
  end

  local addonData = addons

  local function initAddons()
    local lfs = require('lfs')
    local function maybeAdd(dir, signed)
      local name = path.basename(dir)
      local key = name:lower()
      if not addonData[key] then
        local addon = resolveTocDir(dir)
        if addon then
          addon.name = name
          addon.signed = signed
          addon.dir = dir
          addon.revwiths = {}
          addon.bindings = resolveBindingsXml(dir)
          addonData[key] = addon
          table.insert(addonData, addon)
        end
      end
    end
    local function isdir(d)
      return lfs.attributes(d, 'mode') == 'directory'
    end
    local function maybeAddAll(dir)
      if isdir(dir) then
        for d in lfs.dir(dir) do
          if d ~= '.' and d ~= '..' then
            local dd = path.join(dir, d)
            if isdir(dd) then
              maybeAdd(dd)
            end
          end
        end
      end
    end
    if rootDir then
      local toclist = readFile(path.join(rootDir, 'Interface', 'ui-toc-list.txt'))
      for filepath in toclist:gmatch('[^\r\n]+') do
        maybeAdd(path.join(rootDir, path.dirname(filepath)), true)
      end
      local genaddonlist = readFile(path.join(rootDir, 'Interface', 'ui-gen-addon-list.txt'))
      for filepath in genaddonlist:gmatch('[^\r\n]+') do
        if filepath:sub(-4) == '.toc' then
          maybeAdd(path.join(rootDir, path.dirname(filepath)), true)
        end
      end
    end
    for _, d in ipairs(otherAddonDirs) do
      local dir = path.dirname(d)
      maybeAddAll(dir == '' and '.' or dir)
    end
    for _, addon in ipairs(addonData) do
      for name in string.gmatch(addon.attrs.LoadWith or '', '[^, ]+') do
        local dep = addonData[name:lower()]
        if not dep then
          log(1, 'skipping unknown addon %q in LoadWith of %q', name, addon.name)
        else
          table.insert(dep.revwiths, addon.name)
        end
      end
    end
  end

  local function doLoadAddon(addonName, forceSecure)
    local toc = addonData[addonName:lower()]
    if not toc then
      error('unknown addon ' .. addonName)
    end
    addonName = toc.name
    if toc.attrs.AllowLoad and toc.attrs.AllowLoad:lower() == 'glue' then
      log(1, 'skipping glue-only addon %s', addonName)
      return
    end
    if forceSecure then
      if not toc.loaded then
        log(1, 'UseSecureEnvironment dep addon %s not yet loaded insecurely, loading', addonName)
        doLoadAddon(addonName, false)
      end
      if toc.secdeploaded then
        log(1, 'UseSecureEnvironment dep addon %s is already loaded, skipping', addonName)
        return
      end
      if toc.secdeploadattempted then
        log(1, 'UseSecureEnvironment dep addon %s has a load pending already, skipping', addonName)
        return
      end
      toc.secdeploadattempted = true
    else
      if toc.loaded then
        log(1, 'addon %s is already loaded, skipping', addonName)
        return
      end
      if toc.loadattempted then
        log(1, 'addon %s has a load pending already, skipping', addonName)
        return
      end
      toc.loadattempted = true
    end
    local useSecureEnv = forceSecure or toc.attrs.UseSecureEnvironment == '1'
    log(1, 'loading addon dependencies for %s', addonName)
    for _, dep in ipairs(toc.deps) do
      doLoadAddon(dep, useSecureEnv)
    end
    for _, dep in ipairs(toc.optionaldeps) do
      if addonData[dep:lower()] then
        doLoadAddon(dep, useSecureEnv)
      end
    end
    local kindstr = forceSecure and ' (secure dependency)' or useSecureEnv and ' (secure)' or ''
    log(1, 'loading addon files for %s%s', addonName, kindstr)
    local addonEnv = toc.attrs.SuppressLocalTableRef ~= '1' and {} or nil
    local loadFile = loader.forAddon(addonName, addonEnv, toc.dir, useSecureEnv, forceSecure)
    for _, file in ipairs(toc.files) do
      loadFile(file)
    end
    if toc.bindings then
      loadFile(toc.bindings)
      SendEvent('UPDATE_BINDINGS')
    end
    loadFile(('out/%s/SavedVariables/%s.lua'):format(product, addonName), toc.signed and 'SavedVariables' or nil)
    if forceSecure then
      toc.secdeploaded = true
    else
      toc.loaded = true
    end
    log(1, 'done loading %s%s', addonName, kindstr)
    SendEvent('ADDON_LOADED', addonName, not not toc.bindings)
    for _, revwith in ipairs(toc.revwiths) do
      log(1, 'processing LoadWith %q -> %q', addonName, revwith)
      doLoadAddon(revwith)
    end
  end

  local function loadAddon(addonName)
    local success, msg = pcall(doLoadAddon, addonName)
    if success then
      return true, nil
    else
      log(1, 'loading %s failed: %s', addonName, tostring(msg))
      return false, 'LOAD_FAILED'
    end
  end

  local gttokens = {
    [family:lower()] = true,
    [gametype:lower()] = true,
  }

  local function isLoadable(toc)
    local a = datalua.cvars.agentuid.value
    if toc.attrs.OnlyBetaAndPTR == '1' and a ~= 'wow_ptr' and a ~= 'wow_beta' then
      return false
    end
    if not toc.attrs.AllowLoadGameType then
      return true
    end
    for gt in string.gmatch(toc.attrs.AllowLoadGameType, '[^, ]+') do
      if gttokens[gt] then
        return true
      end
    end
    return false
  end

  local function loadFrameXml()
    log(1, 'initializing framexml')
    for tag, text in sqlitedb:urows('SELECT BaseTag, TagText_lang FROM GlobalStrings') do
      genv[tag] = text
      secureenv[tag] = text
    end
    local blizzardAddons = {}
    for _, toc in ipairs(addonData) do
      if toc.signed and toc.attrs.LoadOnDemand ~= '1' and isLoadable(toc) then
        table.insert(blizzardAddons, toc.name:lower())
      end
    end
    log(1, 'loading loadfirst/secureenv framexml addons')
    for _, name in ipairs(blizzardAddons) do
      local a = addonData[name].attrs
      if a.LoadFirst == '1' or a.UseSecureEnvironment == '1' then
        loadAddon(name)
      end
    end
    log(1, 'loading remaining framexml addons')
    for _, name in ipairs(blizzardAddons) do
      loadAddon(name)
    end
    log(1, 'done loading framexml')
  end

  local function saveAllVariables()
    local w = require('tools.prettywrite')
    for _, v in pairs(addonData) do
      if v.loaded then
        local t = {}
        for _, attr in ipairs({ 'savedvariables', 'savedvariablespercharacter' }) do
          for _, var in ipairs(v[attr] or {}) do
            local val = genv[var]
            if val ~= nil then
              table.insert(t, var)
              table.insert(t, ' = ')
              table.insert(t, type(val) == 'table' and w(val) or tostring(val))
              table.insert(t, '\n')
            end
          end
        end
        if next(t) then
          local fn = ('out/%s/SavedVariables/%s.lua'):format(product, v.name)
          assert(require('pl.dir').makepath(path.dirname(fn)))
          assert(require('pl.file').write(fn, table.concat(t)))
        end
      end
    end
  end

  return {
    addons = addons,
    GetAddOnInfo = GetAddOnInfo,
    GetAddOnInterfaceVersion = GetAddOnInterfaceVersion,
    GetNumAddOns = GetNumAddOns,
    initAddons = initAddons,
    loadAddon = loadAddon,
    loadFrameXml = loadFrameXml,
    saveAllVariables = saveAllVariables,
  }
end
