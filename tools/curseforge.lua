local http_request = require('http.request').new_from_uri
local json = require('JSON')

local function main(cfid)
  local url = 'https://addons-ecs.forgesvc.net/api/v2/addon/' .. cfid
  local headers, stream = assert(http_request(url):go())
  assert(headers:get(":status") == "200")
  local cfg = json:decode(assert(stream:get_body_as_string()))
  table.sort(cfg.latestFiles, function(a, b) return a.id > b.id end)
  for _, flavor in ipairs({'wow_classic', 'wow_burning_crusade', 'wow_retail'}) do
    for _, file in ipairs(cfg.latestFiles) do
      if file.gameVersionFlavor == flavor and
          file.releaseType == 1 and
          not file.displayName:match('-nolib') and
          not file.isAlternate then
        print(flavor, file.downloadUrl)
        break
      end
    end
  end
end

main(unpack(arg))
