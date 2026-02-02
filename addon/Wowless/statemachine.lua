local _, G = ...

local tkeys = {
  edges = 'table',
  func = 'function',
  loop = 'boolean',
  to = 'string',
}

local function bfs(edges, from, to)
  local q = { { from } }
  if from == to then
    return q[1]
  end
  repeat
    local e = q[#q]
    q[#q] = nil
    for k, v in pairs(edges[e[#e]]) do
      if next(v) then
        local p = {}
        local loop = false
        for pk, pv in ipairs(e) do
          p[pk] = pv
          loop = loop or k == pv
        end
        p[#p + 1] = k
        if k == to then
          return p
        elseif not loop then
          q[#q + 1] = p
        end
      end
    end
  until not next(q)
  error(('failed to find a path from %q to %q'):format(from, to), 0)
end

local function checkStateMachine(states, transitions, init, arg)
  assert(type(states) == 'table', 'states must be a table')
  for k, v in pairs(states) do
    assert(type(k) == 'string', 'invalid key in states')
    assert(type(v) == 'function', 'invalid value in states')
  end
  assert(states[init], 'init must name a state')
  for k, v in pairs(transitions) do
    assert(type(k) == 'string', 'invalid key in transitions')
    assert(type(v) == 'table', 'invalid value in transitions')
    local nk = 0
    for vk, vv in pairs(v) do
      assert(type(vv) == tkeys[vk], ('transition %q has invalid key %q'):format(k, vk))
      nk = nk + 1
    end
    assert(v.func, ('transition %q missing func'):format(k))
    assert(nk == 2, ('transition %q has too many keys'):format(k))
    if v.edges then
      for ek, ev in pairs(v.edges) do
        assert(states[ek], ('transition %q edge from %q is not a state'):format(k, ek))
        assert(states[ev], ('transition %q edge to %q is not a state'):format(k, ev))
      end
    elseif v.loop ~= nil then
      assert(v.loop == true, ('transition %q has a weird loop spec'):format(k))
    elseif v.to then
      assert(states[v.to], ('transition %q to is not a state'):format(k))
    end
  end
  local edges = {}
  for s in pairs(states) do
    edges[s] = {}
    for ss in pairs(states) do
      edges[s][ss] = {}
    end
  end
  for k, v in pairs(transitions) do
    if v.edges then
      for from, to in pairs(v.edges) do
        edges[from][to][k] = true
      end
    elseif v.loop then
      for s in pairs(states) do
        edges[s][s][k] = true
      end
    elseif v.to then
      for s in pairs(states) do
        edges[s][v.to][k] = true
      end
    end
  end
  local frominit = {}
  for k in pairs(edges) do
    frominit[k] = bfs(edges, init, k)
  end
  local toinit = {}
  for k in pairs(edges) do
    toinit[k] = bfs(edges, k, init)
  end
  local function checkState(s)
    local success, msg = pcall(states[s], arg)
    if not success then
      error(('%s state: %s'):format(s, msg), 0)
    end
  end
  local function checkTransition(from, to, t)
    local success, msg = pcall(transitions[t].func, arg)
    if not success then
      error(('%s transition from %s to %s: %s'):format(t, from, to, msg), 0)
    end
    success, msg = pcall(states[to], arg)
    if not success then
      error(('%s transition from %s to %s poststate: %s'):format(t, from, to, msg), 0)
    end
  end
  local function checkPath(p)
    for i = 2, #p do
      local from, to = p[i - 1], p[i]
      -- Just take the first available transition, we don't care what it is.
      local transition = next(edges[from][to])
      checkTransition(from, to, transition)
    end
  end
  checkState(init)
  for from, tos in pairs(edges) do
    for to, ts in pairs(tos) do
      for t in pairs(ts) do
        checkPath(frominit[from])
        checkTransition(from, to, t)
        checkPath(toinit[to])
      end
    end
  end
end

G.checkStateMachine = checkStateMachine
