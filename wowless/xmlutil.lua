-- Derives XML tag containment from an xml.yaml-shaped schema (contents.tags/
-- extends/text, including the `sealed` flag) -- pure structural computation
-- over that graph, no notion of rendering, tests, or any particular caller's
-- vocabulary. The single implementation shared by wowless/modules/xml.lua's
-- runtime parser (indirectly, via tools/prep.lua's xmlflat, which flattens
-- each tag's supertypes/children once at build time using these) and the
-- build-time tools in tools/xmlcontainment.lua that query the same relation
-- directly over raw (unflattened) product data.

-- A tag's own name plus every ancestor reached by climbing `extends`,
-- lowercased -- climbing stops (without adding that ancestor) once a
-- `sealed` tag is passed, since a sealed tag's own extends-ancestors no
-- longer count as this tag's supertypes for containment purposes.
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

-- The set of (lowercased) supertype names `tag` accepts as direct content,
-- and (as a second return value) whether it accepts text content instead --
-- both flattened across its own `extends` chain (a tag's declared contents
-- are inherited by whatever extends it, same as attributes). Errors if the
-- same child tag name is declared more than once across the chain -- always
-- a schema-authoring mistake, never a legitimate override.
local function childrenOf(xml, tag)
  local kids = {}
  local text = false
  local t = xml[tag]
  while true do
    if t.contents == 'text' then
      text = true
    elseif t.contents then
      for kid in pairs(t.contents.tags) do
        local key = kid:lower()
        assert(not kids[key], kid .. ' is already a child of ' .. tag)
        kids[key] = true
      end
    end
    if not t.extends then
      break
    end
    t = xml[t.extends]
  end
  return kids, text
end

return {
  childrenOf = childrenOf,
  supertypesOf = supertypesOf,
}
