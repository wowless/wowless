local chrclassesxpowertypes, powertype, unit = ...
if unit then
  for join in chrclassesxpowertypes() do
    if join.ClassID == unit.class then
      for row in powertype() do
        if join.PowerType == row.ID then
          return row.PowerTypeEnum, row.NameGlobalStringTag
        end
      end
    end
  end
end
