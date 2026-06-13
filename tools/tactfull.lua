local curl = require('tools.tactfull_curl')

local PORT_FILE = 'tactfull.port'
local IS_WINDOWS = package.config:sub(1, 1) == '\\'

local function read_port()
  local f = io.open(PORT_FILE, 'r')
  if not f then
    return nil
  end
  local n = tonumber(f:read('*n'))
  f:close()
  return n
end

local function base_url(port)
  return string.format('http://127.0.0.1:%d', port)
end

local function health_check(port)
  return curl.health(base_url(port) .. '/health')
end

local function ensure_server()
  local port = read_port()
  if port and health_check(port) then
    return port
  end
  if IS_WINDOWS then
    os.execute('start "" /B tactfull-server >tactfull.log 2>&1')
  else
    os.execute('tactfull-server </dev/null >>tactfull.log 2>&1 &')
  end
  for _ = 1, 20 do
    curl.sleep_ms(100)
    port = read_port()
    if port and health_check(port) then
      return port
    end
  end
  return nil
end

local function open(product, hash)
  local port = ensure_server()
  assert(port, 'failed to start tactfull server')
  local base = string.format('%s/%s/%s/', base_url(port), product, hash)
  return function(name_or_fdid)
    local suffix
    if type(name_or_fdid) == 'number' then
      suffix = 'fdid/' .. name_or_fdid
    else
      suffix = 'name/' .. name_or_fdid
    end
    return curl.get(base .. suffix)
  end
end

return { open = open }
