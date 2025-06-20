return function(s)
  local sx = require('pl.stringx')
  return sx.strip(sx.split(s, ';')[1] or ''), nil
end
