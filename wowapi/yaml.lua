local parse = require('wowapi.cyaml').parse
local pprint = require('wowapi.cyaml').pprint

return {
  parse = parse,
  parseFile = function(f)
    local file = assert(io.open(f, 'r'), 'failed to open ' .. tostring(f))
    local str = file:read('*all')
    file:close()
    return assert(parse(str), 'could not parse ' .. tostring(f) .. ' as yaml')
  end,
  pprint = pprint,
}
