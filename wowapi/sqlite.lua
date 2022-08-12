local quote = (function()
  local moo = require('luasql.sqlite3').sqlite3():connect('')
  return function(s)
    return '\'' .. moo:escape(s) .. '\''
  end
end)()

local function mkdb(theProduct)
  local dbinit = { 'BEGIN' }
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
          table.insert(dbinit, ('CREATE TABLE %s (%s)'):format(dbdef.name, table.concat(fields, ',')))
          local data = require('pl.file').read(('extracts/%s/db2/%s.db2'):format(theProduct, dbdef.name:lower()))
          if data then
            for row in require('dbc').rows(data, '{' .. version.sig:gsub('%.', '%?') .. '}') do
              local values = {}
              for _, field in ipairs(fields) do
                local value = row[version.fields[field]]
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
                  error('unexpected value of type ' .. ty .. ' on field ' .. field .. ' of table ' .. dbdef.name)
                end
                table.insert(values, value)
              end
              table.insert(dbinit, ('INSERT INTO %s VALUES (%s)'):format(dbdef.name, table.concat(values, ',')))
            end
          end
        end
      end
    end
  end
  table.insert(dbinit, 'COMMIT')
  table.insert(dbinit, '')
  local lsqlite3 = require('lsqlite3')
  local db = lsqlite3.open_memory()
  assert(db:exec(table.concat(dbinit, ';\n')) == lsqlite3.OK)
  return db
end

-- TODO precompute sqlite dbs to avoid needing this hack for test performance
local cache = {}
return function(p)
  if not cache[p] then
    cache[p] = mkdb(p)
  end
  return cache[p]
end
