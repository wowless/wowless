local loader = ...
if loader.version == 'Vanilla' then
  return '1.14.3', '44403', 'Jun 27 2022', 11403
elseif loader.version == 'TBC' then
  return '2.5.4', '44400', 'Jun 27 2022', 20504
elseif loader.version == 'Mainline' then
  return '9.2.5', '44325', 'Jun 22 2022', 90205
else
  error('invalid version')
end
