local args = (function()
  local parser = require('argparse')()
  parser:argument('product', 'product to fetch')
  parser:flag('-v --verbose', 'verbose')
  return parser:parse()
end)()
local product = args.product

-- Don't let casc use any system backdoors.
os.execute = function(...) -- luacheck: ignore
  error('attempt to call execute(' .. table.concat({ ... }) .. ')')
end

local log = args.verbose and print or function() end

local build = dofile('build/data/products/' .. product .. '/build.lua')
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

local cmap = {}
local save = (function()
  local bin, hex = require('casc.bin').to_bin, require('casc.bin').to_hex
  return function(fn, fdid)
    if not cmap[fn:lower()] then
      log('saving', fn)
      local ckey = bin(handle:getFileContentHash(fdid or fn))
      local ekey = handle.encoding:getEncodingHash(ckey)[1]
      local rstart, rend, archive = handle.indexCDN[ekey:sub(1, 9)]:match('(%d+)%-(%d+):(.+)')
      cmap[fn:lower()] = {
        archive = archive,
        ckey = hex(ckey),
        ekey = hex(ekey),
        name = fn,
        rend = tonumber(rend),
        rstart = tonumber(rstart),
      }
    end
  end
end)()

local processFile = (function()
  local lxp = require('lxp')
  local function doProcessFile(fn, root)
    if not handle:getFileContentHash(fn) then
      return false
    end
    save(fn)
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
      parser:parse(handle:readFile(fn))
      parser:close()
    end
    return true
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
    save(tocName)
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
    save(bindingsName)
  end
end

for _, db in ipairs(dofile('build/products/' .. product .. '/dblist.lua')) do
  save(path.join('db2', db .. '.db2'), fdids[db:lower()])
end

processTocDir('Interface/FrameXML')
do
  -- Yes, ManifestInterfaceTOCData fdid and sig are hardcoded.
  local tocdata = handle:readFile(1267335)
  for _, filepath in require('tools.dbc').rows(tocdata, 's') do
    processTocDir(normalizePath(filepath))
  end
  processTocDir('Interface/AddOns/Blizzard_APIDocumentationGenerated')
end
processFile('Interface/FrameXML/UI.xsd')
processFile('Interface/FrameXML/UI_Shared.xsd')

local nmap = {}
for _, v in require('pl.tablex').sort(cmap) do
  nmap[v.name] = v
  v.name = nil
end

local outfile = 'build/products/' .. args.product .. '/cmap.lua'
local outstr = require('tools.util').returntable(nmap)
require('pl.file').write(outfile, outstr)
log('wrote', outfile)
