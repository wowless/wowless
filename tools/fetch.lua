local args = (function()
  local parser = require('argparse')()
  parser:argument('product', 'product to fetch')
  parser:flag('-v --verbose', 'verbose')
  return parser:parse()
end)()
local product = args.product

local log = args.verbose and print or function() end

local build = dofile('build/cmake/runtime/products/' .. product .. '/build.lua')
local fdids = require('runtime.listfile')

local path = require('path')
path.mkdir('cache')

local fetch = (function()
  local fetch = require('tactless')(args.product, build.hash)
  if not fetch then
    print('unable to open ' .. build.hash)
    os.exit(1)
  end
  return fetch
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
    local content = fetch(fn)
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

local tocutil = require('wowless.toc')
local tocsuffixes = tocutil.suffixes[build.flavor]

local function processTocDir(dir)
  local addonName = path.basename(dir)
  local tocName, tocContent
  for _, suffix in ipairs(tocsuffixes) do
    tocName = path.join(dir, addonName .. suffix .. '.toc')
    tocContent = fetch(tocName)
    if tocContent then
      break
    end
  end
  if tocContent then
    save(tocName, tocContent)
    local _, files = tocutil.parse(tocContent)
    for _, file in ipairs(files) do
      processFile(joinRelative(tocName, file), dir)
    end
  end
  local bindingsName = path.join(dir, 'Bindings.xml')
  local bindingsContent = fetch(bindingsName)
  if not bindingsContent then
    bindingsName = bindingsName:gsub('^Interface/', 'Interface_' .. build.flavor .. '/')
    bindingsContent = fetch(bindingsName)
  end
  if bindingsContent then
    save(bindingsName, bindingsContent)
  end
end

for _, db in ipairs(dofile('build/products/' .. product .. '/dblist.lua')) do
  save(path.join('db2', db .. '.db2'), fetch(fdids[db:lower()]))
end

processTocDir('Interface/FrameXML')
do
  -- Yes, ManifestInterfaceTOCData fdid and sig are hardcoded.
  local tocdata = fetch(1267335)
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
