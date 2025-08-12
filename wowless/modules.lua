local specs = {
  addons = {},
  api = {
    deps = {
      'datalua',
      'env',
      'events',
      'log',
      'loglevel',
      'parentkey',
      'scripts',
      'templates',
      'time',
      'uiobjects',
      'visibility',
    },
  },
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
  loader = {
    deps = { 'addons', 'api', 'datalua', 'events', 'loadercfg', 'log', 'loglevel', 'scripts', 'security', 'templates' },
  },
  loadercfg = {
    default = {},
    root = true,
  },
  log = {
    default = function() end,
    root = true,
  },
  loglevel = {
    default = 0,
    root = true,
  },
  macrotext = {
    deps = { 'security' },
  },
  maxErrors = {
    default = 0,
    root = true,
  },
  parentkey = {},
  platform = {},
  scripts = {
    deps = { 'env', 'log', 'security' },
  },
  security = {
    deps = { 'log', 'maxErrors' },
  },
  system = {},
  talents = {},
  templates = {
    deps = { 'log' },
  },
  time = {
    deps = { 'log', 'security' },
  },
  typecheck = {
    deps = { 'addons', 'datalua', 'env', 'uiobjects', 'units' },
  },
  uiobjects = {},
  units = {},
  visibility = {
    deps = { 'scripts' },
  },
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
    modules[m] = spec.root and assert(roots[m] or spec.default)
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
