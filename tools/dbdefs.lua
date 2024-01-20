local function colsig(col, ty)
  if ty == 'string' or ty == 'locstring' then
    return 's'
  elseif ty == 'float' then
    return '.' -- luadbc is sometimes broken on floats :(
  elseif ty == 'int' then
    assert(col.size <= 32, 'wide ints not supported')
    return col.unsigned and 'u' or 'i'
  else
    error('invalid column type ' .. ty)
  end
end

local function mksig(dcols, bcols)
  local types = {}
  for _, dc in ipairs(dcols) do
    types[dc.name] = dc.type
  end
  local sig = ''
  local fields = {}
  local idx = 1
  for _, bc in ipairs(bcols) do
    local isID = false
    local isInline = true
    local isRelation = false
    if bc.annotations then
      for _, a in ipairs(bc.annotations) do
        isID = isID or a == 'id'
        isInline = isInline and a ~= 'noninline'
        isRelation = isRelation or a == 'relation'
      end
    end
    if isInline then
      local cs = colsig(bc, types[bc.name])
      if bc.length then
        cs = cs .. string.rep('.', bc.length - 1)
      end
      sig = sig .. cs
      fields[bc.name] = idx
      idx = idx + (bc.length or 1)
    elseif isRelation then
      sig = sig .. 'F'
      fields[bc.name] = idx
      idx = idx + 1
    elseif isID then
      fields[bc.name] = 0
    else
      error('invalid column')
    end
  end
  return sig, fields
end

local function defs(product)
  local build = require('wowapi.yaml').parseFile('data/products/' .. product .. '/build.yaml')
  local bv = build.version .. '.' .. build.build
  local t = {}
  for _, db in ipairs(dofile('build/products/' .. product .. '/dblist.lua')) do
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
    local sig, field2index = mksig(dbd.columns, v.columns)
    t[db] = {
      field2index = field2index,
      sig = sig,
    }
  end
  return t
end

local args = (function()
  local parser = require('argparse')()
  parser:argument('product', 'product to process')
  return parser:parse()
end)()

local deps = {}
for _, db in ipairs(dofile('build/products/' .. args.product .. '/dblist.lua')) do
  deps['vendor/dbdefs/definitions/' .. db .. '.dbd'] = true
end

local outfile = 'build/products/' .. args.product .. '/dbdefs.lua'
local u = require('tools.util')
u.writedeps(outfile, deps)
u.writeifchanged(outfile, u.returntable(defs(args.product)))
