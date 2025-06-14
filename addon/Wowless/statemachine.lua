local _, G = ...

local function checkStateMachine(states, transitions, init, arg)
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
    else
      for s in pairs(states) do
        edges[s][v.to or s][k] = true
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
