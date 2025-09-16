local function defs(product, sourcedir)
  local build = dofile('runtime/products/' .. product .. '/build.lua')
  local bv = build.version .. '.' .. build.build
  local t = {}
  for db in pairs(dofile('runtime/' .. product .. '_dblist.lua')) do
    local content = assert(require('pl.file').read(sourcedir .. '/vendor/dbdefs/definitions/' .. db .. '.dbd'))
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
    local types = {}
    for _, dc in ipairs(dbd.columns) do
      types[dc.name] = dc.type
    end
    local tt = {}
    for _, vc in pairs(v.columns) do
      local aa = {}
      for _, a in ipairs(vc.annotations or {}) do
        aa[a] = true
      end
      local ty = types[vc.name]
      table.insert(tt, {
        id = aa.id,
        length = vc.length,
        name = assert(vc.name),
        noninline = aa.noninline,
        relation = aa.relation,
        size = vc.size,
        type = ty == 'locstring' and 'string' or ty,
        unsigned = vc.unsigned,
      })
    end
    t[db] = tt
  end
  return t
end

local args = (function()
  local parser = require('argparse')()
  parser:argument('product', 'product to process')
  parser:argument('sourcedir', 'sourcedir')
  return parser:parse()
end)()

local deps = {}
for db in pairs(dofile('runtime/' .. args.product .. '_dblist.lua')) do
  deps[args.sourcedir .. '/vendor/dbdefs/definitions/' .. db .. '.dbd'] = true
end

local outfile = 'generated/' .. args.product .. '_dbdefs.lua'
local u = require('tools.util')
u.writedeps(outfile, deps)
u.writeifchanged(outfile, u.returntable(defs(args.product, args.sourcedir)))
