local sx = require('pl.stringx')
return {
  api = function()
    return {
      SecureCmdOptionParse = function(s)
        return sx.strip(sx.split(s, ';')[1] or '')
      end,
    }
  end,
}
