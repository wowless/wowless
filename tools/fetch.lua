local args = (function()
  local parser = require('argparse')()
  parser:argument('product', 'product to fetch')
  parser:flag('-v --verbose', 'verbose')
  return parser:parse()
end)()
local product = args.product

local log = args.verbose and print or function() end

local productToSuffix = {
  wow = 'Mainline',
  wowt = 'Mainline',
  wow_beta = 'Mainline',
  wow_classic = 'TBC',
  wow_classic_beta = 'Wrath',
  wow_classic_era = 'Vanilla',
  wow_classic_era_ptr = 'Vanilla',
  wow_classic_ptr = 'Wrath',
}
local tocSuffix = assert(productToSuffix[product], 'invalid product')

local build = (function()
  local builds = require('wowapi.yaml').parseFile('data/builds.yaml')
  return assert(builds[product], 'invalid product').hash
end)()

local dbs = require('wowless.db')
assert(dbs.fdid('ManifestInterfaceTOCData'), 'missing manifest')

local path = require('path')
path.mkdir('cache')

local handle = (function()
  local casc = require('casc')
  local _, cdn, ckey = casc.cdnbuild('http://us.patch.battle.net:1119/' .. product, 'us')
  local handle, err = casc.open({
    bkey = build,
    cache = 'cache',
    cacheFiles = true,
    cdn = cdn,
    ckey = ckey,
    locale = casc.locale.US,
    log = log,
    zerofillEncryptedChunks = true,
  })
  if not handle then
    print('unable to open ' .. build .. ': ' .. err)
    os.exit()
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

local outdir = 'extracts'
path.mkdir(path.join(outdir, build))
path.remove(path.join(outdir, product))
require('lfs').link(build, path.join(outdir, product), true)

local function save(fn, content)
  log('writing', fn)
  path.mkdir(path.dirname(path.join(outdir, build, fn)))
  require('pl.file').write(path.join(outdir, build, fn), content)
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
  local tocName = path.join(dir, addonName .. '_' .. tocSuffix .. '.toc')
  local content = handle:readFile(tocName)
  if not content then
    tocName = path.join(dir, addonName .. '.toc')
    content = handle:readFile(tocName)
  end
  if content then
    save(tocName, content)
    for line in content:gmatch('[^\r\n]+') do
      if line:sub(1, 1) ~= '#' then
        processFile(joinRelative(tocName, line:gsub('%s*$', '')))
      end
    end
  end
end

for _, db in ipairs(require('tools.dblist')(product)) do
  save(path.join('db2', db .. '.db2'), handle:readFile(dbs.fdid(db)))
end

processTocDir('Interface/FrameXML')
do
  local tocdata = handle:readFile(dbs.fdid('ManifestInterfaceTOCData'))
  for row in dbs.rows(product, 'ManifestInterfaceTOCData', tocdata) do
    processTocDir(normalizePath(row.FilePath))
  end
end
