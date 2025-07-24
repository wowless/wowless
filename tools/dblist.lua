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
    GlobalStrings = {},
  }
  local impls = dofile('build/cmake/runtime/impl.lua')
  local sqlcfgs = dofile('build/cmake/runtime/sql.lua')
  local productapis = dofile('build/cmake/runtime/products/' .. product .. '/apis.lua')
  local sqls = {}
  for _, api in pairs(productapis) do
    local impl = impls[api.impl]
    if impl then
      for _, sql in ipairs(impl.impl and impl.impl.sqls or { impl.directsql }) do
        sqls[sql] = true
      end
    end
  end
  for sql in pairs(sqls) do
    -- We are fortunate that sqlite complains about missing tables first.
    local sqltext = readFile('data/sql/' .. sql .. '.sql')
    local db = require('lsqlite3').open_memory()
    local tables = {}
    while not db:prepare(sqltext) do
      local t = db:errmsg():match('^no such table: (%a+)$')
      if t then
        tables[t] = {}
        assert(db:exec('CREATE TABLE ' .. t .. ' (moo INTEGER)') == 0)
      else
        break
      end
    end
    for tab, idx in pairs(sqlcfgs[sql].indexes or {}) do
      assert(tables[tab], ('index on %q for unused table %q'):format(sql, tab))
      tables[tab][idx] = true
    end
    for k, v in pairs(tables) do
      dbset[k] = dbset[k] or {}
      for vk, vv in pairs(v) do
        assert(dbset[k][vk] == nil or dbset[k][vk] == vv)
        dbset[k][vk] = vv
      end
    end
  end
  for k, v in pairs(dbset) do
    local vv = {}
    for vk in pairs(v) do
      table.insert(vv, vk)
    end
    table.sort(vv)
    dbset[k] = vv
  end
  return dbset
end

local u = require('tools.util')
local outfn = 'build/products/' .. args.product .. '/dblist.lua'
local out = dblist(args.product)
u.writedeps(outfn, deps)
u.writeifchanged(outfn, u.returntable(out))
