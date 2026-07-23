SELECT d.Text_lang
FROM EmotesText AS t
INNER JOIN EmotesTextData AS d ON t.ID = d.EmotesTextID
WHERE
  d.RelationshipFlags = 6
  AND t.Name = $1;
