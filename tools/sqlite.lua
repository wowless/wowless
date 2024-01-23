local lsqlite3 = require('lsqlite3')
local sqlquote = require('tools.sqlite3ext').quote

local indexes = {
  SpecSetMember = { 'SpecSetMember (SpecSet)' },
  TraitNodeGroupXTraitCond = { 'TraitNodeGroupXTraitCond (TraitNodeGroupID)' },
  TraitNodeGroupXTraitNode = { 'TraitNodeGroupXTraitNode (TraitNodeID)' },
  TraitNodeXTraitCond = { 'TraitNodeXTraitCond (TraitNodeID)' },
  TraitNodeXTraitNodeEntry = { 'TraitNodeXTraitNodeEntry (TraitNodeID)' },
  UiTextureAtlasMember = { 'UiTextureAtlasMember (CommittedName COLLATE NOCASE)' },
}

local function factory(theProduct)
  local defs = dofile('build/products/' .. theProduct .. '/dbdefs.lua')

  local function create(filename)
    local dbinit = { 'BEGIN' }
    for k, v in pairs(defs) do
      local fieldnames = {}
      local hasid = false
      for _, f in ipairs(v) do
        table.insert(fieldnames, f.name)
        hasid = hasid or f.id
      end
      table.insert(dbinit, ('CREATE TABLE %s ("%s")'):format(k, table.concat(fieldnames, '","')))
      if hasid then
        table.insert(dbinit, ('CREATE INDEX %sIndexID ON %s (ID)'):format(k, k))
      end
      if indexes[k] then
        for i, index in ipairs(indexes[k]) do
          table.insert(dbinit, ('CREATE INDEX %sIndex%d ON %s'):format(k, i, index))
        end
      end
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
        for row in require('tools.dbc').rows(data, v) do
          local values = {}
          for fk in ipairs(v) do
            local value = row[fk]
            local ty = type(value)
            if ty == 'nil' then
              value = 'NULL'
            elseif ty == 'string' then
              value = '\'' .. sqlquote(value) .. '\''
            elseif ty == 'number' then
              value = tostring(value)
            else
              error('unexpected value of type ' .. ty .. ' on field ' .. fk .. ' of table ' .. k)
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
local filename = ('build/products/%s/%s.sqlite3'):format(args.product, filebase)

require('pl.file').delete(filename)
local create, populate = factory(args.product)
local db = create(filename)
if args.full then
  populate(db)
end
db:close()
