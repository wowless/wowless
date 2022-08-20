return function(product)
  local dbset = {
    GlobalStrings = true,
    ManifestInterfaceTOCData = true,
  }
  local productapis = require('wowapi.yaml').parseFile('data/products/' .. product .. '/apis.yaml')
  local allapis = require('wowapi.data').apis
  local sqls = {}
  for _, apiname in pairs(productapis) do
    local api = allapis[apiname]
    for _, db in ipairs(api.dbs or {}) do
      dbset[db.name] = true
    end
    for _, sql in ipairs(api.sqls or {}) do
      local kk = sql.lookup and 'lookup' or 'cursor'
      table.insert(sqls, kk .. '/' .. sql[kk])
    end
  end
  for _, sql in ipairs(sqls) do
    -- We are fortunate that sqlite complains about missing tables first.
    local sqltext = assert(require('pl.file').read('data/sql/' .. sql .. '.sql'))
    local db = require('lsqlite3').open_memory()
    while not db:prepare(sqltext) do
      local t = db:errmsg():match('^no such table: (%a+)$')
      if t then
        dbset[t] = true
        assert(db:exec('CREATE TABLE ' .. t .. ' (moo INTEGER)') == 0)
      else
        break
      end
    end
  end
  local dblist = {}
  for db in pairs(dbset) do
    table.insert(dblist, db)
  end
  table.sort(dblist)
  return dblist
end
