local writeFile = require('pl.file').write
local yaml = require('wowapi.yaml')

local function rewriteFile(ty, fn)
  for _, p in ipairs(require('wowless.util').productList()) do
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

local function rewriteTypes(fn)
  rewriteFile('apis', function(_, t)
    for _, api in pairs(t) do
      for _, ii in ipairs(api.inputs or {}) do
        for _, i in ipairs(ii) do
          fn(i.type)
        end
      end
      for _, o in ipairs(api.outputs or {}) do
        fn(o.type)
      end
    end
  end)
  rewriteFile('events', function(_, t)
    for _, ev in pairs(t) do
      for _, f in ipairs(ev.payload or {}) do
        fn(f.type)
      end
    end
  end)
  rewriteFile('structures', function(_, t)
    for _, st in pairs(t) do
      for _, f in pairs(st.fields) do
        fn(f.type)
      end
    end
  end)
end

return {
  file = rewriteFile,
  types = rewriteTypes,
}
