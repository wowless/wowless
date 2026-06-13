local serve = require('tools.tactfull_http')
local tactless = require('tactless')

local SOCKET = 'tactfull.sock'
local EXPIRY = 1800 -- 30 minutes
local IDLE_INTERVAL = 60

local pool = {}
local last_request = os.time()

local function get_conn(product, hash)
  local key = product .. '/' .. hash
  local conn = pool[key]
  local now = os.time()
  if conn and now - conn.last_used > EXPIRY then
    pool[key] = nil
    conn = nil
  end
  if not conn then
    local handle = tactless(product, hash)
    if not handle then
      return nil
    end
    conn = { handle = handle, last_used = now }
    pool[key] = conn
  else
    conn.last_used = now
  end
  return conn
end

local function handler(path)
  if path == '/health' then
    return ''
  end
  local product, hash, kind, key = path:match('^/([^/]+)/([^/]+)/(name|fdid)/(.+)$')
  if not product then
    return nil
  end
  local conn = get_conn(product, hash)
  if not conn then
    return nil
  end
  local arg = kind == 'fdid' and tonumber(key) or key
  last_request = os.time()
  return conn.handle(arg)
end

local function on_idle()
  local now = os.time()
  for k, conn in pairs(pool) do
    if now - conn.last_used > EXPIRY then
      pool[k] = nil
    end
  end
  return now - last_request < EXPIRY
end

serve(SOCKET, handler, on_idle, IDLE_INTERVAL)
