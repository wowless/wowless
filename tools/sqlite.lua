local lsqlite3 = require('lsqlite3')

local quote = (function()
  local moo = require('luasql.sqlite3').sqlite3():connect('')
  return function(s)
    return '\'' .. moo:escape(s) .. '\''
  end
end)()

local function factory(theProduct)
  local defs = {}
  for _, file in ipairs(require('pl.dir').getfiles('data/dbdefs')) do
    local dbdef = require('wowapi.yaml').parseFile(file)
    for _, version in ipairs(dbdef.versions) do
      for _, product in ipairs(version.products) do
        if product == theProduct then
          local fields = {}
          for k in pairs(version.fields) do
            table.insert(fields, k)
          end
          table.sort(fields, function(a, b)
            return version.fields[a] < version.fields[b]
          end)
          defs[dbdef.name] = {
            fields = fields,
            version = version,
          }
        end
      end
    end
  end

  local function create(filename)
    local dbinit = { 'BEGIN' }
    for k, v in pairs(defs) do
      table.insert(dbinit, ('CREATE TABLE %s (%s)'):format(k, table.concat(v.fields, ',')))
    end
    table.insert(dbinit, 'COMMIT')
    table.insert(dbinit, '')
    local db = filename and lsqlite3.open(filename) or lsqlite3.open_memory()
    if db:exec(table.concat(dbinit, ';\n')) ~= lsqlite3.OK then
      error('sqlite failure: ' .. db:errmsg())
    end
    return db
  end

  local function populate(db)
    local dbinit = { 'BEGIN' }
    for k, v in pairs(defs) do
      local success, msg = pcall(function()
        local data = require('pl.file').read(('extracts/%s/db2/%s.db2'):format(theProduct, k))
        assert(data, 'missing db2 for ' .. k)
        for row in require('dbc').rows(data, '{' .. v.version.sig:gsub('%.', '%?') .. '}') do
          local values = {}
          for _, field in ipairs(v.fields) do
            local value = row[v.version.fields[field]]
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
    table.insert(dbinit, 'COMMIT')
    table.insert(dbinit, '')
    assert(db:exec(table.concat(dbinit, ';\n')) == lsqlite3.OK)
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
