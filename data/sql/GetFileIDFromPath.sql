SELECT ID FROM ManifestInterfaceData
WHERE
  FilePath = $1 COLLATE NOCASE -- noqa
  AND
  FileName = $2 COLLATE NOCASE -- noqa
