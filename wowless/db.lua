local dbs = {}
for dbname, dbdef in pairs(require('wowapi.data').dbdefs) do
  local dbdata = {}
  for _, version in ipairs(dbdef.versions) do
    local fields = version.fields
    local versiondata = {
      metatable = {
        __index = function(t, k)
          local i = fields[k]
          return i and t[i] or nil
        end,
      },
      sig = '{' .. version.sig .. '}',
    }
    for _, product in ipairs(version.products) do
      dbdata[product] = versiondata
    end
  end
  dbs[dbname] = dbdata
end

local dbcrows = require('dbc').rows

local function rows(product, dbname, data)
  local db = assert(dbs[dbname], 'invalid db ' .. dbname)[product]
  local iterfn, iterdata = dbcrows(data, db.sig)
  local function wrapfn(...)
    local t = iterfn(...)
    return t and setmetatable(t, db.metatable) or nil
  end
  return wrapfn, iterdata
end

return rows
