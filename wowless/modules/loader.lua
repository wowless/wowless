return function(addons, datalua, envmodule, events, loadercfg, log, xmleval)
  local genv = envmodule.genv
  local SendEvent = events.SendEvent

  local rootDir = loadercfg.rootDir
  local product = datalua.product
  assert(product, 'loader requires a product')
  local otherAddonDirs = loadercfg.otherAddonDirs or {}
  local signedAddonDirs = loadercfg.signedAddonDirs or {}

  local path = require('path')
  local readFile = require('wowless.util').readfile

  local function forAddon(addonName, addonEnv, addonRoot, useSecureEnv)
    return function(filename, closureTaint, secondaryFileName)
      return xmleval.LoadFile(addonName, addonEnv, addonRoot, useSecureEnv, filename, closureTaint, secondaryFileName)
    end
  end

  local build = datalua.build
  local gametype = build.gametype
  local family = require('runtime.gametypes')[gametype].family
  local tocutil = require('wowless.toc')
  local tocsuffixes = tocutil.suffixes[gametype]

  local function parseToc(tocFile, content)
    local dir = path.dirname(tocFile)
    local toc = tocutil.parse(gametype, content)
    for i, f in ipairs(toc.files) do
      toc.files[i].name = path.join(dir, f.name)
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

  local addonData = addons.addons

  local gttokens = {
    [family:lower()] = true,
    [gametype:lower()] = true,
  }

  local function isLoadable(addon)
    local a = datalua.cvars.agentuid.default
    if addon.attrs.OnlyBetaAndPTR == '1' and a ~= 'wow_ptr' and a ~= 'wow_beta' then
      return false
    end
    if addon.attrs.AllowLoad and addon.attrs.AllowLoad:lower() == 'glue' then
      return false
    end
    if not addon.attrs.AllowLoadGameType then
      return true
    end
    for gt in string.gmatch(addon.attrs.AllowLoadGameType, '[^, ]+') do
      if gttokens[gt] then
        return true
      end
    end
    return false
  end

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
          addon.onlysecure = signed and addon.attrs.UseSecureEnvironment == '1'
          addon.loadfirst = signed and (addon.onlysecure or addon.attrs.LoadFirst == '1')
          addon.loadondemand = addon.attrs.LoadOnDemand == '1'
          addon.loadable = isLoadable(addon)
          addon.env = addon.attrs.SuppressLocalTableRef ~= '1' and {} or nil
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
    for _, d in ipairs(signedAddonDirs) do
      maybeAdd(d, true)
    end
    for _, d in ipairs(otherAddonDirs) do
      local dir = path.dirname(d)
      maybeAddAll(dir == '' and '.' or dir)
    end
    local allrevdeps = {}
    for _, addon in ipairs(addonData) do
      allrevdeps[addon] = {}
    end
    local q = {}
    for _, addon in ipairs(addonData) do
      for _, depname in ipairs(addon.deps) do
        local dep = addonData[depname:lower()]
        if not dep then
          addon.loadable = false
        else
          allrevdeps[dep][addon] = true
        end
      end
      if not addon.loadable then
        table.insert(q, addon)
      end
    end
    while #q > 0 do
      local bad = table.remove(q)
      for revdep in pairs(allrevdeps[bad]) do
        if revdep.loadable then
          revdep.loadable = false
          table.insert(q, revdep)
        end
      end
    end
    local loadables = {}
    for _, addon in ipairs(addonData) do
      if not addon.loadable then
        log(1, 'addon %q is not loadable', addon.name)
      else
        table.insert(loadables, addon)
      end
    end
    for _, addon in ipairs(loadables) do
      local deps = {}
      for _, depname in ipairs(addon.deps) do
        table.insert(deps, (assert(addonData[depname:lower()], depname)))
      end
      addon.deps = deps
      local optionaldeps = {}
      for _, depname in ipairs(addon.optionaldeps) do
        local dep = addonData[depname:lower()]
        if not dep then
          log(1, 'skipping unknown addon %q in optional deps of %q', depname, addon.name)
        elseif not dep.loadable then
          log(1, 'skipping unloadable addon %q in optional deps of %q', depname, addon.name)
        else
          table.insert(optionaldeps, dep)
        end
      end
      addon.optionaldeps = optionaldeps
      for name in string.gmatch(addon.attrs.LoadWith or '', '[^, ]+') do
        local dep = addonData[name:lower()]
        if not dep then
          log(1, 'skipping unknown addon %q in LoadWith of %q', name, addon.name)
        elseif not dep.loadable then
          log(1, 'skipping unloadable addon %q in LoadWith of %q', name, addon.name)
        else
          table.insert(dep.revwiths, addon)
        end
      end
    end
    return loadables
  end

  local function doLoadAddon(addon, forceSecure)
    local addonName = addon.name
    assert(addon.loadable, addonName)
    if forceSecure then
      if not addon.loaded then
        log(1, 'UseSecureEnvironment dep addon %s not yet loaded insecurely, loading', addonName)
        doLoadAddon(addon, false)
      end
      if addon.secdeploaded then
        log(1, 'UseSecureEnvironment dep addon %s is already loaded, skipping', addonName)
        return
      end
      if addon.secdeploadattempted then
        log(1, 'UseSecureEnvironment dep addon %s has a load pending already, skipping', addonName)
        return
      end
      addon.secdeploadattempted = true
    else
      if addon.loaded then
        log(1, 'addon %s is already loaded, skipping', addonName)
        return
      end
      if addon.loadattempted then
        log(1, 'addon %s has a load pending already, skipping', addonName)
        return
      end
      addon.loadattempted = true
    end
    local useSecureEnv = forceSecure or addon.onlysecure
    log(1, 'loading addon dependencies for %s', addonName)
    for _, dep in ipairs(addon.deps) do
      doLoadAddon(dep, useSecureEnv)
    end
    for _, dep in ipairs(addon.optionaldeps) do
      doLoadAddon(dep, useSecureEnv)
    end
    local kindstr = forceSecure and ' (secure dependency)' or useSecureEnv and ' (secure)' or ''
    log(1, 'loading addon files for %s%s', addonName, kindstr)
    local loadAddonFile = forAddon(addonName, addon.env, addon.dir, useSecureEnv)
    for _, file in ipairs(addon.files) do
      if forceSecure and file.name:lower():sub(-4) == '.xml' then
        log(1, 'skipping insecure xml %s during forceSecure', file.name)
      elseif useSecureEnv and file.AllowLoadEnvironment == 'global' then
        log(1, 'skipping %s because LoadEnvironment="secure" and AllowLoadEnvironment="global"', file.name)
      elseif addon.bootstrapped and file.Bootstrap then
        log(1, 'skipping %s because it was bootstrapped', file.name)
      elseif useSecureEnv and file.LoadIntoEnvironment == 'global' then
        log(1, 'loading secure %s in global env', file.name)
        forAddon(addonName, addon.env, addon.dir, false)(file.name)
      elseif not useSecureEnv and file.LoadIntoEnvironment == 'secure' then
        log(1, 'loading insecure %s in secureenv', file.name)
        forAddon(addonName, addon.env, addon.dir, true)(file.name)
      else
        loadAddonFile(file.name)
      end
    end
    if addon.bindings then
      loadAddonFile(addon.bindings)
      SendEvent('UPDATE_BINDINGS')
    end
    loadAddonFile(('out/%s/SavedVariables/%s.lua'):format(product, addonName), addon.signed and 'SavedVariables' or nil)
    if forceSecure then
      addon.secdeploaded = true
    else
      addon.loaded = true
    end
    log(1, 'done loading %s%s', addonName, kindstr)
    SendEvent('ADDON_LOADED', addonName, not not addon.bindings)
    for _, revwith in ipairs(addon.revwiths) do
      log(1, 'processing LoadWith %q -> %q', addonName, revwith.name)
      doLoadAddon(revwith)
    end
  end

  local function doBootstrap(addon)
    local function dolog(...)
      log(1, 'bootstrap %s: %s', addon.name, string.format(...))
    end
    if not addon.loadondemand then
      dolog('skipping, not loadondemand')
      return
    elseif addon.loaded then
      dolog('skipping, already loaded')
      return
    elseif addon.bootstrapped then
      dolog('skipping, already bootstrapped')
      return
    elseif addon.bootstrapping then
      dolog('skipping, already bootstrapping')
      return
    end
    assert(not addon.onlysecure, addon.name)
    addon.bootstrapping = true
    dolog('bootstrapping')
    for _, dep in ipairs(addon.deps) do
      dolog('bootstrapping required dependency %s', dep.name)
      doBootstrap(dep)
    end
    for _, dep in ipairs(addon.optionaldeps) do
      dolog('bootstrapping optional dependency %s', dep.name)
      doBootstrap(dep)
    end
    local env = addon.attrs.SuppressLocalTableRef ~= '1' and {} or nil
    local loadAddonFile = forAddon(addon.name, env, addon.dir)
    for _, file in ipairs(addon.files) do
      if file.Bootstrap then
        dolog('loading bootstrap file %s', file.name)
        loadAddonFile(file.name)
      end
    end
    addon.bootstrapped = true
    dolog('bootstrapped')
  end

  local function loadAddon(addonName)
    local addon = addonData[addonName:lower()]
    if not addon then
      return false, 'MISSING'
    elseif not addon.loadable then
      return false, 'LOAD_FAILED'
    else
      doLoadAddon(addon)
      return true, nil
    end
  end

  local function loadAddons()
    local loadables = initAddons()
    log(1, 'loading loadfirst/secureenv framexml addons')
    for _, addon in ipairs(loadables) do
      if addon.loadfirst then
        doLoadAddon(addon)
      end
    end
    log(1, 'loading remaining framexml addons')
    for _, addon in ipairs(loadables) do
      if not addon.loaded and addon.signed then
        (addon.loadondemand and doBootstrap or doLoadAddon)(addon)
      end
    end
    log(1, 'loading non-framexml addons')
    for _, addon in ipairs(loadables) do
      if not addon.loaded and not addon.signed then
        (addon.loadondemand and doBootstrap or doLoadAddon)(addon)
      end
    end
    log(1, 'done loading addons')
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
    loadAddon = loadAddon,
    loadAddons = loadAddons,
    saveAllVariables = saveAllVariables,
  }
end
