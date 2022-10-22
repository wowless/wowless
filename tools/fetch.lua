local args = (function()
  local parser = require('argparse')()
  parser:argument('product', 'product to fetch')
  parser:flag('-v --verbose', 'verbose')
  return parser:parse()
end)()
local product = args.product

local log = args.verbose and print or function() end

local build = require('wowapi.yaml').parseFile('data/products/' .. product .. '/build.yaml')

local dbs = require('wowapi.data').dbdefs

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

local function save(fn, content)
  log('writing', fn)
  path.mkdir(path.dirname(path.join(outdir, fn)))
  require('pl.file').write(path.join(outdir, fn), content)
end

local processFile = (function()
  local lxp = require('lxp')
  local function doProcessFile(fn)
    local content = handle:readFile(fn)
    if content then
      save(fn, content)
      if fn:sub(-4) == '.xml' then
        local parser = lxp.new({
          StartElement = function(_, name, attrs)
            local lname = string.lower(name)
            if (lname == 'include' or lname == 'script') and attrs.file then
              doProcessFile(joinRelative(fn, attrs.file))
            end
          end,
        })
        parser:parse(content)
        parser:close()
      end
    end
  end
  return doProcessFile
end)()

local function processTocDir(dir)
  local addonName = path.basename(dir)
  local tocName = path.join(dir, addonName .. '_' .. build.flavor .. '.toc')
  local tocContent = handle:readFile(tocName)
  if not tocContent then
    tocName = path.join(dir, addonName .. '.toc')
    tocContent = handle:readFile(tocName)
  end
  if tocContent then
    save(tocName, tocContent)
    for line in tocContent:gmatch('[^\r\n]+') do
      if line:sub(1, 1) ~= '#' then
        processFile(joinRelative(tocName, line:gsub('%s*$', '')))
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

for _, db in ipairs(require('tools.dblist')(product)) do
  save(path.join('db2', db .. '.db2'), handle:readFile(dbs[db].fdid))
end

processTocDir('Interface/FrameXML')
do
  -- Yes, ManifestInterfaceTOCData fdid and sig are hardcoded.
  local tocdata = handle:readFile(1267335)
  for _, filepath in require('dbc').rows(tocdata, 's') do
    processTocDir(normalizePath(filepath))
  end
  processTocDir('Interface/AddOns/Blizzard_APIDocumentationGenerated')
end
