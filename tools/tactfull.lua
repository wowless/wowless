local curl = require('tools.tactfull_curl')

local SOCKET = 'tactfull.sock'

local function ensure_server()
  if curl.health(SOCKET) then
    return true
  end
  os.execute('tactfull-server </dev/null >>tactfull.log 2>&1 &')
  for _ = 1, 20 do
    curl.sleep_ms(100)
    if curl.health(SOCKET) then
      return true
    end
  end
  return false
end

local function open(product, hash)
  assert(ensure_server(), 'failed to start tactfull server')
  local base = string.format('http://localhost/%s/%s/', product, hash)
  return function(name_or_fdid)
    local url
    if type(name_or_fdid) == 'number' then
      url = base .. 'fdid/' .. name_or_fdid
    else
      url = base .. 'name/' .. name_or_fdid
    end
    return curl.get(SOCKET, url)
  end
end

return { open = open }
