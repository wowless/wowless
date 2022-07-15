local loader = ...
local p = loader.product
if p == 'wow_classic_era' or p == 'wow_classic_era_ptr' then
  return '1.14.3', '44403', 'Jun 27 2022', 11403
elseif p == 'wow_classic' or p == 'wow_classic_ptr' then
  return '2.5.4', '44400', 'Jun 27 2022', 20504
elseif p == 'wow_classic_beta' then
  return '3.4.0', '44644', 'Jul 12 2022', 30400
elseif p == 'wow' or p == 'wowt' then
  return '9.2.5', '44325', 'Jun 22 2022', 90205
else
  error('invalid version')
end
