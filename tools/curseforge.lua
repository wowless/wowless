local json = require('JSON')

local flavors = {
  wow_burning_crusade = 'TBC',
  wow_classic = 'Vanilla',
  wow_retail = 'Mainline',
}

local function main(cfid)
  local pipe = io.popen('wget -qO- https://addons-ecs.forgesvc.net/api/v2/addon/' .. cfid)
  local cfg = json:decode(pipe:read('*all'))
  pipe:close()
  table.sort(cfg.latestFiles, function(a, b)
    if a.releaseType < b.releaseType then
      return true
    elseif a.releaseType > b.releaseType then
      return false
    else
      return a.id > b.id
    end
  end)
  for cfFlavor, wowFlavor in pairs(flavors) do
    for _, file in ipairs(cfg.latestFiles) do
      if file.gameVersionFlavor == cfFlavor and
          not file.displayName:match('-nolib') and
          not file.isAlternate then
        os.execute(([[
          mkdir -p extracts/addons/%s &&
          cd extracts/addons/%s &&
          wget -q "%s" &&
          unzip -q *.zip &&
          rm *.zip
        ]]):format(wowFlavor, wowFlavor, file.downloadUrl))
        break
      end
    end
  end
end

main(unpack(arg))
