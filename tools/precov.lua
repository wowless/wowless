local state = 'WANT_FILE'
local num_numbers, filename
for line in io.lines() do
  if state == 'WANT_FILE' then
    num_numbers, filename = line:match('^(%d+):([a-zA-Z/\\_0-9.-]+.lua)$')
    if num_numbers and filename then
      num_numbers = tonumber(num_numbers)
      state = 'WANT_DATA'
    end
  elseif state == 'WANT_DATA' then
    if select(2, line:gsub('(%d+)', '')) == num_numbers then
      print(string.format('%d:%s', num_numbers, filename:gsub('\\', '/')))
      print(line)
    end
    state = 'WANT_FILE'
  end
end
