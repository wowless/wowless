local dbcrows = require('tools.dbc').rows
local db2rows = require('tools.db2').rows
local deepcompare = require('pl.tablex').deepcompare
local readfile = require('pl.file').read
local sorted = require('pl.tablex').sort

local function collect(fn, data, sig)
  local rows = {}
  for row in fn(data, sig) do
    table.insert(rows, row)
  end
  return rows
end

local function compare(product)
  local defs = dofile('build/products/' .. product .. '/dbdefs.lua')
  for k, v in sorted(defs) do
    local data = readfile('extracts/' .. product .. '/db2/' .. k .. '.db2')
    local sa, a = pcall(collect, dbcrows, data, v)
    local sb, b = pcall(collect, db2rows, data, v)
    if not sa or not sb then
      print(k .. ': error' .. (not sb and ': ' .. b or ''))
    elseif deepcompare(a, b) then
      print(k .. ': success')
    else
      print(k .. ': failure')
    end
  end
end

local args = (function()
  local parser = require('argparse')()
  parser:argument('product', 'product to check')
  return parser:parse()
end)()

compare(args.product)
