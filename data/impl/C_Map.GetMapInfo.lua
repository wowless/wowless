local uimapdb, uimapid = ...
for row in uimapdb() do
  if row.ID == uimapid then
    return {
      flags = row.Flags,
      mapID = row.ID,
      mapType = row.Type,
      name = row.Name_lang,
      parentMapID = row.ParentUiMapID,
    }
  end
end
