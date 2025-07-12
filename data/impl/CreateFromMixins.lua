local mixin = require('wowless.util').mixin
return function(...)
  return mixin({}, ...)
end
