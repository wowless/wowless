local specs = {
  addons = {},
  calendar = {},
  cvars = {
    deps = { 'datalua' },
  },
  datalua = {
    root = true,
  },
  datetime = {
    deps = { 'datalua' },
  },
  env = {},
  events = {
    deps = { 'datalua', 'funcheck', 'log', 'loglevel', 'scripts' },
  },
  funcheck = {
    deps = { 'typecheck', 'log' },
  },
  log = {
    root = true,
  },
  loglevel = {
    root = true,
  },
  macrotext = {
    deps = { 'security' },
  },
  maxErrors = {
    root = true,
  },
  platform = {},
  scripts = {
    deps = { 'security' },
  },
  security = {
    deps = { 'log', 'maxErrors' },
  },
  system = {},
  talents = {},
  time = {
    deps = { 'log', 'security' },
  },
  typecheck = {
    deps = { 'addons', 'datalua', 'env', 'uiobjects', 'units' },
  },
  uiobjects = {},
  units = {},
}

local tt = require('resty.tsort').new()
for k, v in pairs(specs) do
  assert(not v.root or not v.deps)
  tt:add(k)
  for _, vv in ipairs(v.deps or {}) do
    assert(specs[vv])
    tt:add(vv, k)
  end
end
local specorder = assert(tt:sort())

return function(roots)
  local modules = {}
  for _, m in ipairs(specorder) do
    local spec = specs[m]
    modules[m] = spec.root and assert(roots[m])
      or (function()
        local deps = {}
        for _, d in ipairs(spec.deps or {}) do
          table.insert(deps, (assert(modules[d])))
        end
        return require('wowless.modules.' .. m)(unpack(deps))
      end)()
  end
  return modules
end
