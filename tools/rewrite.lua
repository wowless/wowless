local writeFile = require('pl.file').write
local yaml = require('wowapi.yaml')

local function rewriteFile(ty, fn)
  for _, p in ipairs(dofile('build/cmake/runtime/products.lua')) do
    local filename = 'data/products/' .. p .. '/' .. ty .. '.yaml'
    local before = require('pl.file').read(filename)
    local data = yaml.parse(before)
    fn(p, data)
    local after = yaml.pprint(data)
    if after ~= before then
      writeFile(filename, after)
    end
  end
end

local function rewriteTable(x, y)
  for xk, xv in pairs(x) do
    if type(xv) ~= 'table' then
      y[xk] = xv
    else
      y[xk] = y[xk] or {}
      rewriteTable(xv, y[xk])
    end
  end
end

local function rewriteFiles(z)
  for zk, zv in pairs(z) do
    rewriteFile(zk, function(_, t)
      rewriteTable(zv, t)
    end)
  end
end

local function rewriteSpecs(fn)
  rewriteFile('apis', function(_, t)
    for _, api in pairs(t) do
      for _, i in ipairs(api.inputs or {}) do
        fn(i)
      end
      for _, o in ipairs(api.outputs or {}) do
        fn(o)
      end
    end
  end)
  rewriteFile('events', function(_, t)
    for _, ev in pairs(t) do
      for _, f in ipairs(ev.payload or {}) do
        fn(f)
      end
    end
  end)
  rewriteFile('structures', function(_, t)
    for _, st in pairs(t) do
      for _, f in pairs(st.fields) do
        fn(f)
      end
    end
  end)
end

local function align(ty, fn)
  local t = {}
  for _, p in ipairs(dofile('build/cmake/runtime/products.lua')) do
    local filename = 'data/products/' .. p .. '/' .. ty .. '.yaml'
    t[p] = {
      before = require('pl.file').read(filename),
      filename = filename,
    }
  end
  local r = {}
  for p, z in pairs(t) do
    for k, v in pairs(yaml.parse(z.before)) do
      r[k] = r[k] or {}
      r[k][p] = v
    end
  end
  fn(r)
  local s = {}
  for k, z in pairs(r) do
    for p, v in pairs(z) do
      s[p] = s[p] or {}
      s[p][k] = v
    end
  end
  for p, z in pairs(t) do
    local after = yaml.pprint(s[p])
    if after ~= z.before then
      writeFile(z.filename, after)
    end
  end
end

local args = (function()
  local parser = require('argparse')()
  parser:argument('program', 'program.lua')
  return parser:parse()
end)()

local fn = assert(loadfile(args.program))
fn({
  align = align,
  file = rewriteFile,
  files = rewriteFiles,
  specs = rewriteSpecs,
})
