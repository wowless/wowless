local paperdollitemframe, slotName = ...
local arg = string.lower(slotName)
for row in paperdollitemframe() do
  if row.ItemButtonName:lower() == arg then
    return row.SlotNumber, row.SlotIconFileID
  end
end
