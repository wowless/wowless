local _, G = ...

local function levenshtein(s, t)
  local m, n = #s, #t
  local d = {}
  for i = 0, m do
    d[i] = {}
    d[i][0] = i
  end
  for j = 0, n do
    d[0][j] = j
  end
  for i = 1, m do
    for j = 1, n do
      if s:byte(i) == t:byte(j) then
        d[i][j] = d[i - 1][j - 1]
      else
        d[i][j] = 1 + math.min(d[i - 1][j], d[i][j - 1], d[i - 1][j - 1])
      end
    end
  end
  return d[m][n]
end

local function arraydiff(a, b)
  local m, n = #a, #b
  local dp = {}
  for i = 0, m do
    dp[i] = {}
    for j = 0, n do
      if i == 0 or j == 0 then
        dp[i][j] = 0
      elseif a[i] == b[j] then
        dp[i][j] = dp[i - 1][j - 1] + 1
      else
        dp[i][j] = math.max(dp[i - 1][j], dp[i][j - 1])
      end
    end
  end
  local ops = {}
  local k = 0
  local i, j = m, n
  while i > 0 or j > 0 do
    if i > 0 and j > 0 and a[i] == b[j] then
      k = k + 1
      ops[k] = { op = 'keep' }
      i = i - 1
      j = j - 1
    elseif j > 0 and (i == 0 or dp[i][j - 1] >= dp[i - 1][j]) then
      k = k + 1
      ops[k] = { op = 'insert', bj = j }
      j = j - 1
    else
      k = k + 1
      ops[k] = { op = 'delete', ai = i }
      i = i - 1
    end
  end
  for p = 1, k / 2 do
    ops[p], ops[k + 1 - p] = ops[k + 1 - p], ops[p]
  end
  local result = {}
  local r = 0
  local p = 1
  while p <= k do
    local entry = ops[p]
    if entry.op == 'keep' then
      p = p + 1
    elseif entry.op == 'delete' and p + 1 <= k and ops[p + 1].op == 'insert' then
      local va = a[entry.ai]
      local vb = b[ops[p + 1].bj]
      if 2 * levenshtein(va, vb) <= math.max(#va, #vb) then
        r = r + 1
        result[r] = { op = 'change', idx = entry.ai, expected = va, actual = vb }
      else
        r = r + 1
        result[r] = { op = 'delete', idx = entry.ai, value = va }
        r = r + 1
        result[r] = { op = 'insert', idx = ops[p + 1].bj, value = vb }
      end
      p = p + 2
    elseif entry.op == 'delete' then
      r = r + 1
      result[r] = { op = 'delete', idx = entry.ai, value = a[entry.ai] }
      p = p + 1
    else
      r = r + 1
      result[r] = { op = 'insert', idx = entry.bj, value = b[entry.bj] }
      p = p + 1
    end
  end
  return result
end

G.arraydiff = arraydiff
