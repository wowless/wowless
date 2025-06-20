local _, G = ...

local tkeys = {
  edges = 'table',
  func = 'function',
  loop = 'boolean',
  to = 'string',
}

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
    local t = next(edges[init][k])
    assert(t, 'no way to ' .. k .. ' from ' .. init) -- TODO generalize
    frominit[k] = t
  end
  local toinit = {}
  for k, v in pairs(edges) do
    local t = next(v[init])
    assert(t, 'no way back to ' .. init .. ' from ' .. k) -- TODO generalize
    toinit[k] = t
  end
  local function trimerr(s)
    local _, n = s:find(':%d+: ')
    return n and s:sub(n + 1) or s
  end
  local function checkState(s, n)
    local success, msg = pcall(states[s], arg)
    if not success then
      error(('%s state: %s'):format(n, trimerr(msg)))
    end
  end
  local function checkTransition(t, n)
    local success, msg = pcall(transitions[t].func, arg)
    if not success then
      error(('%s transition: %s'):format(n, trimerr(msg)))
    end
  end
  for from, tos in pairs(edges) do
    for to, ts in pairs(tos) do
      for t in pairs(ts) do
        local success, msg = pcall(function()
          checkState(init, 'init')
          checkTransition(frominit[from], 'init -> from')
          checkState(from, 'from')
          checkTransition(t, 'from -> to')
          checkState(to, 'to')
          checkTransition(toinit[to], 'to -> init')
          checkState(init, 'postinit(' .. toinit[to] .. ')')
        end)
        if not success then
          error(('failure on %s -> %s transition %s: %s'):format(from, to, t, trimerr(msg)))
        end
      end
    end
  end
end

G.checkStateMachine = checkStateMachine
