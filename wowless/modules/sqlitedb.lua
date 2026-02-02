return function(datalua, loadercfg)
  local base = loadercfg.rootDir and 'data' or 'schema'
  local file = ('build/cmake/%s_%s.sqlite3'):format(datalua.product, base)
  return require('wowless.sqlite').open(file)
end
