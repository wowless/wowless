local sx = require('pl.stringx')
return {
  api = {
    SecureCmdOptionParse = function(s)
      return sx.strip(sx.split(s, ';')[1] or '')
    end,
  },
}
