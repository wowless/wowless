local function connect(authority)
  local host, port = require('http.util').split_authority(authority)
  local conn = require('http.client').connect({
    host = host,
    port = port,
    tls = false,
  })
  local mkreq = require('http.headers').new
  local function fetch(stream, path)
    local req = mkreq()
    req:append(':authority', authority)
    req:append(':method', 'GET')
    req:append(':path', path)
    assert(stream:write_headers(req, true))
    local res = assert(stream:get_headers())
    if res:get(':status') == '200' then
      return stream:get_body_as_string()
    end
  end
  local function stream(path)
    local s = assert(conn:new_stream())
    local success, data = pcall(function()
      return fetch(s, path)
    end)
    s:shutdown()
    return success and data or nil
  end
  return function(path)
    local success, data = pcall(function()
      return stream(path)
    end)
    return success and data or nil
  end
end

return {
  connect = connect,
}
