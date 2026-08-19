-- Derives XML tag containment from an xml.yaml-shaped schema (contents.tags/
-- extends, including the `sealed` flag), mirroring the containment check
-- wowless/modules/xml.lua's runtime parser uses (see also tools/prep.lua's
-- xmlflat). Pure structural computation over that graph -- no notion of
-- rendering, tests, or any particular caller's vocabulary.

-- The shortest chain of tags from `root` down to every tag reachable, as a
-- descendant, from it -- e.g. chains(xml, 'Frame').Slider = { 'Frame',
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
local function supertypesOf(xml, tag)
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

local function childrenOf(xml, tag)
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

local function chains(xml, root, preferParent)
  local supertypes, children = {}, {}
  for tag in pairs(xml) do
    supertypes[tag] = supertypesOf(xml, tag)
    children[tag] = childrenOf(xml, tag)
  end
  local result = { [root] = { root } }
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
      for i, t in ipairs(result[from]) do
        chain[i] = t
      end
      table.insert(chain, tag)
      result[tag] = chain
      visited[tag] = true
      table.insert(nextFrontier, tag)
    end
    frontier = nextFrontier
  end
  return result, ambiguous
end

-- The set of non-virtual tags that are never a legal child of any other tag
-- in the schema -- i.e. the tags that can legitimately stand as an XML
-- document's root element. A virtual tag is excluded even when nothing
-- names it as a child, since it can never be instantiated as a literal tag
-- either way (it exists only for concrete subtypes to extend).
local function roots(xml)
  local children = {}
  for tag in pairs(xml) do
    children[tag] = childrenOf(xml, tag)
  end
  local result = {}
  for tag in pairs(xml) do
    if not xml[tag].virtual then
      local isChild = false
      for st in pairs(supertypesOf(xml, tag)) do
        for _, kids in pairs(children) do
          if kids[st] then
            isChild = true
            break
          end
        end
        if isChild then
          break
        end
      end
      if not isChild then
        result[tag] = true
      end
    end
  end
  return result
end

return {
  chains = chains,
  roots = roots,
}
