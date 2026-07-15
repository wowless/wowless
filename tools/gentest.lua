local deps = {}
local computeEnumMeta = require('tools.enum').computeMeta
local sorted = require('pl.tablex').sort

local function readfile(f)
  deps[f] = true
  return assert((require('pl.file').read(f)))
end

local function readyaml(f)
  return require('wowapi.yaml').parse(readfile(f))
end

local function perproduct(p, f)
  return readyaml(('data/products/%s/%s.yaml'):format(p, f))
end

local function tpath(t, ...)
  for i = 1, select('#', ...) do
    assert(type(t) == 'table')
    t = t[(select(i, ...))]
    if t == nil then
      return nil
    end
  end
  return t
end

local function renderXml(x)
  local function doRenderXml(y, n, t)
    local attrs = {}
    for k in pairs(y) do
      if type(k) == 'string' and k ~= 'tag' then
        table.insert(attrs, k)
      end
    end
    table.sort(attrs)
    local tt = { (' '):rep(n), '<', y.tag }
    for _, k in ipairs(attrs) do
      table.insert(tt, (' %s=\'%s\''):format(k, tostring(y[k])))
    end
    if #y == 0 then
      table.insert(tt, ' />')
      table.insert(t, table.concat(tt))
    else
      table.insert(tt, '>')
      table.insert(t, table.concat(tt))
      for _, v in ipairs(y) do
        doRenderXml(v, n + 2, t)
      end
      table.insert(t, table.concat({ (' '):rep(n), '</', y.tag, '>' }))
    end
  end
  local t = {}
  doRenderXml(x, 0, t)
  return table.concat(t, '\n')
end

-- The shortest chain of tags from <Frame> down to each tag reachable, as a
-- descendant, from it -- e.g. chains.Slider = { 'Frame', 'Frames', 'Slider'
-- }, chains.Animation = { 'Frame', 'Animations', 'AnimationGroup',
-- 'Animation' }. Mirrors the supertypes/children containment logic
-- wowless/modules/xml.lua itself uses at runtime (built in tools/prep.lua's
-- xmlflat) to determine which tags may legally nest inside which. Used by
-- discoverCases below both for reachability (chains[tag] ~= nil) and to
-- derive exactly how to place a case's tag in the synthetic test frame
-- (see identityHops/objectPath/templateElement), instead of hand-picking a
-- wrapper per xml tag.
--
-- A tag can genuinely have more than one equally-short path from Frame --
-- the real UI.xsd often makes an element legal under several parents at
-- once (see issue #781), so this doesn't error on that by itself. Instead
-- it also returns `ambiguous`, the set of tags reached via more than one
-- distinct parent at their shortest depth; discoverCases below only errors
-- if a tag it actually needs a chain for is (transitively) affected,
-- rather than requiring the whole schema to be unambiguous.
local function frameChains(p)
  local xml = perproduct(p, 'xml')
  local function supertypesOf(tag)
    local st = { [tag:lower()] = true }
    local t = xml[tag]
    local climbing = not t.sealed
    while t.extends do
      if climbing then
        st[t.extends:lower()] = true
      end
      t = xml[t.extends]
      climbing = climbing and not t.sealed
    end
    return st
  end
  local function childrenOf(tag)
    local kids = {}
    local t = xml[tag]
    while true do
      if t.contents and t.contents ~= 'text' then
        for kid in pairs(t.contents.tags) do
          kids[kid:lower()] = true
        end
      end
      if not t.extends then
        break
      end
      t = xml[t.extends]
    end
    return kids
  end
  local supertypes, children = {}, {}
  for tag in pairs(xml) do
    supertypes[tag] = supertypesOf(tag)
    children[tag] = childrenOf(tag)
  end
  -- chains.Frame starts as the trivial zero-hop "this is the synthetic
  -- test frame itself" entry, needed to bootstrap its direct children
  -- (Frames/Layers/Animations/...). But Frame is also a legitimate xml tag
  -- in its own right (e.g. a Frame.framestrata case needs a *fresh* child
  -- Frame instance, not the shared root re-carrying every candidate's
  -- value at once) -- so `visited`, not `chains`, gates rediscovery, and
  -- once Frame is found again for real (via Frames, same as any other
  -- Frame-family tag), its chains entry is overwritten with that real,
  -- reachable-as-a-child chain rather than staying at the trivial one.
  local chains = { Frame = { 'Frame' } }
  local visited = {}
  local ambiguous = {}
  local frontier = { 'Frame' }
  while #frontier > 0 do
    -- Collect every candidate parent per newly-reachable tag from this
    -- whole layer before resolving any of them, so resolution doesn't
    -- depend on frontier iteration order (a tag seeing two non-Layer
    -- candidates before Layer itself must still resolve to Layer, not
    -- latch an early conflict).
    local candidates = {}
    for _, from in ipairs(frontier) do
      local allowed = children[from]
      for tag in pairs(xml) do
        if not visited[tag] then
          for st in pairs(supertypes[tag]) do
            if allowed[st] then
              candidates[tag] = candidates[tag] or {}
              candidates[tag][from] = true
              break
            end
          end
        end
      end
    end
    local parentOf = {}
    for tag, froms in pairs(candidates) do
      if froms.Layer then
        -- <Layer> is the generic, impl:transparent container built for
        -- LayeredRegion tags (Texture/FontString/...): whenever it's one
        -- of the tied candidates, it's always a legal, no-extra-
        -- object-identity placement, so prefer it over erroring -- e.g.
        -- FontString is otherwise also tied between EditBox/MessageFrame/
        -- SimpleHTML, each of which would need its own synthetic
        -- instance for no benefit.
        parentOf[tag] = 'Layer'
      else
        local only, count = nil, 0
        for from in pairs(froms) do
          only, count = from, count + 1
        end
        if count == 1 then
          parentOf[tag] = only
        else
          ambiguous[tag] = true
          parentOf[tag] = only
        end
      end
    end
    local nextFrontier = {}
    for tag, from in pairs(parentOf) do
      local chain = {}
      for i, t in ipairs(chains[from]) do
        chain[i] = t
      end
      table.insert(chain, tag)
      chains[tag] = chain
      visited[tag] = true
      table.insert(nextFrontier, tag)
    end
    frontier = nextFrontier
  end
  return chains, ambiguous
end

-- Per-type field/method data (fields, their init defaults, and which
-- methods getter/set them), flattened across the inherits chain. Shared by
-- the uiobjectapis ptablemap entry and discoverCases below.
local function computeUiobjectApis(p)
  local uiobjects = perproduct(p, 'uiobjects')
  local allscripts = readyaml('data/scripttypes.yaml')
  for _, cfg in pairs(uiobjects) do
    cfg.fieldinitoverrides = cfg.fieldinitoverrides or {}
  end
  for k, cfg in pairs(uiobjects) do
    cfg.isa = {}
    for k2, cfg2 in pairs(uiobjects) do
      cfg.isa[k2] = false
      if cfg2.objectType then
        cfg.isa[cfg2.objectType] = false
      end
    end
    if not cfg.virtual or cfg.objectType then
      cfg.isa[cfg.objectType or k] = true
    end
  end
  local function fixup(cfg)
    for inhname in pairs(cfg.inherits) do
      local inh = uiobjects[inhname]
      fixup(inh)
      for n, f in pairs(inh.fieldinitoverrides) do
        cfg.fieldinitoverrides[n] = f
      end
      for n, f in pairs(inh.fields) do
        cfg.fields[n] = f
      end
      for n, m in pairs(inh.methods) do
        cfg.methods[n] = cfg.methods[n] or m -- overrides
      end
      if inh.scripts then
        cfg.scripts = cfg.scripts or {}
        for n in pairs(inh.scripts) do
          cfg.scripts[n] = {}
        end
      end
      for ik, iv in pairs(inh.isa) do
        if iv then
          cfg.isa[ik] = true
        end
      end
    end
  end
  for _, cfg in pairs(uiobjects) do
    fixup(cfg)
  end
  local t = {}
  for k, v in pairs(uiobjects) do
    local ft = {}
    for fk, fv in pairs(v.fields) do
      local init = fv.init
      local override = v.fieldinitoverrides[fk]
      if override ~= nil then
        init = override
      end
      ft[fk] = {
        dynamicinit = fv.dynamicinit,
        getters = {},
        init = init,
      }
    end
    local mt = {}
    for mk, mv in pairs(v.methods) do
      mt[mk] = true
      for gk, gv in ipairs(mv.impl and mv.impl.getter or {}) do
        table.insert(ft[gv.name].getters, { index = gk, method = mk })
      end
    end
    for fk, fv in pairs(ft) do
      if fv.dynamicinit then
        ft[fk] = nil
      end
    end
    -- TODO remove these super duper field hacks
    ft.parent = nil
    if v.singleton then
      ft = {}
    elseif k == 'EditBox' then
      ft.shown.init = false
    end
    local st = {}
    for scripttype in pairs(allscripts) do
      st[scripttype] = not not (v.scripts and v.scripts[scripttype])
    end
    t[k] = {
      fields = ft,
      isa = v.isa,
      methods = mt,
      objtype = v.objectType or k,
      scripts = st,
      singleton = v.singleton,
      virtual = v.virtual,
    }
  end
  for _, product in ipairs(readyaml('data/products.yaml')) do
    for k in pairs(perproduct(product, 'uiobjects')) do
      if not t[k] then
        t[k] = { unsupported = true }
      end
    end
  end
  return t
end

-- Which positions (2..#chain, i.e. excluding the root Frame itself) in a
-- frameChains chain create a real, separately-addressable uiobject -- the
-- ones that need a parentKey in the generated XML and a hop in objectPath.
-- Pure grouping tags in the chain (Layers/Layer/Frames/Animations/...) have
-- no uiobjects.yaml entry: they splice their contents into the enclosing
-- real object at runtime rather than creating one of their own, so they're
-- skipped here.
local function identityHops(uiobjectApis, chain)
  local hops = {}
  for i = 2, #chain do
    if uiobjectApis[chain[i]] then
      table.insert(hops, i)
    end
  end
  return hops
end

-- The parentKey for the n-th (1-indexed) of a case's `total` identity
-- hops. The last hop is always the case's own test object and keeps the
-- plain candidate key; any earlier identity hop (so far, only an
-- AnimationGroup on the way to an Animation) is scaffolding required to
-- legally nest the test object at all, and needs a per-candidate-unique
-- key of its own so candidates don't collide by sharing one AnimationGroup
-- (and, with it, its field defaults) -- the exact suffix scheme doesn't
-- matter beyond that, since it's never read back, only used to link a
-- wrapper element to its child in the same generated file.
local function hopKey(key, n, total)
  return n == total and key or (key .. '_' .. n)
end

-- objectPath hops from the root Frame to a case's generated test object,
-- keyed the same way ptablemap.templates and 'templatexml' below build the
-- corresponding parentKey chain in the actual XML (see identityHops).
local function objectPath(uiobjectApis, case, key)
  local hops = identityHops(uiobjectApis, case.chain)
  local path = {}
  for n in ipairs(hops) do
    table.insert(path, hopKey(key, n, #hops))
  end
  return path
end

-- Nests a candidate's XML element inside its case's full chain of wrapper
-- tags (see frameChains), from the child directly under the root Frame
-- down to the leaf that carries the tested attribute -- assigning
-- parentKey to each identity hop along the way (see identityHops/hopKey,
-- kept in sync with objectPath above) and the candidate's attribute value
-- to the leaf.
local function templateElement(uiobjectApis, case, key, value)
  local chain = case.chain
  local hops = identityHops(uiobjectApis, chain)
  local hopIndex = {}
  for n, i in ipairs(hops) do
    hopIndex[i] = n
  end
  local total = #hops
  local element
  for i = #chain, 2, -1 do
    local e = { tag = chain[i] }
    if hopIndex[i] then
      e.parentKey = hopKey(key, hopIndex[i], total)
    end
    if i == #chain then
      e[case.xmlAttrKey] = value
    end
    if element then
      table.insert(e, element)
    end
    element = e
  end
  return element
end

-- Every (tag, attribute) pair typed stringenum:/enum:, for tags reachable
-- from Frame (see frameChains) -- these are eligible for per-product
-- XML-attribute-value template tests. An eligible attribute's impl is
-- required to be field-based (data/schemas/xml.yaml's attribute impl
-- taggedunion also allows method/internal/loadfile/scope, but every
-- stringenum-/enum-typed attribute reachable from Frame today uses
-- `impl.field` directly) -- resolve the field's default and real getter
-- method via computeUiobjectApis's already-computed, inherits-flattened
-- field/getter data, rather than re-deriving either from string transforms.
--
-- frameChains doesn't guarantee every tag has one unambiguous chain (see
-- its comment, and issue #781) -- only assert that here, lazily, for a
-- chain a case actually needs, rather than requiring the whole schema to
-- be unambiguous up front.
local function discoverCases(p)
  local chains, ambiguous = frameChains(p)
  local uiobjectApis = computeUiobjectApis(p)
  local cases = {}
  for tag, tdef in pairs(perproduct(p, 'xml')) do
    if chains[tag] then
      for attrKey, attrDef in pairs(tdef.attributes or {}) do
        local ty = attrDef.type
        if ty.stringenum or ty.enum then
          local fieldName = assert(attrDef.impl.field, 'unsupported attribute impl for ' .. tag .. '.' .. attrKey)
          local fv = uiobjectApis[tag].fields[fieldName]
          local chain = chains[tag]
          for _, t in ipairs(chain) do
            assert(not ambiguous[t], ('%s.%s: no unambiguous chain to %s (see #781)'):format(tag, attrKey, t))
          end
          table.insert(cases, {
            chain = chain,
            getter = fv.getters[1].method,
            id = tag:lower() .. '_' .. attrKey,
            init = fv.init,
            xmlAttrKey = attrKey,
            xmlTag = tag,
          })
        end
      end
    end
  end
  return cases
end

local function attrMembers(p, case)
  local tdef = perproduct(p, 'xml')[case.xmlTag]
  local attrDef = tdef and tdef.attributes[case.xmlAttrKey]
  if not attrDef then
    return {}
  end
  local ty = attrDef.type
  if ty.stringenum then
    local members = {}
    for name in pairs(perproduct(p, 'stringenums')[ty.stringenum]) do
      members[name] = name
    end
    return members
  elseif ty.enum then
    return perproduct(p, 'globals').Enum[ty.enum] or {}
  end
  error('unsupported template-case attribute type for ' .. case.id)
end

-- Native candidates from this product's own data (plus a lowercase variant
-- per stringenum member, to check case-insensitive attribute parsing),
-- then a negative pass unioning in other products' foreign values: values
-- valid elsewhere but not native to this product, expecting this
-- product's own field default (mirrors the events ptablemap entry below).
-- Also always includes a guaranteed-nonsense negative case, so this
-- coverage doesn't depend on products having diverged.
local function computeCandidates(p, case)
  local candidates = {}
  local native = {}
  for name, expected in pairs(attrMembers(p, case)) do
    native[name:upper()] = true
    table.insert(candidates, { expected = expected, suffix = name:lower(), value = name })
    if type(expected) == 'string' then
      table.insert(candidates, { expected = expected, suffix = name:lower() .. '_lower', value = name:lower() })
    end
  end
  local seenForeign = {}
  for _, product in ipairs(readyaml('data/products.yaml')) do
    if product ~= p then
      for name in pairs(attrMembers(product, case)) do
        local upper = name:upper()
        if not native[upper] and not seenForeign[upper] then
          seenForeign[upper] = true
          table.insert(candidates, { expected = case.init, suffix = name:lower(), value = name })
        end
      end
    end
  end
  assert(not native.NONSENSE, 'nonsense is apparently not nonsense for ' .. case.id)
  table.insert(candidates, { expected = case.init, suffix = 'nonsense', value = 'nonsense' })
  return candidates
end

local ptablemap = {
  build = function(p)
    return 'Build', perproduct(p, 'build')
  end,
  config = function(p)
    return 'Config', perproduct(p, 'config')
  end,
  cvars = function(p)
    return 'CVars', perproduct(p, 'cvars')
  end,
  events = function(p)
    local t = {}
    for k, v in pairs(perproduct(p, 'events')) do
      t[k] = {
        callback = v.callback or false,
        registerable = not v.noscript,
        restricted = v.restricted,
      }
    end
    for _, product in ipairs(readyaml('data/products.yaml')) do
      for k in pairs(perproduct(product, 'events')) do
        if not t[k] then
          t[k] = {
            callback = false,
            registerable = false,
          }
        end
      end
    end
    return 'Events', t
  end,
  globalapis = function(p)
    local config = perproduct(p, 'config')
    local t = {}
    for name, api in pairs(perproduct(p, 'apis')) do
      if not name:find('%.') and not api.secureonly then
        local vv = {
          overwritten = tpath(config, 'addon', 'overwritten_apis', name) and true,
          protected = api.protected,
          unsupported = api.unsupported,
        }
        t[name] = next(vv) and vv or true
      end
    end
    return 'GlobalApis', t
  end,
  globals = function(p)
    local t = perproduct(p, 'globals')
    local metafix = perproduct(p, 'config').runtime.enummetafix
    local names = {}
    for name in pairs(t.Enum) do
      table.insert(names, name)
    end
    for _, name in ipairs(names) do
      t.Enum[name .. 'Meta'] = computeEnumMeta(t.Enum[name], metafix)
    end
    return 'Globals', t
  end,
  impltests = function(p)
    local test = readyaml('data/test.yaml')
    local impl_to_apis = {}
    for name, api in pairs(perproduct(p, 'apis')) do
      if api.impl then
        if not impl_to_apis[api.impl] then
          impl_to_apis[api.impl] = {}
        end
        impl_to_apis[api.impl][name] = true
      end
    end
    local t = {}
    for test_name, impls_set in pairs(test) do
      local implsets = {}
      local skip = false
      for impl_name in sorted(impls_set) do
        local api_set = impl_to_apis[impl_name]
        if not api_set then
          skip = true
          break
        end
        local api_list = {}
        for name in sorted(api_set) do
          table.insert(api_list, name)
        end
        table.insert(implsets, api_list)
      end
      if not skip then
        t[test_name] = { implsets = implsets, src = readfile('data/test/' .. test_name .. '.lua') }
      end
    end
    return 'ImplTests', t
  end,
  luaobjects = function(p)
    local raw = perproduct(p, 'luaobjects')
    -- For each luaobject type, a mapping of method name to the luaobject type it came from.
    local t = {}
    local function pop(k)
      if t[k] then
        return
      end
      local v = raw[k]
      local methods = {}
      if v.inherits then
        pop(v.inherits)
        for mk, mv in pairs(t[v.inherits]) do
          methods[mk] = mv
        end
      end
      for mk in pairs(v.methods or {}) do
        methods[mk] = k
      end
      t[k] = methods
    end
    for k in pairs(raw) do
      pop(k)
    end
    for k, v in pairs(raw) do
      if v.virtual then
        t[k] = nil
      end
    end
    -- Method partition: name from base type to list of names from all derived types.
    local mp = {}
    for k, v in pairs(t) do
      for vk, vv in pairs(v) do
        local ck = vv .. '/' .. vk
        local cv = mp[ck]
        if not cv then
          cv = {}
          mp[ck] = cv
        end
        table.insert(cv, k .. '/' .. vk)
      end
    end
    -- Compressed method partition, more easily computable addon-side.
    local cmp = {}
    for _, v in pairs(mp) do
      table.sort(v)
      local k = table.concat(v, ',')
      assert(not cmp[k])
      cmp[k] = true
    end
    -- Type to set of method names.
    local types = {}
    for k, v in pairs(t) do
      local m = {}
      for vk in pairs(v) do
        m[vk] = true
      end
      types[k] = m
    end
    return 'LuaObjects', {
      methodpartition = cmp,
      types = types,
    }
  end,
  namespaceapis = function(p)
    local platform = dofile('build/runtime/platform.lua')
    local config = perproduct(p, 'config')
    local apiNamespaces = {}
    for k, api in pairs(perproduct(p, 'apis')) do
      local dot = k:find('%.')
      if dot and (not api.platform or api.platform == platform) and not api.secureonly then
        local name = k:sub(1, dot - 1)
        apiNamespaces[name] = apiNamespaces[name] or { methods = {} }
        apiNamespaces[name].methods[k:sub(dot + 1)] = api
      end
    end
    local t = {}
    for k, v in pairs(apiNamespaces) do
      local mt = {}
      for mk in pairs(v.methods) do
        local tt = {
          overwritten = tpath(config, 'addon', 'overwritten_apis', k .. '.' .. mk) and true,
        }
        mt[mk] = next(tt) and tt or true
      end
      t[k] = mt
    end
    return 'NamespaceApis', t
  end,
  templates = function(p)
    local uiobjectApis = computeUiobjectApis(p)
    local t = {}
    for _, case in ipairs(discoverCases(p)) do
      for _, c in ipairs(computeCandidates(p, case)) do
        local key = case.id .. '_' .. c.suffix
        t[key] = { expected = c.expected, getter = case.getter, objectPath = objectPath(uiobjectApis, case, key) }
      end
    end
    return 'Templates', t
  end,
  uiobjectapis = function(p)
    return 'UIObjectApis', computeUiobjectApis(p)
  end,
}

local args = (function()
  local parser = require('argparse')()
  parser:argument('product')
  parser:argument('file')
  parser:argument('output')
  return parser:parse()
end)()
local function doit(k, p)
  if ptablemap[k] then
    local nn, tt = ptablemap[k](p)
    return '_G.WowlessData.' .. nn .. ' = ' .. require('tools.prettywrite')(tt) .. '\n'
  elseif k == 'product' then
    return ('_G.WowlessData = { product = %q }'):format(p)
  elseif k == 'templatexml' then
    local uiobjectApis = computeUiobjectApis(p)
    local root = { name = 'WowlessGeneratedXmlTests', tag = 'Frame' }
    for _, case in ipairs(discoverCases(p)) do
      for _, c in ipairs(computeCandidates(p, case)) do
        local key = case.id .. '_' .. c.suffix
        table.insert(root, templateElement(uiobjectApis, case, key, c.value))
      end
    end
    return renderXml({ root, tag = 'Ui' })
  elseif k == 'toc' then
    local tt = {}
    for kk in pairs(ptablemap) do
      table.insert(tt, kk .. '.lua')
    end
    table.insert(tt, 'templates.xml')
    table.sort(tt)
    table.insert(tt, 1, 'product.lua')
    table.insert(tt, 1, '## Interface: ' .. perproduct(p, 'build').tocversion)
    table.insert(tt, '')
    return table.concat(tt, '\n')
  else
    error('invalid file type ' .. k)
  end
end
local content = doit(args.file, args.product)
require('pl.file').write(args.output, content)
require('tools.util').writedeps(args.output, deps)
