local args = (function()
  local parser = require('argparse')()
  parser:argument('product', 'product to fetch')
  return parser:parse()
end)()

local deps = {}

local function readFile(f)
  deps[f] = true
  return (assert(require('pl.file').read(f)))
end

local function dblist(product)
  local dbset = {
    GlobalStrings = true,
    ManifestInterfaceTOCData = true,
  }
  local impls = dofile('build/cmake/runtime/impl.lua')
  local productapis = dofile('build/cmake/runtime/products/' .. product .. '/apis.lua')
  local sqls = {}
  for _, api in pairs(productapis) do
    local impl = impls[api.impl]
    if impl then
      for _, sql in ipairs(impl.sqls or {}) do
        sqls[sql] = true
      end
    end
  end
  for sql in pairs(sqls) do
    -- We are fortunate that sqlite complains about missing tables first.
    local sqltext = readFile('data/sql/' .. sql .. '.sql')
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
local outfn = 'build/products/' .. args.product .. '/dblist.lua'
local out = dblist(args.product)
u.writedeps(outfn, deps)
u.writeifchanged(outfn, u.returntable(out))
