local allProducts = require('runtime.products')
local file = require('pl.file')
local yaml = require('wowapi.yaml')

local args = (function()
  local parser = require('argparse')()
  parser:argument('product', 'product to build docs for'):choices(allProducts)
  parser:option('-s --source', 'product to copy missing script object mappings from'):choices(allProducts)
  return parser:parse()
end)()

local function docsfile(product)
  return 'data/products/' .. product .. '/docs.yaml'
end

local function domainfile(product, domain)
  return ('data/products/%s/%ss.yaml'):format(product, domain)
end

local function runbuild(product)
  local tmp = os.tmpname()
  local cmd = ('cmake --build --preset default --target docs-%s >%s 2>&1'):format(product, tmp)
  local code = os.execute(cmd)
  local f = assert(io.open(tmp, 'r'))
  local output = f:read('*a')
  f:close()
  os.remove(tmp)
  return code == 0, output
end

local function fixMissingScriptObject(product, source, name)
  if not source then
    print(('missing script object mapping for %s, but no --source product was given'):format(name))
    return false
  end
  local sourcedata = yaml.parse(file.read(docsfile(source)))
  local mapping = sourcedata.script_objects[name]
  if not mapping then
    if sourcedata.lies.extra_script_objects[name] then
      local targetfile = docsfile(product)
      local target = yaml.parse(file.read(targetfile))
      target.lies.extra_script_objects[name] = {}
      file.write(targetfile, yaml.pprint(target))
      print(('copied lies.extra_script_objects.%s from %s to %s'):format(name, source, product))
      return true
    end
    print(('%s has no script_objects mapping for %s either'):format(source, name))
    return false
  end
  local domain, typename = next(mapping)
  local domainf = domainfile(product, domain)
  local domaindata = yaml.parse(file.read(domainf))
  if not domaindata[typename] then
    domaindata[typename] = domain == 'uiobject'
        and { inherits = { UIObject = true }, fields = {}, methods = {} }
      or { methods = {} }
    file.write(domainf, yaml.pprint(domaindata))
    print(('added empty %s %s to %s'):format(domain, typename, product))
  end
  local targetfile = docsfile(product)
  local target = yaml.parse(file.read(targetfile))
  target.script_objects[name] = mapping
  file.write(targetfile, yaml.pprint(target))
  print(('copied script_objects.%s from %s to %s'):format(name, source, product))
  return true
end

local function fixMissingTypedef(product, source, name)
  if not source then
    print(('wtf %s, but no --source product was given'):format(name))
    return false
  end
  local typedef = yaml.parse(file.read(docsfile(source))).typedefs[name]
  if not typedef then
    print(('%s has no typedefs entry for %s either'):format(source, name))
    return false
  end
  local targetfile = docsfile(product)
  local target = yaml.parse(file.read(targetfile))
  target.typedefs[name] = typedef
  file.write(targetfile, yaml.pprint(target))
  print(('copied typedefs.%s from %s to %s'):format(name, source, product))
  return true
end

local patterns = {
  {
    pattern = 'missing script object mapping for (%S+)',
    fix = fixMissingScriptObject,
  },
  {
    pattern = 'wtf (%S+)',
    fix = fixMissingTypedef,
  },
}

local maxIters = 100
for _ = 1, maxIters do
  local ok, output = runbuild(args.product)
  if ok then
    print(('docs-%s succeeded'):format(args.product))
    os.exit(0)
  end
  local matched = false
  for _, p in ipairs(patterns) do
    local capture = output:match(p.pattern)
    if capture then
      matched = true
      if not p.fix(args.product, args.source, capture) then
        io.stderr:write('fix failed; a human needs to be involved\n')
        os.exit(1)
      end
      break
    end
  end
  if not matched then
    io.stderr:write(output)
    io.stderr:write('\nno pattern matched this failure; a human needs to be involved\n')
    os.exit(1)
  end
end
io.stderr:write('exceeded max iterations without converging\n')
os.exit(1)
