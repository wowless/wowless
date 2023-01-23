local lsqlite3 = require('lsqlite3')

local quote = (function()
  local moo = require('luasql.sqlite3').sqlite3():connect('')
  return function(s)
    return '\'' .. moo:escape(s) .. '\''
  end
end)()

local function factory(theProduct)
  local defs = (function()
    local build = require('wowapi.yaml').parseFile('data/products/' .. theProduct .. '/build.yaml')
    local bv = build.version .. '.' .. build.build
    local t = {}
    for _, db in ipairs(require('build.products.' .. theProduct .. '.dblist')) do
      local content = assert(require('pl.file').read('vendor/dbdefs/definitions/' .. db .. '.dbd'))
      local dbd = assert(require('luadbd.parser').dbd(content))
      local v = (function()
        for _, version in ipairs(dbd.versions) do
          for _, vb in ipairs(version.builds) do
            -- Build ranges are not supported (yet).
            if #vb == 1 and table.concat(vb[1], '.') == bv then
              return version
            end
          end
        end
        error('cannot find ' .. bv .. ' in dbd ' .. db)
      end)()
      local sig, field2index = require('luadbd.sig')(dbd, v)
      t[db] = {
        field2index = field2index,
        orderedfields = (function()
          local list = {}
          for k in pairs(field2index) do
            table.insert(list, k)
          end
          table.sort(list, function(a, b)
            return field2index[a] < field2index[b]
          end)
          return list
        end)(),
        sig = sig,
      }
    end
    return t
  end)()

  local function create(filename)
    local dbinit = { 'BEGIN' }
    for k, v in pairs(defs) do
      table.insert(dbinit, ('CREATE TABLE %s ("%s")'):format(k, table.concat(v.orderedfields, '","')))
    end
    table.insert(dbinit, 'COMMIT')
    table.insert(dbinit, '')
    local db = filename and lsqlite3.open(filename) or lsqlite3.open_memory()
    if db:exec(table.concat(dbinit, ';\n')) ~= lsqlite3.OK then
      error('sqlite failure: ' .. db:errmsg() .. '\n' .. table.concat(dbinit, ';\n'))
    end
    return db
  end

  local function populate(db)
    local dbinit = { 'BEGIN' }
    for k, v in pairs(defs) do
      local success, msg = pcall(function()
        local data = require('pl.file').read(('extracts/%s/db2/%s.db2'):format(theProduct, k))
        assert(data, 'missing db2 for ' .. k)
        for row in require('dbc').rows(data, '{' .. v.sig:gsub('%.', '%?') .. '}') do
          local values = {}
          for _, field in ipairs(v.orderedfields) do
            local value = row[v.field2index[field]]
            local ty = type(value)
            if ty == 'table' then
              value = value[1]
              ty = type(value)
            end
            if ty == 'nil' then
              value = 'NULL'
            elseif ty == 'string' then
              value = quote(value)
            elseif ty == 'number' then
              value = tostring(value)
            else
              error('unexpected value of type ' .. ty .. ' on field ' .. field .. ' of table ' .. k)
            end
            table.insert(values, value)
          end
          table.insert(dbinit, ('INSERT INTO %s VALUES (%s)'):format(k, table.concat(values, ',')))
        end
      end)
      if not success then
        error('failed to populate ' .. k .. ': ' .. msg)
      end
    end
    table.insert(dbinit, 'CREATE INDEX MooIndex ON UiTextureAtlasMember (CommittedName COLLATE NOCASE)')
    table.insert(dbinit, 'CREATE INDEX CowIndex ON UiTextureAtlas (ID)')
    table.insert(dbinit, 'COMMIT')
    table.insert(dbinit, '')
    if db:exec(table.concat(dbinit, ';\n')) ~= lsqlite3.OK then
      error('sqlite failure: ' .. db:errmsg())
    end
  end

  return create, populate
end

local args = (function()
  local parser = require('argparse')()
  parser:argument('product', 'product to fetch')
  parser:flag('-f --full', 'also include data')
  return parser:parse()
end)()
local filebase = args.full and 'data' or 'schema'
local filename = ('build/products/%s/%s.db'):format(args.product, filebase)
require('pl.file').delete(filename)
local create, populate = factory(args.product)
local db = create(filename)
if args.full then
  populate(db)
end
db:close()
