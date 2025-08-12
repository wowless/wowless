local specs = require('runtime.modules')
local sorted = require('pl.tablex').sort

local tt = require('resty.tsort').new()
for k, v in pairs(specs) do
  tt:add(k)
  for d in pairs(v.deps or {}) do
    tt:add(d, k)
  end
end
local specorder = assert(tt:sort())

return function(roots)
  local modules = {}
  local function make(m)
    local spec = specs[m]
    if spec.root then
      return assert(roots[m] or loadstring_untainted('return ' .. spec.root.default)())
    else
      local deps = {}
      for d in sorted(spec.deps) do
        table.insert(deps, (assert(modules[d])))
      end
      return require('wowless.modules.' .. m)(unpack(deps))
    end
  end
  for _, m in ipairs(specorder) do
    modules[m] = make(m)
  end
  return modules
end
