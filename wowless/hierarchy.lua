-- Queries over, and declaration edits to, a data domain shaped like the
-- `hierarchy` schematype (see wowapi/schema.lua): a map of named nodes, each
-- naming its parents in the schema's `parent` field, either as a single name
-- or as a set of names. `spec` is that schematype's own table (`fields`,
-- `parent`, `unique`), e.g. the parsed data/schemas/uiobjects.yaml's
-- type.hierarchy.
--
-- The schema rejects cycles and multiple paths between two nodes, so every
-- ancestor is reachable along exactly one path; this module relies on that
-- rather than rechecking it. Results are memoized and must not be modified
-- by callers. Nodes' parent fields must not change after new(); member
-- fields may, but only through assign(), which keeps the memoized
-- flattenings consistent.

local function deepcopy(v)
  if type(v) ~= 'table' then
    return v
  end
  local t = {}
  for k, x in pairs(v) do
    t[k] = deepcopy(x)
  end
  return t
end

local function new(nodes, spec)
  local parentfield = assert(spec.parent, 'hierarchy spec has no parent field')
  local fields = assert(spec.fields, 'hierarchy spec has no fields')

  local function node(k)
    return assert(nodes[k], 'unknown node ' .. tostring(k))
  end

  local function schemafield(field)
    assert(field ~= parentfield, 'cannot use the parent field as a member field')
    return assert(fields[field], 'unknown field ' .. tostring(field))
  end

  local parentlists = {}
  local function parents(k)
    local ps = parentlists[k]
    if not ps then
      local p = node(k)[parentfield]
      ps = {}
      if type(p) == 'string' then
        ps[1] = p
      elseif p ~= nil then
        for pk in pairs(p) do
          table.insert(ps, pk)
        end
        table.sort(ps)
      end
      for _, pk in ipairs(ps) do
        node(pk)
      end
      parentlists[k] = ps
    end
    return ps
  end

  local childsets
  local function children(k)
    node(k)
    if not childsets then
      childsets = {}
      for ck in pairs(nodes) do
        childsets[ck] = {}
      end
      for ck in pairs(nodes) do
        for _, pk in ipairs(parents(ck)) do
          childsets[pk][ck] = true
        end
      end
    end
    return childsets[k]
  end

  -- Memoized transitive closure of `step` (parents or children), excluding k.
  local function closure(cache, step)
    local function walk(k)
      local r = cache[k]
      if not r then
        r = {}
        for _, n in ipairs(step(k)) do
          r[n] = true
          for a in pairs(walk(n)) do
            r[a] = true
          end
        end
        cache[k] = r
      end
      return r
    end
    return walk
  end

  local ancestors = closure({}, parents)
  local descendants = closure({}, function(k)
    local cs = {}
    for ck in pairs(children(k)) do
      table.insert(cs, ck)
    end
    return cs
  end)

  -- flatcache[field][k] = { members = ..., from = ... }
  local flatcache = {}
  local function doflatten(k, field)
    local fc = flatcache[field]
    if not fc then
      schemafield(field)
      fc = {}
      flatcache[field] = fc
    end
    local r = fc[k]
    if not r then
      local members, from, conflicts = {}, {}, {}
      for _, pk in ipairs(parents(k)) do
        local pr = doflatten(pk, field)
        for mk, mv in pairs(pr.members) do
          if from[mk] and from[mk] ~= pr.from[mk] then
            conflicts[mk] = { from[mk], pr.from[mk] }
          end
          members[mk] = mv
          from[mk] = pr.from[mk]
        end
      end
      for mk, mv in pairs(node(k)[field] or {}) do
        members[mk] = mv
        from[mk] = k
        conflicts[mk] = nil
      end
      local mk, c = next(conflicts)
      if mk then
        table.sort(c)
        error(('%s.%s.%s is inherited from both %s and %s'):format(k, field, mk, c[1], c[2]), 0)
      end
      r = { from = from, members = members }
      fc[k] = r
    end
    return r
  end

  -- The members of `field` that k has, declared on itself or inherited, with
  -- its own declarations taking precedence; and, as a second value, which
  -- node each one is declared on. A member inherited along two parent paths
  -- from two different declarations is an error unless k declares it itself.
  local function flatten(k, field)
    local r = doflatten(k, field)
    return r.members, r.from
  end

  -- The node k gets `field` member `key` from (k itself or an ancestor), or
  -- nil if k doesn't have it.
  local function declarer(k, field, key)
    return doflatten(k, field).from[key]
  end

  -- Where to declare a member so that, among eligible nodes, exactly those
  -- in `set` have it, with no node inheriting it from two declarations.
  -- `eligible` (default: every node) restricts which nodes matter, e.g. to
  -- the non-virtual types a test actually exercises; ineligible nodes may
  -- gain or lose the member freely.
  --
  -- Candidates are the highest nodes whose eligible selves-and-descendants
  -- all lie in `set`, tried largest (by that eligible count) first, then by
  -- name. A candidate sharing a descendant with an already-chosen one (only
  -- possible through a multi-parent node) is replaced by its children, so
  -- e.g. a type with a second, mixin-like parent gets the member through
  -- whichever parent was chosen first. Errors if some node in `set` can't
  -- be covered, which happens when it has an eligible descendant outside
  -- `set`, or when it can only be covered by overlapping declarations.
  local function cover(set, eligible)
    eligible = eligible or function()
      return true
    end
    for k in pairs(set) do
      node(k)
      assert(eligible(k), k .. ' is not eligible')
    end
    local below = {}
    local function under(k)
      local r = below[k]
      if not r then
        r = { n = 0, set = {} }
        local function add(d)
          if not r.set[d] then
            r.set[d] = true
            r.n = r.n + 1
          end
        end
        if eligible(k) then
          add(k)
        end
        for ck in pairs(children(k)) do
          for d in pairs(under(ck).set) do
            add(d)
          end
        end
        below[k] = r
      end
      return r
    end
    local full = {}
    for k in pairs(nodes) do
      local u = under(k)
      local isfull = u.n > 0
      for d in pairs(u.set) do
        isfull = isfull and set[d] or false
      end
      full[k] = isfull
    end
    local tops = {}
    for k, isfull in pairs(full) do
      local top = isfull
      for _, pk in ipairs(parents(k)) do
        top = top and not full[pk]
      end
      if top then
        table.insert(tops, k)
      end
    end
    table.sort(tops, function(a, b)
      local na, nb = under(a).n, under(b).n
      if na ~= nb then
        return na > nb
      end
      return a < b
    end)
    local result, claimed = {}, {}
    local function place(k)
      if claimed[k] then
        return
      end
      local free = true
      for d in pairs(descendants(k)) do
        free = free and not claimed[d]
      end
      if free then
        result[k] = true
        claimed[k] = true
        for d in pairs(descendants(k)) do
          claimed[d] = true
        end
      else
        local cs = {}
        for ck in pairs(children(k)) do
          if full[ck] then
            table.insert(cs, ck)
          end
        end
        table.sort(cs)
        for _, ck in ipairs(cs) do
          place(ck)
        end
      end
    end
    for _, k in ipairs(tops) do
      place(k)
    end
    local missing = {}
    for k in pairs(set) do
      if not claimed[k] then
        table.insert(missing, k)
      end
    end
    if next(missing) then
      table.sort(missing)
      error('no placement gives exactly the requested set; cannot cover: ' .. table.concat(missing, ', '), 0)
    end
    return result
  end

  -- Rewrites every declaration of `field` member `key` so that, among
  -- eligible nodes, exactly those in `want` have it: removes all existing
  -- declarations, then declares a copy of `value` on each node of
  -- cover(want, eligible). A field emptied this way is dropped unless the
  -- schema marks it required. Errors before changing anything if `want` is
  -- not achievable. Returns the set of nodes now declaring `key`.
  local function assign(field, key, want, eligible, value)
    local fs = schemafield(field)
    assert(value ~= nil, 'assign needs a value')
    local decl = cover(want, eligible)
    for _, n in pairs(nodes) do
      local t = n[field]
      if t and t[key] ~= nil then
        t[key] = nil
        if next(t) == nil and not fs.required then
          n[field] = nil
        end
      end
    end
    for k in pairs(decl) do
      local n = nodes[k]
      n[field] = n[field] or {}
      n[field][key] = deepcopy(value)
    end
    flatcache[field] = nil
    return decl
  end

  return {
    ancestors = ancestors,
    assign = assign,
    children = children,
    cover = cover,
    declarer = declarer,
    descendants = descendants,
    flatten = flatten,
    parents = parents,
  }
end

return {
  new = new,
}
