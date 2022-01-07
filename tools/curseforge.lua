local json = require('JSON')

local flavors = {
  Mainline = 517,   -- wow_retail
  TBC = 73246,      -- wow_burning_crusade
  Vanilla = 67408,  -- wow_classic
}

local function main(cfid)
  local pipe = io.popen('wget -qO- https://addons-ecs.forgesvc.net/api/v2/addon/' .. cfid)
  local cfg = json:decode(pipe:read('*all'))
  pipe:close()
  local latestFilesMap = {}
  for _, f in ipairs(cfg.latestFiles) do
    latestFilesMap[f.id] = f
  end
  table.sort(cfg.gameVersionLatestFiles, function(a, b)
    if a.fileType < b.fileType then
      return true
    elseif a.fileType > b.fileType then
      return false
    else
      return a.projectFileId > b.projectFileId
    end
  end)
  for wowFlavor, cfFlavor in pairs(flavors) do
    for _, gvFile in ipairs(cfg.gameVersionLatestFiles) do
      local file = latestFilesMap[gvFile.projectFileId]
      if gvFile.gameVersionTypeId == cfFlavor and
          not file.displayName:match('-nolib') and
          not file.isAlternate then
        local dir = ('extracts/addons/%d-%s/Interface/AddOns'):format(cfid, wowFlavor)
        os.execute(table.concat({
          ('mkdir -p "%s"'):format(dir),
          ('cd "%s"'):format(dir),
          ('wget -q "%s"'):format(file.downloadUrl),
          'unzip -q *.zip',
          'rm *.zip',
        }, '&&'))
        break
      end
    end
  end
end

main(unpack(arg))
