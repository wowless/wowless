local uimapdb, uimapid = ...
local row = uimapdb(uimapid)
if row then
  return {
    flags = row.Flags,
    mapID = row.ID,
    mapType = row.Type,
    name = row.Name_lang,
    parentMapID = row.ParentUiMapID,
  }
end
