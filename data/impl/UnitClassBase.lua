local chrclasses, unit = ...
if unit then
  for row in chrclasses() do
    if row.ID == unit.class then
      return row.Filename, row.ID
    end
  end
end
