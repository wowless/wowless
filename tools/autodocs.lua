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

local function fixMissingScriptObject(product, source, name, objecttype)
  local domain, typename
  if source then
    local sourcedata = yaml.parse(file.read(docsfile(source)))
    local mapping = sourcedata.script_objects[name]
    if mapping then
      domain, typename = next(mapping)
    elseif sourcedata.lies.extra_script_objects[name] then
      local targetfile = docsfile(product)
      local target = yaml.parse(file.read(targetfile))
      target.lies.extra_script_objects[name] = {}
      file.write(targetfile, yaml.pprint(target))
      print(('copied lies.extra_script_objects.%s from %s to %s'):format(name, source, product))
      return true
    end
  end
  if not domain and objecttype == 'Userdata' then
    local stripped = name:match('^(.*)API$')
    if stripped then
      domain, typename = 'luaobject', stripped
      print(('guessed luaobject %s for %s from ObjectType Userdata; verify this is correct'):format(typename, name))
    end
  end
  if not domain then
    if source then
      print(('%s has no script_objects mapping for %s either'):format(source, name))
    else
      print(('missing script object mapping for %s, but no --source product was given'):format(name))
    end
    return false
  end
  local domainf = domainfile(product, domain)
  local domaindata = yaml.parse(file.read(domainf))
  if not domaindata[typename] then
    domaindata[typename] = domain == 'uiobject' and { inherits = { UIObject = {} }, fields = {}, methods = {} }
      or { methods = {} }
    file.write(domainf, yaml.pprint(domaindata))
    print(('added empty %s %s to %s'):format(domain, typename, product))
  end
  local targetfile = docsfile(product)
  local target = yaml.parse(file.read(targetfile))
  target.script_objects[name] = { [domain] = typename }
  file.write(targetfile, yaml.pprint(target))
  print(('added script_objects.%s -> %s %s to %s'):format(name, domain, typename, product))
  return true
end

local function enumsfile(product)
  return 'data/products/' .. product .. '/enums.yaml'
end

local baseLuaTypes = { boolean = true, number = true, string = true, table = true }

local function fixMissingTypedef(product, source, name)
  local targetfile = docsfile(product)
  local target = yaml.parse(file.read(targetfile))
  if baseLuaTypes[name] then
    target.typedefs[name] = { type = name }
    file.write(targetfile, yaml.pprint(target))
    print(('added typedefs.%s -> %s to %s'):format(name, name, product))
    return true
  end
  for _, mapping in pairs(target.script_objects) do
    local domain, typename = next(mapping)
    if typename == name then
      target.typedefs[name] = { type = { [domain] = name } }
      file.write(targetfile, yaml.pprint(target))
      print(
        ('added typedefs.%s -> %s %s (matches own script_objects mapping) to %s'):format(name, domain, name, product)
      )
      return true
    end
  end
  if source then
    local typedef = yaml.parse(file.read(docsfile(source))).typedefs[name]
    if typedef then
      target.typedefs[name] = typedef
      file.write(targetfile, yaml.pprint(target))
      print(('copied typedefs.%s from %s to %s'):format(name, source, product))
      return true
    end
    local enum = yaml.parse(file.read(enumsfile(source)))[name]
    if enum then
      local enumsf = enumsfile(product)
      local enumtarget = yaml.parse(file.read(enumsf))
      enumtarget[name] = enum
      file.write(enumsf, yaml.pprint(enumtarget))
      print(('copied Enum.%s from %s to %s'):format(name, source, product))
      return true
    end
  end
  if name:match('ID$') then
    target.typedefs[name] = { type = 'number' }
    file.write(targetfile, yaml.pprint(target))
    print(('guessed typedefs.%s -> number from name ending in ID; verify this is correct'):format(name))
    return true
  end
  if source then
    print(('%s has no typedefs or Enum entry for %s either'):format(source, name))
  else
    print(('wtf %s, but no --source product was given'):format(name))
  end
  return false
end

-- A lies.<section> patch that no longer applies means the doc it was
-- patching around has itself changed upstream; drop the stale patch.
-- docs.lua's takelieor always passes the section ('apis', 'events', 'enums',
-- 'structures', 'uiobjects') as the first path element, so it's always the
-- text before the first dot here; only lies.uiobjects nests a second level
-- (uiobject type, then method) below that.
local nestedLiesSections = { uiobjects = true }

local function fixStaleApiLie(product, _, path)
  local section, rest = path:match('^([^.]+)%.(.+)$')
  if not section then
    print(('could not parse a lies section out of %s'):format(path))
    return false
  end
  local targetfile = docsfile(product)
  local target = yaml.parse(file.read(targetfile))
  local lies = target.lies and target.lies[section]
  if not lies then
    print(('no lies.%s to remove %s from'):format(section, rest))
    return false
  end
  if nestedLiesSections[section] then
    local outer, inner = rest:match('^([^.]+)%.(.+)$')
    local outerLies = outer and lies[outer]
    if not (outerLies and outerLies[inner] ~= nil) then
      print(('no lies.%s.%s entry to remove'):format(section, rest))
      return false
    end
    outerLies[inner] = nil
    if not next(outerLies) then
      lies[outer] = nil
    end
  else
    if lies[rest] == nil then
      print(('no lies.%s.%s entry to remove'):format(section, rest))
      return false
    end
    lies[rest] = nil
  end
  file.write(targetfile, yaml.pprint(target))
  print(('removed stale lies.%s.%s from %s'):format(section, rest, product))
  return true
end

local doctableSchemaFile = 'data/schemas/doctable.yaml'

-- Recursively hunts a wowapi.schema validation error tree (as produced by
-- wowapi/schema.lua's record validator and pretty-printed by docs.lua) for a
-- leaf error message. Returns the dotted path of record field names leading
-- to (but excluding) the offending field, the field name, and the message.
local function findSchemaError(t, ancestors)
  for k, v in pairs(t) do
    if type(v) == 'string' then
      if type(k) == 'string' then
        return { ancestors = ancestors, field = k, msg = v }
      end
    else
      local nextAncestors = ancestors
      if type(k) == 'string' then
        nextAncestors = {}
        for _, a in ipairs(ancestors) do
          table.insert(nextAncestors, a)
        end
        table.insert(nextAncestors, k)
      end
      local found = findSchemaError(v, nextAncestors)
      if found then
        return found
      end
    end
  end
end

local function recordOf(node)
  if type(node) ~= 'table' then
    return nil
  elseif node.record then
    return node.record
  elseif type(node.sequenceof) == 'table' and node.sequenceof.record then
    return node.sequenceof.record
  end
end

-- Walks a doctable.yaml schema down to the record that findSchemaError's
-- ancestors point at.
local function descendSchema(schema, ancestors)
  local node = schema.type
  for _, a in ipairs(ancestors) do
    local rec = recordOf(node)
    local entry = rec and rec[a]
    if not entry then
      return nil
    end
    node = entry.type
  end
  return recordOf(node)
end

local function fixDoctableSchema(_, _, block)
  local ok, errs = pcall(yaml.parse, block)
  if not ok or type(errs) ~= 'table' then
    print('could not parse doctable schema validation error')
    return false
  end
  local found = findSchemaError(errs, {})
  if not found then
    print('doctable schema validation error had no recognizable leaf error')
    return false
  end
  local path = table.concat(found.ancestors, '.')
  local schema = yaml.parse(file.read(doctableSchemaFile))
  local rec = descendSchema(schema, found.ancestors)
  if not rec then
    print(('could not locate doctable schema record for %s'):format(path))
    return false
  end
  if found.msg == 'unknown field' then
    if rec[found.field] then
      print(('doctable schema already has an entry for %s.%s'):format(path, found.field))
      return false
    end
    -- Almost every field in this schema is a presence-only boolean flag; if
    -- that guess is wrong, the next build attempt reports a different error
    -- (e.g. "want flag, got string") instead of silently accepting bad data.
    rec[found.field] = { type = 'flag' }
    file.write(doctableSchemaFile, yaml.pprint(schema))
    print(('added %s.%s (flag) to doctable schema'):format(path, found.field))
    return true
  elseif found.msg == 'string literal mismatch' then
    local entry = rec[found.field]
    if not (entry and type(entry.type) == 'table' and entry.type.literal ~= nil) then
      print(('doctable schema field %s.%s is not a literal type; cannot relax'):format(path, found.field))
      return false
    end
    entry.type = 'string'
    file.write(doctableSchemaFile, yaml.pprint(schema))
    print(('relaxed %s.%s from a literal to a string in the doctable schema'):format(path, found.field))
    return true
  end
  print(('unrecognized doctable schema error for %s.%s: %s'):format(path, found.field, found.msg))
  return false
end

local function fixUnusedTypedefs(product, _, block)
  local ok, names = pcall(yaml.parse, block)
  if not ok or type(names) ~= 'table' or not next(names) then
    print('could not parse unused typedefs list')
    return false
  end
  local targetfile = docsfile(product)
  local target = yaml.parse(file.read(targetfile))
  for name in pairs(names) do
    target.typedefs[name] = nil
    print(('removed unused typedefs.%s from %s'):format(name, product))
  end
  file.write(targetfile, yaml.pprint(target))
  return true
end

local patterns = {
  {
    pattern = 'tools/docs%.lua:%d+: unused typedefs:\n(.-)\n\n',
    fix = fixUnusedTypedefs,
  },
  {
    pattern = 'tools/docs%.lua:%d+: (.-)\n\n',
    fix = fixDoctableSchema,
  },
  {
    pattern = 'missing script object mapping for (%S+) %(ObjectType (%S+)%)',
    fix = fixMissingScriptObject,
  },
  {
    pattern = 'wtf (%S+)',
    fix = fixMissingTypedef,
  },
  {
    pattern = 'tedit failure on ([^:]+):',
    fix = fixStaleApiLie,
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
    local captures = { output:match(p.pattern) }
    if captures[1] then
      matched = true
      if not p.fix(args.product, args.source, unpack(captures)) then
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
