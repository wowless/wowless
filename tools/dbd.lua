local dbds = (function()
  local dbcsig = require('luadbd.sig')

  local dbdMT = {
    __index = {
      build = require('luadbd.build'),
    },
  }

  local buildMT = {
    __index = {
      rows = require('luadbd.dbcwrap').build,
    },
  }

  local db2s = (function()
    local t = {}
    local listfile = require('pl.file').read('vendor/listfile/community-listfile.csv')
    for line in listfile:gmatch('[^\r\n]+') do
      local id, name = line:match('(%d+);dbfilesclient/([a-z0-9-_]+).db2')
      if id then
        t[name] = tonumber(id)
      end
    end
    return t
  end)()

  local dbds = (function()
    local t = {}
    local dbdparse = require('luadbd.parser').dbd
    for _, f in ipairs(require('pl.dir').getfiles('vendor/dbdefs/definitions')) do
      local tn = assert(f:match('vendor/dbdefs/definitions/(.*)%.dbd'))
      local dbd = assert(dbdparse(require('pl.file').read(f)))
      dbd.name = tn
      t[string.lower(tn)] = dbd
    end
    return t
  end)()

  local ret = {}
  for tn, dbd in pairs(dbds) do
    local fdid = db2s[tn]
    if fdid then
      dbd.fdid = fdid
      ret[tn] = setmetatable(dbd, dbdMT)
      for _, version in ipairs(dbd.versions) do
        local sig, fields = dbcsig(dbd, version)
        version.sig = sig
        version.fields = fields
        version.rowMT = {
          __index = function(t, k)
            local i = fields[k]
            return i and t[i] or nil
          end,
        }
        setmetatable(version, buildMT)
      end
    end
  end
  return ret
end)()

local dblist = require('tools.dblist')
local ret = {}
local builds = require('wowapi.data').builds
for product, build in pairs(builds) do
  for _, db in ipairs(dblist(product)) do
    db = db:lower()
    local dbd = dbds[db]
    local v = (function()
      for _, version in ipairs(dbd.versions) do
        for _, vb in ipairs(version.builds) do
          if #vb == 1 and table.concat(vb[1], '.') == build.version .. '.' .. build.build then
            return version
          end
        end
      end
      error('cannot find build ' .. build.version .. ' for product ' .. product)
    end)()
    if not ret[dbd.name] then
      ret[dbd.name] = {
        fdid = dbd.fdid,
        name = dbd.name,
        versions = {
          {
            fields = v.fields,
            products = { product },
            sig = v.sig,
          },
        },
      }
    else
      local mine = {
        fields = v.fields,
        sig = v.sig,
      }
      local match = nil
      for _, x in ipairs(ret[dbd.name].versions) do
        local theirs = {
          fields = x.fields,
          sig = x.sig,
        }
        if require('pl.tablex').deepcompare(mine, theirs) then
          match = x
        end
      end
      if match then
        table.insert(match.products, product)
        table.sort(match.products)
      else
        table.insert(ret[dbd.name].versions, {
          fields = v.fields,
          products = { product },
          sig = v.sig,
        })
      end
    end
  end
end
do
  local p = require('wowapi.yaml').pprint
  local w = require('pl.file').write
  for _, v in pairs(ret) do
    w('data/dbdefs/' .. v.name .. '.yaml', p(v))
  end
end
