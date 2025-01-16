local args = (function()
  local parser = require('argparse')()
  parser:argument('product', 'product to fetch')
  parser:flag('-v --verbose', 'verbose')
  return parser:parse()
end)()
local product = args.product

-- TODO this is just a playground
local fetch = require('tactless')(args.product)
print(fetch('interface/addons/blizzard_apidocumentation/blizzard_apidocumentation.toc'))
os.exit(0)

-- Don't let casc use any system backdoors.
os.execute = function(...) -- luacheck: ignore
  error('attempt to call execute(' .. table.concat({ ... }) .. ')')
end

local log = args.verbose and print or function() end

local build = dofile('build/cmake/runtime/products/' .. product .. '/build.lua')
local flavor = dofile('build/cmake/runtime/flavors.lua')[build.flavor]
local fdids = require('runtime.listfile')

local path = require('path')
path.mkdir('cache')

local handle = (function()
  local casc = require('casc')
  local _, cdn, ckey = casc.cdnbuild('http://us.patch.battle.net:1119/' .. product, 'us')
  local handle, err = casc.open({
    bkey = build.hash,
    cache = 'cache',
    cacheFiles = true,
    cdn = cdn,
    ckey = ckey,
    keys = require('runtime.tactkeys'),
    locale = casc.locale.US,
    log = log,
    zerofillEncryptedChunks = true,
  })
  if not handle then
    print('unable to open ' .. build.hash .. ': ' .. err)
    os.exit(1)
  end
  return handle
end)()

local function normalizePath(p)
  -- path.normalize does not normalize x/../y to y.
  -- Unfortunately, we need exactly that behavior for Interface_Vanilla etc.
  -- links in per-product TOCs. We hack around it here by adding an extra dir.
  return path.normalize('a/' .. p):sub(3)
end

local function joinRelative(relativeTo, suffix)
  return normalizePath(path.join(path.dirname(relativeTo), suffix))
end

local outdir = path.join('extracts', product)
if path.isdir(outdir) then
  require('pl.dir').rmtree(outdir)
end

local save = (function()
  local saved = {}
  return function(fn, content)
    assert(content, 'attempting to write nil content for ' .. fn)
    if not saved[fn:lower()] then
      log('writing', fn)
      path.mkdir(path.dirname(path.join(outdir, fn)))
      require('pl.file').write(path.join(outdir, fn), content)
      saved[fn:lower()] = true
    end
  end
end)()

local processFile = (function()
  local lxp = require('lxp')
  local function doProcessFile(fn, root)
    local content = handle:readFile(fn)
    if not content then
      return false
    end
    save(fn, content)
    if fn:sub(-4) == '.xml' then
      local parser = lxp.new({
        StartElement = function(_, name, attrs)
          local lname = string.lower(name)
          if (lname == 'include' or lname == 'script') and attrs.file then
            if doProcessFile(joinRelative(fn, attrs.file), root) then
              return true
            end
            return root and doProcessFile(normalizePath(path.join(root, attrs.file)), root)
          end
        end,
      })
      parser:parse(content)
      parser:close()
    end
    return true
  end
  return doProcessFile
end)()

-- TODO unify this logic with the loader, issue #322
local tocsuffixes = (function()
  local t = {
    '_' .. build.flavor,
    '-' .. build.flavor,
  }
  for _, alt in ipairs(flavor.alternates) do
    table.insert(t, '_' .. alt)
    table.insert(t, '-' .. alt)
  end
  table.insert(t, '_Standard')
  table.insert(t, '-Standard')
  table.insert(t, '')
  return t
end)()

local function processTocDir(dir)
  local addonName = path.basename(dir)
  local tocName, tocContent
  for _, suffix in ipairs(tocsuffixes) do
    tocName = path.join(dir, addonName .. suffix .. '.toc')
    tocContent = handle:readFile(tocName)
    if tocContent then
      break
    end
  end
  if tocContent then
    save(tocName, tocContent)
    for line in tocContent:gmatch('[^\r\n]+') do
      if line:sub(1, 1) ~= '#' then
        processFile(joinRelative(tocName, line:gsub('%s*$', '')), dir)
      end
    end
  end
  local bindingsName = path.join(dir, 'Bindings.xml')
  local bindingsContent = handle:readFile(bindingsName)
  if not bindingsContent then
    bindingsName = bindingsName:gsub('^Interface/', 'Interface_' .. build.flavor .. '/')
    bindingsContent = handle:readFile(bindingsName)
  end
  if bindingsContent then
    save(bindingsName, bindingsContent)
  end
end

for _, db in ipairs(dofile('build/products/' .. product .. '/dblist.lua')) do
  save(path.join('db2', db .. '.db2'), handle:readFile(fdids[db:lower()]))
end

processTocDir('Interface/FrameXML')
do
  -- Yes, ManifestInterfaceTOCData fdid and sig are hardcoded.
  local tocdata = handle:readFile(1267335)
  local dbdef = {
    { type = 'string' },
    { id = true, noninline = true },
  }
  for row in require('tools.db2').rows(tocdata, dbdef) do
    processTocDir(normalizePath(row[1]))
  end
  processTocDir('Interface/AddOns/Blizzard_APIDocumentationGenerated')
end
processFile('Interface/FrameXML/UI.xsd')
processFile('Interface/FrameXML/UI_Shared.xsd')
processFile('Interface/AddOns/Blizzard_SharedXML/UI.xsd')
