local args = (function()
  local parser = require('argparse')()
  parser:argument('product', 'product to fetch')
  return parser:parse()
end)()

local parseYaml = require('wowapi.yaml').parseFile

local function dblist(product)
  local dbset = {
    GlobalStrings = true,
    ManifestInterfaceTOCData = true,
  }
  local impls = parseYaml('data/impl.yaml')
  local productapis = parseYaml('data/products/' .. product .. '/apis.yaml')
  local sqls = {}
  for _, api in pairs(productapis) do
    local impl = impls[api.impl]
    if impl then
      for _, db in ipairs(impl.dbs or {}) do
        dbset[db.name] = true
      end
      for _, sql in ipairs(impl.sqls or {}) do
        local kk = sql.lookup and 'lookup' or 'cursor'
        table.insert(sqls, kk .. '/' .. sql[kk])
      end
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
  local t = {}
  for db in pairs(dbset) do
    table.insert(t, db)
  end
  table.sort(t)
  return t
end

local u = require('tools.util')
local out = 'build/products/' .. args.product .. '/dblist.lua'
u.writeifchanged(out, u.returntable(dblist(args.product)))
