SELECT
  InternalName,
  Name_lang
FROM
  FactionGroup
WHERE
  InternalName == ?1;
