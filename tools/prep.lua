local args = (function()
  local parser = require('argparse')()
  parser:argument('product', 'product to fetch')
  return parser:parse()
end)()

local product = args.product
local function parseYaml(...)
  return (assert(require('wowapi.yaml').parseFile(...)))
end
local function readFile(...)
  return (assert(require('pl.file').read(...)))
end

local apis = {}
local impls = {}
local sqlcursors = {}
local sqllookups = {}
do
  local cfg = parseYaml('data/products/' .. product .. '/apis.yaml')
  for name, apiname in pairs(cfg) do
    local apicfg = parseYaml('data/api/' .. apiname .. '.yaml')
    if not apicfg.debug then
      if apicfg.status == 'implemented' and not impls[apiname] then
        impls[apiname] = readFile('data/impl/' .. apiname .. '.lua')
      end
      for _, sql in ipairs(apicfg.sqls or {}) do
        if sql.cursor then
          sqlcursors[sql.cursor] = readFile('data/sql/cursor/' .. sql.cursor .. '.sql')
        elseif sql.lookup then
          sqllookups[sql.lookup] = readFile('data/sql/lookup/' .. sql.lookup .. '.sql')
        end
      end
      apis[name] = apicfg
    end
  end
end

local data = {
  apis = apis,
  build = parseYaml('data/products/' .. product .. '/build.yaml'),
  cvars = parseYaml('data/products/' .. product .. '/cvars.yaml'),
  globals = parseYaml('data/products/' .. product .. '/globals.yaml'),
  impls = impls,
  sqlcursors = sqlcursors,
  sqllookups = sqllookups,
}
local txt = 'return ' .. require('pl.pretty').write(data)
require('pl.file').write('build/products/' .. args.product .. '/data.lua', txt)
