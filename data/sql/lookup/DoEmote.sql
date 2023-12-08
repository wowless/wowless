SELECT d.Text_lang
FROM EmotesText t
JOIN EmotesTextData d ON d.EmotesTextID = t.ID
WHERE d.RelationshipFlags = 6
  AND t.Name = $1;
