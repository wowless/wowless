return function(datalua)
  return require('build.products.' .. datalua.product .. '.uiobjmodel')()
end
