-- Derives XML tag placement from an xml.yaml-shaped containment graph
-- (contents.tags/extends, including the `sealed` flag), mirroring the
-- containment check wowless/modules/xml.lua's runtime parser uses (see
-- also tools/prep.lua's xmlflat). Used by tools/gentest.lua's per-product
-- XML-attribute-value template-test generator to place a case's tag in a
-- synthetic test frame without hand-classifying every tag it covers.

-- The shortest chain of tags from `root` down to every tag reachable, as a
-- descendant, from it -- e.g. frameChains(xml, 'Frame').Slider = { 'Frame',
-- 'Frames', 'Slider' }. `root` is itself a real tag in `xml` (not a
-- separate sentinel), which matters when `root` is also reachable as an
-- ordinary descendant of itself (e.g. a <Frame> nested inside <Frames>):
-- `visited`, not the `chains` table, gates rediscovery, so `root`'s trivial
-- zero-hop bootstrap entry gets overwritten once it's found again for
-- real, the same way any other tag would be.
--
-- A tag can have more than one equally-short path from `root` -- some
-- schemas legitimately allow an element under several parents at once, so
-- this doesn't error on that by itself. If `preferParent` is given and is
-- among a tag's tied candidates, that candidate wins (e.g. a generic,
-- identity-free wrapper tag is always a safe, minimal choice over a more
-- specific parent that also happens to accept the same tag); otherwise the
-- tag is recorded in the second return value, `ambiguous`, the set of tags
-- with no unique shortest path -- callers can then decide whether/when
-- that matters for their own purposes.
local function frameChains(xml, root, preferParent)
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
  local chains = { [root] = { root } }
  local visited = {}
  local ambiguous = {}
  local frontier = { root }
  while #frontier > 0 do
    -- Collect every candidate parent per newly-reachable tag from this
    -- whole layer before resolving any of them, so resolution doesn't
    -- depend on frontier iteration order (a tag seeing two non-preferred
    -- candidates before the preferred one must still resolve to it, not
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
      if preferParent and froms[preferParent] then
        parentOf[tag] = preferParent
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

-- Which positions (2..#chain, i.e. excluding chain[1], the root itself) in
-- a frameChains chain create a real, separately-addressable object -- the
-- ones that need their own identity (e.g. a parentKey in generated XML, or
-- a hop in an object lookup path). `hasIdentity` is a set (table truthy by
-- tag name) of tags that have one; pure grouping tags in the chain have no
-- entry, since they splice their contents into the enclosing real object
-- at runtime rather than creating one of their own.
local function identityHops(hasIdentity, chain)
  local hops = {}
  for i = 2, #chain do
    if hasIdentity[chain[i]] then
      table.insert(hops, i)
    end
  end
  return hops
end

-- The key for the n-th (1-indexed) of `total` identity hops. The last hop
-- keeps the plain candidate key; any earlier identity hop is scaffolding
-- required to legally nest the target object at all, and needs a key of
-- its own so sibling candidates don't collide by sharing that scaffolding
-- (and, with it, its own field defaults) -- the exact suffix scheme
-- doesn't matter beyond that, since it's only used to link a wrapper
-- element to its child within the same generated output.
local function hopKey(key, n, total)
  return n == total and key or (key .. '_' .. n)
end

-- The lookup path from `root` to `key`'s target object: one entry per
-- identity hop in `chain` (see identityHops/hopKey), naming each the same
-- way templateElement below builds the matching XML.
local function objectPath(hasIdentity, chain, key)
  local hops = identityHops(hasIdentity, chain)
  local path = {}
  for n in ipairs(hops) do
    table.insert(path, hopKey(key, n, #hops))
  end
  return path
end

-- Nests an element inside chain[2..], from the child directly under the
-- (pre-existing, not re-rendered) root down to the leaf that carries
-- `attrKey = value` -- assigning a key to each identity hop along the way
-- (see identityHops/hopKey, kept in sync with objectPath above).
local function templateElement(hasIdentity, chain, attrKey, key, value)
  local hops = identityHops(hasIdentity, chain)
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
      e[attrKey] = value
    end
    if element then
      table.insert(e, element)
    end
    element = e
  end
  return element
end

return {
  frameChains = frameChains,
  hopKey = hopKey,
  identityHops = identityHops,
  objectPath = objectPath,
  templateElement = templateElement,
}
