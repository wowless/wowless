SELECT
  DISTINCT Level AS level
FROM
  RenownRewards
WHERE
  CovenantID == ?1
ORDER BY
  Level;
