SELECT
  Level as level,
  FALSE as isCapstone,
  FALSE as isMilestone,
  FALSE as locked
FROM
  RenownRewards
WHERE
  CovenantID == ?1
ORDER BY
  Level;
